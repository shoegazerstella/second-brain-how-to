# Second Brain on Git + Claude Desktop MCP — Setup Tutorial

A complete guide to building a personal knowledge base in Markdown, versioned on GitHub, and fully accessible to Claude Desktop via MCP.

---

## What you are building

```
second-brain/ (local git repo)
        ↕ mcp-server-filesystem  →  Claude reads and writes .md files
        ↕ mcp-server-git         →  Claude commits and pushes to GitHub
GitHub repo
        ↕ GitHub Actions (scheduled) → automated notes, digests, research
```

No proprietary apps required. No database. No special runtime. Just Markdown files, Git, and two MCP servers.

---

## Prerequisites

| Tool | Install |
|---|---|
| [Homebrew](https://brew.sh) | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |
| Node.js + npx | `brew install node` |
| uv + uvx | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| GitHub CLI | `brew install gh && gh auth login` |
| Claude Desktop | [claude.ai/download](https://claude.ai/download) |

Verify everything is installed:

```bash
which npx && which uvx && which gh
```

Note the full paths — you will need them in the Claude Desktop config.

---

## Part 1 — Create the vault

### 1.1 Scaffold the structure

Create a new directory and initialise it as a Git repository:

```bash
mkdir ~/second-brain && cd ~/second-brain
git init
git remote add origin https://github.com/YOUR_USERNAME/second-brain.git
```

The vault follows this structure:

```
second-brain/
├── .github/workflows/       # GitHub Actions (scheduled jobs)
├── inbox/                   # buffer — anything uncategorised lands here
├── journal/
│   ├── daily/
│   └── weekly/
├── projects/                # active work with outcomes
├── areas/                   # ongoing responsibilities (no deadline)
├── resources/
│   ├── papers/
│   ├── tools/
│   ├── people/
│   └── concepts/
├── automated/               # written by GitHub Actions only — never edit manually
│   ├── digests/
│   ├── research/
│   └── feeds/
├── decisions/               # ADR-style log of product, technical, personal decisions
├── preferences/             # your personal preferences — read by Claude to personalise outputs
├── templates/               # note templates
├── index.md                 # vault map — auto-updated by Actions
└── log.md                   # changelog — auto-updated by Actions
```

### 1.2 Note format — Open Knowledge Format (OKF)

Every note uses YAML frontmatter following Google's [Open Knowledge Format](https://github.com/GoogleCloudPlatform/knowledge-catalog/tree/main/okf) spec. This makes every file readable by both humans and AI agents without custom parsers.

Minimum required frontmatter:

```markdown
---
type: concept         # journal | project | person | resource | decision | preference | digest | index | log
title: Note title
date: 2026-07-10
tags: []
author: human         # human | github-actions | claude
---
```

### 1.3 Writer ownership rules

| Zone | Who writes | Notes |
|---|---|---|
| `inbox/` | anyone | buffer — Claude triages on request |
| `journal/` | human only | never touched by automation |
| `projects/`, `areas/`, `resources/`, `decisions/`, `preferences/` | human + Claude | source of truth |
| `automated/` | GitHub Actions only | never edit manually |
| `index.md`, `log.md` | GitHub Actions only | never edit manually |

### 1.4 .gitignore

```
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/cache
.obsidian/*.log
.DS_Store
```

### 1.5 First commit

```bash
git add .
git commit -m "init: second brain vault structure"
git push -u origin main
```

---

## Part 2 — MCP servers

You need two MCP servers running inside Claude Desktop:

| Server | Purpose |
|---|---|
| `@modelcontextprotocol/server-filesystem` | Read and write `.md` files in the vault |
| `mcp-server-git` | Git operations — status, add, commit, push |

Neither server needs to stay running permanently. Claude Desktop starts and stops them automatically when you open and close the app.

### 2.1 Test both servers manually first

```bash
# Test filesystem server
npx -y @modelcontextprotocol/server-filesystem ~/second-brain

# Test git server
uvx mcp-server-git --repository ~/second-brain
```

Both should start without errors. Hit Ctrl+C to stop them.

### 2.2 Configure Claude Desktop

Open the config file:

```bash
nano ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

Add both servers (replace paths with your actual paths from `which npx` and `which uvx`):

```json
{
  "mcpServers": {
    "second-brain-files": {
      "command": "/usr/local/bin/npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/YOUR_USERNAME/second-brain"
      ]
    },
    "second-brain-git": {
      "command": "/Users/YOUR_USERNAME/.local/bin/uvx",
      "args": [
        "mcp-server-git",
        "--repository",
        "/Users/YOUR_USERNAME/second-brain"
      ]
    }
  }
}
```

Fully quit and restart Claude Desktop (Cmd+Q, not just close the window).

### 2.3 Verify

In Claude Desktop, send these messages:

```
List all files in my second brain vault.
```

```
What is the current git status of my second brain?
```

If both return sensible answers, the setup is complete.

### 2.4 Auto-push on commit (optional but recommended)

Add a post-commit hook so every commit automatically pushes to GitHub:

```bash
nano ~/second-brain/.git/hooks/post-commit
```

Paste:

```bash
#!/bin/sh
git push origin main
```

Make it executable:

```bash
chmod +x ~/second-brain/.git/hooks/post-commit
```

From this point, when Claude commits a note, it is pushed to GitHub automatically without Claude needing to run a separate push command.

---

## Part 3 — GitHub Actions (scheduled jobs)

This is the cloud layer — jobs that enrich your vault even when your Mac is off.

### 3.1 How it works

```
GitHub Actions (cron)
    → clone the repo
    → run a Python script
    → write .md files to automated/
    → git commit + push
Mac wakes up
    → Claude Desktop pulls latest via git MCP
```

### 3.2 Example — daily digest

Create `.github/workflows/daily-digest.yml`:

```yaml
name: Daily digest
on:
  schedule:
    - cron: '0 7 * * *'   # every day at 07:00 UTC
  workflow_dispatch:        # manual trigger for testing

jobs:
  digest:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Run digest script
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: python .github/scripts/daily_digest.py

      - name: Commit and push
        run: |
          git config user.name "second-brain-bot"
          git config user.email "bot@users.noreply.github.com"
          git add automated/digests/
          git diff --cached --quiet || git commit -m "auto: daily digest $(date '+%Y-%m-%d')"
          git push
```

### 3.3 Example digest script

Create `.github/scripts/daily_digest.py`:

```python
import anthropic
import datetime
import pathlib

client = anthropic.Anthropic()
today = datetime.date.today().isoformat()

# Define what topics you want summarised
topics = [
    "latest developments in AI agents and MCP protocol",
    "interesting tech and engineering news",
    "recent research in machine learning"
]

content = f"""---
type: digest
date: {today}
source: github-actions
workflow: daily-digest
tags: [automated, daily]
---

# Daily Digest — {today}

"""

for topic in topics:
    message = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=500,
        messages=[{
            "role": "user",
            "content": f"Give me a concise 3-5 bullet summary of: {topic}. Today is {today}. Be factual and brief."
        }]
    )
    content += f"## {topic.title()}\n\n"
    content += message.content[0].text + "\n\n"

