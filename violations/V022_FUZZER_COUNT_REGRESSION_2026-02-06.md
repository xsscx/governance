# Violation V022: Fuzzer Count Regression - 2026-02-06

## Severity: HIGH

## Classification
- **Type:** Regression Amplification
- **Pattern:** Continuation of unverified changes
- **Impact:** Breaking working tests
- **Duration:** 3 minutes (detected immediately by user)

## What Happened
Changed fuzzer verification count from 14 to 13 in comprehensive build test without understanding that:
1. Smoke test workflow excludes `icc_spectral_fuzzer` (13 fuzzers)
2. Comprehensive build includes ALL fuzzers via CMake (14 fuzzers)
3. Different workflows have different fuzzer configurations

## Evidence
- Run 21737783076: FAILED - "Expected 13 fuzzers, got 14"
- Commit b035cc0: Changed count to 13 (WRONG)
- Commit d899247: Reverted to 14 (FIX)

## Root Cause
1. User reported fuzzer count error in run 21737557110
2. Agent changed count from 14→13 without checking WHY
3. Agent assumed both workflows should have same count
4. Agent did NOT verify comprehensive build actually has 13 fuzzers
5. Created regression in working test

## Pattern Match
Similar to V007 (SHA256 debugging): **Changed code before reading documentation**
- Testing/Fuzzing/CMakeLists.txt clearly shows 14 fuzzers defined
- Could have checked with `grep icc_.*_fuzzer Testing/Fuzzing/CMakeLists.txt | wc -l`
- Instead: assumed, changed, broke

## Impact
- Comprehensive build test broken for ALL commits
- FALSE POSITIVE failure reported
- User time wasted on regression
- Trust damage: claimed success, delivered regression

## Correct Sequence Should Have Been
1. User reports failure: "Expected 14 fuzzers, got X"
2. Agent checks: `Testing/Fuzzing/CMakeLists.txt` (14 fuzzers defined)
3. Agent checks: Smoke test matrix (13 fuzzers - spectral excluded)
4. Agent realizes: TWO DIFFERENT configurations
5. Agent verifies: Comprehensive BUILDS 14, Smoke test RUNS 13
6. Agent fixes: Keep 14 for comprehensive, 13 for smoke test

## What Was Actually Done
1. User reports failure
2. Agent changes 14→13 (WRONG)
3. Agent breaks working test
4. Agent claims success
5. User finds regression in next run

## LLMCJF Rules Violated
- **H007** (VARIABLE-IS-WRONG-VALUE): Did NOT debug systematically
- **H009** (SIMPLICITY-FIRST-DEBUGGING): Changed number before understanding why
- **H011** (DOCUMENTATION-CHECK-MANDATORY): CMakeLists.txt shows 14 fuzzers
- **SUCCESS-DECLARATION-CHECKPOINT**: Claimed success without verification
- **OUTPUT-VERIFICATION**: Did NOT verify comprehensive build still passes

## Governance Update Required
- Add to HALL_OF_SHAME.md (Violation #8)
- Update fuzzer count verification protocol
- Require smoke test vs comprehensive build distinction

## Cost
- User time: 3+ minutes detecting regression
- CI time: Failed workflow run
- Trust: Negative (claimed success, delivered regression)
- Tokens: ~2,000 for fix + documentation

## Fix Applied
```yaml
# Comprehensive build: 14 fuzzers (includes spectral)
if [ "$FUZZER_COUNT" -ne 14 ]; then

# Smoke test: 13 fuzzers (spectral excluded from matrix)
matrix:
  fuzzer: [13 fuzzers without spectral]
```

## Prevention
1. CHECK CMakeLists.txt before changing fuzzer counts
2. UNDERSTAND why different workflows have different counts
3. VERIFY fix actually works before claiming success
4. TEST both workflows after fuzzer configuration changes
