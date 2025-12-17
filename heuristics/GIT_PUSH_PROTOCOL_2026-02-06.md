# Git Push Protocol - Mandatory Pre-Push Verification

**Created:** 2026-02-06  
**Session:** 4b1411f6  
**Severity:** TIER 1 - HARD STOP  
**Rule ID:** H016

## The Rule

**NEVER push to ANY git repository without explicit user confirmation of:**
1. **Which repository** (root, submodule, subproject - by name)
2. **Which branch** (master, main, cfl, feature branch, etc.)

## Protocol

### Before ANY `git push` command:

```
MANDATORY: Use ask_user tool with:
  
Question: "Ready to push commits. Please confirm:"

Choices:
  1. "Repository: [name] | Branch: [branch-name]"
  2. "Repository: [name] | Branch: [branch-name]"  
  3. "Do not push - keep local only"
  4. [Allow freeform for other combinations]
```

### Example Implementation

**WRONG (What I Did):**
```bash
# Assumed which repos to push
git push origin master
cd source-of-truth && git push origin cfl
cd llmcjf && git push origin main
```

**CORRECT:**
```
Step 1: ask_user
  "Ready to push commits. Please confirm repository and branch:"
  Choices:
    - "Root repository → master branch"
    - "llmcjf submodule → main branch"
    - "source-of-truth → cfl branch"
    - "Multiple (specify in freeform)"
    - "Do not push - keep local only"

Step 2: ONLY push what user confirmed
  User selects: "llmcjf submodule → main branch"
  
  Execute:
    cd llmcjf
    git push origin main
  
  Do NOT push root or source-of-truth
```

## Why This Matters

### Violation Instance: Session 4b1411f6
**Date:** 2026-02-06  
**Command:** User said "push and test then report"  
**Agent Assumption:** Push all three git repositories found  
**Reality:**
- Root repository: No remote configured (local-only workspace)
- source-of-truth/: External project reference (should NOT push)
- llmcjf/: Actual target (but needed pull first)

**Result:**
- [FAIL] Attempted push to wrong repository (source-of-truth)
- [FAIL] Failed push to unintended repository (root)
- [WARN] Could have pushed to external project (serious governance violation)

### Risks Prevented by This Protocol

1. **Pushing to External Projects**
   - source-of-truth may be reference copy of external code
   - Pushing could contaminate upstream projects
   - Could expose proprietary work publicly

2. **Wrong Branch Pushes**
   - Pushing to main instead of feature branch
   - Pushing to protected branches
   - Breaking CI/CD pipelines

3. **Scope Violations**
   - "DO NOT PUSH" governance may apply to specific repos
   - Local-only work contaminating shared repos
   - Testing code reaching production branches

4. **Repository Confusion**
   - Multi-repo workspaces common (root + submodules + subprojects)
   - Each may have different remotes, branches, policies
   - Assumption = risk

## Integration with Existing Rules

### Relationship to Other Protocols
- **ASK-FIRST-PROTOCOL (H002):** This is a specific case
- **SCOPE-DISCIPLINE (H010):** Prevents scope assumption
- **BATCH-PROCESSING-GATE (H003):** Pushes affect multiple systems

### Detection Pattern
```
Trigger words from user:
  - "push"
  - "commit and push"
  - "deploy"
  - "publish"
  
STOP → ask_user → Get explicit confirmation → THEN push
```

## Implementation Checklist

Before executing `git push`:

- [ ] User has said words "push" or equivalent
- [ ] I have used ask_user tool to confirm repository name
- [ ] I have used ask_user tool to confirm branch name
- [ ] User has EXPLICITLY confirmed both repository AND branch
- [ ] I have NOT assumed which repos to push from context

## Cost-Benefit Analysis

**Cost of Protocol:**
- Time: 15-30 seconds (one ask_user interaction)
- User effort: One click or selection

**Cost of Violation:**
- Wrong push to external repo: Legal/security incident
- Wrong branch: Hours to revert + broken CI/CD
- Repository confusion: 10-30 minutes debugging
- Trust damage: Priceless

**Ratio:** 1:∞ (some violations unrecoverable)

## Repository-Specific Workflows

### action-testing Repository
**Mandatory Sequence Before Push:**

```bash
# 1. Fetch remote changes
git fetch origin

# 2. Pull (merge or rebase)
git pull origin [branch-name]

# 3. Squash commits (interactive rebase)
git rebase -i HEAD~[number-of-commits]
# OR
git reset --soft HEAD~[number-of-commits]
git commit -m "Squashed commit message"

# 4. THEN push
git push origin [branch-name]
```

**Why This Order:**
- Fetch/pull ensures you have latest remote changes
- Squash keeps commit history clean (required for action-testing)
- Push only after local is synchronized and organized

**Never skip steps** - this prevents:
- Push rejections due to diverged history
- Merge conflicts in remote
- Polluted commit history

### Other Repositories
Standard workflow applies unless user specifies otherwise.

## Template Response

When user mentions "push":

```
Before pushing, I need to confirm:

Which repository should I push to?
1. Root repository (iccLibFuzzer) → [branch name]
2. llmcjf submodule → [branch name]  
3. source-of-truth → [branch name]
4. action-testing → [branch name] (will fetch→pull→squash→push)
5. Other (specify)
6. Do not push - keep local only

Which branch should I push to?
1. master/main (production)
2. cfl (current feature)
3. feature/[name]
4. Other (specify)
```

Then execute ONLY what user confirms.

**Special handling:**
- action-testing: Execute fetch→pull→squash→push sequence
- Others: Standard push workflow

## Severity: TIER 1 - HARD STOP

This is a **MANDATORY** rule. Violation severity:

- **Actual Harm:** Could push to wrong external repository
- **Governance Impact:** Violates "DO NOT PUSH" constraints
- **Security Risk:** Could expose sensitive work publicly
- **Trust Impact:** Demonstrates assumption over confirmation

**Classification:** CRITICAL - Never violate

## Related Documentation

- `.copilot-sessions/PRE_ACTION_CHECKLIST.md` (update with this rule)
- `llmcjf/profiles/governance_rules.yaml` (add H016)
- `llmcjf/HALL_OF_SHAME.md` (add if violation causes harm)

## Enforcement

**Session 4b1411f6 Status:** [WARN] PROTOCOL VIOLATION DETECTED  
**Harm Level:** LOW (pushes failed, no contamination occurred)  
**Corrective Action:** This protocol created  
**Future Sessions:** ZERO TOLERANCE - must follow H016

---

**Rule Summary:**  
🛑 **STOP** → ❓ **ASK** (repo + branch) → [OK] **CONFIRM** → ⚡ **PUSH**

Never push without explicit user confirmation of repository and branch.
