---
name: mac-mini-gateway
description: Mac mini M4 as always-on home server running Hermes, OpenClaw, and Nexus Knowledge Bridge — SSH access, Tailscale, service management, troubleshooting
category: devops
---

# Mac Mini Gateway — Home Server for Hermes Stack

## Context

Mac mini M4 (24 GB RAM) in Jarl's home office (Celle area, Germany). Always-on home server and Tailscale exit node. Runs the full agent stack.

## Connection

| Property | Value |
|---|---|
| Local hostname | `Mac` (Bonjour/mDNS) |
| SSH alias | `ssh mini` (configured in `~/.ssh/config`) |
| Tailscale IP | `100.108.69.7` |
| User | `jarl` |
| Home directory | `/Users/jarl` |

**From same network:** `ssh mini`
**From anywhere via Tailscale:** `ssh mini` (alias points to Tailscale IP)

## Services

| Service | Port | Launchd label | Purpose |
|---|---|---|---|
| Hermes gateway | — | `ai.hermes.gateway` | Primary agent gateway |
| OpenClaw gateway | 18789 | `ai.openclaw.gateway` | Multi-agent fleet coordinator |
| OpenClaw node | — | `ai.openclaw.node` | Remote node worker |
| Nexus Knowledge Bridge | 8000 | `ai.nexus.bridge` | Shared memory layer (FastAPI + SQLite + Chroma) |
| Ollama | 11434 | `com.ollama.ollama` | Local LLMs + embeddings (nomic-embed-text) |

## Restart a Service

Standard pattern for any of the services above:

    launchctl kickstart -k "gui/$(id -u)/<LABEL>"

Examples:

    # Hermes
    launchctl kickstart -k "gui/$(id -u)/ai.hermes.gateway"

    # Nexus Knowledge Bridge
    launchctl kickstart -k "gui/$(id -u)/ai.nexus.bridge"

## Quick Status Check

One-liner to run from any machine via SSH:

    ssh mini '
      echo "=== Launchd services ==="
      launchctl list | grep -E "ai\.(hermes|openclaw|nexus)|com\.ollama"
      echo ""
      echo "=== Ports listening ==="
      lsof -iTCP -sTCP:LISTEN -P -n 2>/dev/null | grep -E ":(8000|18789|11434) "
      echo ""
      echo "=== Knowledge Bridge health ==="
      curl -s http://localhost:8000/health
      echo ""
      echo "=== Bridge stats ==="
      curl -s http://localhost:8000/stats
    '

## Troubleshooting

**`ssh mini` gives "Connection timed out":**
- Mac mini may be off, or Tailscale down on the mini
- Need physical access to power on / open Tailscale menu bar app
- Tailscale CLI (when reachable): `/Applications/Tailscale.app/Contents/MacOS/Tailscale up`

**Nexus Bridge not responding (`curl http://mini:8000` fails):**
- Check service: `ssh mini 'launchctl list | grep nexus'` — look for pid greater than 0
- Kickstart: `ssh mini 'launchctl kickstart -k "gui/$(id -u)/ai.nexus.bridge"'`
- Logs: `ssh mini 'tail -50 ~/Dev/nexus-knowledge-bridge/logs/bridge.err.log'`

**OpenClaw gateway down:**
- `ssh mini 'launchctl kickstart -k "gui/$(id -u)/ai.openclaw.gateway"'`
- Verify: `curl http://100.108.69.7:18789/health`

**Hermes process exists but unresponsive:**
- `ssh mini 'launchctl kickstart -k "gui/$(id -u)/ai.hermes.gateway"'`
- Logs: `ssh mini 'tail -50 ~/.hermes/logs/gateway.log'`

**Tailscale shows IP 0.0.0.0 or "Stopped":**
- Open the app from menu bar → Connect
- Or: `/Applications/Tailscale.app/Contents/MacOS/Tailscale up`

## File Locations on Mac Mini

| What | Path |
|---|---|
| Hermes config | `~/.hermes/config.yaml` (symlink → `~/Dev/dotfiles/hermes/config.yaml`) |
| Hermes skills | `~/.hermes/skills/skills/` (symlink → `~/Dev/dotfiles/hermes/skills/`) |
| Hermes state DB | `~/.hermes/state.db` |
| Hermes sessions | `~/.hermes/sessions/` |
| Knowledge Bridge code | `~/Dev/nexus-knowledge-bridge/` |
| Knowledge Bridge data | `~/Dev/nexus-knowledge-bridge/data/knowledge.db` + `data/chroma_vectors_clean/` |
| Knowledge Bridge logs | `~/Dev/nexus-knowledge-bridge/logs/bridge.*.log` |
| Dotfiles repo | `~/Dev/dotfiles/` (github.com/jarl9801/dotfiles) |

## Known Issues

- `ai.openclaw.node` was last seen with exit status `1` (failed). Investigate when time permits: `launchctl print "gui/$(id -u)/ai.openclaw.node"` and check logs.s