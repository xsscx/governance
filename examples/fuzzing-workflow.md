# Security Fuzzing Workflow Guide

Complete workflow for fuzzing security-critical software with governance compliance.

## Profile Configuration

```bash
source ~/.copilot/scripts/load-profile.sh security-research
```

Enforces:
- CVSS 4.0 format compliance
- Evidence-only findings
- Minimal PoC code
- No exploit speculation

## Target Selection

### Criteria
1. **Security-critical**: Authentication, parsing, network protocols
2. **Attack surface**: Network-accessible, handles untrusted input
3. **History**: Prior CVEs, complex codebase
4. **Impact**: High CVSS score potential

### Example Targets
- DNS servers (BIND, dnsmasq, unbound)
- HTTP parsers (nginx, Apache, libcurl)
- Image libraries (libjpeg, libpng, ImageMagick)
- Archive tools (tar, unzip, 7zip)
- Media codecs (ffmpeg, libvpx, libwebp)

## Environment Setup

### Install AFL++
```bash
cd ~/fuzzing
git clone https://github.com/AFLplusplus/AFLplusplus
cd AFLplusplus
make -j$(nproc)
sudo make install
```

### System Configuration
```bash
# Core dumps
echo core | sudo tee /proc/sys/kernel/core_pattern

# CPU scaling
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Performance mode
~/.copilot/scripts/enable-performance-mode.sh
```

## Build Instrumentation

### Compile with AFL++
```bash
cd ~/fuzzing/target-project
export CC=afl-clang-fast
export CXX=afl-clang-fast++
export AFL_USE_ASAN=1  # AddressSanitizer

./configure --enable-static --disable-shared
make clean
make -j$(nproc)
```

### Verify Instrumentation
```bash
afl-showmap -o /dev/null -- ./target-binary < /dev/null
# Should show: "Captured X tuples"
```

## Input Corpus

### Seed Files
```bash
mkdir -p input/
cd input/

# Minimal valid inputs
echo -n "GET / HTTP/1.0\r\n\r\n" > http-get.txt
echo -n '{"key":"value"}' > json-minimal.json

# Edge cases
dd if=/dev/zero bs=1 count=0 of=empty.bin
dd if=/dev/zero bs=1 count=1024 of=1kb.bin
```

### Corpus Minimization
```bash
afl-cmin -i input-raw/ -o input/ -- ./target @@
```

## Parallel Fuzzing

### 32-Core Configuration
```bash
export AFL_THREAD_COUNT=32
export TMPDIR=/dev/shm  # Use RAM disk

# Master instance
afl-fuzz -i input/ -o output/ -M fuzzer01 -t 1000 -- ./target @@

# Slave instances
for i in $(seq -w 02 32); do
  afl-fuzz -i input/ -o output/ -S fuzzer${i} -t 1000 -- ./target @@ &
done
```

### Monitor Progress
```bash
watch -n 5 'afl-whatsup output/'
```

Key metrics:
- **execs/sec**: Target >1000/sec per instance
- **paths**: New coverage discovered
- **crashes**: Unique crashes found
- **stability**: Should be >95%

## Crash Triage

### Reproduce Crash
```bash
cd output/fuzzer01/crashes/

# Test crash
./target < id:000000,sig:11,src:000000,time:12345,op:havoc,rep:4

# With GDB
gdb --args ./target
(gdb) run < id:000000,sig:11,src:000000,time:12345,op:havoc,rep:4
(gdb) bt full
```

### Minimize Crash Input
```bash
afl-tmin -i crashes/id:000000,* -o crash-minimized.bin -- ./target @@
```

### Deduplicate Crashes
```bash
# Group by unique stack trace
for crash in crashes/id:*; do
  gdb --batch -ex "run < $crash" -ex "bt" ./target 2>&1 | \
    sha256sum >> crash-hashes.txt
done

sort crash-hashes.txt | uniq > unique-crashes.txt
```

## Vulnerability Analysis

### Classify Crash
```bash
# Check crash type
exploitable --crash-dir output/crashes/ ./target

# Types:
# - EXPLOITABLE: High confidence (heap overflow, UAF, format string)
# - PROBABLY_EXPLOITABLE: Medium confidence (stack overflow, null deref)
# - PROBABLY_NOT_EXPLOITABLE: Low confidence (assert, divide by zero)
# - UNKNOWN: Needs manual analysis
```

### Root Cause Analysis
```bash
# Build with debug symbols
./configure CFLAGS="-g -O0"
make clean && make -j$(nproc)

# Analyze with Valgrind
valgrind --leak-check=full --track-origins=yes ./target < crash-minimized.bin

# ASan output
ASAN_OPTIONS=symbolize=1 ./target < crash-minimized.bin
```

### CVSS Scoring
```
CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N

Components:
- AV (Attack Vector): N=Network, A=Adjacent, L=Local, P=Physical
- AC (Attack Complexity): L=Low, H=High
- AT (Attack Requirements): N=None, P=Present
- PR (Privileges Required): N=None, L=Low, H=High
- UI (User Interaction): N=None, P=Passive, A=Active
- VC/VI/VA (Vulnerable System Confidentiality/Integrity/Availability): H/L/N
- SC/SI/SA (Subsequent System Confidentiality/Integrity/Availability): H/L/N
```

