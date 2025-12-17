# Crash Reproduction Guide
## Project Tools Only - No External Code

**Version**: 1.0  
**Effective**: 2026-01-29  
**Enforcement**: Mandatory

---

## Critical Rule

**ALL crash reproduction MUST use project tooling exclusively.**

**Prohibited**:
- [FAIL] Creating C++ test programs
- [FAIL] Writing custom reproduction harnesses
- [FAIL] Using external tools not in project
- [FAIL] "Documentation programs"

**Required**:
- [OK] Use project fuzzers
- [OK] Use project command-line tools
- [OK] Archive POC files with descriptive names

---

## Standard Reproduction Workflow

### Method 1: Using Fuzzers (Preferred)

**For UBSan/ASan crashes:**

```bash
# Step 1: Reproduce with undefined sanitizer fuzzer
fuzzers-local/undefined/<fuzzer_name> <crash_file>

# Step 2: Archive POC with descriptive name
cp <crash_file> poc-archive/ub-<type>-<function>-<file>_cpp-L<line>.<ext>

# Example:
fuzzers-local/undefined/icc_fromxml_fuzzer crash-41afa95440828783ceeab4f35b0e6abfdc33e703
cp crash-41afa95440828783ceeab4f35b0e6abfdc33e703 \
   poc-archive/ub-null-ptr-offset-CIccTagUnknown-Describe-IccTagBasic_cpp-L356.xml
```

**For memory crashes:**

```bash
# Use address sanitizer fuzzer
fuzzers-local/address/<fuzzer_name> <crash_file>
```

### Method 2: Using Project Tools

**For XML-based crashes:**

```bash
# Step 1: Convert XML to ICC profile
Build/Tools/IccFromXml/iccFromXml <poc.xml> <output.icc>

# Step 2: Trigger crash with high verbosity
Build/Tools/IccDumpProfile/iccDumpProfile <output.icc> [tag] [verbosity]

# Example:
Build/Tools/IccFromXml/iccFromXml \
  poc-archive/ub-null-ptr-offset-CIccTagUnknown-Describe-IccTagBasic_cpp-L356.xml \
  test-output.icc

Build/Tools/IccDumpProfile/iccDumpProfile test-output.icc desc 100
```

**For TIFF-based crashes:**

```bash
# Convert and inspect TIFF
Build/Tools/IccTiffDump/iccTiffDump <crash.tiff> [verbosity]
```

**For image processing crashes:**

```bash
# Test with apply profiles
Build/Tools/IccApplyProfiles/iccApplyProfiles \
  <profile.icc> <input.tiff> <output.tiff>
```

---

## Available Project Tools

### Core Tools (Build/Tools/)

| Tool | Purpose | Input Format |
|------|---------|--------------|
| `IccFromXml/iccFromXml` | XML → ICC conversion | `.xml` |
| `IccToXml/iccToXml` | ICC → XML conversion | `.icc` |
| `IccDumpProfile/iccDumpProfile` | Profile inspection | `.icc` |
| `IccTiffDump/iccTiffDump` | TIFF inspection | `.tiff` |
| `IccPngDump/iccPngDump` | PNG inspection | `.png` |
| `IccJpegDump/iccJpegDump` | JPEG inspection | `.jpg` |
| `IccApplyProfiles/iccApplyProfiles` | Profile application | `.icc + .tiff` |
| `IccApplyNamedCmm/iccApplyNamedCmm` | CMM application | `.icc` |

### Fuzzers (fuzzers-local/)

**Address Sanitizer** (`fuzzers-local/address/`):
- Detects: heap/stack buffer overflow, use-after-free, double-free
- Memory leak detection with `detect_leaks=1`

**Undefined Behavior Sanitizer** (`fuzzers-local/undefined/`):
- Detects: NULL pointer dereference, integer overflow, enum bounds
- Type confusion, alignment issues

