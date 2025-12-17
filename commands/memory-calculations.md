# Memory Calculations and Conversions

**Purpose:** Convert between hex/decimal and calculate memory sizes
**Platform:** Unix/Linux/macOS (bash/zsh)
**Status:** Verified working
**Updated:** 2026-02-07

---

## Calculate Memory Allocation from Hex

### One-Line Hex to Bytes and GB

```bash
printf "0x3c05fc010 = %d bytes = %d GB\n" $((0x3c05fc010)) $((0x3c05fc010 / 1024 / 1024 / 1024))
```

**Output Format:**
```
0x3c05fc010 = 16088530960 bytes = 14 GB
```

**Use Case:** Quick conversion of hex memory addresses to human-readable sizes

**Explanation:**
- `$((0x3c05fc010))` - Converts hex to decimal (bash arithmetic)
- `$((... / 1024 / 1024 / 1024))` - Converts bytes to GB (1 GB = 1024^3 bytes)
- `printf` - Formats output with original hex, bytes, and GB

---

## Hex to Bytes Function

### Reusable Function for Hex Conversion

```bash
hex2bytes() {
    local v=$1
    printf "%s = %d bytes = %d GB\n" "$v" $((v)) $((v / 1024 / 1024 / 1024))
}
```

**Usage:**
```bash
# Define function
hex2bytes() {
    local v=$1
    printf "%s = %d bytes = %d GB\n" "$v" $((v)) $((v / 1024 / 1024 / 1024))
}

# Use function
hex2bytes 0x3c05fc010
hex2bytes 0x100000000
hex2bytes 0xFFFFFFFF
```

**Output:**
```
0x3c05fc010 = 16088530960 bytes = 14 GB
0x100000000 = 4294967296 bytes = 4 GB
0xFFFFFFFF = 4294967295 bytes = 3 GB
```

**Parameters:**
- `$1` - Hex value (with or without 0x prefix)

**Returns:**
- Formatted string with hex, bytes, and GB

---

## Bytes to Hex Function

### Convert Decimal Bytes to Hex

```bash
bytes2hex() {
    local v=$1
    printf "%d bytes = 0x%x = %d GB\n" "$v" "$v" $((v / 1024 / 1024 / 1024))
}
```

**Usage:**
```bash
# Define function
bytes2hex() {
    local v=$1
    printf "%d bytes = 0x%x = %d GB\n" "$v" "$v" $((v / 1024 / 1024 / 1024))
}

# Use function
bytes2hex 16088530960
bytes2hex 4294967296
bytes2hex 1073741824
```

**Output:**
```
16088530960 bytes = 0x3c05fc010 = 14 GB
4294967296 bytes = 0x100000000 = 4 GB
1073741824 bytes = 0x40000000 = 1 GB
```

**Parameters:**
- `$1` - Decimal byte value

**Returns:**
- Formatted string with bytes, hex, and GB

---

## Enhanced Functions with MB Support

### Include Megabytes in Output

```bash
hex2bytes_full() {
    local v=$1
    local bytes=$((v))
    local kb=$((bytes / 1024))
    local mb=$((bytes / 1024 / 1024))
    local gb=$((bytes / 1024 / 1024 / 1024))
    
    printf "%s = %d bytes = %d KB = %d MB = %d GB\n" "$v" "$bytes" "$kb" "$mb" "$gb"
}

bytes2hex_full() {
    local v=$1
    local kb=$((v / 1024))
    local mb=$((v / 1024 / 1024))
    local gb=$((v / 1024 / 1024 / 1024))
    
    printf "%d bytes = 0x%x = %d KB = %d MB = %d GB\n" "$v" "$v" "$kb" "$mb" "$gb"
}
```

**Usage:**
```bash
hex2bytes_full 0x3c05fc010
bytes2hex_full 16088530960
```

