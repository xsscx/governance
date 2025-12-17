# H015: VERIFICATION-REQUIREMENTS

**ID:** H015  
**Name:** VERIFICATION-REQUIREMENTS  
**Category:** General Verification / Quality Assurance  
**Severity:** TIER 2 VERIFICATION GATE (HIGH)  
**Created:** 2026-02-02

---

## Rule Statement

General verification requirements for all operations.

Before claiming completion of any task:
1. Execute verification command
2. Check output matches expected result
3. Compare before/after state
4. Count/measure actual metrics
5. Test critical functionality

Referenced in: Multiple violations as general verification framework.

PRINCIPLE: Don't trust, verify. Every claim needs evidence.

---

## Core Verification Principles

### 1. Test Before Claiming
```
WRONG: Make change -> Claim success
RIGHT: Make change -> Test -> Verify result -> Claim success
```

### 2. Count Actual Metrics
```
WRONG: "16 fuzzers built" (assumed)
RIGHT: find Build -name "*_fuzzer" | wc -l
       -> 16 fuzzers built (verified)
```

### 3. Compare States
```
BEFORE: wc -l file.txt  -> 344 lines
ACTION: Append entries
AFTER:  wc -l file.txt  -> 406 lines
VERIFY: 406 - 344 = 62 new lines (matches expectation)
```

### 4. Functional Testing
```
Not enough: Binary compiled
Must also: Binary executes and produces expected output
```

---

## Verification Levels

### Level 0: No Verification (VIOLATION)
```bash
# Make change
sed -i 's/old/new/' file.txt

# Claim success
echo "File updated successfully"

# Problem: Never verified change worked
```

### Level 1: Existence Check
```bash
# Make change
sed -i 's/old/new/' file.txt

# Verify exists
ls -la file.txt

# Problem: File exists but may have wrong content
```

### Level 2: Content Verification
```bash
# Make change
sed -i 's/old/new/' file.txt

# Verify content
grep "new" file.txt

# Better: Content verified
# Still: Only checks presence, not correctness
```

### Level 3: Complete Verification (REQUIRED)
```bash
# Before state
BEFORE=$(grep -c "old" file.txt)

# Make change
sed -i 's/old/new/' file.txt

# After state
AFTER=$(grep -c "new" file.txt)

# Verify
if [ "$BEFORE" -eq "$AFTER" ] && [ "$AFTER" -gt 0 ]; then
  echo "SUCCESS: Replaced $AFTER instances"
else
  echo "FAIL: Before=$BEFORE, After=$AFTER"
fi

# Best: Before/after comparison with metrics
```

---

## Domain-Specific Verification

### Build Verification
```bash
# Not enough: cmake succeeded
# Required:
make -j32 2>&1 | tee build.log
if [ ${PIPESTATUS[0]} -eq 0 ]; then
  # Count artifacts
  BINARY_COUNT=$(find Build -name "target" -type f | wc -l)
  echo "Build succeeded: $BINARY_COUNT binaries created"
else
  echo "Build failed, see build.log"
fi
```

### Test Verification
```bash
# Not enough: Tests ran
# Required:
./run_tests.sh 2>&1 | tee test.log
PASSED=$(grep -c "PASSED" test.log)
FAILED=$(grep -c "FAILED" test.log)
echo "Tests: $PASSED passed, $FAILED failed"
```

### File Operation Verification
```bash
# Not enough: cp succeeded
# Required:
cp source.txt dest.txt
if cmp -s source.txt dest.txt; then
  echo "File copied correctly"
else
  echo "File copy verification failed"
fi
```

### Package Verification
```bash
# Not enough: Package created
# Required:
tar czf package.tar.gz files/
tar tzf package.tar.gz | wc -l  # Count files
tar xzf package.tar.gz -C /tmp/test/  # Test extraction
./test-package.sh /tmp/test/  # Functional test
```

---

## Integration with Specific Rules

### H006 (SUCCESS-DECLARATION-CHECKPOINT)
General verification framework for success claims.

### H018 (NUMERIC-CLAIM-VERIFICATION)
Specific verification for numeric/metric claims.

### H019 (LOGS-FIRST-PROTOCOL)
Verification for build/test status claims.

---

## Verification Checklist Template

### Before Claiming Success