**Available Fuzzers**:
- `icc_fromxml_fuzzer` - XML to ICC fuzzing
- `icc_toxml_fuzzer` - ICC to XML fuzzing
- `icc_profile_fuzzer` - Core profile parsing
- `icc_calculator_fuzzer` - Calculator element fuzzing
- `icc_spectral_fuzzer` - Spectral data fuzzing
- `icc_io_fuzzer` - I/O operations fuzzing
- `icc_multitag_fuzzer` - Multi-tag fuzzing
- `icc_apply_fuzzer` - Profile application fuzzing
- `icc_applyprofiles_fuzzer` - ApplyProfiles tool fuzzing
- `icc_roundtrip_fuzzer` - Roundtrip testing
- `icc_link_fuzzer` - Profile linking fuzzing
- `icc_dump_fuzzer` - Dump operations fuzzing
- `icc_tiffdump_fuzzer` - TIFF dump fuzzing

---

## POC Naming Convention

**Format**: `<category>-<type>-<function>-<file>_cpp-L<line>.<ext>`

**Categories**:
- `crash` - General crashes
- `ub` - Undefined behavior
- `leak` - Memory leaks
- `oom` - Out of memory
- `timeout` - Timeout/hang
- `ubsan` - UBSan-specific
- `asan` - ASan-specific

**Examples**:
```
ub-null-ptr-offset-CIccTagUnknown-Describe-IccTagBasic_cpp-L356.xml
crash-heap-overflow-icCurvesFromXml-IccTagXml_cpp-L3294.xml
leak-memory-CIccProfile-Read-IccProfile_cpp-L445.icc
oom-allocation-CIccTagDict-Read-IccTagDict_cpp-L580.icc
```

---

## Reproduction Documentation

After successful reproduction, document in session logs ONLY.

**Required Information**:
1. Crash type (NULL deref, heap overflow, etc.)
2. Source location (file:line)
3. Reproduction command (using project tools)
4. POC archive location

**Example Documentation**:
```markdown
## UBSan SEGV - NULL Pointer Offset

**Location**: IccTagBasic.cpp:356
**Type**: NULL + 4 dereference in CIccTagUnknown::Describe
**POC**: poc-archive/ub-null-ptr-offset-CIccTagUnknown-Describe-IccTagBasic_cpp-L356.xml

**Reproduction**:
fuzzers-local/undefined/icc_fromxml_fuzzer \
  crash-41afa95440828783ceeab4f35b0e6abfdc33e703

**Root Cause**: 
icMemDump called with m_pData+4 where m_pData is NULL

**Fix**: Add NULL check before icMemDump call
```

**Prohibited Documentation**:
```cpp
// [FAIL] DO NOT CREATE FILES LIKE THIS
int main() {
  std::cout << "Reproduction steps...\n";
  return 0;
}
```

---

## Common Reproduction Patterns

### Pattern 1: Direct Fuzzer Reproduction

**When**: Crash file from fuzzer run
**How**: Run same fuzzer with crash file

```bash
# Most direct method
fuzzers-local/undefined/icc_fromxml_fuzzer crash-XXXXX
```

### Pattern 2: Tool Chain Reproduction

**When**: Need to inspect intermediate states
**How**: Convert → Dump → Analyze

```bash
# Step-by-step analysis
Build/Tools/IccFromXml/iccFromXml crash.xml output.icc
Build/Tools/IccDumpProfile/iccDumpProfile output.icc desc 100
```

### Pattern 3: High Verbosity Triggers

**When**: Crash only occurs with detailed output
**How**: Use verbosity parameter

```bash
# Verbosity levels:
# 0   = minimal output
# 50  = normal details
# 100 = full details (triggers Describe calls, icMemDump, etc.)

Build/Tools/IccDumpProfile/iccDumpProfile profile.icc tag 100
```

### Pattern 4: Tag-Specific Reproduction

**When**: Crash in specific tag type
**How**: Target specific tag

```bash
# Dump specific tag only
Build/Tools/IccDumpProfile/iccDumpProfile profile.icc desc 100
Build/Tools/IccDumpProfile/iccDumpProfile profile.icc wtpt 100
Build/Tools/IccDumpProfile/iccDumpProfile profile.icc chad 100
```

---

## Verification Checklist

Before marking reproduction complete:

- [ ] Crash reproduced with project tool (fuzzer OR command-line tool)
- [ ] POC file archived with descriptive name
- [ ] Crash location documented (file:line)
- [ ] Root cause identified
- [ ] No external code created
- [ ] No custom test programs written
- [ ] All temp files cleaned up

