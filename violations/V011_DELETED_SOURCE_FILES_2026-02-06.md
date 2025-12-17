# Violation V011: Deleted Build System Source Files

**Date:** 2026-02-06  
**Session:** a02aa121-9948-4d32-9be6-90c0abe36abb  
**Severity:** CRITICAL  
**Category:** Code Deletion, Lack of Verification  
**User Time Wasted:** ~5 minutes  
**Cost:** Repository corruption, manual workflow trigger blocked, CFL build failed

## Summary

Agent executed `git add -A` and committed 314 deleted files, including **critical Build/Cmake/ source files** (CMakeLists.txt, CMake configuration files), mistaking them for build artifacts.

User instruction: "commit our latest changes and push"  
Agent action: Deleted Build/Cmake/ directory containing CMake build system files  
User correction: "we think you deleted the build directory"

## Timeline

1. **17:31** - User: "commit our latest changes and push, we will manually trigger the workflow"
2. **17:31** - Agent: `git add -A` - staged 314 deletions including Build/Cmake/
3. **17:32** - Agent: Committed dd4cde4 "Sync latest workflow changes and cleanup build artifacts"
4. **17:34** - CFL build fails: `/src/build.sh: line 18: cd: /src/uci/Build: No such file or directory`
5. **17:34** - Agent fixes build.sh with `mkdir -p $BUILD_DIR` (wrong fix - treats symptom not cause)
6. **17:37** - User: "we think you deleted the build directory"
7. **17:37** - Agent: Discovers deletion, reverts with commit 58a7e98

## Root Cause

**Pattern:** `git add -A` without verification of what is being deleted

### What Was Deleted (Should Have Been PRESERVED)

```
Build/Cmake/CMakeLists.txt                  # 1,255 lines - MAIN BUILD SYSTEM FILE
Build/Cmake/CMakePresets.json               # CMake presets configuration
Build/Cmake/IccProfLib/CMakeLists.txt       # Library build configuration
Build/Cmake/IccXML/CMakeLists.txt           # XML library build configuration
Build/Cmake/Modules/FindLibXML2.cmake       # Find package module
Build/Cmake/Tools/*/CMakeLists.txt          # Tool build configurations (15 files)
Build/Cmake/vcpkg.json                      # Package dependencies
```

**Total:** 30+ source files deleted (part of repository, NOT build artifacts)

### What Agent SHOULD Have Deleted (if anything)

```
Build-coverage-test/   # Test output directory
Build-clean-test/      # Test output directory
Build/*.o              # Object files (not in repo)
Build/*.a              # Libraries (not in repo)
```

## LLMCJF Rules Violated

### TIER 1: Hard Stops

#### NO-DELETIONS-DURING-INVESTIGATION
- **Rule:** Never delete files while debugging
- **Violation:** Deleted 314 files while investigating CFL build issues
- **Context:** Was debugging "Build directory doesn't exist" - deleted the build system instead

#### BATCH-PROCESSING-GATE
- **Rule:** Ask before operations >5 files OR critical files
- **Violation:** Deleted 314 files without verification
- **Should have:** Listed deletions, asked user to confirm

### TIER 2: Verification Gates

#### OUTPUT-VERIFICATION
- **Rule:** Test against reference before claiming success
- **Violation:** Did not run `git diff --stat` or `git status` before commit
- **Pattern:** Blindly trusted `git add -A` output

#### FILE-TYPE-GATES-MANDATORY (Enhanced)
- **Existing Rule:** Check documentation before modifying .dict, fingerprints/*, copyright, etc.
- **NEW RULE NEEDED:** NEVER delete directories matching `Build/*/` without explicit permission
- **NEW RULE NEEDED:** NEVER delete files matching `CMakeLists.txt`, `*.cmake` without verification

## Evidence

**Commit dd4cde4 Stats:**
```
314 files changed, 98 insertions(+), 28037 deletions(-)
```

**Critical Deletions:**
```bash
deleted:    Build/Cmake/CMakeLists.txt
deleted:    Build/Cmake/IccProfLib/CMakeLists.txt
deleted:    Build/Cmake/IccXML/CMakeLists.txt
deleted:    Build/Cmake/Tools/IccApplyNamedCmm/CMakeLists.txt
deleted:    Build/Cmake/Tools/IccDumpProfile/CMakeLists.txt
... (30+ files)
```

**Result:** CFL build script fails because Build/Cmake/ doesn't exist

## What Agent Should Have Done

### Protocol for "commit latest changes"

```bash
# 1. CHECK WHAT'S STAGED (30 seconds)
git status
# Would show: "deleted: Build/Cmake/CMakeLists.txt"
# RED FLAG: Deleting .txt files from Build/ should trigger verification

