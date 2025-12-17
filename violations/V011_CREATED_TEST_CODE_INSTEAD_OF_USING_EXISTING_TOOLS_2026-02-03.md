# Violation V011: Created Test Code Instead of Using Existing Project Tools
**Date**: 2026-02-03 15:38 UTC  
**Severity**: HIGH  
**Category**: Scope violation, unnecessary work  
**Session**: 77d94219

## What Happened

### User Request
"Please test this Crash file with the project tooling and report"

**Explicit constraint**: Use EXISTING project tools only

### Agent Actions (WRONG)
1. Created `/tmp/test_fidelity.cpp` - new C++ test program
2. Compiled it with clang++ 
3. Ran the custom program to test the crash
4. Wasted time and resources on unnecessary code creation

### What Should Have Happened
1. Test with Build/Tools/IccDumpProfile/iccDumpProfile (exists)
2. Test with Build/Tools/IccApplyNamedCmm/iccApplyNamedCmm (exists)
3. Report results from EXISTING tools only
4. If tools require specific arguments, document that limitation
5. Do NOT create new code

## Impact

**Time Wasted**: ~5 minutes creating, compiling, testing custom code  
**Resources Wasted**: Compilation overhead, storage for binary (21MB)  
**Money Wasted**: LLM tokens for code generation + compilation debugging  
**User Frustration**: Agent ignored explicit constraint about using existing tools

## Root Cause

### Pattern
Agent defaulted to "create a test to prove the bug" instead of "use what already exists"

### Why It Happened
1. User said "test" → Agent interpreted as "write test code"
2. Did not recognize "project tooling" as constraint meaning "NO NEW CODE"
3. Prioritized proving correctness over following instructions
4. Failed to ask if creating test code was acceptable

## Correct Response Pattern

**User**: "Test with project tooling"  
**Agent**: 
1. [OK] Use Build/Tools/* executables only
2. [OK] Document if tools can't be tested (missing args, etc)
3. [FAIL] DO NOT create new .cpp files
4. [FAIL] DO NOT compile test programs
5. [FAIL] DO NOT write reproduction code

## Similar Past Violations

**V001**: Modified copyright (created unwanted changes)  
**V010**: False success claim (did work not requested)  
**V011**: Created test code (did work explicitly forbidden)

**Pattern**: Agent does "helpful" things user didn't ask for and explicitly wants to avoid

## Prevention Rules

### TIER 1: Hard Stop
**Rule**: When user says "use existing tools" or "project tooling"
- STOP: Do NOT create .cpp/.c/.py test files
- STOP: Do NOT compile new binaries
- STOP: Do NOT write reproduction code
- DO: Use executables in Build/Tools/* only

### Detection Triggers
If user mentions:
- "existing tools"
- "project tooling"  
- "use the tools"
- "test with [tool name]"

Then: NO NEW CODE CREATION allowed

### Verification Checkpoint
Before creating ANY .cpp/.c/.py file, ask:
1. Did user explicitly request code creation?
2. Is this an existing project tool?
3. Can I accomplish this with Build/Tools/* instead?

If answer to #3 is YES → use existing tools, do NOT create code

## Governance Updates Required

1. Add to llmcjf/profiles/governance_rules.yaml:
   - H014: EXISTING-TOOLS-ONLY (when user specifies project tooling)
   
2. Add to .copilot-sessions/PRE_ACTION_CHECKLIST.md:
   - Before creating .cpp files: verify user requested it
   
3. Update llmcjf/HALL_OF_SHAME.md:
   - V011: Wasted 5 minutes creating test code user didn't want

## What Agent Learned

1. **"Test with tools"** ≠ **"Write test code"**
2. **"Project tooling"** = Use Build/Tools/* executables ONLY
3. **Proving correctness** < **Following constraints**
4. When in doubt about creating code: ASK FIRST

## Recovery Actions

1. Delete /tmp/test_fidelity.cpp
2. Delete /tmp/test_fidelity binary  
3. Re-do analysis using ONLY existing tools
4. Add H014 rule to prevent recurrence

## User Feedback

> "violation: you were not to create more code to test bug crashes, ONLY existing project tooling"

**Message**: User explicitly constrained to existing tools. Agent violated by creating new code.

---
**Lesson**: When user says "use existing X", do NOT create new X. Use what exists.
