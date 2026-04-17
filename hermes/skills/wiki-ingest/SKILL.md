---
name: wiki-ingest
description: Ingest raw materials (URLs, files, text, PDFs, images) into the personal knowledge base wiki. Summarizes, extracts key concepts, creates wiki articles, and updates the index.
---

# Wiki Ingest — Personal Knowledge Base

Ingest raw material into the AXON personal knowledge base at `~/.openclaw/workspace/knowledge/`.

## When to Use

Use this skill when the user:
- Shares a URL, article, paper, or file to "add to the wiki" or "save this"
- Drops content into `knowledge/raw/` and asks to process it
- Says "ingest this", "add to knowledge base", "wiki this", "save to wiki"
- Shares information about AI/agents, finance, or civil engineering topics

## Topics

| ID | Folder | Scope |
|---|---|---|
| `ai` | `wiki/ai-agents/` | IA, LLMs, agentes, frameworks, RAG, fine-tuning, MLOps |
| `fin` | `wiki/finance/` | Finanzas empresariales, contabilidad, inversión, mercados |
| `ce` | `wiki/civil-engineering/` | Análisis estructural, diseño, materiales, normativas, cálculo |

## Ingestion Process

### Step 1: Classify
Determine the topic (ai, fin, ce) from the content. If ambiguous, ask the user.

### Step 2: Extract
- If URL: use `summarize` CLI or web fetch to get content
- If file (PDF, image): read/describe the content
- If raw text: use directly
- Save original to `knowledge/raw/{topic}/` with date prefix

### Step 3: Check Duplicates
Search existing wiki articles in `knowledge/wiki/{topic}/` for overlapping concepts.
- If strong overlap: UPDATE the existing article instead of creating new
- If partial overlap: create new article with backlinks to existing

### Step 4: Create Wiki Article
Use the template at `knowledge/_templates/article.md`:

```markdown
---
title: "Descriptive Title"
topic: "{topic_id}"
tags: [tag1, tag2, tag3]
sources:
  - "original URL or filename"
related:
  - "[[Related Article Name]]"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
status: published
---

# Title

## Summary
2-3 sentence overview of the key insight.

## Key Concepts
Main content organized with clear headers.
Use [[wikilinks]] to connect to other articles.

## Connections
How this relates to other knowledge in the wiki.

## Open Questions
Things worth investigating further.

## Sources
- [Source Name](URL)
```

### Step 5: Update Index
Update `knowledge/_index.md`:
- Increment article count for the topic
- Add entry to Recent Activity table
- Update "Last updated" date

### Step 6: Cross-link
Scan other articles in the wiki for concepts that relate to the new article.
Add `[[wikilinks]]` in both directions.

## File Naming Convention
Wiki articles: `{topic-folder}/{slug}.md`
- Use kebab-case slugs
- Be descriptive but concise
- Examples: `transformer-architecture.md`, `dcf-valuation.md`, `beam-deflection-methods.md`

Raw files: `raw/{topic}/{YYYY-MM-DD}_{original-name}.{ext}`

## Quality Standards
- Every article must have a Summary section
- Minimum 3 tags per article
- At least 1 cross-reference (related article or open question)
- No orphan articles (everything connects to something)
- Spanish or English based on source language; prefer Spanish for original content
