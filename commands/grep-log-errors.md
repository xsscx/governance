# Grep Log Files for Errors and Issues

**Purpose:** Search log files for errors, warnings, crashes, and anomalies
**Platform:** Unix/Linux/macOS (grep with extended regex)
**Status:** Verified working
**Updated:** 2026-02-07

---

## Comprehensive Error Pattern

### All Error Patterns in One Command

```bash
grep -E 'ERROR|WARN|WARNING|FAIL|FAILED|FATAL|ASSERT|ABORT|PANIC|EXCEPTION|SEGFAULT|SIG(SEGV|ABRT|BUS|ILL)|CRASH|CORE|INVALID|CORRUPT|MALFORMED|TRUNCATED|OUT OF RANGE|OVERFLOW|UNDERFLOW|UNSUPPORTED|UNKNOWN|UNDEFINED|MISMATCH|INCONSISTENT|CHECKSUM|CRC|PARSE|DECODE|ENCODE|ALLOC|FREE|LEAK|OOM|OUT OF MEMORY|NULL|NPE|TIMEOUT|DEADLOCK|HANG|RUNTIME' *.log
```

**Pattern Categories:**
- General errors: ERROR, WARN, WARNING, FAIL, FAILED, FATAL
- Program termination: ASSERT, ABORT, PANIC, EXCEPTION
- Crashes: SEGFAULT, SIG(SEGV|ABRT|BUS|ILL), CRASH, CORE
- Data issues: INVALID, CORRUPT, MALFORMED, TRUNCATED
- Range issues: OUT OF RANGE, OVERFLOW, UNDERFLOW
- Status issues: UNSUPPORTED, UNKNOWN, UNDEFINED
- Consistency: MISMATCH, INCONSISTENT
- Integrity: CHECKSUM, CRC
- Parsing: PARSE, DECODE, ENCODE
- Memory: ALLOC, FREE, LEAK, OOM, OUT OF MEMORY, NULL, NPE
- Timing: TIMEOUT, DEADLOCK, HANG
- Runtime: RUNTIME

**Use Case:** Quick scan for any kind of error in log files

---

## Categorized Error Searches

### General Errors and Warnings

```bash
grep -E 'ERROR|WARN|WARNING|FAIL|FAILED|FATAL|ASSERT|ABORT|PANIC|EXCEPTION|CRASH|CORE|RUNTIME' *.log
```

**Patterns:**
- `ERROR` - Error messages
- `WARN`, `WARNING` - Warning messages
- `FAIL`, `FAILED` - Test/operation failures
- `FATAL` - Fatal errors (program termination)
- `ASSERT` - Assertion failures
- `ABORT` - Program abort
- `PANIC` - Panic conditions
- `EXCEPTION` - Exception thrown
- `CRASH` - Program crash
- `CORE` - Core dump
- `RUNTIME` - Runtime errors

**Example Output:**
```
build.log:ERROR: Compilation failed for IccProfile.cpp
test.log:WARN: Test timeout increased to 120s
fuzzer.log:FATAL: Heap buffer overflow detected
```

---

### Signal-Related Crashes

```bash
grep -E 'SEGFAULT|SIG(SEGV|ABRT|BUS|ILL)' *.log
```

**Patterns:**
- `SEGFAULT` - Segmentation fault
- `SIGSEGV` - Signal: Segmentation violation
- `SIGABRT` - Signal: Abort
- `SIGBUS` - Signal: Bus error
- `SIGILL` - Signal: Illegal instruction

**Example Output:**
```
crash.log:SEGFAULT: Invalid memory access at 0x7f1234567890
core.log:SIGSEGV: Segmentation violation in icReadIccProfile()
sanitizer.log:SIGABRT: Abort signal raised by sanitizer
```

---

### Data Validation Errors

```bash
grep -E 'INVALID|CORRUPT|MALFORMED|TRUNCATED|UNSUPPORTED|UNKNOWN|UNDEFINED' *.log
```

**Patterns:**
- `INVALID` - Invalid input/parameter
- `CORRUPT` - Corrupted data
- `MALFORMED` - Malformed data structure
- `TRUNCATED` - Truncated file/data
- `UNSUPPORTED` - Unsupported feature/format
- `UNKNOWN` - Unknown type/value
- `UNDEFINED` - Undefined behavior

**Example Output:**
```
icc.log:INVALID: Tag type 0xFFFFFFFF not recognized
parser.log:MALFORMED: ICC profile header corrupted
validator.log:TRUNCATED: File size smaller than expected
```

---

### Parsing and Encoding Errors

