# Safe Backup-Verify-Restore Pattern

**Purpose**: Prevent data loss during destructive operations  
**Applies to**: WSL migrations, database operations, file system modifications, registry changes  
**Severity if violated**: CRITICAL (permanent data loss)

---

## Overview

Any destructive operation MUST follow this pattern:
1. **Backup**: Create verified backup
2. **Verify**: Confirm backup integrity
3. **Redundancy**: Create second backup
4. **Approval**: Obtain user confirmation
5. **Execute**: Perform destructive operation
6. **Restore Test**: Verify restoration works
7. **Cleanup**: Delete backups only after verification

---

## Pattern: PowerShell

### Phase 1: Verified Backup Creation

```powershell
# Export/backup with explicit error handling
wsl --export Ubuntu-24.04 "C:\backup\ubuntu.tar"

# MANDATORY: Check exit code
if ($LASTEXITCODE -ne 0) {
  Write-Error "Export failed with exit code $LASTEXITCODE - ABORTING"
  exit 1
}

# MANDATORY: Verify file exists
if (-not (Test-Path "C:\backup\ubuntu.tar")) {
  Write-Error "Export reported success but file not found - ABORTING"
  exit 1
}

# MANDATORY: Verify file size
$BackupSize = (Get-Item "C:\backup\ubuntu.tar").Length
if ($BackupSize -eq 0) {
  Write-Error "Backup file is empty - ABORTING"
  exit 1
}

Write-Host "Primary backup verified: $([math]::Round($BackupSize/1GB, 2)) GB"
```

### Phase 2: Redundant Backup

```powershell
# Create redundant backup in different location
Copy-Item "C:\backup\ubuntu.tar" "E:\backup\ubuntu-redundant.tar" -ErrorAction Stop

# Verify redundant backup
if (-not (Test-Path "E:\backup\ubuntu-redundant.tar")) {
  Write-Error "Redundant backup creation failed - ABORTING"
  exit 1
}

$RedundantSize = (Get-Item "E:\backup\ubuntu-redundant.tar").Length
if ($RedundantSize -ne $BackupSize) {
  Write-Error "Redundant backup size mismatch - ABORTING"
  exit 1
}

Write-Host "Redundant backup verified: $([math]::Round($RedundantSize/1GB, 2)) GB"
```

### Phase 3: User Confirmation

```powershell
# Present verification results
Write-Host ""
Write-Host "=== BACKUP VERIFICATION COMPLETE ==="
Write-Host "Primary: C:\backup\ubuntu.tar ($([math]::Round($BackupSize/1GB, 2)) GB)"
Write-Host "Redundant: E:\backup\ubuntu-redundant.tar ($([math]::Round($RedundantSize/1GB, 2)) GB)"
Write-Host ""
Write-Host "Ready to execute DESTRUCTIVE operation"
Write-Host ""
Write-Host "Type 'PROCEED' to continue:"

# STOP HERE - WAIT FOR USER INPUT
```

### Phase 4: Checklist

Before ANY destructive operation:

- [ ] Backup created successfully
- [ ] Exit code checked (must be 0)
- [ ] Backup file exists (Test-Path)
- [ ] Backup file size verified (not zero)
- [ ] Redundant backup created
- [ ] User confirmation obtained

**If ANY checkbox unchecked: ABORT**

---

**References**: `reports/LLMCJF_PostMortem_17JAN2026_WSL_Data_Loss.md`  
**Violations**: V-CRITICAL-004, V-CRITICAL-005  
**Heuristic**: CJF-09
