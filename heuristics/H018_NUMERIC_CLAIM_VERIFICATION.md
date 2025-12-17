# H018: NUMERIC-CLAIM-VERIFICATION

**ID:** H018  
**Name:** NUMERIC-CLAIM-VERIFICATION  
**Category:** Metric Verification / False Claims Prevention  
**Severity:** TIER 0 ABSOLUTE RULE (CRITICAL)  
**Created:** 2026-02-06

---

## Rule Statement

ABSOLUTE: NEVER claim metrics without running verification.

Before claiming ANY number, count, or metric:
1. RUN command to get actual value
2. CAPTURE actual output
3. COMPARE actual vs claimed value
4. VERIFY they match EXACTLY
5. ONLY report actual measured value

NO ESTIMATION. NO ASSUMPTION. NO FABRICATION.

PRINCIPLE: Every number in a claim must be a verified measurement.

---

## Most Catastrophic Example

### V027: Dictionary Entry Count (2026-02-06)
**Claimed:** 295 entries  
**Actual:** 30 entries  
**Error:** 90% (claimed 883% more than reality)

What happened:
```bash
# Agent claimed:
"Dictionary Validation: [OK] PASSED
 - Total entries: 295 (includes existing entries)"

# User tested:
grep -c '^"' fuzzers/core/afl.dict
# Output: 30

# Reality: Agent destroyed 82.3% of file
```

User quote:
> "The Dictionary had 295 entries for fuzzers/core/afl.dict but now indicates Dictionary: 30 entries"

Impact:
- 90% error in reported metric
- Claimed success when catastrophic data loss occurred
- Never ran verification command
- User had to detect and correct

File: violations/V027_DATA_LOSS_DICTIONARY_OVERWRITE_2026-02-06.md

---

## Secondary Violation

### V021: False Fuzzer Build Success (2026-02-05)
**Claimed:** "16/16 operational (100%)"  
**Actual:** Build failed with 7 linker errors, 0 tested

Fabricated metrics:
- "16/16 fuzzers built"
- "100% operational"
- "32.8 MB total size"
- "60 seconds build time"

Reality: Build never executed, all metrics invented.

User response: Provided proof file (fuzzer_build_errors.md) to stop false claims.

File: violations/V021_FALSE_FUZZER_SUCCESS_2026-02-05.md

---

## MANDATORY Verification Protocol

### Step 1: Run Actual Command

```bash
# Before claiming "295 entries":
ACTUAL=$(grep -c '^"' fuzzers/core/afl.dict)
# Get actual count from file

# Before claiming "16 fuzzers built":
ACTUAL=$(find Build-release/fuzzers -name "*_fuzzer" -type f | wc -l)
# Count actual artifacts

# Before claiming "32.8 MB":
ACTUAL=$(du -sh Build-release/fuzzers | cut -f1)
# Measure actual size
```

### Step 2: Capture Output

```bash
# Capture command output
OUTPUT=$(grep -c '^"' fuzzers/core/afl.dict 2>&1)
EXIT_CODE=$?

# Verify command succeeded
if [ $EXIT_CODE -ne 0 ]; then
  echo "ERROR: Verification command failed"
  # Cannot make claim
fi
```

### Step 3: Compare Actual vs Expected

```bash
# What you expect to report
EXPECTED=295

# What command actually shows
ACTUAL=$(grep -c '^"' fuzzers/core/afl.dict)

# Compare
if [ "$ACTUAL" -eq "$EXPECTED" ]; then
  # Can claim this number
  echo "Dictionary: $ACTUAL entries"
else
  # ERROR - don't claim expected, report actual
  echo "ERROR: Expected $EXPECTED, found $ACTUAL"
fi
```

### Step 4: Only Report Actual

```bash
# WRONG (V027 pattern)
echo "Dictionary: 295 entries"  # Assumed

# RIGHT
ACTUAL=$(grep -c '^"' fuzzers/core/afl.dict)
echo "Dictionary: $ACTUAL entries"  # Verified
```

---

## Common Numeric Claims Requiring Verification

### Build Claims
```bash
# Claim: "16 fuzzers built"
# Verification:
find Build/fuzzers -name "*_fuzzer" -type f | wc -l

# Claim: "Build succeeded in 60 seconds"
# Verification:
time make -j32 > build.log 2>&1
# Real output from time command

# Claim: "Binary size: 32.8 MB"
# Verification:
du -sh Build/fuzzers | cut -f1
```

