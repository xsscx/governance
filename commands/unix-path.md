# Unix/Linux/macOS PATH Configuration

**Purpose:** Add ICC build executables to Unix PATH
**Platform:** Unix/Linux/macOS (bash/zsh)
**Status:** Verified working
**Updated:** 2026-02-07

---

## Add ICC Build Tools to PATH

### Iterate Through Build Tool Directories

Adds all subdirectories in `Build/Tools/` to PATH.

```bash
cd Testing/
echo "=== Updating PATH ==="
for d in ../Build/Tools/*; do
  [ -d "$d" ] && export PATH="$(realpath "$d"):$PATH"
done
```

**What It Does:**
1. Changes to `Testing/` directory (common starting point for test scripts)
2. Loops through all items in `../Build/Tools/*`
3. Checks if item is a directory with `[ -d "$d" ]`
4. Resolves absolute path with `realpath`
5. Prepends directory to PATH with `export PATH="...":$PATH`

**Example Directories Added:**
```
/home/user/iccLibFuzzer/Build/Tools/IccApplyNamedCmm
/home/user/iccLibFuzzer/Build/Tools/IccApplyProfiles
/home/user/iccLibFuzzer/Build/Tools/IccDumpProfile
/home/user/iccLibFuzzer/Build/Tools/IccFromXml
/home/user/iccLibFuzzer/Build/Tools/IccToXml
```

---

## Verify PATH Configuration

### Show ICC-Related Directories in PATH

```bash
echo $PATH | tr ':' '\n' | grep -i icc
```

**Output Format:**
```
/home/user/iccLibFuzzer/Build/Tools/IccApplyNamedCmm
/home/user/iccLibFuzzer/Build/Tools/IccApplyProfiles
/home/user/iccLibFuzzer/Build/Tools/IccDumpProfile
```

**Usage:**
```bash
# Count ICC directories in PATH
echo $PATH | tr ':' '\n' | grep -i icc | wc -l
# Expected: 10+ directories

# Test tool availability
which IccDumpProfile IccFromXml IccToXml IccApplyNamedCmm
# Should return absolute paths
```

---

## Add All Build Directories (Comprehensive)

### From Repository Root

```bash
cd /path/to/iccLibFuzzer
echo "=== Updating PATH ==="
for d in Build/Tools/*; do
  [ -d "$d" ] && export PATH="$(realpath "$d"):$PATH"
done
```

**Use Case:** When working from repository root instead of Testing/

---

## Add IccXML Tools to PATH

### Include XML Command-Line Tools

```bash
# Add Tools/CmdLine directories
for d in Build/Tools/*/; do
  [ -d "$d" ] && export PATH="$(realpath "$d"):$PATH"
done

# Add IccXML/CmdLine directories
for d in Build/IccXML/CmdLine/*; do
  [ -d "$d" ] && export PATH="$(realpath "$d"):$PATH"
done
```

**Directories Added:**
```
Build/IccXML/CmdLine/IccFromXml
Build/IccXML/CmdLine/IccToXml
```

---

## Complete PATH Setup Script

### Full Configuration with Verification

```bash
#!/bin/bash

# 1. Verify location
echo "=== Current Directory ==="
pwd

# 2. Add Build/Tools directories to PATH
echo "=== Updating PATH ==="
for d in Build/Tools/*; do
  if [ -d "$d" ]; then
    abs_path=$(realpath "$d")
    export PATH="$abs_path:$PATH"
    echo "[OK] Added: $abs_path"
  fi
done

# 3. Optional: Add IccXML tools
for d in Build/IccXML/CmdLine/*; do
  if [ -d "$d" ]; then
    abs_path=$(realpath "$d")
    export PATH="$abs_path:$PATH"
    echo "[OK] Added: $abs_path"
  fi
done

# 4. Verify ICC tools in PATH
echo ""
echo "=== ICC Directories in PATH ==="
echo $PATH | tr ':' '\n' | grep -i icc

# 5. Count total ICC directories
icc_count=$(echo $PATH | tr ':' '\n' | grep -i icc | wc -l)
echo ""
echo "[OK] $icc_count ICC directories added to PATH"

# 6. Test tool availability
echo ""
echo "=== Testing Tool Availability ==="
for tool in IccDumpProfile IccFromXml IccToXml IccApplyNamedCmm; do
  if which "$tool" > /dev/null 2>&1; then
    echo "[OK] $tool: $(which $tool)"
  else
    echo "[FAIL] $tool not found"
  fi
done
```

