# Best Practices
## GitHub Copilot CLI Governance

**Version**: 1.0  
**Effective**: 2025-12-24  
**Purpose**: Engineering standards and code quality

**Table of Contents**:
- [Core Engineering Principles](#core-engineering-principles)
- [Code Modification Patterns](#code-modification-patterns)
- [Testing Requirements](#testing-requirements)
- [Documentation Standards](#documentation-standards)
- [Git Workflow](#git-workflow)
- [Build System Practices](#build-system-practices)
  - [Fuzzer Dictionary Format](#fuzzer-dictionary-format) [STAR] NEW
- [Performance Optimization](#performance-optimization)
- [Code Review Guidelines](#code-review-guidelines)
- [Continuous Improvement](#continuous-improvement)
- [Safe Directory Management](#safe-directory-management)
- [References](#references)

---

## Core Engineering Principles

### 1. Minimal Changes Philosophy

**Rule**: Make the smallest possible change to achieve the goal.

**Good Example**:
```diff
# Fix single path reference
- cd $SRC/ipatch/fuzzers
+ cd $SRC/iccLibFuzzer/fuzzers
```

**Bad Example**:
```diff
# Unnecessary rewrite of working code
- cd $SRC/ipatch/fuzzers
- make clean
- rm -f old_fuzzer
+ pushd $SRC/iccLibFuzzer/fuzzers >/dev/null
+ find . -name "*.o" -delete
+ rm -rf $(ls | grep -v keep)
+ popd >/dev/null
```

**Why**: Minimal changes reduce regression risk, are easier to review, and maintain code history.

---

### 2. Surgical Modifications

**Pattern**: Target specific lines, preserve context.

**Implementation**:
```bash
# Use edit tool for precise changes
old_str: "exact match with context"
new_str: "minimal modification"

# NOT full file replacements
```

**Metrics**:
- [OK] Good: 1-5 lines changed per fix
- [WARN]  Caution: 6-20 lines changed
- [FAIL] Review: 20+ lines changed

---

## Code Modification Patterns

### Pattern 1: Bug Fix

**Process**:
1. Identify exact location of bug
2. Understand root cause
3. Make minimal fix
4. Verify fix doesn't break other code
5. Add test if applicable

**Example**:
```cpp
// Bug: Integer overflow
// Bad fix: Rewrite entire function
// Good fix: Add bounds check

// Before
int result = steps * steps;

// After
if (steps > 1000) return false;  // Add bounds check
int result = steps * steps;
```

**Commit Message**:
```
Fix: Integer overflow in spectral range calculation

Issue: steps * steps can overflow for large values
Root cause: No bounds checking on user input
Solution: Add max limit of 1000 steps
Impact: Prevents UBSan errors on malformed profiles
```

### Pattern 2: Path Update

**Process**:
1. Identify all occurrences (grep)
2. Verify context for each
3. Update systematically
4. Verify no references remain

**Example**:
```bash
# Find all references
grep -r "old_path" .

# Update each file
edit file1: old_path → new_path
edit file2: old_path → new_path

# Verify none remain
grep -r "old_path" .  # Should be empty
```

### Pattern 3: Configuration Change

**Process**:
1. Understand current behavior
2. Identify exact parameter to change
3. Document old and new values
4. Justify the change

**Example**:
```yaml
# .clusterfuzzlite/build.sh
# Change: Increase memory limit for complex profiles

# Before
rss_limit_mb = 6144  # 6GB

# After
rss_limit_mb = 8192  # 8GB

# Rationale: Complex spectral profiles OOM at 6GB
# Testing: Validated with 15MB test profiles
```

---

## Testing Requirements

### Before Commit

**Mandatory Checks**:
1. [OK] Code compiles without errors
2. [OK] Existing tests pass
3. [OK] No new compiler warnings
4. [OK] Changes don't break existing functionality

**Commands**:
```bash
# Build check
cd Build && cmake Cmake && make -j32

# Warning check
make 2>&1 | grep -i warning

# Regression check
cd Testing && ./RunTests.sh
```

### For Fuzzing Changes

**Mandatory**:
1. [OK] Fuzzer builds successfully
2. [OK] Fuzzer runs without immediate crash
3. [OK] Corpus loads correctly
4. [OK] Sanitizers functional

**Commands**:
```bash
# Build fuzzers
.clusterfuzzlite/build.sh

# Quick test
./out/icc_profile_fuzzer corpus/ -max_total_time=10

# Verify sanitizer
ASAN_OPTIONS=detect_leaks=1 ./out/icc_profile_fuzzer ...
```

---

## Documentation Standards

### Commit Messages

**Format**:
```
<Type>: <Short summary (50 chars max)>

<Detailed description>
- What was changed
- Why it was changed
- How it was tested
- Impact/implications

<Optional references>
Fixes: #issue_number
Related: GH Actions run #12345
```

**Types**:
- `Fix:` - Bug fix
- `Feature:` - New functionality
- `Refactor:` - Code restructuring (no behavior change)
- `Docs:` - Documentation only
- `Test:` - Test additions or fixes
- `Build:` - Build system changes
- `CI:` - CI/CD changes
- `Perf:` - Performance improvement

**Example**:
```
Fix: ipatch references in .clusterfuzzlite/build.sh

Critical fix for CFL build failure in run 20490062142.

Changes:
- $SRC/ipatch → $SRC/iccLibFuzzer (20 occurrences)
- All fuzzer build paths updated
- All corpus paths updated

Testing:
- Repository-wide grep confirms no ipatch refs remain
- Ready for next CFL run

Impact: Resolves CFL build failures, enables fuzzing runs
Related: GH Actions run #20490062142
```

### Code Comments

**When to Comment**:
- Complex algorithms requiring explanation
- Non-obvious workarounds
- Security-critical sections
- Performance optimizations

**When NOT to Comment**:
- Obvious code (e.g., `i++; // increment i`)
- Restating what code does
- Outdated or incorrect information

**Example - Good**:
```cpp
// Spectral range calculation can overflow for large step values
// Limit to 1000 steps to prevent UBSan errors while maintaining
// support for all valid ICC spectral ranges (380-780nm typical)
if (steps > 1000) return false;
```

**Example - Bad**:
```cpp
// Check if steps is greater than 1000
if (steps > 1000) return false;  // Returns false
```

### Session Documentation

**Required Elements**:
1. [OK] Snapshot before major changes
2. [OK] Decision rationale documented
3. [OK] Session summary at end
4. [OK] Next-session guide updated

**Template**: See `SESSION_TEMPLATE.md`

---

## Git Workflow

### Branching (Current: Direct to Master)

**Current Practice**:
- Direct commits to master for bug fixes
- Immediate push after verification
- Session tracking provides audit trail

**Future Enhancement** (optional):
```bash
# Feature branches for major work
git checkout -b fix/issue-description
# Make changes
git commit -m "Fix: Description"
# Push and create PR
git push origin fix/issue-description
```

### Commit Hygiene

**Requirements**:
```bash
# 1. Stage only related changes
git add file1.cpp file2.h  # Not 'git add .'

# 2. Review before commit
git diff --cached

# 3. Clear, detailed message
git commit  # Opens editor for full message

# 4. Verify commit
git show HEAD
```

**Anti-Patterns**:
```bash
[FAIL] git add .  # Stages unrelated files
[FAIL] git commit -m "fix"  # Vague message
[FAIL] git commit -am "wip"  # Skip review
[FAIL] git push --force  # Loses history
```

---

## Build System Practices

### CMake Best Practices

**Configuration**:
```cmake
# Explicit compiler settings
set(CMAKE_C_COMPILER ${CC})
set(CMAKE_CXX_COMPILER ${CXX})

# Optimization flags
set(CMAKE_CXX_FLAGS "${CXXFLAGS} -frtti")
set(CMAKE_BUILD_TYPE RelWithDebInfo)

# Static linking for fuzzers
set(BUILD_SHARED_LIBS OFF)
```

**Parallel Builds**:
```bash
# Use all available cores (W5-2465X optimized)
cmake --build . -j32

# Or with make
make -j$(nproc)
```

### Build Script Patterns

**Requirements**:
1. [OK] Idempotent (can run multiple times safely)
2. [OK] Error handling (set -e, check returns)
3. [OK] Clean previous builds
4. [OK] Verify outputs exist

**Example**:
```bash
#!/bin/bash -eu  # Exit on error, undefined vars

# Clean previous build
rm -rf build/ || true
mkdir -p build/

# Build with error checking
cd build
cmake .. || { echo "CMake failed"; exit 1; }
make -j32 || { echo "Build failed"; exit 1; }

# Verify outputs
test -f libIccProfLib2-static.a || { echo "Library missing"; exit 1; }
echo "Build successful"
```

### Fuzzer Dictionary Format

**Critical**: libFuzzer and AFL dictionaries have different syntax despite both using `.dict` extension.

**libFuzzer Format Rules**:
1. Comments must be on separate lines (start with `#`)
2. No inline comments after entries
3. Hex escapes (`\xHH`) for special characters
4. Single-line entries only (no multiline strings)
5. Double quotes required around token value

**Correct Format**:
```python
# Token description goes here
"token_value"

# Special characters use hex escapes
"\x0a\x0d"  # Newline + carriage return (comment on separate line)

# Multiple tokens
"G3G8"
"*aMess*"
"uupt"
```

**WRONG - Common Mistakes**:
```python
# [FAIL] Inline comments (AFL style - breaks libFuzzer)
"token"  # Uses: 265

# [FAIL] Octal escapes (use hex instead)
"\012    "

# [FAIL] Multiline strings
"first line
second line"

# [FAIL] C++ style comments
"value"  // This breaks

# [FAIL] No quotes
token_value
```

**Verification Before Commit**:
```bash
# Test dictionary parsing
./fuzzer -dict=file.dict -runs=0 2>&1 | grep -E "Dictionary:|error"

# Success output:
# Dictionary: 153 entries

# Failure output:
# ParseDictionaryFile: error in line 156

# Check for inline comments (will break libFuzzer)
grep -n '".*".*#' file.dict
```

**Reference Examples**:
- Working libFuzzer dict: `fuzzers/core/afl.dict` (uses `\x` escapes)
- Working AFL dict: Same format works for AFL
- See: CJF-09 violation report for detailed incident analysis

---

## Performance Optimization

### Profiling Before Optimizing

**Process**:
1. Measure current performance
2. Identify bottleneck
3. Implement optimization
4. Measure improvement
5. Document results

**Tools**:
```bash
# CPU profiling
perf record -g ./fuzzer corpus/
perf report

# Memory profiling
valgrind --tool=massif ./fuzzer

# Fuzzing throughput
./fuzzer corpus/ -max_total_time=60 -print_final_stats=1
```

### Optimization Patterns

**Pattern 1: Parallel Builds**
```bash
# Before: Sequential
make target1 && make target2 && make target3

# After: Parallel
make -j32 target1 target2 target3
```

**Pattern 2: Corpus Caching**
```yaml
# GitHub Actions cache
- name: Cache Corpus
  uses: actions/cache@v4
  with:
    path: corpus/
    key: corpus-${{ hashFiles('fuzzers/*.cpp') }}
```

**Pattern 3: Resource Limits**
```bash
# Prevent OOM, allow complex inputs
max_len = 15728640  # 15MB
rss_limit_mb = 8192  # 8GB
timeout = 45  # 45s per input
```

---

## Code Review Guidelines

### Self-Review Checklist

Before requesting review or committing:
- [ ] Code compiles without warnings
- [ ] Changes are minimal and focused
- [ ] Existing tests pass
- [ ] New code has appropriate comments
- [ ] Commit message is clear and complete
- [ ] No debug code or commented-out code
- [ ] No hardcoded values (use constants)
- [ ] Error handling present
- [ ] Security review passed

### Peer Review Focus

**Reviewer Should Check**:
1. Security implications
2. Performance impact
3. Edge cases handled
4. Code clarity
5. Test coverage

**Review Comments**:
```
[OK] Approved: Change is minimal and well-justified
[WARN]  Suggestion: Consider edge case where size=0
[FAIL] Request changes: Hardcoded path needs to be configurable
```

---

## Continuous Improvement

### Learning from Failures

**Process**:
1. Document failure in ANTI_PATTERNS.md
2. Identify root cause
3. Create mitigation strategy
4. Update governance if needed

**Example**:
```markdown
## CJF-09: Incomplete Path Migration

Symptom: Build failures after repository rename
Root Cause: Grep missed files in nested directories
Mitigation: Use `git grep -r` instead of `grep -r`
Prevention: Add pre-commit check for old paths
```

### Metrics Tracking

**Session Metrics**:
- Time to resolution
- Lines changed per fix
- Number of commits
- Test pass rate
- CI/CD success rate

**Quality Metrics**:
- Regression rate (target: 0%)
- Security violations (must be 0)
- Code review approval time
- Bug fix effectiveness

---

## Safe Directory Management

### Critical Rule: Never Delete User Data

**Principle**: Always assume directories contain user-curated data unless proven otherwise.

**Classification of Directories**:

```bash
# EPHEMERAL (safe to delete/recreate)
build/, Build/, .cache/, tmp/, temp/

# PERSISTENT (NEVER delete without asking)
corpus/, seed_corpus/, crashes/, artifacts/, 
*_optimized_seed_corpus/, custom_corpus/
```

### Pattern: Conditional Directory Creation

**WRONG**:
```bash
# [FAIL] DANGEROUS - Destroys existing data
mkdir -p "$corpus_dir"
cp defaults/* "$corpus_dir/"
```

**CORRECT**:
```bash
# [OK] SAFE - Preserves existing data
if [ ! -d "$corpus_dir" ]; then
  mkdir -p "$corpus_dir"
  echo "Created seed corpus: $corpus_dir"
  cp defaults/* "$corpus_dir/"
else
  echo "Preserving existing corpus: $corpus_dir"
fi
```

### Pattern: Safe File Operations

**Writing Files**:
```bash
# [FAIL] WRONG - Overwrites without checking
cat data > important_file.txt

# [OK] CORRECT - Check before overwrite
if [ -f "important_file.txt" ]; then
  echo "WARNING: File exists, creating backup"
  cp important_file.txt important_file.txt.bak
fi
cat data > important_file.txt
```

**Removing Directories**:
```bash
# [FAIL] WRONG - Silent destruction
rm -rf "$dir"

# [OK] CORRECT - Verify and confirm
if [ -d "$dir" ]; then
  echo "About to delete: $dir"
  ls -lah "$dir"
  read -p "Confirm deletion? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$dir"
  fi
fi
```

### Pattern: Directory Preservation Logging

**Requirements**:
1. [OK] Log all directory operations
2. [OK] Distinguish creation vs preservation
3. [OK] Make operations visible to user
4. [OK] Support custom directory names

**Implementation**:
```bash
setup_corpus_directory() {
  local fuzzer=$1
  local base_dir=$2
  
  # Support multiple naming variants
  for variant in "seed_corpus" "optimized_seed_corpus" "minimal_corpus"; do
    local dir="${base_dir}/${fuzzer}_${variant}"
    
    if [ ! -d "$dir" ]; then
      mkdir -p "$dir"
      echo "  ✓ Created: ${fuzzer}_${variant}"
      # Only populate new directories
      populate_corpus "$dir"
    else
      echo "  ✓ Preserved: ${fuzzer}_${variant} ($(du -sh $dir | cut -f1))"
    fi
  done
}
```

### Testing Directory Safety

**Test Suite**:
```bash
# Test 1: Preserve existing directory
test_preserve_existing() {
  mkdir -p test_corpus
  echo "important" > test_corpus/data.txt
  
  ./build_script.sh
  
  [ -f test_corpus/data.txt ] || fail "Data destroyed"
  grep -q "important" test_corpus/data.txt || fail "Data corrupted"
}

# Test 2: Create missing directory
test_create_missing() {
  rm -rf test_corpus
  
  ./build_script.sh
  
  [ -d test_corpus ] || fail "Directory not created"
}

# Test 3: Support custom naming
test_custom_naming() {
  mkdir -p fuzzer_optimized_seed_corpus
  touch fuzzer_optimized_seed_corpus/custom.icc
  
  ./build_script.sh
  
  [ -f fuzzer_optimized_seed_corpus/custom.icc ] || fail "Custom corpus destroyed"
}
```

### Real-World Example: Fuzzer Corpus Preservation

**Context**: Build script destroying hours of fuzzing work

**Problem**:
```bash
# build-fuzzers-local.sh (BEFORE)
for fuzzer in icc_*_fuzzer; do
  mkdir -p "$OUTPUT_DIR/${fuzzer}_seed_corpus"  # Destroys existing!
  cp Testing/*.icc "$OUTPUT_DIR/${fuzzer}_seed_corpus/"
done
```

**Impact**:
- Lost custom corpus: `icc_tiffdump_fuzzer_optimized_seed_corpus`
- Hours of fuzzing work destroyed
- Campaign must restart from scratch

**Solution**:
```bash
# build-fuzzers-local.sh (AFTER)
for fuzzer in icc_*_fuzzer; do
  if [ ! -d "$OUTPUT_DIR/${fuzzer}_seed_corpus" ]; then
    mkdir -p "$OUTPUT_DIR/${fuzzer}_seed_corpus"
    echo "  Created seed corpus directory: ${fuzzer}_seed_corpus"
    cp Testing/*.icc "$OUTPUT_DIR/${fuzzer}_seed_corpus/"
  else
    echo "  Preserving existing seed corpus: ${fuzzer}_seed_corpus"
  fi
done
```

**Result**: [OK] Corpus data safe across all rebuilds

### Pre-commit Checks for Directory Safety

**Hook Template**:
```bash
#!/bin/bash
# .git/hooks/pre-commit

# Detect dangerous directory operations
DANGEROUS_PATTERNS=(
  "rm -rf.*corpus"
  "rm -rf.*seed"
  "rm -rf.*crashes"
  "mkdir -p.*corpus.*&&.*cp"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if git diff --cached | grep -E "$pattern"; then
    echo "[WARN]  WARNING: Potentially dangerous directory operation detected"
    echo "Pattern: $pattern"
    echo ""
    echo "Please verify:"
    echo "1. Existence check before mkdir/rm"
    echo "2. Preservation message for existing directories"
    echo "3. Not deleting user data"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  fi
done
```

### Directory Management Checklist

Before modifying any script that manages directories:

- [ ] Identified all persistent directories (corpus, crashes, artifacts)
- [ ] Added existence checks before mkdir/rm operations
- [ ] Added preservation messages for existing directories
- [ ] Supported custom naming variants (*_optimized_, *_minimal_, etc.)
- [ ] Tested with existing data in directories
- [ ] Tested with custom-named directories
- [ ] Tested "dirty state" (not just clean)
- [ ] Documented which directories are persistent vs ephemeral
- [ ] No rm -rf without confirmation prompts
- [ ] Logged all directory operations

### Key Lessons (2026-01-27 Session)

1. **Never assume directory is disposable**
   - Fuzzer corpus represents hours/days of work
   - Build artifacts may contain state
   - Cache directories accumulate over time

2. **Always check existence before operating**
   - `[ ! -d "$dir" ] && mkdir -p "$dir"`
   - Never use naked `mkdir -p` on data directories

3. **Inform user of preservation**
   - Silent operations are dangerous
   - User must know their data is safe
   - Log creation vs preservation

4. **Support naming flexibility**
   - Don't hardcode exact directory names
   - Pattern matching: `*_seed_corpus`, `*_optimized_*`
   - User may have custom naming conventions

5. **Test with "dirty state"**
   - Clean environment tests are insufficient
   - Test when directories already exist
   - Test with existing files in directories
   - Test with unexpected directory names

---

## References

### Internal Standards
- `.github/copilot-instructions.md` - Project conventions
- `llmcjf/profiles/` - Behavioral patterns and CJF heuristics
- `ANTI_PATTERNS.md` - What NOT to do (AP-06: Destructive Directory Operations)
- `llmcjf/reports/LLMCJF_PostMortem_27JAN2026_Corpus_Destruction.md` - Directory safety failure
- `llmcjf/reports/CJF-09_Dictionary_Format_Violation_27JAN2026.md` - Format specification incident
- Project README.md - Build and test instructions

### External Standards
- [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html)
- [CMake Best Practices](https://cmake.org/cmake/help/latest/guide/tutorial/)
- [Git Best Practices](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project)
- [libFuzzer Documentation](https://llvm.org/docs/LibFuzzer.html) - Especially dictionary format

---

**Status**: [OK] Active  
**Last Review**: 2026-01-27  
**Next Review**: 2026-02-03  
**Compliance**: Mandatory for all Copilot CLI sessions

**Recent Additions**:
- Fuzzer Dictionary Format (2026-01-27) - CJF-09 prevention
- Safe Directory Management (2026-01-27) - AP-06 prevention
- Corpus preservation best practices
- Pre-commit hooks for directory safety
- Real-world examples from production incidents

---

### 8. Fuzzer Fidelity Verification

**Rule**: Fuzzers must maintain behavioral fidelity with production tools.

**Principle**: **Tools are source of truth** - Fuzzers MUST conform to tool AST gates.

**Pattern**: 
1. Verify fuzzer crashes reproduce with actual tools
2. Match tool AST gate sequence exactly (minimum 95% fidelity)
3. Don't add extra gates not in tool path
4. Test complete, well-formed inputs as users would provide them
5. Create automated fidelity tests
6. Document fidelity analysis for each fuzzer

**Good Example - AST Gate Conformance**:
```cpp
// [OK] CORRECT - Exact copy of IccFromXml tool code
if (!profile.LoadXml(temp_file, szRelaxNGDir.c_str(), &reason)) {
    return 0;
}

if (profile.Validate(valid_report)<=icValidateWarning) {
    // Branch A - valid path (matches tool)
    for (i=0; i<16; i++) {
        if (profile.m_Header.profileID.ID8[i]) break;
    }
    SaveIccProfile(temp_out, &profile,
        bNoId ? icNeverWriteID : (i<16 ? icAlwaysWriteID : icVersionBasedID));
} else {
    // Branch B - invalid path (matches tool)
    // ... same logic
}
```

**Bad Example - Poor Fidelity**:
```cpp
// [FAIL] WRONG - Missing AST gates from tool
profile.LoadXml(temp_file, nullptr, &reason);  // Wrong parameter
profile.Validate(valid_report);  // ← Result ignored (tool uses it!)

// [FAIL] WRONG - Added non-tool behavior (false positives)
for each tag:
    tag->Describe(desc, 100);  // ← NOT IN IccFromXml TOOL PATH

// [FAIL] WRONG - Simplified logic (tool has conditional)
SaveIccProfile(temp_out, &profile, icVersionBasedID);  // Always same
```

**Fidelity Score Calculation**:
```
Fidelity % = (Gates Matched / Total Tool Gates) * 100

Example:
Tool has 6 gates: LoadXml, Validate, ProfileID check (2x), SaveIccProfile (2x)
Fuzzer matches 2.5: LoadXml (partial), Validate (ignored), SaveIccProfile (wrong)
Fidelity = 2.5/6 * 100 = 41.7% [FAIL] FAIL (minimum 95% required)
```

**Verification Steps**:
1. Identify tool source (e.g., `Tools/CmdLine/IccFromXml/IccFromXml.cpp`)
2. Extract tool AST gate sequence
3. Compare with fuzzer implementation side-by-side
4. Calculate fidelity score
5. If < 95%, document gaps in `docs/FUZZER_FIDELITY_*.md`
6. Fix or replace fuzzer

**Implementation**:
```bash
# Test crash with fuzzer
fuzzers-local/undefined/icc_fromxml_fuzzer crash.xml

# Test same crash with tool (MUST match behavior)
Build/Tools/IccFromXml/iccFromXml crash.xml output.icc

# Both should produce identical results
# If different → fidelity broken, fuzzer needs fixing
```

**Documentation Requirements**:
- AST Gate Spec: `docs/AST_GATES_REFERENCE.md`
- Tool Documentation: `docs/TOOL_<toolname>.md`
- Fuzzer Documentation: `docs/FUZZER_<fuzzername>.md`
- Fidelity Analysis: `docs/FUZZER_FIDELITY_<fuzzername>.md`

**LLMCJF Config**:
```yaml
fuzzer_fidelity:
  enabled: true
  mode: "ast_gate_strict"
  minimum_required: 95
  verification_workflow: [identify, extract, compare, score, document, fix]
```

**Why**: False positives waste time, create noise, and reduce confidence in fuzzing results. AST gate fidelity ensures bugs found are real security issues users can trigger with actual tools.

**Reference**: 
- See `docs/AST_GATES_REFERENCE.md` for complete gate specification
- See `docs/FUZZER_FIDELITY_ICC_FROMXML.md` for case study (40% vs 100% fidelity)
- See `.llmcjf-config.yaml` section `fuzzer_fidelity` for enforcement


---

## Command Verification Pattern [STAR] NEW (2026-01-29)

**Critical**: Every command must verify success before proceeding.

### The Problem

**Silent failures**:
```bash
# WRONG - No verification
clang++ -S -emit-llvm file.cpp -o output.ll
opt -passes=dot-callgraph output.ll  # Fails silently if first command failed
dot -Tpng callgraph.dot -o output.png  # Fails silently if no dot file
```

**Result**: 3 commands, 3 silent failures, no useful output

### The Solution

**Mandatory verification pattern**:
```bash
# CORRECT - Verify each step
clang++ -S -emit-llvm file.cpp -o output.ll && \
  ls -lh output.ll && \
  file output.ll || \
  { echo "FAILED: LLVM IR generation"; exit 1; }

# Only proceed if previous succeeded
opt -passes=dot-callgraph output.ll -disable-output && \
  ls -lh *.dot || \
  { echo "FAILED: Call graph generation"; exit 1; }

# Verify dot file location before conversion
DOT_FILE=$(ls /tmp/*.callgraph.dot 2>/dev/null | head -1)
[ -f "$DOT_FILE" ] || { echo "ERROR: No dot file found"; exit 1; }

dot -Tpng "$DOT_FILE" -o output.png && \
  ls -lh output.png && \
  file output.png || \
  { echo "FAILED: PNG conversion"; exit 1; }
```

### Verification Requirements

After **every** command, verify:

1. **Exit code**: `$?` equals 0
2. **Output exists**: `ls -lh output_file`
3. **Correct format**: `file output_file`
4. **Expected size**: Not zero bytes, reasonable size
5. **Report result**: Explicit success/failure

### Template

```bash
#!/bin/bash
set -e  # Exit on any error

# Command template
DESCRIPTION="What this does"
OUTPUT_FILE="expected_output.ext"

echo "Step: $DESCRIPTION"
command arg1 arg2 -o "$OUTPUT_FILE" && \
  [ -f "$OUTPUT_FILE" ] && \
  [ -s "$OUTPUT_FILE" ] && \
  file "$OUTPUT_FILE" | grep -q "expected type" || \
  { echo "FAILED: $DESCRIPTION"; exit 1; }

echo "SUCCESS: $DESCRIPTION"
ls -lh "$OUTPUT_FILE"
```

### Anti-Patterns

[FAIL] **NEVER**:
- Respond "Good!" to silent output
- Proceed without checking file existence
- Assume no error message = success
- Continue after errors
- Skip verification steps

[OK] **ALWAYS**:
- Verify before declaring success
- Check file existence and size
- Validate output format
- Stop at first error
- Report specific failures

### Real Example (2026-01-29)

**Wrong** (Session 003 violation):
```bash
$ clang++ -S -emit-llvm ... -o /tmp/output.ll
# (no output)
Response: "Good! Now check if the IR file was created"
```

**Correct**:
```bash
$ clang++ -S -emit-llvm ... -o /tmp/output.ll && \
  ls -lh /tmp/output.ll && \
  file /tmp/output.ll | grep "LLVM IR" || \
  { echo "FAILED: Compilation or invalid IR"; exit 1; }

# Expected output:
# -rw-rw-r-- 1 user user 5.0M ... /tmp/output.ll
# /tmp/output.ll: ASCII text
# SUCCESS: LLVM IR generated
```

### Chaining Commands

**Sequential with gates**:
```bash
#!/bin/bash
set -e

step1() {
  echo "Step 1: Compile to LLVM IR"
  clang++ -S -emit-llvm source.cpp -o /tmp/out.ll
  [ -f /tmp/out.ll ] || return 1
  file /tmp/out.ll | grep -q "ASCII" || return 1
  echo "✓ Step 1 complete"
}

step2() {
  echo "Step 2: Generate call graph"
  opt -passes=dot-callgraph /tmp/out.ll -disable-output
  DOT=$(ls /tmp/*.callgraph.dot 2>/dev/null | head -1)
  [ -f "$DOT" ] || return 1
  echo "✓ Step 2 complete: $DOT"
}

step3() {
  echo "Step 3: Convert to PNG"
  DOT=$(ls /tmp/*.callgraph.dot 2>/dev/null | head -1)
  dot -Tpng "$DOT" -o callgraph.png
  [ -s callgraph.png ] || return 1
  file callgraph.png | grep -q "PNG" || return 1
  echo "✓ Step 3 complete"
  ls -lh callgraph.png
}

# Execute with error handling
step1 || { echo "ABORT: Step 1 failed"; exit 1; }
step2 || { echo "ABORT: Step 2 failed"; exit 1; }
step3 || { echo "ABORT: Step 3 failed"; exit 1; }

echo "SUCCESS: All steps completed"
```

### Parallel Commands

**Multiple independent verifications**:
```bash
# Analyze multiple files in parallel
for file in file1.cpp file2.cpp file3.cpp; do
  (
    clang++ -c "$file" -o "${file%.cpp}.o" && \
      [ -f "${file%.cpp}.o" ] || \
      { echo "FAILED: $file compilation"; exit 1; }
  ) &
done

# Wait and verify all succeeded
wait
[ $? -eq 0 ] || { echo "Some compilations failed"; exit 1; }

# Verify all outputs exist
for file in file1.cpp file2.cpp file3.cpp; do
  [ -f "${file%.cpp}.o" ] || { echo "Missing: ${file%.cpp}.o"; exit 1; }
done

echo "SUCCESS: All files compiled"
ls -lh *.o
```

---

## User Example Handling [STAR] NEW (2026-01-29)

**Critical**: Never echo user examples. Always analyze source.

### The Problem

User provides example output format:
```
GetElemNumberValue() 
  ├─ Allocates: float rv (4 bytes) at [16, 20)
  └─ Calls: GetValues(&rv, 0, 1)
```

**Wrong response** - echo the example:
```bash
cat << 'TREE'
GetElemNumberValue() 
  ├─ Allocates: float rv (4 bytes) at [16, 20)
  └─ Calls: GetValues(&rv, 0, 1)
TREE
```

### The Solution

**Analyze source to generate**:
```bash
#!/bin/bash
# Parse actual source code

# Extract function
FUNC="GetElemNumberValue"
FILE="IccProfLib/IccTagComposite.cpp"

# Get actual code
CODE=$(sed -n '/^icFloatNumber.*GetElemNumberValue/,/^}/p' "$FILE")

# Parse variable declaration
VAR=$(echo "$CODE" | grep "icFloatNumber rv" | sed 's/.*icFloatNumber//')
echo "$FUNC()"

# Analyze with AST
clang++ -Xclang -ast-dump -Xclang -ast-dump-filter="$FUNC" \
  -fsyntax-only -I./IccProfLib "$FILE" 2>&1 | \
  grep "VarDecl.*rv" | \
  awk '{print "  ├─ Allocates: " $3 " (4 bytes) at stack offset"}'

# Extract function call
echo "$CODE" | grep "GetValues" | \
  sed 's/^/  └─ Calls: /'
```

### Rules

1. **User examples are FORMAT templates** - not content to copy
2. **Always analyze source** - extract real data
3. **Compute values** - don't hard-code user's numbers
4. **Generate output** - from parsed information
5. **Verify correctness** - against actual source

### Detection

Script echoes user example if:
- Contains user's exact text
- No source file parsing
- No AST analysis
- Hard-coded values
- No computed output

### Mitigation

```bash
# WRONG
cat << 'OUTPUT'
  ├─ Allocates: float rv (4 bytes) at [16, 20)
OUTPUT

# CORRECT  
VARIABLE=$(parse_ast_for_variable)
SIZE=$(get_type_size "$VARIABLE")
OFFSET=$(compute_stack_offset)
echo "  ├─ Allocates: $VARIABLE ($SIZE bytes) at [$OFFSET, $((OFFSET+SIZE)))"
```

---

## Session Startup Procedure [STAR] UPDATED (2026-01-29)

Every session must begin with:

```bash
#!/bin/bash
# Session startup self-check

echo "╔════════════════════════════════════════════════════════╗"
echo "║          CJF Prevention Checklist - Session Start      ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Governance Verification:"
echo "  [ ] CJF-10: No echoing user examples - ANALYZE source"
echo "  [ ] CJF-11: Verify all commands before claiming success"
echo "  [ ] CJF-12: Stop at first error - don't proceed"
echo "  [ ] CJF-13: Plan before iterate - one attempt to completion"
echo ""
echo "Command Pattern:"
echo "  [ ] Every command has verification gate"
echo "  [ ] Silent output = verify before success"
echo "  [ ] Error message = full stop and fix"
echo "  [ ] User examples = format template only"
echo ""
echo "Session Documents Read:"
echo "  [ ] .copilot-sessions/governance/ANTI_PATTERNS.md"
echo "  [ ] .copilot-sessions/governance/BEST_PRACTICES.md"
echo "  [ ] llmcjf/STRICT_ENGINEERING_PROLOGUE.md"
echo ""
echo "════════════════════════════════════════════════════════"
```

**Add to**: All session start scripts, checkpoint resumption

---

**Updated**: 2026-01-29  
**New Sections**: Command Verification, User Example Handling, Startup Procedure  
**Source**: Session 003 CJF violations
