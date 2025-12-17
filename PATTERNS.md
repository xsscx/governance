# Common Patterns Catalog

Documented usage patterns for GitHub Copilot CLI governance framework.

## Session Bootstrap

### Method 1: Direct Profile Load
```bash
source governance/scripts/load-profile.sh strict-engineering
```

Exports:
- `COPILOT_PROFILE=strict-engineering`
- `COPILOT_GOVERNANCE=~/.copilot/governance/COPILOT_GOVERNANCE.md`
- `COPILOT_VIOLATIONS_LOG=~/.copilot/violations/session-$(date +%Y%m%d-%H%M%S).jsonl`

### Method 2: Inline Profile Declaration
Paste at start of session:
```
Active Profile: strict-engineering
Max unrequested lines: 12
Code changes: Diff-only patches
Shell standards: See governance/templates/shell/
Violations log: governance/violations/session-YYYYMMDD-HHMMSS.jsonl
```

### Method 3: Reference Governance
```
Reference: governance/governance/COPILOT_GOVERNANCE.md
Profile: strict-engineering (JSON)
Enforcement: Active, log violations to JSONL
```

## Violation Recovery

### Pattern: Detect and Recover
1. **Identify violation** (scope creep, format deviation, etc.)
2. **Stop current approach**: "Stop. Violation detected: [type]"
3. **Reference pattern**: "See governance/enforcement/violation-patterns.md#[ID]"
4. **Minimal correction**: Apply only necessary changes
5. **Log violation**: Append to violations log (JSONL)

### Pattern: Pre-emptive Check
Before large operations:
```bash
governance/scripts/check-shell-prologue.sh .github/workflows/*.yml
echo "Exit code: $?"
```

Exit 0 = compliant, Exit 1 = violations found

## Code Review with Governance

### Pattern: Structured Review
1. **Load profile**: `source governance/scripts/load-profile.sh strict-engineering`
2. **Review constraints**:
   - Max 12 unrequested lines of explanation
   - Code changes as diff-only patches
   - No narrative padding, apologies, or meta-commentary
3. **Output format**:
   ```
   Issues found: [count]
   
   1. [file]:[line] - [issue] (severity: [HIGH|MEDIUM|LOW])
      Fix: [minimal diff]
   
   2. [file]:[line] - [issue]
      Fix: [minimal diff]
   ```

### Pattern: Security Review
Use `security-research` profile:
```bash
source governance/scripts/load-profile.sh security-research
```

Constraints:
- CVSS format: `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`
- No speculation on exploitability
- Evidence-only findings
- Minimal PoC code

## CI/CD Integration

### Pattern: GitHub Actions Governance Check
```yaml
# .github/workflows/governance-check.yml
name: Governance Check

on: [push, pull_request]

jobs:
  compliance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Validate shell prologues
        shell: bash --noprofile --norc {0}
        env:
          BASH_ENV: /dev/null
        run: |
          set -euo pipefail
          git config --global --add safe.directory "$GITHUB_WORKSPACE"
          git config --global credential.helper ""
          unset GITHUB_TOKEN || true
          
          governance/scripts/check-shell-prologue.sh .github/workflows/*.yml
      
      - name: Calculate compliance score
        run: |
          python3 governance/scripts/compliance-score.py session-metrics.json
```

### Pattern: Pre-commit Hook
```bash
# Install hook
ln -sf governance/templates/git-hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Test hook
git add -A
git commit -m "test: governance compliance"
```

Hook validates:
- Shell prologue presence in workflows
- File change count (scope creep detection)
- Unrequested file modifications

## Session Quality Monitoring

### Pattern: Real-time Compliance
During session, calculate score:
```bash
cat > /tmp/session-metrics.json <<EOF
{
  "corrections_required": 0,
  "unrequested_lines": 8,
  "format_deviations": 0,
  "apologies_issued": 0,
  "user_frustration_signals": 0
}
EOF

governance/scripts/compliance-score.py /tmp/session-metrics.json
```

Output: `Session Compliance Score: 84/100`

### Pattern: Violation Logging
Append to violations log:
```bash
echo '{"timestamp":"2025-02-07T19:30:00Z","type":"V-MEDIUM-001","severity":"medium","description":"Narrative padding detected","context":"Added 15 unrequested explanation lines","resolution":"Removed padding, applied strict-engineering limits"}' >> governance/violations/session-20250207-193000.jsonl
```

## Performance Optimization

### Pattern: Parallel Operations
```bash
# Load performance config from profile
source governance/scripts/load-profile.sh strict-engineering

# Use all available cores for parallel fuzzing
export AFL_THREAD_COUNT=32

# Use tmpfs for temp data
export TMPDIR=/dev/shm
```

### Pattern: Benchmark Before Changes
```bash
governance/scripts/benchmark-system.sh > baseline-perf.txt

# Make changes

governance/scripts/benchmark-system.sh > new-perf.txt
diff baseline-perf.txt new-perf.txt
```

## Fuzzing Workflow

