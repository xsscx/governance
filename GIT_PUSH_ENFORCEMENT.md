# Git Push Enforcement Implementation

**Closes the GAP between policy and enforcement**

Last Updated: 2026-02-07  
Status: ACTIVE ENFORCEMENT  
Policy: profiles/git-push-policy.yaml (GIT-001 through GIT-004)  
Rule: TIER 0 H016 - NEVER push without explicit authorization

---

## The Gap

### Before (Policy Only)

**Policy Defined:**
```yaml
# profiles/git-push-policy.yaml
rules:
  - id: "GIT-001"
    name: "No Push Without Explicit Request"
    severity: "CRITICAL"
```

**Enforcement:** NONE  
- No repo-native enforcement script  
- Pre-commit hook checks workflow prologues, NOT push authorization  
- **GAP:** Push authorization defined in YAML but not enforced

### After (Policy + Enforcement)

**Enforcement Tools:**
1. Pre-push git hook (`hooks/pre-push`)
2. Authorization helper (`scripts/authorize-push.sh`)
3. Hook installer (`scripts/install-git-hooks.sh`)

**Status:** GAP CLOSED - Push operations now enforced by git hooks

---

## Implementation

### File Structure

```
llmcjf/
├── hooks/
│   └── pre-push (254 lines, executable)
│       - Enforces GIT-001 through GIT-004
│       - Runs BEFORE git push
│       - Can abort unauthorized pushes
│
├── scripts/
│   ├── authorize-push.sh (40 lines, executable)
│   │   - Creates temporary authorization file
│   │   - Valid for 60 seconds
│   │   - Fast-path for authorized pushes
│   │
│   └── install-git-hooks.sh (82 lines, executable)
│       - Installs pre-push hook to .git/hooks/
│       - Verifies installation
│       - Provides usage instructions
│
└── profiles/
    └── git-push-policy.yaml (existing, 166 lines)
        - Policy definitions (GIT-001 through GIT-004)
        - Detection patterns
        - Prevention logic
```

---

## Pre-Push Hook (hooks/pre-push)

### What It Does

1. **Checks authorization file** (`/tmp/.git-push-authorized-$$`)
   - If found and <60s old: ALLOW push
   - If expired: Require interactive authorization

2. **Checks for "do not push" markers**
   - Session state files (*do-not-push*, *local-only*)
   - Commit messages (last 5 commits)
   - llmcjf/GOVERNANCE_DASHBOARD.md
   - If found: ABORT push (GIT-002)

3. **Interactive authorization** (if no authorization file)
   - Shows: remote, URL, branch, commits
   - Asks: "Did user explicitly request this push?"
   - Requires: TWO confirmations (TIER 0 safety gate)
   - Logs: Violations to llmcjf/violations/

4. **Violation logging**
   - Creates: V_PUSH_ATTEMPT_<timestamp>.md
   - Includes: Remote, URL, branch, commits, reason
   - Documents: Policy reference and resolution steps

### Enforcement Levels

| Level | Trigger | Action |
|-------|---------|--------|
| 1. Fast-path | Authorization file exists (<60s) | ALLOW push immediately |
| 2. Prohibition check | "do not push" marker found | ABORT push (GIT-002) |
| 3. Interactive | No authorization, no prohibition | Ask user (2 confirmations) |
| 4. Violation log | Unauthorized attempt | Create violation record |

---

## Authorization Helper (scripts/authorize-push.sh)

### What It Does

Creates a temporary authorization file that the pre-push hook recognizes.

### Usage

```bash
# Authorize the next push (valid for 60 seconds)
./llmcjf/scripts/authorize-push.sh

# Output:
#   Do you explicitly authorize the next git push? (yes/no)
#   > yes
#   [OK] Push authorized for the next 60 seconds
#   Now run: git push
```

### Benefits

- **Fast workflow:** No interactive prompts during push
- **Time-limited:** Authorization expires after 60s (security)
- **Explicit:** User must consciously authorize
- **Auditable:** Clear authorization trail

---

## Hook Installer (scripts/install-git-hooks.sh)

### What It Does

Installs the pre-push hook into the repository's `.git/hooks/` directory.

### Usage

```bash
# Install hook (safe - won't overwrite existing)
./llmcjf/scripts/install-git-hooks.sh

# Force install (overwrite existing hook)
./llmcjf/scripts/install-git-hooks.sh --force
```

### Installation Process

1. Verifies git repository
2. Checks llmcjf directory exists
3. Checks for existing pre-push hook
4. Copies hook from llmcjf/hooks/pre-push
5. Sets executable permissions
6. Verifies installation
7. Shows usage instructions

---

## Workflows

### Workflow 1: Authorized Push (Fast Path)

```bash
# Step 1: Authorize push
./llmcjf/scripts/authorize-push.sh
# Output: [OK] Push authorized for the next 60 seconds

# Step 2: Push immediately (within 60s)
git push
# Output: [OK] PUSH AUTHORIZED - Proceeding
```

