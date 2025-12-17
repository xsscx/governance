# LLMCJF Commands - Known Good and Working

**Purpose:** Verified commands for common operations
**Status:** Reference library for reliable execution
**Updated:** 2026-02-07

---

## Find Unix Binaries and Generate SHA256

### Find Unix Binaries (Recent 24 Hours)

Finds executables, static libraries (.a), shared libraries (.so, .dylib) modified in last 24 hours.

```bash
find . -type f \( -perm -111 -o -name "*.a" -o -name "*.so" -o -name "*.dylib" \) \
  -mmin -1440 \
  ! -path "*/.git/*" \
  ! -path "*/CMakeFiles/*" \
  ! -name "*.sh" \
  -print
```

**Parameters:**
- `-type f` - Files only
- `-perm -111` - Executable permission (any execute bit set)
- `-name "*.a"` - Static libraries
- `-name "*.so"` - Shared libraries (Linux)
- `-name "*.dylib"` - Dynamic libraries (macOS)
- `-mmin -1440` - Modified in last 1440 minutes (24 hours)
- `! -path "*/.git/*"` - Exclude .git directory
- `! -path "*/CMakeFiles/*"` - Exclude CMake build artifacts
- `! -name "*.sh"` - Exclude shell scripts

**Output:** List of binary file paths

### Generate SHA256 for Found Binaries

```bash
find . -type f \( -perm -111 -o -name "*.a" -o -name "*.so" -o -name "*.dylib" \) \
  -mmin -1440 \
  ! -path "*/.git/*" \
  ! -path "*/CMakeFiles/*" \
  ! -name "*.sh" \
  -print | xargs sha256sum
```

**Output Format:**
```
a1b2c3d4e5f6...  ./Build/Tools/IccApplyNamedCmm/iccApplyNamedCmm
f7e8d9c0b1a2...  ./Build/IccProfLib/libIccProfLib2.a
```

**Usage:**
```bash
# Save to file for verification
find . -type f \( -perm -111 -o -name "*.a" -o -name "*.so" -o -name "*.dylib" \) \
  -mmin -1440 ! -path "*/.git/*" ! -path "*/CMakeFiles/*" ! -name "*.sh" \
  -print | xargs sha256sum > build-checksums.txt

# Verify later
sha256sum -c build-checksums.txt
```

---

## Find Windows Binaries and Generate SHA256

### PowerShell: Find and Hash Binaries (Recent 24 Hours)

```powershell
Get-ChildItem -Path ".\build" -Recurse -File | 
  Where-Object { 
    ($_.Extension -in '.exe','.dll','.lib','.a','.so','.dylib') -and 
    ($_.LastWriteTime -gt (Get-Date).AddMinutes(-1440)) -and 
    ($_.FullName -notmatch '\.git|CMakeFiles') -and 
    ($_.Extension -ne '.sh') 
  } | 
  ForEach-Object { 
    "$((Get-FileHash $_.FullName -Algorithm SHA256).Hash)  $($_.FullName)" 
  }
```

**Parameters:**
- `-Path ".\build"` - Search in build directory
- `-Recurse` - Search subdirectories
- `-File` - Files only
- `Extension -in '.exe','.dll','.lib','.a','.so','.dylib'` - Binary extensions
- `LastWriteTime -gt (Get-Date).AddMinutes(-1440)` - Last 24 hours
- `FullName -notmatch '\.git|CMakeFiles'` - Exclude patterns
- `Get-FileHash -Algorithm SHA256` - Generate SHA256 hash

**Output Format:**
```
A1B2C3D4E5F6...  .\build\Tools\IccApplyNamedCmm\iccApplyNamedCmm.exe
F7E8D9C0B1A2...  .\build\IccProfLib\IccProfLib2.lib
```

