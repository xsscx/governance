# V008 Quick Reference

**Rule:** H012 (USER-TEMPLATE-LITERAL)

## Signals
- User includes code block in request
- User says "given:" followed by example
- User provides time estimate
- Pattern is obvious (swap X for Y)

## Correct Response
1. Recognize template structure
2. Make minimal change
3. Output result
4. STOP

## DO NOT
- [FAIL] Create comparison guides
- [FAIL] Write documentation
- [FAIL] Expand scope
- [FAIL] Take >2x user's time estimate

## Example
**User:** "provide example for iccDumpProfile given: [5 lines]" (10 sec)  
**Agent:** [5 modified lines] (10 sec) [OK]  
**NOT:** [400-line guide] (60 sec) [FAIL]

---
When user shows you the answer, FOLLOW IT.