### Workflow 2: Unauthorized Push (Interactive)

```bash
# Attempt push without authorization
git push

# Hook prompts:
#   PRE-PUSH HOOK: Git Push Authorization Check
#   Policy: LLMCJF Git Push Policy (GIT-001 through GIT-004)
#   Remote: origin
#   URL: https://github.com/user/repo
#   
#   Did the user explicitly request this push? (yes/no)
#   > yes
#   
#   Second confirmation required (TIER 0 safety gate)
#   Confirm push to origin? (yes/no)
#   > yes
#   
#   [OK] PUSH AUTHORIZED - Proceeding
```

### Workflow 3: Prohibited Push (Marker Found)

```bash
# User said "commit local only, do not push"
# Marker exists in commit message or session state

git push

# Hook output:
#   Checking for 'do not push' markers...
#   [RED] Found 'do not push' instruction in recent commit messages
#   
#   [RED] PUSH BLOCKED: Explicit prohibition found
#   User has explicitly requested LOCAL ONLY commits.
#   Push operation ABORTED per GIT-002 policy.
#   
#   [INFO] Violation logged: llmcjf/violations/V_PUSH_ATTEMPT_<timestamp>.md
```

### Workflow 4: Bypass Hook (Testing Only)

```bash
# WARNING: Only for testing - violates TIER 0 H016
git push --no-verify

# This BYPASSES the pre-push hook
# Should ONLY be used for testing hook functionality
# NEVER use in production without explicit user authorization
```

---

## Policy Enforcement Rules

### GIT-001: No Push Without Explicit Request

**Rule:** NEVER push to git remote unless explicitly requested by user

**Enforcement:**
- Pre-push hook asks: "Did user explicitly request this push?"
- Requires TWO confirmations (first + second)
- Authorization expires after 60 seconds

**Examples:**

```
User request: "commit and push"
Hook action: ALLOW (explicit request)

User request: "commit local only"
Hook action: ABORT (no push requested)

User request: "commit" (ambiguous)
Hook action: ASK (interactive authorization)
```

### GIT-002: Treat 'Do Not Push' as Absolute

**Rule:** If user says "do not push", NEVER push under ANY circumstance

**Enforcement:**
- Hook checks for markers in:
  - Session state files (*do-not-push*, *local-only*)
  - Commit messages (last 5)
  - llmcjf/GOVERNANCE_DASHBOARD.md
- If ANY marker found: ABORT immediately

**Trigger phrases:**
- "do not push"
- "don't push"
- "no push"
- "local only"
- "commit local only"

### GIT-003: No Assumptions About Push

**Rule:** Never assume user wants push, even if it seems logical

**Enforcement:**
- Hook NEVER assumes authorization
- No silent pushes
- Always requires explicit confirmation

### GIT-004: Document Push Violations

**Rule:** If push attempted without authorization, document as violation

**Enforcement:**
- Hook creates violation record: V_PUSH_ATTEMPT_<timestamp>.md
- Includes: remote, URL, branch, commits, reason
- Stored in: llmcjf/violations/

---

## Violation Logging

### Violation Record Structure

```markdown
# Git Push Attempt Blocked

**Timestamp:** 2026-02-07T01:15:00Z  
**Violation:** GIT-001 (No Push Without Explicit Request)  
**Severity:** CRITICAL  
**Status:** PREVENTED BY PRE-PUSH HOOK

## Details

- Remote: origin
- URL: https://github.com/user/repo
- Branch: main
- Reason: Interactive authorization denied
- Commits blocked: 3

## Action Taken

Pre-push hook ABORTED the push operation per TIER 0 H016 policy.

## Commits That Were Not Pushed

\`\`\`
abc1234 Add new feature
def5678 Fix bug
ghi9012 Update docs
\`\`\`

## Policy Reference

- Policy: llmcjf/profiles/git-push-policy.yaml
- Rule: GIT-001 (No Push Without Explicit Request)
- Enforcement: TIER 0 H016 (absolute rule, cannot be overridden)

## Resolution

If push is needed:
1. User must explicitly request push
2. Run: touch /tmp/.git-push-authorized-$$
3. Run: git push (within 60 seconds)

Or use authorization helper:
\`\`\`bash
./llmcjf/scripts/authorize-push.sh
\`\`\`
```

---

## Installation

### Step 1: Install Pre-Push Hook

```bash
cd /path/to/repository
./llmcjf/scripts/install-git-hooks.sh
```

Output:
```
========================================
  LLMCJF Git Hooks Installer
========================================

[INFO] Installing pre-push hook...
[OK] Pre-push hook installed

[INFO] Verifying installation...
[OK] Pre-push hook is executable

==========================================
  Installation Complete
==========================================

Hook installed: /path/to/repo/.git/hooks/pre-push
Source: /path/to/repo/llmcjf/hooks/pre-push
Policy: llmcjf/profiles/git-push-policy.yaml

TIER 0 H016 enforcement is now ACTIVE
```

