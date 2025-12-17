# Build Error Detection Guide

**User Preferred Method:** `make -j32 | grep error`

## Why This Method

**Direct real-time detection:**
- No intermediate log files
- Immediate feedback
- Clean pipeline
- Exits on first error with grep

## Basic Usage

```bash
make -j32 | grep error
```

**Result:**
- If errors exist: Shows error lines and exits with failure code
- If no errors: No output, exit code 0

## Enhanced Detection

### Multiple Error Patterns
```bash
make -j32 2>&1 | grep -iE '(error|failed|undefined reference|cannot find)'
```

**Catches:**
- `error:` - Compiler errors
- `failed` - Linker/build failures
- `undefined reference` - Missing symbols
- `cannot find` - Missing files/libraries

### With Exit Code Handling
```bash
if make -j32 2>&1 | grep -iE '(error|failed|undefined reference)'; then
  echo "Build FAILED"
  exit 1
else
  echo "Build successful"
fi
```

### Comprehensive Pattern (Maximum Coverage)
```bash
if make -j32 2>&1 | grep -iE '(error|fail|undefined|cannot find|no such|missing)'; then
  echo "Build FAILED - see errors above"
  exit 1
else
  echo "Build successful - all targets built"
  ls -lh path/to/binaries | wc -l
fi
```

## Common Build Error Patterns

| Pattern | Meaning | Example |
|---------|---------|---------|
| `error:` | Compiler error | `file.cpp:123: error: 'var' was not declared` |
| `failed` | Build step failed | `make[2]: *** [target] Error 1` |
| `undefined reference` | Linker error | `undefined reference to 'function'` |
| `cannot find` | Missing dependency | `cannot find -llibname` |
| `No such file` | Missing source | `No such file or directory` |
| `multiple definition` | Duplicate symbols | `multiple definition of 'main'` |
| `No rule to make` | Missing target | `No rule to make target 'file'` |

## Test Success Detection

### Verify Artifacts After Build
```bash
# Build
make -j32 2>&1 | grep error && { echo "Build failed"; exit 1; }

# Count artifacts
BUILT=$(ls -1 Testing/Fuzzing/icc_*_fuzzer 2>/dev/null | wc -l)
EXPECTED=16

if [ "$BUILT" -eq "$EXPECTED" ]; then
  echo "Success: $BUILT/$EXPECTED fuzzers built"
else
  echo "FAILED: Only $BUILT/$EXPECTED fuzzers built"
  exit 1
fi
```

### Check Make Exit Code
```bash
if make -j32 2>&1; then
  echo "Make succeeded"
else
  echo "Make failed with exit code $?"
  exit 1
fi
```

### Combined Approach (Most Reliable)
```bash
# Capture both stdout and stderr
BUILD_OUTPUT=$(make -j32 2>&1)
BUILD_EXIT=$?

# Check exit code first
if [ $BUILD_EXIT -ne 0 ]; then
  echo "Build failed with exit code $BUILD_EXIT"
  echo "$BUILD_OUTPUT" | grep -iE 'error|failed'
  exit 1
fi

# Check for error keywords even if exit code is 0 (catches warnings promoted to errors)
if echo "$BUILD_OUTPUT" | grep -iE 'error'; then
  echo "Build completed but errors detected:"
  echo "$BUILD_OUTPUT" | grep -iE 'error'
  exit 1
fi

# Verify artifacts
EXPECTED=16
BUILT=$(ls -1 Testing/Fuzzing/icc_*_fuzzer 2>/dev/null | wc -l)

if [ "$BUILT" -ne "$EXPECTED" ]; then
  echo "Artifact mismatch: $BUILT built, $EXPECTED expected"
  exit 1
fi

echo "Build successful: $BUILT/$EXPECTED artifacts built"
```

## Integration with Governance

### BUILD-VERIFICATION-MANDATORY Compliance

```bash
# 1. Edit configuration
vim CMakeLists.txt

# 2. Build with error detection (MANDATORY)
if make -j32 2>&1 | grep error; then
  echo "FAILED - cannot claim success"
  exit 1
fi

# 3. Verify artifacts (MANDATORY)
ls -lh binaries | wc -l

# 4. Test binaries (MANDATORY)
for f in binaries/*; do timeout 3 $f; done

# 5. THEN report success
echo "Built X binaries, all tested successfully"
```

## Flawed Methods to Avoid

### [FAIL] Post-build log grep (my original method)
```bash
make -j32 2>&1 | tee build.log
grep -i error build.log  # TOO LATE - build already finished
```
**Problem:** Requires waiting for entire build, then checking log

### [FAIL] No error checking
```bash
make -j32
# Assume success
```
**Problem:** V021 violation - configuration assumption pattern

### [FAIL] Only checking exit code
```bash
make -j32 && echo "success"
```
**Problem:** Some errors don't fail make (warnings, partial builds)

## Best Practice (User Method)

```bash
# Simple and direct
make -j32 | grep error

# With conditional handling
make -j32 2>&1 | grep error && exit 1 || echo "Build OK"

# Enhanced for comprehensive detection
make -j32 2>&1 | grep -iE '(error|failed|undefined)' && exit 1
```

**Advantages:**
- Real-time detection
- No log files needed
- Immediate feedback
- Exit on first error
- Clean pipeline

---

**Created:** 2026-02-05  
**Based on:** User feedback on V021 violation  
**Status:** ACTIVE - Recommended method for all builds
