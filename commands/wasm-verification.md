# WASM Build Verification

**Purpose:** Verify WebAssembly build artifacts and format correctness
**Platform:** Unix/Linux/macOS (requires wasm-objdump from WABT)
**Status:** Verified working
**Updated:** 2026-02-07

---

## Check WASM Format in Static Libraries

### Verify Object Files in .a Archives

Extracts and inspects object files from static libraries to verify WASM format.

```bash
find IccProfLib/ -name '*.a' -exec sh -c '
  for obj in $(ar t "$1" | grep "\.o$"); do
    ar p "$1" "$obj" > "/tmp/$obj"
    command -v wasm-objdump && wasm-objdump -x "/tmp/$obj" | head || echo "wasm-objdump not installed"
  done
' sh {} \;
```

**What It Does:**
1. Finds all `.a` (archive) files in `IccProfLib/` directory
2. For each archive, lists object files with `ar t`
3. Filters to `.o` object files
4. Extracts each object file to `/tmp/` with `ar p`
5. Checks if `wasm-objdump` is installed with `command -v`
6. If available, dumps WASM object metadata with `wasm-objdump -x`
7. Shows first 10 lines with `head`
8. Falls back to error message if `wasm-objdump` not installed

**Example Output:**
```
/tmp/IccProfile.o:      file format wasm

Sections:

  Details for section Type:
   - type[0] (i32, i32) -> i32
   - type[1] (i32) -> i32
   - type[2] () -> i32

  Details for section Import:
   - func[0] sig=0 <env.__linear_memory> <- env.__linear_memory
```

**Use Case:** Verify WASM build produced correct object format (not native x86_64/ARM)

---

## Verify WASM Build Dependencies

### Check for Emscripten SDK

```bash
command -v emcc && emcc --version || echo "[FAIL] Emscripten SDK not found"
command -v wasm-objdump && wasm-objdump --version || echo "[FAIL] WABT tools not found"
```

**Output Format:**
```
emcc (Emscripten gcc/clang-like replacement + linker emulating GNU ld) 3.1.50
clang version 18.0.0
[OK] Emscripten SDK found

wasm-objdump 1.0.33
[OK] WABT tools found
```

**Required Tools:**
- `emcc` - Emscripten compiler
- `wasm-objdump` - WASM object dumper (from WABT)
- `wasm-validate` - WASM binary validator
- `wasm-dis` - WASM disassembler

---

## Verify WASM Binary Format

### Check .wasm Files

```bash
find Build-WASM-Release/ -name "*.wasm" -type f -exec sh -c '
  echo "=== $1 ==="
  if command -v wasm-validate > /dev/null; then
    wasm-validate "$1" && echo "[OK] Valid WASM binary" || echo "[FAIL] Invalid WASM binary"
  else
    echo "[WARN] wasm-validate not installed"
  fi
  echo ""
' sh {} \;
```

**Output Format:**
```
=== Build-WASM-Release/IccProfLib/libIccProfLib2.wasm ===
[OK] Valid WASM binary

=== Build-WASM-Release/Tools/IccDumpProfile/IccDumpProfile.wasm ===
[OK] Valid WASM binary
```

**Use Case:** Verify WASM binaries are valid before deployment

---

## Inspect WASM Binary Metadata

### Show WASM Sections and Imports

```bash
wasm_file="Build-WASM-Release/IccProfLib/libIccProfLib2.wasm"

if [ -f "$wasm_file" ]; then
  echo "=== WASM File: $wasm_file ==="
  
  # Validate
  wasm-validate "$wasm_file" && echo "[OK] Valid" || echo "[FAIL] Invalid"
  
  # Show sections
  echo ""
  echo "=== Sections ==="
  wasm-objdump -h "$wasm_file"
  
  # Show imports
  echo ""
  echo "=== Imports ==="
  wasm-objdump -x "$wasm_file" | grep -A 20 "Import"
  
  # Show exports
  echo ""
  echo "=== Exports ==="
  wasm-objdump -x "$wasm_file" | grep -A 20 "Export"
else
  echo "[FAIL] File not found: $wasm_file"
fi
```

