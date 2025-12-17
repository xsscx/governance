# H010: NO-DELETIONS-DURING-INVESTIGATION

**ID:** H010  
**Name:** NO-DELETIONS-DURING-INVESTIGATION  
**Category:** Data Safety / Investigation Protocol  
**Severity:** TIER 2 VERIFICATION GATE (HIGH)  
**Created:** 2026-02-02

---

## Rule Statement

Never delete files while debugging.

When investigating issues:
1. DO NOT delete files "to see if it helps"
2. DO NOT remove data hoping to fix problem
3. DO NOT clean up during active debugging
4. ONLY delete after understanding root cause
5. IF must delete: ask user first (H002)

PRINCIPLE: Deleting files during investigation destroys evidence and rarely fixes root cause.

---

## Trigger Conditions

### When This Rule Applies
- During any debugging session
- When investigating bugs
- While trying to fix issues
- Before understanding root cause

### Specific Scenarios
- "Maybe deleting X will help"
- "Let me clean up and try again"
- "Remove this file to test"
- "Delete and regenerate"

---

## Related Violations

### V006: SHA256 Index Destruction (2026-02-02)
**Severity:** CRITICAL  
**Time Wasted:** 45 minutes  
**File Deleted:** fingerprints/FINGERPRINT_INDEX.json

What happened:
- User: "SHA256 index shows 0"
- Agent: Debugged for 30+ minutes
- Agent: Deleted FINGERPRINT_INDEX.json (hoping it would help)
- Result: Made problem worse, destroyed evidence
- Reality: File deletion was unnecessary, real issue was variable scope

User quote: "Does not justify paying money"

File: violations/VIOLATION_006_SHA256_INDEX_DESTRUCTION_2026-02-02.md

### V011: Deleted Build System Source Files (2026-02-06)
**Severity:** CRITICAL  
**Time Wasted:** 6 minutes  
**Files Deleted:** 314 files including Build/Cmake/

What happened:
- User: "commit our latest changes and push"
- Agent: Executed `git add -A` without checking
- Result: Deleted 314 files including build system sources
- Impact: Repository corruption, workflow blocked

User quote: "We think you deleted the build directory"

File: violations/V011_DELETED_SOURCE_FILES_2026-02-06.md

---

## Why Deletions During Investigation Fail

### Reason 1: Destroys Evidence
```
Before deletion: Can analyze file, check history, compare versions
After deletion: Evidence gone, harder to debug
```

### Reason 2: Rarely Fixes Root Cause
```
Bugs are usually logic issues, not "bad files"
Deleting files treats symptoms, not causes
```

### Reason 3: Creates New Problems
```
V006: Deleted FINGERPRINT_INDEX.json
      Now debugging TWO issues: original bug + missing file
```

### Reason 4: Can't Undo
```
Deleted files may not be in git
Even if in git, requires revert/restore
Adds complexity to debugging
```

---

## Safe Investigation Protocol

### Instead of Deleting: Investigate

```bash
# WRONG (V006 pattern)
# Bug: SHA256 index shows 0
rm fingerprints/FINGERPRINT_INDEX.json  # Hope deletion helps
# Result: File gone, bug remains, evidence destroyed

# RIGHT
# Bug: SHA256 index shows 0
cat fingerprints/FINGERPRINT_INDEX.json | jq '.sha256_hashes | length'
# Output: 68 hashes exist in file
# Diagnosis: File is fine, variable not populated from it
# Evidence: Preserved for further investigation
```

### Instead of Deleting: Move to Backup

```bash
# WRONG
rm problematic_file.json

# RIGHT
mv problematic_file.json problematic_file.json.bak
# Can restore if needed
# Can compare old vs new
# Evidence preserved
```

### Instead of Deleting: Rename

```bash
# WRONG  
rm config.yaml

# RIGHT
mv config.yaml config.yaml.$(date +%Y%m%d_%H%M%S)
# Timestamped backup
# Can revert if deletion wasn't the fix
```

---

## Integration with Other Rules

- H002 (ASK-FIRST-PROTOCOL): Ask before deleting files
- H003 (BATCH-PROCESSING-GATE): Deleting >5 files requires confirmation
- H006 (SUCCESS-DECLARATION): Verify deletion fixed issue before claiming success
- H008 (USER-SAYS-I-BROKE-IT): If user says "broken", don't delete evidence
- H017 (DESTRUCTIVE-OPERATION-GATE): Deletion is destructive, verify backup exists

---

## Exceptions (When Deletion Is OK)

### 1. User Explicitly Requests
```
User: "Delete the backup directories"
Action: Can delete (explicit request)
But: Still verify which directories before deleting (H003)
```

### 2. Cleaning Known Build Artifacts
```bash
# Safe - these regenerate
rm -rf Build/
make clean

# Not safe - source files
rm -rf Build/Cmake/  # V011 violation
```

### 3. After Understanding Root Cause
```
Diagnosis complete: File is corrupted and needs regeneration
Action: Delete and regenerate
But: Keep backup first
```

### 4. Temporary Test Files
```bash
# Safe
rm /tmp/test_output.txt
rm test_file_$(date +%s).tmp

# Not safe
rm fingerprints/FINGERPRINT_INDEX.json  # V006
```