**Expected Output:**
```
=== Current Directory ===
/home/user/iccLibFuzzer

=== Updating PATH ===
[OK] Added: /home/user/iccLibFuzzer/Build/Tools/IccApplyNamedCmm
[OK] Added: /home/user/iccLibFuzzer/Build/Tools/IccApplyProfiles
[OK] Added: /home/user/iccLibFuzzer/Build/Tools/IccDumpProfile
...

=== ICC Directories in PATH ===
/home/user/iccLibFuzzer/Build/Tools/IccApplyNamedCmm
/home/user/iccLibFuzzer/Build/Tools/IccApplyProfiles
...

[OK] 12 ICC directories added to PATH

=== Testing Tool Availability ===
[OK] IccDumpProfile: /home/user/iccLibFuzzer/Build/Tools/IccDumpProfile/IccDumpProfile
[OK] IccFromXml: /home/user/iccLibFuzzer/Build/IccXML/CmdLine/IccFromXml/iccFromXml
[OK] IccToXml: /home/user/iccLibFuzzer/Build/IccXML/CmdLine/IccToXml/iccToXml
[OK] IccApplyNamedCmm: /home/user/iccLibFuzzer/Build/Tools/IccApplyNamedCmm/iccApplyNamedCmm
```

---

## Alternative: One-Liner PATH Update

### Compact Version

```bash
export PATH="$(find ./Build/Tools -mindepth 1 -maxdepth 1 -type d -exec realpath {} \; | tr '\n' ':')$PATH"
```

**What It Does:**
1. Finds all first-level subdirectories in `./Build/Tools`
2. Converts each to absolute path with `realpath`
3. Joins with `:` separator using `tr`
4. Prepends to existing PATH

**Usage:**
```bash
# From repository root
cd /path/to/iccLibFuzzer
export PATH="$(find ./Build/Tools -mindepth 1 -maxdepth 1 -type d -exec realpath {} \; | tr '\n' ':')$PATH"

# Verify
echo $PATH | tr ':' '\n' | head -5
```

---

## Persistent PATH Configuration

### Add to Shell Profile

For permanent PATH configuration, add to shell profile:

**Bash (~/.bashrc or ~/.bash_profile):**
```bash
# Add ICC tools to PATH
ICC_BUILD_PATH="/home/user/iccLibFuzzer/Build/Tools"
if [ -d "$ICC_BUILD_PATH" ]; then
  for d in "$ICC_BUILD_PATH"/*; do
    [ -d "$d" ] && export PATH="$(realpath "$d"):$PATH"
  done
fi
```

**Zsh (~/.zshrc):**
```zsh
# Add ICC tools to PATH
ICC_BUILD_PATH="/home/user/iccLibFuzzer/Build/Tools"
if [ -d "$ICC_BUILD_PATH" ]; then
  for d in "$ICC_BUILD_PATH"/*; do
    [ -d "$d" ] && export PATH="$(realpath "$d"):$PATH"
  done
fi
```

**Apply Changes:**
```bash
# Reload profile
source ~/.bashrc   # or ~/.zshrc
```

---

## Common Use Cases

### 1. Post-Build PATH Configuration

After building iccDEV project, add tools to PATH:

```bash
cd /path/to/iccLibFuzzer
for d in Build/Tools/*; do
  [ -d "$d" ] && export PATH="$(realpath "$d"):$PATH"
done
```

### 2. Testing Workflow PATH Setup

From Testing directory (common in test scripts):

```bash
cd Testing/
for d in ../Build/Tools/*; do
  [ -d "$d" ] && export PATH="$(realpath "$d"):$PATH"
done
```

### 3. Verify Tool Accessibility

Check if tools can be executed without full path:

```bash
# Before PATH modification
which IccDumpProfile
# Output: (nothing) or /usr/bin/IccDumpProfile (wrong version)

# After PATH modification
which IccDumpProfile
# Output: /home/user/iccLibFuzzer/Build/Tools/IccDumpProfile/IccDumpProfile
```

### 4. Multi-Build Configuration Support

Support multiple build configurations:

```bash
# Add both release and debug builds
for build_dir in Build Build-debug Build-release; do
  for d in "$build_dir/Tools"/*; do
    [ -d "$d" ] && export PATH="$(realpath "$d"):$PATH"
  done
done
```

---

## Cross-Platform Comparison

### Unix vs Windows

