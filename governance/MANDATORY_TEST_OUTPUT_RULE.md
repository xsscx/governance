# MANDATORY-TEST-OUTPUT Rule

**Created:** 2026-02-03  
**Trigger:** V013-V016 loop violations  
**Enforcement:** ZERO TOLERANCE

---

## The Rule

**Before claiming any of these words:**
- "removed"
- "fixed"
- "complete"
- "ready"
- "restored"
- "added"
- "updated"
- "verified"

**MUST show:**
1. Test command
2. Test execution
3. Test output
4. Verification result

**No exceptions. Response REJECTED if missing.**

---

## Why This Rule Exists

### The Violations

**V013:** Claimed "unicode removed" → Never tested → Still broken  
**V014:** Claimed "copyright restored" → Never tested → Still broken  
**V016:** User discovers both still broken → Had to fix AGAIN

**Cost:** 60 minutes wasted (vs 30 seconds testing)  
**Ratio:** 120× waste

---

## Examples

### [FAIL] WRONG (Violation)

```
I've successfully removed all unicode characters from the source files.
The build completed successfully and the binary has been updated.
```

**Problem:** Claims with no evidence. Response REJECTED.

### [OK] CORRECT (Compliant)

```bash
$ grep -P "[\x80-\xFF]" *.cpp | wc -l
0

$ ./binary-test -h test.icc | grep -P "[\x80-\xFF]" | wc -l
0
```

**Evidence shown:** 4 lines, no claims needed.

---

## Governance Framework Integration

From https://github.com/xsscx/governance:

```yaml
# enforcement/violation-patterns-v2.yaml
false_success_pattern:
  detection:
    - claim_contains: ["removed", "fixed", "complete", "ready"]
    - evidence_shown: false
  action: REJECT_RESPONSE
  message: "Show test output before claiming success"
```

---

## Enforcement Checklist

**Before EVERY response claiming completion:**

```yaml
required:
  - [ ] Test command stated
  - [ ] Test executed  
  - [ ] Output shown
  - [ ] Verification passed
  - [ ] Evidence > 80% of response
  - [ ] Narrative < 20% of response
```

**If ANY checkbox unchecked:** STOP. Run tests. Show output.

---

## Pattern Detection

**Agent claiming success indicators:**
- "Successfully [verb]"
- "[Task] completed ✓"
- "Ready for [next step]"
- "All [items] [action]"

**Required response:**
- Test output proving claim
- No test output = VIOLATION

---

## Integration With Existing Rules

Works with:
- **H011** - Check documentation before debugging
- **FILE-TYPE-GATES** - Consult docs before modifying gated files
- **SUCCESS-DECLARATION-CHECKPOINT** - Verify before claiming complete

**Supersedes:** All previous "test before claiming" informal rules

**Status:** MANDATORY, ZERO TOLERANCE, AUTOMATED ENFORCEMENT

---

**Rule Status:** ACTIVE  
**Violations Prevented:** V013, V014, V016 (all would be REJECTED)  
**Compliance Requirement:** 100%  
**Enforcement:** Automated via governance framework scripts
