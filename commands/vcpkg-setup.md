# vcpkg Setup and Integration

**Purpose:** Install and configure vcpkg C++ package manager
**Platform:** Cross-platform (Windows, Linux, macOS)
**Status:** Verified working
**Updated:** 2026-02-07

---

## Clone vcpkg and Bootstrap (Windows)

### Initial Setup

```powershell
# Clone vcpkg repository
git clone https://github.com/microsoft/vcpkg.git
cd vcpkg

# Bootstrap vcpkg (disable telemetry)
.\bootstrap-vcpkg.bat -disableMetrics

# Integrate with Visual Studio / MSBuild
.\vcpkg.exe integrate install
```

**What It Does:**
1. Clones vcpkg repository from GitHub
2. Runs bootstrap script to compile vcpkg executable
3. Disables telemetry with `-disableMetrics` flag
4. Integrates vcpkg with Visual Studio and MSBuild (system-wide)

**Expected Output:**
```
Downloading vcpkg-glibc...
Building vcpkg.exe...
vcpkg package management program version 2024.01.12

Applied user-wide integration for this vcpkg root.
All MSBuild C++ projects can now #include any installed libraries.
```

**Integration Result:**
- vcpkg packages automatically available in Visual Studio projects
- No need to specify include paths or library paths manually
- CMake integration enabled

---

## Clone vcpkg and Bootstrap (Unix/Linux/macOS)

### Initial Setup

```bash
# Clone vcpkg repository
git clone https://github.com/microsoft/vcpkg.git
cd vcpkg

# Bootstrap vcpkg (disable telemetry)
./bootstrap-vcpkg.sh -disableMetrics

# Optional: Add to PATH for convenience
echo "export PATH=\"$(pwd):\$PATH\"" >> ~/.bashrc
source ~/.bashrc
```

**What It Does:**
1. Clones vcpkg repository from GitHub
2. Runs bootstrap script to compile vcpkg binary
3. Disables telemetry with `-disableMetrics` flag
4. Optionally adds vcpkg to PATH for system-wide access

**Expected Output:**
```
Downloading vcpkg-glibc...
Building vcpkg...
vcpkg package management program version 2024.01.12

vcpkg successfully installed
```

**System Requirements:**
- Git
- CMake (version 3.10 or higher)
- C++ compiler (GCC, Clang, or MSVC)
- curl or wget
- tar (Unix/Linux)
- zip/unzip

---

## Verify vcpkg Installation

### Windows

```powershell
# Verify vcpkg executable
.\vcpkg.exe version

# Check integration status
.\vcpkg.exe integrate project

# List installed packages
.\vcpkg.exe list
```

**Expected Output:**
```
vcpkg package management program version 2024.01.12-unknownhash

CMake projects should use: "-DCMAKE_TOOLCHAIN_FILE=C:/path/to/vcpkg/scripts/buildsystems/vcpkg.cmake"

No packages are installed. To install a package, run `vcpkg install <package-name>`.
```

### Unix/Linux/macOS

```bash
# Verify vcpkg binary
./vcpkg version

# List installed packages
./vcpkg list

# Search for packages
./vcpkg search <package-name>
```

**Expected Output:**
```
vcpkg package management program version 2024.01.12-unknownhash

No packages are installed. To install a package, run `vcpkg install <package-name>`.
```

---

## Install Packages

### Install iccDEV Dependencies

```bash
# Windows
.\vcpkg.exe install libxml2:x64-windows libtiff:x64-windows libpng:x64-windows libjpeg-turbo:x64-windows wxwidgets:x64-windows nlohmann-json:x64-windows

# Unix/Linux
./vcpkg install libxml2 libtiff libpng libjpeg-turbo wxwidgets nlohmann-json

# macOS
./vcpkg install libxml2 libtiff libpng libjpeg-turbo wxwidgets nlohmann-json
```

**Triplets (Windows):**
- `x64-windows` - 64-bit Windows, dynamic linking
- `x86-windows` - 32-bit Windows, dynamic linking
- `x64-windows-static` - 64-bit Windows, static linking

**Triplets (Unix/Linux/macOS):**
- Default triplet is automatically selected based on platform
- `x64-linux` - 64-bit Linux
- `x64-osx` - 64-bit macOS
- `arm64-osx` - ARM64 macOS (Apple Silicon)

---

## CMake Integration

### Configure CMake with vcpkg

