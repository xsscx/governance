# CJF-13 Example: icc_dump_fuzzer Heap Buffer Overflow

**Date**: 2026-01-30  
**Fuzzer**: icc_dump_fuzzer  
**Crash**: `crash-fed96cb327b8fd993eccdef28374456a9d064ebe`

---

## Fuzzer Crash

```
==2443==ERROR: AddressSanitizer: heap-buffer-overflow
READ of size 117 at 0x51000006eefe
#0 strlen
#1 CIccTagColorantTable::Describe() IccTagBasic.cpp:8931
```

**Exit**: ABRT (fuzzer aborts)

---

## Tool Test (CJF-13 Verification)

```bash
$ ./Build/Tools/IccDumpProfile/iccDumpProfile crash-fed96cb327b8fd993eccdef28374456a9d064ebe
Profile: 'crash-fed96cb327b8fd993eccdef28374456a9d064ebe'
[... displays profile successfully ...]
EXIT 0
```

**Exit**: 0 (SUCCESS)

---

## Root Cause Analysis

### Library Code (IccTagBasic.cpp:8931)
```cpp
for (i=0; i<m_nCount; i++) {
  nLen = (icUInt32Number)strlen(m_pData[i].name);  // ← Line 8931
  if (nLen>nMaxLen)
    nMaxLen =nLen;
}
```

**Issue**: `m_pData[i].name` is not null-terminated in malicious input

### Tool Behavior (IccDumpProfile)
- Parses profile header
- Displays tag table  
- **Does NOT call** `Describe()` on tags
- Exits successfully

### Fuzzer Behavior (icc_dump_fuzzer)
- Parses profile
- **Calls** `tag->Describe()` on all tags (including ColorantTable)
- `Describe()` calls `strlen()` on non-null-terminated data
- Heap-buffer-overflow → ABRT

---

## CJF-13 Classification

**Fuzzer crashes**: YES (heap-buffer-overflow, ABRT)  
**Tool crashes**: NO (exit 0)

**Classification**: **FUZZER FIDELITY ISSUE**

Fuzzer exercises code path (`Describe()`) that tools don't use.

---

## Fix Location

### [FAIL] DO NOT fix library code

Reasons:
1. IccDumpProfile doesn't crash (tool works correctly)
2. `Describe()` is debug/diagnostic function (not production)
3. No production tool calls `Describe()` on malicious input
4. Library assumes validated input for `Describe()`

### [OK] Fix fuzzer

**Option 1**: Don't call `Describe()` on untrusted input
```cpp
// REMOVE or guard:
// tag->Describe(description, verbosity);
```

**Option 2**: Validate input before `Describe()`
```cpp
if (tag->GetType() == icSigColorantTableType) {
  CIccTagColorantTable* pColorant = (CIccTagColorantTable*)tag;
  // Validate all names are null-terminated
  for (icUInt32Number i = 0; i < pColorant->m_nCount; i++) {
    size_t name_len = strnlen(pColorant->m_pData[i].name, 32);
    if (name_len >= 32) {
      // Not null-terminated, skip Describe()
      continue;
    }
  }
}
tag->Describe(description, verbosity);
```

**Option 3**: Use `strnlen()` in library (safer but not necessary)
```cpp
// In IccTagBasic.cpp:8931
nLen = (icUInt32Number)strnlen(m_pData[i].name, 32);  // Safe bounds
```

---

## Recommended Action

**Fix fuzzer**: Stop calling `Describe()` or validate input first

Fuzzer should test production code paths, not debug functions.

---

## Governance Rule Confirmed

**CJF-13**: Tool behavior is authoritative

- Tool exit 0 → Not a production bug
- Fuzzer ABRT → Fuzzer exercising non-production code
- Classify as: **Fuzzer needs fixing, not library**

---

**Do NOT document as library vulnerability.**