| Feature | Unix/Linux/macOS | Windows PowerShell |
|---------|------------------|-------------------|
| Loop construct | for d in dir/*; do | Get-ChildItem \| ForEach-Object |
| Directory check | [ -d "$d" ] | Test-Path |
| Absolute path | realpath "$d" | Split-Path -Parent |
| Path separator | : (colon) | ; (semicolon) |
| Export variable | export PATH="..." | $env:PATH = "..." |
| Test availability | which tool | Get-Command tool |

**Windows Equivalent:**
```powershell
$toolDirs = Get-ChildItem -Path .\Build\Tools -Directory | 
    ForEach-Object { $_.FullName }
$env:PATH = ($toolDirs -join ';') + ';' + $env:PATH
```

---

## Troubleshooting

### Issue: "realpath: command not found"

**Cause:** `realpath` not available on some macOS/BSD systems

**Solution:** Use alternative methods

```bash
# Method 1: Use readlink (macOS compatible)
for d in Build/Tools/*; do
  [ -d "$d" ] && export PATH="$(cd "$d" && pwd):$PATH"
done

# Method 2: Use Python
for d in Build/Tools/*; do
  [ -d "$d" ] && export PATH="$(python3 -c "import os; print(os.path.realpath('$d'))"):$PATH"
done

# Method 3: Install coreutils (macOS with Homebrew)
brew install coreutils
# Use grealpath instead of realpath
```

### Issue: "which tool" shows wrong version

**Cause:** System tool has same name, appears earlier in PATH

**Solution:** Verify ICC tool takes precedence

```bash
# Check which tool is found first
which -a IccDumpProfile
# Output should show Build/Tools version first

# If wrong order, ensure PATH prepends (not appends)
export PATH="/path/to/Build/Tools/IccDumpProfile:$PATH"  # Correct (prepend)
export PATH="$PATH:/path/to/Build/Tools/IccDumpProfile"  # Wrong (append)
```

### Issue: "Too many directories in PATH"

**Cause:** Multiple executions appending duplicates

**Solution:** Clear and rebuild PATH, or use conditional addition

```bash
# Method 1: Clear and rebuild (careful - may break system tools)
export PATH="/usr/local/bin:/usr/bin:/bin"
for d in Build/Tools/*; do
  [ -d "$d" ] && export PATH="$(realpath "$d"):$PATH"
done

# Method 2: Check if already in PATH before adding
for d in Build/Tools/*; do
  if [ -d "$d" ]; then
    abs_path=$(realpath "$d")
    if ! echo "$PATH" | grep -q "$abs_path"; then
      export PATH="$abs_path:$PATH"
    fi
  fi
done
```

### Issue: "No such file or directory: Build/Tools"

**Cause:** Running from wrong directory or tools not built yet

**Solution:** Verify location and build status

```bash
# Check current directory
pwd
# Expected: /path/to/iccLibFuzzer or /path/to/iccLibFuzzer/Testing

# Check if Build/Tools exists
ls -la Build/Tools/ 2>&1
# Should list subdirectories

# If not found, build project first
cd Build && cmake Cmake && make -j$(nproc)
```

---

## Related Heuristics

**H006: SUCCESS-DECLARATION-CHECKPOINT**
- Verify tools are in PATH before claiming "PATH configured"
- Use `which <tool>` to test availability
- Count actual directories added

**H018: NUMERIC-CLAIM-VERIFICATION**
- Count actual directories: `echo $PATH | tr ':' '\n' | grep -i icc | wc -l`
- Don't claim "N tools added" without counting

---

## Notes

**Why These Commands:**
- Uses `realpath` for absolute paths (prevents relative path issues)
- Checks `[ -d "$d" ]` before adding (avoids adding files or missing dirs)
- Prepends to PATH (new tools take precedence over system versions)
- Works across bash and zsh shells

**Common Pitfalls:**
- Running multiple times creates duplicate PATH entries
- Using relative paths (breaks when changing directories)
- Not verifying tools are accessible after PATH modification
- Claiming success without testing `which <tool>`
- Forgetting to export PATH (only sets in current scope)

**Session Scope:**
- PATH modifications are session-local (lost when closing terminal)
- For permanent PATH, modify ~/.bashrc, ~/.bash_profile, or ~/.zshrc
- Each new terminal needs PATH reconfigured unless in profile

---

## Quick Reference

```bash
# Add Build/Tools to PATH
for d in Build/Tools/*; do [ -d "$d" ] && export PATH="$(realpath "$d"):$PATH"; done

# Verify
echo $PATH | tr ':' '\n' | grep -i icc

# Count
echo $PATH | tr ':' '\n' | grep -i icc | wc -l

# Test
which IccDumpProfile IccFromXml IccToXml
```

---

**Status:** Active reference
**Platform:** Unix/Linux/macOS (bash/zsh)
**Testing:** Verified on Ubuntu 20.04+, macOS 12+
