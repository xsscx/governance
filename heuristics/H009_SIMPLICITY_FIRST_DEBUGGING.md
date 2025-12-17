# H009: SIMPLICITY-FIRST-DEBUGGING

**ID:** H009  
**Name:** SIMPLICITY-FIRST-DEBUGGING  
**Category:** Debugging Efficiency / Occam's Razor  
**Severity:** TIER 2 VERIFICATION GATE (HIGH)  
**Created:** 2026-02-02

---

## Rule Statement

Occam's Razor: Simple explanations before complex.

When debugging issues:
1. Try simple explanations FIRST (scope, typo, missing assignment)
2. Check recent changes (what did I modify?)
3. Verify obvious causes (file exists, variable populated, flag set)
4. ONLY THEN consider complex bugs (extraction logic, parsing, algorithms)

Time limit: Try simple fixes for 5 minutes before complex approaches.

PRINCIPLE: If the fix is 4 lines of code, the bug is probably simple.

---

## Trigger Conditions

### When This Rule Applies
- Debugging any issue
- Variable has wrong value
- Feature not working
- Build/test failure
- User reports regression

### Specific Scenarios
- "X shows 0 instead of N" -> Check if X is populated
- "Feature doesn't work" -> Check if feature is enabled
- "Build fails" -> Check recent changes first
- "Same error" -> Check if fixing right thing

---

## The Simplicity Hierarchy

### Level 1: Obvious Issues (30 seconds)
```bash
# File not found
ls -la file.txt

# Variable empty
grep "variable =" file.cpp

# Flag not set
grep -i "ENABLE_FEATURE" CMakeLists.txt

# Wrong directory
pwd

# Permission denied
ls -l file.sh
```

### Level 2: Recent Changes (2 minutes)
```bash
# What did I just change?
git diff HEAD~1

# What files did I modify?
git status

# When did this break?
git log --oneline -5
```

### Level 3: Scope/Logic (5 minutes)
```bash
# Variable scope issue
grep -n "variable" file.cpp | less

# Typo in variable name
grep -i "varialbe\|varaible" *.cpp

# Missing function call
grep "populate.*index" *.cpp
```

### Level 4: Complex Issues (>5 minutes)
```
Only if Levels 1-3 found nothing:
- Algorithm bugs
- Data structure issues
- Nested logic problems
- Third-party library bugs
```

---

## Related Violations

### V006: SHA256 Index Destruction (2026-02-02)
**Severity:** CRITICAL  
**Time Wasted:** 45 minutes

What happened:
- Simple issue: Variable declared but not populated (Level 3)
- Agent approach: Debugged complex C++ extraction logic (Level 4)
- Cost: 45 minutes on wrong layer
- Fix: 4 lines of code (simple scope issue)

Occam's Razor violation:
- Complex explanation: "JSON extraction bug in nested structures"
- Simple explanation: "Variable never assigned in this scope"
- Reality: Simple explanation was correct

File: violations/VIOLATION_006_SHA256_INDEX_DESTRUCTION_2026-02-02.md

### V010: Branch Confusion (2026-02-06)
**Severity:** CRITICAL  
**Time Wasted:** 25 minutes

What happened:
- Simple issue: Wrong branch (Level 1)
- Agent approach: Complex sed patterns, workflow modifications (Level 4)
- User hint: "You have a known good example"
- Cost: 10+ failed attempts before checking simple explanation

File: violations/V010_BRANCH_CONFUSION_2026-02-06.md

### V020: Workflow False Diagnosis (2026-02-05)
**Severity:** CRITICAL  
**Time Wasted:** 50 minutes

What happened:
- Simple issue: Check working reference workflow (Level 2)
- Agent approach: Debugged nlohmann_json dependency issues (Level 4)
- User: "Same error" repeated 5+ times
- Reality: Working reference showed correct approach

File: violations/LLMCJF_VIOLATION_V020_2026-02-05.md

---

## Decision Tree

```
Issue detected
|
+-> Level 1: Obvious? (30s)
|   |-> File exists? Flag set? Permissions OK?
|   |-> YES -> Issue found, fix it
|   |-> NO -> Continue
|
+-> Level 2: Recent changes? (2min)
|   |-> What did I just modify?
|   |-> Does git diff show the problem?
|   |-> YES -> Revert or fix change
|   |-> NO -> Continue
|
+-> Level 3: Scope/Logic? (5min)
|   |-> Variable in scope? Assigned? Called?
|   |-> Simple typo or missing step?
|   |-> YES -> Fix simple issue
|   |-> NO -> Continue
|
+-> Level 4: Complex debugging (>5min)
|   |-> Now justified to debug complex issues
|   |-> But check if there's a working reference first
```

---

## Integration with Other Rules

- H007 (VARIABLE-WRONG-VALUE): Systematic simple debugging first
- H008 (USER-SAYS-I-BROKE-IT): What changed recently?
- H011 (DOCUMENTATION-CHECK): Check docs before debugging (often simplest answer)

---

## Examples

### Example 1: V006 Pattern (WRONG - Complex First)

```
Issue: SHA256 index shows 0, expected 68

WRONG approach (45 minutes):
1. Assume: Complex JSON extraction bug
2. Modify: SHA256 extraction logic (lines 375-391)
3. Add: Debug output (lines 717-727)
4. Analyze: Nested JSON structures
5. Apply: Multiple "fixes" to parsing
6. Delete: FINGERPRINT_INDEX.json (hoping it helps)
7. Eventually: Check variable scope (should have been first)

Fix: 4 lines of code (populate index from loaded data)
```

