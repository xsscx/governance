# Governance: Tag Type Validation Pattern
**Updated:** 2026-01-30
**Version:** 1.1

## Critical Discovery: Tag Signature ≠ Tag Type

### Background

During fuzzer UAF fix (commit 007d580f), we discovered a critical distinction in ICC profile tag validation that was not previously documented in governance:

**ICC profiles use TWO identifiers for each tag:**

1. **Tag Signature** (in tag table at offset 132+)
   - Purpose: Identifies tag's ROLE in the profile
   - Examples: 'desc' (description), 'clrt' (colorant), 'wtpt' (white point)
   - Location: Tag table entry bytes 0-3
   - Used by: Applications for tag lookup

2. **Tag Type** (in tag data, first 4 bytes)
   - Purpose: Identifies tag's IMPLEMENTATION structure
   - Examples: 'text' (text), 'tary' (tag array), 'XYZ ' (XYZ)
   - Location: First 4 bytes of tag data at tag offset
   - Used by: Library for parsing tag structure

### The Vulnerability

**Previous (Incorrect) Validation:**
```cpp
// WRONG: Only checking tag signature
if (tagSignature == 0x74617279) {  // 'tary'
  // Reject TagArrayType
}
```

**Problem:**
- TagArrayType can appear under ANY signature
- A tag with signature 'desc' can have type 'tary'
- This mismatch triggers heap-use-after-free in CIccTagArray::Cleanup()

**Correct Validation:**
```cpp
// CORRECT: Check tag TYPE from data, not just signature
icUInt32Number tagType = ReadTypeFromTagData(tagOffset);
if (tagType == 0x74617279) {  // 'tary'
  // Reject TagArrayType regardless of signature
}
```

## Mandatory Validation Pattern

### For Fuzzer Code

When validating dangerous tag types in fuzzers:

```cpp
// 1. Read tag table
icUInt32Number tagCount;
pIO->Read32(&tagCount);

// 2. Iterate ALL tags
for (icUInt32Number i = 0; i < tagCount; i++) {
  IccTagEntry entry;
  pIO->ReadTagEntry(&entry);
  
  // 3. Save current position
  icPositionNumber curPos = pIO->Tell();
  
  // 4. Seek to tag data and read TYPE (not signature)
  pIO->Seek(entry.offset, icSeekSet);
  icUInt32Number tagType;
  pIO->Read32(&tagType);
  
  // 5. Check TYPE for dangerous values
  if (tagType == 0x74617279) {  // TagArrayType
    return false;  // REJECT
  }
  
  // 6. Restore position
  pIO->Seek(curPos, icSeekSet);
}
```

### For Security Tools (iccAnalyzer)

When validating profiles for security analysis:

```cpp
// 1. Re-open file for raw validation
FILE *fp = fopen(filename, "rb");

// 2. Read tag count from header
fseek(fp, 128, SEEK_SET);
icUInt8Number buf[4];
fread(buf, 1, 4, fp);
icUInt32Number tagCount = (buf[0]<<24) | (buf[1]<<16) | (buf[2]<<8) | buf[3];

// 3. Check each tag's TYPE
for (icUInt32Number i = 0; i < tagCount && i < 256; i++) {
  // Read tag entry (12 bytes at offset 132 + i*12)
  fseek(fp, 132 + i*12, SEEK_SET);
  icUInt8Number entry[12];
  fread(entry, 1, 12, fp);
  
  // Extract tag offset
  icUInt32Number tagOffset = (entry[4]<<24) | (entry[5]<<16) | 
                              (entry[6]<<8) | entry[7];
  
  // Read tag TYPE from data
  fseek(fp, tagOffset, SEEK_SET);
  icUInt8Number typeData[4];
  fread(typeData, 1, 4, fp);
  icUInt32Number tagType = (typeData[0]<<24) | (typeData[1]<<16) |
                            (typeData[2]<<8) | typeData[3];
  
  // Check for dangerous types
  if (tagType == 0x74617979) {  // TagArrayType
    // Report critical warning
  }
}

fclose(fp);
```

## Known Dangerous Tag Types

### TagArrayType (0x74617279 = 'tary')

**Vulnerability:**
- Location: IccProfLib/IccTagComposite.cpp:1514
- Function: CIccTagArray::Cleanup()
- Issue: Heap-use-after-free / double-free
- Severity: CRITICAL (code execution possible)

