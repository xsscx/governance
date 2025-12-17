# Troubleshooting Guide

**Purpose:** Common issues and solutions for Copilot Governance  
**Version:** 2.0  
**Date:** 2026-01-11

---

## Quick Diagnostics

```bash
# Run test suite
~/governance/tests/run-all-tests.sh

# Check profile
cat ~/governance/profiles/strict-engineering.json | python3 -m json.tool

# Verify scripts
ls -la ~/governance/scripts/*.sh
```

## OOM Issues

The Governance Runtime may need addiitonal memory: `export NODE_OPTIONS="--max-old-space-size=8192"`


---

## Common Issues

### Issue 1: Profile Not Loading

**Symptoms:**
- Error: "Profile not found"
- No constraints displayed
- Environment variables not set

**Diagnosis:**
```bash
# Check if profile exists
ls -la ~/governance/profiles/

# Verify JSON syntax
python3 -m json.tool ~/governance/profiles/strict-engineering.json
```

**Solutions:**
```bash
# Fix 1: Profile file missing
# Re-run Phase 1 implementation or copy from llmcjf

# Fix 2: Invalid JSON syntax
# Validate and fix JSON errors

# Fix 3: Wrong profile name
source ~/governance/scripts/load-profile.sh strict-engineering
# Note: Use exact profile name (case-sensitive)
```

---

### Issue 2: Git Hooks Not Running

**Symptoms:**
- Commits succeed with violations
- No governance checks at commit time
- Hooks not executed

**Diagnosis:**
```bash
# Check if hooks exist
ls -la .git/hooks/

# Verify hook is executable
ls -la .git/hooks/pre-commit

# Test hook manually
.git/hooks/pre-commit
```

**Solutions:**
```bash
# Fix 1: Hook not installed
ln -s ~/governance/templates/git-hooks/pre-commit .git/hooks/pre-commit
chmod +x .~/governance/hooks/pre-commit

# Fix 2: Hook not executable
chmod +x ~/governance/hooks/pre-commit

# Fix 3: Bypass hooks (if needed for emergency)
git commit --no-verify
```

---

### Issue 3: Shell Prologue Validation Fails

**Symptoms:**
- Git pre-commit hook blocks commits
- False positive violations
- Workflow files flagged incorrectly

**Diagnosis:**
```bash
# Check specific workflow file
grep -A5 "shell:" .github/workflows/your-workflow.yml

# Run checker manually
~/governance/scripts/check-shell-prologue.sh
```

**Solutions:**
```bash
# Fix 1: Missing bash flags
# Change from:
shell: bash
# To:
shell: bash --noprofile --norc {0}

# Fix 2: Missing BASH_ENV
# Add to workflow step:
env:
  BASH_ENV: /dev/null

# Fix 3: Missing error handling
# Add to run block:
run: |
  set -euo pipefail
  # your commands
```

**Template:**
```yaml
- name: Your Step
  shell: bash --noprofile --norc {0}
  env:
    BASH_ENV: /dev/null
  run: |
    set -euo pipefail
    git config --global --add safe.directory "$GITHUB_WORKSPACE"
    git config --global credential.helper ""
    unset GITHUB_TOKEN || true
    # your commands
```

---

### Issue 4: Compliance Score Unexpectedly Low

**Symptoms:**
- Score <60 despite good session
- Metrics don't match perception
- Unexpected violations counted

**Diagnosis:**
```bash
# Check metrics file
cat session-metrics.json | python3 -m json.tool

# Calculate score manually
~/governance/scripts/compliance-score.py session-metrics.json
```

**Understanding Scoring:**
```
Base: 100 points

Deductions:
- User corrections: -20 per correction
- Unrequested lines: -2 per line
- Format deviations: -15 per deviation
- Apologies: -5 per apology
- Frustration signals: -10 per signal
- Compression <0.5: -20

Example:
- 2 corrections → -40
- 15 unrequested lines → -30
- 1 format deviation → -15
- Score: 100 - 85 = 15/100 (FAILED)
```

**Solutions:**
- Aim for 0 user corrections
- Keep unrequested changes ≤12 lines
- Apply user formats exactly
- No apologies without fixes

---

### Issue 5: Violation False Positives

**Symptoms:**
- Correct behavior flagged as violation
- Valid changes blocked
- Over-sensitive detection

**Diagnosis:**
```bash
# Check violation patterns
grep "V-CRITICAL" ~/governance/enforcement/violation-patterns.md

# Review session log
cat ~/governance/violations/*.jsonl | tail -10
```

**Solutions:**
```bash
# Fix 1: Adjust detection thresholds
# Edit profile:
vi ~/governance/profiles/strict-engineering.json
# Change max_unrequested_lines from 12 to 20

# Fix 2: Whitelist specific patterns
# Add exceptions to detection rules

# Fix 3: Disable specific checks
# Comment out overly strict rules in hooks
```

---

### Issue 6: Python/jq Command Not Found

**Symptoms:**
- Error: "jq: command not found"
- Error: "python3: command not found"
- Scripts fail to run

**Solutions:**
```bash
# Install jq (Ubuntu/Debian)
sudo apt install jq

# Install Python 3
sudo apt install python3

# Alternative: Use scripts without jq dependency
# Most scripts have fallback behavior
```

---

### Issue 7: Performance Issues

