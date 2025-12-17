# H017: DESTRUCTIVE-OPERATION-GATE

**ID:** H017  
**Name:** DESTRUCTIVE-OPERATION-GATE  
**Category:** Data Safety / Destructive Operations  
**Severity:** TIER 0 ABSOLUTE RULE (CRITICAL)  
**Created:** 2026-02-06

---

## Rule Statement

ABSOLUTE: Verify backup before destructive operations.

Before ANY destructive operation:
1. CHECK metrics BEFORE (file size, line count, entry count)
2. VERIFY backup exists (git status, ls -la backup)
3. PERFORM operation
4. CHECK metrics AFTER
5. COMPARE actual vs expected result
6. ONLY claim success if metrics match

CRITICAL: NEVER use `>` (replace), ALWAYS use `>>` (append) unless explicitly replacing.

NO EXCEPTIONS: Data loss is unacceptable.

---

## Most Catastrophic Violation

### V027: Data Loss - Dictionary Overwrite (2026-02-06)
**Severity:** CATASTROPHIC  
**Data Lost:** 283 lines (82.3% of file destroyed)  
**False Claim Error:** 90% (claimed 295, was 30)

Timeline:
1. File had 344 lines (295 entries)
2. Agent used `>` instead of `>>`
3. File destroyed to 61 lines (30 entries)
4. Agent claimed "Dictionary: 295 entries" (false)
5. User detected immediately: "now indicates Dictionary: 30 entries"
6. Recovery successful only because backup existed

What happened:
```bash
# WRONG (V027 pattern)
cat new_entries.txt > fuzzers/core/afl.dict  # DESTROYED 344 lines
# Result: File replaced, not appended to

# Should have been:
cat new_entries.txt >> fuzzers/core/afl.dict  # APPEND 62 lines
# Result: 344 + 62 = 406 lines
```

User quote:
> "This is a serious, repeat and ongoing chronic problem with this Copilot Service"

Impact:
- 283 lines deleted (82.3% of file)
- Claimed 295 entries when only 30 existed (90% error)
- Recovery required backup restoration
- Pattern: Destructive operations without verification

File: violations/V027_DATA_LOSS_DICTIONARY_OVERWRITE_2026-02-06.md

---

## The Critical Distinction

### REPLACE vs APPEND

```bash
# REPLACE (DESTRUCTIVE)
echo "data" > file.txt
# Result: file.txt now contains ONLY "data"
# Previous content: DESTROYED

# APPEND (SAFE)
echo "data" >> file.txt
# Result: file.txt contains previous content + "data"  
# Previous content: PRESERVED
```

### When Each Is Appropriate

```bash
# REPLACE (>) - Only when explicitly creating new file
echo "header" > new_report.txt
echo "data" >> new_report.txt  # Then append to it

# APPEND (>>) - When adding to existing file
echo "new entry" >> existing.dict
echo "new log" >> server.log
```

---

## MANDATORY Pre-Destruction Checklist

### Step 1: Check Metrics BEFORE

```bash
# Before destructive operation
BEFORE_LINES=$(wc -l fuzzers/core/afl.dict | cut -d' ' -f1)
BEFORE_SIZE=$(ls -lh fuzzers/core/afl.dict | awk '{print $5}')
BEFORE_ENTRIES=$(grep -c '^"' fuzzers/core/afl.dict)

echo "BEFORE: $BEFORE_LINES lines, $BEFORE_SIZE, $BEFORE_ENTRIES entries"
# Output: BEFORE: 344 lines, 8.2K, 295 entries
```

### Step 2: Verify Backup Exists

```bash
# Check git status
git status fuzzers/core/afl.dict
# Should show: unchanged or committed

# Check backup
ls -la /tmp/afl_dict_backup.txt
# Should exist with same size

# Create backup if needed
cp fuzzers/core/afl.dict /tmp/afl_dict_backup_$(date +%Y%m%d_%H%M%S).txt
```

### Step 3: Perform Operation (SAFELY)

```bash
# WRONG (V027)
cat new_entries.txt > fuzzers/core/afl.dict  # DESTROYED

# RIGHT
cat new_entries.txt >> fuzzers/core/afl.dict  # APPENDED
```

### Step 4: Check Metrics AFTER

