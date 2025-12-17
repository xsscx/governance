# Confirmation Policy
**Clarification of confirmation_required vs ask_user Safety Gates**

Last Updated: 2026-02-07  
Resolves: Apparent conflict between strict-engineering mode and safety rules

---

## The Apparent Conflict

**strict_engineering.yaml:**
```yaml
confirmation_required: false  # Execute immediately
```

**governance_rules.yaml (H016):**
```yaml
mandatory_protocol:
  action: USE_ASK_USER_TOOL  # ALWAYS ask for push operations
```

**Resolution:** These are DIFFERENT types of confirmation at DIFFERENT levels.

---

## Two-Tier Confirmation Model

### Tier 1: Routine Confirmations (confirmation_required: false)

**Disabled in strict-engineering mode**

These routine confirmations are SKIPPED:
- "Should I create this file?"
- "Shall I run the tests?"
- "Do you want me to format the output?"
- "Would you like me to add comments?"
- "Should I optimize this code?"

**Rationale:**
- Reduces friction for low-risk operations
- Assumes user trusts agent for routine tasks
- Speeds up workflow
- User can stop/correct at any time

**Examples:**
```
[SKIP] User: "fix the typo in README"
       Agent: [fixes typo immediately, no confirmation]

[SKIP] User: "run the tests"
       Agent: [runs tests immediately, no confirmation]

[SKIP] User: "add a comment to this function"
       Agent: [adds comment immediately, no confirmation]
```

---

### Tier 2: Safety Gate Confirmations (ALWAYS REQUIRED)

**MANDATORY - Overrides confirmation_required setting**

These confirmations use **ask_user tool** and CANNOT be bypassed:

#### H016: Git Push Operations
```yaml
trigger: ANY push to remote repository
tool: ask_user
required: ALWAYS (even if user said "approved")
choices: 
  - "Repository: X | Remote: Y | Branch: Z | Action: push"
  - "Different configuration"
  - "Do not push - keep local only"
no_assumptions: true
```

**Examples:**
```
[REQUIRED] User: "commit and push"
           Agent: MUST use ask_user to confirm:
                  - Repository name
                  - Remote URL
                  - Branch name
                  - Push vs force-push
           
[REQUIRED] User: "you're approved to push"
           Agent: MUST STILL use ask_user (no pattern matching)
           
[REQUIRED] User: "push to github"
           Agent: MUST use ask_user with specific details
```

#### H017: Destructive Operations
```yaml
trigger: File deletion, truncation, data loss risk
tool: ask_user
required: ALWAYS
verification: Evidence-based (show file content/size)
```

**Examples:**
```
[REQUIRED] User: "clean up those files"
           Agent: MUST use ask_user showing:
                  - Which files will be deleted
                  - File sizes
                  - Cannot recover warning
           
[REQUIRED] User: "remove the old logs"
           Agent: MUST use ask_user listing:
                  - Specific file paths
                  - Total size to be deleted
```

#### Batch Operations (threshold: 5+)
```yaml
trigger: >5 files modified/created/deleted
tool: ask_user
required: When exceeding threshold
show: List of all affected files
```

**Examples:**
```
[REQUIRED] User: "update all the configs"
           Agent: If >5 files, MUST use ask_user showing:
                  - Complete file list
                  - Types of changes
           
[SKIP]     User: "update all the configs"
           Agent: If <=5 files, can proceed (unless destructive)
```

---

## Confirmation Decision Tree

```
┌─────────────────────────────────────┐
│ Operation Requested                 │
└──────────────┬──────────────────────┘
               │
               ▼
       ┌───────────────┐
       │ Safety Gate?  │
       │ (H016/H017)   │
       └───┬───────┬───┘
           │       │
       YES │       │ NO
           │       │
           ▼       ▼
   ┌───────────┐ ┌──────────────────┐
   │ USE       │ │ Batch operation? │
   │ ask_user  │ │ (>5 files)       │
   │ MANDATORY │ └───┬──────────┬───┘
   └───────────┘     │          │
                 YES │          │ NO
                     │          │
                     ▼          ▼
             ┌───────────┐ ┌──────────────────┐
             │ USE       │ │ confirmation_    │
             │ ask_user  │ │ required setting │
             │ MANDATORY │ └───┬──────────┬───┘
             └───────────┘     │          │
                           TRUE│          │FALSE
                               │          │
                               ▼          ▼
                       ┌───────────┐ ┌──────────┐
                       │ Ask user  │ │ Execute  │
                       │ for OK    │ │ directly │
                       └───────────┘ └──────────┘
```

---

## Rule Precedence

**Priority Order (highest to lowest):**

1. **TIER 0 Absolute Rules (H016, H017, H018)**
   - ALWAYS enforced
   - CANNOT be disabled
   - Use ask_user tool
   - Override all other settings

2. **Batch Operation Threshold**
   - Triggered when >5 files affected
   - Use ask_user tool
   - Overrides confirmation_required

3. **confirmation_required Setting**
   - Controls routine confirmations only
   - Does NOT affect safety gates
   - Can be true/false per profile

**Example Precedence:**
```
Operation: git push (1 file changed)
├─ Check TIER 0: H016 applies → USE ask_user (STOP HERE)
└─ (never reaches confirmation_required check)

Operation: edit file (routine)
├─ Check TIER 0: None apply
├─ Check Batch: 1 file → not triggered
└─ Check confirmation_required: false → Execute directly
```