## PoC Development

### Minimal PoC (Python)
```python
#!/usr/bin/env python3
import socket

# Trigger buffer overflow in HTTP header parser
payload = b'GET / HTTP/1.1\r\n'
payload += b'Host: ' + b'A' * 8192 + b'\r\n'
payload += b'\r\n'

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('127.0.0.1', 8080))
s.send(payload)
s.close()
```

### Minimal PoC (C)
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(void) {
    char buf[8192];
    memset(buf, 'A', sizeof(buf));
    
    FILE *fp = fopen("/tmp/poc.bin", "wb");
    fwrite(buf, 1, sizeof(buf), fp);
    fclose(fp);
    
    return 0;
}
```

## Disclosure

### Report Template
```markdown
# Vulnerability Report

**Title**: Buffer overflow in parse_http_header()
**Component**: HTTP parser (src/http.c:123)
**Version**: 1.2.3
**CVSS**: CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N
**CWE**: CWE-120 (Buffer Overflow)

## Description
The HTTP header parser does not validate the length of the Host header,
allowing a remote attacker to overflow a stack buffer.

## PoC
See attached poc.py

## Impact
Remote code execution via crafted HTTP request.

## Suggested Fix
Add bounds checking in parse_http_header():
```diff
- strcpy(host_buf, header_value);
+ strncpy(host_buf, header_value, sizeof(host_buf) - 1);
+ host_buf[sizeof(host_buf) - 1] = '\0';
```

## Timeline
- 2025-02-07: Discovered via fuzzing
- 2025-02-07: Vendor notified
- 2025-02-XX: CVE assigned
- 2025-XX-XX: Public disclosure (90 days)
```

### Responsible Disclosure
1. **Notify vendor**: security@vendor.com
2. **Wait 90 days**: Allow time for patch development
3. **Request CVE**: Via MITRE or vendor CNA
4. **Coordinate disclosure**: Align with vendor release
5. **Public disclosure**: Blog post, conference talk

## Continuous Fuzzing

### Automation Script
```bash
#!/bin/bash
# continuous-fuzz.sh
set -euo pipefail

TARGET="./target-binary"
INPUT_DIR="input/"
OUTPUT_DIR="output/"

# Load performance config
source ~/.copilot/scripts/load-profile.sh security-research

# Start fuzzing
afl-fuzz -i "$INPUT_DIR" -o "$OUTPUT_DIR" -M fuzzer01 -t 1000 -- "$TARGET" @@ &

for i in $(seq -w 02 32); do
  afl-fuzz -i "$INPUT_DIR" -o "$OUTPUT_DIR" -S fuzzer${i} -t 1000 -- "$TARGET" @@ &
done

# Monitor crashes
while true; do
  CRASHES=$(find "$OUTPUT_DIR" -name 'id:*' -path '*/crashes/*' | wc -l)
  
  if [ "$CRASHES" -gt 0 ]; then
    echo "[$(date)] Found $CRASHES crashes, triaging..."
    ./triage-crashes.sh
  fi
  
  sleep 3600  # Check hourly
done
```

## Performance Tuning

### AFL++ Options
```bash
export AFL_FAST_CAL=1           # Faster calibration
export AFL_DISABLE_TRIM=1       # Skip trimming (speed)
export AFL_CMPLOG_ONLY_NEW=1    # Optimize cmplog
export AFL_FORKSRV_INIT_TMOUT=10000  # Longer timeout
```

### CPU Pinning
```bash
# Pin fuzzer instances to specific cores
taskset -c 0-7 afl-fuzz -i input/ -o output/ -M fuzzer01 -- ./target @@ &
taskset -c 8-15 afl-fuzz -i input/ -o output/ -S fuzzer02 -- ./target @@ &
# ... repeat for all cores
```

## Common Issues

### Low Execution Speed
- Disable ASAN if not needed: `unset AFL_USE_ASAN`
- Use persistent mode: `afl-clang-fast -DAFL_LOOP=1000`
- Reduce timeout: `-t 100` (100ms)

### No New Paths
- Seed corpus too large: Minimize with `afl-cmin`
- Target deterministic: Add `-d` flag for deterministic fuzzing
- Need dictionary: Create with `afl-showmap` or manually

### Crashes Not Unique
- Same root cause: Normal, deduplicate by stack trace
- ASAN finds more: ASAN detects issues normal build misses

## References

- AFL++ docs: https://github.com/AFLplusplus/AFLplusplus/blob/stable/docs/
- CVSS 4.0 calculator: https://www.first.org/cvss/calculator/4.0
- CWE database: https://cwe.mitre.org/
- CVE request: https://cveform.mitre.org/
- Governance: `~/.copilot/governance/COPILOT_GOVERNANCE.md`
- Profile: `~/.copilot/profiles/security-research.json`
