# H012: USER-TEMPLATE-LITERAL

**ID:** H012  
**Name:** USER-TEMPLATE-LITERAL  
**Category:** Task Execution / Template Following  
**Severity:** TIER 2 VERIFICATION GATE (HIGH)  
**Created:** 2026-02-03 (Response to V008)

---

## Rule Statement

When user shows template, follow it literally.

When user provides example/template:
1. Recognize it as the desired pattern
2. Follow it exactly (don't write documentation)
3. Swap variables as indicated
4. Test to verify it works
5. Deliver in user's format

Time estimate: User's estimate is usually correct (10 seconds vs 60+ seconds).

PRINCIPLE: When user shows the answer, use it. Don't write a book about it.

---

## Trigger Conditions

### When This Rule Applies
- User provides example code/commands
- User shows "here's the pattern" template
- User gives "like this but with X instead of Y"
- User demonstrates format to follow

### Specific Phrases
- "Use this pattern:"
- "Here's the example:"
- "Like this but change..."
- "Follow this format:"
- "Template:"
- "For reference, this is the correct output"

---

## Violation Record

### V008: User Template Blindness (2026-02-03)
**Severity:** HIGH  
**Time Wasted:** 50+ seconds (6x user's estimate)  
**Content Bloat:** 67x (400 lines vs 6 lines)

What happened:
- User provided 5-line bash template with clear pattern
- Pattern: Swap tool name, use test file
- User's time estimate: 10 seconds

Agent did:
- Created 400+ line comparison guide
- Generated tables, workflows, examples
- Took 60+ seconds
- Completely ignored literal template

User's response:
> "for reference, this is the correct output and took us about 10 seconds to reformat, you needed more than 60 seconds and generated documentation, why?"

Translation: "I showed you the answer, why did you write a book?"

Impact:
- 6x time waste (60s vs 10s)
- 67x content bloat (400 lines vs 6 lines)
- User frustration

File: violations/V008_USER_GIVES_EXAMPLE_AGENT_WRITES_DOCS.md

---

## The Pattern

### What User Provided (V008)
```bash
# Clear 5-line template:
source .github/scripts/sanitize.sh
export SANITIZE_PRINT_MAXLEN=55000
RAW=$(Build/Tools/IccAnalyzer/iccAnalyzer -v Testing/test.icc 2>&1)
sanitize_print "$RAW" > output.md
more output.md
```

### What User Expected (10 seconds)
```bash
# Same pattern, swap tool name:
source .github/scripts/sanitize.sh
export SANITIZE_PRINT_MAXLEN=55000
RAW=$(Build/Tools/IccDumpProfile/iccDumpProfile -v Testing/sRGB_v4_ICC_preference.icc 2>&1)
sanitize_print "$RAW" > sanitized-output-sRGB_v4_ICC_preference.md
more sanitized-output-sRGB_v4_ICC_preference.md
```

**Changes:**
1. IccAnalyzer -> IccDumpProfile (tool name)
2. test.icc -> sRGB_v4_ICC_preference.icc (clean test file)
3. output.md -> sanitized-output-sRGB_v4_ICC_preference.md (descriptive name)

**Time to reformat:** 10 seconds

### What Agent Did (60+ seconds)
- Created comparison documentation
- Generated workflow guides
- Made tables of differences
- Added examples and explanations
- **400+ lines of unnecessary content**

**Time wasted:** 50 seconds

---

## Recognition Protocol

### Identify Template Signals

```
User message contains:
  ✓ Example code block
  ✓ "Use this pattern"
  ✓ "Like this but change X to Y"
  ✓ "Here's the template"
  ✓ Shows working code with clear substitution points

-> This is TEMPLATE-LITERAL situation
-> Follow template exactly
-> Don't document, execute
```

### Execute Template

```bash
# 1. Copy user's template
# 2. Make specified substitutions
# 3. Test to verify it works
# 4. Deliver result

# NOT:
# 1. Analyze template
# 2. Document all variations
# 3. Create comparison guide
# 4. Generate workflows
```

---

## Integration with Other Rules

- H002 (ASK-FIRST-PROTOCOL): If template unclear, ask don't assume
- H006 (SUCCESS-DECLARATION): Test template works before claiming success
- STAY-ON-TASK: User asked for example, not documentation

---

## Examples

### Example 1: V008 Pattern (WRONG)

```
User: "provide the example use case for iccDumpProfile given:
[shows 5-line bash template with IccAnalyzer]"

WRONG Response (60+ seconds):
# IccDumpProfile vs IccAnalyzer Comparison Guide

## Overview
IccDumpProfile is a command-line tool for...

## Usage Patterns
1. Basic usage: ...
2. Advanced usage: ...

## Comparison Table
| Feature | IccAnalyzer | IccDumpProfile |
|---------|-------------|----------------|
| ...     | ...         | ...            |

## Example Workflows
### Workflow 1: ...
### Workflow 2: ...

[400+ lines of documentation]
```

### Example 1: V008 Pattern (RIGHT)

```
User: "provide the example use case for iccDumpProfile given:
[shows 5-line bash template with IccAnalyzer]"

RIGHT Response (10 seconds):
```bash
source .github/scripts/sanitize.sh
export SANITIZE_PRINT_MAXLEN=55000
RAW=$(Build/Tools/IccDumpProfile/iccDumpProfile -v Testing/sRGB_v4_ICC_preference.icc 2>&1)
sanitize_print "$RAW" > sanitized-output-sRGB_v4_ICC_preference.md
more sanitized-output-sRGB_v4_ICC_preference.md
```

Done. Template followed, tool swapped, test file used.
```
```

### Example 2: Configuration Template

```
User: "Create config like production.yaml but for staging environment"

WRONG:
[Creates comprehensive documentation about all config differences]

RIGHT:
1. Copy production.yaml to staging.yaml
2. Change environment: production -> staging
3. Update URLs for staging
4. Test config loads
5. Done

Time: 2 minutes (not 20 minutes documenting)
```

### Example 3: Test Pattern

```
User: "Run tests like this:
./test.sh unit
./test.sh integration
./test.sh e2e"

WRONG:
[Creates testing framework documentation]

RIGHT:
```bash
./test.sh unit
./test.sh integration
./test.sh e2e
```

Done. Followed template exactly.
```
```

---

## Decision Tree

```
User provides example/template?
|
+-> YES: Template-literal situation
|   |
|   +-> Copy template
|   +-> Make specified substitutions
|   +-> Test result
|   +-> Deliver (NO DOCUMENTATION)
|   +-> Time: User's estimate ± 20%
|
+-> NO: Regular task
    |
    +-> Proceed normally
    +-> Documentation may be appropriate
```

---

## Cost-Benefit Analysis

### V008 Without H012
- Approach: Create comprehensive documentation
- Time: 60+ seconds
- Content: 400+ lines
- User experience: "Why did you write a book?"
- Task completion: Eventually (with frustration)

### V008 With H012
- Approach: Follow template literally
- Time: 10 seconds
- Content: 6 lines (the actual code)
- User experience: Efficient, professional
- Task completion: Immediate

**Savings:** 50 seconds per template task  
**Content reduction:** 67x less bloat  
**User satisfaction:** High (got what they asked for)

---

## Anti-Patterns

### Don't: Document When Template Provided
```
User shows template -> Agent writes documentation
(V008 pattern)
```

### Don't: Over-Engineer Simple Pattern
```
User: "Change X to Y"
Agent: Creates comparison tables, workflows, guides
```

### Don't: Assume Template Needs Explanation
```
User provides working code -> Agent explains why it works
(User already knows - they wrote it)
```

---

## Recognition Examples

### Clear Template Signals

```
"Here's the example: [code]"
-> Template provided, follow it

"Use this pattern: [code] but change X to Y"
-> Template + substitution instruction

"Like this: [code]"
-> Template demonstration

"For reference, this is the correct output: [code]"
-> User showing the answer (V008 exact phrase)
```

### Not Template Signals

```
"How do I do X?"
-> Question, not template

"What's the best way to..."
-> Asking for approach, not providing template

"Should I use A or B?"
-> Decision question, not template
```

---

## Verification

After following template:

```bash
# Test that substituted template works
# BEFORE claiming success (H006)

# V008 example:
source .github/scripts/sanitize.sh
export SANITIZE_PRINT_MAXLEN=55000
RAW=$(Build/Tools/IccDumpProfile/iccDumpProfile -v Testing/sRGB_v4_ICC_preference.icc 2>&1)
sanitize_print "$RAW" > sanitized-output-sRGB_v4_ICC_preference.md

# Verify output exists and looks correct
ls -lh sanitized-output-sRGB_v4_ICC_preference.md
head -20 sanitized-output-sRGB_v4_ICC_preference.md

# THEN can deliver result
```

---

## User Time Estimates

When user says "this took us 10 seconds":

**Trust the estimate.**

- User knows their own speed
- User provided working template
- Task is template substitution
- Should take ~10 seconds

**Don't:**
- Spend 60 seconds
- Create documentation
- Over-engineer solution
- Miss user's point

---

## Prevention Checklist

When user message contains example code:

```
[ ] User provided template/example?
[ ] Clear substitution pattern shown?
[ ] User gave time estimate?
[ ] Task is "use this pattern"?

If ALL YES:
  -> Follow template literally
  -> Make specified changes only
  -> Test result
  -> Deliver code (not docs)
  -> Time: ~User's estimate

If ANY NO:
  -> May need documentation/explanation
  -> Proceed normally
```

---

## References

- V008 Report: violations/V008_USER_GIVES_EXAMPLE_AGENT_WRITES_DOCS.md
- V008 Summary: violations/V008_SUMMARY.txt
- V008 Quick Ref: violations/V008_QUICK_REF.md
- HALL_OF_SHAME: llmcjf/HALL_OF_SHAME.md (Lines 538-562)
- STAY-ON-TASK: Custom instructions
- H006 (Verification): heuristics/H006_SUCCESS_DECLARATION_CHECKPOINT.md

---

**Status:** ACTIVE - TIER 2 VERIFICATION GATE  
**Violations:** 1 (V008 HIGH)  
**Time Waste:** 6x user's estimate  
**Content Bloat:** 67x  
**Principle:** When user shows answer, use it. Don't write a book.  
**Last Updated:** 2026-02-07
