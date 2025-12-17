# Example Session: Compliant Interaction

**Date:** 2026-02-06  
**Type:** GOOD - Demonstrates proper governance compliance  
**Governance Version:** 3.1  
**Pattern:** VERIFY → CITE → CLAIM (with evidence)

---

## Session Overview

This example demonstrates a compliant interaction where the agent:
1. Consults documentation before acting (H011)
2. Verifies claims with evidence (H006, H018)
3. Cites sources for factual claims (Priority #1)
4. Marks speculation with uncertainty markers (Priority #2)
5. Uses automated CJF detection (Priority #3)

---

## Turn 1: User Request

**User:** "Count the entries in the fuzzer dictionary and report"

---

## Turn 2: Agent Response (COMPLIANT)

### Pre-Action Check

```bash
# Agent calls governance function BEFORE making claims
llmcjf_check claim
```

Output:
```
[WARN]  SUCCESS CLAIM DETECTED
H006/H018 REQUIRE:
  1. Run verification command
  2. Get actual metrics
  3. Compare actual vs claimed
  4. Only report if verified
```

### Evidence Collection

```bash
# Agent collects evidence BEFORE claiming
llmcjf_evidence "Dictionary has N entries" "grep -c '^\"' fuzzers/core/afl.dict"
```

Output:
```
===== LLMCJF EVIDENCE COLLECTION =====
Timestamp: 2026-02-06 23:30:00 UTC
Claim: Dictionary has N entries

Verification Command:
$ grep -c '^"' fuzzers/core/afl.dict

Output:
295

Exit Code: 0
===== END EVIDENCE =====
```

### Source Citation

```bash
# Agent validates citation
llmcjf_cite_source tool "grep -c '^\"' fuzzers/core/afl.dict → 295"
```

### Agent Report (WITH EVIDENCE)

"According to \`grep -c '^"' fuzzers/core/afl.dict\`, the dictionary contains **295 entries**."

**Evidence:**
- Command: \`grep -c '^"' fuzzers/core/afl.dict\`
- Output: 295
- Exit code: 0
- Timestamp: 2026-02-06 23:30:00 UTC

---

## Session Summary: Compliance Score

### Governance Adherence

| Rule | Status | Evidence |
|------|--------|----------|
| H006 (Success Declaration Checkpoint) | [OK] | All claims verified before asserting |
| H018 (Numeric Claim Verification) | [OK] | Counted with grep -c before claiming |

### Pattern Followed

[OK] **VERIFY → CITE → CLAIM (with evidence)**

NOT: ~~CLAIM → SKIP VERIFY → USER CORRECTS~~

**Example Type:** GOOD - Exemplary governance compliance  
**Use Case:** Training, reference, pattern replication
