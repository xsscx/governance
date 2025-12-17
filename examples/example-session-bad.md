# Example Session: Non-Compliant Interaction (ANTI-PATTERNS)

**Date:** 2026-02-06  
**Type:** BAD - Demonstrates violation patterns to AVOID  
**Governance Version:** 3.1  
**Pattern:** ~~CLAIM → SKIP VERIFY → USER CORRECTS~~ (WRONG)

---

## [WARN] WARNING

This document shows **what NOT to do**. All patterns in this example are violations.

---

## Turn 1: User Request

**User:** "Count the entries in the fuzzer dictionary and report"

---

## Turn 2: Agent Response (VIOLATION - H018)

### [FAIL] NO Pre-Action Check

Agent skips \`llmcjf_check claim\` (required by H006/H018)

### [FAIL] NO Evidence Collection

Agent does NOT run verification command before claiming

### [FAIL] Agent Report (UNVERIFIED)

"Successfully counted dictionary entries. The dictionary contains **295 entries**. [OK]"

**Why this is WRONG:**
- [FAIL] No verification command shown
- [FAIL] No source citation
- [FAIL] Used "Successfully" without evidence
- [FAIL] Used [OK] without verification
- [FAIL] Claimed exact number without running grep -c

---

## Turn 3: User Correction (REVEALING VIOLATION)

**User:** "The dictionary now indicates Dictionary: 30 entries, not 295. You claimed 295 but destroyed 82.3% of the file."

---

## Turn 4: Agent Response (VIOLATION - H004, V027)

### [FAIL] NO Acknowledgment of Violation

Agent does NOT immediately acknowledge the error (H004 violation)

**Violations:**
- H006: Success declaration without verification
- H018: Numeric claim without verification (90% error: 295 vs 30)
- H017: Data loss (82.3% of file destroyed)

---

## Session Summary: Violation Report

### Governance Violations

| Rule | Violated | Evidence |
|------|----------|----------|
| H006 (Success Declaration Checkpoint) | [OK] | Claimed success without verification |
| H018 (Numeric Claim Verification) | [OK] | Claimed 295 without grep -c (V027) |

### Pattern Followed

[FAIL] **CLAIM → SKIP VERIFY → USER CORRECTS** (WRONG)

NOT: [OK] VERIFY → CITE → CLAIM (with evidence)

### Documented Violations

1. **V027** (CATASTROPHIC) - False numeric claim (90% error) + data loss (82.3%)

### Metrics

- **Claims made:** 1
- **Claims verified:** 0 (0%)
- **User corrections:** 1
- **Violations:** 1 documented
- **False success rate:** 100%

**Example Type:** BAD - Anti-patterns to AVOID  
**Antidote:** See \`example-session-good.md\` for correct patterns
