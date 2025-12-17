# Fuzzer Count Verification Protocol

## Mandatory Checks Before Changing Fuzzer Counts

### Context: Two Different Fuzzer Configurations

**Smoke Test Workflow (`ci-fuzzer-smoke-test.yml`):**
- Runs 13 fuzzers in matrix
- Excludes: `icc_spectral_fuzzer` (timeout issues)
- Purpose: Quick validation (60s per fuzzer)

**Comprehensive Build Workflow (`ci-comprehensive-build-test.yml`):**
- Builds ALL 14 fuzzers via CMake
- Includes: `icc_spectral_fuzzer`
- Purpose: Full build verification

### Verification Checklist

Before changing ANY fuzzer count assertion:

1. **Check CMakeLists.txt**
   ```bash
   grep -E "add_executable.*fuzzer" Testing/Fuzzing/CMakeLists.txt | wc -l
   ```
   Expected: 14 (all fuzzers defined in CMake)

2. **Check Smoke Test Matrix**
   ```bash
   grep -A 15 "matrix:" .github/workflows/ci-fuzzer-smoke-test.yml | grep "icc_.*_fuzzer" | wc -l
   ```
   Expected: 13 (spectral excluded from matrix)

3. **Understand WHY Different**
   - Smoke test: Runtime limitation (spectral times out >60s)
   - Comprehensive: Build verification (all fuzzers must compile)

4. **Verify BOTH Workflows**
   - Smoke test: Matrix count must match executable list
   - Comprehensive: Count must match CMakeLists.txt definitions

### Error Response Protocol

**When fuzzer count mismatch occurs:**

1. DO NOT immediately change expected count
2. CHECK which fuzzers are actually built: `ls Build*/Testing/Fuzzing/icc_*_fuzzer`
3. CHECK CMakeLists.txt definitions
4. CHECK workflow matrix configuration
5. UNDERSTAND root cause before fixing

### Violation V022 Lesson

**What Happened:**
- User reported: "Expected 13 fuzzers, got 14"
- Agent changed: `if [ "$FUZZER_COUNT" -ne 13 ]` in comprehensive workflow
- Result: Broke working comprehensive build test
- Root cause: Different workflows have different configurations

**Should Have Done:**
1. Check CMakeLists.txt → 14 fuzzers defined
2. Check smoke test matrix → 13 fuzzers listed
3. Realize: TWO DIFFERENT counts are correct
4. Fix: Keep 14 for comprehensive, verify smoke test has 13

### Quick Reference

```yaml
# Smoke Test (ci-fuzzer-smoke-test.yml)
Expected Count: 13
Excludes: icc_spectral_fuzzer
Reason: Timeout in 60-second runs

# Comprehensive Build (ci-comprehensive-build-test.yml)  
Expected Count: 14
Includes: ALL fuzzers from CMakeLists.txt
Reason: Build verification of all defined fuzzers
```

### Related Violations
- V022: Fuzzer count regression (2026-02-06)
- Pattern: Changed value without understanding context