output_path = pathlib.Path(f"automated/digests/{today}-digest.md")
output_path.parent.mkdir(parents=True, exist_ok=True)
output_path.write_text(content)
print(f"Written: {output_path}")
```

### 3.4 Add your API key to GitHub

```
GitHub repo → Settings → Secrets and variables → Actions → New repository secret
Name: ANTHROPIC_API_KEY
Value: your key
```

### 3.5 Test the workflow manually

```
GitHub repo → Actions → Daily digest → Run workflow
```

Check that a new file appears in `automated/digests/`.

---

## Part 4 — Working with Claude Desktop

### Useful prompts to get started

**Read and triage inbox:**
```
Read everything in my inbox/ folder and suggest how to categorise each note.
```

**Write a new decision:**
```
Create a new decision note in decisions/ about choosing mcp-server-filesystem 
over mcp-obsidian. Fill in context, options considered, and consequences.
Then commit it with message "decision: mcp server choice".
```

**Update a project:**
```
Open projects/my-project/_index.md and add a log entry for today 
summarising what we discussed in our last meeting.
```

**Search across the vault:**
```
Search my vault for all notes mentioning "machine learning" and give me a summary.
```

### Recommended system prompt addition

Add this to Claude Desktop's custom instructions (Settings → Custom instructions):

```
You have access to my second brain vault via two MCP servers:
- second-brain-files: read and write Markdown files
- second-brain-git: git operations

Rules:
- Always use OKF frontmatter when creating new notes
- Set author: claude on notes you create
- After writing or editing files, always commit with a descriptive message
- After writing or editing files in the vault, always run git add + commit + push before ending the response. No exceptions.
- Never write to automated/ — that folder is reserved for GitHub Actions
- Check preferences/ before giving personalised recommendations
- When asked to "remember" something, write it to the appropriate folder and commit
```

---

## Architecture summary

```
┌─────────────────────────────────────────────────────┐
│                   GitHub Repo                        │
│            (source of truth, always up)              │
└──────────────────────┬──────────────────────────────┘
                       │
          ┌────────────┴────────────┐
          │                         │
   git pull/push               git push
          │                         │
┌─────────▼──────────┐   ┌─────────▼──────────┐
│  Mac (Claude        │   │  GitHub Actions     │
│  Desktop)           │   │  (cloud, always on) │
│                     │   │                     │
│  mcp-server-        │   │  daily digest       │
│  filesystem         │   │  research jobs      │
│       +             │   │  feed processing    │
│  mcp-server-git     │   │  any scheduled task │
│       ↕             │   └────────────────────┘
│  Claude Desktop     │
└─────────────────────┘
```

---

## Troubleshooting

**MCP server shows "failed" in Claude Desktop settings**

Check the exact package name:
```bash
uvx mcp-server-git --repository ~/second-brain
```
If it fails, try `mcp-git`. Use whichever name works and update the config accordingly.

**Claude Desktop can't find uvx or npx**

Use absolute paths in the config. Get them with:
```bash
which uvx   # e.g. /Users/yourname/.local/bin/uvx
which npx   # e.g. /usr/local/bin/npx
```

**Git push fails from hook**

Make sure GitHub CLI is authenticated:
```bash
gh auth status
```

**GitHub Actions workflow fails**

Check the Actions log in the GitHub UI. Most common cause: `ANTHROPIC_API_KEY` secret not set.

---

## What's next

- Add more GitHub Actions workflows for your specific topics
- Build a `preferences/` folder so Claude personalises outputs without re-explaining context
- Add a `decisions/` log — every significant product or technical choice gets an ADR-style note
- Set up Obsidian as an optional viewer (point it at the same folder — no conflict with the MCP setup)
