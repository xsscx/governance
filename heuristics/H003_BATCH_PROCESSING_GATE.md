# H003: BATCH-PROCESSING-GATE

**ID:** H003  
**Name:** BATCH-PROCESSING-GATE  
**Category:** Batch Operations / Data Safety  
**Severity:** TIER 1 HARD STOP (CRITICAL)  
**Created:** 2026-02-02

---

## Rule Statement

Ask before operations affecting >5 files OR critical files.

Before performing batch operations:
1. Count files affected
2. If >5 files OR critical files: STOP
3. Present list to user with impact assessment
4. Wait for user approval
5. Only proceed after explicit confirmation

Threshold: 5 files OR any critical file pattern

---

## Trigger Conditions

### Quantitative Triggers
- Deleting >5 files
- Modifying >5 files
- Moving >5 files
- Git operations affecting >5 files

### Qualitative Triggers (ANY count)
- Files matching *copyright*, *license*
- Build system source files (Build/Cmake/*)
- Configuration files (*.yaml, *.json)
- Documentation with user content

### Git-Specific Triggers
```bash
git status
# If deletions > 5 -> BATCH-PROCESSING-GATE -> Ask user

git diff --stat
# Shows: 314 files changed, 28037 deletions <- IMMEDIATE STOP
```

---

## Related Violations

### V011: Deleted Build System Source Files (2026-02-06)
**Severity:** CRITICAL  
**Impact:** `git add -A` deleted 314 files including Build/Cmake/ directory

What happened:
- User: "commit our latest changes and push"
- Agent executed `git add -A` without checking
- Deleted 314 files including build system sources
- Added `mkdir -p` to "fix" missing directory (treated symptom, not cause)

Batch size: 314 deletions (63x over threshold)  
Time wasted: 6 minutes (discovery + revert)

File: violations/V011_DELETED_SOURCE_FILES_2026-02-06.md

### V022: Subproject Scope Misunderstanding (2026-02-06)
**Severity:** HIGH  
**Impact:** Moved 3 workflow files to wrong location without asking

What happened:
- Should have asked before moving files
- Even 3 files triggers gate for critical files (workflows)
- Violated scope of action-testing/ subproject

File: violations/V022_SUBPROJECT_SCOPE_MISUNDERSTANDING.md

---

## Prevention Protocol

### Step 1: Count Files Affected

```bash
# Before git commit
git status --short | wc -l

# Before git add
git status | grep deleted | wc -l

# Check stats
git diff --stat | tail -1
# Shows: X files changed, Y insertions(+), Z deletions(-)
```

### Step 2: Evaluate Threshold

```bash
if [ $deletions -gt 5 ] || [ $critical_files -gt 0 ]; then
  # TRIGGER: BATCH-PROCESSING-GATE
  # -> Ask user
fi
```

### Step 3: Present to User

```bash
# Example from V011 prevention:
"I see 314 deletions including Build/Cmake/ source files.
 Files affected:
   - Build/Cmake/CMakeLists.txt (1,255 lines - MAIN BUILD SYSTEM)
   - Build/Cmake/IccProfLib/CMakeLists.txt
   - Build/Cmake/Tools/*/CMakeLists.txt (15 files)
   
 Should I:
   1. Commit these deletions
   2. Exclude Build/ directory
   3. Review each file individually"
```

### Step 4: Wait for Approval

WRONG:
```bash
git add -A
git commit -m "changes"  # <- Assumes user wants all changes
```

RIGHT:
```bash
git status  # Show user what will be committed
# Ask via ask_user tool
# Wait for approval
# Then execute
```

---

## What Should Have Happened (V011)

```bash
# 1. Check what's staged
git status
# Shows: "deleted: Build/Cmake/CMakeLists.txt" <- RED FLAG

# 2. Review stats  
git diff --stat
# Shows: 314 files changed, 28037 deletions <- BATCH-PROCESSING-GATE

# 3. ASK USER (required by H003)
ask_user(
  question="I see 314 deletions including Build/Cmake/ source files. " +
           "Should I commit these or exclude them?",
  choices=[
    "Commit deletions (includes build system)",
    "Exclude Build/ directory",
    "Let me review first"
  ]
)

# 4. Proceed based on user choice
```

---

## Integration with Other Rules

- H002 (ASK-FIRST-PROTOCOL): Batch operations are decision points
- H008 (OUTPUT-VERIFICATION): Check `git status` output before committing
- H017 (DESTRUCTIVE-OPERATION-GATE): Deleting >5 files is destructive

---

## File Type Gates

File: .copilot-sessions/governance/FILE_TYPE_GATES.md

| Condition | Operation | Gate | Violation |
|-----------|-----------|------|-----------|
| >5 files | DELETE | BATCH-PROCESSING-GATE | V011 |
| >5 files | MODIFY | BATCH-PROCESSING-GATE | - |
| Build/* | ANY | ASK-FIRST | V011 |
| *copyright* | ANY | H001 + ASK-FIRST | V001 |

---

## Detection Patterns

### Git Operations
```bash
# Danger signals:
git add -A           # Adds EVERYTHING (including deletions)
git add .            # Adds all in directory
rm -rf */            # Batch deletion

# Safe alternatives:
git add specific-file.cpp
git add dir/specific-subdir/
git status           # Review first
```

### File Operations
```bash
# Danger:
rm *.md              # Could delete many files
sed -i 's/x/y/' *.py # Modifies all .py files

# Safe:
ls *.md | wc -l      # Count first
# If >5 -> Ask user
```

---

## Cost of Violations

### V011 Impact
- 314 files deleted (including build system source)
- Build/Cmake/ directory lost (1,255-line CMakeLists.txt)
- 6 minutes to discover and revert
- Workflow blocked
- Repository corruption

### V022 Impact
- Files in wrong location
- Scope violation
- Cleanup required

---

## References

- V011 Report: violations/V011_DELETED_SOURCE_FILES_2026-02-06.md
- V022 Report: violations/V022_SUBPROJECT_SCOPE_MISUNDERSTANDING.md
- File Type Gates: .copilot-sessions/governance/FILE_TYPE_GATES.md
- Git Safety Rules: profiles/git_safety_rules.yaml
- HALL_OF_SHAME: Line 673, 685

---

**Status:** ACTIVE - TIER 1 HARD STOP  
**Threshold:** >5 files OR critical files  
**Violations:** 2 (V011 CRITICAL, V022 HIGH)  
**Last Updated:** 2026-02-07
