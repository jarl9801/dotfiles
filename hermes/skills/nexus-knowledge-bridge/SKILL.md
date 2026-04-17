---
name: nexus-knowledge-bridge
description: Query and write to the shared knowledge base (Nexus Knowledge Bridge) used by both Hermes and OpenClaw. Use before answering complex queries about past projects, decisions, or user profile; use after completing important tasks to save structured memories.
category: memory
---

# Nexus Knowledge Bridge — Shared Memory for Hermes

## What This Is

A FastAPI service (`ai.nexus.bridge`) running on the Mac mini that stores structured memories, project metadata, user profile, and documents. Shared between Hermes and OpenClaw so both agents see the same knowledge.

**Stack:** FastAPI + SQLite + ChromaDB + Ollama embeddings (`nomic-embed-text`)
**Location on disk:** `~/Dev/nexus-knowledge-bridge/`
**Launchd label:** `ai.nexus.bridge`

## Bridge URL Resolution

Hermes MUST resolve the Bridge URL in this order:

1. Environment variable `$NEXUS_BRIDGE_URL` if set
2. Otherwise default to `http://localhost:8000`

Always use `${NEXUS_BRIDGE_URL:-http://localhost:8000}` in shell commands and the equivalent pattern in Python:

```python
import os
BRIDGE_URL = os.environ.get("NEXUS_BRIDGE_URL", "http://localhost:8000")
```

**Expected config by machine:**

| Machine | NEXUS_BRIDGE_URL value |
|---|---|
| Mac mini (runs the Bridge) | unset (uses localhost default) |
| MacBook Air (via Tailscale) | `http://100.108.69.7:8000` (set in `~/.zshrc`) |

## When to Use This Skill

### BEFORE answering complex or contextual queries
When the user asks about: past projects, previous decisions, their profile/preferences, documents they shared, or uses possessives like "my project", "our work", "we decided":

1. Call `POST /knowledge/context` with the user's query
2. Inject retrieved context as reference when composing the answer
3. Never claim "I don't remember" without first checking the Bridge

### AFTER completing important tasks
When a task produces a concrete decision, plan, fact, or artifact worth remembering:

1. Build a structured memory (title, summary, facts, tags)
2. POST to `/memory/write`
3. Never overwrite — writes create new versions

### SKIP the Bridge for
- Small talk, greetings, one-off factual questions
- Math, coding help not tied to a user project
- Anything where generic knowledge suffices

## Core Operations

### Health check before use

```bash
curl -s -o /dev/null -w "%{http_code}\n" ${NEXUS_BRIDGE_URL:-http://localhost:8000}/health
```

Must return `200`. If not, see Troubleshooting.

### Build context for a query (primary read operation)

```bash
curl -s -X POST ${NEXUS_BRIDGE_URL:-http://localhost:8000}/knowledge/context \
  -H "Content-Type: application/json" \
  -d '{
    "query": "user question here",
    "project_id": "HMR-Nexus",
    "include_profile": true,
    "include_memories": true,
    "include_documents": false,
    "include_skills": false,
    "top_k": 5
  }'
```

Python equivalent:

```python
import os, requests

BRIDGE = os.environ.get("NEXUS_BRIDGE_URL", "http://localhost:8000")

def get_context(query, project_id=None, top_k=5):
    r = requests.post(f"{BRIDGE}/knowledge/context", json={
        "query": query,
        "project_id": project_id,
        "include_profile": True,
        "include_memories": True,
        "include_documents": False,
        "include_skills": False,
        "top_k": top_k,
    }, timeout=5)
    r.raise_for_status()
    return r.json()
```

### Search memories (narrower than context)

```bash
curl -s -X POST ${NEXUS_BRIDGE_URL:-http://localhost:8000}/memory/search \
  -H "Content-Type: application/json" \
  -d '{"query": "fincontrol", "top_k": 5}'
```

### Write a new memory (primary write operation)

```bash
curl -s -X POST ${NEXUS_BRIDGE_URL:-http://localhost:8000}/memory/write \
  -H "Content-Type: application/json" \
  -d '{
    "source": "hermes",
    "memory_type": "decision",
    "title": "Stack decidido para Lumen",
    "summary": "Se eligió React 19 + Supabase + Vite + Tailwind v4 para Lumen.",
    "facts": ["React 19 por hooks nativos", "Supabase por auth fácil"],
    "tags": ["lumen", "stack", "decisión"],
    "project_id": "Lumen",
    "confidence": 0.9
  }'
```