```
Operation: [Description]

Verification Steps:
[ ] Executed verification command
[ ] Checked exit code / status
[ ] Counted actual metrics
[ ] Compared before/after state
[ ] Tested functionality
[ ] Output matches expectation
[ ] No errors in logs

Evidence:
  - Command: [verification command]
  - Result: [actual output]
  - Metrics: [actual counts/measurements]
  
Status: [SUCCESS/FAIL]
```

---

## Common Verification Patterns

### Pattern 1: Count Files
```bash
# Before
BEFORE=$(find dir/ -name "*.txt" | wc -l)

# Operation
rm dir/obsolete.txt

# Verify
AFTER=$(find dir/ -name "*.txt" | wc -l)
EXPECTED=$((BEFORE - 1))

if [ "$AFTER" -eq "$EXPECTED" ]; then
  echo "SUCCESS: Deleted 1 file"
else
  echo "FAIL: Expected $EXPECTED, got $AFTER"
fi
```

### Pattern 2: Check Output Format
```bash
# Execute
./binary input.txt > output.txt

# Verify format
if grep -q "^Expected Header" output.txt && \
   grep -q "Expected Footer$" output.txt; then
  echo "SUCCESS: Output format correct"
else
  echo "FAIL: Output format incorrect"
fi
```

### Pattern 3: Functional Test
```bash
# Execute
./binary --new-feature input.txt > output.txt

# Verify function works
if grep -q "Feature Result:" output.txt; then
  RESULT=$(grep "Feature Result:" output.txt | cut -d: -f2)
  echo "SUCCESS: Feature returned $RESULT"
else
  echo "FAIL: Feature not working"
fi
```

---

## Anti-Patterns

### Anti-Pattern 1: Assume Success
```bash
# WRONG
make install
echo "Installation complete"

# RIGHT
make install
if [ $? -eq 0 ] && [ -f /usr/bin/program ]; then
  echo "Installation complete"
else
  echo "Installation failed"
fi
```

### Anti-Pattern 2: Partial Verification
```bash
# WRONG (only checks file exists)
touch file.txt
ls file.txt
echo "File created"

# RIGHT (checks file has expected content)
echo "data" > file.txt
if grep -q "data" file.txt; then
  echo "File created with correct content"
else
  echo "File creation failed"
fi
```

### Anti-Pattern 3: No Metrics
```bash
# WRONG (no actual count)
echo "All tests passed"

# RIGHT (actual metric)
PASSED=$(grep -c "PASS" test.log)
TOTAL=$(grep -c "TEST" test.log)
echo "Tests passed: $PASSED / $TOTAL"
```

---

## Referenced In Violations

Multiple violations reference general verification requirements:

- V003: Unverified file copy (should have checked copyright)
- V005: Unverified metadata change (should have compared before/after)
- V008: Unverified HTML generation (should have tested all pages)
- V010: Unverified build (should have counted artifacts)
- V012: Unverified package (should have tested extraction)
- V013: Unverified unicode removal (should have tested output)
- V021: Unverified fuzzer build (should have run make)
- V027: Unverified dictionary update (should have counted entries)

**Pattern:** Most violations involve claiming success without verification

---

## Verification Time Investment

### Typical Costs
- File operation: 5 seconds (check file exists and has expected content)
- Build operation: 10 seconds (check exit code, count artifacts)
- Test operation: 15 seconds (run tests, count passes/fails)
- Package operation: 30 seconds (test extraction, verify contents)

### Typical Savings
- Prevents false success claims: 5-50 minutes
- Prevents user correction cycles: 10-30 minutes
- Prevents reputation damage: Priceless

**ROI:** 10-100x return on verification time

---

## References

- H006 (Success Declaration): heuristics/H006_SUCCESS_DECLARATION_CHECKPOINT.md
- H018 (Numeric Claims): heuristics/H018_NUMERIC_CLAIM_VERIFICATION.md
- H019 (Logs First): heuristics/H019_LOGS_FIRST_PROTOCOL.md
- Multiple violation reports reference verification requirements
- Governance Rules: profiles/governance_rules.yaml

---

**Status:** ACTIVE - TIER 2 VERIFICATION GATE  
**Purpose:** General verification framework  
**Referenced By:** Multiple rules (H006, H018, H019)  
**Principle:** Don't trust, verify. Every claim needs evidence.  
**Last Updated:** 2026-02-07
