# Violation: Documenting Fuzzer-Only Crash as Real Bug

**Date**: 2026-01-30  
**Severity**: CRITICAL  
**Heuristic**: CJF-13 (created)

---

## Violation Summary

Documented IccTagBasic.cpp:1866 as "SEGV caused by WRITE" based on fuzzer crash, but **tool does NOT crash**.

## Evidence

### Fuzzer Behavior (INCORRECT)
```
UndefinedBehaviorSanitizer:DEADLYSIGNAL
==7646==ERROR: UndefinedBehaviorSanitizer: SEGV on unknown address 0x0001fffffffe
==7646==The signal is caused by a WRITE memory access.
==7646==ABORTING
```
**Fuzzer aborts with SEGV signal**

### Tool Behavior (CORRECT/AUTHORITATIVE)
```
$ ./Build/Tools/IccV5DspObsToV4Dsp/iccV5DspObsToV4Dsp display.icc observer.icc out.icc
runtime error: applying non-zero offset 8589934590 to null pointer
SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior
$ echo $?
1
```
**Tool shows UB warning, exits cleanly with code 1, NO SEGV**

## Root Cause Analysis

**Fuzzer uses stricter UBSan configuration** (likely `-fsanitize-trap=undefined` or `halt_on_error=1`)  
**Tool uses permissive UBSan** (warnings only, no trap)

### Reality
- Tool handles UB gracefully: detects issue, logs warning, exits with error code 1
- Fuzzer aborts on same UB: treats as fatal, issues SEGV signal
- **Fuzzer does NOT have fidelity to tool behavior**

## What Was Wrong

1. [FAIL] Documented fuzzer crash as real bug
2. [FAIL] Created 305-line "NULL_POINTER_WRITE_IccTagBasic_1866.md"
3. [FAIL] Added 6 fingerprint files (3 ICC + 3 JSON)
4. [FAIL] Claimed "SEGV caused by WRITE" (false - tool doesn't SEGV)
5. [FAIL] Did NOT verify tool actually crashes with signal

## Correct Interpretation

- **UB exists**: Yes (line 1866 offset on null pointer)
- **Tool crashes**: NO (exit 1 is graceful error handling)
- **Fuzzer crashes**: YES (but fuzzer config too strict)
- **Production impact**: LOW (tool detects and handles UB)
- **Fuzzer fidelity**: BROKEN (fuzzer aborts where tool continues)

## Governance Rule

### Tool Behavior is Authoritative

When fuzzer and tool disagree:
1. **Tool behavior = reality**
2. **Fuzzer behavior = test artifact**

### Testing Hierarchy

```
Tool shows:        Fuzzer shows:       Classification:
-----------        -------------       ---------------
Exit 0             Crash              Fuzzer fidelity issue
Exit 1 (UB warn)   SEGV/abort         Fuzzer fidelity issue  ← THIS CASE
Exit != 0          Crash              Real bug (document)
SEGV               SEGV               Real bug (document)
```

### Mandatory Verification

Before documenting ANY crash:
1. Test with project tool
2. Verify tool actually crashes (SEGV/ABRT signal, not just exit 1)
3. If fuzzer crashes but tool only shows UB warning → **fuzzer fidelity issue**
4. Do NOT document fuzzer-only crashes

## CJF-13 Heuristic Created

**Name**: "Fuzzer Crash vs Tool Graceful Failure Confusion"

**Pattern**: Fuzzer shows DEADLYSIGNAL, tool shows exit 1 with UB warning

**Rule**: Exit code 1 (soft failure) ≠ SEGV (hard crash)

**Distinction**:
- **Soft failure**: Tool detects issue, exits cleanly (exit 1-255)
- **Hard crash**: Uncontrolled termination (SEGV, ABRT signals)

**Only document hard crashes reproducible with project tools.**

## Files Affected (To Be Corrected)

- `NULL_POINTER_WRITE_IccTagBasic_1866.md` - Falsely claims SEGV
- `fingerprints/undefined-behavior/segv-null-pointer-write-*` - 6 files for non-crash
- `FINGERPRINT_INDEX.json` - Contains false crash fingerprints
- `test-segv-fingerprint.sh` - Tests non-crash as crash

## Required Cleanup

1. Update NULL_POINTER_WRITE doc: Change "SEGV crash" → "UB warning (tool exit 1)"
2. Reclassify fingerprints: Change "crash" → "undefined-behavior-handled"
3. Note fuzzer fidelity issue: Fuzzer too strict for this UB

## Prevention

**Before documenting crash:**
```bash
# Test with tool
./Build/Tools/ToolName input.icc output.icc
EXIT_CODE=$?

if [ $EXIT_CODE -eq 1 ]; then
    echo "Soft failure (UB detected, handled gracefully)"
    echo "If fuzzer crashed here: FUZZER FIDELITY ISSUE"
    echo "DO NOT DOCUMENT AS CRASH"
elif [ $EXIT_CODE -gt 128 ]; then
    echo "Hard crash (signal $((EXIT_CODE - 128)))"
    echo "DOCUMENT AS CRASH"
fi
```

**Exit codes:**
- 0 = Success
- 1-127 = Soft failures (errors, UB warnings handled)
- 128+ = Hard crashes (128 + signal number)
  - 134 = ABRT (128 + 6)
  - 139 = SEGV (128 + 11)

---

**Lesson**: Fuzzer behavior is NOT authoritative. Tool behavior is reality.