```bash
# Windows
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=C:/path/to/vcpkg/scripts/buildsystems/vcpkg.cmake

# Unix/Linux/macOS
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=/path/to/vcpkg/scripts/buildsystems/vcpkg.cmake
```

**Automatic Integration (after vcpkg integrate install on Windows):**
```bash
# No need to specify toolchain file on Windows after integration
cmake -B build -S .
```

**Environment Variable (Alternative):**
```bash
# Set once per session
export CMAKE_TOOLCHAIN_FILE=/path/to/vcpkg/scripts/buildsystems/vcpkg.cmake

# Then use cmake normally
cmake -B build -S .
```

---

## Complete Setup Script

### Windows (PowerShell)

```powershell
# vcpkg setup script for Windows
# Run in directory where you want vcpkg installed

$ErrorActionPreference = "Stop"

Write-Host "=== vcpkg Setup for Windows ==="
Write-Host ""

# 1. Check prerequisites
Write-Host "=== Step 1: Check Prerequisites ==="
$prereq_ok = $true

if (Get-Command git -ErrorAction SilentlyContinue) {
    $git_version = git --version
    Write-Host "[OK] Git: $git_version"
} else {
    Write-Host "[FAIL] Git not found"
    $prereq_ok = $false
}

if (Get-Command cmake -ErrorAction SilentlyContinue) {
    $cmake_version = cmake --version | Select-Object -First 1
    Write-Host "[OK] CMake: $cmake_version"
} else {
    Write-Host "[FAIL] CMake not found"
    $prereq_ok = $false
}

if (-not $prereq_ok) {
    Write-Host ""
    Write-Host "[FAIL] Missing prerequisites"
    exit 1
}

Write-Host ""

# 2. Clone vcpkg
Write-Host "=== Step 2: Clone vcpkg ==="
if (Test-Path "vcpkg") {
    Write-Host "[WARN] vcpkg directory already exists"
    cd vcpkg
    git pull
} else {
    git clone https://github.com/microsoft/vcpkg.git
    cd vcpkg
    Write-Host "[OK] Cloned vcpkg repository"
}

Write-Host ""

# 3. Bootstrap
Write-Host "=== Step 3: Bootstrap vcpkg ==="
if (Test-Path "vcpkg.exe") {
    Write-Host "[WARN] vcpkg.exe already exists"
} else {
    .\bootstrap-vcpkg.bat -disableMetrics
    Write-Host "[OK] Bootstrap complete"
}

Write-Host ""

# 4. Integrate
Write-Host "=== Step 4: Integrate with Visual Studio ==="
.\vcpkg.exe integrate install
Write-Host ""

# 5. Verify
Write-Host "=== Step 5: Verify Installation ==="
$vcpkg_version = .\vcpkg.exe version
Write-Host "[OK] vcpkg version: $vcpkg_version"

Write-Host ""
Write-Host "=== Setup Complete ==="
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Install packages: .\vcpkg.exe install <package-name>"
Write-Host "2. List packages: .\vcpkg.exe search <query>"
Write-Host "3. CMake: Use -DCMAKE_TOOLCHAIN_FILE=$(pwd)\scripts\buildsystems\vcpkg.cmake"
```

**Expected Output:**
```
=== vcpkg Setup for Windows ===

=== Step 1: Check Prerequisites ===
[OK] Git: git version 2.42.0.windows.1
[OK] CMake: cmake version 3.28.0

=== Step 2: Clone vcpkg ===
[OK] Cloned vcpkg repository

=== Step 3: Bootstrap vcpkg ===
[OK] Bootstrap complete

=== Step 4: Integrate with Visual Studio ===
Applied user-wide integration for this vcpkg root.

=== Step 5: Verify Installation ===
[OK] vcpkg version: vcpkg package management program version 2024.01.12

=== Setup Complete ===

Next steps:
1. Install packages: .\vcpkg.exe install <package-name>
2. List packages: .\vcpkg.exe search <query>
3. CMake: Use -DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake
```

### Unix/Linux/macOS (Bash)