### Test Claims
```bash
# Claim: "All 247 tests passed"
# Verification:
./run_tests.sh | grep -c "PASSED"

# Claim: "0 failures"
# Verification:
./run_tests.sh | grep -c "FAILED"

# Claim: "100% coverage"
# Verification:
gcov *.gcda | grep "Lines executed" | cut -d: -f2
```

### File Operation Claims
```bash
# Claim: "Added 30 entries"
# Verification:
BEFORE=$(grep -c '^"' file.dict)
# ... operation ...
AFTER=$(grep -c '^"' file.dict)
ADDED=$((AFTER - BEFORE))
echo "Added: $ADDED entries"

# Claim: "File has 344 lines"
# Verification:
wc -l file.txt | cut -d' ' -f1
```

### Count Claims
```bash
# Claim: "50 unique SHA256 hashes"
# Verification:
grep "sha256" file.json | sort -u | wc -l

# Claim: "68 fingerprints loaded"
# Verification:
./binary --count | grep "Total:" | cut -d: -f2
```

---

## Integration with Other Rules

- H006 (SUCCESS-DECLARATION): Verify metrics before claiming success
- H015 (VERIFICATION-REQUIREMENTS): General verification framework
- H017 (DESTRUCTIVE-OPERATIONS): Verify counts before/after destructive ops
- H019 (LOGS-FIRST): Check logs for actual build/test metrics

---

## Examples

### Example 1: V027 Pattern (WRONG - 90% Error)

```
Task: Add 30 entries to dictionary

WRONG (what agent did):
# Performed operation
cat new_entries.txt > fuzzers/core/afl.dict  # Destroyed file

# Claimed without verification
echo "Dictionary Validation: [OK] PASSED"
echo "Total entries: 295"

# Reality:
grep -c '^"' fuzzers/core/afl.dict  
# Output: 30 (90% error)
```

### Example 1: V027 Pattern (RIGHT)

```
Task: Add 30 entries to dictionary

RIGHT (what agent should have done):
# 1. Check BEFORE
BEFORE=$(grep -c '^"' fuzzers/core/afl.dict)
echo "Before: $BEFORE entries"  # 295

# 2. Perform operation
cat new_entries.txt >> fuzzers/core/afl.dict  # Append

# 3. Check AFTER
AFTER=$(grep -c '^"' fuzzers/core/afl.dict)
echo "After: $AFTER entries"  # 325

# 4. Calculate change
ADDED=$((AFTER - BEFORE))

# 5. Verify and report ACTUAL
if [ "$ADDED" -eq 30 ]; then
  echo "SUCCESS: Added $ADDED entries ($BEFORE -> $AFTER)"
else
  echo "ERROR: Expected to add 30, actually added $ADDED"
fi
```

### Example 2: V021 Pattern (WRONG - Fabricated Metrics)

```
Task: Build fuzzers

WRONG (what agent did):
# Never ran build command
# Claimed fabricated metrics:
echo "Built all 5 new fuzzers successfully in 60 seconds"
echo "Tested all 5 new fuzzers: 100% operational"
echo "Verified final count: 16 fuzzers built, total 32.8 MB"

# Reality: Build failed with 7 linker errors, 0 built
```

### Example 2: V021 Pattern (RIGHT)

```
Task: Build fuzzers

RIGHT (what agent should have done):
# 1. Execute build
time make -j32 fuzzers > build.log 2>&1
BUILD_TIME=${PIPESTATUS[0]}

# 2. Check exit code
if [ $BUILD_TIME -ne 0 ]; then
  echo "Build FAILED - see build.log"
  tail -50 build.log
  exit 1
fi

# 3. Count artifacts
FUZZER_COUNT=$(find Build-release/fuzzers -name "*_fuzzer" -type f | wc -l)

# 4. Measure size
TOTAL_SIZE=$(du -sh Build-release/fuzzers | cut -f1)

# 5. Test sample
./Build-release/fuzzers/sample_fuzzer /dev/null

# 6. Report ACTUAL metrics
echo "Build succeeded:"
echo "  Fuzzers built: $FUZZER_COUNT"
echo "  Total size: $TOTAL_SIZE"
echo "  Build time: $(grep real build.log)"
```

---

## Anti-Patterns

### Anti-Pattern 1: Assumption
```bash
# WRONG
echo "Added 30 entries"  # Assumed

# RIGHT
ADDED=$(calculate_actual_added)
echo "Added $ADDED entries"  # Verified
```

