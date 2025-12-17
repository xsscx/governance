# Windows Visual Studio Version Queries

**Purpose:** Detect and query Visual Studio installations on Windows
**Platform:** Windows PowerShell
**Status:** Verified working
**Updated:** 2026-02-07

---

## Get Visual Studio Version String

### Query Latest Visual Studio Version

```powershell
& "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -products * -latest -property catalog_productDisplayVersion
```

**Output Format:**
```
17.8.3
```

**Use Case:** Get installed Visual Studio version number

**Properties:**
- `catalog_productDisplayVersion` - User-friendly version (e.g., "17.8.3")
- `catalog_productSemanticVersion` - Full semantic version (e.g., "17.8.3+34129.40")
- `installationVersion` - Installation version (e.g., "17.8.34129.40")

---

## Get devenv.exe Path

### Locate devenv.exe for Any Edition

```powershell
# Get the path to devenv.exe using vswhere (works for any edition)
$devenv = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -products * -latest -property productPath

Write-Host "devenv.exe path: $devenv" -ForegroundColor Cyan
```

**Output Format:**
```
devenv.exe path: C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe
```

**Use Case:** Locate Visual Studio IDE executable for command-line builds

**Editions Detected:**
- Community
- Professional
- Enterprise
- Build Tools

---

## Show Visual Studio Version Details

### Complete Version Information

```powershell
# Show the version number
$vsVersion = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" `
  -products * -latest -property catalog_productDisplayVersion
Write-Host "Visual Studio Version: $vsVersion" -ForegroundColor Green

# Show the version line from devenv /?
& $devenv /? | Select-String "Microsoft Visual Studio"

# Show file version from exe metadata
(Get-Item $devenv).VersionInfo.ProductVersion
```

**Output Format:**
```
Visual Studio Version: 17.8.3
Microsoft Visual Studio 2022 Version 17.8.3.
17.8.3
```

**Use Case:** Comprehensive version verification for build requirements

---

## Detect Visual Studio Installation

### Check if Visual Studio is Installed

```powershell
# Check if vswhere.exe exists
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

if (Test-Path $vswhere) {
    Write-Host "[OK] Visual Studio Installer found" -ForegroundColor Green
    
    # Get version
    $vsVersion = & $vswhere -products * -latest -property catalog_productDisplayVersion
    Write-Host "[OK] Visual Studio $vsVersion installed" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Visual Studio not found" -ForegroundColor Red
}
```

**Output Format:**
```
[OK] Visual Studio Installer found
[OK] Visual Studio 17.8.3 installed
```

**Use Case:** Pre-build dependency verification

---

## Query Visual Studio Properties

### Get All Available Properties

```powershell
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

# List all properties
& $vswhere -products * -latest -format json | ConvertFrom-Json | Format-List
```

**Key Properties:**
- `instanceId` - Unique installation ID
- `installDate` - Installation date
- `installationName` - Installation name (e.g., "VisualStudio/17.8.3+34129.40")
- `installationPath` - Installation directory
- `installationVersion` - Full version string
- `productId` - Product identifier (e.g., "Microsoft.VisualStudio.Product.Community")
- `productPath` - Path to devenv.exe
- `catalog_productDisplayVersion` - Display version (e.g., "17.8.3")
- `catalog_productSemanticVersion` - Semantic version
- `displayName` - User-friendly name (e.g., "Visual Studio Community 2022")

**Example Output:**
```
instanceId              : 12345678-1234-1234-1234-123456789012
installDate             : 01/15/2024 10:30:45
installationName        : VisualStudio/17.8.3+34129.40
installationPath        : C:\Program Files\Microsoft Visual Studio\2022\Community
installationVersion     : 17.8.34129.40
productId               : Microsoft.VisualStudio.Product.Community
productPath             : Common7\IDE\devenv.exe
catalog_productDisplayVersion : 17.8.3
displayName             : Visual Studio Community 2022
```

---

## Query Specific Visual Studio Components

### Check for C++ Build Tools

```powershell
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

