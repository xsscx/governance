# Git Repository Setup

## Local-Only Directories (Excluded)

The following directories are **device-specific** and excluded from git:

```
pkg/             46MB   - Copilot CLI binaries (platform-specific)
logs/            140KB  - Session logs (local only)
session-state/   1.3MB  - Session state data (local only)
```

Also excluded:
- `config.json` - Device-specific configuration
- `command-history-state.json` - Local command history
- `violations/*.jsonl` - Session-specific violation logs

## Repository Contents (Tracked)

**Governance files only** (portable across devices):

```
governance/          - Framework documentation
profiles/            - JSON behavioral constraints
enforcement/         - YAML violation patterns + heuristics
templates/           - Shell prologues, git hooks, workflows
scripts/             - Automation scripts (executable)
tests/               - Validation test suite
examples/            - Real-world workflow guides
archive/             - Historical LLMCJF v1.0 data
```

**Documentation**:
- README.md, CHANGELOG.md, QUICKSTART.md
- GOVERNANCE_BOOTSTRAP.md, PATTERNS.md, TROUBLESHOOTING.md
- LICENSE (GPL-3.0)

## Initialize Git Repository

```bash
cd ~/.copilot

# Initialize repo
git init

# Add governance files
git add -A

# Verify exclusions
git status | grep -E "pkg|logs|session-state"  # Should show nothing

# Commit
git commit -m "Initial commit: Copilot governance framework v2.1"

# Add remote (optional)
git remote add origin https://github.com/yourusername/copilot-governance.git
git push -u origin main
```

## Verify .gitignore

```bash
# Check what's tracked
git ls-files | head -20

# Verify exclusions
ls -d pkg/ logs/ session-state/ config.json 2>/dev/null | \
  while read f; do git check-ignore -v "$f"; done
```

Expected output:
```
.gitignore:2:pkg/                pkg/
.gitignore:3:logs/               logs/
.gitignore:4:session-state/      session-state/
.gitignore:5:config.json         config.json
```

## Clone to New Device

```bash
# Clone repo
git clone https://github.com/yourusername/copilot-governance.git ~/.copilot

# Verify structure
ls -la ~/.copilot/

# Local-only directories won't exist (expected)
ls ~/.copilot/pkg/  # Should fail (will be created by Copilot CLI on first run)
```

## File Count Breakdown

**Tracked (governance)**: ~35 files, ~300KB
- Profiles: 3 files
- Enforcement: 2 files
- Scripts: 7 files
- Templates: 5 files
- Tests: 5 files
- Examples: 5 files
- Docs: 8 files

**Excluded (local)**: ~90 files, ~47MB
- pkg/: Copilot CLI binaries
- logs/: Session logs
- session-state/: Runtime state

## Best Practices

1. **Never commit**: pkg/, logs/, session-state/, config.json
2. **Always commit**: profiles/, enforcement/, scripts/, templates/, tests/
3. **Review before push**: `git diff --cached`
4. **Keep .gitignore updated**: Add new local-only patterns as needed

## Migration Between Devices

```bash
# Device A: Push governance
cd ~/.copilot
git add -A
git commit -m "Update profiles"
git push

# Device B: Pull updates
cd ~/.copilot
git pull

# Local config remains intact (not overwritten)
ls config.json  # Still present, not touched by git
```

## Size Comparison

```
Repository (tracked):    300KB  (portable governance files)
Local runtime (ignored): 47MB   (device-specific binaries/logs)

Ratio: 0.6% tracked, 99.4% local-only
```

This ensures the repository stays lean and portable while preserving local customizations.
