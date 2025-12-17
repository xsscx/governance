# Build Verification Technique - Artifact Counting
**Date:** 2026-02-06  
**Category:** Best Practice  
**Related Rules:** H015 (CLEANUP-VERIFICATION-MANDATORY), H013 (PACKAGE-CONTENTS-VERIFICATION)

---

## Command

```bash
find . -type f \
  \( -perm -111 -o -name "*.a" -o -name "*.so" -o -name "*.dylib" \) \
  -mmin -1440 \
  ! -path "*/.git/*" \
  ! -path "*/CMakeFiles/*" \
  ! -name "*.sh" \
  -print
```

**Quick count:**
```bash
find . -type f \( -perm -111 -o -name "*.a" -o -name "*.so" -o -name "*.dylib" \) -mmin -1440 ! -path "*/.git/*" ! -path "*/CMakeFiles/*" ! -name "*.sh" -print | wc -l
```

---

## Purpose

**Quantitative verification** of build success by counting actual artifacts instead of trusting exit codes or log output.

**Prevents:** False success violations (V003, V008, V024, etc.)

**Use cases:**
1. Verify fuzzer builds (expected: 15 binaries)
2. Verify library builds (expected: 2 static libraries)
3. Verify tool builds (expected: 20+ executables)
4. Package validation before distribution

---

## Command Breakdown

| Component | Purpose |
|-----------|---------|
| `find . -type f` | Search for files in current directory |
| `-perm -111` | Executable files (any execute bit set) |
| `-name "*.a"` | Static libraries |
| `-name "*.so"` | Shared libraries (Linux) |
| `-name "*.dylib"` | Dynamic libraries (macOS) |
| `-mmin -1440` | Modified in last 1440 minutes (24 hours) |
| `! -path "*/.git/*"` | Exclude git metadata |
| `! -path "*/CMakeFiles/*"` | Exclude CMake build metadata |
| `! -name "*.sh"` | Exclude shell scripts |
| `-print` | Output matching files |
| `\| wc -l` | Count total artifacts |

---

## Expected Counts

### Fuzzer Builds
```bash
Expected: 15 binaries + 2 libraries = 17 artifacts
- IccProfLib2-static.a
- IccXML2-static.a
- icc_profile_fuzzer
- icc_calculator_fuzzer
- icc_v5dspobs_fuzzer
- icc_multitag_fuzzer
- icc_roundtrip_fuzzer
- icc_dump_fuzzer
- icc_io_fuzzer
- icc_link_fuzzer
- icc_spectral_fuzzer
- icc_apply_fuzzer
- icc_applyprofiles_fuzzer
- icc_specsep_fuzzer
- icc_tiffdump_fuzzer
- icc_fromxml_fuzzer
- icc_toxml_fuzzer
```

### Full Project Build
```bash
Expected: 40+ artifacts
- 2 static libraries (IccProfLib2, IccXML2)
- 2 shared libraries (IccProfLib2.so, IccXML2.so)
- 20+ command-line tools
- 15 fuzzers (if ENABLE_FUZZING=ON)
```

### Tool-Only Build
```bash
Expected: 20-25 artifacts
- All Tools/CmdLine/* executables
- IccAnalyzer variants (if built)
```

---

## Integration with H015

### Before (False Success Pattern)
```bash
make -j32 && echo "[OK] Build complete"
# No verification - assumes success
```

### After (H015 Compliant)
```bash
make -j32

# Verify with artifact count
EXPECTED=17
ACTUAL=$(find . -type f \( -perm -111 -o -name "*.a" \) -mmin -10 ! -path "*/.git/*" ! -path "*/CMakeFiles/*" ! -name "*.sh" -print | wc -l)

if [ $ACTUAL -ge $EXPECTED ]; then
  echo "[OK] Build verified: $ACTUAL artifacts (expected: $EXPECTED)"
else
  echo "[FAIL] Build failed: $ACTUAL artifacts (expected: $EXPECTED)"
  exit 1
fi
```

---

## Breakdown by Artifact Type

```bash
# Count by type
LIBS=$(find . -name "*.a" -mmin -1440 ! -path "*/.git/*" ! -path "*/CMakeFiles/*" -print | wc -l)
EXECS=$(find . -type f -perm -111 -mmin -1440 ! -path "*/.git/*" ! -path "*/CMakeFiles/*" ! -name "*.sh" ! -name "*.a" ! -name "*.so" -print | wc -l)

echo "Static libraries: $LIBS"
echo "Executables: $EXECS"
echo "Total: $((LIBS + EXECS))"
```

---

## Example: CFL Build Verification