```bash
grep -E 'PARSE|DECODE|ENCODE|MISMATCH|INCONSISTENT' *.log
```

**Patterns:**
- `PARSE` - Parse error
- `DECODE` - Decode failure
- `ENCODE` - Encode failure
- `MISMATCH` - Data mismatch
- `INCONSISTENT` - Inconsistent state

**Example Output:**
```
xml.log:PARSE: XML parsing failed at line 42
codec.log:DECODE: Failed to decode JPEG image
validator.log:MISMATCH: Expected 256 entries, found 128
```

---

### Numeric Range Errors

```bash
grep -E 'OVERFLOW|UNDERFLOW|OUT OF RANGE' *.log
```

**Patterns:**
- `OVERFLOW` - Arithmetic overflow
- `UNDERFLOW` - Arithmetic underflow
- `OUT OF RANGE` - Value out of valid range

**Example Output:**
```
math.log:OVERFLOW: Integer overflow in multiplication
float.log:UNDERFLOW: Floating point underflow detected
bounds.log:OUT OF RANGE: Index 512 exceeds maximum 255
```

---

### Memory-Related Errors

```bash
grep -E 'ALLOC|FREE|LEAK|OOM|OUT OF MEMORY|NULL' *.log
```

**Patterns:**
- `ALLOC` - Allocation failure/message
- `FREE` - Free error/double-free
- `LEAK` - Memory leak
- `OOM`, `OUT OF MEMORY` - Out of memory
- `NULL` - Null pointer dereference

**Example Output:**
```
malloc.log:ALLOC: Failed to allocate 16GB memory
sanitizer.log:LEAK: Memory leak detected: 1024 bytes
error.log:NULL: Null pointer dereference at 0x0
```

---

### Data Integrity Errors

```bash
grep -E 'CHECKSUM|CRC' *.log
```

**Patterns:**
- `CHECKSUM` - Checksum mismatch
- `CRC` - CRC error

**Example Output:**
```
verify.log:CHECKSUM: MD5 checksum mismatch
integrity.log:CRC: CRC32 verification failed
```

---

### Timing and Concurrency Errors

```bash
grep -E 'TIMEOUT|DEADLOCK|HANG' *.log
```

**Patterns:**
- `TIMEOUT` - Operation timeout
- `DEADLOCK` - Deadlock detected
- `HANG` - Program hang

**Example Output:**
```
test.log:TIMEOUT: Test exceeded 60 second timeout
threading.log:DEADLOCK: Deadlock detected in mutex acquisition
monitor.log:HANG: Process appears to be hung
```

---

## Enhanced Search Commands

### Case-Insensitive Search

```bash
grep -iE 'error|warn|fail|crash' *.log
```

**Flags:**
- `-i` - Case-insensitive matching
- `-E` - Extended regex

**Use Case:** Catch errors with inconsistent capitalization (Error, ERROR, error)

---

### Show Line Numbers

```bash
grep -nE 'ERROR|WARN|FAIL' *.log
```

**Flags:**
- `-n` - Show line numbers

**Example Output:**
```
build.log:42:ERROR: Compilation failed
build.log:156:WARN: Deprecated function used
test.log:89:FAIL: Test case failed
```

---

### Show Context Lines

```bash
# Show 3 lines before and after match
grep -C 3 -E 'ERROR|CRASH' *.log

# Show 5 lines after match
grep -A 5 -E 'FATAL|SEGFAULT' *.log

# Show 2 lines before match
grep -B 2 -E 'WARN|FAIL' *.log
```

**Flags:**
- `-C N` - Show N lines before and after match
- `-A N` - Show N lines after match
- `-B N` - Show N lines before match

**Use Case:** Get context around errors for debugging

---

### Count Matches

```bash
grep -c -E 'ERROR|WARN|FAIL' *.log
```

**Flags:**
- `-c` - Count matching lines (not occurrences)

**Example Output:**
```
build.log:12
test.log:5
fuzzer.log:0
```

---

### Invert Match (Show Non-Errors)

```bash
grep -vE 'ERROR|WARN|FAIL' *.log
```

**Flags:**
- `-v` - Invert match (show non-matching lines)

**Use Case:** Filter out error lines to see normal operation

---

### Recursive Directory Search

```bash
grep -r -E 'ERROR|WARN|FAIL' ./logs/
```

**Flags:**
- `-r` - Recursive search in directories

**Use Case:** Search all log files in directory tree

---

## Complete Error Analysis Script

### Categorized Error Report

