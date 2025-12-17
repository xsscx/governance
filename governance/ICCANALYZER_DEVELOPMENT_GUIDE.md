# IccAnalyzer Development Guide

**Version**: 1.0  
**Date**: 2026-01-29  
**Purpose**: Development governance and standards for IccAnalyzer tool

---

## Overview

IccAnalyzer is a modular command-line tool for low-level ICC profile analysis, security auditing, and LUT manipulation. This guide establishes development standards, governance requirements, and typical usage patterns.

---

## Architecture

### Modular Design (16 Components)

**Core Entry Point:**
- `iccAnalyzer.cpp` (302 lines) - Main entry, CLI parsing

**Functional Modules:**
1. **IccAnalyzerCommon.h** (81 lines) - Shared includes, types
2. **IccAnalyzerSecurity** (.h/.cpp, 417 lines) - Security heuristics, threat detection
3. **IccAnalyzerInspect** (.h/.cpp, 272 lines) - Hex dump, header/tag inspection
4. **IccAnalyzerSignatures** (.h/.cpp, 245 lines) - Signature validation
5. **IccAnalyzerValidation** (.h/.cpp, 336 lines) - Round-trip validation, batch scanning
6. **IccAnalyzerLUT** (.h/.cpp, 864 lines) - LUT extraction/injection (legacy + MPE)
7. **IccAnalyzerNinja** (.h/.cpp, 245 lines) - Unsafe raw analysis
8. **IccAnalyzerComprehensive** (.h/.cpp, 196 lines) - Multi-phase orchestration
9. **IccAnalyzerFingerprint** (.h/.cpp) - Anomaly detection, weaponization signatures

### Dependency Graph
```
iccAnalyzer.cpp
  ├─> IccAnalyzerCommon.h (all modules)
  ├─> IccAnalyzerSecurity
  │     └─> IccAnalyzerSignatures
  ├─> IccAnalyzerInspect
  ├─> IccAnalyzerValidation
  │     └─> IccAnalyzerSignatures
  ├─> IccAnalyzerLUT
  │     └─> IccAnalyzerInspect
  ├─> IccAnalyzerNinja
  │     └─> IccAnalyzerInspect
  ├─> IccAnalyzerComprehensive
  │     └─> (all modules)
  └─> IccAnalyzerFingerprint
```

---

## Operational Modes

### 1. Dump Mode (-d, default)
**Purpose**: Basic profile inspection  
**Output**: Hex dump + header + tag table  
**Usage**: `iccAnalyzer -d profile.icc`

### 2. Security Heuristics (-h)
**Purpose**: Detect suspicious patterns  
**Module**: IccAnalyzerSecurity.cpp  
**Checks**: 10 heuristic validations (header + tags)  
**Usage**: `iccAnalyzer -h suspicious.icc`

### 3. Fingerprint Analysis (-f)
**Purpose**: Anomaly detection + weaponization signatures  
**Module**: IccAnalyzerFingerprint.cpp  
**Detects**:
- NaN values (undefined behavior triggers)
- 0xFF pollution (buffer overflow indicators)
- File size mismatches
- High-entropy trailing data
- Null vendor fields

**Usage**: `iccAnalyzer -f weaponized.icc`

### 4. Comprehensive Mode (-a)
**Purpose**: All-in-one analysis  
**Module**: IccAnalyzerComprehensive.cpp  
**Executes**: Security + Validation + Signatures + Inspection  
**Usage**: `iccAnalyzer -a profile.icc`

### 5. Signature Analysis (-s)
**Purpose**: Validate all signatures in profile  
**Module**: IccAnalyzerSignatures.cpp  
**Usage**: `iccAnalyzer -s profile.icc`

### 6. Round-Trip Validation (-rt)
**Purpose**: Check AToB/BToA, DToB/BToD tag pair consistency  
**Module**: IccAnalyzerValidation.cpp  
**Usage**: `iccAnalyzer -rt display.icc`

### 7. Ninja Mode (-n)
**Purpose**: Raw analysis without validation (malformed profiles)  
**Module**: IccAnalyzerNinja.cpp  
**Usage**: `iccAnalyzer -n corrupted.icc`  
**Warning**: Bypasses safety checks - use for forensic analysis only

### 8. Recursive Scan (-r)
**Purpose**: Batch process directory trees  
**Module**: IccAnalyzerValidation.cpp  
**Usage**: `iccAnalyzer -r ./Testing/`

### 9. LUT Extraction (-x)
**Purpose**: Extract legacy (lut8/lut16) and MPE CLUTs  
**Module**: IccAnalyzerLUT.cpp  
**Usage**: `iccAnalyzer -x display.icc basename`  
**Output**: `{basename}_{tag}_mpe_clut{N}.bin` (uint16 big-endian)