```bash
# After running .clusterfuzzlite/build.sh
cd /tmp/cfl-test-out

# Expected: 15 fuzzer binaries
EXPECTED=15
ACTUAL=$(find . -type f -perm -111 ! -name "*.sh" -print | wc -l)

echo "Fuzzers built: $ACTUAL (expected: $EXPECTED)"

if [ $ACTUAL -eq $EXPECTED ]; then
  echo "[OK] All fuzzers built successfully"
  find . -type f -perm -111 ! -name "*.sh" -exec basename {} \; | sort
else
  echo "[WARN] Missing fuzzers: $((EXPECTED - ACTUAL))"
  # Show what was built
  find . -type f -perm -111 ! -name "*.sh" -exec basename {} \; | sort
fi
```

---

## Time Window Adjustments

| Duration | Minutes | Use Case |
|----------|---------|----------|
| **10 min** | `-mmin -10` | Quick test builds |
| **1 hour** | `-mmin -60` | Single fuzzer build |
| **6 hours** | `-mmin -360` | Full project build |
| **24 hours** | `-mmin -1440` | Daily CI/CD verification |
| **7 days** | `-mmin -10080` | Weekly releases |

---

## Violations Prevented

This technique prevents:
- **V003**: Unverified copy operations
- **V008**: False build success claims
- **V024**: Backup removal without verification
- **Future**: Any "build complete" claim without quantitative proof

**Pattern:** Action → COUNT → Compare → ONLY then claim success

---

## Integration Points

### CMake Builds
```bash
cmake --build . -j32
ARTIFACTS=$(find . -type f \( -perm -111 -o -name "*.a" \) -mmin -10 ! -path "*/.git/*" ! -path "*/CMakeFiles/*" ! -name "*.sh" -print | wc -l)
echo "Build artifacts: $ARTIFACTS"
```

### CI/CD Workflows
```yaml
- name: Build project
  run: cmake --build . -j32

- name: Verify artifacts
  run: |
    EXPECTED=17
    ACTUAL=$(find . -type f \( -perm -111 -o -name "*.a" \) -mmin -10 ! -path "*/.git/*" ! -path "*/CMakeFiles/*" ! -name "*.sh" -print | wc -l)
    echo "Artifacts: $ACTUAL (expected: $EXPECTED)"
    if [ $ACTUAL -lt $EXPECTED ]; then
      echo "Build verification failed"
      exit 1
    fi
```

### Package Creation
```bash
# Before creating distribution package
TOOLS=$(find Tools/ -type f -perm -111 ! -name "*.sh" -print | wc -l)
FUZZERS=$(find Testing/Fuzzing/ -type f -perm -111 -print | wc -l)

echo "Package contents:"
echo "  Tools: $TOOLS"
echo "  Fuzzers: $FUZZERS"
echo "  Total: $((TOOLS + FUZZERS))"

# Only package if counts match expectations
```

---

## Best Practices

1. **Always count after build claims**
   ```bash
   make && COUNT=$(find . -type f -perm -111 -mmin -10 ! -path "*/.git/*" -print | wc -l) && echo "Built: $COUNT"
   ```

2. **Show what was built**
   ```bash
   find . -type f -perm -111 -mmin -10 ! -path "*/.git/*" ! -name "*.sh" -exec basename {} \; | sort
   ```

3. **Compare expected vs actual**
   ```bash
   EXPECTED=15
   ACTUAL=$(...)
   [ $ACTUAL -eq $EXPECTED ] || echo "[WARN] Mismatch: $ACTUAL vs $EXPECTED"
   ```

4. **Document expected counts in build scripts**
   ```bash
   # Expected artifacts: 17 (2 libraries + 15 fuzzers)
   EXPECTED_ARTIFACTS=17
   ```

---

## Quick Reference

**Count all recent builds:**
```bash
find . -type f \( -perm -111 -o -name "*.a" \) -mmin -1440 ! -path "*/.git/*" ! -path "*/CMakeFiles/*" ! -name "*.sh" -print | wc -l
```

**List recent builds:**
```bash
find . -type f \( -perm -111 -o -name "*.a" \) -mmin -1440 ! -path "*/.git/*" ! -path "*/CMakeFiles/*" ! -name "*.sh" -exec ls -lh {} \;
```

**Group by type:**
```bash
echo "Libraries:"; find . -name "*.a" -mmin -1440 ! -path "*/CMakeFiles/*" -print
echo "Executables:"; find . -type f -perm -111 -mmin -1440 ! -path "*/.git/*" ! -name "*.sh" ! -name "*.a" -print
```

---

## Conclusion

**This technique provides quantitative verification** of build success, preventing false success violations.

**Cost:** 1-2 seconds per verification  
**Benefit:** Prevents 10-45 minute correction cycles  
**Waste ratio:** 300-1350× improvement  

**Mandate:** Use this technique for ALL build verification claims per H015.

---

**Documentation Date:** 2026-02-06  
**Status:** APPROVED - Integrate into all build workflows  
**Governance:** H015 compliance mandatory