**Detection:**
- Check tag TYPE == 0x74617279
- Reject regardless of tag signature
- Implemented in:
  - fuzzers/icc_v5dspobs_fuzzer.cpp (lines 327-342, 510-525)
  - Tools/CmdLine/IccAnalyzer/IccAnalyzerSecurity.cpp (H14)
  - Tools/CmdLine/IccAnalyzer/IccAnalyzerNinja.cpp (tag table display)

**Status:** [OK] Detection implemented and tested

## Testing Requirements

### For Tag Type Validation

**Test Case 1: Detect Hidden Dangerous Type**
```
Create profile with:
- Tag signature: 'desc' (0x64657363)
- Tag type: 'tary' (0x74617979)
Expected: Detection triggers
```

**Test Case 2: No False Positives**
```
Test with clean profiles:
- Testing/Calc/*.icc
- Testing/Display/*.icc
Expected: No warnings on legitimate profiles
```

**Test Case 3: Multiple Dangerous Tags**
```
Create profile with:
- Tag 0: sig='desc', type='tary'
- Tag 1: sig='clrt', type='tary'
Expected: Both detected and counted
```

## Governance Rules

### RULE 1: Always Check Tag TYPE, Not Just Signature

**When:** Validating for security vulnerabilities
**Where:** Fuzzers, security tools, validation utilities
**How:** Read tag TYPE from tag data at tag offset
**Why:** Tag signature is application-level, tag type is implementation-level

### RULE 2: Raw File Validation for Security Checks

**Principle:** Don't trust library parsing for security validation

**Rationale:**
- Library may have bugs that allow dangerous tags to load
- Security tools must catch issues BEFORE library processing
- Raw validation provides defense-in-depth

**Implementation:**
- Re-open file with fopen() or similar
- Read tag table directly from bytes
- Validate tag TYPE at tag offset
- Report issues before calling library Read() functions

### RULE 3: Zero False Positives for Security Features

**Requirement:** Security warnings must be accurate

**Standards:**
- Test with clean profiles from Testing/ directory
- Verify 0% false positive rate
- Don't warn on legitimate ICC v4/v5 features
- Critical warnings only for actual threats

**Quality Gate:**
- All new security checks must pass false positive test
- Document expected behavior for edge cases
- Provide clear remediation guidance

### RULE 4: Fuzzer and Tool Consistency

**Principle:** Security tools must match fuzzer protections

**Requirements:**
- Same validation logic in fuzzers and tools
- Feature parity for known vulnerabilities
- Consistent warning messages and severity levels
- Synchronized updates when new threats discovered

**Example:**
- Fuzzer detects TagArrayType → Tool must also detect
- Fuzzer rejects enum value → Tool must also warn
- Fuzzer has OOM limit → Tool should have equivalent check

## Implementation Checklist

When adding tag type validation:

- [ ] Read tag TYPE from data, not just signature from table
- [ ] Check ALL tags (iterate through entire tag table)
- [ ] Validate tag offset is within file bounds
- [ ] Handle corrupted tag tables gracefully
- [ ] Create minimal POC that triggers detection
- [ ] Test with clean profiles (verify 0% false positives)
- [ ] Document expected behavior
- [ ] Add automated tests
- [ ] Update this governance document
- [ ] Synchronize fuzzers and tools

## References

### Code Locations

**Fuzzer Implementation:**
- `fuzzers/icc_v5dspobs_fuzzer.cpp:327-342` (display profile)
- `fuzzers/icc_v5dspobs_fuzzer.cpp:510-525` (observer profile)

**Tool Implementation:**
- `Tools/CmdLine/IccAnalyzer/IccAnalyzerSecurity.cpp` (H14 heuristic)
- `Tools/CmdLine/IccAnalyzer/IccAnalyzerNinja.cpp` (tag table display)

**Test Suite:**
- `test-iccanalyzer-tagarray.sh` (5 test cases)
- `test_tagarray_malicious.icc` (POC profile)

### Documentation

- `ICCANALYZER_TAGARRAY_UPDATE.md` - Implementation guide
- `FUZZER_FIXES_2026-01-30_UAF_SEGV.md` - Fuzzer UAF fix details
- `SESSION_2026-01-30_ICCANALYZER_TAGARRAY.md` - Session log

### Commits

- `007d580f` - Fix icc_v5dspobs_fuzzer heap-use-after-free
- `6dfec297` - Add TagArrayType detection to iccAnalyzer

## Version History

**v1.1 (2026-01-30)**
- Added Tag Type vs Signature validation pattern
- Documented TagArrayType vulnerability and detection
- Added testing requirements
- Added governance rules
- Initial version

---

**This is a living document. Update when new tag type vulnerabilities are discovered.**
