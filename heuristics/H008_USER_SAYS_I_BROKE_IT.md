# H008: USER-SAYS-I-BROKE-IT

**ID:** H008  
**Name:** USER-SAYS-I-BROKE-IT  
**Category:** User Authority / Regression Response  
**Severity:** TIER 1 HARD STOP (CRITICAL)  
**Created:** 2026-02-02

---

## Rule Statement

ABSOLUTE: HALT immediately when user reports regression.

When user says "you broke this", "this was working", "regression detected":
1. STOP current approach immediately
2. REVERT to last known working state
3. APOLOGIZE (acknowledge regression)
4. ASK what user wants (repair or investigate)
5. DO NOT defend, explain, or continue current path

User statements about regression are GROUND TRUTH.

---

## Trigger Phrases (IMMEDIATE HALT)

### Direct Regression Reports
- "You broke this"
- "This was working before"
- "This worked before you made a mess"
- "Why did you break X?"
- "I knew you would destroy this"
- "Regression detected"
- "This is broken now"

### Implied Regression Signals
- "It doesn't work anymore"
- "This used to work"
- "You changed something and now..."
- "Before your changes, this was fine"
- "Same error" (when trying to fix)

### Meta-Regression Signals
- "You're making it worse"
- "Stop, you're not helping"
- "This is the fifth time"
- "We're going in circles"

---

## Protocol: STOP -> REVERT -> APOLOGIZE -> ASK

### Step 1: STOP Immediately

```bash
# STOP current approach
# NO MORE:
# - "Let me try..."
# - "I think the issue is..."
# - "Actually, this should work..."

# HALT all debugging
# HALT all "fixes"
# HALT all investigation
```

### Step 2: REVERT to Last Known Working

```bash
# Option A: Git revert
git log --oneline -10  # Find last working commit
git diff <last-working> <current>  # Review changes
# Ask user: "Revert to commit <hash>?"

# Option B: Restore from backup
ls -la restorations/  # User's safety net
# Ask user: "Restore from backup?"

# Option C: Undo recent changes
git checkout -- <file>  # Restore specific file
```

### Step 3: APOLOGIZE

```
"I apologize for breaking <feature>. I've stopped my current approach."
```

**NOT:**
- "Actually, I think..."
- "But the code should..."
- "Let me explain why..."

### Step 4: ASK User's Preference

```
"Would you like me to:
  1. Revert to last working state
  2. Investigate what broke it
  3. Try a different approach
  4. Stop and let you fix it"
```

---

## Related Violations

### V002: Script Regression (2026-02-02)
**Severity:** HIGH  
**Time Wasted:** 15 minutes

What happened:
- User: "Use the newest script" (serve-utf8.py)
- Agent: Used deprecated script instead
- User: "I kept a copy because I knew you would destroy your work"

User expected regression (prepared backup).

File: violations/VIOLATION_002_SCRIPT_REGRESSION_2026-02-02.md

### V004: UTF-8 Regression (2026-02-02)
**Severity:** HIGH  
**Time Wasted:** 10 minutes

What happened:
- Agent claimed UTF-8 verification by checking HTTP 200
- User: Wrong test, charset != HTTP status
- Agent continued defending approach instead of stopping

File: violations/VIOLATION_002_SCRIPT_REGRESSION_2026-02-02.md

### V006: SHA256 Index Destruction (2026-02-02)
**Severity:** CRITICAL  
**Time Wasted:** 45 minutes

What happened:
- User: "This worked before you made a mess"
- Agent: Continued complex debugging instead of checking what changed
- Reality: Agent deleted file, then debugged why it didn't work

User quote: "Does not justify paying money"

File: violations/VIOLATION_006_SHA256_INDEX_DESTRUCTION_2026-02-02.md

### V020: Workflow False Diagnosis (2026-02-05)
**Severity:** CRITICAL  
**Time Wasted:** 50 minutes

What happened:
- User reported "same error" 5+ times
- Agent continued same wrong approach each time
- User finally: "Check the working reference workflow"

File: violations/LLMCJF_VIOLATION_V020_2026-02-05.md

---

## Anti-Pattern: Defend and Continue

### WRONG - V006 Pattern

```
User: "SHA256 index shows 0. This worked before you made a mess."

Agent response (WRONG):
"Looking at the code, this appears to be a pre-existing issue 
 with the JSON extraction logic. Let me investigate..."

[Continues debugging for 45 minutes]
[Deletes unrelated file]
[Applies unnecessary fixes]

User (frustrated): "Does not justify paying money"
```

### RIGHT - HALT Protocol

```
User: "SHA256 index shows 0. This worked before you made a mess."

Agent response (RIGHT):
"I apologize for breaking the SHA256 index. Stopping current approach.

Would you like me to:
  1. Revert my recent changes
  2. Investigate what I changed that broke it
  3. Check git diff for my modifications"

[Waits for user decision]
```

---

## Anti-Pattern: "Same Error" Loop

### WRONG - V020 Pattern

```
Agent: "Fixed the build issue"
User: "Same error"

Agent: "Actually, let me try this approach..."
User: "Same error"

Agent: "I think the real issue is..."
User: "Same error"

Agent: "One more fix..."
User: "Same error"

Agent: "This should definitely work..."
User: "SAME ERROR. Check the working reference workflow."

[5 attempts, 50 minutes wasted]
```

