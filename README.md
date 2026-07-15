# Second Brain Setup — Tutorials & Automation

```
   ___  _   _  ____    ____  ____    _    ___ _   _ 
  |__ \| \ | ||  _ \  | __ )|  _ \  / \  |_ _| \ | |
    / /|  \| || | | | |  _ \| |_) |/ _ \  | ||  \| |
   |_| | |\  || |_| | | |_) |  _ </ ___ \ | || |\  |
  (_)  |_| \_||____/  |____/|_| \_\_/   \_\___|_| \_|
                                                      
     Git + Markdown + Claude MCP = Knowledge Engine
```

Tutorials and prompts for building a Markdown + Git knowledge base, automated by Claude via MCP servers.

## What this repo contains

Tutorials, prompts, and automation scripts for building a personal second brain system:

- **Setup tutorial**: Step-by-step guide to create a local Markdown vault, connect Claude Desktop via MCP, configure GitHub Actions for automated tasks
- **Daily sync automation**: Prompt template for pulling Jira, Slack, Gmail, Calendar data into vault with entity auto-detection and wikilinks
- **Cowork automation**: Additional automation workflow for team/project context aggregation
- **Setup script**: Executable that scaffolds vault structure, git hooks, and GitHub Actions workflows

**Stack**: Markdown files, Git version control, Claude Desktop (MCP servers), GitHub Actions. No proprietary apps or databases.

## Contents

- [`second-brain-setup-prompt.md`](./second-brain-setup-prompt.md) — Interactive prompt for setting up vault structure and config
- [`daily-second-brain-sync-skill.md`](./daily-second-brain-sync-skill.md) — Prompt template for automated daily digest (Jira/Slack/Gmail/Calendar)
- [`cowork_automation_prompt.md`](./cowork_automation_prompt.md) — Duplicate of daily sync (kept for reference)
- [`setup.sh`](./setup.sh) — Bash script to scaffold vault, git repo, GitHub Actions workflows

## Architecture

```
Local vault (Markdown + Git)
    ↕ mcp-server-filesystem  →  Claude reads/writes .md files
    ↕ mcp-server-git         →  Claude commits/pushes
GitHub remote
    ↕ GitHub Actions (cron)  →  Scheduled automations (digests, research)
```

**Core principle**: Plain text files you own, version-controlled with Git, enhanced by Claude automation. No vendor lock-in.

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

**From the setup tutorial:**
- Folder structure following PARA method (inbox, journal, projects, areas, resources, automated)
- YAML frontmatter templates based on Open Knowledge Format (OKF)
- MCP server config for Claude Desktop (filesystem + git integration)
- GitHub Actions workflow for scheduled automation
- Git hooks for auto-commit/auto-push

**From the daily sync automation:**
- Prompt template that pulls Jira issues, Slack messages, Gmail threads, Calendar events
- Entity auto-detection (projects, teams, people, companies) with stub file creation
- Wikilink generation for cross-referencing
- Starred emails and saved Slack messages prioritized
- Filesystem watcher pattern (fswatch + launchd) for auto-commit/push

## Features

✅ Local-first, Git-versioned  
✅ Claude Desktop MCP integration  
✅ GitHub Actions for cloud automation  
✅ OKF frontmatter standard  
✅ Daily digest with entity linking  
✅ Auto-commit on file changes  
✅ Works with Obsidian (optional)  

## Use cases

- Personal knowledge management (PKM)
- Engineering project notes and decision logs
- Daily digest from work tools (Jira, Slack, Gmail, Calendar)
- Research vault with automated topic tracking
- Team documentation with git-versioned history

## Why this approach

**Local-first**: Files live on your machine. No cloud dependency.  
**Open format**: Markdown files work in any editor (Obsidian, VS Code, vim).  
**Version control**: Git tracks every change. Full history, easy rollback.  
**Automation-ready**: Claude + MCP servers = programmable knowledge base.  
**No lock-in**: Plain text files. Move them anywhere.

---

**License**: MIT  
**Author**: Community tutorial collection
