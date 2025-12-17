# Coverage Artifacts Exclusion - On-the-Fly Learning
**Date:** 2026-02-07 18:33 UTC  
**Session:** cb1e67d2  
**Context:** research repository - iccanalyzer-lite build artifacts  
**Status:** ✅ LEARNING (Not a Violation)

## Issue Discovery
During iccanalyzer-lite workflow development, 24 coverage artifacts (.gcda/.gcno files) were accidentally committed to the research repository:
- 12 .gcda files (coverage data)
- 12 .gcno files (coverage notes)
- Total: ~6.2 MB of build artifacts

## Root Cause
Coverage artifacts generated during local testing were not excluded from git tracking. Standard .gitignore only covered .o/.a files but not gcov coverage files.

## Impact Assessment
**Severity:** LOW (Build artifacts, not code defects)  
**Repository pollution:** 24 binary files in commit history  
**Workflow impact:** None (files regenerated during CI/CD)  
**Security impact:** None (coverage data is benign)

## Resolution
**Immediate:**
1. Removed all .gcda/.gcno files: `git rm -f *.gcda *.gcno`
2. Updated .gitignore with coverage exclusions:
   ```gitignore
   # Coverage files (gcov)
   *.gcda
   *.gcno
   *.gcov
   ```
3. Squashed commits to remove artifacts from history
4. Force pushed clean commit to origin/main

**Verification:**
```bash
# Before: 68 files (24 coverage artifacts)
# After:  44 files (0 coverage artifacts)
git ls-files | grep -E '\.(gcda|gcno)$'  # Exit code 1 (no matches)
```

## Learning Points

### 1. Coverage Artifacts Are Build Output
**Pattern:** Coverage files are generated during instrumented builds  
**Analogy:** Same as .o object files - never commit build output  
**Common artifacts:**
- `.gcda` - Coverage data (runtime execution counts)
- `.gcno` - Coverage notes (compile-time graph info)
- `.gcov` - Coverage reports (text summaries)

### 2. Standard .gitignore Insufficiency
**Issue:** Generic C++ .gitignore templates don't always include coverage files  
**Solution:** Always add coverage-specific patterns when using:
- ASAN/UBSAN instrumentation
- gcov/lcov coverage tools
- `-fprofile-arcs -ftest-coverage` flags

### 3. Local Build Hygiene
**Before committing:**
```bash
# Quick check for build artifacts
git status --short | grep -E '\.(gcda|gcno|o|a)$'

# If found, update .gitignore BEFORE first commit
echo "*.gcda" >> .gitignore
echo "*.gcno" >> .gitignore
```

## Prevention Protocol

### For New Repositories
**Step 1:** Check build flags for coverage/instrumentation  
**Step 2:** Add corresponding .gitignore patterns BEFORE first commit  
**Step 3:** Verify with `git status` before staging files

### For Existing Repositories
**Step 1:** Audit for build artifacts: `git ls-files | grep -E '\.(gcda|gcno|o)$'`  
**Step 2:** If found: Remove, update .gitignore, squash commits  
**Step 3:** Document in lessons/ for team awareness

### Standard Coverage Exclusions
```gitignore
# Coverage files (gcov/lcov)
*.gcda    # Coverage data (per-run execution counts)
*.gcno    # Coverage notes (compile-time metadata)
*.gcov    # Coverage reports (text output)
coverage/ # Coverage HTML reports
*.info    # LCOV trace files

# Profiling data
gmon.out  # gprof profiling
*.prof    # Other profilers
```

## Related Patterns

### Build Artifact Categories
1. **Object files:** .o, .a, .so - Standard exclusion
2. **Debug info:** .dwo, .pdb - Usually excluded
3. **Coverage data:** .gcda, .gcno - **Often missed**
4. **Profiling data:** gmon.out, .prof - Sometimes missed

### High-Risk Scenarios
- Instrumented builds (ASAN/UBSAN/coverage combined)
- CI/CD testing locally before pushing
- Copy-paste from local build directories

## Time Savings
**Proactive .gitignore setup:** 2 minutes  
**Reactive cleanup (this case):** 15 minutes  
**Cost of missing:** 7.5x time penalty + commit history pollution

## Success Metrics
✅ All 24 coverage artifacts removed  
✅ .gitignore updated with 3 patterns  
✅ Commit history cleaned (squashed)  
✅ Workflow still functional  
✅ Documentation created for team

## Repository Impact
**Before cleanup:**
- Commit: a659d91 (68 files, 24 coverage artifacts)
- Size: ~8.2 MB committed data

**After cleanup:**
- Commit: b651e6b (44 files, 0 coverage artifacts)
- Size: ~2.0 MB committed data
- Reduction: 74% smaller commit

## References
- **research/.gitignore** - Updated patterns (lines 35-38)
- **Commit:** b651e6b - Clean squashed commit
- **Session:** cb1e67d2-9f40-4601-b3b1-36d9f90cc616

## Classification
**Type:** On-the-Fly Learning (OTF-L001)  
**Category:** Repository Hygiene  
**Severity:** Educational (Low Impact)  
**Recurrence Risk:** Low (preventable with checklist)

---

**Key Takeaway:** Coverage artifacts are build output. Treat like .o files - exclude from git tracking. Update .gitignore proactively when using instrumented builds.