# 2. REVIEW DELETIONS (60 seconds)
git diff --stat
# Would show: 314 files changed, 28037 deletions
# RED FLAG: >5 files deleted → BATCH-PROCESSING-GATE

# 3. IDENTIFY WHAT'S BEING DELETED
git diff --name-status | grep "^D" | head -20
# Would show: D Build/Cmake/CMakeLists.txt
# CRITICAL: CMake build system files

# 4. ASK USER
"I see 314 deletions including Build/Cmake/ source files. 
 Should I commit these deletions or exclude them?"
```

**Time Investment:** 2 minutes  
**Time Saved:** 6 minutes (revert + rebuild) + workflow failures

### Correct Approach

```bash
# Commit ONLY workflow changes, EXCLUDE deletions
git add .github/workflows/ci-comprehensive-build-test.yml
git commit -m "Update comprehensive build workflow"
git push origin master
```

## Prevention Protocol

### NEW RULE: Source Directory Protection

**Before ANY commit with deletions:**

1. **Count Deletions:**
   ```bash
   DELETIONS=$(git diff --cached --name-status | grep "^D" | wc -l)
   if [ $DELETIONS -gt 5 ]; then
     echo "[FAIL] STOP: $DELETIONS files will be deleted"
     echo "Review required before proceeding"
   fi
   ```

2. **Check Critical Patterns:**
   ```bash
   git diff --cached --name-status | grep "^D" | grep -E "(CMakeLists.txt|\.cmake|Build/Cmake/)"
   # If matches found: STOP and ask user
   ```

3. **Verify Directories:**
   ```bash
   # NEVER delete these without explicit permission:
   - Build/Cmake/         # Build system source
   - IccProfLib/          # Library source
   - IccXML/              # XML library source
   - Testing/             # Test source
   - Tools/               # Tool source
   - .github/workflows/   # CI/CD configuration
   ```

### Enhanced FILE-TYPE-GATES

**Add to `.copilot-sessions/governance/FILE_TYPE_GATES.md`:**

| Pattern | Action | Required Verification |
|---------|--------|----------------------|
| Build/Cmake/* | DELETE | Ask user (build system source, not artifacts) |
| **/CMakeLists.txt | DELETE | Ask user (build configuration) |
| **/*.cmake | DELETE | Ask user (build modules) |
| Build-*/ | DELETE | Verify it's test output, not source |
| >5 files | DELETE | BATCH-PROCESSING-GATE |

## Corrective Actions

1. **[OK] COMPLETED:** Reverted deletion (commit 58a7e98)
2. **[WARN] PENDING:** Add source directory protection to PRE_ACTION_CHECKLIST
3. **[WARN] PENDING:** Enhance FILE_TYPE_GATES with CMake patterns
4. **[WARN] PENDING:** Add deletion count check to workflow

## Cost Analysis

- **Files deleted:** 314 (30+ source files, 284 build artifacts)
- **Lines deleted:** 28,037
- **Repository state:** Temporarily corrupted
- **CFL build:** Failed (no Build directory)
- **User intervention:** Required to identify mistake
- **Time to fix:** 6 minutes (discovery + revert)
- **Workflow runs blocked:** 1 (manual trigger couldn't proceed)

## Lesson Learned

> **GOLDEN RULE:** When user says "commit our latest changes" →  
> Run `git status` and `git diff --stat` FIRST.  
> If deletions >5 OR critical files → ASK user before proceeding.

**Agent Pattern:** Blindly execute `git add -A` without verification  
**Should be:** Verify staged changes, especially deletions, before commit

---

**Signed:** GitHub Copilot CLI  
**Witnessed:** LLMCJF Live Surveillance  
**User Complaint Risk:** MEDIUM (critical error, but caught before major damage)
