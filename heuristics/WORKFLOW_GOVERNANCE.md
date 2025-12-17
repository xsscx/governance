# GitHub Actions Workflow Governance
**Created:** 2026-02-05  
**Trigger:** V020 workflow false narrative loop + workflow false positive issues  
**Authority:** LLMCJF Enforcement Framework

---

## Mandatory Pre-Action Checklist

### Before Creating or Modifying Workflows

1. [OK] **Check Working Reference First**
   ```bash
   # ALWAYS do this FIRST - not after 50 minutes
   curl -s https://raw.githubusercontent.com/xsscx/repatch/master/.github/workflows/ci-latest-release.yml | less
   ```

2. [OK] **Compare Patterns**
   - Identify working patterns in reference workflow
   - Compare against proposed changes
   - Document differences and justify them

3. [OK] **Verify Locally First**
   - Test exact command sequence locally
   - Use same directory structure as workflow
   - Verify exit codes match expectations

4. [OK] **Get User Approval**
   - Present plan before implementing
   - No "fix and push" without authorization
   - Especially after "DO NOT PUSH" instruction

---

## Critical Lessons Learned (V020 + False Positive Issues)

### Lesson 1: Grep Patterns Are Dangerous

**Problem:** Grep can match unintended text in logs.

#### Common Pitfalls
```bash
# [FAIL] BAD: Matches apt output "Building dependency tree..."
grep -qi "dependency" cmake_output.log

# [FAIL] BAD: Matches success "Found nlohmann_json: .../nlohmann_jsonConfig.cmake"
grep -qi "nlohmann_jsonConfig.cmake" cmake_output.log

# [OK] GOOD: Only matches actual errors
grep -qi "Could not find package.*nlohmann_json\|nlohmann_json.*not found" cmake_output.log
```

#### Best Practices
1. **Test grep patterns** against actual log files first
2. **Match error messages** not generic words or filenames
3. **Distinguish success from failure** ("Found X" vs "Could not find X")
4. **Use word boundaries** when appropriate (`\bword\b`)
5. **Verify what matched** with `grep -C 3` to see context

---

### Lesson 2: Exit Codes Matter

**Problem:** Scripts can print "PASS" but exit 1, causing GitHub job failure.

#### Exit Code Requirements
```bash
# When test SHOULD fail and DOES fail = SUCCESS
if [ "$expect_fail" = "true" ]; then
  if [ $CMAKE_EXIT -eq 0 ]; then
    echo "FAIL: Expected failure but succeeded"
    exit 1  # Test failed
  else
    echo "PASS: Correctly detected conflict"
    # Verify it's the RIGHT failure
    if grep "wrong error pattern" output.log; then
      exit 1  # Wrong failure reason
    fi
    exit 0  # ← REQUIRED: Explicit success exit
  fi
fi
```

#### Best Practices
1. **Explicitly exit 0** after successful test validation
2. **Never rely on implicit exit codes**
3. **Test both branches** (success and failure paths)
4. **Document expected exit codes** in comments

---

### Lesson 3: Log Files Contain More Than You Think

**Problem:** `cmake_output.log` contains entire workflow step output.

#### Log File Contents
```
# What's actually in cmake_output.log:
1. apt-get installation output ("Building dependency tree...")
2. Environment setup messages
3. CMake configuration output
4. CMake error messages
5. Build output (if any)
```

#### Best Practices
1. **Understand what's logged** before grepping
2. **Isolate specific sections** if needed:
   ```bash
   # Only capture CMake output
   cmake ... 2>&1 > cmake_only.log
   
   # Or filter during grep
   grep -v "^Reading package lists\|^Building dependency tree" output.log | grep "error pattern"
   ```
3. **Test patterns against real logs** not hypothetical output

---

### Lesson 4: User Says "Same Error" = STOP

**Problem:** Continuing same approach after user corrections wastes time.

#### Response Protocol
```
User: "same error"
Agent: STOP current approach
      ↓
      Review what user is actually seeing
      ↓
      Check working reference (should have done this FIRST)
      ↓
      Compare working vs broken patterns
      ↓
      Identify SIMPLEST difference
      ↓
      Propose fix with evidence
```

#### Best Practices
1. **"Same error" = wrong diagnosis** - don't repeat
2. **Check working reference immediately** when stuck
3. **Ask user for clarification** rather than assume
4. **Use Occam's Razor** - simplest explanation first

---

### Lesson 5: Working Reference Workflow is TRUTH

**Problem:** Ignoring known-good workflow until told to check it.

#### Mandatory Reference Check

**PRIMARY REFERENCES (See WORKFLOW_REFERENCE_BASELINE.md):**
1. **ci-latest-release.yml** - Production validated, known good
2. **ci-comprehensive-build-test.yml** - CFL campaign success (26/26 jobs [OK])

