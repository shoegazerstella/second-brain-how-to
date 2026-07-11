#!/bin/bash

# Second Brain Setup Script
# Run with: ./setup.sh

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_step() { echo -e "${GREEN}▶ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }

# Check prerequisites
print_step "Checking prerequisites..."

if ! command -v npx &> /dev/null; then
    print_error "npx not found. Install Node.js: brew install node"
    exit 1
fi

if ! command -v uvx &> /dev/null; then
    print_error "uvx not found. Install: curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
fi

if ! command -v gh &> /dev/null; then
    print_error "gh not found. Install: brew install gh && gh auth login"
    exit 1
fi

print_success "All prerequisites installed"

# Get GitHub username
print_step "Enter your GitHub username:"
read -r GITHUB_USERNAME

# Get vault path
print_step "Enter full path for vault (default: ~/second-brain):"
read -r VAULT_PATH
VAULT_PATH=${VAULT_PATH:-"$HOME/second-brain"}

# Create vault structure
print_step "Creating vault at $VAULT_PATH..."
mkdir -p "$VAULT_PATH"/{inbox,journal/{daily,weekly},projects,areas,resources/{papers,tools,people,concepts},automated/{digests,research,feeds},decisions,preferences,templates,.github/{workflows,scripts}}

cd "$VAULT_PATH"

# Create .gitignore
cat > .gitignore << 'EOF'
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/cache
.obsidian/*.log
.DS_Store
EOF

# Create index.md
cat > index.md << 'EOF'
---
type: index
title: Vault Index
date: $(date '+%Y-%m-%d')
author: human
---

# Second Brain Index

Auto-updated by GitHub Actions.
EOF

# Create log.md
cat > log.md << 'EOF'
---
type: log
title: Vault Changelog
date: $(date '+%Y-%m-%d')
author: github-actions
---

# Changelog

Auto-updated on every commit.
EOF

# Initialize git
print_step "Initializing git repository..."
git init
git remote add origin "https://github.com/$GITHUB_USERNAME/second-brain.git"

# Create GitHub Actions workflow
print_step "Creating daily digest workflow..."
cat > .github/workflows/daily-digest.yml << 'EOF'
name: Daily digest
on:
  schedule:
    - cron: '0 7 * * *'
  workflow_dispatch:

jobs:
  digest:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: pip install anthropic

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
EOF

# Create digest script
cat > .github/scripts/daily_digest.py << 'EOF'
import anthropic
import datetime
import pathlib
import os

client = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])
today = datetime.date.today().isoformat()

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
EOF

# Create post-commit hook
print_step "Creating auto-push hook..."
cat > .git/hooks/post-commit << 'EOF'
#!/bin/sh
git push origin main
EOF
chmod +x .git/hooks/post-commit

# First commit
print_step "Creating first commit..."
git add .
git commit -m "init: second brain vault structure"

# Test MCP servers
print_step "Testing MCP servers..."
print_warning "Testing filesystem server (Ctrl+C to stop)..."
timeout 2 npx -y @modelcontextprotocol/server-filesystem "$VAULT_PATH" || true

print_warning "Testing git server (Ctrl+C to stop)..."
timeout 2 uvx mcp-server-git --repository "$VAULT_PATH" || true

# Get paths for config
NPX_PATH=$(which npx)
UVX_PATH=$(which uvx)
USERNAME=$(whoami)

# Generate Claude Desktop config
print_step "Generating Claude Desktop config..."
CONFIG_FILE="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

cat << EOF

${GREEN}═══════════════════════════════════════════════════${NC}
Add this to: $CONFIG_FILE

{
  "mcpServers": {
    "second-brain-files": {
      "command": "$NPX_PATH",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "$VAULT_PATH"
      ]
    },
    "second-brain-git": {
      "command": "$UVX_PATH",
      "args": [
        "mcp-server-git",
        "--repository",
        "$VAULT_PATH"
      ]
    }
  }
}
${GREEN}═══════════════════════════════════════════════════${NC}

EOF

print_success "Vault created at: $VAULT_PATH"
print_warning "Next steps:"
echo "1. Create GitHub repo: https://github.com/new (name: second-brain)"
echo "2. Push: cd $VAULT_PATH && git push -u origin main"
echo "3. Add ANTHROPIC_API_KEY secret in GitHub repo settings"
echo "4. Update Claude Desktop config (path printed above)"
echo "5. Restart Claude Desktop (Cmd+Q)"
