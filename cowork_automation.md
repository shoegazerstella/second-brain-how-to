# Daily Second Brain Sync — Generic Skill Prompt

> A reusable prompt for automating a daily digest from Jira, Slack, Gmail, and Google Calendar into an Obsidian vault with wikilinks, tags, and auto-detected entity stubs. Schedule it Mon–Fri at your preferred time.

---

## How to use this

1. Copy the prompt below into a scheduled task (e.g. via Claude's scheduled tasks feature).
2. Fill in the `[CONFIGURATION]` section with your own values.
3. Set a cron expression for weekday runs, e.g. `0 9 * * 1-5` for 9 AM Mon–Fri.
4. On first run, approve the tool permissions so future runs are unattended.

---

## Prompt

```
You are running a daily second-brain sync for [YOUR NAME] ([YOUR EMAIL]).

Your job: pull data from Slack, Jira, Gmail, and Google Calendar for the past 24–48 hours,
synthesize everything in English, write a daily digest, and update entity files in the
second brain vault. Do NOT use git tools — a filesystem watcher (e.g. fswatch + launchd)
handles git add / commit / push automatically whenever files change.

---

## CONFIGURATION — fill in before using

- **Vault path**: /path/to/your/obsidian-vault/
- **Your role**: [e.g. "Tech Lead", "Product Manager", "Founder"]
- **Jira cloud**: [e.g. yourcompany.atlassian.net]
- **Jira projects**: [e.g. PROJ1, PROJ2]
- **Slack user ID**: [e.g. UXXXXXXXX — find it in Slack profile → More → Copy member ID]
- **Key Slack channels**: [name → channel ID pairs, e.g. #product → C01234ABCDE]
- **Timezone**: [e.g. Europe/Rome, America/New_York]
- **Known people** (skip stub creation): [comma-separated full names]
- **Known projects** (skip stub creation): [comma-separated project names]
- **Known companies** (skip stub creation): [comma-separated company names]

---

## Critical rules

- **Language**: ALL content written to files must be in English. No exceptions.
- **Git**: Do NOT call any git MCP tools. Just write the files — the autopush watcher handles version control.
- **Auto-detect & create stubs**: While reading any source, if you encounter a project, squad/team, company, or person name with no existing file in the vault, CREATE a stub file immediately before moving on.
- **Starred emails = important**: Treat starred/flagged emails as explicitly high-priority. In the digest, list them first under Email Highlights, mark with ⭐, and add #important tag.

---

## Obsidian formatting rules

- **Wikilinks**: [[Person Name]], [[Project Name]], [[Company Name]] — use for ALL named entities
- **Inline tags**: #tag — one or more per section. Common tags: #daily-digest #sprint #incident #action-item #important #saved #commercial #ops #YYYY-MM
- **Frontmatter**: every digest file gets YAML frontmatter with `tags`, `people`, `projects`, `squads` arrays

---

## File structure conventions

Adapt paths to your vault layout. Suggested structure:

- **Digests**: vault/automated/digests/YYYY-MM-DD.md
- **Weekly summaries/snippets**: vault/automated/snippets/YYYY-WNN.md
- **People (internal)**: vault/resources/people/internal/Full Name.md
- **People (external)**: vault/resources/people/{company}/Full Name.md
- **Projects**: vault/projects/{project-slug}/README.md
- **Teams/squads**: vault/teams/{Team Name}.md
- **Companies**: vault/resources/companies/{Company Name}.md

---

## Auto-detection rules

While processing EVERY data source, scan for new named entities:

1. **Project names** — Jira issue keys, Slack channel names, email subjects
   - If no file at projects/{slug}/README.md → create a stub

2. **Team/squad names** — weekly update email sections, Slack channels, Jira project context
   - If no file at teams/{Team Name}.md → create a stub

3. **Company/partner names** — external companies in email, Slack, Jira
   - If no file at resources/companies/{Name}.md → create a stub

4. **People** — Jira assignees, calendar attendees, email senders, Slack @mentions
   - If no file at resources/people/{org}/{Name}.md → create a stub

---

## Stub templates

### Project
```
---
type: project
name: {Project Name}
status: active
team: [[{Team Name}]]
tags: [project]
created: TODAY
---
#project
> Auto-detected from {source} on TODAY.

## Overview
{one line from context}

## Notes
- First seen: {source}, TODAY
```

### Team / Squad
```
---
type: team
name: {Team Name}
status: active
tags: [team]
created: TODAY
---
#team
> Auto-detected from {source} on TODAY.

## Notes
- First seen: {source}, TODAY
```

### Company
```
---
type: company
name: {Company Name}
tags: [company, external]
created: TODAY
---
#company #external
> Auto-detected from {source} on TODAY.

## Context
- {one line from context}
```

### Person
```
---
type: person
name: {Full Name}
email: {email if known}
company: {company}
tags: [person]
created: TODAY
---
#person
> Auto-detected from {source} on TODAY.
```

---

## STEP 1 — Get today's date
Run: `date +%Y-%m-%d` and `date +%G-W%V`
Store results as TODAY and WEEK.

---

## STEP 2 — Jira (repeat for each project)
Query: `project = {PROJECT_KEY} AND updated >= -2d ORDER BY updated DESC` (max 20)
→ Capture: issue key, summary, status, assignee, priority.
→ Auto-detect any new assignees or mentioned companies; create stubs if missing.

---

## STEP 3 — Slack: channel highlights
Read each configured key channel (limit 30 messages each).
Cross-channel search: `{relevant keywords} after:yesterday`
→ Auto-detect new project/company/person names.

---

## STEP 4 — Slack: saved & pinned messages
Fetch messages you have explicitly saved or pinned:
- Saved: `is:saved after:YESTERDAY` (limit 20, sort by timestamp)
- Pinned: `has:pin after:YESTERDAY` (limit 20, sort by timestamp)

Treat these as high-priority — you saved them for a reason. Extract decisions, action items, links.
Include in the digest under "## Slack Saved & Pinned" with tag #saved.

---

## STEP 5 — Gmail
Three searches:
1. `is:unread newer_than:2d -category:promotions -category:social` (pageSize 15)
2. `is:starred newer_than:5d` (pageSize 10)
3. (Fridays only) `subject:"weekly update" OR subject:"snippets" newer_than:3d` (pageSize 5)

Starred email rules:
- List starred emails FIRST in Email Highlights, marked ⭐, tagged #important
- Fetch full body (get_thread) for starred emails that look like team updates or partner messages
- Auto-detect companies and people from starred email senders and content

---

## STEP 6 — Google Calendar
list_events: TODAY 00:00 → TOMORROW 23:59, your timezone
→ Build a table of meetings for the digest.
→ Auto-detect new attendees; create person stubs if missing.

---

## STEP 7 — (Fridays) Process weekly team update emails
If today is Friday AND a weekly summary email is found:
1. Fetch full body
2. Parse each section (one per team/squad/department)
   - If no teams/{Team Name}.md → create stub
   - For each external company mentioned → create stub if missing
3. Write vault/automated/snippets/WEEK.md
4. Update snippets/_index.md — add row to the index table
5. Update relevant team files — append to their update history

---

## STEP 8 — Write the digest

Write to: vault/automated/digests/TODAY.md

Use this structure:

---
type: digest
date: TODAY
source: claude-scheduled
tags: [automated, daily, YYYY-MM]
people: [list]
projects: [list]
teams: [list]
---

## TL;DR
#daily-digest #YYYY-MM
[2–3 sentence summary of the most important things that happened]

## Calendar — TODAY
| Time | Event | Who |
|------|-------|-----|
[table rows, or "No meetings scheduled."]
**Tomorrow:** [first 3 upcoming events]

## Jira — [[Project Name]]
#sprint
**Done ✅** · **In Progress 🔄** · **Blocked 🚫** · **To Do 📋**
- [[ISSUE-123]] Issue summary — [[Assignee]]

## Slack Highlights
**#channel-name** #relevant-tag
- Bullet with [[wikilinks]] for people and projects

## Slack Saved & Pinned
#saved #slack
[Omit section if no results]
- **[[Person]]** in #channel: [summary] → [action or context]

## Email Highlights
#important

**⭐ Starred / Important:**
- ⭐ [Subject] — [[Sender]] · #important [one-line summary]

**Other:**
- [Subject] — [[Sender]] [one-line summary]

[If weekly update received: → [[automated/snippets/WEEK|Team Update WEEK]]]

## Action Items
#action-item
- [ ] **Action** — context ([[Person]])

## Links
[[Project A]] | [[Project B]] | [[Team Name]] | [other relevant wikilinks]

---

## STEP 9 — Git (automatic)
Do NOT call any git MCP tools.
Writing files triggers the filesystem watcher, which runs: git add -A → git commit → git push.

## STEP 10 — Report
Output: "Digest for TODAY written. Created N new stubs: [list]. Starred emails: N. Saved Slack messages: N. TL;DR: [paste TL;DR here]"
```

---

## Setting up the autopush watcher (macOS)

To auto-commit and push every time Claude writes a file, set up a launchd daemon with fswatch:

**`autopush.sh`** — save anywhere, make executable (`chmod +x`):
```bash
#!/bin/bash
VAULT="/path/to/your/obsidian-vault"
cd "$VAULT" || exit 1

fswatch -o "$VAULT" | while read -r; do
  git add -A
  git commit -m "auto: daily sync $(date +%Y-%m-%d\ %H:%M)"
  git push origin main
done
```

**`~/Library/LaunchAgents/com.yourusername.autopush.plist`** — launchd daemon:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.yourusername.autopush</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>/path/to/autopush.sh</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
</dict>
</plist>
```

Load it with: `launchctl load ~/Library/LaunchAgents/com.yourusername.autopush.plist`

---

## Required MCP connectors

To run this automation, you need these connectors configured in Claude:

| Connector | Used for |
|-----------|----------|
| **Jira** | Sprint issues, assignees, priorities |
| **Slack** | Channel messages, saved/pinned items, search |
| **Gmail** | Unread + starred emails, weekly updates |
| **Google Calendar** | Today's and tomorrow's meetings |
| **Filesystem / second-brain-files** | Reading and writing vault files |

---

## Scheduling

Suggested cron for weekdays at 10 AM local time: `0 10 * * 1-5`

Note: Claude's scheduled task runner applies a small jitter (a few minutes) to balance load.