```bash
#!/bin/bash

# Log error analysis script

log_dir="${1:-.}"  # Default to current directory

echo "==================================================================="
echo "Log Error Analysis"
echo "==================================================================="
echo ""

# 1. General errors
echo "=== General Errors and Warnings ==="
count=$(grep -rhE 'ERROR|WARN|WARNING|FAIL|FAILED|FATAL' "$log_dir"/*.log 2>/dev/null | wc -l)
echo "Found $count general errors/warnings"
if [ $count -gt 0 ]; then
    grep -rnE 'ERROR|WARN|WARNING|FAIL|FAILED|FATAL' "$log_dir"/*.log 2>/dev/null | head -10
fi
echo ""

# 2. Crashes
echo "=== Crashes and Signals ==="
count=$(grep -rhE 'SEGFAULT|SIG(SEGV|ABRT|BUS|ILL)|CRASH|CORE' "$log_dir"/*.log 2>/dev/null | wc -l)
echo "Found $count crash-related errors"
if [ $count -gt 0 ]; then
    grep -rnE 'SEGFAULT|SIG(SEGV|ABRT|BUS|ILL)|CRASH|CORE' "$log_dir"/*.log 2>/dev/null
fi
echo ""

# 3. Memory errors
echo "=== Memory Errors ==="
count=$(grep -rhE 'LEAK|OOM|OUT OF MEMORY|NULL' "$log_dir"/*.log 2>/dev/null | wc -l)
echo "Found $count memory-related errors"
if [ $count -gt 0 ]; then
    grep -rnE 'LEAK|OOM|OUT OF MEMORY|NULL' "$log_dir"/*.log 2>/dev/null
fi
echo ""

# 4. Data validation
echo "=== Data Validation Errors ==="
count=$(grep -rhE 'INVALID|CORRUPT|MALFORMED|TRUNCATED' "$log_dir"/*.log 2>/dev/null | wc -l)
echo "Found $count validation errors"
if [ $count -gt 0 ]; then
    grep -rnE 'INVALID|CORRUPT|MALFORMED|TRUNCATED' "$log_dir"/*.log 2>/dev/null | head -10
fi
echo ""

# 5. Summary by file
echo "=== Error Count by File ==="
for log in "$log_dir"/*.log; do
    if [ -f "$log" ]; then
        count=$(grep -cE 'ERROR|WARN|FAIL|CRASH|SEGFAULT' "$log" 2>/dev/null)
        if [ $count -gt 0 ]; then
            echo "$log: $count errors"
        fi
    fi
done
echo ""

echo "==================================================================="
echo "Analysis Complete"
echo "==================================================================="
```

**Usage:**
```bash
chmod +x analyze-logs.sh
./analyze-logs.sh ./logs/
./analyze-logs.sh .
```

**Expected Output:**
```
===================================================================
Log Error Analysis
===================================================================

=== General Errors and Warnings ===
Found 23 general errors/warnings
build.log:42:ERROR: Compilation failed for IccProfile.cpp
test.log:156:WARN: Test timeout increased
fuzzer.log:89:FATAL: Heap buffer overflow detected
...

=== Crashes and Signals ===
Found 3 crash-related errors
crash.log:12:SEGFAULT: Invalid memory access at 0x7f1234567890
sanitizer.log:45:SIGABRT: Abort signal raised

=== Memory Errors ===
Found 5 memory-related errors
malloc.log:78:LEAK: Memory leak detected: 1024 bytes
...

=== Data Validation Errors ===
Found 12 validation errors
icc.log:234:INVALID: Tag type 0xFFFFFFFF not recognized
...

=== Error Count by File ===
build.log: 12 errors
test.log: 8 errors
fuzzer.log: 15 errors

===================================================================
Analysis Complete
===================================================================
```

---

## Common Use Cases

### 1. Quick Error Check After Build

```bash
# Check build logs for errors
grep -E 'ERROR|FATAL|FAIL' build.log

# Count errors
grep -cE 'ERROR|FATAL|FAIL' build.log
```

### 2. Find Specific Error Type

```bash
# Find memory leaks
grep -nE 'LEAK|memory leak' asan.log

# Find segmentation faults
grep -C 5 -E 'SEGFAULT|SIGSEGV' crash.log

# Find parse errors
grep -E 'PARSE.*error|parsing failed' xml.log
```

### 3. Compare Error Counts Across Runs

```bash
# Count errors in multiple log files
for log in run*.log; do
    count=$(grep -cE 'ERROR|FAIL' "$log")
    echo "$log: $count errors"
done
```

### 4. Extract Error Lines to File