---

## Examples

### Example 1: V006 Pattern (WRONG)

```
User: "SHA256 index shows 0"

Agent investigation (WRONG):
1. Debug C++ extraction logic (30 min)
2. Add debug output
3. Analyze JSON structures
4. Still showing 0
5. "Maybe file is corrupted, let me delete it"
6. rm fingerprints/FINGERPRINT_INDEX.json
7. Rebuild
8. Still showing 0 (now with missing file error too)

Result: 
- Original bug: Variable not populated
- New bug: File missing
- Evidence: Destroyed
- Time: 45 minutes
```

### Example 1: V006 Pattern (RIGHT)

```
User: "SHA256 index shows 0"

Agent investigation (RIGHT):
1. Check file exists and has data:
   cat fingerprints/FINGERPRINT_INDEX.json | jq '.sha256_hashes | length'
   Output: 68
   Conclusion: File is fine with 68 entries

2. Check variable population:
   grep "sha256_index\[" IccAnalyzer.cpp
   Found: Only in scan_directory() function
   Not found: In main() where needed
   
3. Diagnosis: Variable declared in main() but never populated
   
4. Fix: Add population after loading (4 lines)

Result:
- Original bug: Fixed
- File: Preserved
- Evidence: Available for verification
- Time: 5 minutes
```

### Example 2: V011 Pattern (WRONG)

```
Agent: "Committing changes"

Action (WRONG):
git add -A  # Adds EVERYTHING including deletions
git commit -m "changes"

Result:
- Deleted: Build/Cmake/ source directory (314 files)
- Lost: Main build system CMakeLists.txt (1,255 lines)
- Impact: Repository corrupted
```

### Example 2: V011 Pattern (RIGHT)

```
Agent: "Committing changes"

Action (RIGHT):
1. Check what's staged:
   git status
   git diff --stat
   
2. Notice: 314 deletions including Build/Cmake/
   
3. Ask user:
   "I see 314 deletions including build system sources.
    Should I:
    1. Commit these deletions
    2. Exclude Build/ directory  
    3. Review each file"
    
4. User: "Exclude Build/ - those are source files"

5. Execute safely:
   git reset
   git add <specific files>
   git commit -m "changes"
```

---

## Detection Patterns

### Deletion Red Flags

```bash
# During debugging session:
rm <file>              # RED FLAG - deleting evidence
rm -rf <directory>     # RED FLAG - batch deletion
git add -A             # RED FLAG - may stage deletions

# Safe alternatives:
mv <file> <file>.bak   # Backup, not delete
ls <file>              # Check existence
git status             # Review before staging
```

### Ask-First Triggers

If during investigation session and considering:
- `rm` command
- `git add -A` with deletions
- Deleting >1 file
- Deleting anything in source directories

THEN: Stop and ask user (H002)

---

## Cost of Violations

### V006 Impact
- File deleted: FINGERPRINT_INDEX.json
- Time wasted: 45 minutes
- Evidence: Destroyed
- Fix complexity: Increased (2 problems instead of 1)
- User trust: "Does not justify paying money"

### V011 Impact
- Files deleted: 314 (including critical build system)
- Recovery: Git revert required
- Workflow: Blocked
- Time wasted: 6 minutes
- Repository: Corrupted

**Total:** 51 minutes wasted + repository corruption + 315 files deleted

---

## Prevention Checklist

Before deleting any file during investigation:

```
[ ] Root cause understood?
[ ] Deletion necessary to fix issue?
[ ] File backed up or in git?
[ ] User approved deletion?
[ ] File is not source code or documentation?
[ ] File is not build system configuration?

If ALL YES -> Can delete
If ANY NO -> DO NOT delete
```

---

## Safe Debugging Without Deletion

```bash
# Investigating file corruption
# WRONG: rm file.json
# RIGHT: 
cat file.json | jq .  # Validate JSON
cp file.json file.json.bak  # Backup
# Then fix in place or regenerate

# Investigating build issues
# WRONG: rm -rf Build/
# RIGHT:
make clean  # Clean artifacts, not source
ls -la Build/  # Check what exists
# Diagnose before deleting

# Investigating git issues
# WRONG: git add -A && git commit
# RIGHT:
git status  # See what will be committed
git diff --stat  # Check deletions
# Ask before committing deletions
```

---

## References

- V006 Report: violations/VIOLATION_006_SHA256_INDEX_DESTRUCTION_2026-02-02.md
- V011 Report: violations/V011_DELETED_SOURCE_FILES_2026-02-06.md
- HALL_OF_SHAME: llmcjf/HALL_OF_SHAME.md (Lines 432-444, 638-692)
- H003 (Batch Processing): heuristics/H003_BATCH_PROCESSING_GATE.md
- H017 (Destructive Operations): heuristics/H017_DESTRUCTIVE_OPERATION_GATE.md

---

**Status:** ACTIVE - TIER 2 VERIFICATION GATE  
**Violations:** 2 (V006 CRITICAL, V011 CRITICAL)  
**Files Lost:** 315 total  
**Principle:** Preserve evidence, diagnose before deleting  
**Last Updated:** 2026-02-07
