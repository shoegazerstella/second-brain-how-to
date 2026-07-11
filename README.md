# Second Brain Setup Guide

```
   ___  _   _  ____    ____  ____    _    ___ _   _ 
  |__ \| \ | ||  _ \  | __ )|  _ \  / \  |_ _| \ | |
    / /|  \| || | | | |  _ \| |_) |/ _ \  | ||  \| |
   |_| | |\  || |_| | | |_) |  _ </ ___ \ | || |\  |
  (_)  |_| \_||____/  |____/|_| \_\_/   \_\___|_| \_|
                                                      
     Git + Markdown + Claude MCP = Knowledge Engine
```

Build personal knowledge base in Markdown + Git, managed by Claude Desktop via MCP servers.

## What this is

Tutorial for setting up:
- **Local vault**: Markdown files in Git repo
- **Claude Desktop integration**: Two MCP servers (filesystem + git) give Claude read/write access
- **GitHub Actions**: Scheduled jobs for automated digests, research, feeds
- **Daily sync automation**: Pull from Jira, Slack, Gmail, Calendar into vault

No proprietary apps. No database. Just `.md` files, Git, Claude Desktop.

## Contents

- [`second-brain-setup-tutorial.md`](./second-brain-setup-tutorial.md) — Complete setup guide
- [`daily-second-brain-sync-skill.md`](./daily-second-brain-sync-skill.md) — Automated daily digest from Jira/Slack/Gmail/Calendar
- [`setup.sh`](./setup.sh) — Executable script to create vault structure

## Quick overview

```
second-brain/ (local git repo)
    ↕ mcp-server-filesystem  →  Claude reads/writes .md files
    ↕ mcp-server-git         →  Claude commits and pushes
GitHub repo
    ↕ GitHub Actions (cron) → automated notes, digests, research
```

## Prerequisites

- Node.js + npx
- Python uv + uvx
- GitHub CLI (authenticated)
- Claude Desktop

## Quick start

Run setup script:
```bash
chmod +x setup.sh
./setup.sh
```

Follow prompts. Script creates vault, git setup, GitHub Actions workflow, auto-push hook.

## What you get

**Base setup:**
- Vault structure (inbox, journal, projects, areas, resources, automated)
- Note format based on Google's Open Knowledge Format (OKF)
- Claude Desktop commands for reading, writing, searching, committing
- Example GitHub Actions workflow for daily digest
- Post-commit hook for auto-push

**Daily automation (optional):**
- Scheduled digest from Jira, Slack, Gmail, Google Calendar
- Auto-detection of projects, teams, people, companies
- Stub creation for new entities with wikilinks
- Starred emails + saved Slack messages highlighted
- Filesystem watcher for auto git commit/push

## Features

✅ Local-first, Git-versioned  
✅ Claude Desktop MCP integration  
✅ GitHub Actions for cloud automation  
✅ OKF frontmatter standard  
✅ Daily digest with entity linking  
✅ Auto-commit on file changes  
✅ Works with Obsidian (optional)  

## Future additions

More tutorials planned:
- Advanced workflows
- Custom automation scripts
- Integration patterns
- Multi-vault setup

---

**License**: MIT