```bash
# Save all errors to separate file
grep -hE 'ERROR|WARN|FAIL|CRASH' *.log > errors-summary.txt

# Sort and count unique errors
grep -hE 'ERROR' *.log | sort | uniq -c | sort -rn > error-counts.txt
```

---

## PowerShell Equivalent

### Windows Error Searching

```powershell
# Search for errors in log files
Get-Content *.log | Select-String -Pattern 'ERROR|WARN|FAIL|CRASH'

# Case-insensitive search
Get-Content *.log | Select-String -Pattern 'ERROR|WARN|FAIL' -CaseSensitive:$false

# Show file name and line number
Get-ChildItem *.log | Select-String -Pattern 'ERROR|WARN|FAIL'

# Count matches
(Get-Content *.log | Select-String -Pattern 'ERROR|WARN|FAIL').Count

# Show context (3 lines before and after)
Get-Content *.log | Select-String -Pattern 'ERROR|CRASH' -Context 3
```

---

## Troubleshooting

### Issue: "grep: invalid option"

**Cause:** Using `-E` flag not supported by grep version

**Solution:** Use `egrep` instead
```bash
egrep 'ERROR|WARN|FAIL' *.log
```

### Issue: "No such file or directory"

**Cause:** No .log files in directory

**Solution:** Check file extension or use broader pattern
```bash
# Check if log files exist
ls *.log

# Search all files
grep -E 'ERROR|WARN' *

# Search with different extension
grep -E 'ERROR|WARN' *.txt
```

### Issue: "Binary file matches"

**Cause:** grep detects binary content in file

**Solution:** Force text mode
```bash
grep -a -E 'ERROR|WARN' *.log
```

### Issue: "Argument list too long"

**Cause:** Too many files matching *.log

**Solution:** Use find with exec
```bash
find . -name "*.log" -exec grep -E 'ERROR|WARN|FAIL' {} +
```

---

## Related Heuristics

**H019: LOGS-FIRST-PROTOCOL**
- Check logs before claiming success
- Use grep to verify no errors before reporting "build succeeded"
- Count actual errors vs claimed errors

**H006: SUCCESS-DECLARATION-CHECKPOINT**
- Grep logs for errors before declaring success
- Don't claim "no errors" without checking logs
- Verify error count is 0

**H018: NUMERIC-CLAIM-VERIFICATION**
- Count actual errors: `grep -c`
- Don't claim "N errors" without counting
- Compare expected vs actual error counts

---

## Notes

**Why These Patterns:**
- Covers common error keywords across languages and tools
- Extended regex for flexible matching
- Organized by error category for systematic analysis
- Cross-platform support (grep, PowerShell)

**Common Pitfalls:**
- Claiming "no errors" without grepping logs
- Missing errors due to case sensitivity (use -i)
- Not checking multiple log files
- Ignoring warnings (can indicate future errors)
- Not getting context around errors (-C flag)

**Error Categories:**
- Fatal: ERROR, FATAL, CRASH, SEGFAULT
- Warnings: WARN, WARNING
- Failures: FAIL, FAILED
- Data: INVALID, CORRUPT, MALFORMED
- Memory: LEAK, OOM, NULL
- Integrity: CHECKSUM, CRC

---

## Quick Reference

```bash
# All errors (one command)
grep -E 'ERROR|WARN|FAIL|CRASH|SEGFAULT|LEAK|INVALID|OVERFLOW|TIMEOUT' *.log

# Categorized searches
grep -E 'ERROR|WARN|WARNING|FAIL|FAILED|FATAL' *.log
grep -E 'SEGFAULT|SIG(SEGV|ABRT|BUS|ILL)' *.log
grep -E 'INVALID|CORRUPT|MALFORMED|TRUNCATED' *.log
grep -E 'PARSE|DECODE|ENCODE|MISMATCH' *.log
grep -E 'OVERFLOW|UNDERFLOW|OUT OF RANGE' *.log
grep -E 'ALLOC|FREE|LEAK|OOM|NULL' *.log
grep -E 'CHECKSUM|CRC' *.log
grep -E 'TIMEOUT|DEADLOCK|HANG' *.log

# With line numbers and context
grep -nC 3 -E 'ERROR|CRASH' *.log

# Count errors
grep -cE 'ERROR|FAIL' *.log

# Recursive search
grep -rE 'ERROR|WARN' ./logs/
```

---

**Status:** Active reference
**Platform:** Unix/Linux/macOS (grep), Windows (PowerShell)
**Testing:** Verified on Linux, macOS, Windows