### 10. LUT Injection (-i, -im)
**Purpose**: Inject modified CLUT data  
**Module**: IccAnalyzerLUT.cpp  
**Legacy**: `iccAnalyzer -i profile.icc clut.bin output.icc`  
**MPE**: `iccAnalyzer -im profile.icc clut.bin output.icc`

### 11. Tag Dump (-t)
**Purpose**: Hex dump specific tag by signature  
**Module**: IccAnalyzerInspect.cpp  
**Usage**: `iccAnalyzer -t A2B0 display.icc`

---

## Development Standards

### Code Style
- **Indentation**: 2 spaces, no tabs
- **Bracing**: K&R style
- **Member prefix**: `m_` for class/struct members
- **Copyright**: ICC BSD 3-Clause header required on all files
- **Include guards**: Required on all headers
- **C++ Standard**: C++17 or higher

### Module Design Principles
1. **Single Responsibility**: Each module has one clear purpose
2. **Minimal Dependencies**: Reduce coupling between modules
3. **Explicit Interfaces**: Clear header-defined APIs
4. **No Circular Dependencies**: Enforce directed acyclic graph
5. **Testability**: Each module independently testable

### Adding New Functionality

#### Option 1: Extend Existing Module
When to use:
- Feature logically fits existing module
- Module size remains < 1000 lines
- No new major functional area

Steps:
1. Add function declaration to module header
2. Implement in module .cpp file
3. Update module documentation
4. Add test case to test suite

#### Option 2: Create New Module
When to use:
- New functional area (e.g., JSON output, threat scoring)
- Would bloat existing module beyond 1000 lines
- Independent concern with distinct dependencies

Steps:
1. Create `IccAnalyzer{ModuleName}.h` (interface)
2. Create `IccAnalyzer{ModuleName}.cpp` (implementation)
3. Add ICC copyright header (full BSD 3-Clause)
4. Include in `IccAnalyzerCommon.h` if widely used
5. Update `Build/Cmake/Tools/IccAnalyzer/CMakeLists.txt`
6. Add to dependency graph documentation
7. Create test cases

Template:
```cpp
// IccAnalyzer{ModuleName}.h
#ifndef _ICC_ANALYZER_{MODULENAME}_H
#define _ICC_ANALYZER_{MODULENAME}_H

#include "IccAnalyzerCommon.h"

// Function declarations
int {ModuleName}Function(const char* arg);

#endif // _ICC_ANALYZER_{MODULENAME}_H
```

### Build System Integration

**CMakeLists.txt Location**: `Build/Cmake/Tools/IccAnalyzer/CMakeLists.txt`

**Adding New Module**:
```cmake
SET( SOURCES  
  ${SRC_PATH}/Tools/CmdLine/IccAnalyzer/iccAnalyzer.cpp
  ${SRC_PATH}/Tools/CmdLine/IccAnalyzer/IccAnalyzerInspect.cpp
  ${SRC_PATH}/Tools/CmdLine/IccAnalyzer/IccAnalyzerSecurity.cpp
  # ... existing modules ...
  ${SRC_PATH}/Tools/CmdLine/IccAnalyzer/IccAnalyzer{NewModule}.cpp  # ADD HERE
)
```

**Build Command**:
```bash
cd Build/Cmake
cmake .
make -j32 iccAnalyzer
```

**Binary Location**: `Build/Cmake/build_*/Tools/IccAnalyzer/iccAnalyzer`

---

## Testing Requirements

### Functional Testing
Test all operational modes after changes:
```bash
# Dump mode
iccAnalyzer -d Testing/Calc/srgbCalcTest.icc

# Security heuristics
iccAnalyzer -h Testing/Calc/srgbCalcTest.icc

# Comprehensive
iccAnalyzer -a Testing/Calc/srgbCalcTest.icc

# Signature analysis
iccAnalyzer -s Testing/Calc/srgbCalcTest.icc

# Round-trip
iccAnalyzer -rt Testing/Display/LCDDisplay.icc

# Recursive scan
iccAnalyzer -r Testing/Calc/

# LUT extraction
iccAnalyzer -x Testing/Display/LCDDisplay.icc test_lut

# Fingerprint
iccAnalyzer -f Testing/Calc/srgbCalcTest.icc
```

### Regression Testing
**Test Suite**: `test_refactored_iccanalyzer.sh`  
**Coverage**: 10 operational modes  
**Requirement**: All tests pass before commit

### Static Analysis
```bash
# CodeQL analysis
./build-for-codeql.sh
codeql database analyze codeql-db-iccanalyzer --format=sarif-latest --output=results.sarif

# Scan-build
scan-build make -j32 iccAnalyzer
```

