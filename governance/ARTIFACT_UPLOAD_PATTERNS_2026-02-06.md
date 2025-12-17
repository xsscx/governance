# GitHub Actions Artifact Upload Patterns
**Created:** 2026-02-06  
**Status:** ACTIVE - Mandatory Reference  
**Authority:** Session e99391ed Lesson Learned  

---

## Purpose

Document proven artifact upload patterns to prevent path guessing failures.

**Problem:** Agent guesses at artifact paths, uploads fail with 0 files.  
**Solution:** Use proven patterns from reference workflow `ci-latest-release.yml`.

---

## The Golden Rule

**NEVER guess at artifact paths. Use the entire Build directory.**

---

## Proven Pattern (ci-latest-release.yml)

### Working Configuration

```yaml
- name: Upload Linux Artifacts
  uses: actions/upload-artifact@330a01c490aca151604b8cf639adc76d48f6c5d4
  with:
    name: iccdev-linux-${{ matrix.compiler }}
    path: |
      Build
      LICENSE.md
      README.md            
      docs/**
```

**Why This Works:**
1. Uploads entire `Build/` directory (no path guessing)
2. Includes documentation in every artifact
3. Preserves directory structure
4. No dependency on CMake internals
5. Compression handles size automatically

---

## Common Mistakes (Avoid These)

### [FAIL] Mistake 1: Cherry-Picking Individual Executables

```yaml
# DON'T DO THIS - Path guessing fails
path: |
  Build/Tools/IccApplyNamedCmm/IccApplyNamedCmm
  Build/Tools/IccDumpProfile/IccDumpProfile
  Build/IccProfLib/libIccProfLib2*.so*
  Build/IccProfLib/libIccProfLib2*.a
```

