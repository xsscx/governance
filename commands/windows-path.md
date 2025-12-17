# Windows PATH Configuration

**Purpose:** Add ICC build executables to Windows PATH
**Platform:** Windows PowerShell
**Status:** Verified working
**Updated:** 2026-02-07

---

## Add ICC Build Executables to PATH

### Find and Add Build Directory Executables

Locates all ICC-related executables in `.\build\` and adds their directories to PATH.

```powershell
$exeDirs = Get-ChildItem -Recurse -File -Include *.exe -Path .\build\ |
    Where-Object { $_.FullName -match 'icc' -and $_.FullName -notmatch '\\CMakeFiles\\' -and $_.Name -notmatch '^CMake(C|CXX)CompilerId\.exe$' } |
    ForEach-Object { Split-Path $_.FullName -Parent } |
    Sort-Object -Unique
$env:PATH = ($exeDirs -join ';') + ';' + $env:PATH
```

**What It Does:**
1. Searches recursively in `.\build\` for `.exe` files
2. Filters to include only ICC-related executables (`-match 'icc'`)
3. Excludes CMake temporary files (`-notmatch '\\CMakeFiles\\' -and -notmatch 'CMake(C|CXX)CompilerId\.exe'`)
4. Extracts parent directory for each executable
5. Removes duplicates with `Sort-Object -Unique`
6. Prepends directories to PATH

**Example Directories Added:**
```
.\build\Tools\IccApplyNamedCmm
.\build\Tools\IccApplyProfiles
.\build\Tools\IccDumpProfile
.\build\IccXML\CmdLine\IccFromXml
.\build\IccXML\CmdLine\IccToXml
```

---

## Verify ICC Tools in PATH

Show which PATH entries contain "icc":

```powershell
$env:PATH -split ';' | Select-String "icc"
```

**Output Format:**
```
.\build\Tools\IccApplyNamedCmm
.\build\Tools\IccApplyProfiles
.\build\Tools\IccDumpProfile
.\build\IccXML\CmdLine\IccFromXml
.\build\IccXML\CmdLine\IccToXml
```

**Usage:**
```powershell
# After adding to PATH, verify tools are accessible
$env:PATH -split ';' | Select-String "icc" | Measure-Object | Select-Object -ExpandProperty Count
# Expected: 10+ directories

# Test tool availability
Get-Command IccDumpProfile
# Should return: CommandType: Application, Name: IccDumpProfile.exe
```

---

## Add Tools Directory to PATH

For development builds where executables are in `.\Tools\` source tree:

```powershell
$toolDirs = Get-ChildItem -Recurse -File -Include *.exe -Path .\Tools\ |
    ForEach-Object { Split-Path -Parent $_.FullName } |
    Sort-Object -Unique
$env:PATH = ($toolDirs -join ';') + ';' + $env:PATH
```

**What It Does:**
1. Searches recursively in `.\Tools\` for `.exe` files
2. Extracts parent directory for each executable
3. Removes duplicates
4. Prepends directories to PATH

**Use Case:** Development environment where tools are built in-place

---

## Show All PATH Entries

Display entire PATH for verification:

```powershell
$env:PATH -split ';'
```

**Output:** List of all directories in PATH (one per line)

**Usage:**
```powershell
# Count total PATH entries
($env:PATH -split ';').Count

# Show last 10 entries added
($env:PATH -split ';')[0..9]

# Find specific tool
$env:PATH -split ';' | Select-String "IccDumpProfile"
```

---

## Show Current Working Directory

Verify you're in correct repository location:

```powershell
pwd
```

**Output Format:**
```
Path
----
C:\Users\username\iccLibFuzzer
```

---

## Complete Setup Script

Combined script for full PATH configuration:

```powershell
# 1. Verify location
pwd

# 2. Add build executables to PATH
$exeDirs = Get-ChildItem -Recurse -File -Include *.exe -Path .\build\ |
    Where-Object { $_.FullName -match 'icc' -and $_.FullName -notmatch '\\CMakeFiles\\' -and $_.Name -notmatch '^CMake(C|CXX)CompilerId\.exe$' } |
    ForEach-Object { Split-Path $_.FullName -Parent } |
    Sort-Object -Unique
$env:PATH = ($exeDirs -join ';') + ';' + $env:PATH

# 3. Verify ICC tools in PATH
Write-Host "[INFO] ICC directories in PATH:"
$env:PATH -split ';' | Select-String "icc"

# 4. Optional: Add Tools directory (development builds)
# $toolDirs = Get-ChildItem -Recurse -File -Include *.exe -Path .\Tools\ |
#     ForEach-Object { Split-Path -Parent $_.FullName } |
#     Sort-Object -Unique
# $env:PATH = ($toolDirs -join ';') + ';' + $env:PATH

# 5. Count total ICC directories
$iccCount = ($env:PATH -split ';' | Select-String "icc").Count
Write-Host "[OK] $iccCount ICC directories added to PATH"

