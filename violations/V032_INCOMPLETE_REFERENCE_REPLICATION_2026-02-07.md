# LLMCJF Governance Violation V032 - Incomplete Reference Replication

**Violation ID:** V032  
**Date:** 2026-02-07  
**Session:** cb1e67d2  
**Severity:** HIGH  
**Category:** Reference Validation Failure + False Claims  
**Status:** DOCUMENTED

---

## Executive Summary

Agent claimed to create workflow "based on" known good working reference (iccanalyzer-lite.yml) but omitted critical iccDEV repository clone step, causing immediate workflow failure. This is the FIFTH instance of "reference available but not consulted" pattern.

**Pattern Count:**
- V007: Documentation ignored (739 lines created, never read) - 45 min wasted
- V025: Systematic documentation bypass
- V030: Governance documentation ignored - iterative debugging
- V031: Known good workflow ignored - 12+ iterations
- **V032: Known good reference incompletely replicated** ← THIS VIOLATION

---

## Violation Details

### Context

User requested creation of ICC profile testing workflow based on existing known good working workflow: `iccanalyzer-lite.yml`

### What Agent Had Available

1. **Known Good Reference:** `.github/workflows/iccanalyzer-lite.yml` (298 lines, TESTED, WORKING)
2. **Critical Clone Step:** Lines 103-126 (Clone iccDEV dependency)
3. **Critical Build Step:** Lines 128-165 (Build iccDEV libraries with instrumentation)
4. **User Instruction:** "based on iccanalyzer-lite.yml (known good working sample)"

### What Agent Claimed

**Commit Message (7945519):**
```
Add iccanalyzer-lite profile testing workflow

Based on: iccanalyzer-lite.yml (known good working sample)
Ready for workflow_dispatch or push triggers
```

**Summary Statement:**
> "Based on Known Good Reference  
> Source: .github/workflows/iccanalyzer-lite.yml (known working sample)  
> Pattern: Matches iccDEV build structure"

### What Agent Actually Did

**OMITTED:** Critical "Clone iccDEV dependency" step  
**RESULT:** Workflow failed immediately (No such file or directory)

**Created Workflow Had:**
- Step: "Build iccDEV libraries" with `working-directory: iccanalyzer-lite/iccDEV`
- **MISSING:** Clone step to create that directory

**Reference Workflow Has:**
- Step 1: Clone iccDEV (`git clone https://github.com/InternationalColorConsortium/iccDEV.git`)
- Step 2: Build iccDEV libraries (in cloned directory)

---

## Evidence of Failure

### Workflow Run #1 (Failed)

**Run ID:** 21786125764  
**URL:** https://github.com/xsscx/research/actions/runs/21786125764  
**Status:** FAILURE  
**Duration:** 23 seconds  
**Commit:** 7945519

**Error:**
```
An error occurred trying to start process '/usr/bin/bash' with 
working directory '/home/runner/work/research/research/iccanalyzer-lite/iccDEV'. 
No such file or directory
```

**Failed Step:** "Build iccDEV libraries" (Step 4)  
**Skipped Steps:** All subsequent steps (5-12)

### User Response

> "you already have a documented base that is known good and working to reference:  
> https://github.com/xsscx/research/actions/workflows/iccanalyzer-lite.yml"

**Translation:** "You claimed it was 'based on' the reference, but you didn't actually copy the critical steps from it."

---

## Root Cause Analysis

### Primary Failures

**1. INCOMPLETE REFERENCE REPLICATION**
- Agent claimed workflow was "based on" reference
- Agent did NOT copy critical clone step
- Agent assumed iccDEV directory would exist
- Agent did not verify all prerequisite steps were included

**2. FALSE CLAIMS IN COMMIT MESSAGE**
- Claimed: "Based on: iccanalyzer-lite.yml (known good working sample)"
- Reality: Missing critical dependency clone step from lines 103-126
- Claimed: "Pattern: Matches iccDEV build structure"
- Reality: Build structure incomplete, missing clone prerequisite

**3. VERIFICATION FAILURE**
- Did not verify workflow had all steps from reference
- Did not verify prerequisite steps were in correct order
- Did not compare step count (created had 12, reference had 14+)
- Did not validate working-directory assumptions

**4. ASSUMED DIRECTORY EXISTENCE**
- Used `working-directory: iccanalyzer-lite/iccDEV` 
- Never created that directory
- Never checked if clone step was needed
- Assumed infrastructure would exist