**Symptoms:**
- Profile loading slow (>1 second)
- Git hooks timeout
- Compliance checks slow

**Diagnosis:**
```bash
# Benchmark system
~/governance/scripts/benchmark-system.sh

# Time profile load
time source ~/governance/scripts/load-profile.sh strict-engineering
```

**Solutions:**
```bash
# Fix 1: Use fast mode
source ~/governance/scripts/enable-performance-mode.sh

# Fix 2: Skip JSON parsing
# Use simplified profile loader

# Fix 3: Use RAM disk for logs
export COPILOT_VIOLATIONS_LOG="/dev/shm/violations.jsonl"
```

---

### Issue 8: Data Loss from Destructive Operation

**Symptoms:**
- Destructive command executed without backup verification
- Backup file missing or corrupted
- Original data permanently deleted
- No recovery possible

**Prevention:**
```powershell
# ALWAYS follow safe destructive operation pattern
# See: ~/governance/templates/safe-operations/backup-verify-restore.md

# 1. Create backup
wsl --export Ubuntu "backup.tar"

# 2. MANDATORY verification
if ($LASTEXITCODE -ne 0) { Write-Error "Backup failed"; exit 1 }
if (-not (Test-Path "backup.tar")) { Write-Error "File missing"; exit 1 }
if ((Get-Item "backup.tar").Length -eq 0) { Write-Error "Empty file"; exit 1 }

# 3. Redundant backup
Copy-Item "backup.tar" "backup-redundant.tar"

# 4. User confirmation
Write-Host "Type 'PROCEED' to continue:"
$Confirm = Read-Host
if ($Confirm -ne "PROCEED") { exit 0 }

# 5. Execute destructive operation
wsl --unregister Ubuntu
```

**Recovery (if too late):**
- Check Recycle Bin
- Use file recovery software on source drive
- Restore from system backups (if enabled)
- Contact data recovery service (expensive)

**Violations:**
- V-CRITICAL-004: Destructive Operation Without Verification
- V-CRITICAL-005: Exit Code Assumption
- CJF-09: Destructive Operation Without Verified Backup

**Reference:**
- Post-Mortem: `~/governance/reports/LLMCJF_PostMortem_17JAN2026_WSL_Data_Loss.md`
- Pattern: `~/governance/templates/safe-operations/backup-verify-restore.md`
- Checklist: `~/governance/templates/safe-operations/destructive-operation-checklist.md`

---

### Issue 9: BIND Not Starting (DNS Issue)

**Symptoms:**
- service named status shows "not running"
- DNS queries fail
- /run/named missing

**Diagnosis:**
```bash
# Check BIND status
service named status

# Check directory
ls -la /run/named

# Check logs
tail -50 /var/log/syslog | grep named
```

**Solutions:**
```bash
# Fix 1: Create runtime directory
sudo mkdir -p /run/named
sudo chown root:bind /run/named
sudo chmod 775 /run/named

# Fix 2: Start BIND
sudo service named start

# Fix 3: Check WSL boot script
cat /etc/wsl.conf
ls -la ~/wsl-bind-boot.sh

# See: ~/governance/examples/dns-bind-setup.md
```

---

## Error Messages

### "Deviation prevented (governance active)"

**Meaning:** Governance framework blocked non-compliant action  
**Action:** Review what was requested vs what was attempted  
**Fix:** Follow governance constraints (minimal delta, user authority, etc.)

### "Profile not found: [name]"

**Meaning:** Specified profile doesn't exist  
**Action:** List available profiles  
**Fix:** `ls ~/governance/profiles/` to see valid names

### "Syntax error in sudoers file"

**Meaning:** Invalid /etc/sudoers.d/ entry  
**Action:** DO NOT SAVE - will break sudo  
**Fix:** Validate with `visudo -c -f /path/to/file` before installing

---

## Verification Checklist

After troubleshooting, verify:

- [ ] Profile loads without error
- [ ] Git hooks execute on commit
- [ ] Shell prologue checker runs clean
- [ ] Compliance score calculates correctly
- [ ] Test suite passes
- [ ] BIND service running (if applicable)
- [ ] No false positive violations

---

## Getting Help

### Self-Help Resources
1. Read: `~/governance/README.md`
2. Examples: `~/governance/examples/`
3. Run tests: `~/governance/tests/run-all-tests.sh`
4. Check logs: `~/governance/violations/*.jsonl`

### Debug Mode
```bash
# Enable verbose output
set -x

# Run command
source ~/governance/scripts/load-profile.sh strict-engineering

# Disable verbose
set +x
```

### Report Issues
Document:
- Error message (exact text)
- Command run
- Expected vs actual behavior
- Environment (WSL2, Ubuntu version)
- Test results

---

## Emergency Recovery

### Reset Governance
```bash
# Backup current state
cp -r ~/governance ~/governance.backup

# Remove and reinstall
rm -rf ~/governance
# Re-run Phase 1 & 2 implementation
```

### Bypass All Checks (Emergency Only)
```bash
# Git commits
git commit --no-verify

# Disable hooks temporarily
mv .git/hooks/pre-commit .git/hooks/pre-commit.disabled

# Re-enable after emergency
mv .git/hooks/pre-commit.disabled .git/hooks/pre-commit
```

---

**Last Updated:** 2026-01-11  
**Status:** Active  
**Maintenance:** Update as new issues discovered
