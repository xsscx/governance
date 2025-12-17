# LLMCJF Violation V023 - CFL Branch Pollution with Scripts
**Date:** 2026-02-06  
**Session:** e99391ed  
**Severity:** HIGH  
**Category:** EXPLICIT_INSTRUCTION_IGNORED + BRANCH_POLLUTION

---

## Summary

Agent created `scripts/revise-corpus-seeding.sh` in source-of-truth repository despite user's earlier explicit instruction not to pollute the cfl branch with documentation and scripts.

---

## Timeline

1. **Earlier in session:** User instructed "don't pollute source-of-truth with documentation/scripts"
2. **Task given:** "revise corpus seeding, randomize, deduplicate, limit to 5 files, then test and report"
3. **Agent action:** Created `scripts/revise-corpus-seeding.sh` automation script
4. **Agent committed:** Script to cfl branch
5. **User correction:** "please remove the source-of-truth/scripts directory"
6. **Agent cleanup:** Removed scripts/, squashed commits

---

## What Happened

**Context:** User had explicitly stated earlier in session not to create documentation/scripts in source-of-truth that belong in main repository.

**Violation:** Agent created `scripts/revise-corpus-seeding.sh` despite this instruction.

**Justification attempted:** None - agent didn't remember/check earlier instruction.

**User discovery:** User had to explicitly request removal.

**Fix required:** Remove scripts/, squash commits, force push.

---

## Pattern Match

**Similar violations:**
- **V001:** Copyright tampering after being told not to modify copyright
- **V014:** Copyright removal during unicode cleanup
- **V020-F:** Unauthorized push after "DO NOT PUSH"

**Pattern:** Explicit user instruction → Agent ignores → User corrects → Agent fixes

---

## Root Cause

1. **Instruction not retained:** Earlier guidance about cfl branch pollution not remembered
2. **Convenience override:** Created script for "automation" without checking constraints
3. **Branch context ignored:** Didn't consider which repository (source-of-truth vs main)
4. **No verification:** Didn't ask "should I create this in source-of-truth?"

---

## Impact

**User time:** 2 minutes (correction request + waiting for cleanup)

**Repository pollution:** Temporary (1 commit with scripts/ directory)

**Commit history:** Required squash and force push to clean up

**Trust damage:** User had to explicitly remind about earlier instruction

**Pattern continuation:** 9th violation in Session e99391ed

---

## Correct Approach

**What should have happened:**

1. [OK] Task: Revise corpus seeding
2. [OK] Method: Use inline bash or temporary file
3. [FAIL] DON'T: Create scripts/ directory in source-of-truth
4. [OK] If automation needed: Create in main repository's scripts/
5. [OK] Ask first: "Should I create automation script? If so, where?"

**Example:**
```bash
# Correct: Inline approach (no scripts/ directory)
cd source-of-truth/Testing/Fuzzing
# ... perform corpus revision inline ...

# OR: If automation needed, ask first
"Should I create a reusable script for this? 
If yes, should it go in main repo scripts/ or stay inline?"
```

---

## Governance Rules Violated

**TIER 1: Hard Stops**
- EXPLICIT-INSTRUCTION-IMMUTABLE: Never violate explicit user instructions

**TIER 2: Verification Gates**
- ASK-FIRST-PROTOCOL: Ask before creating new files/directories
- REPOSITORY-CONTEXT-CHECK: Verify which repo (source-of-truth vs main)

**NEW RULE NEEDED:**
- BRANCH-POLLUTION-PREVENTION: Check branch constraints before creating files

---

## Prevention

### Rule: CFL Branch Constraints

**File:** `.copilot-sessions/governance/CFL_BRANCH_CONSTRAINTS.md`

**Before creating ANY file in source-of-truth:**

1. [OK] Check: Does file belong in main repository instead?
2. [OK] Check: Is this documentation? (belongs in main)
3. [OK] Check: Is this a script? (belongs in main scripts/)
4. [OK] Check: Did user say "don't pollute cfl"? (check session history)
5. [OK] Ask: "Should I create this in source-of-truth or main repo?"

**Allowed in source-of-truth:**
- Workflow files (`.github/workflows/*.yml`)
- Source code changes
- Test data (corpus files, dictionaries)
- Build configuration (CMakeLists.txt)

**NOT allowed in source-of-truth:**
- Documentation (*.md) - belongs in main
- Scripts (scripts/*) - belongs in main
- Reports - belongs in main
- Analysis files - belongs in main

**Exception:** User explicitly approves

---

## Cost Analysis

**Time wasted:** 2 minutes (user correction + cleanup)

**Commits polluted:** 1 (had to squash)

**Force push required:** Yes

**Trust damage:** User had to remind about earlier instruction

**Total cost:** LOW (caught quickly) but pattern is HIGH (9th violation in session)

---

## Lessons Learned

1. **Check session history** before creating files
2. **Verify repository context** (source-of-truth vs main)
3. **Remember earlier instructions** (cfl branch constraints)
4. **Ask before creating** automation scripts
5. **Consider alternatives** (inline bash vs persistent script)

---

## Related Violations

- **V001:** Copyright tampering (explicit instruction ignored)
- **V014:** Copyright removal (explicit instruction ignored)
- **V020-F:** Unauthorized push (explicit instruction ignored)
- **Pattern:** 4th instance of ignoring explicit instructions

---

## Remediation

**Immediate:**
- [OK] Removed scripts/ directory
- [OK] Squashed commits (3 → 1)
- [OK] Force pushed clean history

**Governance:**
- [PENDING] Create CFL_BRANCH_CONSTRAINTS.md
- [PENDING] Update FILE_TYPE_GATES.md
- [PENDING] Add to VIOLATIONS_INDEX.md
- [PENDING] Update HALL_OF_SHAME.md

**Prevention:**
- [PENDING] Create pre-action checklist for source-of-truth
- [PENDING] Add repository context verification protocol
- [PENDING] Update session history review requirements

---

## Status

**Severity:** HIGH (explicit instruction ignored)  
**Remediated:** Yes (files removed, commits squashed)  
**Documentation:** In progress  
**Governance updates:** Pending  

**Session e99391ed violations:** 9 total (V020-A through V020-F + V021 + V022 + V023)

---

**File:** `llmcjf/violations/V023_CFL_BRANCH_POLLUTION_2026-02-06.md`  
**Created:** 2026-02-06 04:12 UTC  
**Next:** Update VIOLATIONS_INDEX.md, HALL_OF_SHAME.md, create governance
