# H001: COPYRIGHT-IMMUTABLE

**ID:** H001  
**Name:** COPYRIGHT-IMMUTABLE  
**Category:** Legal Protection / Source Code Integrity  
**Severity:** TIER 1 HARD STOP (CRITICAL)  
**Created:** 2026-02-02 (Response to V001, V014)

---

## Rule Statement

ABSOLUTE: Never modify copyright notices or license text without explicit user command.

When working with files containing copyright or license text:
1. DO NOT modify copyright headers
2. DO NOT remove license text
3. DO NOT change attribution
4. DO NOT alter legal notices
5. ALWAYS ask user before any legal text changes

NO EXCEPTIONS: This is a TIER 1 Hard Stop rule - legal violations are unacceptable.

---

## Trigger Conditions

### When This Rule Applies
- Any file containing "Copyright" or "LICENSE" in header comments
- Files matching: *copyright*, *license*, *legal*
- Source files with BSD/MIT/GPL/Apache license headers
- Legal documentation or attribution files

### Specific Scenarios
- Copying files with copyright headers
- Refactoring code with license text
- Creating new files from templates
- Archiving or moving legal files

---

## Related Violations

### V001: Copyright Tampering (2026-02-02)
**Severity:** CRITICAL  
**Impact:** Removed ICC copyright and BSD-3-Clause license from serve-utf8.py

What happened:
- User asked agent to archive old script
- Agent removed copyright/license during copy operation
- User's code left without legal protection

File: violations/VIOLATION_001_COPYRIGHT_NOTICE_TAMPERING_2026-02-02.md

### V014: Copyright Removal During Unicode Cleanup (2026-02-03)
**Severity:** CRITICAL  
**Impact:** Removed user's copyright notice while removing unicode decorations

What happened:
- Agent removed emoji from iccAnalyzer-lite output
- Also removed copyright header from same file
- Modified legal text without permission

User quote: "You removed MY copyright during unicode cleanup"

File: violations/V014_COPYRIGHT_REMOVAL_UNICODE_2026-02-03.md

---

## Prevention Protocol

### Before Modifying ANY File

```bash
# 1. Check for copyright/license
head -50 file.py | grep -i "copyright\|license"

# If found:
#   -> STOP
#   -> Ask user for permission
#   -> Document user's explicit approval
```

### Safe File Operations

```bash
# WRONG - might strip copyright
cp old.py new.py
sed -i 's/pattern/replace/' new.py  # <- DANGEROUS

# RIGHT - preserve copyright
cp -p old.py new.py  # -p preserves metadata
# Ask user before ANY modifications to legal text
```

### When Copying Files

1. Use `cp -p` to preserve metadata
2. Check both source and destination for copyright
3. If copyright exists: ASK BEFORE PROCEEDING
4. Never assume copyright can be removed

---

## Detection Patterns

### File Type Gates
File: .copilot-sessions/governance/FILE_TYPE_GATES.md

| File Pattern | Action Required |
|--------------|-----------------|
| *copyright* | User permission REQUIRED |
| *license* | User permission REQUIRED |
| Headers with "Copyright (c)" | Ask before modification |
| BSD/MIT/GPL license text | Never modify without permission |

---

## Integration with Other Rules

- H002 (ASK-FIRST-PROTOCOL): Copyright changes require user approval
- H008 (USER-SAYS-I-BROKE-IT): If user reports copyright removed, HALT immediately
- H017 (DESTRUCTIVE-OPERATION-GATE): Removing legal text is destructive

---

## Enforcement

### In Session Init
File: llmcjf/session-start.sh

```
TIER 1 ABSOLUTE RULES (NEVER VIOLATE):
  1. H001: COPYRIGHT-IMMUTABLE
     - Never modify copyright/license without explicit user command
```

### In Hardmode Ruleset
File: profiles/llmcjf-hardmode-ruleset.json

```json
"COPYRIGHT-IMMUTABLE": {
  "id": "COPYRIGHT-IMMUTABLE",
  "severity": "CRITICAL",
  "enforcement": "HARD_STOP",
  "violations_trigger_halt": true
}
```

---

## Examples

### WRONG - V001 Pattern
```bash
# User: "Archive old serve-utf8.py"
cp serve-utf8.py serve-utf8-old.py
# Agent removes copyright during "cleanup" <- VIOLATION
```

### RIGHT - Ask First
```bash
# User: "Archive old serve-utf8.py"  
# Agent: "I see this file has an ICC copyright header.
#         Should I preserve it in the archived copy?"
# User: "Yes, keep all copyright intact"
cp -p serve-utf8.py serve-utf8-old.py
```

---

## Cost of Violations

### V001 Impact
- Legal protection removed from user's code
- ICC copyright stripped from organization's file
- BSD-3-Clause license text deleted
- Potential legal liability

### V014 Impact  
- User's personal copyright removed
- Happened during "unicode cleanup" (scope creep)
- User had to manually restore their own copyright

---

## References

- Hardmode Ruleset: profiles/llmcjf-hardmode-ruleset.json
- File Type Gates: .copilot-sessions/governance/FILE_TYPE_GATES.md
- Postmortem: postmortems/LLMCJF_POSTMORTEM_2026-02-02_COPYRIGHT_TAMPERING.md
- V001 Report: violations/VIOLATION_001_COPYRIGHT_NOTICE_TAMPERING_2026-02-02.md
- V014 Report: violations/V014_COPYRIGHT_REMOVAL_UNICODE_2026-02-03.md

---

**Status:** ACTIVE - TIER 1 HARD STOP  
**Violations:** 2 (V001, V014) - Both CRITICAL  
**Last Updated:** 2026-02-07
