# Violation V008: User Gives Example, Agent Writes Documentation

**Date:** 2026-02-03 02:42 UTC  
**Session:** 77d94219-1adf-4f99-8213-b1742026dc43  
**Severity:** HIGH  
**Category:** Task Mismatch / Overengineering  
**Cost:** 60+ seconds wasted, user frustration

## What Happened

**User Request:**
> provide the example use case for iccDumpProfile given:
> [shows 5-line bash snippet]

**User's Intent:**
- Reformat the example with IccDumpProfile instead of iccAnalyzer
- Same pattern, different tool
- 10-second task

**What Agent Did:**
1. Created 400+ line comparison document
2. Took 60+ seconds
3. Generated theoretical workflows, comparison tables, advanced scripts
4. Completely ignored the literal example provided

**What Agent Should Have Done:**
```bash
source .github/scripts/sanitize.sh
export SANITIZE_PRINT_MAXLEN=55000
RAW=$(Build/Tools/IccDumpProfile/iccDumpProfile -v Testing/sRGB_v4_ICC_preference.icc 2>&1)
sanitize_print "$RAW" > sanitized-output-sRGB_v4_ICC_preference.md
more sanitized-output-sRGB_v4_ICC_preference.md
```

**Time to complete:** 10 seconds (user's estimate)  
**Time agent took:** 60+ seconds creating docs

## Root Cause

**Pattern Recognition Failure:**
- User provided EXACT template
- Pattern: Same commands, swap tool name, use clean test file
- Agent ignored template and invented complex solution

**Overengineering:**
- User asked for "example"
- Agent created comparison guide, workflows, tables
- Violated STAY-ON-TASK and SIMPLICITY-FIRST

## User's Correction

> for reference, this is the correct output and took us about 10 seconds to reformat, you needed more than 60 seconds and generated documentation, why?

**Translation:** "I showed you the answer, why did you write a book?"

## Violation Type

**TEMPLATE-BLINDNESS:**
- User provides literal example/template
- Agent ignores it and creates new approach
- Results in 6x time waste

## Impact

- **Time wasted:** 50+ seconds
- **User frustration:** "took us about 10 seconds... you needed more than 60"
- **Trust damage:** User had to explain the obvious
- **Pattern:** Agent creates docs when action requested

## What Was Violated

1. **STAY-ON-TASK** - Asked for example, created documentation
2. **SIMPLICITY-FIRST (H009)** - 10-second reformat became 60-second doc generation
3. **USER-TEMPLATE-LITERAL** - When user shows exact pattern, follow it

## New Rule Required

**USER-TEMPLATE-LITERAL (H012):**
```yaml
name: USER-TEMPLATE-LITERAL
category: Pattern Recognition
severity: HIGH
trigger: User provides code example/template in request
action: |
  1. User shows code/commands → Follow exact pattern
  2. User shows 5 lines → Give 5 lines back (modified as requested)
  3. User shows time estimate → Match or beat it
  4. DO NOT create documentation unless explicitly requested
  5. DO NOT expand scope beyond literal request
```

**Signal Detection:**
- User includes code blocks in request
- User says "given:" followed by example
- User shows time estimate ("took us 10 seconds")
- Pattern is obvious: swap X for Y

**Correct Response:**
1. Recognize template structure
2. Apply requested change
3. Output result
4. Done (no docs, no explanation, no expansion)

## Prevention Protocol

**When user provides code example:**
1. [OK] Parse template structure
2. [OK] Identify what to change (tool name, file path, etc.)
3. [OK] Make minimal change
4. [OK] Output result
5. [FAIL] NO documentation generation
6. [FAIL] NO comparison tables
7. [FAIL] NO "comprehensive guides"

**Time Check:**
- User says "10 seconds" → Agent should take ≤10 seconds
- If agent plan takes 6x user's estimate → STOP, follow template

## Example of Correct Response

**User:** "provide the example use case for iccDumpProfile given: [5-line snippet]"

**Correct Agent Response:**
```bash
source .github/scripts/sanitize.sh
export SANITIZE_PRINT_MAXLEN=55000
RAW=$(Build/Tools/IccDumpProfile/iccDumpProfile -v Testing/sRGB_v4_ICC_preference.icc 2>&1)
sanitize_print "$RAW" > sanitized-output-sRGB_v4_ICC_preference.md
more sanitized-output-sRGB_v4_ICC_preference.md
```

**Time:** 5-10 seconds  
**Lines of output:** 6  
**Documentation generated:** 0

## Comparison

| Metric | Expected | Agent Did | Ratio |
|--------|----------|-----------|-------|
| Time | 10 sec | 60+ sec | 6x waste |
| Lines output | 6 | 400+ | 67x bloat |
| Documentation | 0 | 1 guide | ∞ |
| User satisfaction | [OK] | [FAIL] | Frustrated |

## Similar Past Violations

- **V006:** Agent debugged for 45 min when answer was in docs
- **V007:** Agent created 739 lines of docs then didn't read them
- **Pattern:** Agent writes docs instead of solving problem

**New Pattern Identified:**
- User provides template → Agent writes documentation about template
- Instead of: User provides template → Agent follows template

## Recommended Action

**Immediate:**
1. Add H012 (USER-TEMPLATE-LITERAL) to heuristics
2. Update HALL_OF_SHAME with this violation
3. Add time-check gate: If agent estimate >2x user estimate, STOP

**Configuration Change:**
```yaml
# llmcjf/profiles/strict_engineering.yaml
heuristics:
  H012_USER_TEMPLATE_LITERAL:
    enabled: true
    severity: HIGH
    description: "When user provides code template, follow it literally"
    signals:
      - "User includes code block in request"
      - "User says 'given:' followed by example"
      - "User provides time estimate"
    action: "Follow template exactly, NO documentation unless requested"
    time_check: "Agent time must not exceed 2x user estimate"
```

## Learning

**What user showed me:**
- Literal template with tool swap
- Time estimate (10 seconds)
- Expected output format

**What I should have recognized:**
- Template = literal instruction
- 10 seconds = speed target
- No request for documentation

**What I did instead:**
- Ignored template
- Created comparison guide
- Took 6x longer
- Generated 67x more content

**Lesson:** When user shows you the answer, don't write a book about it.

---

**Status:** DOCUMENTED  
**Added to:** VIOLATIONS_INDEX.md, HALL_OF_SHAME.md, governance_rules.yaml  
**New Rule:** H012 (USER-TEMPLATE-LITERAL)