### Step 2: Verify Installation

```bash
ls -l .git/hooks/pre-push
# Output: -rwxr-xr-x 1 user user 8633 Feb  7 01:11 .git/hooks/pre-push

head -5 .git/hooks/pre-push
# Output:
#   #!/bin/bash
#   # Pre-Push Git Hook - Enforces LLMCJF Git Push Policy
#   # Implements: profiles/git-push-policy.yaml (GIT-001, GIT-002, GIT-003, GIT-004)
#   # Purpose: Prevent unauthorized git push operations (TIER 0 H016 enforcement)
```

### Step 3: Test Hook

```bash
# Make a test commit
echo "test" > test.txt
git add test.txt
git commit -m "Test commit (LOCAL ONLY)"

# Try to push without authorization
git push

# Expected output:
#   PRE-PUSH HOOK: Git Push Authorization Check
#   Policy: LLMCJF Git Push Policy (GIT-001 through GIT-004)
#   ...
#   Did the user explicitly request this push? (yes/no)
```

---

## Integration with Session Workflow

### session-start.sh Integration (Recommended)

Add to `scripts/session-start.sh`:

```bash
# Check if pre-push hook is installed
if [ ! -f "$REPO_ROOT/.git/hooks/pre-push" ]; then
    echo "[WARN] Pre-push hook not installed"
    echo "       Run: ./llmcjf/scripts/install-git-hooks.sh"
fi

# Verify hook is up to date
if [ -f "$REPO_ROOT/.git/hooks/pre-push" ]; then
    if ! diff -q "$REPO_ROOT/llmcjf/hooks/pre-push" "$REPO_ROOT/.git/hooks/pre-push" >/dev/null 2>&1; then
        echo "[WARN] Pre-push hook out of date"
        echo "       Run: ./llmcjf/scripts/install-git-hooks.sh --force"
    fi
fi
```

---

## Benefits

### Before Enforcement

1. **Policy only** - Rules documented but not enforced
2. **Manual compliance** - Relies on agent discipline
3. **Violations possible** - No technical prevention
4. **Post-facto detection** - Violations discovered after the fact

### After Enforcement

1. **Technical prevention** - Git hook blocks unauthorized pushes
2. **Automatic compliance** - No agent discipline required
3. **Proactive blocking** - Violations prevented before they occur
4. **Real-time feedback** - User knows immediately if push blocked

---

## Limitations

1. **Can be bypassed** - `git push --no-verify` skips hook
   - Mitigation: Trust-based system, violations logged

2. **Client-side only** - Hook runs on local machine
   - Mitigation: Server-side hooks possible (requires repo admin)

3. **Authorization file** - Uses /tmp (not persistent across reboots)
   - Mitigation: 60-second expiration limits exposure

4. **Interactive prompts** - May disrupt automated workflows
   - Mitigation: Use authorize-push.sh for fast-path

---

## Future Enhancements

1. **Server-side enforcement**
   - GitHub Actions workflow to verify push authorization
   - Reject pushes without proper markers

2. **Authorization tokens**
   - Persistent authorization (user-scoped)
   - Revocable tokens
   - Audit trail

3. **CI/CD integration**
   - Automated hook installation in CI
   - Hook version verification
   - Enforcement compliance reporting

4. **Multi-repository support**
   - Centralized hook management
   - Organization-wide policy enforcement
   - Hook update automation

---

## References

- Policy: llmcjf/profiles/git-push-policy.yaml
- Hook: llmcjf/hooks/pre-push
- Helper: llmcjf/scripts/authorize-push.sh
- Installer: llmcjf/scripts/install-git-hooks.sh
- TIER 0 Rules: heuristics/H016_GIT_PUSH_PROTOCOL.md
- Policy Resolution: POLICY_RESOLUTION_ORDER.md (TIER 0 precedence)

---

## Quick Reference

**Install hook:**
```bash
./llmcjf/scripts/install-git-hooks.sh
```

**Authorize push:**
```bash
./llmcjf/scripts/authorize-push.sh
git push
```

**Check installation:**
```bash
ls -l .git/hooks/pre-push
```

**Update hook:**
```bash
./llmcjf/scripts/install-git-hooks.sh --force
```

**Bypass (testing only):**
```bash
git push --no-verify  # WARNING: Violates TIER 0 H016
```

---

## Summary

**GAP IDENTIFIED:** Push authorization policy exists but not enforced  
**GAP CLOSED:** Pre-push git hook now enforces GIT-001 through GIT-004  
**ENFORCEMENT:** TIER 0 H016 - NEVER push without authorization  
**STATUS:** ACTIVE - Ready for installation and use

---

END OF DOCUMENT