### Fuzzing Integration
**Corpus**: `corpus/` directory  
**Attack Files**: `poc-archive/` (documented weaponized profiles)  
**Usage**: Test fingerprint mode against known attack vectors

---

## Security Considerations

### Input Validation
- **Always validate file existence** before processing
- **Check file size limits** (prevent OOM attacks)
- **Validate tag offsets** (prevent out-of-bounds reads)
- **Handle malformed profiles gracefully** (use Ninja mode for unsafe analysis)

### Unsafe Operations
**Ninja Mode (-n)**: Bypasses ICC library validation  
**Use Cases**: Forensic analysis, malware research  
**Restrictions**: 
- Never use on untrusted files in production
- Document rationale when used in test scripts
- Isolate in IccAnalyzerNinja module

### Fuzzing Safety
- LUT injection validates CLUT dimensions before modification
- File size mismatches detected in Fingerprint mode
- NaN detection prevents undefined behavior propagation

---

## Governance Requirements

### Documentation Updates
When modifying iccAnalyzer:
1. Update module-specific documentation in `Tools/CmdLine/IccAnalyzer/`
2. Update this development guide if architecture changes
3. Add examples for new modes to `Readme.md`
4. Document security implications if applicable

### Commit Standards
**Message Format**:
```
{type}: {scope} - {description}

Types: feat, fix, refactor, docs, test, security
Scopes: iccanalyzer-{module}, iccanalyzer-build, iccanalyzer-docs

Examples:
feat: iccanalyzer-security - Add threat scoring calculation
fix: iccanalyzer-lut - Validate CLUT dimensions before injection
refactor: iccanalyzer - Extract fingerprint module
docs: iccanalyzer - Add JSON output examples
```

### Pre-Commit Checklist
- [ ] All existing tests pass
- [ ] New functionality has test coverage
- [ ] No new compiler warnings
- [ ] Documentation updated
- [ ] Build system updated if new modules added
- [ ] Security review if handling untrusted input
- [ ] ICC copyright header on new files

---

## Typical Development Workflows

### Workflow 1: Add New Analysis Mode

**Example**: Add JSON output mode

1. **Planning**:
   - Determine if new module needed (yes - distinct output format)
   - Design interface: `int OutputJSON(const char* filename, const char* mode)`

2. **Implementation**:
   ```bash
   # Create module files
   cd Tools/CmdLine/IccAnalyzer/
   touch IccAnalyzerJSON.h IccAnalyzerJSON.cpp
   
   # Add ICC copyright header
   # Implement JSON output functions
   # Update CMakeLists.txt
   # Add -j flag to main CLI parser
   ```

3. **Testing**:
   ```bash
   cd Build/Cmake
   make -j32 iccAnalyzer
   
   # Test new mode
   ../Tools/IccAnalyzer/iccAnalyzer -j Testing/Calc/srgbCalcTest.icc
   
   # Validate JSON output
   ../Tools/IccAnalyzer/iccAnalyzer -j test.icc | jq .
   ```

4. **Documentation**:
   - Add mode to Readme.md
   - Update ICCANALYZER_DEVELOPMENT_GUIDE.md
   - Add examples

### Workflow 2: Extend Security Heuristics

**Example**: Add duplicate tag detection

1. **Module Location**: `IccAnalyzerSecurity.cpp`

2. **Add Heuristic**:
   ```cpp
   // In HeuristicAnalyze() function
   
   // Check 11: Duplicate tags
   std::map<icSignature, int> tagCounts;
   for (int i = 0; i < tagCount; i++) {
     TagEntry entry = pProfile->m_Tags->GetIndex(i);
     tagCounts[entry.TagInfo.sig]++;
   }
   
   for (const auto& pair : tagCounts) {
     if (pair.second > 1) {
       printf("  ⚠  SUSPICIOUS: Tag '%s' appears %d times (duplicate)\n",
              icGetSigStr(pair.first), pair.second);
     }
   }
   ```

3. **Testing**:
   - Create test profile with duplicate tags
   - Run: `iccAnalyzer -h duplicate_test.icc`
   - Verify detection message

4. **Documentation**:
   - Update heuristics count in Readme.md
   - Add to FINGERPRINT_MODE.md if applicable

### Workflow 3: Fix Bug in LUT Module

**Example**: CLUT dimension overflow

1. **Locate Issue**: `IccAnalyzerLUT.cpp`

2. **Minimal Fix**:
   ```cpp
   // Before
   icUInt32Number totalValues = outputChannels * gridSize;
   
   // After (with overflow check)
   icUInt32Number totalValues;
   if (gridSize > UINT32_MAX / outputChannels) {
     fprintf(stderr, "Error: CLUT dimension overflow\n");
     return 1;
   }
   totalValues = outputChannels * gridSize;
   ```

