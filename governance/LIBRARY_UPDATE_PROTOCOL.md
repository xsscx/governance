# Library Update Protocol

**Purpose:** Document process for updating iccDEV library from upstream source  
**Last Updated:** 2026-02-03  
**Governance:** MANDATORY - NO GIT PUSH EVER

## When to Update

1. Upstream provides security fixes
2. Critical bug fixes available (e.g., SEGV, null pointer)
3. New features needed for fuzzing
4. Version sync required

## Update Source

**Primary:** `source-of-truth/` directory in project root  
**Structure:**
```
source-of-truth/
├── IccProfLib/     (core library)
├── IccXML/         (XML serialization)
├── Tools/          (command-line tools)
├── Testing/        (test data)
└── Build/          (build configuration)
```

## Pre-Update Checklist

- [ ] Verify source-of-truth/ exists and is populated
- [ ] Check source size: `du -sh source-of-truth/` (should be ~156 MB)
- [ ] Review upstream changelog if available
- [ ] Backup current fuzzer binaries (optional)
- [ ] Note current git status: `git status`

## Update Procedure

### Step 1: Compare Differences
```bash
cd /home/xss/copilot/iccLibFuzzer

# Compare each component
diff -rq IccProfLib/ source-of-truth/IccProfLib/ | grep differ
diff -rq IccXML/ source-of-truth/IccXML/ | grep differ
diff -rq Tools/ source-of-truth/Tools/ | grep differ
```

**Document:** List of changed files

### Step 2: Preview Sync (Dry Run)
```bash
# Preview IccProfLib changes
rsync -av --dry-run source-of-truth/IccProfLib/ IccProfLib/

# Preview IccXML changes
rsync -av --dry-run source-of-truth/IccXML/ IccXML/

# Preview Tools changes
rsync -av --dry-run source-of-truth/Tools/ Tools/
```

**Verify:** Expected files are listed, no unexpected deletions

### Step 3: Execute Sync
```bash
# Sync IccProfLib
rsync -av source-of-truth/IccProfLib/ IccProfLib/

# Sync IccXML
rsync -av source-of-truth/IccXML/ IccXML/

# Sync Tools
rsync -av source-of-truth/Tools/ Tools/
```

**Record:** Bytes transferred, files modified

### Step 4: Verify Changes
```bash
# Check git status
git status --short

# Count modified files
git status --short | wc -l
```

**Expected:** Only source files (.cpp, .h) modified, no build artifacts

### Step 5: Document Update
Create `LIBRARY_UPDATE_<date>.md` with:
- Date and time
- Files modified (list all)
- Critical changes (SEGV fixes, API changes)
- Bytes transferred
- Git status snapshot

### Step 6: Update Governance
Add entry to `llmcjf/profiles/governance_rules.yaml`:
```yaml
library_update:
  last_update: "<date>"
  files_updated: <count>
  critical_fixes:
    - "<description>"
```

## Post-Update Actions

### 1. Rebuild Fuzzers (MANDATORY)
```bash
./build-fuzzers-local.sh
```

**Why:** Library changes require recompilation  
**Duration:** ~5-10 minutes  
**Verify:** Clean build, no errors

### 2. Test Critical Fixes
If update includes specific bug fixes (e.g., SEGV), test them:
```bash
# Example: Test SEGV fix in icc_toxml_fuzzer
./fuzzers-local/undefined/icc_toxml_fuzzer \
  fuzz/graphics/ \
  -max_total_time=300 \
  -dict=fuzzers/specialized/icc_toxml_fuzzer.dict
```

**Expected:** No crash on previously failing input

### 3. Smoke Test All Fuzzers
```bash
# 5-minute test per fuzzer
for fuzzer in fuzzers-local/undefined/icc_*_fuzzer; do
  $fuzzer fuzz/graphics/ -max_total_time=300 -print_final_stats=1
done
```

**Goal:** Verify no regressions introduced

### 4. Document Findings
Create `LIBRARY_UPDATE_REPORT_<date>.md` with:
- Test results
- Fixed bugs verified
- New issues discovered (if any)
- Fuzzer modifications needed (if any)

## Constraints (MANDATORY)

### Git Operations
- [OK] `git status` - Allowed
- [OK] `git diff` - Allowed
- [OK] `git checkout <file>` - Allowed (rollback)
- [FAIL] `git push` - **NEVER ALLOWED**
- [FAIL] `git push --force` - **NEVER ALLOWED**

### File Operations
- [OK] rsync from source-of-truth/ - Allowed
- [OK] Local builds - Allowed
- [OK] Local testing - Allowed
- [FAIL] Destructive operations - Ask first
- [FAIL] Deleting source files - Ask first

## Rollback Procedure

If update causes issues:
```bash
# Rollback single file
git checkout -- IccProfLib/IccTagBasic.cpp

# Rollback entire component
git checkout -- IccProfLib/

# Rollback all changes
git checkout -- .
```

## API Change Detection

### Check for Breaking Changes
```bash
# Compare function signatures
diff -u <(grep "^.*(" IccProfLib/*.h.old) \
        <(grep "^.*(" IccProfLib/*.h)

# Look for removed functions
git diff IccProfLib/*.h | grep "^-.*("
```

### Update Fuzzers if Needed
If API changes detected:
1. Review fuzzer harness code
2. Update function calls to match new API
3. Test thoroughly
4. Document in `FUZZER_MODIFICATIONS_<date>.md`

## Success Criteria

[OK] All files synced without errors  
[OK] Git status shows expected modifications  
[OK] Fuzzers rebuild cleanly  
[OK] Critical fixes verified  
[OK] No regressions in smoke tests  
[OK] Documentation complete  
[OK] NO git push performed

## Example Session

```bash
# 1. Compare
diff -rq IccProfLib/ source-of-truth/IccProfLib/
# Output: 8 files differ

# 2. Preview
rsync -av --dry-run source-of-truth/IccProfLib/ IccProfLib/
# Output: ~2.3 MB to transfer

# 3. Sync
rsync -av source-of-truth/IccProfLib/ IccProfLib/
# Output: sent 2,370,257 bytes

# 4. Verify
git status --short
# Output: M IccProfLib/IccTagBasic.cpp (+ 7 more)

# 5. Document
cat > LIBRARY_UPDATE_2026-02-03.md

# 6. Rebuild
./build-fuzzers-local.sh
# Output: Build successful

# 7. Test
./fuzzers-local/undefined/icc_toxml_fuzzer fuzz/graphics/ -max_total_time=300
# Output: No SEGV, ran 10k+ inputs

# 8. Report
cat > LIBRARY_UPDATE_REPORT_2026-02-03.md
```

---

**Reference:** LIBRARY_UPDATE_2026-02-03.md (example implementation)