# Check if C++ build tools are installed
$hasCpp = & $vswhere -products * -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64

if ($hasCpp) {
    Write-Host "[OK] C++ build tools installed" -ForegroundColor Green
    
    # Get installation path
    $vsPath = & $vswhere -products * -latest -property installationPath
    Write-Host "[INFO] Installation path: $vsPath" -ForegroundColor Cyan
} else {
    Write-Host "[FAIL] C++ build tools not installed" -ForegroundColor Red
}
```

**Common Components:**
- `Microsoft.VisualStudio.Component.VC.Tools.x86.x64` - MSVC C++ build tools
- `Microsoft.VisualStudio.Component.Windows10SDK` - Windows 10 SDK
- `Microsoft.VisualStudio.Component.VC.CMake.Project` - CMake tools
- `Microsoft.VisualStudio.Workload.NativeDesktop` - Desktop development with C++

---

## Get MSBuild Path

### Locate MSBuild.exe

```powershell
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

# Get Visual Studio installation path
$vsPath = & $vswhere -products * -latest -property installationPath

# Construct MSBuild path (VS 2017+)
$msbuild = Join-Path $vsPath "MSBuild\Current\Bin\MSBuild.exe"

if (Test-Path $msbuild) {
    Write-Host "[OK] MSBuild found: $msbuild" -ForegroundColor Green
    
    # Get MSBuild version
    & $msbuild /version | Select-Object -Last 1
} else {
    Write-Host "[FAIL] MSBuild not found at $msbuild" -ForegroundColor Red
}
```

**Output Format:**
```
[OK] MSBuild found: C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe
17.8.3+6e1dec7c8
```

**Use Case:** Locate MSBuild for command-line project builds

---

## Complete Visual Studio Detection Script

### Full Detection and Verification

```powershell
# Visual Studio detection and verification script

$ErrorActionPreference = "Continue"

Write-Host "==================================================================="
Write-Host "Visual Studio Detection and Verification"
Write-Host "==================================================================="
Write-Host ""

# 1. Check if vswhere exists
Write-Host "=== Step 1: Check vswhere.exe ==="
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

