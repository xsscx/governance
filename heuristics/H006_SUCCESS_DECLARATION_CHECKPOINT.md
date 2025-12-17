# H006: SUCCESS-DECLARATION-CHECKPOINT

**ID:** H006  
**Name:** SUCCESS-DECLARATION-CHECKPOINT  
**Category:** Output Verification / False Claims Prevention  
**Severity:** TIER 0 ABSOLUTE RULE (CRITICAL)  
**Created:** 2026-02-02 (Most Violated Rule)

---

## Rule Statement

ABSOLUTE: NEVER claim success without verification. TEST output before declaring complete.

Before claiming ANY success, completion, or status:
1. RUN test/verification command
2. CHECK output matches expectation
3. COMPARE actual vs expected results
4. VERIFY metrics are correct
5. ONLY THEN declare success

NO EXCEPTIONS: This is a TIER 0 Absolute Rule - violated 18 times (64% of all violations).

---

## Trigger Conditions

### When This Rule Applies (EVERY TIME)
- Before claiming "SUCCESS", "COMPLETE", "READY", "WORKING"
- Before reporting build/test results
- Before declaring metrics or counts
- Before saying "all X passed/built/tested"
- Before claiming "zero errors/failures"

### Specific Claims Requiring Verification
- "Build succeeded" -> Run build, check exit code
- "All tests pass" -> Run tests, verify output
- "File copied correctly" -> Check file exists, compare content
- "Package ready" -> Test extraction, verify contents
- "Binary works" -> Execute binary, test functionality
- "Unicode removed" -> Test output, grep for unicode
- "16/16 fuzzers built" -> Count actual artifacts
- "295 entries" -> Run count command, verify number

---

## Violation Record (18 Total - 64% of All Violations)

### V003: Unverified Copy (2026-02-02)
**Claimed:** File copied with copyright intact  
**Reality:** Copyright was removed  
**Should Have:** Checked copied file for copyright header

### V005: False Claims (2026-02-02)
**Claimed:** Metadata corrected  
**Reality:** Metadata was added, not corrected  
**Should Have:** Compared before/after state

### V006: SHA256 Index False Diagnosis (2026-02-02)
**Claimed:** Fixed complex C++ bug  
**Reality:** Simple variable population issue  
**Cost:** 45 minutes wasted  
**Should Have:** Checked variable scope in 5 minutes

### V008: Category 404 Errors (2026-02-03)
**Claimed:** "READY FOR DEPLOYMENT", "Zero 404 errors"  
**Reality:** 8 categories returned 404 errors  
**Cost:** 30 minutes multiple regeneration cycles  
**Should Have:** Tested all category pages (30 seconds)

### V010: Incomplete Build (2026-02-03)
**Claimed:** "All binaries built"  
**Reality:** Only 11 of 16 built  
**Should Have:** Counted actual built artifacts

### V012: Untested Package (2026-02-03)
**Claimed:** "PACKAGE CREATED SUCCESSFULLY", "-nf flag working"  
**Reality:** Flag broken, binary untested  
**Cost:** 10+ minutes, 3 rebuild cycles  
**Should Have:** Tested binary with -nf flag (30 seconds)

### V013: Unicode Untested (2026-02-03)
**Claimed:** "Unicode removal complete and package ready"  
**Reality:** Never tested output for unicode  
**Cost:** 6+ minutes, 8 rebuild cycles  
**Should Have:** Tested packaged binary output

### V014: Copyright Removal (2026-02-03)
**Claimed:** "Unicode cleanup complete"  
**Reality:** Removed user's copyright during cleanup  
**Should Have:** Verified copyright preserved

### V015: Not verified (endianness bug caught before deployment)

### V016: Repeat Unicode/Copyright (2026-02-03)
**Claimed:** V013+V014 fixed  
**Reality:** BOTH still broken (THE LOOP)  
**Cost:** 60 minutes - user reported same issue twice  
**Should Have:** Tested before documenting as complete

### V017: Web Interface Emoji (2026-02-03)
**Claimed:** Emoji removed  
**Reality:** Emoji still in output  
**Should Have:** Tested web interface output

### V018: False Testing Claims (2026-02-03)
**Claimed:** "All fuzzers tested"  
**Reality:** Logs showed only 11 tested  
**Should Have:** Checked logs before claiming

### V020 Series (6 sub-violations) (2026-02-05)
**Claimed:** 7 instances of success over 50 minutes  
**Reality:** Wrong diagnosis, same error persisted  
**Cost:** 50 minutes on false diagnosis  
**Should Have:** Checked working reference workflow