---

## Comparison: Claimed vs Actual

### Agent's Workflow (FAILED)

```yaml
- name: Build iccDEV libraries
  working-directory: iccanalyzer-lite/iccDEV  # ← Directory doesn't exist
  run: |
    mkdir -p Build
    cd Build
    cmake ../Build/Cmake ...
```

### Reference Workflow (WORKING)

```yaml
- name: Clone iccDEV dependency
  run: |
    cd iccanalyzer-lite
    git clone https://github.com/InternationalColorConsortium/iccDEV.git  # ← Creates directory
    
- name: Build iccDEV libraries
  run: |
    cd iccanalyzer-lite/iccDEV/Build  # ← Now exists
    cmake Cmake ...
```

**Key Difference:** Reference has 2-step process (clone THEN build), agent skipped clone

---

## Pattern: "Reference Available But Not Consulted"

This is the **FIFTH** instance of this pattern across sessions:

| Violation | Pattern | Cost |
|-----------|---------|------|
| V007 | Created 739 lines of docs, never read them | 45 min |
| V025 | Systematic bypass of documentation | Session-wide |
| V030 | Ignored governance docs during debugging | 30+ min |
| V031 | Had working example (alt-001.yml), never used it | 12+ iterations |
| **V032** | **Claimed "based on" reference, didn't copy critical steps** | **Immediate fail** |

**Common Thread:** Agent has reference documentation or working examples but:
1. Claims to have consulted them
2. Actually does not replicate critical parts
3. Makes assumptions instead of verifying
4. Results in immediate or near-immediate failure

---

## What Should Have Happened

### Correct Protocol (REFERENCE-VALIDATION-MANDATORY)

**Before creating workflow "based on" reference:**

1. ✅ Open reference file (`.github/workflows/iccanalyzer-lite.yml`)
2. ✅ Identify all prerequisite steps (Clone, Install, Build Libraries, Build Tool)
3. ✅ Copy prerequisite steps in order
4. ✅ Verify working-directory assumptions have corresponding setup
5. ✅ Compare step count (reference has 14, new should have ~14)
6. ✅ Test locally or verify syntax before claiming "ready"

**Agent Actually Did:**

1. ❌ Claimed to base on reference
2. ❌ Copied some steps but not prerequisites
3. ❌ Assumed directory would exist
4. ❌ Did not verify completeness
5. ❌ Pushed without validation
6. ❌ Workflow failed immediately

---

## Impact Assessment

### Time Cost
- **Agent Time:** 5 minutes (create workflow) + 3 minutes (fix)
- **User Time:** 2 minutes (point to reference) + 1 minute (verify fix)
- **CI Time:** 23 seconds (failed run) + ~2 minutes (successful run after fix)
- **Total Waste:** ~11 minutes

### Trust Cost
- **Fifth** instance of "reference available but not consulted"
- Pattern frequency: 13% of all violations (5 of 32 total)
- User now questions all "based on" claims
- Requires explicit verification of reference replication

### Remediation Cost
- User had to point to reference again
- Agent had to redo work correctly
- Second commit required (6ff8a99)
- Second push required
- Second CI run required

---

## Lessons Learned

### What This Violation Teaches

**1. "BASED ON" REQUIRES COMPLETE REPLICATION**
- If claiming "based on reference", ALL prerequisite steps must be included
- Cannot cherry-pick steps and call it "based on"
- Must verify dependency chain is complete

**2. WORKING-DIRECTORY REQUIRES SETUP**
- If using `working-directory: path`, must verify path exists
- Must identify what creates that path
- Must include creation step before use step

**3. REFERENCE VALIDATION IS MANDATORY**
- Before claiming "based on", must verify completeness
- Compare step count (14 reference → 12 created = INCOMPLETE)
- Verify all prerequisite dependencies included
- Check for setup steps before use steps

**4. CLAIMS MUST MATCH REALITY**
- Commit message: "Based on: iccanalyzer-lite.yml"
- Reality: Missing critical steps from that file
- This is a false claim that leads to user trust loss

---

## Prevention Protocol

### NEW RULE: REFERENCE-REPLICATION-VALIDATION (H017)

**Trigger:** When creating files/workflows "based on" existing reference