3. **Verify Fix**:
   ```bash
   # Test with attack file
   iccAnalyzer -x oom-attack.icc test
   
   # Should reject gracefully, not crash
   ```

4. **Regression Test**:
   ```bash
   ./test_refactored_iccanalyzer.sh
   ```

---

## Configuration Files

### Build Configuration
**File**: `Build/Cmake/Tools/IccAnalyzer/CMakeLists.txt`

```cmake
SET( SRC_PATH ../../../.. )
SET( SOURCES  
  ${SRC_PATH}/Tools/CmdLine/IccAnalyzer/iccAnalyzer.cpp
  ${SRC_PATH}/Tools/CmdLine/IccAnalyzer/IccAnalyzerCommon.h
  ${SRC_PATH}/Tools/CmdLine/IccAnalyzer/IccAnalyzerInspect.cpp
  ${SRC_PATH}/Tools/CmdLine/IccAnalyzer/IccAnalyzerSecurity.cpp
  ${SRC_PATH}/Tools/CmdLine/IccAnalyzer/IccAnalyzerSignatures.cpp
  ${SRC_PATH}/Tools/CmdLine/IccAnalyzer/IccAnalyzerValidation.cpp
  ${SRC_PATH}/Tools/CmdLine/IccAnalyzer/IccAnalyzerLUT.cpp
  ${SRC_PATH}/Tools/CmdLine/IccAnalyzer/IccAnalyzerNinja.cpp
  ${SRC_PATH}/Tools/CmdLine/IccAnalyzer/IccAnalyzerComprehensive.cpp
  ${SRC_PATH}/Tools/CmdLine/IccAnalyzer/IccAnalyzerFingerprint.cpp
)

SET( TARGET_NAME iccAnalyzer )
ADD_EXECUTABLE( ${TARGET_NAME} ${SOURCES} )
TARGET_LINK_LIBRARIES( ${TARGET_NAME} ${TARGET_LIB_ICCPROFLIB} )
```

### Test Configuration
**Script**: `test_refactored_iccanalyzer.sh`  
**Purpose**: Functional regression testing  
**Coverage**: All 12 operational modes

### Fuzzer Integration
**Dictionary**: `fuzzers/specialized/iccanalyzer.dict` (if created)  
**Corpus**: Test against `corpus/` and `poc-archive/`

---

## Future Enhancements

### Phase A: Threat Scoring (Priority 0)
**Module**: IccAnalyzerSecurity.cpp

**Interface**:
```cpp
struct ThreatScoreResult {
  int score;              // 0-100 (0=benign, 100=malicious)
  const char* level;      // "BENIGN", "SUSPICIOUS", "MALICIOUS"
  int headerFlags;        // Bitmask of header anomalies
  int tagFlags;           // Bitmask of tag anomalies
  int nanCount;           // NaN values detected
  int oxffRuns;           // 0xFF pollution runs
  icInt64Number sizeDelta; // File size mismatch
};

int CalculateThreatScore(const char* filename, ThreatScoreResult* result);
const char* GetThreatLevel(int score);
```

**Usage**: `iccAnalyzer -ts profile.icc`

### Phase B: JSON Output (Priority 1)
**Module**: IccAnalyzerJSON (new module)

**Output Format**:
```json
{
  "profile": "test.icc",
  "mode": "comprehensive",
  "threat_score": 85,
  "threat_level": "MALICIOUS",
  "anomalies": {
    "nan_count": 78,
    "oxff_runs": 1,
    "size_mismatch": 1101,
    "null_vendor": true
  },
  "tags": [...],
  "heuristics": [...]
}
```

**Usage**: `iccAnalyzer -ts --json profile.icc > analysis.json`

### Phase C: Advanced Heuristics (Priority 2)
- Duplicate tag detection
- Tag overlap detection (buffer aliasing)
- CLUT dimension overflow prediction
- Recursive embedding detection

---

## References

### Primary Documentation
- `Tools/CmdLine/IccAnalyzer/Readme.md` - User documentation
- `Tools/CmdLine/IccAnalyzer/FINGERPRINT_MODE.md` - Fingerprint mode details
- `ICCANALYZER_REFACTORING_2026-01-29.md` - Refactoring rationale and metrics

### Related Documentation
- `.copilot-sessions/governance/BEST_PRACTICES.md` - General engineering standards
- `.copilot-sessions/governance/SECURITY_CONTROLS.md` - Security requirements
- `README.md` - Project overview
- `Build/Cmake/README.md` - Build system documentation

### External Resources
- ICC Specification: http://www.color.org/specification/ICC.1-2022-05.pdf
- IccProfLib API: `IccProfLib/` source code
- IEEE 754 (NaN detection): Floating-point arithmetic standard

---

## Version History

- **1.0** (2026-01-29): Initial governance framework for modular iccAnalyzer
