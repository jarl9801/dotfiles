---
name: obsidian
description: Read, search, and create notes in the Obsidian vault.
---

# Obsidian Vault

**Vault Discovery Strategy:**

1. Check `OBSIDIAN_VAULT_PATH` env var first
2. Check `~/Documents/Obsidian Vault` (default)
3. Check `~/Library/Mobile Documents/com~apple~CloudDocs/` (iCloud path)
4. Check Desktop for emoji folders (`📄 Documents/`, `📊 Spreadsheets/`)
5. **If none found:** Ask user for the path directly — they may have iCloud sync issues or non-standard location

**Important:** If `~/Library/Mobile Documents/com~apple~CloudDocs/` is empty, the vault hasn't been synced locally. Ask user to open Obsidian and confirm the vault is downloaded. Broad `find` searches on Mac home directory timeout easily — avoid.

Note: Vault paths may contain spaces - always quote them.

## Read a note

```bash
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/Documents/Obsidian Vault}"
cat "$VAULT/Note Name.md"
```

## List notes

```bash
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/Documents/Obsidian Vault}"

# All notes
find "$VAULT" -name "*.md" -type f

# In a specific folder
ls "$VAULT/Subfolder/"
```

## Search

```bash
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/Documents/Obsidian Vault}"

# By filename
find "$VAULT" -name "*.md" -iname "*keyword*"

# By content
grep -rli "keyword" "$VAULT" --include="*.md"
```

## Create a note

```bash
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/Documents/Obsidian Vault}"
cat > "$VAULT/New Note.md" << 'ENDNOTE'
# Title

Content here.
ENDNOTE
```

## Append to a note

```bash
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/Documents/Obsidian Vault}"
echo "
New content here." >> "$VAULT/Existing Note.md"
```

## Wikilinks

Obsidian links notes with `[[Note Name]]` syntax. When creating notes, use these to link related content.
