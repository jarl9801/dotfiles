---
name: wiki-compile
description: Compile, lint, and maintain the personal knowledge base wiki. Finds contradictions, suggests new articles, builds connections, and keeps the index up to date.
---

# Wiki Compile — Knowledge Base Maintenance

Maintain and improve the AXON personal knowledge base at `~/.openclaw/workspace/knowledge/`.

## When to Use

Use this skill when the user:
- Says "compile wiki", "lint wiki", "wiki health check", "maintain wiki"
- Asks "what's missing in my knowledge base?"
- Asks "what should I read next?"
- Says "connect my articles", "find gaps"
- On a scheduled cron job (recommended: daily or weekly)

## Maintenance Tasks

### 1. Index Rebuild
Scan all `knowledge/wiki/*/` directories and rebuild `_index.md`:
- Count articles per topic
- Count total words
- List recent activity
- Update stats

### 2. Orphan Detection
Find articles with zero incoming backlinks.
- Suggest connections to existing articles
- If truly isolated, flag for review

### 3. Contradiction Detection
Compare claims across articles:
- Look for conflicting numbers, dates, or statements
- Flag with `⚠️ CONTRADICTION` comment in both articles
- Log in `_index.md` under a Contradictions section

### 4. Gap Analysis
Based on existing articles, identify:
- Concepts referenced but not yet explained (broken [[wikilinks]])
- Topics with few articles compared to depth of related topics
- Open Questions from existing articles that could become new articles
- Suggest a prioritized list of "articles to create next"

### 5. Cross-linking Pass
For each article:
- Scan all other articles for shared concepts/terms
- Add missing `[[wikilinks]]` where relevant
- Update `related:` frontmatter field

### 6. Raw Processing Check
Scan `knowledge/raw/*/` for unprocessed files:
- Files without a corresponding wiki article
- Files with `ingested: false` in frontmatter
- Report count and suggest ingestion

### 7. Quality Scoring
Score each article (0-100):
- Has summary: +20
- Has 3+ tags: +10
- Has sources: +15
- Has connections: +15
- 500+ words: +15
- Updated in last 30 days: +10
- No open contradictions: +15
- Report average score per topic and overall

## Output Format

After running, produce a report:

```markdown
# Wiki Health Report — {DATE}

## Stats
- Total articles: X
- Total words: ~Xk
- Raw pending: X items

## Health Score: X/100

## By Topic
| Topic | Articles | Words | Avg Score | Pending Raw |
|---|---|---|---|---|

## Issues Found
### Contradictions (X)
- ...

### Orphan Articles (X)
- ...

### Broken Links (X)
- ...

## Suggested Next Articles
1. ...
2. ...
3. ...

## Suggested Connections
- ...
```

Save this report to `knowledge/_reports/health_{YYYY-MM-DD}.md`

## Scheduling
Recommended: run `wiki-compile` weekly via AXON cron.
Can also run on-demand after a batch ingestion.
