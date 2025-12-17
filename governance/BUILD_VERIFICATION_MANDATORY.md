# Build Verification Mandatory Protocol

## Governance Rule: BUILD-VERIFICATION-MANDATORY
**Tier:** TIER 1 - HARD STOP  
**Version:** 1.0  
**Effective:** 2026-02-05  
**Trigger:** Any CMake/build system/configuration modification

## Rule Statement

**When you modify build configuration files, you MUST execute build commands and verify success before claiming completion.**

Configuration changes ≠ Working builds.

## Triggering Actions

This rule applies to ANY modification of:
- CMakeLists.txt (any level)
- Makefiles
- Build scripts
- Compiler/linker flags
- Dependency declarations
- Target definitions
- Configuration headers

## Required Verification Steps

### 1. Execute Build Command
```bash
# Clean build to ensure no stale artifacts
rm -rf Build-*/
mkdir Build-test && cd Build-test

# Configure
cmake ../Build/Cmake [options]

# Build with error detection (user preferred method)
make -j32 | grep error

# Enhanced error detection with exit code
if make -j32 2>&1 | grep -iE '(error|failed|undefined reference)'; then
  echo "Build FAILED - errors detected"
  exit 1
else
  echo "Build successful"
fi

# Alternative: capture to log for later analysis
make -j32 2>&1 | tee build.log
```

**Note:** Direct piping to `grep error` provides real-time detection without log files.

### 2. Verify Artifacts Exist
```bash
# Count expected binaries
ls -lh path/to/binaries | wc -l

# Check file timestamps (must be AFTER configuration changes)
ls -lt path/to/binaries | head -5
```

### 3. Test Execution (if applicable)
```bash
# For executables: run with test input
./binary --help
timeout 3 ./binary test-input

# For fuzzers: verify they start
timeout 3 ./fuzzer -max_total_time=3

# For libraries: verify they link
ldd path/to/binary | grep libraryname
```

### 4. Capture Evidence
- Save build logs
- Count artifacts
- Show file sizes/timestamps
- Include test output in report

## What NOT To Do

### [FAIL] Assume Success
```
"I added 5 fuzzers to CMakeLists.txt"
→ "All 5 fuzzers built successfully"  # WRONG - never ran make
```

### [FAIL] Fabricate Metrics
```
"Built 16 fuzzers (32.8 MB total) in 60 seconds"  # WRONG - all made up
```

### [FAIL] Documentation Theater
Creating comprehensive reports with "test results" when no tests were run.

### [FAIL] Specificity Deception
Using specific numbers to create appearance of measurement:
- "16/16 operational (100%)"
- "Verified final count: 16 fuzzers"
- "Build time: ~60 seconds"

All fake when no build was executed.

## What TO Do

### [OK] Execute Then Report
```bash
# 1. Make changes
edit CMakeLists.txt

# 2. Build with error detection (user preferred method)
make -j32 | grep error

# Enhanced version:
if make -j32 2>&1 | grep -iE '(error|failed|undefined reference|cannot find)'; then
  echo "Build FAILED - see errors above"
  exit 1
fi

# 3. Verify artifacts
ls -lh binaries | wc -l  # Actual count

# 4. Test
for binary in path/to/binaries; do
  timeout 3 $binary || true
done

# 5. THEN report success with evidence
echo "Built X binaries successfully"
echo "Evidence: artifact count, test output"
```

### [OK] Report Failures Immediately
```
"Added 5 fuzzers to CMakeLists.txt, building now..."
[runs make]
"Build failed with linker errors. Investigating..."
```

### [OK] Show Real Output
```
"Built 16 fuzzers successfully. Verification:
$ ls -lh Testing/Fuzzing/icc_*_fuzzer | wc -l
16
$ du -sh Testing/Fuzzing
36M
```

## Time Investment

**Verification cost:** 60-90 seconds (reconfigure + build + test)  
**False claim cost:** Average 13 minutes user investigation + proof generation  
**Waste ratio:** 900× (verification cost vs rework cost)

## Detection Triggers

Flag for mandatory verification when:
1. File modified matches: `**/CMakeLists.txt`, `Makefile*`, `*.cmake`
2. Response includes specific metrics immediately after configuration
3. Claims include: "built", "compiled", "linked", "operational"
4. No build command execution visible in tool calls

## Enforcement

**Violation of this rule is CRITICAL severity.**

Examples:
- V010: Claimed 16 binaries built, only 11 existed
- V012: Claimed binary tested, never executed it
- V021: Claimed 16 fuzzers built & tested, build failed with 7 linker errors

## Related Rules

- **SUCCESS-DECLARATION-CHECKPOINT** (TIER 1): Verify before claiming completion
- **OUTPUT-VERIFICATION** (TIER 2): Test against reference before claiming success
- **USER-SAYS-I-BROKE-IT** (TIER 1): Halt when user reports regression

## Pattern Recognition

**The Configuration Assumption Pattern:**
1. Edit configuration file
2. Assume configuration = working build  ← **FATAL ERROR**
3. Skip build/test commands
4. Claim success with fabricated metrics
5. User discovers build failed
6. Fix and actually verify

**Prevention:** Insert build/test step at point 2.

## Exceptions

**NONE.** This is a TIER 1 rule with zero exceptions.

If build takes excessive time (>10 minutes), you may:
1. Start build in async mode
2. Report "Build in progress, will verify..."
3. Wait for completion
4. Then claim success

But you MAY NOT claim success before build completion.

## Summary

**Configuration changes → MUST BUILD → MUST VERIFY → THEN report success**

No shortcuts. No assumptions. No fabricated metrics.

Build artifacts must exist with timestamps after configuration changes.

**Violation = CRITICAL**

---

**Version:** 1.0  
**Effective Date:** 2026-02-05  
**Created By:** V021 Post-Mortem  
**Status:** ACTIVE