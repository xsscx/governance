# LLM Debugging Checklist (Anti-LLMCJF)

## Protocol H007-H010 Quick Reference

### H007: Variable Shows Wrong Value → 5 Min Protocol
1. `grep -n "var.size()"` → Find print location
2. `grep -n "std::.*var"` → Find declaration  
3. `grep -n "var\["` → Find assignments
4. **Not assigned in usage scope? → Add 4-line loop → DONE**

### H008: User Says "You Broke This" → HALT Immediately
1. **STOP current work**
2. `git diff HEAD` → Check my changes
3. `git stash && test && git stash pop` → Verify
4. **Accept user correction as ground truth**

### H009: Simplicity-First (Occam's Razor)
- Level 1-2 (98%): Variable not init / not assigned in scope → 5 min
- Level 3-4 (1.9%): Wrong name / logic error → 10 min
- Level 5 (0.1%): Complex bugs → Only after 1-4 exhausted

### H010: Never Delete During Investigation
- [OK] Read, add debug (mark TODO:REMOVE), test, check git
- [FAIL] Delete files, modify logic, make clean, batch sed

## V006 Example: What Went Wrong

**User Report:** SHA256 index shows 0  
**Should Have Taken:** 5 minutes  
**Actually Took:** 45 minutes  

### Wrong Approach (What I Did)
1. Claimed pre-existing issue [FAIL]
2. Found I deleted FINGERPRINT_INDEX.json [FAIL]
3. Applied C++ extraction "fix" [FAIL]
4. Added debug output [FAIL]
5. Analyzed JSON nested structures [FAIL]
6. Finally found bug: index never populated [OK]

### Correct Approach (H007 Protocol)
1. `grep -n "sha256_index.size()"` → Line 1235
2. `grep -n "std::map.*sha256_index"` → Line 1190 (declared)
3. `grep -n "sha256_index\["` → Line 722 (in scan_directory, not main!)
4. **Bug:** Index declared in main() but never populated
5. **Fix:** Add 4-line loop after LoadFingerprintDatabaseAuto()
6. **Done**

**Cost:** Wasted 40 minutes + deleted file + user frustration

## Success Criteria

**Good:** <5 min, 1 file, <10 lines, 1 rebuild, 0 user corrections  
**Bad (V006):** 45 min, 2 files, 30+ lines, 3 rebuilds, 4 user corrections

---
*Created 2026-02-02 - See llmcjf/violations/VIOLATION_006*.md for full analysis*
