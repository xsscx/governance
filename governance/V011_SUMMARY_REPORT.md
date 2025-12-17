# V011 Violation Summary Report
## Deleted Build System Source Files

**Date:** 2026-02-06 17:31-17:37 UTC  
**Session:** a02aa121-9948-4d32-9be6-90c0abe36abb  
**Repository:** action-testing/uci  
**Branch:** master

---

## Executive Summary

Agent deleted 314 files (30+ source files, 284 build artifacts) via `git add -A` without verification. Critical Build/Cmake/ directory containing main build system (CMakeLists.txt, 1,255 lines) was removed. User intervention required to identify and revert.

**Impact:**
- Repository temporarily corrupted
- CFL build failed (Build directory doesn't exist)
- Manual workflow trigger blocked
- 6 minutes wasted on discovery + revert

**Root Cause:** No verification of deletions before commit

**Resolution:** Full revert (commit 58a7e98)

---

## Timeline

| Time | Event | Agent Action | Result |
|------|-------|--------------|--------|
| 17:31 | User: "commit our latest changes" | `git add -A` | 314 deletions staged |
| 17:32 | Agent commits | dd4cde4 "Sync latest workflow changes" | Build/Cmake/ deleted |
| 17:34 | CFL build runs | build.sh fails | "cd: Build: No such file" |
| 17:34 | Agent fixes | Add `mkdir -p $BUILD_DIR` | Wrong fix (symptom not cause) |
| 17:37 | User: "you deleted build directory" | Agent realizes mistake | Discovery |
| 17:37 | Agent reverts | Commit 58a7e98 | Restoration complete |

---

## What Was Deleted (Should Have Been PRESERVED)

### Build System Source Files (30+)
```
Build/Cmake/CMakeLists.txt                       # 1,255 lines - MAIN
Build/Cmake/CMakePresets.json                    # Presets
Build/Cmake/IccProfLib/CMakeLists.txt            # Library
Build/Cmake/IccXML/CMakeLists.txt                # XML
Build/Cmake/Modules/FindLibXML2.cmake            # Find module
Build/Cmake/Tools/IccApplyNamedCmm/CMakeLists.txt
Build/Cmake/Tools/IccApplyProfiles/CMakeLists.txt
Build/Cmake/Tools/IccApplySearch/CMakeLists.txt
Build/Cmake/Tools/IccApplyToLink/CMakeLists.txt
Build/Cmake/Tools/IccDEVCmm/CMakeLists.txt
Build/Cmake/Tools/IccDumpProfile/CMakeLists.txt
Build/Cmake/Tools/IccFromCube/CMakeLists.txt
Build/Cmake/Tools/IccFromXml/CMakeLists.txt
Build/Cmake/Tools/IccJpegDump/CMakeLists.txt
Build/Cmake/Tools/IccPngDump/CMakeLists.txt
Build/Cmake/Tools/IccRoundTrip/CMakeLists.txt
Build/Cmake/Tools/IccSpecSepToTiff/CMakeLists.txt
Build/Cmake/Tools/IccTiffDump/CMakeLists.txt
Build/Cmake/Tools/IccToXml/CMakeLists.txt
Build/Cmake/Tools/IccV5DspObsToV4Dsp/CMakeLists.txt
Build/Cmake/Tools/wxProfileDump/CMakeLists.txt
Build/Cmake/vcpkg.json                           # Dependencies
```

### Build Artifacts (284 - Could Have Been Deleted)
```
Build-coverage-test/     # Test output
Build-clean-test/        # Test output
Build/Tools/*/binary     # Compiled executables
```

**Total Deletion:** 314 files, 28,037 lines

---

## LLMCJF Rules Violated

### TIER 1: Hard Stops (CRITICAL)

1. **NO-DELETIONS-DURING-INVESTIGATION**
   - Was debugging CFL build issues
   - Deleted 314 files during investigation
   - Should have frozen deletions while troubleshooting

2. **BATCH-PROCESSING-GATE**
   - 314 deletions = far exceeds >5 threshold
   - No user confirmation requested
   - No review of what's being deleted

### TIER 2: Verification Gates (HIGH)

3. **OUTPUT-VERIFICATION**
   - No `git status` check before commit
   - No `git diff --stat` review
   - Blindly trusted `git add -A`

---

## What Agent Should Have Done

### Correct Protocol for "commit latest changes"

```bash
# STEP 1: Check status (10 seconds)
git status
# Would show:
#   deleted: Build/Cmake/CMakeLists.txt
#   deleted: Build/Cmake/IccProfLib/CMakeLists.txt
# [WARN] RED FLAG: Deleting .txt files from Build/

# STEP 2: Review statistics (10 seconds)
git diff --stat
# Would show:
#   314 files changed, 98 insertions(+), 28037 deletions(-)
# [WARN] RED FLAG: Massive deletions (>5 files)

# STEP 3: Identify deletions (10 seconds)
git diff --name-status | grep "^D" | head -20
# Would show:
#   D Build/Cmake/CMakeLists.txt
#   D Build/Cmake/IccProfLib/CMakeLists.txt
# [ALERT] CRITICAL: Build system files being deleted

# STEP 4: Ask user (required by BATCH-PROCESSING-GATE)
"I see 314 deletions including Build/Cmake/ source files.
 These appear to be build system files, not artifacts.
 Should I:
 1. Exclude deletions and commit only workflow changes
 2. Proceed with deletions
 3. Let you review the changes first"
```

**Time Investment:** 30 seconds  
**Time Saved:** 6 minutes + workflow failures + user frustration

---

## Prevention Mechanisms Implemented

### 1. Git Safety Rules (`llmcjf/profiles/git_safety_rules.yaml`)

- GIT-001: Pre-Commit Verification Required
- GIT-002: Deletion Count Gate (>5 files)
- GIT-003: Protected File Patterns (CMake, source dirs)
- GIT-004: Source vs Artifact Detection
- GIT-005: Commit Message Verification

### 2. Enhanced FILE_TYPE_GATES

| Pattern | Action | Verification Required |
|---------|--------|----------------------|
| Build/Cmake/* | DELETE | Ask user |
| **/CMakeLists.txt | DELETE | Ask user |
| **/*.cmake | DELETE | Ask user |
| >5 files | DELETE | BATCH-PROCESSING-GATE |

### 3. PRE_ACTION_CHECKLIST Updates

**Before EVERY git commit:**
1. Run `git status`
2. Run `git diff --stat`
3. Count deletions: `git diff --name-status | grep "^D" | wc -l`
4. If >5 OR CMake files → STOP and ask user

### 4. Source Directory Protection

**NEVER delete without explicit permission:**
- Build/Cmake/ (build system source)
- IccProfLib/ (library source)
- IccXML/ (XML library source)
- Tools/ (tool source)
- Testing/ (test source)
- .github/workflows/ (CI/CD config)

---

## Cost Analysis

| Metric | Value |
|--------|-------|
| Files deleted | 314 |
| Source files deleted | 30+ |
| Build artifacts deleted | 284 |
| Lines deleted | 28,037 |
| Time to discover | 6 minutes |
| Time to revert | 1 minute |
| Workflow runs blocked | 1 |
| Repository state | Temporarily corrupted |
| User intervention | Required |

**Prevention Cost:** 30 seconds (run git status + diff)  
**Correction Cost:** 6 minutes (discovery + revert)  
**ROI:** 12× time savings

---

## Key Takeaways

### For Agent (Me)

> **NEVER use `git add -A` without verification**

**Golden Rule:** Before ANY commit with deletions:
1. `git status` - what's changed?
2. `git diff --stat` - how much?
3. Count deletions - trigger BATCH-PROCESSING-GATE if >5
4. Review critical patterns - CMakeLists.txt, *.cmake, Build/Cmake/
5. Ask user if uncertain

### For LLMCJF System

**Pattern Identified:** Agent confuses build artifacts with build source

**Solution:** 
- Explicit directory classification
- Protected pattern list
- Deletion count gates
- Mandatory verification before commit

### For User

**Lesson:** "commit our latest changes" ≠ "delete everything git sees"

**Request Format (if deletions desired):**
```
"Commit workflow changes only (exclude deletions)"
OR
"Review deletions: git diff --name-status | grep '^D'"
```

---

## Verification

**Revert Successful:**
```bash
$ ls -la Build/Cmake/CMakeLists.txt
-rw-rw-r-- 1 xss xss 50287 Feb  6 17:37 Build/Cmake/CMakeLists.txt
```

**Commit:**
```
58a7e98 Revert "Sync latest workflow changes and cleanup build artifacts"
```

**Status:** [OK] RESOLVED  
**Repository:** [OK] RESTORED  
**Documentation:** [OK] COMPLETE

---

**Signed:** GitHub Copilot CLI  
**Witnessed:** LLMCJF Live Surveillance  
**Date:** 2026-02-06
