# Git Repository Verification

## Confirmation

✅ **pkg/ directory is LOCAL ONLY** - Never committed to git
✅ **logs/ directory is LOCAL ONLY** - Never committed to git  
✅ **session-state/ directory is LOCAL ONLY** - Never committed to git
✅ **config.json is LOCAL ONLY** - Never committed to git

## Repository Contains (Portable Governance Only)

```bash
git ls-files | wc -l
# Expected: ~53 files

git ls-files | grep -E "^(governance|profiles|enforcement|templates|scripts|tests|examples|archive)" | wc -l
# Expected: ~45 files (all governance)
```

## Local Files (Excluded)

```bash
ls -d pkg/ logs/ session-state/ config.json command-history-state.json 2>/dev/null
# These exist locally but are NOT in git
```

## Verify Exclusions

```bash
cd ~/.copilot

# Should return nothing (all ignored)
git status --porcelain | grep -E "pkg/|logs/|session-state/|config.json"

# Should list all ignored patterns
git check-ignore -v pkg/ logs/ session-state/ config.json
```

## Clone Test (Verification)

When you clone this repo to a new device:

```bash
git clone <repo-url> ~/.copilot-test

ls ~/.copilot-test/pkg/          # DOES NOT EXIST (correct)
ls ~/.copilot-test/logs/         # DOES NOT EXIST (correct)
ls ~/.copilot-test/profiles/     # EXISTS (correct)
ls ~/.copilot-test/scripts/      # EXISTS (correct)
```

The Copilot CLI will create `pkg/`, `logs/`, `session-state/` on first run.

## Size Comparison

```
Repository (.git):    ~200KB   (governance files only)
Local runtime:        ~47MB    (pkg, logs, session-state - NOT in git)

Files tracked:        53        (portable governance)
Files local-only:     ~90       (device-specific binaries/logs)
```

## .gitignore Effectiveness

```bash
# Show what's ignored
git status --ignored | grep "pkg/\|logs/\|session-state/"

# Expected output:
# pkg/
# logs/
# session-state/
```

All confirmed: Local runtime directories are excluded from git repository.