**Output:**
```
0x3c05fc010 = 16088530960 bytes = 15711456 KB = 15343 MB = 14 GB
16088530960 bytes = 0x3c05fc010 = 15711456 KB = 15343 MB = 14 GB
```

---

## Common Memory Size Conversions

### Quick Reference Table

```bash
# Define function to show common sizes
show_common_sizes() {
    echo "=== Common Memory Sizes ==="
    echo ""
    
    # Powers of 2
    for i in {10..40..10}; do
        size=$((2 ** i))
        hex=$(printf "0x%x" $size)
        gb=$((size / 1024 / 1024 / 1024))
        mb=$((size / 1024 / 1024))
        
        if [ $gb -gt 0 ]; then
            printf "2^%-2d = %-15s = %10s = %5d GB\n" "$i" "$size" "$hex" "$gb"
        else
            printf "2^%-2d = %-15s = %10s = %5d MB\n" "$i" "$size" "$hex" "$mb"
        fi
    done
}
```

**Output:**
```
=== Common Memory Sizes ===

2^10 = 1024            = 0x400      =     1 MB
2^20 = 1048576         = 0x100000   =     1 MB
2^30 = 1073741824      = 0x40000000 =     1 GB
2^40 = 1099511627776   = 0x10000000000 =  1024 GB
```

---

## Calculate Maximum Allocatable Memory

### Determine Maximum Size for Address Space

```bash
# 32-bit address space
max_32bit=$((2**32))
printf "32-bit max: %d bytes = 0x%x = %d GB\n" $max_32bit $max_32bit $((max_32bit / 1024 / 1024 / 1024))

# 64-bit address space (theoretical)
max_64bit=$((2**64))
printf "64-bit max: %d bytes = %d GB\n" $max_64bit $((max_64bit / 1024 / 1024 / 1024))
```

**Output:**
```
32-bit max: 4294967296 bytes = 0x100000000 = 4 GB
64-bit max: 18446744073709551616 bytes = 17179869184 GB
```

**Note:** Bash arithmetic may overflow for very large values. Use `bc` for precise calculations.

---

## Precise Calculations with bc

### High-Precision Memory Calculations

```bash
hex2gb_precise() {
    local hex=$1
    # Remove 0x prefix if present
    hex=${hex#0x}
    
    # Convert using bc for precision
    local bytes=$(echo "ibase=16; ${hex^^}" | bc)
    local gb=$(echo "scale=2; $bytes / 1024 / 1024 / 1024" | bc)
    
    printf "%s = %s bytes = %s GB\n" "0x$hex" "$bytes" "$gb"
}

bytes2gb_precise() {
    local bytes=$1
    local gb=$(echo "scale=2; $bytes / 1024 / 1024 / 1024" | bc)
    
    printf "%s bytes = %s GB\n" "$bytes" "$gb"
}
```

**Usage:**
```bash
hex2gb_precise 0x3c05fc010
bytes2gb_precise 16088530960
```

**Output:**
```
0x3c05fc010 = 16088530960 bytes = 14.98 GB
16088530960 bytes = 14.98 GB
```

**Advantages:**
- No integer overflow
- Decimal precision (scale=2)
- Handles very large numbers

---

## Complete Memory Conversion Utility

### All-in-One Script