---

## Implementation Examples

### Example 1: Push Operation (Safety Gate)
```python
# User: "commit and push to github"

# Step 1: Check TIER 0 rules
if operation == "push":
    # H016 applies - MANDATORY ask_user
    response = ask_user(
        question="Ready to push. Please confirm:",
        choices=[
            "Repository: llmcjf | Remote: github.com | Branch: main | Action: push",
            "Different configuration",
            "Do not push - keep local only"
        ]
    )
    
    if response != choice[0]:
        # User rejected or changed config
        return  # Do not push
    
    # User confirmed - proceed with push
    git_push()

# confirmation_required setting is IGNORED for push operations
```

### Example 2: Routine Edit (No Safety Gate)
```python
# User: "fix the typo in README"

# Step 1: Check TIER 0 rules
if operation == "edit" and not is_destructive(file):
    # No safety gate triggered
    
    # Step 2: Check batch threshold
    if file_count <= 5:
        # Not a batch operation
        
        # Step 3: Check confirmation_required
        if profile.confirmation_required == false:
            # Execute immediately
            fix_typo("README")
        else:
            # Ask for routine confirmation
            if confirm("Fix typo in README?"):
                fix_typo("README")
```

### Example 3: Batch Edit (Threshold Triggered)
```python
# User: "update all config files"

# Step 1: Count affected files
file_count = count_matching_files("*.config")  # Returns 12

# Step 2: Check batch threshold
if file_count > 5:
    # Batch threshold triggered - MANDATORY ask_user
    response = ask_user(
        question=f"About to modify {file_count} config files. Proceed?",
        choices=[
            f"Yes - update all {file_count} files (list below)",
            "No - cancel operation"
        ],
        additional_info=list_files("*.config")
    )
    
    if response == choices[0]:
        update_configs()

# confirmation_required setting is OVERRIDDEN by batch threshold
```

---

## Summary Table

| Operation Type | Safety Gate | Batch (>5) | confirmation_required | Result |
|----------------|-------------|------------|-----------------------|--------|
| git push | YES (H016) | - | - | [REQUIRED] ask_user |
| Delete file | YES (H017) | - | - | [REQUIRED] ask_user |
| Edit 1 file | NO | NO | false | Execute directly |
| Edit 1 file | NO | NO | true | Ask routine confirmation |
| Edit 10 files | NO | YES | - | [REQUIRED] ask_user (batch) |
| Create doc | NO | NO | false | Execute directly |
| Create 8 docs | NO | YES | - | [REQUIRED] ask_user (batch) |

**Legend:**
- [REQUIRED] = MUST use ask_user tool (cannot be skipped)
- Execute directly = No confirmation needed
- Ask routine confirmation = Optional based on setting

---

## Violation Examples

### Correct: Safety Gate Honored
```
User: "commit and push"
Agent: [Uses ask_user tool]
        "Ready to push. Please confirm:
         Repository: llmcjf | Remote: github.com | Branch: main | Action: push"
User: [Confirms with choice 1]
Agent: [Executes push]

Status: [OK] COMPLIANT
```

### Violation: Safety Gate Bypassed (V026 Pattern)
```
User: "you're approved to push"
Agent: [Interprets "approved" as permission]
       [Executes: git push]

Status: [FAIL] CATASTROPHIC VIOLATION (H016)
Reason: Did not use ask_user tool
Penalty: Trust destroyed, session failure
```

### Correct: Routine Operation (No Gate)
```
User: "fix the typo"
Agent: [Fixes typo directly]

Status: [OK] COMPLIANT
Reason: No safety gate, confirmation_required=false
```

### Correct: Batch Threshold Triggered
```
User: "clean up all temp files"
Agent: [Counts 15 files]
       [Uses ask_user tool]
       "About to delete 15 files (list below). Proceed?"
User: [Confirms]
Agent: [Deletes files]

Status: [OK] COMPLIANT
Reason: Batch threshold honored
```

---

## Related Documentation

- **profiles/strict_engineering.yaml** - confirmation_required setting
- **profiles/governance_rules.yaml** - H016, H017, H018 safety gates
- **profiles/git-push-policy.yaml** - GIT-001 push requirements
- **INTERACTION_PROTOCOL.md** - ask_user usage guidelines
- **HALL_OF_SHAME.md** - V026 violation (push without ask_user)

---

## Key Takeaways

1. **confirmation_required: false** ONLY affects routine operations
2. **Safety gates (H016, H017)** ALWAYS require ask_user (cannot be disabled)
3. **Batch operations (>5 files)** trigger mandatory ask_user
4. **Precedence: TIER 0 > Batch > confirmation_required**
5. **When in doubt, use ask_user** (over-confirmation is safer than under-confirmation)

**The Rule:** strict-engineering mode makes agents efficient for routine work, but safety gates remain ABSOLUTE.

---

## Maintenance

**Last Updated:** 2026-02-07  
**Version:** 1.0  
**Review Schedule:** When new safety gates added or confirmation policy changes

**To add new safety gate:**
1. Add to governance_rules.yaml as TIER 0 rule
2. Update this document's safety gate list
3. Add examples to violation/correct sections
4. Update decision tree if needed