# 6. Test tool availability
$testTools = @('IccDumpProfile', 'IccFromXml', 'IccToXml', 'IccApplyNamedCmm')
foreach ($tool in $testTools) {
    if (Get-Command $tool -ErrorAction SilentlyContinue) {
        Write-Host "[OK] $tool available"
    } else {
        Write-Host "[FAIL] $tool not found"
    }
}
```

**Expected Output:**
```
[INFO] ICC directories in PATH:
.\build\Tools\IccApplyNamedCmm
.\build\Tools\IccApplyProfiles
.\build\Tools\IccDumpProfile
...
[OK] 12 ICC directories added to PATH
[OK] IccDumpProfile available
[OK] IccFromXml available
[OK] IccToXml available
[OK] IccApplyNamedCmm available
```

---

## Cross-Platform Equivalent

### Unix/Linux/macOS (Bash/Zsh)

```bash
# Add build executables to PATH
export PATH="$(find ./build -type f -perm -111 -name "*icc*" ! -path "*/CMakeFiles/*" -exec dirname {} \; | sort -u | tr '\n' ':')$PATH"

# Verify
echo $PATH | tr ':' '\n' | grep icc

# Show current directory
pwd

# Test tool availability
which IccDumpProfile IccFromXml IccToXml IccApplyNamedCmm
```

---

## Common Use Cases

### 1. Post-Build PATH Configuration

After building iccDEV project, add tools to PATH:

```powershell
cd C:\iccLibFuzzer
$exeDirs = Get-ChildItem -Recurse -File -Include *.exe -Path .\build\ |
    Where-Object { $_.FullName -match 'icc' -and $_.FullName -notmatch '\\CMakeFiles\\' } |
    ForEach-Object { Split-Path $_.FullName -Parent } |
    Sort-Object -Unique
$env:PATH = ($exeDirs -join ';') + ';' + $env:PATH
```

### 2. Verify Tool Accessibility

Check if tools can be executed without full path:

```powershell
# Before PATH modification
Get-Command IccDumpProfile
# Error: The term 'IccDumpProfile' is not recognized

# After PATH modification
Get-Command IccDumpProfile
# Success: CommandType: Application, Name: IccDumpProfile.exe
```

### 3. Session-Persistent PATH (User Profile)

Add to PowerShell profile for permanent PATH:

```powershell
# Edit profile
notepad $PROFILE

# Add to profile:
$iccBuildPath = "C:\iccLibFuzzer\build"
$exeDirs = Get-ChildItem -Recurse -File -Include *.exe -Path $iccBuildPath |
    Where-Object { $_.FullName -match 'icc' -and $_.FullName -notmatch '\\CMakeFiles\\' } |
    ForEach-Object { Split-Path $_.FullName -Parent } |
    Sort-Object -Unique
$env:PATH = ($exeDirs -join ';') + ';' + $env:PATH
```

---

## Troubleshooting

### Issue: "Get-Command: Cannot find path"

**Cause:** Executables not built yet or wrong directory

**Solution:**
```powershell
# Verify build directory exists
Test-Path .\build\
# Expected: True

# Count executables in build
(Get-ChildItem -Recurse -File -Include *.exe -Path .\build\ | 
    Where-Object { $_.FullName -match 'icc' }).Count
# Expected: 15+ executables
```

### Issue: "CMake compiler ID executables in PATH"

**Cause:** Filter not excluding CMake temporary files

**Solution:**
```powershell
# Use stricter filter
$exeDirs = Get-ChildItem -Recurse -File -Include *.exe -Path .\build\ |
    Where-Object { 
        $_.FullName -match 'icc' -and 
        $_.FullName -notmatch '\\CMakeFiles\\' -and 
        $_.Name -notmatch '^CMake(C|CXX)CompilerId\.exe$' 
    } | ForEach-Object { Split-Path $_.FullName -Parent } | Sort-Object -Unique
```

### Issue: "Too many directories in PATH"

**Cause:** Multiple executions appending duplicates

**Solution:**
```powershell
# Clear and rebuild PATH
$env:PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine")

# Then add ICC directories once
$exeDirs = Get-ChildItem -Recurse -File -Include *.exe -Path .\build\ |
    Where-Object { $_.FullName -match 'icc' -and $_.FullName -notmatch '\\CMakeFiles\\' } |
    ForEach-Object { Split-Path $_.FullName -Parent } |
    Sort-Object -Unique
$env:PATH = ($exeDirs -join ';') + ';' + $env:PATH
```

---

## Related Heuristics

**H006: SUCCESS-DECLARATION-CHECKPOINT**
- Verify tools are in PATH before claiming "PATH configured"
- Use `Get-Command <tool>` to test availability

**H018: NUMERIC-CLAIM-VERIFICATION**
- Count actual directories added: `($env:PATH -split ';' | Select-String "icc").Count`
- Don't claim "N tools added" without counting

---

## Notes

**Why These Commands:**
- Filters out CMake temporary files (CMakeFiles, CMake*CompilerId.exe)
- Uses `-Unique` to prevent duplicate PATH entries
- Matches only ICC-related executables
- Prepends to PATH (takes precedence over system tools)

**Common Pitfalls:**
- Running multiple times creates duplicate PATH entries
- Forgetting to exclude CMakeFiles directory
- Not verifying tools are accessible after PATH modification
- Claiming success without testing `Get-Command <tool>`

**Session Scope:**
- PATH modifications are session-local (lost when closing PowerShell)
- For permanent PATH, modify system environment or user profile

---

**Status:** Active reference
**Platform:** Windows PowerShell 5.1+
**Testing:** Verified on Windows 10/11
