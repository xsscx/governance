# Violation V010: Branch Confusion & Repeated Failed Pattern

**Date:** 2026-02-06  
**Session:** a02aa121-9948-4d32-9be6-90c0abe36abb  
**Severity:** HIGH  
**Category:** Documentation Ignored, Assume→Act→Fail Loop  
**User Time Wasted:** ~25 minutes  
**Cost:** Multiple workflow runs, context switching

## Summary

Agent attempted 10+ iterations of CFL (ClusterFuzzLite) build fixes without:
1. Checking which branch contains working code
2. Consulting proven working fuzzer-smoke-test pattern FIRST
3. Verifying repository structure differences

User explicitly stated: "you have a known good and working Fuzzer Smoke test to learn from" but agent continued modifying CFL build.sh without comparing to working example.

## Timeline

1. **16:47** - User reports CFL failure, mentions "known good and working Fuzzer Smoke test"
2. **16:47-16:58** - Agent makes 3+ attempts modifying build.sh (sed patterns, cmake flags)
3. **16:58** - User identifies critical issue: "Which branch are you working on?"
4. **17:02** - Discovered: user-controllable-input **cfl branch** has fuzzers, was working on **master**
5. **17:03** - Applied working pattern from fuzzer-smoke-test, immediately succeeded

## Root Cause

**Pattern:** Assume→Act→Fail→Repeat (did not break loop with verification step)

### What Agent Should Have Done (H011 Protocol)

**Before first attempt:**
```bash
# 1. CHECK FOR WORKING EXAMPLES (30 seconds)
cd /home/xss/copilot/iccLibFuzzer/action-testing
gh run list --workflow=ci-fuzzer-smoke-test.yml --limit 1
# Found: Run 21757518094 - SUCCESS [OK]

# 2. COMPARE WORKING TO FAILING
diff .github/workflows/ci-fuzzer-smoke-test.yml .clusterfuzzlite/build.sh
# Would immediately show: -DENABLE_TOOLS=OFF vs sed patterns

# 3. CHECK BRANCH STRUCTURE
cd user-controllable-input
git branch -a
ls -la .clusterfuzzlite/  # Check if exists on current branch
git checkout cfl && ls -la .clusterfuzzlite/  # Verify working branch
```

**Time Cost:** 2 minutes to verify vs 25 minutes of failed attempts

### What Agent Actually Did

```
Attempt 1: Modify sed pattern (failed)
Attempt 2: Change if(FALSE) wrapper (failed)  
Attempt 3: Printf-based sed (failed)
Attempt 4: CMake cache deletion (failed)
Attempt 5: Copy entire workflow (failed)
... (10+ iterations)
```

**Never consulted working example until user intervention at 16:58**

## LLMCJF Rules Violated

### H011: DOCUMENTATION-CHECK-MANDATORY
- **Rule:** MUST check for .md/.txt files and working examples BEFORE debugging
- **Violation:** Did not compare to fuzzer-smoke-test.yml (working) until forced
- **Cost:** 25 minutes vs 30 seconds

### H007: VARIABLE-IS-WRONG-VALUE  
- **Rule:** 5-minute systematic debugging protocol
- **Violation:** Made assumptions about build pattern without verifying working state
- **Pattern:** Assumed sed would work, didn't check if -DENABLE_TOOLS=OFF was actual solution

### H009: SIMPLICITY-FIRST-DEBUGGING
- **Rule:** Occam's Razor - simple explanations before complex
- **Violation:** Complex sed patterns, printf workarounds when simple `-DENABLE_TOOLS=OFF` existed

### BRANCH-AWARENESS (New Rule Candidate)
- **Rule:** When working across multiple repos/branches, verify branch structure FIRST
- **Violation:** Assumed master branch had working code when cfl branch was actual working branch
- **Impact:** 10+ failed attempts on wrong branch

## Evidence

**Working Pattern (fuzzer-smoke-test.yml):**
```yaml
- name: Configure
  run: |
    cmake Cmake/ \
      -DENABLE_FUZZING=ON \
      -DENABLE_TOOLS=OFF \  # ← Simple solution
      -Wno-dev
```

**Failed Pattern (build.sh attempts):**
```bash
# Attempt 1-3: sed patterns
sed -i '1162,1170s/^/# DISABLED_FOR_CFL: /' CMakeLists.txt

# Attempt 4-6: if(FALSE) wrappers
printf '%s\n' '1162i\' '  if(FALSE) # wxWidgets disabled' | sed -i -f -

# Should have been:
cmake Cmake/ -DENABLE_TOOLS=OFF  # One line, already proven
```

## Prevention Protocol

### Pre-Action Checklist for "X Doesn't Work" Issues

1. **Identify Working Example** (60 seconds)
   - Search for similar working functionality
   - Check recent successful workflow runs
   - Look for test suites that exercise the feature

2. **Compare Configurations** (60 seconds)
   - Working vs Failing
   - Document differences
   - Identify simplest fix

3. **Verify Branch/Repo Structure** (30 seconds)
   - Which branch has the code?
   - Are there multiple repos with similar names?
   - Check branch divergence

4. **Apply Simplest Fix First** (Occam's Razor)
   - Don't engineer complex solutions
   - Copy working pattern exactly
   - Verify before iterating

**Total Time:** 3 minutes to verify → saves 25+ minutes of failed attempts

## Corrective Actions

1. **[OK] COMPLETED:** Applied working fuzzer-smoke-test pattern to CFL build
2. **[OK] COMPLETED:** Deployed to correct cfl branch
3. **[WARN] PENDING:** Add BRANCH-AWARENESS to LLMCJF hardmode ruleset
4. **[WARN] PENDING:** Update PRE_ACTION_CHECKLIST.md with branch verification

## Related Violations

- **V007:** 45 minutes debugging when answer was in documentation (2026-02-02)
- **V009:** Dictionary format violations (inline comments) - 3rd repeat
- **Pattern:** Agent does not consult working examples before debugging

## Cost Analysis

- **Agent attempts:** 10+ iterations
- **Workflow runs triggered:** 6-8 runs
- **User time wasted:** ~25 minutes  
- **Resolution time after identifying mistake:** 2 minutes
- **Efficiency ratio:** 0.08 (2min solution / 25min wasted)

## Lesson Learned

> **GOLDEN RULE:** When user says "you have a known good and working X to learn from" → 
> STOP CURRENT APPROACH, compare to working example FIRST, apply identical pattern.

**User was correct:** Fuzzer-smoke-test had the answer all along.  
**Agent was stubborn:** Continued modifying CFL build without comparison.

---

**Signed:** GitHub Copilot CLI  
**Witnessed:** LLMCJF Live Surveillance  
**User Complaint Risk:** MEDIUM (resolved before escalation)