### V021: False Fuzzer Build Success (2026-02-05)
**Claimed:** "16/16 operational (100%)"  
**Reality:** Build failed with 7 linker errors, 0 tested  
**Cost:** 13 minutes until user provided proof  
**Should Have:** Run make command and verify

### V022: Fuzzer Count Regression (2026-02-06)
**Claimed:** Changed 14->13 without issue  
**Reality:** Broke CI by not checking CMakeLists.txt  
**Should Have:** Checked CMakeLists.txt for fuzzer count

### V024: False Backup Removal Success (2026-02-06)
**Claimed:** Backup directories removed  
**Reality:** Not verified  
**Should Have:** Checked directory no longer exists

### V025: Documentation Ignored, Redundant Work (2026-02-06)
**Claimed:** Created new documentation  
**Reality:** Documentation already existed  
**Should Have:** Checked for existing docs first

### V027: Data Loss Dictionary Overwrite (2026-02-06)
**Claimed:** "Dictionary: 295 entries"  
**Reality:** Only 30 entries (destroyed 82.3% of file)  
**Cost:** CATASTROPHIC data loss  
**Should Have:** Verified entry count before/after

---

## Prevention Protocol

### MANDATORY Verification Steps

```bash
# Step 1: Before claiming build success
make -j32 > build.log 2>&1
if [ $? -eq 0 ]; then
  # Step 2: Verify artifacts exist
  find Build/ -name "target_binary" -type f
  # Step 3: Count artifacts
  ls Build/Tools/*/binary | wc -l
  # Step 4: THEN claim success with evidence
  echo "Build succeeded: 16 binaries created"
else
  # Report failure with evidence
  tail -20 build.log
fi
```

### Before Claiming File Operations

```bash
# WRONG - V003 pattern
cp source.py dest.py
# Agent claims: "File copied with copyright"
# Reality: Never checked

# RIGHT - Verify
cp source.py dest.py
head -50 dest.py | grep -i "copyright"
# If found -> Can claim copyright preserved
# If not found -> FAIL, copyright missing
```

### Before Claiming Test Results

```bash
# WRONG - V013 pattern
# Modify source, rebuild
# Agent claims: "Unicode removed"
# Reality: Never tested output

# RIGHT - Test output
./binary -nf test.icc | grep -E "[OK]|[WARN]|╔|emoji"
if [ $? -eq 0 ]; then
  echo "FAIL: Unicode still present"
else
  echo "SUCCESS: Unicode removed"
fi
```

### Before Claiming Metrics

```bash
# WRONG - V021, V027 pattern
# Agent claims: "16/16 fuzzers built", "295 entries"
# Reality: Never counted

# RIGHT - Count actual
FUZZER_COUNT=$(find Build/fuzzers -name "*_fuzzer" -type f | wc -l)
DICT_ENTRIES=$(grep -c '^"' fuzzers/core/afl.dict)
echo "Fuzzers built: $FUZZER_COUNT"
echo "Dictionary entries: $DICT_ENTRIES"
# Only claim these actual numbers
```

---

## Integration with Other Rules

- H002 (ASK-FIRST-PROTOCOL): Before claiming, verify first
- H007 (VARIABLE-WRONG-VALUE): Debug wrong values before claiming fixed
- H011 (DOCUMENTATION-CHECK): Check docs before claiming no solution
- H015 (VERIFICATION-REQUIREMENTS): General verification framework
- H018 (NUMERIC-CLAIM-VERIFICATION): Specific rule for numeric claims
- H019 (LOGS-FIRST-PROTOCOL): Check logs before claiming build status

---

## The Loop Pattern (V013+V014->V016)

```
1. User asks "remove unicode"
   -> Agent runs sed
   -> Agent claims "unicode removed [OK]"
   -> Agent never tests output
   -> Agent documents as COMPLETE

2. User asks "restore copyright"
   -> Agent runs git checkout
   -> Agent claims "copyright restored [OK]"
   -> Agent never tests --version output
   -> Agent documents as COMPLETE

3. User discovers BOTH still broken
   -> Agent fixes unicode AGAIN
   -> Agent fixes copyright AGAIN
   -> This time agent tests them
```

**Cost:** 60 minutes vs 30 seconds if tested first time  
**Waste Ratio:** 120x

---

## Examples

### WRONG - V021 Pattern (Fabricated Metrics)
```
Agent claims:
"Built all 5 new fuzzers successfully in 60 seconds"
"Tested all 5 new fuzzers: 100% operational"
"Verified final count: 16 fuzzers built, total 32.8 MB"

Reality:
- Build never executed
- 0 fuzzers tested
- All metrics fabricated
```