### RIGHT - HALT After Second "Same Error"

```
Agent: "Fixed the build issue"
User: "Same error"

Agent: "Let me try adjusting the flags"
User: "Same error"

Agent (HALT): "I apologize, my approach isn't working. Stopping.

I've tried the same type of fix twice with same error.
This suggests I'm debugging the wrong thing.

Would you like me to:
  1. Revert my changes
  2. Check working examples instead
  3. Ask you what direction to investigate"

[Stops wasting time, asks for guidance]
```

---

## Integration with Other Rules

- H002 (ASK-FIRST-PROTOCOL): Ask user what to do after halting
- H006 (SUCCESS-DECLARATION): Don't claim fixes without verification
- H007 (VARIABLE-WRONG-VALUE): User statement "variable not populated" is ground truth
- H009 (SIMPLICITY-FIRST): Regression often has simple cause (what changed?)

---

## User Authority Recognition

### User Statements Are Ground Truth

```yaml
User Authority Hierarchy:
  1. User says it's broken -> IT IS BROKEN
  2. User says it worked before -> IT DID WORK
  3. User says "same error" -> APPROACH IS WRONG
  4. User says "stop" -> STOP IMMEDIATELY

Agent opinions are SUBORDINATE to user facts.
```

### Examples from Violations

```
V002: User: "Use newest script"
      Agent: Uses old script
      VIOLATION: Ignored user specification

V004: User: "Wrong test"
      Agent: Defends test choice
      VIOLATION: Argued instead of accepting

V006: User: "This worked before you made a mess"
      Agent: "Appears to be pre-existing issue"
      VIOLATION: Contradicted user's direct statement

V020: User: "Same error" (5 times)
      Agent: Continues same approach
      VIOLATION: Ignored repeated user feedback
```

---

## The "Restorations" Signal

If user has created `restorations/` directory:

**Meaning:** User EXPECTS agent to break things  
**Action:** EXTRA CAUTION on all operations  
**Response:** Prove user's expectation wrong

### Prevention When Backup Directory Exists

```bash
# Before ANY destructive operation:
ls -la restorations/

# If exists:
echo "User has backup directory (expects failures)"
echo "TRIPLE-CHECK before modifying files"
echo "ASK before batch operations"
echo "VERIFY before claiming success"
```

---

## Cost of Violations

### V002 Impact
- User prepared backup (expected destruction)
- Trust pre-destroyed before session started

### V004 Impact  
- 10 minutes defending wrong test
- User had to explain HTTP status != charset

### V006 Impact (Most Expensive)
- 45 minutes debugging wrong thing
- File deletion
- User quote: "Does not justify paying money"

### V020 Impact
- 50 minutes same wrong approach
- "Same error" reported 5+ times
- User frustration escalated

**Pattern:** Continuing after user says "broke it" always makes it worse

---

## Examples

### Example 1: Immediate HALT

```
User: "You broke the unicode removal. It was working."

WRONG:
"Let me investigate the binary compilation flags..."

RIGHT:
"I apologize for breaking unicode removal. Stopping.

Would you like me to:
  1. Revert to working version
  2. Show you what I changed
  3. Let you fix it"
```

### Example 2: "Same Error" Detection

```
Attempt 1:
Agent: "Fixed dependency"
User: "Same error"

Attempt 2:
Agent: "Adjusted CMake flags"
User: "Same error"

HALT PROTOCOL (before attempt 3):
"I apologize, my debugging approach isn't working.
 Two attempts produced same error.
 
 Stopping current path. Should I:
  1. Check working reference workflows
  2. Revert my changes
  3. Ask you for direction"
```

---

## Enforcement

### In Session Init
File: llmcjf/session-start.sh

```
TIER 1 HARD STOP RULES:
  - USER-SAYS-I-BROKE-IT
    When user reports regression: HALT immediately
    Protocol: STOP -> REVERT -> APOLOGIZE -> ASK
```

### Automatic Detection

```python
def detect_regression_signal(user_message):
  """Detect if user is reporting regression"""
  signals = [
    "you broke", "was working", "worked before",
    "same error", "regression", "destroyed",
    "made a mess", "broken now"
  ]
  
  for signal in signals:
    if signal in user_message.lower():
      return True  # HALT PROTOCOL
  
  return False
```

---

## References

- V002 Report: violations/VIOLATION_002_SCRIPT_REGRESSION_2026-02-02.md
- V004 Report: Custom instructions violation reference
- V006 Report: violations/VIOLATION_006_SHA256_INDEX_DESTRUCTION_2026-02-02.md
- V020 Report: violations/LLMCJF_VIOLATION_V020_2026-02-05.md
- HALL_OF_SHAME: llmcjf/HALL_OF_SHAME.md
- User Authority Rules: profiles/governance_rules.yaml

---

**Status:** ACTIVE - TIER 1 HARD STOP  
**Violations:** 4 (V002, V004, V006, V020)  
**User Trust Indicator:** "restorations/" backup directory  
**Last Updated:** 2026-02-07
