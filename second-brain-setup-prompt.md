# Second Brain Setup

Set up a personal second brain vault for me. Follow the steps below exactly.

---

## Step 1 — Ask me these questions first (one at a time, wait for each answer before proceeding)

1. Where do you want the vault folder? (e.g. ~/Desktop/second-brain)
2. What is your name or handle? (used in note frontmatter)
3. Do you want to version the vault on Git/GitHub? (yes / no — completely optional)

---

## Step 2 — Create the folder structure

```
<vault>/
├── inbox/
├── journal/
│   ├── daily/
│   └── weekly/
├── projects/
├── areas/
├── resources/
│   ├── papers/
│   ├── tools/
│   ├── people/
│   └── concepts/
├── decisions/
├── preferences/
├── templates/
├── squads/
└── events/
```

Also create a `README.md` at the vault root with a brief description of each folder.

---

## Step 3 — Create the Obsidian config

Inside `<vault>/.obsidian/`, create:

**`app.json`**:
```json
{
  "legacyEditor": false,
  "livePreview": true,
  "defaultViewMode": "source",
  "foldHeading": true,
  "useTab": false,
  "tabSize": 2,
  "spellcheck": false,
  "strictLineBreaks": false,
  "showLineNumber": true
}
```

**`appearance.json`**:
```json
{
  "theme": "obsidian",
  "baseFontSize": 16
}
```

**`.gitignore`** at vault root (add regardless of Git choice — good hygiene):
```
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/cache
.obsidian/*.log
.DS_Store
```

---

## Step 4 — Create the templates

All files go in `templates/`. Use YAML frontmatter on every note.

**`templates/daily-note.md`**:
```markdown
---
type: journal
title: Daily — {{date}}
date: {{date}}
tags: []
author: <name>
---

## Focus
- 

## Notes
- 

## Decisions made
- 

## Tomorrow
- 
```

**`templates/decision-note.md`**:
```markdown
---
type: decision
title: 
date: {{date}}
project: 
status: draft   # draft | accepted | superseded | deprecated
tags: []
people: []
author: <name>
---

## Context


## Options considered
1. 
2. 

## Decision


## Consequences

```

**`templates/person-note.md`**:
```markdown
---
type: person
title: 
date: {{date}}
company: 
role: 
tags: []
author: <name>
---

## Contact


## Context


## Notes
- 

## Related
- 
```

**`templates/concept-note.md`**:
```markdown
---
type: concept
title: 
date: {{date}}
tags: []
author: <name>
---

## Summary


## Details


## Related
- 
```

**`templates/project-index.md`**:
```markdown
---
type: project
title: 
date: {{date}}
status: active   # active | paused | done | cancelled
tags: []
author: <name>
---

## Goal


## Log
| Date | Update |
|------|--------|
| {{date}} | Project started |

## Decisions
- 

## Resources
- 
```

---

## Step 5 — Configure MCP servers in Claude Desktop

Update `~/Library/Application Support/Claude/claude_desktop_config.json`.

First, detect the correct absolute paths:
```bash
which npx
which uvx
```

If `uvx` is not installed:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Add to the config (merge with any existing `mcpServers`, do not overwrite other entries):

```json
{
  "mcpServers": {
    "second-brain-files": {
      "command": "<absolute path to npx>",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "<vault_path>"
      ]
    },
    "second-brain-git": {
      "command": "<absolute path to uvx>",
      "args": [
        "mcp-server-git",
        "--repository",
        "<vault_path>"
      ]
    }
  }
}
```

> Note: include `second-brain-git` regardless of the Git choice — it does no harm if Git is not initialised, and avoids having to reconfigure later.

Tell me once the config is updated so I know to restart Claude Desktop.

---

## Step 6 — Git setup (only if the user said yes in Step 1)

```bash
cd <vault_path>
git init
git add .
git commit -m "init: second brain vault"
```

Then ask: "Do you have an existing GitHub repo, or should I create one with `gh repo create`?"

Wait for the answer, then add the remote and push accordingly.

---

## Step 7 — Final report

Tell me:
- Vault path and total folders created
- Whether Obsidian config is in place
- Whether MCP config was updated
- Whether Git was initialised (if applicable)
- List of templates created

Then give me 3 starter prompts I can send to Claude Desktop right now to begin using the vault.
```
