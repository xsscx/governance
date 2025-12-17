# H013: PACKAGE-VERIFICATION

## Rule Definition
**ID:** H013  
**Name:** PACKAGE-VERIFICATION  
**Category:** Testing / Verification  
**Severity:** CRITICAL  
**Trigger:** Creating distribution package for users (*.tar.gz, *.zip, installers)  
**Created:** 2026-02-03 (Response to V012)

---

## Rule Statement

**MANDATORY: Every distribution package MUST be tested from user perspective before claiming success.**

When creating packages for distribution to users or development teams:
1. Extract package to clean temporary directory
2. Test primary use case as user would
3. Test ALL new or changed functionality
4. Verify version strings, help text, documentation
5. **Only claim success if ALL tests pass**

**NO EXCEPTIONS:** "Package created" ≠ "Package works"

---

## Trigger Conditions

### When This Rule Applies
- Creating distribution tarball/zip
- Generating installer package
- Building release binary for users
- Packaging for deployment
- Creating "ready for distribution" deliverable

### When This Rule Does NOT Apply
- Development builds (not for distribution)
- Internal testing builds
- Work-in-progress artifacts
- Build verification (H010 applies instead)

---

## Mandatory Test Protocol

### Step 1: Extract Package
```bash
# Clean environment
mkdir /tmp/package-test-$$
cd /tmp/package-test-$$

# Extract
tar xzf /path/to/package.tar.gz
# OR
unzip /path/to/package.zip
```

### Step 2: Test Primary Use Case
```bash
# Run main command as user would
./package/bin/tool --help

# Test basic functionality
./package/bin/tool example-input
```

### Step 3: Test New/Changed Features
If package claims new feature (e.g., "-nf flag added"):
```bash
# MUST test that feature specifically
./package/bin/tool -nf test-file

# Expected: Feature works
# If error: FIX BEFORE claiming success
```

### Step 4: Verify Metadata
```bash
# Version strings
./package/bin/tool --version

# Help text accuracy
./package/bin/tool --help | grep "new-feature"

# Documentation matches code
cat package/docs/README.md
```

### Step 5: Cleanup
```bash
cd /
rm -rf /tmp/package-test-$$
```

---

## Test Examples

### Example: iccAnalyzer-lite Package (V012 Case)

#### What Agent Did (WRONG)
```bash
$ bash create_lite_package.sh
Package: iccanalyzer-lite-2.9.0-linux-x86_64.tar.gz
[OK] PACKAGE CREATED SUCCESSFULLY  # CLAIMED SUCCESS HERE
```

#### What Agent Should Have Done (CORRECT)
```bash
$ bash create_lite_package.sh
Package: iccanalyzer-lite-2.9.0-linux-x86_64.tar.gz

# BEFORE claiming success:
$ tar xzf iccanalyzer-lite-2.9.0-linux-x86_64.tar.gz
$ cd iccanalyzer-lite-2.9.0-linux-x86_64

# Test new feature (claimed: "-nf flag added")
$ ./bin/iccanalyzer-lite-run -nf ../Testing/Calc/srgbCalcTest.icc

# Expected: Full dump output
# Actual (V012): ERROR: Unknown option: -nf

# RESULT: DO NOT CLAIM SUCCESS
# FIX: Rebuild with native compiler, test again, then claim success
```

#### Time Cost
```yaml
H013_testing: 30 seconds
V012_debugging_after_user_found: 10+ minutes
savings: 9.5 minutes + user trust
```

---

## Success Criteria

### Package Tests PASS When
- [x] Extraction succeeds without errors
- [x] Primary use case executes
- [x] All claimed features work
- [x] Help/version output correct
- [x] Documentation matches functionality
- [x] No missing dependencies
- [x] File permissions correct

### Package Tests FAIL When
- [ ] Extraction errors
- [ ] Primary command not found
- [ ] Claimed feature returns error
- [ ] Help text inaccurate
- [ ] Missing libraries
- [ ] Broken wrapper scripts

**If ANY test fails: FIX BEFORE claiming success**

---

## Integration with Other Rules

### H003: SUCCESS-DECLARATION-CHECKPOINT
H013 is specialized application of H003 for packages:
- H003: General "verify before claiming"
- H013: Specific "extract and test packages"

### H010: BUILD-VERIFICATION
Related but different scope:
- H010: "Did build produce expected artifacts?"
- H013: "Do artifacts work from user perspective?"

### H011: DOCUMENTATION-CHECK-MANDATORY
Complementary:
- H011: Check docs before debugging
- H013: Verify docs match package contents

---

## Violation Examples