**Problems:**
- CMake builds tools in nested subdirectories (`Tools/Tool/Tool`)
- Extension wildcards fail (`*.so*` doesn't match versioned libs)
- Build structure varies by platform/configuration
- Result: 0 files uploaded despite success

### [FAIL] Mistake 2: Overly Specific Wildcards

```yaml
# DON'T DO THIS - Extension filtering fails
path: |
  Build/IccProfLib/libIccProfLib2*.so*
  Build/IccProfLib/libIccProfLib2*.a
  Build/IccXML/libIccXML2*.so*
  Build/IccXML/libIccXML2*.a
```

**Problems:**
- `*.so*` expects extension, but CMake creates `libIcc.so.2.3.1.4`
- Wildcard may not match actual library naming
- Platform variations (`.dylib` on macOS, `.dll` on Windows)

### [FAIL] Mistake 3: Assuming Build Structure

```yaml
# DON'T DO THIS - Assumes specific structure
path: Build/Tools/IccDumpProfile/IccDumpProfile
```

**Problems:**
- Tool is actually at `Build/Tools/IccDumpProfile/IccDumpProfile/IccDumpProfile`
- CMake creates nested directories
- Structure varies by generator (Ninja vs Make)

---

## Correct Pattern (From Reference)

### Standard Builds

```yaml
- name: Upload Build Artifacts (on success)
  if: success()
  uses: actions/upload-artifact@b4b15b8c7c6ac21ea08fcf65892d2ee8f75cf882  # v4.4.3
  with:
    name: build-${{ matrix.os }}-${{ matrix.compiler }}-${{ matrix.build_type }}
    path: |
      Build
      LICENSE.md
      README.md
      docs/**
    if-no-files-found: warn
    retention-days: 14
    compression-level: 9
```

**Benefits:**
- [OK] Captures all build outputs automatically
- [OK] Includes documentation
- [OK] Works regardless of CMake structure
- [OK] Platform-independent
- [OK] Future-proof (new tools added automatically)

### Fuzzer Builds

```yaml
- name: Upload Fuzzer Executables (on success)
  if: success()
  uses: actions/upload-artifact@b4b15b8c7c6ac21ea08fcf65892d2ee8f75cf882  # v4.4.3
  with:
    name: fuzzer-executables-debug-instrumentation
    path: |
      Build-fuzzing/Testing/Fuzzing/*_fuzzer
      LICENSE.md
      README.md
    retention-days: 14
    compression-level: 9
```

**Notes:**
- Fuzzer path is known and consistent (`Testing/Fuzzing/*_fuzzer`)
- Still include documentation
- Wildcard is safe (predictable naming: `icc_*_fuzzer`)

### Sanitizer Builds

```yaml
- name: Upload Sanitizer Build Artifacts
  if: always()
  uses: actions/upload-artifact@b4b15b8c7c6ac21ea08fcf65892d2ee8f75cf882  # v4.4.3
  with:
    name: sanitizer-${{ matrix.sanitizer }}-${{ matrix.build_type }}
    path: |
      Build
      LICENSE.md
      README.md
    if-no-files-found: warn
    retention-days: 7
    compression-level: 9
```

**Notes:**
- Use `if: always()` for sanitizer builds (want artifacts even if tests fail)
- Shorter retention (7 days) for debug builds
- Still upload entire `Build/` directory

---

## Windows Pattern (Special Case)

From `ci-latest-release.yml`:

```yaml
- name: Upload build artifacts
  uses: actions/upload-artifact@330a01c490aca151604b8cf639adc76d48f6c5d4
  with:
    name: iccdev-windows-msvc
    path: |
      Build/Cmake/build/**/*.lib
      Build/Cmake/build/**/*.a
      Build/Cmake/build/**/*.dll
      Build/Cmake/build/**/*.exe
      Build/Cmake/build/**/*.pdb
      Build/Cmake/Testing/**/*
      LICENSE.md
      README.md            
      docs/**
    if-no-files-found: warn
```

**Why More Specific on Windows:**
- Windows build creates many intermediate files
- PDB files are large (debug symbols)
- Testing outputs are self-contained
- Wildcards work because directory structure is predictable

**Key Point:** Still includes documentation files at root

---

## Verification Protocol

### After Configuring Artifact Upload

**DON'T assume it works. Verify:**

```bash
# 1. Trigger workflow
gh workflow run ci-comprehensive-build-test.yml --ref cfl

# 2. Wait for completion
gh run list --workflow=ci-comprehensive-build-test.yml --limit 1

# 3. Check artifact count (CRITICAL)
gh run view <run-id> | grep -i "artifacts"

# 4. Download and inspect first artifact
gh run download <run-id> --name <artifact-name>
ls -lah <artifact-name>/

# 5. Verify contents match expectations
find <artifact-name> -name "IccDumpProfile" -o -name "*.so" | head -5
```

**Expected Results:**
- Artifact count > 0 (not 0 artifacts)
- Each artifact has reasonable size (>1MB for builds)
- Executables present in artifact
- LICENSE.md and README.md included

**Red Flags:**
- "0 artifacts uploaded" (paths wrong)
- Artifact size < 100KB (incomplete)
- Missing documentation files
- Empty directories in artifact

---

## Violation History

### Session e99391ed (2026-02-06)

**Violation:** V022 + Artifact Upload Failure

**Issue:** 
- Comprehensive build workflow configured artifact uploads
- All 26 jobs passed
- **0 artifacts created**
- Paths didn't match actual build structure

**Root Cause:**
- Agent guessed paths: `Build/Tools/IccDumpProfile/IccDumpProfile`
- Actual path: `Build/Tools/IccDumpProfile/IccDumpProfile/IccDumpProfile`
- Didn't check reference workflow `ci-latest-release.yml`

**Fix:**
- User reminded: "refer to known good sample"
- Agent checked `ci-latest-release.yml`
- Found proven pattern: `path: Build` (entire directory)
- Applied pattern to all artifact uploads
- Simplified from 8 lines to 4 lines per upload
- Eliminated guessing

**Time Cost:**
- Initial configuration: 10 min
- Debugging: 15 min
- User reminder: 1 min
- Correct fix: 5 min
- **Total: 31 minutes (20 min wasted)**

**Lesson:**
- **Check reference workflow FIRST** (not after debugging)
- **Use entire Build directory** (not individual files)
- **Include documentation** (LICENSE.md, README.md)
- **Verify uploads work** (download and inspect)

---

## Mandatory Pre-Action Checklist

### Before Configuring Artifact Uploads

**MUST answer YES to all:**
- [ ] Checked `ci-latest-release.yml` reference workflow
- [ ] Reviewed proven pattern section (lines 130-139, 222-231, 418-432)
- [ ] Identified differences from proven pattern
- [ ] Justified any deviations
- [ ] Planned verification after push
- [ ] User approved configuration

**Time Investment:** 5 minutes  
**Time Saved:** 15-30 minutes of debugging  
**ROI:** 3-6×

---

## Quick Reference Card

```
═══════════════════════════════════════════════════════
  GitHub Actions Artifact Upload Pattern
───────────────────────────────────────────────────────
  [OK] DO: Upload entire Build directory
  [OK] DO: Include LICENSE.md and README.md
  [OK] DO: Use proven pattern from ci-latest-release.yml
  [OK] DO: Verify artifacts created (not 0)
───────────────────────────────────────────────────────
  [FAIL] DON'T: Guess at executable paths
  [FAIL] DON'T: Use complex wildcards (*.so*)
  [FAIL] DON'T: Assume CMake structure
  [FAIL] DON'T: Skip verification
───────────────────────────────────────────────────────
  Reference: .github/workflows/ci-latest-release.yml
  Lines: 130-139 (Linux), 222-231 (macOS), 418-432 (Win)
═══════════════════════════════════════════════════════
```

---

## Platform-Specific Notes

### Linux/macOS
- Use: `path: Build` (entire directory)
- CMake creates: `Build/Tools/*/Tool/Tool` structure
- Libraries in: `Build/IccProfLib/` and `Build/IccXML/`

### Windows
- Use: `Build/Cmake/build/**/*.exe` (recursive glob works)
- CMake creates: Deep nesting with configuration folders
- Include: `.lib`, `.dll`, `.exe`, `.pdb`, `.a` files

### All Platforms
- **Always include:** `LICENSE.md`, `README.md`
- **Optional:** `docs/**` for complete documentation
- **Compression:** Level 9 for long-term storage
- **Retention:** 14 days standard, 7 days debug/sanitizer

---

## Success Metrics

### Before This Document
- Artifact uploads: Guessed paths
- Success rate: 0/1 (0% - no artifacts created)
- User time wasted: 20 minutes

### After Implementation
- Artifact uploads: Proven pattern
- Expected success rate: 100%
- User time saved: 15-30 min per workflow
- Build artifacts: Complete and verifiable

---

## Enforcement

### File Pattern: `.github/workflows/*.yml`

**Before adding artifact upload:**
1. [OK] Check this document
2. [OK] Check `ci-latest-release.yml` (lines 130-139)
3. [OK] Use proven pattern
4. [OK] Verify after push

**Violations Prevented:**
- Path guessing failures
- Missing documentation in artifacts
- 0 artifacts created
- Incomplete upload configuration

---

## Related Documents

- `.copilot-sessions/governance/WORKFLOW_REFERENCE_BASELINE.md` - Full workflow patterns
- `.copilot-sessions/governance/WORKFLOW_GOVERNANCE.md` - Comprehensive workflow guide
- `.copilot-sessions/governance/FILE_TYPE_GATES.md` - Gate 5 (workflows)

---

## Conclusion

**The solution is simple:** Use entire `Build/` directory, include documentation, verify uploads.

**The mistake is common:** Guessing paths, using complex wildcards, skipping verification.

**The cost is real:** 15-30 minutes wasted debugging upload failures.

**The prevention is mandatory:** Check reference workflow first, use proven pattern.

---

**Status:** ACTIVE  
**Reference Workflow:** ci-latest-release.yml  
**Mandatory:** Before any artifact upload configuration  
**Last Updated:** 2026-02-06  
**Next Review:** After next artifact upload implementation