```bash
#!/bin/bash

# vcpkg setup script for Unix/Linux/macOS
# Run in directory where you want vcpkg installed

set -e

echo "==================================================================="
echo "vcpkg Setup for Unix/Linux/macOS"
echo "==================================================================="
echo ""

# 1. Check prerequisites
echo "=== Step 1: Check Prerequisites ==="
prereq_ok=true

if command -v git > /dev/null; then
  git_version=$(git --version)
  echo "[OK] Git: $git_version"
else
  echo "[FAIL] Git not found"
  prereq_ok=false
fi

if command -v cmake > /dev/null; then
  cmake_version=$(cmake --version | head -1)
  echo "[OK] CMake: $cmake_version"
else
  echo "[FAIL] CMake not found"
  prereq_ok=false
fi

if command -v g++ > /dev/null || command -v clang++ > /dev/null; then
  if command -v g++ > /dev/null; then
    compiler_version=$(g++ --version | head -1)
    echo "[OK] Compiler: $compiler_version"
  else
    compiler_version=$(clang++ --version | head -1)
    echo "[OK] Compiler: $compiler_version"
  fi
else
  echo "[FAIL] C++ compiler not found (g++ or clang++)"
  prereq_ok=false
fi

if [ "$prereq_ok" = false ]; then
  echo ""
  echo "[FAIL] Missing prerequisites"
  exit 1
fi

echo ""

# 2. Clone vcpkg
echo "=== Step 2: Clone vcpkg ==="
if [ -d "vcpkg" ]; then
  echo "[WARN] vcpkg directory already exists"
  cd vcpkg
  git pull
else
  git clone https://github.com/microsoft/vcpkg.git
  cd vcpkg
  echo "[OK] Cloned vcpkg repository"
fi

echo ""

# 3. Bootstrap
echo "=== Step 3: Bootstrap vcpkg ==="
if [ -f "vcpkg" ]; then
  echo "[WARN] vcpkg binary already exists"
else
  ./bootstrap-vcpkg.sh -disableMetrics
  echo "[OK] Bootstrap complete"
fi

echo ""

# 4. Verify
echo "=== Step 4: Verify Installation ==="
vcpkg_version=$(./vcpkg version)
echo "[OK] vcpkg version: $vcpkg_version"

# 5. Get toolchain file path
vcpkg_root=$(pwd)
toolchain_file="$vcpkg_root/scripts/buildsystems/vcpkg.cmake"

echo ""
echo "==================================================================="
echo "Setup Complete"
echo "==================================================================="
echo ""
echo "Next steps:"
echo "1. Install packages: ./vcpkg install <package-name>"
echo "2. Search packages: ./vcpkg search <query>"
echo "3. CMake: Use -DCMAKE_TOOLCHAIN_FILE=$toolchain_file"
echo ""
echo "Optional: Add to PATH"
echo "  echo 'export PATH=\"$vcpkg_root:\$PATH\"' >> ~/.bashrc"
echo "  source ~/.bashrc"
```

**Expected Output:**
```
===================================================================
vcpkg Setup for Unix/Linux/macOS
===================================================================

=== Step 1: Check Prerequisites ===
[OK] Git: git version 2.34.1
[OK] CMake: cmake version 3.22.1
[OK] Compiler: g++ (GCC) 11.4.0

=== Step 2: Clone vcpkg ===
[OK] Cloned vcpkg repository

=== Step 3: Bootstrap vcpkg ===
[OK] Bootstrap complete

=== Step 4: Verify Installation ===
[OK] vcpkg version: vcpkg package management program version 2024.01.12

===================================================================
Setup Complete
===================================================================

Next steps:
1. Install packages: ./vcpkg install <package-name>
2. Search packages: ./vcpkg search <query>
3. CMake: Use -DCMAKE_TOOLCHAIN_FILE=/home/user/vcpkg/scripts/buildsystems/vcpkg.cmake

Optional: Add to PATH
  echo 'export PATH="/home/user/vcpkg:$PATH"' >> ~/.bashrc
  source ~/.bashrc
```

---

## Common Use Cases

### 1. Install iccDEV Dependencies

```bash
# Clone and bootstrap vcpkg (if not done)
git clone https://github.com/microsoft/vcpkg.git && cd vcpkg
./bootstrap-vcpkg.sh -disableMetrics

# Install all dependencies
./vcpkg install libxml2 libtiff libpng libjpeg-turbo wxwidgets nlohmann-json

# Configure iccDEV with vcpkg
cd /path/to/iccLibFuzzer
cmake -B Build -S Build/Cmake -DCMAKE_TOOLCHAIN_FILE=/path/to/vcpkg/scripts/buildsystems/vcpkg.cmake
```

### 2. Update vcpkg and Packages

```bash
cd vcpkg

# Update vcpkg itself
git pull

# Rebuild vcpkg binary
./bootstrap-vcpkg.sh -disableMetrics

# Update all installed packages
./vcpkg upgrade --no-dry-run
```