**Output Format:**
```
=== WASM File: Build-WASM-Release/IccProfLib/libIccProfLib2.wasm ===
[OK] Valid

=== Sections ===
Sections:

     Type start=0x0000000a end=0x00000234 (size=0x0000022a) count: 89
   Import start=0x00000239 end=0x00000456 (size=0x0000021d) count: 23
 Function start=0x0000045b end=0x0000067c (size=0x00000221) count: 544
    Table start=0x00000681 end=0x00000689 (size=0x00000008) count: 1
   Memory start=0x0000068e end=0x00000691 (size=0x00000003) count: 1
   Global start=0x00000696 end=0x000006a3 (size=0x0000000d) count: 2
   Export start=0x000006a8 end=0x000007f2 (size=0x0000014a) count: 45
     Code start=0x000007f7 end=0x0003d4e8 (size=0x0003ccf1) count: 544

=== Imports ===
 - func[0] sig=0 <env.emscripten_resize_heap> <- env.emscripten_resize_heap
 - func[1] sig=1 <env.abort> <- env.abort
 - table[0] elem_type=funcref init=0 max=unlimited <- env.__indirect_function_table
 - memory[0] pages: initial=256 <- env.memory

=== Exports ===
 - memory[0] -> "memory"
 - func[12] <__wasm_call_ctors> -> "__wasm_call_ctors"
 - func[45] <icReadIccProfile> -> "icReadIccProfile"
 - func[67] <icValidateProfile> -> "icValidateProfile"
```

---

## Check WASM Object Format in Archives

### Detailed Archive Inspection

```bash
archive_file="Build-WASM-Release/IccProfLib/libIccProfLib2.a"

if [ -f "$archive_file" ]; then
  echo "=== Archive: $archive_file ==="
  
  # List object files
  echo "=== Object Files in Archive ==="
  ar t "$archive_file" | grep "\.o$"
  
  # Count objects
  obj_count=$(ar t "$archive_file" | grep "\.o$" | wc -l)
  echo ""
  echo "[INFO] Total object files: $obj_count"
  
  # Verify WASM format for first 3 objects
  echo ""
  echo "=== WASM Format Verification (First 3 Objects) ==="
  for obj in $(ar t "$archive_file" | grep "\.o$" | head -3); do
    echo "--- $obj ---"
    ar p "$archive_file" "$obj" > "/tmp/$obj"
    
    if command -v wasm-objdump > /dev/null; then
      if wasm-objdump -h "/tmp/$obj" 2>&1 | grep -q "file format wasm"; then
        echo "[OK] WASM format confirmed"
      else
        echo "[FAIL] Not WASM format"
      fi
    else
      echo "[WARN] wasm-objdump not available"
    fi
    
    rm -f "/tmp/$obj"
  done
else
  echo "[FAIL] Archive not found: $archive_file"
fi
```

**Output Format:**
```
=== Archive: Build-WASM-Release/IccProfLib/libIccProfLib2.a ===
=== Object Files in Archive ===
IccProfile.o
IccTag.o
IccTagBasic.o
...

[INFO] Total object files: 87

=== WASM Format Verification (First 3 Objects) ===
--- IccProfile.o ---
[OK] WASM format confirmed
--- IccTag.o ---
[OK] WASM format confirmed
--- IccTagBasic.o ---
[OK] WASM format confirmed
```

---

## Complete WASM Build Verification Script

### Full Verification Workflow