**Required fields:** `source`, `memory_type`, `title`, `summary`
**Recommended:** `facts` (array), `tags` (array), `project_id`, `confidence` (0.0–1.0)
**Valid `memory_type`:** `profile`, `project_context`, `decision`, `fact`, `preference`, `skill`, `conversation_summary`, `general``

### Get user profile

```bash
curl -s ${NEXUS_BRIDGE_URL:-http://localhost:8000}/profile/jarl
```

### List projects

```bash
curl -s ${NEXUS_BRIDGE_URL:-http://localhost:8000}/projects
```

### Stats (health indicator)

```bash
curl -s ${NEXUS_BRIDGE_URL:-http://localhost:8000}/stats
```

Returns memory count, project count, document count, dedup groups.

## Writing Good Memories — Style Guide

Good memories are:

- **Atomic:** one decision or fact per memory, not a whole conversation
- **Titled for retrieval:** title must be searchable with 2–3 keywords
- **Summary in user's words:** use the user's terminology (`UMTELKOMD`, `NEXUS`, `Fincontrol`) not generic rephrasing
- **Tagged generously:** 3–6 tags; include project, domain, type
- **Attributed with confidence:** 0.9+ for explicit user decisions, 0.6–0.8 for inferences, skip below 0.5

Bad memory example (too vague):

```json
{"title": "User talked about work", "summary": "User mentioned something about his company."}
```

Good memory example:

```json
{
  "title": "NEXUS ownership split confirmed",
  "summary": "NEXUS (HMR Nexus Engineering GmbH) has three partners: Andres 30%, Isabelle Horstmann 30%, third partner TBD at 40%.",
  "facts": [
    "Andres: 30%",
    "Isabelle Horstmann: 30%",
    "Third partner: TBD 40%",
    "Legal entity name: HMR Nexus Engineering GmbH"
  ],
  "tags": ["nexus", "ownership", "structure", "partnership"],
  "project_id": "HMR-Nexus",
  "source": "hermes",
  "memory_type": "fact",
  "confidence": 1.0
}
```

## Security Rules

1. **Read/write knowledge only** — this skill never executes user commands
2. **Never leak raw memories** to external services or logs
3. **Sanitize before indexing** — trust the exporter; don't hand-craft raw dumps
4. **Writes are versioned** — never try to update in place
5. **Trace everything** — all writes land in the `write_log` table automatically

## Available Endpoints

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/health` | Liveness check |
| GET | `/stats` | Memory/project counts |
| GET | `/profile/{user_id}` | User profile |
| GET | `/projects` | List projects |
| GET | `/projects/{project_id}` | Project detail |
| POST | `/memory/search` | Keyword + semantic search |
| POST | `/memory/write` | Create new memory |
| GET | `/memory/{memory_id}` | Fetch specific memory |
| POST | `/knowledge/context` | Full context builder (preferred for reads) |
| POST | `/knowledge/documents/search` | Document search |
| POST | `/knowledge/documents/ingest` | Add document |
| POST | `/knowledge/documents/ingest/path` | Ingest local file |
| POST | `/knowledge/search/hybrid` | Hybrid FTS + semantic search |
| POST | `/knowledge/fts/rebuild` | Rebuild full-text index |
| GET | `/skills` | List shared skills |
| POST | `/projects` | Create project |
| GET | `/admin/audit` | Write log audit |
| POST | `/admin/deduplicate` | Merge duplicates |

## Memory Ranking (for awareness)

The Bridge ranks memories with a weighted score:

- 40% semantic similarity (ChromaDB)
- 20% recency (≤30 days boost)
- 20% project match
- 10% source reliability (`user` 1.0 > `hermes`/`openclaw` 0.9)
- 10% memory type priority

Higher `confidence` on writes improves future retrieval ranking.

## Troubleshooting

**`curl` returns empty / connection refused:**
- On Mac mini: `launchctl kickstart -k "gui/$(id -u)/ai.nexus.bridge"`
- On MacBook: check Tailscale is up and `NEXUS_BRIDGE_URL` is set to `http://100.108.69.7:8000`
- Logs: `tail -50 ~/Dev/nexus-knowledge-bridge/logs/bridge.err.log`

**`/stats` returns 0 memories:**
- Data wasn't ingested. Run on the Mini:
```bash
  cd ~/Dev/nexus-knowledge-bridge
  source .venv/bin/activate
  python -m exporter.openclaw_exporter --full --output data/export.json
  python -m scripts.ingest --input data/export.json --profile --projects
```

**Slow responses (>2s):**
- Ollama may be cold. Warm up: `curl http://localhost:11434/api/embeddings -d '{"model":"nomic-embed-text","prompt":"warmup"}'`
- ChromaDB may need reindexing: `curl -X POST ${NEXUS_BRIDGE_URL:-http://localhost:8000}/knowledge/fts/rebuild`

**Writes succeed but search doesn't find them:**
- Semantic indexing is async. Wait 5-10s, then retry search.
- If persistent: `python -m scripts.reindex_vectors`

## File Locations

| What | Path (on Mac mini) |
|---|---|
| Code | `~/Dev/nexus-knowledge-bridge/` |
| SQLite DB | `~/Dev/nexus-knowledge-bridge/data/knowledge.db` |
| Chroma vectors | `~/Dev/nexus-knowledge-bridge/data/chroma_vectors_clean/` |
| Logs | `~/Dev/nexus-knowledge-bridge/logs/bridge.*.log` |
| LaunchAgent | `~/Library/LaunchAgents/ai.nexus.bridge.plist` |