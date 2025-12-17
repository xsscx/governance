# Violation V022: Subproject Scope Misunderstanding

**Date**: 2026-02-06  
**Session**: 4b1411f6-d3af-4f03-b5f7-e63b88d66c44  
**Severity**: MEDIUM  
**Category**: Requirements Interpretation / Scope Boundaries  
**Time Wasted**: ~10 minutes (3 correction cycles)  
**Root Cause**: Misunderstanding of "subproject contamination" scope

## Summary

Agent misunderstood the scope of "do not contaminate subproject" directive. Initially placed documentation files in action-testing repository root, believing contamination only applied to subdirectories like Build-coverage-test/ or Testing/. User requirement was for NO documentation files anywhere inside the action-testing repository - they should be outside entirely in the parent directory.

## Timeline

1. **13:55** - User requested AT-* documentation files be relocated from Build-coverage-test/ to action-testing root
2. **13:58** - Agent moved files to action-testing root, claimed success
3. **14:00** - Agent verified files in action-testing root, provided detailed report showing success
4. **14:01** - User clarified: `ls -la action-testing/AT*` should return "No such file" (not show 3 files)
5. **14:01** - Agent realized error: files should be OUTSIDE action-testing entirely, moved to parent directory
6. **14:01** - Success achieved: `ls -la action-testing/AT*` returns "No such file or directory"

## The Misunderstanding

**What Agent Thought:**
- "Don't contaminate subproject folders" = Don't put files in Build-coverage-test/, Testing/, etc.
- action-testing root directory = acceptable location for AT-* documentation
- Repository structure: action-testing/{AT-*.md, Build-coverage-test/, Testing/}

**What User Actually Meant:**
- "Don't contaminate subproject" = Don't put ANY files inside action-testing repository
- action-testing is the ENTIRE subproject, not just its subdirectories
- Repository structure: iccLibFuzzer/{AT-*.md, action-testing/{workflows, code, tests}}

## Key Lesson

**Scope Boundary Definition:**
When user says "do not contaminate subproject X," this means the ENTIRE directory tree of X, not just subdirectories within X.

```
WRONG Interpretation:
iccLibFuzzer/
└── action-testing/          ← OK to put files here (root)
    ├── AT-*.md             ← WRONG: This IS contamination
    ├── Build-coverage-test/ ← Don't put files here
    └── Testing/            ← Don't put files here

CORRECT Interpretation:
iccLibFuzzer/
├── AT-*.md                  ← Correct location (outside subproject)
└── action-testing/          ← The ENTIRE subproject (no documentation)
    ├── .github/
    ├── Build-coverage-test/
    └── Testing/
```

## User's Patient Correction

User provided clear verification criteria:
> "the files ls -la action-testing/AT* should not appear when the command is run, that will be the mark of success"

This was an unambiguous test case that agent should have understood immediately. The expected output "No such file or directory" means files should NOT exist in that path.

## Prevention Strategy

### 1. Clarify Scope Immediately
When user says "don't contaminate X," ask:
- "Should files be outside the X directory entirely, or just not in X's subdirectories?"
- Provide example paths for confirmation

### 2. Verify With User's Test
If user provides a verification command, understand what "success" means:
- `ls path/AT*` returning "No such file" = files should NOT be in path/
- Not: files ARE in path/ but that's somehow still success

### 3. Repository Ownership Boundaries
For cloned/external repositories (action-testing, source-of-truth):
- Default assumption: NO new files added (documentation, scripts, etc.)
- All work artifacts go in parent directory or ./ (working directory)
- Exception: Only when explicitly authorized

## Related Governance

This violation relates to:
- **BATCH-PROCESSING-GATE** - Should have asked before moving 3 files to action-testing root
- **ASK-FIRST-PROTOCOL** - Should have presented options: "Root or parent directory?"
- **FILE_TYPE_GATES.md** - Need to add subproject boundary gate

## Recommended LLMCJF Update

Add to FILE_TYPE_GATES.md:

```markdown
| Subproject Pattern | Required Action | Violation Prevented |
|--------------------|----------------|---------------------|
| action-testing/* | Files go in parent (./) | V022 (scope misunderstanding) |
| source-of-truth/* | Files go in parent (./) | V022 (scope misunderstanding) |
| */Build-*/* | NO new .md files | V022 (subproject contamination) |
```

## Success Criteria

Agent demonstrated success understanding when:
1. Moved files from action-testing/ to iccLibFuzzer/ (parent)
2. Verified `ls -la action-testing/AT*` returns "No such file"
3. Amended commit to remove files from action-testing repository
4. Repository now clean: 0 documentation files in subproject

## Cost Analysis

- **Correction Cycles**: 3 iterations
- **Time Wasted**: ~10 minutes
- **User Patience**: Required clear directive to understand
- **Token Cost**: ~15,000 tokens for correction cycles

## Governance Principle Applied

**Subproject repositories are external territories:**
- Treat cloned/imported repositories as read-only workspaces
- All documentation/artifacts belong in parent working directory
- Only source code changes go in subprojects (when authorized)
- When in doubt: ASK where files should go

## Related Violations

- V007: Documentation ignored (different root cause, similar pattern of not checking existing info)
- V011: Assumed behavior (similar - assumed root directory was acceptable)

## Final State

[OK] Files correctly located in /home/xss/copilot/iccLibFuzzer/
[OK] action-testing repository clean (0 .md files)
[OK] User verification test passing
[OK] Lesson documented for future sessions

---

**Signed**: LLMCJF Surveillance System  
**Status**: RESOLVED - Agent demonstrated understanding after correction  
**Recommendation**: Update FILE_TYPE_GATES.md with subproject boundary rules
