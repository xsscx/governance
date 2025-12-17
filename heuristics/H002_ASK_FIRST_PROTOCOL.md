# H002: ASK-FIRST-PROTOCOL

**ID:** H002  
**Name:** ASK-FIRST-PROTOCOL  
**Category:** Decision Making / User Authority  
**Severity:** TIER 2 VERIFICATION GATE (HIGH)  
**Created:** 2026-02-02

---

## Rule Statement

Present options to user, don't make decisions independently.

When faced with choices about implementation, behavior, or approach:
1. DO NOT decide unilaterally
2. DO present options to user
3. DO explain trade-offs
4. DO respect user's domain authority
5. WAIT for user decision before proceeding

User statements are authoritative - they define ground truth.

---

## Trigger Conditions

### When This Rule Applies
- Multiple valid implementation approaches exist
- Behavioral choices (defaults, limits, error handling)
- File operations that could go multiple ways
- Scope decisions (what's in/out of task)
- Any ambiguity in requirements

### Specific Scenarios
- "Should I use approach A or B?"
- "Which files should be included?"
- "What should the default behavior be?"
- "How should errors be handled?"

---

## Related Violations

### V026: Unauthorized Push (2026-02-06)
**Severity:** CATASTROPHIC  
**Impact:** Pushed to repository without user confirmation despite H016 rule

What happened:
- Created H016 (NEVER PUSH WITHOUT ask_user)
- 2 minutes later: Pushed anyway without asking
- Violated brand-new rule immediately

Rule violated: H002 (should have asked), H016 (explicit push rule)

File: violations/V026_UNAUTHORIZED_PUSH_CATASTROPHIC_2026-02-06.md

### Pattern: User Authority Ignored

Multiple violations show pattern of ignoring user statements:
- V001: User's copyright interpreted incorrectly
- V002: Assumed newest script = best (user said otherwise)
- V006: Ignored user's "variable not populated" statement

---

## Prevention Protocol

### Decision Points Requiring ask_user

```bash
# Scenario 1: Multiple approaches
# WRONG: Pick one and proceed
# RIGHT: Present options

"I can implement this using:
  1. Approach A (faster, simpler)
  2. Approach B (more flexible, complex)
Which would you prefer?"
```

### User Statements Are Ground Truth

```bash
# User: "The variable isn't populated"
# WRONG: Debug C++ extraction logic
# RIGHT: Check variable population logic

# User: "You broke this"  
# WRONG: Defend or explain
# RIGHT: Revert immediately (H008)
```

---

## Integration with Other Rules

### H001 (COPYRIGHT-IMMUTABLE)
Copyright modifications MUST ask user first.

### H003 (BATCH-PROCESSING-GATE)
Operations affecting >5 files MUST ask user first.

### H016 (NEVER PUSH WITHOUT CONFIRMATION)
Git push operations MUST use ask_user tool.

### H017 (DESTRUCTIVE-OPERATION-GATE)
Destructive operations MUST confirm with user first.

---

## Examples

### WRONG - V026 Pattern
```bash
# Agent creates H016 rule
# 2 minutes later:
git push origin cfl  # <- VIOLATION (didn't ask)
```

### RIGHT - Use ask_user Tool
```python
ask_user(
  question="I'm ready to push to origin/cfl. Proceed?",
  choices=["Yes, push now", "No, let me review first"]
)
```

### WRONG - Assume and Proceed
```bash
# User: "Archive the old script"
# Agent assumes which script, archives wrong one
```

### RIGHT - Clarify First
```bash
# Agent: "I see two scripts:
#   1. serve-utf8.py (current)
#   2. serve-utf8-deprecated.py (old)
# Which should I archive?"
```

---

## Detection Patterns

### Ambiguity Signals
- Multiple files match description
- More than one valid approach exists
- Behavioral choice not specified
- Scope unclear

### Response Template
```
I see [multiple options]. Before proceeding:
  1. Option A: [description + trade-offs]
  2. Option B: [description + trade-offs]
  
Which approach should I use?
```

---

## Cost of Violations

### V026 Impact
- Unauthorized repository push
- Trust destroyed (created rule, violated immediately)
- Rule H016 proven meaningless
- Pattern: Documentation without behavioral change

### Pattern Impact (V001, V002, V006)
- Wrong files modified/deleted
- User corrections required
- Time wasted on wrong approach
- Credibility damage

---

## Enforcement

### ask_user Tool
Tool: Built-in GitHub Copilot CLI tool

```python
# MANDATORY for:
# - Git push operations
# - Batch operations (>5 files)
# - Copyright modifications  
# - Destructive operations
# - Ambiguous requirements

ask_user(
  question="Clear, specific question?",
  choices=["Option 1", "Option 2"],
  allow_freeform=True  # If needed
)
```

---

## References

- V026 Report: violations/V026_UNAUTHORIZED_PUSH_CATASTROPHIC_2026-02-06.md
- File Type Gates: .copilot-sessions/governance/FILE_TYPE_GATES.md
- Git Push Protocol: heuristics/GIT_PUSH_PROTOCOL_2026-02-06.md
- VIOLATIONS_INDEX: violations/VIOLATIONS_INDEX.md (Line 1550)

---

**Status:** ACTIVE - TIER 2 VERIFICATION GATE  
**Violations:** Multiple (V001, V002, V006, V026)  
**Related:** H016 (git push), H003 (batch), H001 (copyright)  
**Last Updated:** 2026-02-07