**Usage:**
```powershell
# Save to file for verification
Get-ChildItem -Path ".\build" -Recurse -File | 
  Where-Object { 
    ($_.Extension -in '.exe','.dll','.lib','.a','.so','.dylib') -and 
    ($_.LastWriteTime -gt (Get-Date).AddMinutes(-1440)) -and 
    ($_.FullName -notmatch '\.git|CMakeFiles') 
  } | 
  ForEach-Object { 
    "$((Get-FileHash $_.FullName -Algorithm SHA256).Hash)  $($_.FullName)" 
  } | Out-File -FilePath build-checksums.txt

# Verify later (PowerShell)
Get-Content build-checksums.txt | ForEach-Object {
  $hash, $file = $_ -split '  '
  $actual = (Get-FileHash $file -Algorithm SHA256).Hash
  if ($actual -eq $hash) { "[OK] $file" } else { "[FAIL] $file" }
}
```

---

## Cross-Platform Comparison

| Feature | Unix/Linux | Windows PowerShell |
|---------|------------|-------------------|
| Search scope | Current directory (.) | Specific path (.\build) |
| Time filter | -mmin -1440 | LastWriteTime -gt (Get-Date).AddMinutes(-1440) |
| Exclude .git | ! -path "*/.git/*" | FullName -notmatch '\.git' |
| Exclude CMake | ! -path "*/CMakeFiles/*" | FullName -notmatch 'CMakeFiles' |
| Hash command | sha256sum | Get-FileHash -Algorithm SHA256 |
| Output format | hash  path | Hash  Path |

---

## Common Use Cases

### 1. Build Verification

After building, verify all binaries were created:

```bash
# Unix
count=$(find . -type f -perm -111 -mmin -30 ! -path "*/.git/*" | wc -l)
echo "Built $count executables in last 30 minutes"

# Windows
$count = (Get-ChildItem -Path ".\build" -Recurse -File | 
  Where-Object { $_.Extension -in '.exe','.dll' -and 
  $_.LastWriteTime -gt (Get-Date).AddMinutes(-30) }).Count
Write-Host "Built $count executables in last 30 minutes"
```

### 2. Pre-Distribution Checksums

Generate checksums before packaging:

```bash
# Unix
find . -type f \( -perm -111 -o -name "*.a" -o -name "*.so" \) \
  ! -path "*/.git/*" ! -path "*/CMakeFiles/*" \
  -print | xargs sha256sum | tee CHECKSUMS.txt
```

### 3. Post-Build Artifact Inventory

List all build artifacts with metadata:

```bash
# Unix
find . -type f \( -perm -111 -o -name "*.a" -o -name "*.so" \) \
  -mmin -60 ! -path "*/.git/*" \
  -printf "%T@ %s %p\n" | sort -n
# Output: timestamp size path
```

---

## Verification Protocol

### Before Claiming "Build Success"

```bash
# 1. Count binaries built
count=$(find . -type f -perm -111 -mmin -30 ! -path "*/.git/*" | wc -l)

# 2. Generate checksums
find . -type f -perm -111 -mmin -30 ! -path "*/.git/*" \
  -print | xargs sha256sum > build-checksums-$(date +%Y%m%d-%H%M%S).txt

# 3. Verify count matches expected
expected=16
if [ $count -eq $expected ]; then
  echo "[OK] Built $count binaries (expected $expected)"
else
  echo "[FAIL] Built $count binaries (expected $expected)"
fi
```

**Related Heuristics:**
- H006: SUCCESS-DECLARATION-CHECKPOINT (verify before claiming)
- H018: NUMERIC-CLAIM-VERIFICATION (count actual vs claimed)
- H019: LOGS-FIRST-PROTOCOL (check build logs before claiming)

---

## Notes

**Why These Commands:**
- Tested and verified on multiple platforms
- Exclude common false positives (.git, CMakeFiles, .sh)
- Time-based filtering reduces noise
- SHA256 for cryptographic verification

**Common Pitfalls:**
- Don't claim "N binaries built" without running count command
- Don't trust cmake output alone (verify filesystem)
- Don't skip checksum generation (prevents V027-style data loss detection)

**References:**
- violations/V021_FALSE_FUZZER_SUCCESS_2026-02-05.md (claimed build without verification)
- violations/V027_DATA_LOSS_DICTIONARY_OVERWRITE_2026-02-06.md (90% false metrics)
- heuristics/H018_NUMERIC_CLAIM_VERIFICATION.md

---

**Status:** Active reference
**Maintenance:** Add new commands as verified
**Testing:** All commands tested on Linux and Windows
