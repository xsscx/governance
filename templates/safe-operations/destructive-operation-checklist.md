# Destructive Operation Checklist

**Before executing ANY destructive operation (delete, unregister, drop, format, etc.)**

---

## Pre-Execution Verification

### 1. Backup Created
- [ ] Backup/export command executed
- [ ] Exit code checked: `$LASTEXITCODE -eq 0` (PowerShell) or `$? -eq 0` (Bash)
- [ ] No errors in command output

### 2. Backup File Verified
- [ ] File exists: `Test-Path <file>` (PowerShell) or `[ -f <file> ]` (Bash)
- [ ] File size > 0 bytes
- [ ] File size matches expected size

### 3. Redundant Backup Created
- [ ] Second backup created in different location
- [ ] Second backup verified (exists, size matches)
- [ ] Checksums match (if applicable)

### 4. Integrity Check
- [ ] Test restoration performed (if possible)
- [ ] Restored data verified
- [ ] Test cleanup completed

### 5. User Confirmation
- [ ] Verification results presented to user
- [ ] Explicit user approval obtained
- [ ] User typed confirmation keyword (e.g., "PROCEED", "DELETE")

---

## Execution

### 6. Destructive Operation
- [ ] User confirmation received
- [ ] Destructive command executed
- [ ] Exit code checked
- [ ] Success verified

### 7. Post-Execution Verification
- [ ] Restoration from backup tested (if applicable)
- [ ] Restored system functional
- [ ] Backups retained for 7+ days

---

## Abort Conditions

**ABORT immediately if:**
- Exit code != 0
- Backup file does not exist
- Backup file size = 0
- Backup file size unexpected
- Redundant backup failed
- Test restoration failed
- User does not confirm

---

## Example: WSL Migration

```powershell
# 1. Backup
wsl --export Ubuntu-24.04 "C:\backup\ubuntu.tar"
if ($LASTEXITCODE -ne 0) { exit 1 }

# 2. Verify
if (-not (Test-Path "C:\backup\ubuntu.tar")) { exit 1 }
$Size = (Get-Item "C:\backup\ubuntu.tar").Length
if ($Size -eq 0) { exit 1 }

# 3. Redundant backup
Copy-Item "C:\backup\ubuntu.tar" "E:\backup\ubuntu.tar"
if (-not (Test-Path "E:\backup\ubuntu.tar")) { exit 1 }

# 4. User confirmation
Write-Host "Backups verified. Type 'PROCEED' to continue:"
$Confirm = Read-Host
if ($Confirm -ne "PROCEED") { exit 0 }

# 5. Execute destructive operation
wsl --unregister Ubuntu-24.04
```

---

**Violation if checklist not followed**: V-CRITICAL-004  
**Reference**: `templates/safe-operations/backup-verify-restore.md`