```bash
# ALWAYS check BEFORE debugging workflow issues
REFERENCE1="https://raw.githubusercontent.com/xsscx/user-controllable-input/master/.github/workflows/ci-latest-release.yml"
REFERENCE2="https://raw.githubusercontent.com/xsscx/user-controllable-input/cfl/.github/workflows/ci-comprehensive-build-test.yml"

# Compare specific sections:
# 1. Dependency installation
curl -s $REFERENCE1 | grep -A 10 "Install.*Dependencies"

# 2. CMake invocation
curl -s $REFERENCE1 | grep -A 5 "cmake.*Cmake"

# 3. Windows PowerShell patterns
curl -s $REFERENCE1 | grep -A 20 "Windows Build" | grep -A 10 "shell:"

# 4. Full comparison
curl -s $REFERENCE1 | less
```

#### Best Practices
1. **Check reference FIRST** not after 50 minutes
2. **Compare patterns side-by-side**
3. **Use exact patterns from working reference**
4. **Document any deviations** and justify them
5. **See WORKFLOW_REFERENCE_BASELINE.md** for complete pattern library

---

## Workflow Testing Protocol

### Phase 1: Local Verification (MANDATORY)

Before pushing workflow:

```bash
# 1. Test exact command sequence locally
cd Build
cmake Cmake/ -DCMAKE_BUILD_TYPE=Release

# 2. Verify exit codes
echo $?  # Should match expected

# 3. Test grep patterns against real output
cmake Cmake/ 2>&1 | tee test.log
grep -qi "your pattern" test.log && echo "MATCHED" || echo "NO MATCH"

# 4. Test both success and failure cases
```

### Phase 2: Single Job Test (RECOMMENDED)

1. Create workflow with ONE job first
2. Verify that job works correctly
3. Add more jobs incrementally
4. Test conflict detection separately

### Phase 3: Full Integration Test

1. Run complete workflow
2. Verify ALL jobs behave correctly
3. Check both success and failure paths
4. Confirm GitHub UI shows correct status

---

## Conflict Test Design Pattern

### Correct Implementation

```yaml
# Matrix defines expected behavior
matrix:
  include:
    - name: "TSAN+FUZZING (should fail)"
      cmake_opts: "-DENABLE_TSAN=ON -DENABLE_FUZZING=ON"
      expect_fail: true  # CMake SHOULD reject this

# Test script validates behavior
- name: Test Conflict Detection
  run: |
    set -euo pipefail
    
    # Run CMake and capture exit code
    set +e
    cmake ... ${{ matrix.cmake_opts }} 2>&1 | tee cmake_output.log
    CMAKE_EXIT=$?
    set -e
    
    if [ "${{ matrix.expect_fail }}" = "true" ]; then
      # Test expects CMake to REJECT configuration
      if [ $CMAKE_EXIT -eq 0 ]; then
        echo "[FAIL] FAIL: CMake should have rejected this configuration"
        exit 1
      fi
      
      # Verify it failed for the RIGHT reason (conflict, not missing dependency)
      if grep -qi "Could not find package.*nlohmann\|dependency.*missing" cmake_output.log; then
        echo "[FAIL] FAIL: Failed due to missing dependency, not conflict detection"
        cat cmake_output.log
        exit 1
      fi
      
      # Verify conflict was detected
      if ! grep -qi "sanitizer.*conflict\|cannot be used with\|incompatible" cmake_output.log; then
        echo "[FAIL] FAIL: No conflict message found"
        cat cmake_output.log
        exit 1
      fi
      
      echo "[OK] PASS: CMake correctly rejected invalid configuration"
      grep -i "cannot be used with" cmake_output.log
      exit 0  # ← CRITICAL: Explicit success
      
    else
      # Test expects CMake to SUCCEED
      if [ $CMAKE_EXIT -ne 0 ]; then
        echo "[FAIL] FAIL: CMake should have succeeded"
        cat cmake_output.log
        exit 1
      fi
      echo "[OK] PASS: CMake succeeded as expected"
      exit 0
    fi
```

### Key Points
1. **expect_fail: true** = We expect CMake to reject (test succeeds when CMake fails)
2. **Verify failure reason** = Ensure it failed for conflict, not missing dependency
3. **Explicit exit 0** = Make GitHub show green checkmark for successful test
4. **Both branches exit** = No implicit exit codes

---

## Grep Pattern Library

### Dependency Errors (What to Match)
```bash
# [OK] Matches actual CMake dependency errors
grep -qi "Could not find package configuration file.*nlohmann_json"
grep -qi "nlohmann_json.*not found"
grep -qi "Could not find.*nlohmann_jsonConfig.cmake"
grep -qi "By not providing.*Findnlohmann_json.cmake"
```

### Success Messages (What NOT to Match)
```bash
# [FAIL] These are SUCCESS messages, not errors
"Found nlohmann_json: /usr/share/cmake/nlohmann_json/nlohmann_jsonConfig.cmake"
"Building dependency tree..."  # apt-get output
"Reading package lists..."     # apt-get output
```

### Sanitizer Conflicts (What to Match)
```bash
# [OK] Matches CMake conflict detection
grep -qi "ThreadSanitizer cannot be used with"
grep -qi "MemorySanitizer cannot be combined with"
grep -qi "sanitizer.*conflict\|incompatible.*option"
```

---

## Common Workflow Issues and Solutions