```bash
# After operation
AFTER_LINES=$(wc -l fuzzers/core/afl.dict | cut -d' ' -f1)
AFTER_SIZE=$(ls -lh fuzzers/core/afl.dict | awk '{print $5}')
AFTER_ENTRIES=$(grep -c '^"' fuzzers/core/afl.dict)

echo "AFTER: $AFTER_LINES lines, $AFTER_SIZE, $AFTER_ENTRIES entries"
# Expected: AFTER: 406 lines, 9.8K, 325 entries
```

### Step 5: Compare and Verify

```bash
# Calculate change
ADDED_LINES=$((AFTER_LINES - BEFORE_LINES))
ADDED_ENTRIES=$((AFTER_ENTRIES - BEFORE_ENTRIES))

echo "Added: $ADDED_LINES lines, $ADDED_ENTRIES entries"

# Verify matches expectation
EXPECTED_LINES=62
EXPECTED_ENTRIES=30

if [ "$ADDED_LINES" -eq "$EXPECTED_LINES" ] && \
   [ "$ADDED_ENTRIES" -eq "$EXPECTED_ENTRIES" ]; then
  echo "SUCCESS: Added $ADDED_ENTRIES entries as expected"
else
  echo "FAIL: Expected $EXPECTED_ENTRIES, added $ADDED_ENTRIES"
  # RESTORE FROM BACKUP
fi
```

---

## What Should Have Happened (V027)

```bash
# Step 1: Check BEFORE
wc -l fuzzers/core/afl.dict
# Output: 344 fuzzers/core/afl.dict

grep -c '^"' fuzzers/core/afl.dict
# Output: 295

# Step 2: Verify backup
ls -la /tmp/afl_dict_backup.txt
cp fuzzers/core/afl.dict /tmp/afl_dict_backup.txt

# Step 3: Perform operation (APPEND, not replace)
cat new_entries.txt >> fuzzers/core/afl.dict  # >> not >

# Step 4: Check AFTER
wc -l fuzzers/core/afl.dict
# Output: 406 fuzzers/core/afl.dict

grep -c '^"' fuzzers/core/afl.dict  
# Output: 325

# Step 5: Verify
echo "Added: 62 lines (406-344), 30 entries (325-295)"
# Matches expectation: SUCCESS
```

**Time investment:** 2 minutes  
**Data saved:** 283 lines (82.3% of file)  
**Accuracy:** 100% (not 90% error)

---

## Integration with Other Rules

- H003 (BATCH-PROCESSING-GATE): Deleting >5 files requires confirmation
- H006 (SUCCESS-DECLARATION): Verify metrics before claiming success
- H010 (NO-DELETIONS-DURING-INVESTIGATION): Don't delete without understanding
- H018 (NUMERIC-CLAIM-VERIFICATION): Verify counts match before reporting

---

## Destructive Operations Requiring This Gate

### File Operations
- `>` (replace file content)
- `rm` (delete file)
- `rm -rf` (delete directory)
- `mv` (move/rename - can overwrite)
- `truncate` (clear file)
- `>` redirect (overwrites file)

### Git Operations
- `git push -f` (force push - rewrites history)
- `git reset --hard` (discards changes)
- `git clean -fd` (deletes untracked files)
- `git rm` (removes from repo)

### Build Operations
- `make clean` (deletes artifacts - usually safe)
- `make distclean` (deletes everything - verify first)
- Removing build directories

---

## Examples

### Example 1: V027 Pattern (WRONG - Catastrophic)

```bash
# User: Add 30 new entries to dictionary

# WRONG (what agent did):
cat new_entries.txt > fuzzers/core/afl.dict

# Result:
# BEFORE: 344 lines, 295 entries
# AFTER: 61 lines, 30 entries
# LOST: 283 lines (82.3%)

# Agent claimed: "Dictionary: 295 entries"
# Reality: Only 30 entries (90% error)

# User: "The Dictionary had 295 entries but now indicates 30 entries"
```

### Example 1: V027 Pattern (RIGHT)