### 3. List and Search Packages

```bash
# List installed packages
./vcpkg list

# Search for packages
./vcpkg search libxml
./vcpkg search json

# Get package info
./vcpkg search nlohmann-json --x-full-desc
```

---

## Troubleshooting

### Issue: "bootstrap-vcpkg.bat not found"

**Cause:** Not in vcpkg directory

**Solution:**
```bash
cd vcpkg
.\bootstrap-vcpkg.bat -disableMetrics
```

### Issue: "MSBUILD : error MSB1009: Project file does not exist"

**Cause:** Visual Studio Build Tools not installed (Windows)

**Solution:**
```powershell
# Download and install Visual Studio Build Tools
# https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022

# Or install Visual Studio Community with C++ workload
```

### Issue: "Could not find a suitable compiler"

**Cause:** C++ compiler not installed (Unix/Linux/macOS)

**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install build-essential cmake

# macOS
xcode-select --install

# Fedora/RHEL
sudo dnf install gcc-c++ cmake
```

### Issue: "vcpkg integrate install" fails

**Cause:** Insufficient permissions (Windows) or not applicable (Unix/Linux)

**Solution:**
```powershell
# Windows: Run PowerShell as Administrator
.\vcpkg.exe integrate install

# Unix/Linux: Integration not needed
# Just use CMAKE_TOOLCHAIN_FILE
```

### Issue: "Package installation fails"

**Cause:** Missing system dependencies

**Solution:**
```bash
# Ubuntu/Debian: Install common dependencies
sudo apt-get install pkg-config autoconf automake libtool

# macOS: Install Homebrew dependencies
brew install pkg-config autoconf automake libtool

# Then retry package installation
./vcpkg install <package-name>
```

### Issue: "vcpkg directory already exists"

**Cause:** Previous installation or clone

**Solution:**
```bash
# Option 1: Update existing installation
cd vcpkg
git pull
./bootstrap-vcpkg.sh -disableMetrics

# Option 2: Remove and re-clone
cd ..
rm -rf vcpkg
git clone https://github.com/microsoft/vcpkg.git
cd vcpkg
./bootstrap-vcpkg.sh -disableMetrics
```

---

## Related Heuristics

**H006: SUCCESS-DECLARATION-CHECKPOINT**
- Verify vcpkg binary exists before claiming "vcpkg installed"
- Use `./vcpkg version` to test executable
- Check integration status with `./vcpkg integrate project`

**H013: PACKAGE-VERIFICATION**
- Verify vcpkg installed before using: `command -v vcpkg`
- Check package installed: `./vcpkg list | grep <package>`
- Don't assume packages installed without verification

**H018: NUMERIC-CLAIM-VERIFICATION**
- Count actual packages: `./vcpkg list | wc -l`
- Don't claim "N packages installed" without counting

---

## Notes

**Why These Commands:**
- `-disableMetrics` flag prevents telemetry collection
- `integrate install` makes packages available system-wide (Windows)
- Toolchain file is required for CMake to find vcpkg packages
- Cross-platform support (Windows, Linux, macOS)

**Common Pitfalls:**
- Forgetting to specify CMAKE_TOOLCHAIN_FILE in CMake command
- Not running bootstrap script before using vcpkg
- Claiming "vcpkg integrated" without running integrate command
- Installing wrong triplet (x86 vs x64, static vs dynamic)
- Not updating vcpkg before installing new packages

**vcpkg vs System Packages:**
- vcpkg provides consistent package versions across platforms
- System packages vary by distribution and version
- vcpkg allows multiple versions side-by-side
- vcpkg integrates cleanly with CMake

---

## Quick Reference

```bash
# Clone and bootstrap (Unix/Linux/macOS)
git clone https://github.com/microsoft/vcpkg.git && cd vcpkg && ./bootstrap-vcpkg.sh -disableMetrics

# Clone and bootstrap (Windows)
git clone https://github.com/microsoft/vcpkg.git; cd vcpkg; .\bootstrap-vcpkg.bat -disableMetrics; .\vcpkg.exe integrate install

# Install package
./vcpkg install <package-name>

# CMake with vcpkg
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=/path/to/vcpkg/scripts/buildsystems/vcpkg.cmake

# List packages
./vcpkg list

# Search packages
./vcpkg search <query>
```

---

**Status:** Active reference
**Platform:** Cross-platform (Windows, Linux, macOS)
**Testing:** Verified with vcpkg 2024.01.12