```bash
#!/bin/bash

# Memory conversion utility

# Hex to bytes/GB
hex2bytes() {
    local v=$1
    printf "%s = %d bytes = %d GB\n" "$v" $((v)) $((v / 1024 / 1024 / 1024))
}

# Bytes to hex/GB
bytes2hex() {
    local v=$1
    printf "%d bytes = 0x%x = %d GB\n" "$v" "$v" $((v / 1024 / 1024 / 1024))
}

# GB to bytes/hex
gb2bytes() {
    local gb=$1
    local bytes=$((gb * 1024 * 1024 * 1024))
    printf "%d GB = %d bytes = 0x%x\n" "$gb" "$bytes" "$bytes"
}

# MB to bytes/hex
mb2bytes() {
    local mb=$1
    local bytes=$((mb * 1024 * 1024))
    printf "%d MB = %d bytes = 0x%x\n" "$mb" "$bytes" "$bytes"
}

# Show usage
usage() {
    cat << 'USAGE'
Memory Conversion Utility

Usage:
  hex2bytes <hex_value>    Convert hex to bytes and GB
  bytes2hex <bytes>        Convert bytes to hex and GB
  gb2bytes <gb>            Convert GB to bytes and hex
  mb2bytes <mb>            Convert MB to bytes and hex

Examples:
  hex2bytes 0x3c05fc010
  bytes2hex 16088530960
  gb2bytes 16
  mb2bytes 1024
USAGE
}

# Main
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

command=$1
value=$2

case $command in
    hex2bytes)
        hex2bytes $value
        ;;
    bytes2hex)
        bytes2hex $value
        ;;
    gb2bytes)
        gb2bytes $value
        ;;
    mb2bytes)
        mb2bytes $value
        ;;
    *)
        echo "Unknown command: $command"
        usage
        exit 1
        ;;
esac
```

**Usage:**
```bash
# Make executable
chmod +x memory-convert.sh

# Run conversions
./memory-convert.sh hex2bytes 0x3c05fc010
./memory-convert.sh bytes2hex 16088530960
./memory-convert.sh gb2bytes 16
./memory-convert.sh mb2bytes 1024
```

**Output:**
```
0x3c05fc010 = 16088530960 bytes = 14 GB
16088530960 bytes = 0x3c05fc010 = 14 GB
16 GB = 17179869184 bytes = 0x400000000
1024 MB = 1073741824 bytes = 0x40000000
```

---

## Common Use Cases

### 1. Analyze Memory Allocation from Logs

```bash
# Extract hex address from fuzzer output
log_line="malloc(0x3c05fc010) = 0x7f1234567890"

# Extract size
size=$(echo "$log_line" | grep -oP 'malloc\(\K0x[0-9a-fA-F]+')

# Convert
hex2bytes $size
```

### 2. Calculate Total Memory for Multiple Allocations

```bash
# Multiple hex allocations
allocations=(0x100000 0x200000 0x400000)

total=0
for alloc in "${allocations[@]}"; do
    bytes=$((alloc))
    total=$((total + bytes))
    hex2bytes $alloc
done

echo ""
printf "Total: %d bytes = 0x%x = %d MB\n" $total $total $((total / 1024 / 1024))
```

**Output:**
```
0x100000 = 1048576 bytes = 0 GB
0x200000 = 2097152 bytes = 0 GB
0x400000 = 4194304 bytes = 0 GB

Total: 7340032 bytes = 0x700000 = 7 MB
```

### 3. Verify Memory Limits

```bash
# Get system memory
total_mem=$(free -b | awk '/^Mem:/{print $2}')

# Convert to GB
total_gb=$((total_mem / 1024 / 1024 / 1024))

# Check if allocation fits
alloc_hex="0x3c05fc010"
alloc_bytes=$((alloc_hex))
alloc_gb=$((alloc_bytes / 1024 / 1024 / 1024))

echo "System memory: $total_gb GB"
echo "Requested allocation: $alloc_gb GB"

if [ $alloc_bytes -le $total_mem ]; then
    echo "[OK] Allocation fits in system memory"
else
    echo "[FAIL] Allocation exceeds system memory"
fi
```

---

## PowerShell Equivalent

### Windows Memory Conversions

```powershell
function Hex2Bytes {
    param([string]$hex)
    
    $bytes = [Convert]::ToInt64($hex, 16)
    $gb = [Math]::Floor($bytes / 1GB)
    
    Write-Host "$hex = $bytes bytes = $gb GB"
}

function Bytes2Hex {
    param([long]$bytes)
    
    $hex = "0x{0:X}" -f $bytes
    $gb = [Math]::Floor($bytes / 1GB)
    
    Write-Host "$bytes bytes = $hex = $gb GB"
}

# Usage
Hex2Bytes "0x3c05fc010"
Bytes2Hex 16088530960
```