if (Test-Path $vswhere) {
    Write-Host "[OK] vswhere.exe found" -ForegroundColor Green
} else {
    Write-Host "[FAIL] vswhere.exe not found" -ForegroundColor Red
    Write-Host "[INFO] Visual Studio 2017+ not installed" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# 2. Get Visual Studio version
Write-Host "=== Step 2: Visual Studio Version ==="
$vsVersion = & $vswhere -products * -latest -property catalog_productDisplayVersion

if ($vsVersion) {
    Write-Host "[OK] Visual Studio Version: $vsVersion" -ForegroundColor Green
    
    # Get edition
    $vsEdition = & $vswhere -products * -latest -property displayName
    Write-Host "[INFO] Edition: $vsEdition" -ForegroundColor Cyan
    
    # Get installation path
    $vsPath = & $vswhere -products * -latest -property installationPath
    Write-Host "[INFO] Installation Path: $vsPath" -ForegroundColor Cyan
} else {
    Write-Host "[FAIL] Could not determine Visual Studio version" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 3. Check for devenv.exe
Write-Host "=== Step 3: Check devenv.exe ==="
$devenv = & $vswhere -products * -latest -property productPath

if (Test-Path $devenv) {
    Write-Host "[OK] devenv.exe found: $devenv" -ForegroundColor Green
    
    # Get file version
    $fileVersion = (Get-Item $devenv).VersionInfo.ProductVersion
    Write-Host "[INFO] File version: $fileVersion" -ForegroundColor Cyan
} else {
    Write-Host "[FAIL] devenv.exe not found" -ForegroundColor Red
}

Write-Host ""

# 4. Check for C++ build tools
Write-Host "=== Step 4: Check C++ Build Tools ==="
$cppPath = & $vswhere -products * -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath

if ($cppPath) {
    Write-Host "[OK] C++ build tools installed" -ForegroundColor Green
    
    # Check for specific components
    $cmake = & $vswhere -products * -latest -requires Microsoft.VisualStudio.Component.VC.CMake.Project -property installationPath
    if ($cmake) {
        Write-Host "[OK] CMake tools installed" -ForegroundColor Green
    } else {
        Write-Host "[WARN] CMake tools not installed" -ForegroundColor Yellow
    }
} else {
    Write-Host "[FAIL] C++ build tools not installed" -ForegroundColor Red
}

Write-Host ""

# 5. Check for MSBuild
Write-Host "=== Step 5: Check MSBuild ==="
$msbuild = Join-Path $vsPath "MSBuild\Current\Bin\MSBuild.exe"

if (Test-Path $msbuild) {
    Write-Host "[OK] MSBuild found: $msbuild" -ForegroundColor Green
    
    $msbuildVersion = & $msbuild /version /nologo | Select-Object -Last 1
    Write-Host "[INFO] MSBuild version: $msbuildVersion" -ForegroundColor Cyan
} else {
    Write-Host "[FAIL] MSBuild not found" -ForegroundColor Red
}

Write-Host ""

# 6. Summary
Write-Host "==================================================================="
Write-Host "Detection Complete"
Write-Host "==================================================================="
Write-Host ""
Write-Host "Visual Studio $vsVersion - $vsEdition" -ForegroundColor Green
Write-Host "Installation Path: $vsPath" -ForegroundColor Cyan
```

**Expected Output:**
```
===================================================================
Visual Studio Detection and Verification
===================================================================

=== Step 1: Check vswhere.exe ===
[OK] vswhere.exe found

=== Step 2: Visual Studio Version ===
[OK] Visual Studio Version: 17.8.3
[INFO] Edition: Visual Studio Community 2022
[INFO] Installation Path: C:\Program Files\Microsoft Visual Studio\2022\Community

=== Step 3: Check devenv.exe ===
[OK] devenv.exe found: C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe
[INFO] File version: 17.8.3

=== Step 4: Check C++ Build Tools ===
[OK] C++ build tools installed
[OK] CMake tools installed

=== Step 5: Check MSBuild ===
[OK] MSBuild found: C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe
[INFO] MSBuild version: 17.8.3+6e1dec7c8

===================================================================
Detection Complete
===================================================================

Visual Studio 17.8.3 - Visual Studio Community 2022
Installation Path: C:\Program Files\Microsoft Visual Studio\2022\Community
```

---

## Common Use Cases

### 1. Pre-Build Verification

```powershell
# Verify Visual Studio before starting build
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

if (-not (Test-Path $vswhere)) {
    Write-Host "[FAIL] Visual Studio not installed" -ForegroundColor Red
    exit 1
}

$vsVersion = & $vswhere -products * -latest -property catalog_productDisplayVersion
Write-Host "[OK] Visual Studio $vsVersion detected" -ForegroundColor Green

# Proceed with build
cmake -B build -G "Visual Studio 17 2022" -A x64
```

### 2. Find vcvarsall.bat for Environment Setup

```powershell
# Get Visual Studio installation path
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vsPath = & $vswhere -products * -latest -property installationPath

# Construct vcvarsall.bat path
$vcvarsall = Join-Path $vsPath "VC\Auxiliary\Build\vcvarsall.bat"

if (Test-Path $vcvarsall) {
    Write-Host "[OK] vcvarsall.bat: $vcvarsall" -ForegroundColor Green
    Write-Host "[INFO] Usage: cmd /k `"$vcvarsall`" x64" -ForegroundColor Cyan
} else {
    Write-Host "[FAIL] vcvarsall.bat not found" -ForegroundColor Red
}
```

### 3. Detect Multiple Visual Studio Installations

```powershell
# List all Visual Studio installations
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

Write-Host "=== All Visual Studio Installations ===" -ForegroundColor Cyan

& $vswhere -products * -format json | ConvertFrom-Json | ForEach-Object {
    $displayName = $_.displayName
    $version = $_.catalog.productDisplayVersion
    $path = $_.installationPath
    
    Write-Host ""
    Write-Host "Name: $displayName" -ForegroundColor Green
    Write-Host "Version: $version" -ForegroundColor Yellow
    Write-Host "Path: $path" -ForegroundColor Gray
}
```

---

## Troubleshooting

### Issue: "vswhere.exe not found"

**Cause:** Visual Studio 2017 or later not installed

**Solution:**
```powershell
# Download and install Visual Studio
# https://visualstudio.microsoft.com/downloads/

# Or install Build Tools only
# https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022
```

### Issue: "The term 'vswhere.exe' is not recognized"

**Cause:** Path not properly quoted or escaped

**Solution:**
```powershell
# Use full path with proper quoting
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
& $vswhere -products * -latest -property catalog_productDisplayVersion

# Not: vswhere.exe (won't work without PATH setup)
```

### Issue: "No Visual Studio installation found"

**Cause:** Visual Studio not installed or wrong edition

**Solution:**
```powershell
# Check if vswhere exists
Test-Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

# If True: Visual Studio installed but no instances
# Solution: Reinstall or repair Visual Studio

# If False: Visual Studio not installed
# Solution: Install Visual Studio 2017 or later
```

### Issue: "C++ build tools not found"

**Cause:** Visual Studio installed without C++ workload

**Solution:**
```powershell
# Launch Visual Studio Installer
Start-Process "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vs_installer.exe"

# Then modify installation and select:
# - Desktop development with C++
# - C++ CMake tools for Windows (optional)
# - Windows 10 SDK (optional)
```

---

## Related Heuristics

**H006: SUCCESS-DECLARATION-CHECKPOINT**
- Verify Visual Studio installed before claiming "VS detected"
- Use vswhere to test installation
- Check version matches requirements

**H013: PACKAGE-VERIFICATION**
- Verify Visual Studio before build: `Test-Path $vswhere`
- Check C++ tools installed: `-requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64`
- Verify MSBuild available

**H018: NUMERIC-CLAIM-VERIFICATION**
- Get actual version: `& $vswhere -property catalog_productDisplayVersion`
- Don't claim "VS 2022" without checking version
- Verify version meets minimum requirements

---

## Notes

**Why These Commands:**
- vswhere.exe is the official way to locate Visual Studio 2017+
- Works with all editions (Community, Professional, Enterprise, Build Tools)
- Returns structured data (JSON, XML, text)
- Supports querying specific components and workloads

**Common Pitfalls:**
- Using hardcoded paths (breaks with different editions)
- Not quoting path to vswhere.exe (fails with spaces)
- Claiming "Visual Studio installed" without version check
- Not verifying C++ build tools (VS can be installed without them)
- Confusing Visual Studio version (2022) with product version (17.x)

**Version Mappings:**
- Visual Studio 2022 = Version 17.x
- Visual Studio 2019 = Version 16.x
- Visual Studio 2017 = Version 15.x

**vswhere Documentation:**
- https://github.com/microsoft/vswhere

---

## Quick Reference

```powershell
# Get Visual Studio version
& "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -products * -latest -property catalog_productDisplayVersion

# Get devenv.exe path
& "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -products * -latest -property productPath

# Get installation path
& "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -products * -latest -property installationPath

# Check C++ tools
& "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -products * -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64

# Get all properties (JSON)
& "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -products * -latest -format json
```

---

**Status:** Active reference
**Platform:** Windows PowerShell
**Testing:** Verified with Visual Studio 2019, 2022 (Community, Professional, Enterprise)