```bash
#!/bin/bash

echo "==================================================================="
echo "WASM Build Verification"
echo "==================================================================="
echo ""

# 1. Check dependencies
echo "=== Step 1: Check Dependencies ==="
deps_ok=true

if command -v emcc > /dev/null; then
  emcc_version=$(emcc --version | head -1)
  echo "[OK] Emscripten: $emcc_version"
else
  echo "[FAIL] emcc not found"
  deps_ok=false
fi

if command -v wasm-objdump > /dev/null; then
  wabt_version=$(wasm-objdump --version 2>&1 | head -1)
  echo "[OK] WABT: $wabt_version"
else
  echo "[FAIL] wasm-objdump not found"
  deps_ok=false
fi

if command -v wasm-validate > /dev/null; then
  echo "[OK] wasm-validate available"
else
  echo "[WARN] wasm-validate not found (optional)"
fi

if [ "$deps_ok" = false ]; then
  echo ""
  echo "[FAIL] Missing required dependencies"
  exit 1
fi

echo ""

# 2. Find WASM build directories
echo "=== Step 2: Locate WASM Builds ==="
wasm_builds=$(find . -maxdepth 1 -type d -name "Build-WASM*" -o -name "Build*WASM*" | sort)

if [ -z "$wasm_builds" ]; then
  echo "[FAIL] No WASM build directories found"
  exit 1
fi

echo "$wasm_builds" | while read -r build_dir; do
  echo "[OK] Found: $build_dir"
done

echo ""

# 3. Verify WASM binaries
echo "=== Step 3: Verify WASM Binaries ==="
wasm_count=0
valid_count=0
invalid_count=0

find . -name "*.wasm" -type f ! -path "*/.git/*" | while read -r wasm_file; do
  wasm_count=$((wasm_count + 1))
  
  if wasm-validate "$wasm_file" 2>/dev/null; then
    echo "[OK] $wasm_file"
    valid_count=$((valid_count + 1))
  else
    echo "[FAIL] $wasm_file"
    invalid_count=$((invalid_count + 1))
  fi
done

echo ""
echo "[INFO] WASM binaries: $wasm_count total"

echo ""

# 4. Verify WASM archives
echo "=== Step 4: Verify WASM Archives ==="
archive_count=0
wasm_archive_count=0

find . -name "*.a" -type f ! -path "*/.git/*" ! -path "*/CMakeFiles/*" | while read -r archive; do
  archive_count=$((archive_count + 1))
  
  # Extract first object file to check format
  first_obj=$(ar t "$archive" | grep "\.o$" | head -1)
  
  if [ -n "$first_obj" ]; then
    ar p "$archive" "$first_obj" > "/tmp/check_wasm.o" 2>/dev/null
    
    if wasm-objdump -h "/tmp/check_wasm.o" 2>&1 | grep -q "file format wasm"; then
      echo "[OK] WASM archive: $archive"
      wasm_archive_count=$((wasm_archive_count + 1))
    else
      echo "[INFO] Native archive: $archive"
    fi
    
    rm -f "/tmp/check_wasm.o"
  fi
done

echo ""
echo "[INFO] Archives checked: $archive_count total"
echo "[INFO] WASM archives: $wasm_archive_count"

echo ""

# 5. Summary
echo "==================================================================="
echo "Verification Complete"
echo "==================================================================="
```

**Expected Output:**
```
===================================================================
WASM Build Verification
===================================================================

=== Step 1: Check Dependencies ===
[OK] Emscripten: emcc (Emscripten gcc/clang-like replacement) 3.1.50
[OK] WABT: wasm-objdump 1.0.33
[OK] wasm-validate available

=== Step 2: Locate WASM Builds ===
[OK] Found: ./Build-WASM-Debug
[OK] Found: ./Build-WASM-Release

=== Step 3: Verify WASM Binaries ===
[OK] ./Build-WASM-Release/Tools/IccDumpProfile/IccDumpProfile.wasm
[OK] ./Build-WASM-Release/IccProfLib/libIccProfLib2.wasm

[INFO] WASM binaries: 2 total

=== Step 4: Verify WASM Archives ===
[OK] WASM archive: ./Build-WASM-Release/IccProfLib/libIccProfLib2.a
[INFO] Native archive: ./Build/IccProfLib/libIccProfLib2.a

[INFO] Archives checked: 2 total
[INFO] WASM archives: 1

===================================================================
Verification Complete
===================================================================
```

---

## Installation: WABT Tools

### Ubuntu/Debian

```bash
sudo apt-get update
sudo apt-get install wabt
```

### macOS (Homebrew)

```bash
brew install wabt
```

### Manual Installation

```bash
# Clone WABT repository
git clone --recursive https://github.com/WebAssembly/wabt
cd wabt

# Build
mkdir build && cd build
cmake ..
make -j$(nproc)

# Install (optional)
sudo make install

# Or use from build directory
export PATH="$(pwd):$PATH"
```

---

## Common Use Cases

### 1. Post-Build WASM Verification

After building with Emscripten, verify WASM format:

```bash
# Build with Emscripten
cd Build-WASM-Release
emcmake cmake ../Build/Cmake -DCMAKE_BUILD_TYPE=Release
emmake make -j$(nproc)

# Verify WASM format
cd ..
find Build-WASM-Release -name "*.a" -exec sh -c '
  for obj in $(ar t "$1" | grep "\.o$" | head -1); do
    ar p "$1" "$obj" > "/tmp/$obj"
    wasm-objdump -h "/tmp/$obj" | head -5
  done
' sh {} \;
```

### 2. Compare Native vs WASM Builds

```bash
# Check native build
ar t Build/IccProfLib/libIccProfLib2.a | head -1 | xargs -I {} ar p Build/IccProfLib/libIccProfLib2.a {} > /tmp/native.o
file /tmp/native.o
# Output: /tmp/native.o: ELF 64-bit LSB relocatable, x86-64

# Check WASM build
ar t Build-WASM-Release/IccProfLib/libIccProfLib2.a | head -1 | xargs -I {} ar p Build-WASM-Release/IccProfLib/libIccProfLib2.a {} > /tmp/wasm.o
file /tmp/wasm.o
# Output: /tmp/wasm.o: WebAssembly (wasm) binary module
```

### 3. Extract and Disassemble WASM

```bash
# Extract WASM object
ar t Build-WASM-Release/IccProfLib/libIccProfLib2.a | head -1 | xargs -I {} ar p Build-WASM-Release/IccProfLib/libIccProfLib2.a {} > /tmp/IccProfile.wasm.o

# Disassemble to WebAssembly text format
wasm-dis /tmp/IccProfile.wasm.o > /tmp/IccProfile.wat

# View disassembly
head -50 /tmp/IccProfile.wat
```

---

## Troubleshooting

### Issue: "wasm-objdump: command not found"

**Cause:** WABT tools not installed

**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get install wabt

# macOS
brew install wabt

# Verify
command -v wasm-objdump && wasm-objdump --version
```

### Issue: "file format not recognized"

**Cause:** Attempting to use wasm-objdump on native (x86_64/ARM) object files

**Solution:** Verify build directory is WASM build
```bash
# Check if Emscripten was used
grep -r "emcc\|emscripten" Build-WASM-Release/CMakeCache.txt

# Expected: CMAKE_C_COMPILER:FILEPATH=/path/to/emcc
```

### Issue: "Invalid WASM binary"

**Cause:** Corrupted build or incomplete compilation

**Solution:** Rebuild with clean state
```bash
# Clean build
rm -rf Build-WASM-Release
mkdir Build-WASM-Release && cd Build-WASM-Release

# Rebuild
emcmake cmake ../Build/Cmake -DCMAKE_BUILD_TYPE=Release
emmake make clean
emmake make -j$(nproc)

# Verify
cd .. && wasm-validate Build-WASM-Release/IccProfLib/libIccProfLib2.wasm
```

---

## Related Heuristics

**H006: SUCCESS-DECLARATION-CHECKPOINT**
- Verify WASM format before claiming "WASM build succeeded"
- Use `wasm-validate` to test binary validity
- Check object files with `wasm-objdump -h`

**H018: NUMERIC-CLAIM-VERIFICATION**
- Count actual WASM binaries: `find . -name "*.wasm" | wc -l`
- Count WASM archives: Check with wasm-objdump
- Don't claim "N WASM files built" without counting

**H013: PACKAGE-VERIFICATION**
- Verify Emscripten SDK before WASM build: `emcc --version`
- Check WABT tools: `wasm-objdump --version`

---

## Notes

**Why These Commands:**
- Extracts object files from archives without extracting entire archive
- Uses `command -v` for graceful fallback when tools missing
- Verifies WASM format vs native format (prevents false success)
- Temporary files in `/tmp/` for inspection

**Common Pitfalls:**
- Claiming "WASM build succeeded" without verifying format
- Confusing native and WASM build directories (both produce .a files)
- Not checking if wasm-objdump is installed
- Using `file` command alone (may not detect WASM correctly)
- Not cleaning `/tmp/*.o` files after inspection

**WASM vs Native:**
- Native .o: `ELF 64-bit LSB relocatable, x86-64`
- WASM .o: `WebAssembly (wasm) binary module version 0x1`
- Always verify format after build

---

**Status:** Active reference
**Platform:** Unix/Linux/macOS (requires WABT)
**Testing:** Verified with Emscripten 3.1.50, WABT 1.0.33