### V012: Untested Package (2026-02-03)
**Claimed:** "iccAnalyzer-lite package with -nf flag"  
**Testing:** None  
**User discovers:** `-nf` flag returns "ERROR: Unknown option"  
**Cost:** 10+ minutes, 4 rebuilds, trust erosion

**H013 would have caught:**
```bash
$ ./bin/iccanalyzer-lite-run -nf test.icc
ERROR: Unknown option: -nf
# STOP: FIX BEFORE CLAIMING SUCCESS
```

### V010: Untested Build (2026-02-03)
**Claimed:** "All fuzzers built"  
**Testing:** None  
**User discovers:** 5 fuzzers missing  
**Cost:** Wasted time attempting to run non-existent binaries

**H013 would have caught:**
```bash
$ ls fuzzers-local/combined/ | wc -l
12  # Expected: 17
# STOP: 5 MISSING
```

---

## Prevention Checklist

Before claiming "PACKAGE CREATED SUCCESSFULLY":

```markdown
## Package Verification Checklist

### Extraction
- [ ] Package extracts without errors
- [ ] Directory structure correct
- [ ] All expected files present

### Functionality Testing
- [ ] Primary command executes
- [ ] Help text displays correctly
- [ ] Version string accurate
- [ ] New features work (test each specifically)
- [ ] Changed features work (regression test)

### Dependencies
- [ ] No missing library errors
- [ ] Wrapper scripts set paths correctly
- [ ] Bundled libraries load properly

### Documentation
- [ ] README matches package contents
- [ ] Examples run successfully
- [ ] Version numbers consistent

### User Perspective
- [ ] Extract as user would
- [ ] Run as user would
- [ ] Works without special setup (beyond README instructions)

## Success Criteria
ALL boxes checked = Claim success  
ANY box unchecked = Fix before claiming
```

---

## Time Cost Analysis

### Testing Cost (H013 Compliance)
```yaml
extraction: 5 seconds
primary_test: 10 seconds
feature_tests: 10-15 seconds
verification: 5 seconds
total: 30 seconds
```

### Violation Cost (H013 Non-Compliance)
```yaml
user_discovers_bug: 1 minute
agent_debugging: 5-10 minutes
rebuild_cycles: 2-5 minutes
repackage: 1-2 minutes
retest: 30 seconds
user_frustration: Significant
total: 10-20 minutes + trust erosion
```

**ROI:** 30 seconds prevents 10-20 minutes waste  
**Multiplier:** 20-40x return on testing investment

---

## Enforcement

### Mandatory Compliance
H013 is MANDATORY for:
- Distribution packages
- Release candidates
- User-facing deliverables
- "Ready for team" packages

### Verification Method
```bash
# Before claiming success, show test results:
echo "PACKAGE VERIFICATION:"
echo "1. Extraction: OK"
echo "2. Primary test: ./bin/tool test.file -> OK"
echo "3. New feature: ./bin/tool -new-flag -> OK"
echo "4. Help text: grep 'new-flag' -> FOUND"
echo "5. Package test: PASSED"
echo ""
echo "All tests passed. Package ready for distribution."
```

### Violation Consequences
- Record violation (V0XX)
- Update VIOLATIONS_INDEX.md
- Increment CRITICAL counter
- Add to HALL_OF_SHAME.md
- Pattern tracking (FALSE_SUCCESS)

---

## Related Documentation

**Violations:**
- V012: Untested package (iccAnalyzer-lite -nf flag)
- V010: Untested build (missing fuzzers)
- V008: Untested HTML bundle (404 errors)
- V003: Unverified file copy

**Rules:**
- H003: SUCCESS-DECLARATION-CHECKPOINT (parent rule)
- H010: BUILD-VERIFICATION (related)
- H011: DOCUMENTATION-CHECK-MANDATORY (complementary)

**Governance:**
- llmcjf/profiles/llmcjf-hardmode-ruleset.json
- llmcjf/violations/VIOLATIONS_INDEX.md
- llmcjf/HALL_OF_SHAME.md

---

## Summary

**Rule:** Test packages before claiming success  
**Why:** Users shouldn't discover bugs agent should have found  
**How:** Extract, test primary + new features, verify docs  
**Cost:** 30 seconds  
**Benefit:** Prevent 10-20 minutes waste + trust preservation  
**Compliance:** MANDATORY for distribution packages  

**One-liner:** "If you claim it works, prove you tested it."

---

**Rule created:** 2026-02-03T16:24 UTC  
**Triggered by:** V012 (Untested -nf flag in iccAnalyzer-lite package)  
**Status:** ACTIVE - MANDATORY enforcement