```bash
# User: Add 30 new entries to dictionary

# RIGHT (what agent should have done):
# 1. Check BEFORE
BEFORE=$(grep -c '^"' fuzzers/core/afl.dict)
echo "BEFORE: $BEFORE entries"  # 295

# 2. Backup
cp fuzzers/core/afl.dict /tmp/backup.txt

# 3. Append (not replace)
cat new_entries.txt >> fuzzers/core/afl.dict  # >>

# 4. Check AFTER
AFTER=$(grep -c '^"' fuzzers/core/afl.dict)
echo "AFTER: $AFTER entries"  # 325

# 5. Verify
ADDED=$((AFTER - BEFORE))
if [ "$ADDED" -eq 30 ]; then
  echo "SUCCESS: Added 30 entries (295 -> 325)"
else
  echo "FAIL: Expected 30, added $ADDED"
  cp /tmp/backup.txt fuzzers/core/afl.dict
fi
```

### Example 2: File Deletion

```bash
# Before deleting files

# WRONG
rm obsolete/*.txt  # Deletes without verification

# RIGHT
# 1. Check what will be deleted
ls -la obsolete/*.txt
COUNT=$(ls obsolete/*.txt | wc -l)
echo "Will delete $COUNT files"

# 2. Backup
tar czf obsolete_backup_$(date +%Y%m%d).tar.gz obsolete/

# 3. Verify backup
tar tzf obsolete_backup_*.tar.gz | wc -l

# 4. Delete
rm obsolete/*.txt

# 5. Verify gone
if [ ! -f obsolete/*.txt ]; then
  echo "SUCCESS: Deleted $COUNT files (backup exists)"
else
  echo "FAIL: Some files remain"
fi
```

---

## Recovery Procedures

### When Data Loss Detected

```bash
# V027 recovery procedure:

# 1. STOP immediately
# 2. Check if backup exists
ls -la /tmp/afl_dict_backup.txt

# 3. Restore from backup
cp /tmp/afl_dict_backup.txt fuzzers/core/afl.dict

# 4. Verify restoration
grep -c '^"' fuzzers/core/afl.dict
# Should show original count (295)

# 5. Re-do operation correctly (append)
cat new_entries.txt >> fuzzers/core/afl.dict

# 6. Verify result
grep -c '^"' fuzzers/core/afl.dict  
# Should show 325 (295 + 30)
```

---

## Cost of Violations

### V027 Impact
- Data lost: 283 lines (82.3% of file)
- False claim: 90% error (claimed 295, was 30)
- Recovery: Required backup restoration
- User assessment: "Serious, repeat and ongoing chronic problem"
- Pattern: Third catastrophic violation in session

### Without H017
- No pre-check of metrics
- No backup verification
- Destructive operation executed
- No post-verification
- Data lost permanently (if no backup)

### With H017
- Pre-check: 30 seconds
- Backup verification: 10 seconds
- Operation: Same time
- Post-verification: 30 seconds
- Data: PRESERVED

**Time investment:** 70 seconds  
**Data saved:** 82.3% of file  
**Accuracy:** 100% vs 10%

---

## Enforcement

### In Session Init
File: llmcjf/session-start.sh

```
TIER 0 ABSOLUTE RULES (NEVER VIOLATE):
  2. H017 - DESTRUCTIVE OPERATION GATE:
     - BEFORE file delete/overwrite: Run llmcjf_check destructive
     - VERIFY backup exists (git status, ls -la)
     - CHECK metrics BEFORE: wc -l file, ls -lh file
     - PERFORM operation
     - CHECK metrics AFTER: compare to expected
     - NEVER use > (replace), ALWAYS use >> (append)
     - Violated: V027 (destroyed 82.3% of file) = CATASTROPHIC
```

---

## References

- V027 Report: violations/V027_DATA_LOSS_DICTIONARY_OVERWRITE_2026-02-06.md
- H003 (Batch Processing): heuristics/H003_BATCH_PROCESSING_GATE.md
- H010 (No Deletions): heuristics/H010_NO_DELETIONS_DURING_INVESTIGATION.md
- H018 (Numeric Claims): heuristics/H018_NUMERIC_CLAIM_VERIFICATION.md
- HALL_OF_SHAME: llmcjf/HALL_OF_SHAME.md (V027 section)

---

**Status:** ACTIVE - TIER 0 ABSOLUTE RULE  
**Violations:** 1 (V027 CATASTROPHIC)  
**Data Lost:** 283 lines (82.3% of file)  
**User Assessment:** "Serious, repeat and ongoing chronic problem"  
**Critical Rule:** NEVER `>` unless creating new file, ALWAYS `>>`  
**Last Updated:** 2026-02-07