---

## LLMCJF Enforcement

**Violation Detection**:
- Any `.cpp` or `.c` files in `/tmp/` during reproduction
- Custom `main()` functions for "documentation"
- External tools not in `Build/Tools/` or `fuzzers-local/`

**Consequences**:
1. Immediate violation report to `llmcjf/reports/`
2. Cleanup of unnecessary files
3. Documentation update (this guide)
4. Fingerprint recording

**Reference Violation**: `llmcjf/reports/LLMCJF_Violation_29JAN2026_Mission_Creep.md`

---

## Real-World Examples

### Example 1: UBSan NULL Pointer (2026-01-29)

**Initial Report**:
```
UndefinedBehaviorSanitizer: SEGV on unknown address 0x000000000004
IccUtil.cpp:1002:36 in icMemDump
```

**Correct Reproduction**:
```bash
fuzzers-local/undefined/icc_fromxml_fuzzer \
  crash-41afa95440828783ceeab4f35b0e6abfdc33e703
```

**Result**: [OK] Reproduced in 1 command

**What NOT to do**:
```cpp
// [FAIL] WRONG - Unnecessary code
int main() {
  std::cout << "Testing NULL pointer...\n";
  void* ptr = nullptr;
  // ...
}
```

### Example 2: Heap Overflow in icCurvesFromXml

**Reproduction**:
```bash
# Step 1: Convert
Build/Tools/IccFromXml/iccFromXml \
  heap-buffer-overflow-icCurvesFromXml-IccTagXml_cpp-Line3294.xml \
  test.icc

# Step 2: Inspect (if needed)
Build/Tools/IccDumpProfile/iccDumpProfile test.icc 100
```

### Example 3: OOM in CIccTagDict

**Reproduction**:
```bash
fuzzers-local/address/icc_profile_fuzzer \
  oom-CIccTagDict-Read-IccTagDict_cpp-Line580.icc
```

---

## Tool Build Instructions

**If tools are missing:**

```bash
# Build all command-line tools
cd Build
cmake Cmake
make -j32

# Tools will be in:
# Build/Tools/Icc*/icc*

# Verify tools exist
ls -lh Build/Tools/*/icc*
```

**If fuzzers are missing:**

```bash
# Build both sanitizer variants
./build-fuzzers-local.sh address      # 5-7 minutes
./build-fuzzers-local.sh undefined    # 5-7 minutes

# Fuzzers will be in:
# fuzzers-local/address/
# fuzzers-local/undefined/

# Verify fuzzers exist
ls -lh fuzzers-local/address/
ls -lh fuzzers-local/undefined/
```

---

## Quick Reference Card

**Most Common Workflows**:

```bash
# XML crash → Fuzzer test
fuzzers-local/undefined/icc_fromxml_fuzzer <crash.xml>

# XML crash → Tool test
Build/Tools/IccFromXml/iccFromXml <crash.xml> out.icc
Build/Tools/IccDumpProfile/iccDumpProfile out.icc 100

# ICC crash → Fuzzer test
fuzzers-local/undefined/icc_profile_fuzzer <crash.icc>

# ICC crash → Tool test
Build/Tools/IccDumpProfile/iccDumpProfile <crash.icc> 100

# TIFF crash → Tool test
Build/Tools/IccTiffDump/iccTiffDump <crash.tiff> 100
```

**Archive POC**:
```bash
cp <crash_file> poc-archive/<descriptive-name>.<ext>
```

**Clean up**:
```bash
rm -f test-output.icc test.icc out.icc foo.bar
```

---

## Status

- [OK] **Active**: Mandatory for all crash reproduction
- 📅 **Effective**: 2026-01-29
- 🔄 **Next Review**: 2026-02-05
- 🔒 **Enforcement**: LLMCJF strict mode

**Updates**:
- 2026-01-29: Initial version based on mission creep violation

**See Also**:
- `.llmcjf-config.yaml` - Workflow configuration
- `llmcjf/profiles/strict_engineering.yaml` - Behavioral rules
- `llmcjf/reports/LLMCJF_Violation_29JAN2026_Mission_Creep.md` - Violation case study
- `.copilot-sessions/governance/BEST_PRACTICES.md` - Engineering standards
