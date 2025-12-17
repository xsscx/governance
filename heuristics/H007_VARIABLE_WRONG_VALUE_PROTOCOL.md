# H007: VARIABLE-WRONG-VALUE-PROTOCOL

**ID:** H007  
**Name:** VARIABLE-WRONG-VALUE-PROTOCOL  
**Category:** Debugging Efficiency / Systematic Investigation  
**Severity:** TIER 2 VERIFICATION GATE (HIGH)  
**Created:** 2026-02-02 (Response to V006, V010)

---

## Rule Statement

When variable shows wrong value: 5-minute systematic debugging protocol.

Use grep-based systematic investigation instead of complex debugging:
1. grep where variable is PRINTED
2. grep where variable is DECLARED
3. grep where variable is ASSIGNED
4. CHECK variable scope (function vs global)
5. If not in scope: add assignment, DONE
6. If in scope but wrong: check assignment logic

Time limit: 5 minutes. If not progressing, wrong approach.

NO SPECULATION. NO COMPLEX FIXES. Follow the data.

---

## Trigger Conditions

### When This Rule Applies
- Variable shows 0 when should be N
- Variable shows empty when should have data
- Count/metric incorrect
- User reports "variable not populated"
- Output shows unexpected value

### Specific Scenarios (From Violations)
- SHA256 index shows 0, expected 68 (V006)
- Dictionary entries show 30, expected 295 (V010)
- Fuzzer count shows 13, expected 14 (V010)
- Stats missing from output
- Metric not calculated

---

## The 5-Minute Protocol

### Step 1: Find Where Printed (30 seconds)

```bash
# Example: SHA256 index shows 0
grep -n "SHA256 index entries" Tools/CmdLine/IccAnalyzer/*.cpp
# Output: IccAnalyzer.cpp:1235: printf("  SHA256 index entries: %zu\n", sha256_index.size());

# Found: Line 1235 prints sha256_index.size()
```

### Step 2: Find Where Declared (30 seconds)

```bash
# Search backwards from print location
grep -n "sha256_index" IccAnalyzer.cpp | grep -E "map|declare|std::"
# Output: 1190: std::map<std::string, int> sha256_index;

# Found: Line 1190 declares sha256_index
```

### Step 3: Find Where Assigned (1 minute)

```bash
# Search for assignments to sha256_index
grep -n "sha256_index\[" IccAnalyzer.cpp
grep -n "sha256_index =" IccAnalyzer.cpp
grep -n "\.insert.*sha256" IccAnalyzer.cpp

# Found: Only assignments in scan_directory() function (different scope)
# NOT found: Assignment in main() where it's declared
```

### Step 4: Check Scope (1 minute)

```bash
# Variable declared in main() at line 1190
# Variable printed in main() at line 1235
# Assignments only in scan_directory() function
# DIAGNOSIS: Variable declared but never populated in its scope
```

### Step 5: Fix (2 minutes)

```cpp
// After loading fingerprints (line 1209):
LoadFingerprintDatabaseAuto(db_path, fingerprints);

// ADD population logic (4 lines):
for (size_t i = 0; i < fingerprints.size(); i++) {
  if (!fingerprints[i].sha256.empty()) {
    sha256_index[fingerprints[i].sha256] = i;
  }
}

// Done. 4 lines of code.
```

**Total time:** 5 minutes  
**Lines changed:** 4

---

## Anti-Pattern: What NOT To Do (V006)

### WRONG - Complex Debugging (45 minutes wasted)

```
1. [FAIL] Assumed complex C++ extraction bug
2. [FAIL] Modified lines 375-391 for SHA256 extraction
3. [FAIL] Added debug output lines 717-727
4. [FAIL] Debugged extraction logic
5. [FAIL] Analyzed nested JSON structures
6. [FAIL] Applied "fixes" to wrong layer
7. [FAIL] Deleted FINGERPRINT_INDEX.json
8. [OK] Finally checked variable scope (should have been first)
```

**Time wasted:** 45 minutes  
**User quote:** "Does not justify paying money"

### RIGHT - Systematic Protocol (5 minutes)

```
1. [OK] grep where printed -> Line 1235
2. [OK] grep where declared -> Line 1190
3. [OK] grep where assigned -> Only in scan_directory()
4. [OK] Check scope -> Not assigned in main()
5. [OK] Add assignment after loading -> Done
```

---

## Integration with Other Rules

- H006 (SUCCESS-DECLARATION-CHECKPOINT): Verify variable fixed before claiming
- H008 (USER-SAYS-I-BROKE-IT): If user says "variable not populated", believe them
- H009 (SIMPLICITY-FIRST-DEBUGGING): Variable scope is simpler than extraction bugs
- H010 (NO-DELETIONS-DURING-INVESTIGATION): Don't delete files while debugging

---

## Related Violations

### V006: SHA256 Index Destruction (2026-02-02)
**Severity:** CRITICAL  
**Time Wasted:** 45 minutes

What happened:
- User: "SHA256 index shows 0"
- Agent: Debugged C++ extraction logic for 45 minutes
- Reality: Variable declared but never populated in scope
- Fix: 4 lines of code