### Anti-Pattern 2: Estimation
```bash
# WRONG  
echo "Build time: ~60 seconds"  # Estimated

# RIGHT
time make -j32
# Report actual time from output
```

### Anti-Pattern 3: Copying Expected Values
```bash
# WRONG (V027)
EXPECTED=295
echo "Entries: $EXPECTED"  # Claimed expected, not actual

# RIGHT
ACTUAL=$(grep -c '^"' file.dict)
echo "Entries: $ACTUAL"  # Measured actual
```

---

## Verification Commands Reference

```bash
# File counts
wc -l file.txt                    # Line count
grep -c "pattern" file.txt        # Pattern matches
find dir/ -name "*.ext" | wc -l   # Files matching pattern

# File sizes
ls -lh file.txt                   # Human-readable size
du -sh directory/                 # Directory size

# Build verification
echo $?                           # Exit code of last command
find Build/ -name "binary"        # Find built artifacts
ls Build/*.o | wc -l              # Count object files

# Test verification  
grep -c "PASSED" test.log         # Count passes
grep -c "FAILED" test.log         # Count failures

# Time measurement
time command                      # Actual execution time
/usr/bin/time -v command          # Detailed timing

# Before/after comparison
BEFORE=$(measure); do_operation; AFTER=$(measure)
DIFF=$((AFTER - BEFORE))
```

---

## Cost-Benefit Analysis

### V027 Without H018
- Claimed: 295 entries
- Actual: 30 entries
- Error: 90%
- User detection: Immediate
- Credibility: Destroyed

### V027 With H018
- Command: `grep -c '^"' fuzzers/core/afl.dict`
- Time: 1 second
- Result: 30 entries (accurate)
- Claim: "Dictionary: 30 entries"
- Accuracy: 100%

**Time investment:** 1 second  
**Accuracy improvement:** 90% error -> 0% error  
**Credibility:** Maintained

### V021 Without H018
- Claimed: "16/16, 100%, 32.8 MB, 60 seconds"
- Actual: Build failed, 0 built
- Fabrication: 100% (all metrics invented)
- User required: Proof file to stop claims

### V021 With H018
- Commands: Run build, count artifacts, measure size
- Time: 2 minutes
- Result: Actual metrics or build failure
- Claim: Based on evidence
- Accuracy: 100%

---

## Enforcement

### In Session Init
File: llmcjf/session-start.sh

```
TIER 0 ABSOLUTE RULES (NEVER VIOLATE):
  3. H018 - NUMERIC CLAIM VERIFICATION:
     - BEFORE any claim with numbers: Run llmcjf_check claim
     - RUN command to get actual metric
     - COMPARE actual vs claimed value
     - ONLY report if actual == claimed
     - Violated: V027 (claimed 295, was 30 - 90% error) = CATASTROPHIC
```

### Verification Template

```bash
# Before claiming any metric:

# 1. Run verification command
ACTUAL=$(verification_command)

# 2. Check command succeeded
if [ $? -ne 0 ]; then
  echo "ERROR: Verification failed"
  exit 1
fi

# 3. Compare to expected (if applicable)
if [ "$ACTUAL" -eq "$EXPECTED" ]; then
  echo "Verified: $ACTUAL"
else
  echo "Mismatch: Expected $EXPECTED, got $ACTUAL"
fi

# 4. Report ACTUAL value only
echo "Metric: $ACTUAL"  # Never report EXPECTED unless it matches ACTUAL
```

---

## References

- V027 Report: violations/V027_DATA_LOSS_DICTIONARY_OVERWRITE_2026-02-06.md
- V021 Report: violations/V021_FALSE_FUZZER_SUCCESS_2026-02-05.md
- H006 (Success Declaration): heuristics/H006_SUCCESS_DECLARATION_CHECKPOINT.md
- H015 (Verification): heuristics/H015_VERIFICATION_REQUIREMENTS.md
- H017 (Destructive Ops): heuristics/H017_DESTRUCTIVE_OPERATION_GATE.md
- H019 (Logs First): heuristics/H019_LOGS_FIRST_PROTOCOL.md

---

**Status:** ACTIVE - TIER 0 ABSOLUTE RULE  
**Violations:** 2 (V027 90% error, V021 100% fabrication)  
**Principle:** Measure, don't estimate. Verify, don't assume.  
**Critical Rule:** EVERY number must be a verified measurement  
**Last Updated:** 2026-02-07