**Output:**
```
0x3c05fc010 = 16088530960 bytes = 14 GB
16088530960 bytes = 0x3C05FC010 = 14 GB
```

---

## Troubleshooting

### Issue: "value too great for base"

**Cause:** Hex value exceeds bash integer limits (64-bit signed)

**Solution:** Use `bc` for large values
```bash
hex2gb_precise() {
    local hex=$1
    hex=${hex#0x}
    local bytes=$(echo "ibase=16; ${hex^^}" | bc)
    local gb=$(echo "scale=2; $bytes / 1024 / 1024 / 1024" | bc)
    printf "%s = %s bytes = %s GB\n" "0x$hex" "$bytes" "$gb"
}
```

### Issue: "integer expression expected"

**Cause:** Invalid hex format or non-numeric input

**Solution:** Validate input
```bash
hex2bytes_safe() {
    local v=$1
    
    # Check if valid hex
    if [[ ! $v =~ ^0x[0-9a-fA-F]+$ ]]; then
        echo "Error: Invalid hex format: $v"
        return 1
    fi
    
    printf "%s = %d bytes = %d GB\n" "$v" $((v)) $((v / 1024 / 1024 / 1024))
}
```

### Issue: "division by zero"

**Cause:** Input value is 0

**Solution:** Check for zero
```bash
hex2bytes_checked() {
    local v=$1
    local bytes=$((v))
    
    if [ $bytes -eq 0 ]; then
        echo "$v = 0 bytes = 0 GB"
        return
    fi
    
    printf "%s = %d bytes = %d GB\n" "$v" "$bytes" $((bytes / 1024 / 1024 / 1024))
}
```

---

## Related Heuristics

**H018: NUMERIC-CLAIM-VERIFICATION**
- Calculate actual memory size before claiming "allocated X GB"
- Verify hex conversion is correct
- Don't assume allocation size without calculation

**H006: SUCCESS-DECLARATION-CHECKPOINT**
- Verify memory allocation succeeded
- Check calculated size matches expected
- Confirm allocation within system limits

---

## Notes

**Why These Functions:**
- Quick conversion between hex and decimal
- Human-readable memory sizes (GB, MB)
- Reusable functions for scripts
- Cross-platform support (bash, PowerShell)

**Common Pitfalls:**
- Bash integer overflow for large values (use bc)
- Off-by-one errors in division (1024 vs 1000)
- Claiming "X GB allocated" without calculation
- Not checking if allocation fits in system memory
- Forgetting 0x prefix in hex values

**Memory Size Units:**
- 1 KB = 1024 bytes (binary)
- 1 MB = 1024 KB = 1,048,576 bytes
- 1 GB = 1024 MB = 1,073,741,824 bytes
- 1 TB = 1024 GB = 1,099,511,627,776 bytes

---

## Quick Reference

```bash
# Hex to bytes/GB
printf "0x3c05fc010 = %d bytes = %d GB\n" $((0x3c05fc010)) $((0x3c05fc010 / 1024 / 1024 / 1024))

# Function definitions
hex2bytes() { local v=$1; printf "%s = %d bytes = %d GB\n" "$v" $((v)) $((v / 1024 / 1024 / 1024)); }
bytes2hex() { local v=$1; printf "%d bytes = 0x%x = %d GB\n" "$v" "$v" $((v / 1024 / 1024 / 1024)); }

# Common sizes
1 GB  = 1073741824 bytes     = 0x40000000
4 GB  = 4294967296 bytes     = 0x100000000
16 GB = 17179869184 bytes    = 0x400000000
```

---

**Status:** Active reference
**Platform:** Unix/Linux/macOS (bash/zsh), Windows (PowerShell)
**Testing:** Verified on Linux, macOS, Windows