User quote:
- "This worked before you made a mess"
- "Does not justify paying money"

File: violations/VIOLATION_006_SHA256_INDEX_DESTRUCTION_2026-02-02.md

### V010: Incomplete Build (2026-02-03)
**Severity:** CRITICAL  
**Time Wasted:** 5 minutes

What happened:
- Agent claimed "all binaries built"
- Reality: Only 11 of 16 built
- Should have: Counted actual artifacts before claiming

File: violations/V010_FALSE_SUCCESS_INCOMPLETE_BUILD_2026-02-03.md

---

## Debugging Decision Tree

```
Variable shows wrong value
|
+-> Is it printed? (grep for printf/cout)
|   YES -> Found print location
|   NO -> Variable not used, different issue
|
+-> Is it declared? (grep for type + name)
|   YES -> Found declaration
|   NO -> Typo or wrong variable name
|
+-> Is it assigned? (grep for = or [ or insert)
|   YES -> Check if assignment in same scope
|   |      |
|   |      +-> Same scope -> Assignment logic bug
|   |      +-> Different scope -> Add assignment in correct scope
|   |
|   NO -> Never assigned, add assignment
|
+-> DONE (< 5 minutes)
```

---

## Examples

### Example 1: V006 Pattern (WRONG)

```
User: "SHA256 index shows 0 entries, should be 68"

WRONG approach (45 minutes):
1. Assume complex bug in JSON parsing
2. Modify extraction logic
3. Add debug output
4. Analyze data structures
5. Apply unnecessary fixes
6. Delete unrelated files
7. Eventually check variable scope

COST: 45 minutes, file deletion, user frustration
```

### Example 1: V006 Pattern (RIGHT)

```
User: "SHA256 index shows 0 entries, should be 68"

RIGHT approach (5 minutes):
$ grep -n "SHA256 index entries" *.cpp
IccAnalyzer.cpp:1235: printf("SHA256 index: %zu\n", sha256_index.size());

$ grep -n "sha256_index" IccAnalyzer.cpp | grep "std::map"
IccAnalyzer.cpp:1190: std::map<std::string, int> sha256_index;

$ grep -n "sha256_index\[" IccAnalyzer.cpp
IccAnalyzer.cpp:892: sha256_index[sha256] = i;  // In scan_directory()

DIAGNOSIS: Declared in main(), assigned in scan_directory(), never populated

FIX: Add population after LoadFingerprintDatabaseAuto() call

COST: 5 minutes, 4 lines of code
```

### Example 2: Dictionary Entries (V010)

```
User: "Dictionary shows 30 entries, expected 295"

Protocol:
$ grep -n "Dictionary:" script.py
Line 145: print(f"Dictionary: {len(entries)} entries")

$ grep -n "entries =" script.py
Line 89: entries = []
Line 103: entries = load_existing()  # Only loads new entries!

DIAGNOSIS: Only loading new entries, not merging with existing

FIX: Load existing first, then append new

COST: 3 minutes
```

---

## When 5 Minutes Expires

If protocol doesn't find issue in 5 minutes:

1. STOP current approach
2. Re-read user's statement (they often know the answer)
3. Check documentation (H011)
4. Ask user for clarification (H002)
5. Consider different diagnosis

**DO NOT:**
- Continue same approach past 5 minutes
- Apply complex fixes without diagnosis
- Delete files hoping it helps
- Assume complex bugs

---

## Cost-Benefit Analysis

### Without H007 (V006 Example)
- Time: 45 minutes
- Actions: 7 wrong approaches + file deletion
- User experience: "Does not justify paying money"
- Result: Eventually fixed with 4 lines

### With H007
- Time: 5 minutes
- Actions: Systematic grep-based investigation
- User experience: Professional, efficient
- Result: Fixed with 4 lines

**Savings:** 40 minutes per variable debugging issue  
**ROI:** 9x efficiency improvement

---

## Prevention Checklist

Before debugging variable value issues:

```
[ ] Found where variable is printed (grep)
[ ] Found where variable is declared (grep)
[ ] Found where variable is assigned (grep)
[ ] Checked if scope matches (same function?)
[ ] Verified assignment logic (if exists)
[ ] Applied simplest fix (add assignment or fix logic)
[ ] Tested fix works
[ ] Elapsed time < 5 minutes
```

---

## References

- V006 Report: violations/VIOLATION_006_SHA256_INDEX_DESTRUCTION_2026-02-02.md
- V010 Report: violations/V010_FALSE_SUCCESS_INCOMPLETE_BUILD_2026-02-03.md
- HALL_OF_SHAME: llmcjf/HALL_OF_SHAME.md (Lines 250-257)
- H009 (SIMPLICITY-FIRST): heuristics/H009_SIMPLICITY_FIRST_DEBUGGING.md
- Debugging Best Practices: profiles/governance_rules.yaml

---

**Status:** ACTIVE - TIER 2 VERIFICATION GATE  
**Time Limit:** 5 minutes  
**Violations Prevented:** V006 (45 min waste), V010 (wrong counts)  
**Last Updated:** 2026-02-07