### Pattern: AFL++ Setup
```bash
# Load security profile
source governance/scripts/load-profile.sh security-research

# Clone target
git clone https://github.com/target/repo
cd repo

# Build with instrumentation
CC=afl-clang-fast CXX=afl-clang-fast++ ./configure
make -j$(nproc)

# Run fuzzer
afl-fuzz -i input/ -o output/ -M fuzzer01 -- ./target @@

# Parallel instances (32 cores)
for i in {02..32}; do
  afl-fuzz -i input/ -o output/ -S fuzzer$i -- ./target @@ &
done
```

### Pattern: Crash Triage
```bash
# Minimize crash input
afl-tmin -i output/crashes/id:000000 -o minimized.bin -- ./target @@

# Generate PoC
gdb --batch -ex "run < minimized.bin" -ex "bt" ./target > crash-trace.txt

# CVSS scoring
echo "CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N" > cvss.txt
```

## Vulnerability Research

### Pattern: CVE Analysis
```bash
# Load security profile
source governance/scripts/load-profile.sh security-research

# Clone target at vulnerable version
git clone https://github.com/target/repo
cd repo
git checkout v1.2.3  # Vulnerable version

# Review patch
git diff v1.2.3..v1.2.4 -- path/to/vuln.c

# Build vulnerable version
./configure --enable-debug
make -j$(nproc)

# Create PoC (minimal)
cat > poc.py <<'EOF'
#!/usr/bin/env python3
import socket
s = socket.socket()
s.connect(('127.0.0.1', 8080))
s.send(b'A' * 1024)  # Trigger overflow
EOF

# Document finding
cat > CVE-YYYY-NNNNN.md <<'EOF'
# CVE-YYYY-NNNNN Analysis

**Vulnerability**: Buffer overflow in parse_header()
**CVSS**: CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N
**Affected**: v1.0.0 - v1.2.3
**Fixed**: v1.2.4 (commit abc123)

## PoC
See poc.py

## Evidence
- Crash at 0x7fff12345678
- RIP control via buffer overflow
- No ASLR/stack canary in v1.2.3
EOF
```

## Common Anti-Patterns to Avoid

### [FAIL] Anti-Pattern: Destructive Operation Without Verification
```powershell
# WRONG - no verification before destructive operation
wsl --export Ubuntu "backup.tar"
Write-Host "Backup complete!"  # Assumed success without verification
wsl --unregister Ubuntu  # DESTRUCTIVE - DATA LOSS RISK
```

### [OK] Correct: Verified Destructive Operation
```powershell
wsl --export Ubuntu "backup.tar"
if ($LASTEXITCODE -ne 0) { exit 1 }
if (-not (Test-Path "backup.tar")) { exit 1 }
$Size = (Get-Item "backup.tar").Length
if ($Size -eq 0) { exit 1 }
# Create redundant backup
Copy-Item "backup.tar" "backup-redundant.tar"
# Get user confirmation
Write-Host "Type 'PROCEED' to continue:"
$Confirm = Read-Host
if ($Confirm -ne "PROCEED") { exit 0 }
wsl --unregister Ubuntu
```

### [FAIL] Anti-Pattern: Verbose Session Start
```
Hello! I'd be happy to help you with that. Let me start by understanding 
your requirements and checking the current system state. I'll be thorough 
and make sure everything is configured correctly...
```

### [OK] Correct: Minimal Acknowledgment
```
[Immediately start with tool calls to check system state]
```

### [FAIL] Anti-Pattern: Narrative Padding
```
Now that we've successfully completed the first step, let's move on to 
the next phase. This is important because it will ensure that our changes 
are properly integrated...
```

### [OK] Correct: Direct Action
```
Next: Create profile loader script.
```

### [FAIL] Anti-Pattern: Apologetic Tone
```
I apologize for the confusion. Let me try a different approach. Sorry 
about the earlier mistake...
```

### [OK] Correct: Direct Correction
```
Correction: Use `named` service, not `bind9`.
```

### [FAIL] Anti-Pattern: Scope Creep
```
# User asks to fix DNS resolution
# Agent creates:
# - DNS configuration
# - Firewall rules
# - Network monitoring
# - Log rotation
# - Performance tuning
# - Documentation
```

### [OK] Correct: Minimal Scope
```
# User asks to fix DNS resolution
# Agent creates:
# - DNS configuration only
```

## Metrics and Thresholds

**Compliance Score Ranges:**
- 90-100: Excellent (strict adherence)
- 75-89: Good (minor deviations)
- 60-74: Fair (multiple deviations)
- <60: Poor (major violations)

**Unrequested Lines (strict-engineering):**
- Target: 0 lines
- Warning: >6 lines
- Violation: >12 lines

**Corrections Required:**
- Target: 0 corrections
- Warning: 1-2 corrections
- Violation: >3 corrections

**Format Deviations:**
- Target: 0 deviations
- Violation: Any deviation from explicit format

## References

- **Safe Operations**: `governance/templates/safe-operations/`
  - `backup-verify-restore.md` - Destructive operation pattern
  - `destructive-operation-checklist.md` - Pre-execution checklist
- Governance: `governance/governance/COPILOT_GOVERNANCE.md`
- Profiles: `governance/profiles/*.json`
- Violations: `governance/enforcement/violation-patterns.md`
- Shell standards: `governance/templates/shell/`
- Post-mortems: `governance/reports/post-mortems/`
