# LLMCJF Commands Reference

**Purpose:** Curated collection of verified, working commands
**Status:** Active reference library
**Updated:** 2026-02-07

---

## Directory Contents

### Active Commands

- **find-binaries.md** - Find and verify build artifacts
  - Unix/Linux: find + sha256sum
  - Windows: PowerShell Get-ChildItem + Get-FileHash
  - Use cases: Build verification, checksum generation, artifact inventory
  - Related: H006 (SUCCESS-DECLARATION-CHECKPOINT), H018 (NUMERIC-CLAIM-VERIFICATION)

- **windows-path.md** - Windows PATH configuration
  - PowerShell: Add ICC executables to PATH
  - Filters: Exclude CMakeFiles, CMake compiler ID files
  - Verification: Get-Command tool testing
  - Cross-platform: Unix/Linux/macOS equivalent provided
  - Related: H006 (verify before claiming), H018 (count actual directories)

- **unix-path.md** - Unix/Linux/macOS PATH configuration
  - Bash/Zsh: Add ICC build tools to PATH
  - Iterate through Build/Tools/* directories
  - Verification: which command testing
  - Alternative: One-liner find command
  - Persistent: Shell profile configuration (.bashrc, .zshrc)
  - Troubleshooting: realpath alternatives for macOS
  - Related: H006 (verify before claiming), H018 (count actual directories)

---

## Command Categories

### Build Verification
- Binary discovery (executables, libraries)
- Checksum generation (SHA256)
- Artifact counting and validation

- **wasm-verification.md** - WebAssembly build verification
  - Verify WASM format in static libraries (.a archives)
  - Extract and inspect object files with wasm-objdump
  - Validate WASM binaries with wasm-validate
  - Complete verification script with dependencies check
  - Compare native vs WASM builds
  - Installation: WABT tools (Ubuntu, macOS, manual)
  - Related: H006 (verify before claiming), H018 (count actual files), H013 (package verification)

- **vcpkg-setup.md** - vcpkg C++ package manager setup
  - Clone and bootstrap vcpkg (Windows: .bat, Unix: .sh)
  - Disable telemetry with -disableMetrics flag
  - Integrate with Visual Studio and MSBuild (Windows)
  - CMake toolchain file configuration
  - Install iccDEV dependencies (libxml2, libtiff, libpng, etc.)
  - Complete setup scripts (PowerShell, Bash)
  - Troubleshooting: compiler dependencies, integration issues
  - Related: H006 (verify before claiming), H013 (package verification), H018 (count packages)

- **windows-visual-studio.md** - Visual Studio detection and queries (Windows)
  - Get Visual Studio version with vswhere.exe
  - Locate devenv.exe path for any edition
  - Query installation properties (path, components, workloads)
  - Verify C++ build tools installation
  - Find MSBuild.exe and vcvarsall.bat
  - Complete detection script with verification
  - Troubleshooting: missing components, installation issues
  - Related: H006 (verify before claiming), H013 (package verification), H018 (version verification)

- **memory-calculations.md** - Memory size conversions and calculations
  - Convert hex to bytes and GB (one-liner and functions)
  - Convert bytes to hex and GB
  - Enhanced functions with KB/MB/GB support
  - Precise calculations with bc (high precision)
  - Complete conversion utility script
  - PowerShell equivalents for Windows
  - Common use cases: analyze allocations, verify memory limits
  - Related: H018 (numeric claim verification), H006 (verify before claiming)

- **grep-log-errors.md** - Search log files for errors and issues
  - Comprehensive error pattern (all categories in one command)
  - Categorized searches: crashes, memory, parsing, validation, timing
  - Enhanced commands: case-insensitive, line numbers, context, count
  - Complete error analysis script
  - PowerShell equivalents for Windows
  - Common use cases: post-build checks, error extraction, comparison
  - Related: H019 (logs-first protocol), H006 (verify before claiming), H018 (count errors)

### Planned Additions
- Git operations (status, diff, log)
- File operations (safe deletion, backup, restore)
- Search operations (grep, find, patterns)
- Test operations (run, verify, report)

---

## Usage Philosophy

### Why This Directory Exists

**Problem:** Claiming success without verification (V006, V018, V021, V027)

**Evidence:**
- V006: Claimed SHA256 fixed, was broken (45 min wasted)
- V018: Claimed "all builds succeeded", 2 failed (false success)
- V021: Claimed "15 fuzzers built", was 0 (catastrophic false claim)
- V027: Claimed "295 entries", was 30 (90% error rate)

**Solution:** Verified command reference library

### Command Quality Standards

[OK] **REQUIRED:**
- Tested on target platform (Linux, Windows, macOS)
- Cross-referenced with actual use case
- Includes expected output format
- Documents common pitfalls
- References related heuristics

[FAIL] **PROHIBITED:**
- Untested commands
- Platform-specific without alternatives
- Commands without verification protocol
- Commands that assume state without checking

---

## Contributing Commands

### Before Adding New Command

```bash
# 1. Test command on actual system
cd /path/to/test && <command> && echo "[OK] Command works"

# 2. Verify output matches expected
<command> > actual-output.txt
diff expected-output.txt actual-output.txt

# 3. Document parameters and gotchas
# (What does each flag do? What can go wrong?)

# 4. Add to appropriate .md file in commands/
# (Or create new category file)
```

### Command Documentation Template

```markdown
## Command Name

**Purpose:** One-line description

**Platform:** Linux/macOS/Windows/Cross-platform

**Command:**
```bash
<actual command here>
```

**Parameters:**
- `-flag` - What it does
- `--option value` - What it does

**Output Format:**
```
<example output>
```

**Usage:**
```bash
# Common use case
<command with real example>
```

**Related Heuristics:**
- HXXX: Rule name (why this command exists)

**Pitfalls:**
- Don't do X (leads to Y problem)
- Always check Z before running
```

---

## Quick Reference

### Build Verification
```bash
# Count binaries built in last 30 minutes
find . -type f -perm -111 -mmin -30 ! -path "*/.git/*" | wc -l

# Generate checksums
find . -type f -perm -111 -mmin -30 ! -path "*/.git/*" \
  -print | xargs sha256sum > checksums.txt
```

### Git Status
```bash
# Quick status check
git --no-pager status --short

# See recent commits
git --no-pager log --oneline -n 5
```

### File Search
```bash
# Find files by pattern
find . -name "*.md" ! -path "*/.git/*" | head -20

# Search file contents
grep -r "pattern" --include="*.cpp" --exclude-dir=".git"
```

---

## Heuristic Cross-Reference

**Commands Support These Rules:**

- **H006: SUCCESS-DECLARATION-CHECKPOINT**
  - find-binaries.md: Verify before claiming build success
  
- **H018: NUMERIC-CLAIM-VERIFICATION**
  - find-binaries.md: Count actual binaries vs claimed
  
- **H019: LOGS-FIRST-PROTOCOL**
  - (Future: log parsing commands)

---

## Maintenance
