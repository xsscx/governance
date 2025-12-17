# LLMCJF Git Hooks

**Git hooks for enforcing governance policies**

---

## Available Hooks

### pre-push (272 lines)

**Purpose:** Enforce git-push-policy.yaml (GIT-001 through GIT-004)  
**Rule:** TIER 0 H016 - NEVER push without explicit authorization  
**Status:** ACTIVE ENFORCEMENT

**What it does:**
1. Checks for authorization file (/tmp/.git-push-authorized-$$)
2. Checks for "do not push" markers
3. Requires interactive confirmation (2 confirmations)
4. Logs violations to llmcjf/violations/

**Installation:**
```bash
./llmcjf/scripts/install-git-hooks.sh
```

---

## Installation

### Automatic (Recommended)

```bash
cd /path/to/repository
./llmcjf/scripts/install-git-hooks.sh
```

### Manual

```bash
cp llmcjf/hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

---

## Usage

### Authorize Push (Fast Path)

```bash
./llmcjf/scripts/authorize-push.sh
git push
```

### Without Pre-Authorization (Interactive)

```bash
git push
# Hook will prompt for authorization
```

---

## Policy Enforcement

| Rule | Description | Enforcement |
|------|-------------|-------------|
| GIT-001 | No push without explicit request | Pre-push hook asks user |
| GIT-002 | Treat "do not push" as absolute | Hook checks markers, aborts |
| GIT-003 | No assumptions about push | Hook never assumes authorization |
| GIT-004 | Document violations | Hook logs to llmcjf/violations/ |

---

## Files in This Directory

- `pre-push` - Pre-push git hook (enforces GIT-001 through GIT-004)
- `README.md` - This file

---

## Related Files

- `../scripts/authorize-push.sh` - Authorization helper
- `../scripts/install-git-hooks.sh` - Hook installer
- `../profiles/git-push-policy.yaml` - Policy definitions
- `../GIT_PUSH_ENFORCEMENT.md` - Complete documentation

---

## Quick Reference

**Install:** `./llmcjf/scripts/install-git-hooks.sh`  
**Authorize:** `./llmcjf/scripts/authorize-push.sh`  
**Bypass (testing):** `git push --no-verify` (WARNING: Violates TIER 0 H016)

---

For complete documentation, see: `../GIT_PUSH_ENFORCEMENT.md`
