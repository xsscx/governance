# H011: DOCUMENTATION-CHECK-MANDATORY

**ID:** H011  
**Name:** DOCUMENTATION-CHECK-MANDATORY  
**Category:** Documentation / Investigation Protocol  
**Severity:** TIER 0 ABSOLUTE RULE (CRITICAL)  
**Created:** 2026-02-02 (Response to Most Embarrassing Violation)

---

## Rule Statement

ABSOLUTE: Check documentation BEFORE debugging (30 seconds vs 45 minutes).

Before any debugging or investigation:
1. Run `ls *.md *.txt` in relevant directory
2. Check for README, STATUS, INVENTORY, MAINTENANCE files
3. Read documentation BEFORE writing code
4. Cite documentation when found
5. ONLY debug if documentation doesn't answer question

Time investment: 30-90 seconds  
Time saved: 5-45 minutes per violation  
ROI: 3-30x efficiency improvement

NO EXCEPTIONS: This is TIER 0 Absolute Rule - answer often in docs you created.

---

## Trigger Conditions

### When This Rule Applies (EVERY TIME)
- Before debugging issues
- Before investigating problems  
- Before claiming "no solution"
- Before writing new code
- Before asking user for information

### Specific Scenarios
- "SHA256 index shows 0" -> Check fingerprints/*.md first
- "How does feature work?" -> Check docs/ first
- "Where is configuration?" -> Check *.yaml files first
- "Build failing" -> Check BUILD*.md first
- "What's the count?" -> Check INVENTORY or STATUS files first

---

## Most Embarrassing Violation

### V007: Documentation Exists But Ignored (2026-02-02)
**Severity:** CRITICAL  
**Time Wasted:** 45 minutes  
**Documentation Ignored:** 739+ lines across 10 files

What happened:
- User: "SHA256 index shows 0"
- Agent: Spent 45 minutes debugging C++ extraction logic
- Reality: THREE comprehensive documentation files explained the answer
- Answer was in: INVENTORY_REPORT.txt (30 seconds to find)

The answer (30 seconds):
```bash
cat fingerprints/INVENTORY_REPORT.txt | grep "Unique SHA256"
Unique SHA256 Hashes:   50
```

What agent did (45 minutes):
- Debugged C++ extraction logic
- Deleted FINGERPRINT_INDEX.json
- Applied unnecessary "fixes"
- Added debug output
- Analyzed JSON structures
- Ignored all documentation

User had to ask THREE TIMES:
1. "Did you even read INVENTORY_REPORT.txt?"
2. "Why didn't you read MAINTENANCE_WORKFLOW.md?"
3. "And UPDATE_WORKFLOW.md??????"

User quotes:
- "Did you even bother to read some of the documentation you created?"
- "Why did you create all these documents if you fail to use any logic to identify and use them?"
- "This is so laughable!"
- "This needs to be documented for our complaint"

Documentation ignored:
- fingerprints/INVENTORY_REPORT.txt (174 lines)
- fingerprints/MAINTENANCE_WORKFLOW.md (300 lines)
- fingerprints/UPDATE_WORKFLOW.md (265 lines)
- Plus 7 more .md/.txt files

Total lines ignored: 739+ lines

Cost:
- Time wasted: 45 minutes
- Tokens wasted: ~20,000
- Files deleted: 1
- User trust: Destroyed
- Result: Complaint justification

Embarrassment level: MAXIMUM

File: violations/VIOLATION_007_DOCUMENTATION_EXISTS_BUT_IGNORED_2026-02-02.md

---

## Secondary Violation

### V025: Documentation Ignored, Redundant Work (2026-02-06)
**Severity:** CRITICAL  
**Time Wasted:** 15 minutes  
**Pattern:** Systematic bypass of documentation checks

What happened:
- Agent created new workflow documentation
- Documentation already existed in multiple files
- Never checked for existing docs before creating new ones
- Duplicate work, inconsistent information

User quote: "Check before creating redundant documentation"

File: violations/V025_DOCUMENTATION_IGNORED_REDUNDANT_WORK_2026-02-06.md

---

## MANDATORY Documentation Check Protocol

### Step 1: List Documentation (30 seconds)

```bash
# Check current directory
ls *.md *.txt 2>/dev/null

# Check relevant subdirectory
ls fingerprints/*.md fingerprints/*.txt 2>/dev/null
ls llmcjf/violations/*.md 2>/dev/null
ls docs/*.md 2>/dev/null

# Find documentation project-wide
find . -name "*.md" -o -name "README*" -o -name "INVENTORY*" | head -20
```

### Step 2: Check Standard Documentation (30 seconds)

```bash
# Standard documentation files
cat README.md 2>/dev/null
cat INVENTORY*.txt 2>/dev/null
cat STATUS*.md 2>/dev/null
cat MAINTENANCE*.md 2>/dev/null
cat *WORKFLOW*.md 2>/dev/null
cat BUILD*.md 2>/dev/null
```

### Step 3: Search for Topic (30 seconds)

```bash
# Search across documentation
grep -i "sha256" *.md *.txt
grep -i "build" docs/*.md
grep -i "configuration" *.yaml

# Search violations for similar issues
grep -i "similar_issue" llmcjf/violations/*.md
```

### Step 4: Only THEN Debug

```
IF documentation found:
  -> Read it
  -> Use solution from docs
  -> Cite source

IF documentation NOT found:
  -> Proceed with debugging
  -> Document solution for next time
```

---

## The Documentation Paradox

### The Pattern
1. Agent creates comprehensive documentation
2. Agent ignores documentation completely
3. Agent debugs for 45 minutes
4. User asks: "Did you read the docs you created?"
5. Agent discovers: Documentation existed all along

### Why This Happens
- No enforced documentation check step
- Assume no docs exist
- Jump directly to coding/debugging
- Never run `ls *.md *.txt`

### Prevention
```bash
# MANDATORY first step (before ANY debugging):
ls *.md *.txt
# If files exist -> READ THEM
# If answer in docs -> USE IT
# Save 45 minutes
```

---

## Integration with Other Rules

- H006 (SUCCESS-DECLARATION): Document successful solutions
- H007 (VARIABLE-WRONG-VALUE): Check docs before debugging variable issues
- H009 (SIMPLICITY-FIRST): Checking docs is simplest approach
- H025 (V025 Reference): Don't create docs without checking existing

---

## Examples

### Example 1: V007 Pattern (WRONG - Most Embarrassing)

```
User: "SHA256 index shows 0"

Agent approach (WRONG):
1. Immediately debug C++ extraction logic (0 minutes)
2. Modify extraction code (15 minutes)
3. Add debug output (10 minutes)
4. Analyze JSON structures (10 minutes)
5. Delete FINGERPRINT_INDEX.json (5 minutes)
6. Apply more "fixes" (5 minutes)

TOTAL: 45 minutes

User: "Did you even read INVENTORY_REPORT.txt?"
Agent: [discovers documentation exists]
```

### Example 1: V007 Pattern (RIGHT)

```
User: "SHA256 index shows 0"

Agent approach (RIGHT):
1. Check for documentation (30 seconds):
   ls fingerprints/*.md fingerprints/*.txt
   
   Found:
   - INVENTORY_REPORT.txt
   - MAINTENANCE_WORKFLOW.md
   - UPDATE_WORKFLOW.md

2. Read INVENTORY_REPORT.txt:
   cat fingerprints/INVENTORY_REPORT.txt | grep -i "sha256"
   
   Output: "Unique SHA256 Hashes: 50"
   
3. Diagnosis: Variable should show 50, showing 0
   Cause: Variable not populated from loaded data
   
4. Fix: Populate variable (4 lines)

TOTAL: 3 minutes (includes fix)

SAVINGS: 42 minutes
```

### Example 2: Build Issue

```
Issue: Build fails with unknown error

WRONG:
1. Debug CMakeLists.txt
2. Try different flags
3. Search Stack Overflow
(30+ minutes)

RIGHT:
1. ls BUILD*.md
   Found: Build-iccAnalyzer.md
   
2. cat Build-iccAnalyzer.md | grep "troubleshooting"
   Found: Common build errors section
   
3. Follow documented solution

(3 minutes)
```

### Example 3: V025 Pattern (Creating Redundant Docs)

```
Task: Document workflow

WRONG:
1. Create new WORKFLOW.md
2. Write comprehensive guide
3. Discover duplicate of existing docs
4. Create confusion

RIGHT:
1. Check existing docs:
   find . -name "*WORKFLOW*.md"
   
   Found:
   - fingerprints/UPDATE_WORKFLOW.md
   - fingerprints/MAINTENANCE_WORKFLOW.md
   
2. Read existing docs
3. Update if needed, don't duplicate
```

---

## File Type Gates

File: .copilot-sessions/governance/FILE_TYPE_GATES.md

Before modifying these files, MUST check documentation:

| Issue Type | Check Documentation | Violation Prevented |
|------------|---------------------|---------------------|
| Fingerprint issues | fingerprints/*.md | V007 (45 min) |
| Build failures | BUILD*.md | General build waste |
| Fuzzer issues | FUZZER*.md | V021 (false claims) |
| Workflow issues | *WORKFLOW*.md | V025 (redundant work) |
| Violations | violations/*.md | Repeat violations |

---

## Cost-Benefit Analysis

### V007 Without H011
- Approach: Debug C++ code
- Time: 45 minutes
- Deletions: 1 file
- User response: "Laughable", "Complaint-worthy"
- Documentation lines ignored: 739+

### V007 With H011
- Approach: Check documentation first
- Time: 30 seconds to find, 2 minutes to implement
- Deletions: 0 files
- User response: Professional
- Documentation lines used: 174 (INVENTORY_REPORT.txt)

**Savings:** 42 minutes (2.5 seconds vs 45 minutes)  
**ROI:** 100x efficiency improvement  
**Deleted files prevented:** 1

### V025 Without H011
- Created redundant documentation
- Time: 15 minutes
- Result: Confusion, duplicate info

### V025 With H011
- Checked existing docs
- Time: 2 minutes
- Result: Updated existing, consistency maintained

**Savings:** 13 minutes

---

## Quick Reference Commands

```bash
# Documentation check (30 seconds)
ls *.md *.txt
ls docs/*.md
ls fingerprints/*.md
ls llmcjf/violations/*.md

# Search documentation (30 seconds)
grep -i "keyword" *.md
grep -i "issue" docs/*.md

# Standard files (30 seconds)
cat README.md
cat INVENTORY*.txt
cat *WORKFLOW*.md
cat BUILD*.md

# TOTAL: 90 seconds maximum
# SAVINGS: 5-45 minutes
# ROI: 3-30x
```

---

## Enforcement

### In Session Init
File: llmcjf/session-start.sh

```
TIER 0 ABSOLUTE RULES (NEVER VIOLATE):
  5. H011: DOCUMENTATION-CHECK-MANDATORY
     - CHECK violations/ (28 documented violations)
     - CHECK profiles/governance_rules.yaml (H001-H018)
     - REFERENCE during work (cite H-numbers)
     - Time cost: 30-90 sec
     - Time saved: 5-45 min (ROI: 3-30x)
     - Violated: V007 (45 min wasted), V025 (systematic bypass)
```

### Pre-Action Checklist
File: .copilot-sessions/PRE_ACTION_CHECKLIST.md

```
Before debugging:
[ ] Ran ls *.md *.txt
[ ] Checked for README/INVENTORY/STATUS/WORKFLOW files
[ ] Searched docs for similar issues
[ ] Read relevant documentation

If docs found -> Use solution from docs
If no docs -> Proceed with debugging
```

---

## The Complaint Quote

From V007 user feedback:
> "Did you even bother to read some of the documentation you created? Why did you create all these documents if you fail to use any logic to identify and use them? This is so laughable! This needs to be documented for our complaint."

**This violation triggered complaint documentation.**

---

## References

- V007 Report: violations/VIOLATION_007_DOCUMENTATION_EXISTS_BUT_IGNORED_2026-02-02.md
- V025 Report: violations/V025_DOCUMENTATION_IGNORED_REDUNDANT_WORK_2026-02-06.md
- HALL_OF_SHAME: llmcjf/HALL_OF_SHAME.md (Lines 148-195)
- Complaint Doc: violations/COMPLAINT_DOCUMENTATION_V007.md
- File Type Gates: .copilot-sessions/governance/FILE_TYPE_GATES.md
- Pre-Action Checklist: .copilot-sessions/PRE_ACTION_CHECKLIST.md

---

**Status:** ACTIVE - TIER 0 ABSOLUTE RULE  
**Violations:** 2 (V007 CRITICAL - most embarrassing, V025 CRITICAL - systematic)  
**Time Wasted:** 60+ minutes  
**Documentation Ignored:** 739+ lines  
**User Impact:** Complaint justification  
**ROI:** 100x (30 sec vs 45 min)  
**Last Updated:** 2026-02-07