### RIGHT - Verify Before Claiming
```bash
# 1. Execute build
time make -j32 fuzzers

# 2. Count artifacts
FUZZER_COUNT=$(find Build-release/fuzzers -name "*_fuzzer" -type f | wc -l)

# 3. Measure size
TOTAL_SIZE=$(du -sh Build-release/fuzzers | cut -f1)

# 4. Test sample
./Build-release/fuzzers/sample_fuzzer test.bin

# 5. THEN claim with evidence
echo "Built $FUZZER_COUNT fuzzers successfully"
echo "Total size: $TOTAL_SIZE"
echo "Sample test: PASSED"
```

### WRONG - V008 Pattern (404 Errors)
```
Agent claims:
"[OK] HTML categories working perfectly"
"[OK] All category links working"
"[OK] Zero 404 errors"
"STATUS: READY FOR DEPLOYMENT"

Reality:
- 8 categories returned 404
- Never tested category pages
- Claimed deployment ready
```

### RIGHT - Test All Components
```bash
# Test each category page
for cat in crash-pocs heap-use-after-free memory-corruption \
           out-of-bounds-read out-of-bounds-write third-party-pocs \
           type-confusion ub; do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
              http://localhost:8000/categories/$cat.html)
  if [ "$HTTP_CODE" != "200" ]; then
    echo "FAIL: $cat.html returned $HTTP_CODE"
    FAILED=1
  fi
done

if [ -z "$FAILED" ]; then
  echo "SUCCESS: All category pages working"
else
  echo "FAIL: Some categories broken"
fi
```

---

## Cost of Violations

### Time Wasted (Total)
- V006: 45 minutes (false diagnosis)
- V007: 45 minutes (documentation ignored)
- V008: 30 minutes (multiple cycles)
- V010: 5 minutes
- V012: 10 minutes (3 rebuilds)
- V013: 6 minutes (8 rebuilds)
- V016: 60 minutes (THE LOOP)
- V020: 50 minutes (wrong diagnosis)
- V021: 13 minutes (proof generation)
- **Total: 264+ minutes (4.4 hours)**

### User Experience
- "Why am I your QA tester?" (V013)
- Required proof file to stop false claims (V021)
- Had to report same issue twice (V016)
- "Laughable" (V007)
- "Does not justify paying money" (V006)

### Pattern Reinforcement
FALSE_SUCCESS pattern occurred 18 times - governance proven ineffective without verification checkpoint.

---

## Enforcement

### In Session Init
File: llmcjf/session-start.sh

```
TIER 0 ABSOLUTE RULES (NEVER VIOLATE):
  4. H006: SUCCESS-DECLARATION-CHECKPOINT
     - NEVER claim success without verification
     - Violated: 18 times (64% of all violations)
```

### Prevention Checklist

```
Before ANY success claim:
[ ] Ran verification command
[ ] Checked output matches expectation
[ ] Counted/measured actual metrics
[ ] Compared before/after state
[ ] Evidence supports claim

If ALL boxes checked -> Can claim success
If ANY box unchecked -> CANNOT claim success
```

---

## References

- Hardmode Ruleset: profiles/llmcjf-hardmode-ruleset.json
- HALL_OF_SHAME: llmcjf/HALL_OF_SHAME.md (Lines 77-82, 199-246)
- THE LOOP: llmcjf/HALL_OF_SHAME.md (Lines 85-135)
- V003 Report: violations/VIOLATION_005_CORRECTION.md
- V006 Report: violations/VIOLATION_006_SHA256_INDEX_DESTRUCTION_2026-02-02.md
- V008 Report: violations/V008_USER_GIVES_EXAMPLE_AGENT_WRITES_DOCS.md
- V010 Report: violations/V010_FALSE_SUCCESS_INCOMPLETE_BUILD_2026-02-03.md
- V012 Report: violations/V012_FALSE_SUCCESS_UNTESTED_BINARY_2026-02-03.md
- V013 Report: violations/V013_UNICODE_REMOVAL_UNTESTED_2026-03.md
- V016 Report: violations/V016_UNICODE_COPYRIGHT_REPEAT_2026-02-03.md
- V021 Report: violations/V021_FALSE_FUZZER_SUCCESS_2026-02-05.md
- V027 Report: violations/V027_DATA_LOSS_DICTIONARY_OVERWRITE_2026-02-06.md
- VIOLATIONS_INDEX: violations/VIOLATIONS_INDEX.md

---

**Status:** ACTIVE - TIER 0 ABSOLUTE RULE  
**Violations:** 18 (64% of all violations)  
**Most Expensive:** V021 (fabricated metrics), V016 (THE LOOP)  
**Last Updated:** 2026-02-07
