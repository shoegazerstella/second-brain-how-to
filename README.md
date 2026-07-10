# Second Brain Setup Guide

Build personal knowledge base in Markdown + Git, managed by Claude Desktop via MCP servers.

## What this is

Tutorial for setting up:
- **Local vault**: Markdown files in Git repo
- **Claude Desktop integration**: Two MCP servers (filesystem + git) give Claude read/write access
- **GitHub Actions**: Scheduled jobs for automated digests, research, feeds

No proprietary apps. No database. Just `.md` files, Git, Claude Desktop.

## Contents

- [`second-brain-setup-tutorial.md`](./second-brain-setup-tutorial.md) — Complete setup guide

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

## What you get

- Vault structure (inbox, journal, projects, areas, resources, automated)
- Note format based on Google's Open Knowledge Format (OKF)
- Claude Desktop commands for reading, writing, searching, committing
- Example GitHub Actions workflow for daily digest
- Post-commit hook for auto-push

## Future additions

More tutorials planned:
- Advanced workflows
- Custom automation scripts
- Integration patterns

---

**License**: MIT