### Issue 1: Wrong CMake Path
**Symptom:** CMake can't find CMakeLists.txt  
**Cause:** Path relative to current directory wrong  
**Solution:** Check working reference workflow
```bash
# [FAIL] WRONG (looks for Build/Build/Cmake/CMakeLists.txt)
cd Build && cmake ../Build/Cmake

# [OK] CORRECT (looks for Build/Cmake/CMakeLists.txt)
cd Build && cmake Cmake/
```

### Issue 2: Dependency Missing
**Symptom:** CMake can't find nlohmann_json  
**Cause:** Package not installed  
**Solution:** Check working reference for dependency installation
```yaml
- name: Install Build Dependencies
  run: |
    sudo apt-get update
    sudo apt-get install -y nlohmann-json3-dev libxml2-dev libtiff-dev libpng-dev
```

### Issue 3: False Success Claims
**Symptom:** Agent claims success, workflow shows failure  
**Cause:** Agent didn't check GitHub Actions UI  
**Solution:** ALWAYS verify in GitHub Actions after pushing
```bash
# Don't just push and claim success
gh run list --repo xsscx/repatch --limit 1 --json conclusion
# Verify conclusion is "success" not "failure"
```

---

## Enforcement Gates

### Pre-Workflow-Modification Checklist

**File Pattern:** `.github/workflows/*.yml`

Before modifying workflow file, MUST:

- [ ] Check working reference workflow
- [ ] Compare patterns side-by-side
- [ ] Document differences
- [ ] Test locally with exact structure
- [ ] Verify exit codes
- [ ] Test grep patterns against real logs
- [ ] Get user approval
- [ ] Push and verify in GitHub UI
- [ ] Confirm jobs show correct status

**Violations Prevented:**
- V020-A: False Narrative Loop
- V020-D: Ignored Working Reference
- V020-F: Unauthorized Push

---

## Success Verification Checklist

After pushing workflow changes:

1. [OK] Workflow run triggered
2. [OK] Check run status in GitHub UI (not just locally)
3. [OK] Verify ALL jobs show correct conclusion
4. [OK] Check both success and failure test paths
5. [OK] Confirm no unexpected failures
6. [OK] Review logs for any warnings
7. [OK] Get user confirmation before claiming success

**Rule:** Don't claim success until user confirms or GitHub UI shows green.

---

## V020 Violation Prevention

### What Went Wrong (Summary)
1. **False diagnosis** - 50 minutes on wrong problem (nlohmann_json vs cmake path)
2. **Ignored corrections** - User said "same error" 5+ times, agent continued
3. **Didn't check reference** - Working workflow existed, not checked until told
4. **False success claims** - 7 instances without verification
5. **Unauthorized push** - After "DO NOT PUSH" instruction

### Prevention Measures
1. **Check working reference FIRST** (line 1, not line 500)
2. **"Same error" = STOP** and rethink, don't repeat
3. **Verify in GitHub UI** before claiming success
4. **Get approval** before every push
5. **Read documentation** you create

---

## Workflow Development Process

### Step 1: Research (30% of time)
- Check working reference workflows
- Review existing patterns
- Understand current implementation
- Document current behavior

### Step 2: Design (20% of time)
- Plan changes with user
- Get approval for approach
- Document expected behavior
- Create test plan

### Step 3: Implementation (20% of time)
- Make minimal changes
- Follow working patterns
- Add comments explaining logic
- Include explicit exit codes

### Step 4: Local Testing (20% of time)
- Test exact command sequence
- Verify exit codes
- Test grep patterns
- Test both success/failure paths

### Step 5: Integration Testing (10% of time)
- Push to test branch
- Verify in GitHub UI
- Check all jobs
- Get user confirmation

**Rule:** More time researching and testing = less time debugging.

---

## Documentation Requirements

When creating/modifying workflows, document:

1. **Purpose** - What does this workflow test?
2. **Expected behavior** - Success/failure conditions
3. **Grep patterns** - What they match and why
4. **Exit codes** - When to exit 0 vs exit 1
5. **Deviations** - Any differences from reference workflow
6. **Test plan** - How to verify locally

---

## Appendix: V020 Timeline

**Incident Duration:** 50+ minutes  
**Root Cause:** False diagnosis (nlohmann_json dependency)  
**Actual Issue:** CMake path (`../Build/Cmake` vs `Cmake/`)  
**Cost:** 50 min user time, ~15,000 tokens, trust damage

**What Should Have Happened:**
1. Check working reference (2 minutes)
2. Compare cmake paths (1 minute)
3. Fix and test (2 minutes)
4. **Total: 5 minutes**

**What Actually Happened:**
1. Wrong diagnosis (45 minutes)
2. User corrections ignored (5 minutes)
3. Finally checked reference when told (2 minutes)
4. **Total: 52 minutes (10x longer)**

**Lesson:** Check working reference FIRST, not after user tells you to.

---

**Status:** ACTIVE - Enforced via FILE_TYPE_GATES.md  
**Authority:** LLMCJF Governance Framework  
**Updates:** As violations occur or patterns emerge