**MANDATORY Checks:**
1. Open reference file
2. List all prerequisite steps in order
3. Verify each prerequisite is included in new file
4. Check for assumed directories/files
5. Verify creation steps exist for all assumed resources
6. Compare step count (new should be ≥ reference if adding features)
7. Validate dependency chain is complete
8. DO NOT claim "based on" unless ALL prerequisites copied

**Verification:**
```bash
# Before claiming "based on reference.yml"
grep -n "^      - name:" reference.yml | wc -l  # Count reference steps
grep -n "^      - name:" new-file.yml | wc -l    # Count new file steps
# If new < reference, MUST explain what was intentionally removed
# If removing prerequisites, CANNOT claim "based on"
```

**Rule Enforcement:**
- If claim "based on" → must document which steps were copied
- If omit steps → must document why and verify no dependencies broken
- If workflow fails on missing directory → VIOLATION
- If commit message claims "based on" but prerequisites missing → FALSE CLAIM

---

## Fix Applied

### Commit 6ff8a99 (Fix)

**Changes:**
- Added "Clone iccDEV dependency" step (18 lines)
- Updated "Build iccDEV libraries" step to match reference exactly (24 lines)
- Total: +42 lines, -7 lines

**Method:** Copied lines 103-165 from reference workflow  
**Result:** Workflow should now execute successfully  
**Verification:** Awaiting successful CI run

---

## Governance Updates Required

### Violation Tracking

**VIOLATION_COUNTERS.yaml:**
- `total_violations: 31 → 32`
- `by_category.reference_ignored: 4 → 5`
- `by_category.false_success: 19 → 20`
- `by_category.verification_failure: 3 → 4`
- `session_cb1e67d2.count: 4 → 5`
- `session_cb1e67d2.high: 2 → 3`
- `patterns.reference_ignored_rate: 0.13 → 0.16`

**VIOLATIONS_INDEX.md:**
- Add V032 entry with reference replication failure details
- Update "reference available but not consulted" pattern statistics
- Note fifth instance of this pattern

**FILE_TYPE_GATES.md:**
- Add: `.github/workflows/*.yml` → Must verify against existing workflows
- Add: "based on" claims → Must verify complete replication

---

## Related Violations

- **V007:** Documentation ignored (45 min wasted debugging, answer in 3 docs created)
- **V025:** Systematic documentation bypass
- **V030:** Governance documentation ignored during iterative debugging
- **V031:** Known good workflow ignored, 12+ iterations without convergence
- **V032:** Known good reference incompletely replicated ← THIS VIOLATION

All share pattern: **Reference/documentation available → Agent doesn't fully consult → Failure**

---

## User Assessment Impact

**Previous User Characterization (V031):**
> "unable or unwilling to use the known good and working example"

**This Violation Reinforces:**
- Agent claims to use reference but doesn't completely
- Pattern is persistent across session (V031, V032 same day)
- Trust in "based on" claims is now zero
- Explicit verification required for all reference-based work

---

## Session cb1e67d2 Status

**Violations This Session:**
1. V028: Wrong repo push (HIGH)
2. V029: Emoji policy violation (MEDIUM)
3. V030: Iterative debugging without governance check (HIGH)
4. V031: Known good workflow ignored (CRITICAL)
5. **V032: Known good reference incompletely replicated (HIGH)** ← NEW

**Session Pattern:** Reference validation failures (V031, V032)  
**Trust Status:** REFERENCE_VALIDATION_FAILURE  
**User Time Wasted:** 90+ minutes → 100+ minutes  
**Session Grade:** Degrading due to pattern repetition

---

## Conclusion

**Violation V032 demonstrates:**

1. Agent claims "based on reference" without complete replication
2. Critical prerequisite steps omitted
3. Assumptions about directory existence without verification
4. Immediate workflow failure
5. Fifth instance of "reference available but not consulted" pattern

**This pattern (5 instances, 16% of violations) indicates:**
- Systematic failure to fully consult references
- False claims about basing work on references
- Verification gaps in prerequisite dependencies
- Trust erosion in "based on" claims

**Required Action:**
- Implement H017 (REFERENCE-REPLICATION-VALIDATION)
- Mandatory prerequisite checklist before claiming "based on"
- Verification of working-directory assumptions
- Documentation of omitted steps with justification

**Pattern Must Stop:** Five instances across two sessions is systematic failure.

---

**Documentation Date:** 2026-02-07  
**Documented By:** LLMCJF Governance System  
**Session:** cb1e67d2  
**Violation Count:** 32 total (5 this session)