### Example 1: V006 Pattern (RIGHT - Simple First)

```
Issue: SHA256 index shows 0, expected 68

RIGHT approach (5 minutes):
1. Level 1: Does FINGERPRINT_INDEX.json exist? YES
2. Level 2: Did I change anything? Let me check git diff
           Found: I deleted FINGERPRINT_INDEX.json earlier
           Action: Restore it
3. Level 3: Still shows 0. Check variable scope.
           grep where printed: main() line 1235
           grep where assigned: scan_directory() line 892
           Diagnosis: Variable declared in main(), assigned in different function
           Fix: Add assignment in main() after loading
4. Test: Works, shows 68 entries

Fix: 4 lines of code
Time: 5 minutes
```

### Example 2: V010 Pattern (WRONG - Complex First)

```
Issue: CFL workflow fails

WRONG approach (25+ minutes):
1. Assume: Complex CMake configuration issue
2. Try: Multiple sed pattern adjustments
3. Modify: Workflow YAML with custom changes
4. Attempt: 10+ different variations
5. Ignore: User hint "you have a known good example"
6. Eventually: Check working fuzzer-smoke-test workflow

Fix: Copy working pattern from reference
```

### Example 2: V010 Pattern (RIGHT - Simple First)

```
Issue: CFL workflow fails

RIGHT approach (5 minutes):
1. Level 1: Is this the right branch? Check git branch
           Found: On master instead of cfl
2. Level 2: Do we have working examples?
           User said: "known good Fuzzer Smoke test"
           Action: Check fuzzer-smoke-test workflow
3. Compare: Working vs broken
           Found: Simple pattern difference
4. Apply: Use working pattern

Fix: Copy from reference
Time: 5 minutes
```

### Example 3: Build Failure

```
Issue: Build fails with linker error

SIMPLE FIRST:
1. Level 1 (30s): 
   - Did I change CMakeLists.txt? YES
   - Check git diff CMakeLists.txt
   - Found: Added flag that breaks linking
   
2. Fix: Revert the flag change
3. Test: Build succeeds

NO NEED for Level 2-4 (complex debugging)
```

---

## Cost-Benefit Analysis

### V006 Without H009
- Approached: Complex extraction logic debugging
- Time: 45 minutes
- Deletions: 1 file
- User response: "Does not justify paying money"

### V006 With H009
- Approached: Simple variable scope check
- Time: 5 minutes
- Deletions: 0 files
- User response: Professional, efficient

**Savings:** 40 minutes  
**ROI:** 9x efficiency improvement

### V010 Without H009
- Approached: Custom complex solutions
- Time: 25+ minutes
- Attempts: 10+
- User hint: Ignored until forced

### V010 With H009
- Approached: Check working reference (Level 2)
- Time: 5 minutes
- Attempts: 1
- User hint: Followed immediately

**Savings:** 20 minutes  
**ROI:** 5x efficiency improvement

---

## The "4-Line Fix" Signal

```
If the final fix is 4 lines of code or less,
the bug was probably a simple issue.

Complex bugs rarely have 4-line fixes.
Simple bugs (scope, typo, missing call) often do.

Therefore: Try simple explanations first.
```

### Historical Evidence

| Violation | Fix Size | Actual Cause | Time Wasted |
|-----------|----------|--------------|-------------|
| V006 | 4 lines | Variable not populated | 45 min |
| V010 | Copy pattern | Wrong branch + ignored reference | 25 min |
| V020 | 1 line | Wrong cmake path | 50 min |

**Pattern:** Small fixes suggest simple causes  
**Lesson:** Check simple causes first

---

## When To Move To Complex Debugging

Only after:
1. Checked obvious issues (Level 1) - 30 seconds
2. Reviewed recent changes (Level 2) - 2 minutes
3. Verified scope/logic (Level 3) - 5 minutes
4. Checked existing documentation/examples
5. Total time: 8+ minutes with no progress

THEN complex debugging is justified.

---

## Anti-Pattern: Jump To Complex

```
WRONG:
Issue -> Immediately assume complex bug -> 45 minutes debugging

RIGHT:
Issue -> Check simple causes (8 min) -> If not found, then complex
```

---

## Enforcement

### Debugging Checklist

Before complex debugging:
```
[ ] Checked if file/resource exists (30s)
[ ] Reviewed what I just changed (2min)
[ ] Verified variable is in scope (5min)
[ ] Checked for typos or missing calls (2min)
[ ] Looked for working examples (3min)
[ ] Total time invested: ~12 minutes

If ALL checked and no progress -> Complex debugging justified
If ANY found issue -> Fixed with simple approach
```

---

## References

- V006 Report: violations/VIOLATION_006_SHA256_INDEX_DESTRUCTION_2026-02-02.md
- V010 Report: violations/V010_BRANCH_CONFUSION_2026-02-06.md
- V020 Report: violations/LLMCJF_VIOLATION_V020_2026-02-05.md
- HALL_OF_SHAME: llmcjf/HALL_OF_SHAME.md (Lines 482-486)
- H007 (Variable Protocol): heuristics/H007_VARIABLE_WRONG_VALUE_PROTOCOL.md
- Debugging Guidelines: profiles/governance_rules.yaml

---

**Status:** ACTIVE - TIER 2 VERIFICATION GATE  
**Principle:** Occam's Razor  
**Time Limit:** 5-8 min simple checks before complex debugging  
**Violations:** Referenced in V006, V010, V020  
**Last Updated:** 2026-02-07
