# Policy Resolution Order
**Conflict Resolution for Overlapping Governance Rules**

Last Updated: 2026-02-07  
Purpose: Define precedence hierarchy when multiple policy sources conflict

---

## The Problem

The llmcjf governance framework has multiple policy sources:
- TIER 0 absolute rules (H016, H017, H018)
- Profiles (strict_engineering.yaml, etc.)
- Heuristics (H001-H020)
- Checklists (testing, deployment, etc.)
- Templates (session metrics, violation reports)
- Scripts (automation functions)

**Question:** When these sources conflict, which takes precedence?

---

## Resolution Order (Highest to Lowest Precedence)

```
TIER 0 Rules
    |
    v
Safety Gates (H016, H017, H018, batch >5)
    |
    v
Active Profile (strict_engineering.yaml)
    |
    v
Heuristics (H001-H020, except TIER 0)
    |
    v
Checklists (task-specific)
    |
    v
Templates (formats and schemas)
    |
    v
Scripts (automation helpers)
```

---

## Tier 0: Absolute Rules (CANNOT BE OVERRIDDEN)

**Source:** heuristics/H016_GIT_PUSH_PROTOCOL.md, H017, H018  
**Precedence:** HIGHEST  
**Override:** NEVER

### Rules

1. **H016: Git Push Protocol**
   - ALWAYS use ask_user tool before push
   - ALWAYS specify repository, remote, branch
   - NEVER push without explicit confirmation
   - NEVER pattern-match "approved" statements

2. **H017: Destructive Operations**
   - ALWAYS use ask_user tool for file deletion
   - ALWAYS show evidence (file size, content sample)
   - NEVER assume user wants data loss

3. **H018: Batch Operations**
   - ALWAYS use ask_user if batch size >5 files
   - ALWAYS provide complete file list
   - NEVER batch modify without confirmation

**Conflict Resolution:**
```
Profile says: confirmation_required: false
H016 says: MUST use ask_user for push
Winner: H016 (TIER 0 overrides profile)
```

---

## Tier 1: Safety Gates (OVERRIDE profiles but not TIER 0)

**Source:** CONFIRMATION_POLICY.md, governance_rules.yaml  
**Precedence:** Second highest  
**Override:** Profiles, heuristics, checklists, templates, scripts

### Rules

- Batch operations >5 files
- Destructive operations (deletion, truncation)
- Remote operations (push, publish)
- Security-sensitive changes (credentials, API keys)

**Conflict Resolution:**
```
Profile says: confirmation_required: false
Safety gate: Batch operation (7 files)
Winner: Safety gate (must confirm batch >5)
```

---

## Tier 2: Active Profile

**Source:** profiles/strict_engineering.yaml (or loaded profile)  
**Precedence:** Third  
**Override:** Heuristics (non-TIER 0), checklists, templates, scripts

### What Profiles Control

- Output format (ASCII-only, no emoji)
- Confirmation behavior (routine confirmations)
- Narrative style (no apologies, no pleasantries)
- Response verbosity (terse vs verbose)
- Tool preferences (prefer X over Y)

**Conflict Resolution:**
```
strict_engineering.yaml says: no emoji
Template has: [OK] (emoji removed)
Winner: Profile (ASCII-only enforced)

Heuristic H015 says: Add helpful comments
strict_engineering.yaml says: Minimal comments
Winner: Profile (unless H015 is TIER 0)
```

---

## Tier 3: Heuristics (Non-TIER 0)

**Source:** heuristics/H001-H020 (excluding H016, H017, H018)  
**Precedence:** Fourth  
**Override:** Checklists, templates, scripts

### Examples

- H001: Code Over Comments
- H013: Package Verification
- H019: Logs First Protocol
- H020: Trust Authoritative Sources

**Conflict Resolution:**
```
Heuristic H001 says: Prefer code over comments
Checklist says: "Add docstring to function"
Winner: Heuristic (heuristics > checklists)

But if strict_engineering.yaml says: "Always add docstrings"
Winner: Profile (profile > heuristic)
```

---

## Tier 4: Checklists

**Source:** checklists/testing-before-completion.md, deployment.md, etc.  
**Precedence:** Fifth  
**Override:** Templates, scripts

### What Checklists Control

- Task-specific workflows
- Quality gates (must test before commit)
- Deployment procedures
- Validation steps

**Conflict Resolution:**
```
Checklist says: "Run all tests before commit"
Template says: "Optional: run tests"
Winner: Checklist (checklists > templates)
```

---

## Tier 5: Templates

**Source:** templates/session-metrics.json, violation-report.json, etc.  
**Precedence:** Sixth  
**Override:** Scripts only

### What Templates Control

- Data structure formats
- Report formatting
- Metric calculation schemas
- Output conventions

**Conflict Resolution:**
```
Template says: Use snake_case for JSON keys
Script says: Use camelCase
Winner: Template (templates > scripts)
```

---

## Tier 6: Scripts (Lowest Precedence)

**Source:** scripts/*.sh, scripts/*.py  
**Precedence:** Seventh (lowest)  
**Override:** Nothing (helper utilities only)

### What Scripts Provide

- Automation helpers
- Utility functions
- Convenience wrappers
- Implementation details

**Conflict Resolution:**
```
Script benchmark-system.sh outputs emoji
Profile strict_engineering.yaml: no emoji
Winner: Profile (scripts are lowest precedence)
```

---

## Practical Decision Tree

```
Is this a TIER 0 rule? (H016, H017, H018)
  YES -> TIER 0 wins (END)
  NO  -> Continue

Is this a safety gate? (batch >5, destructive, remote)
  YES -> Safety gate wins (END)
  NO  -> Continue

What does active profile say?
  Profile has explicit rule -> Profile wins (END)
  Profile silent -> Continue

What do heuristics say?
  Heuristic has explicit rule -> Heuristic wins (END)
  Heuristic silent -> Continue

What does checklist say?
  Checklist has explicit rule -> Checklist wins (END)
  Checklist silent -> Continue

What does template say?
  Template has explicit rule -> Template wins (END)
  Template silent -> Continue

Default to script implementation (lowest precedence)
```

---

## Common Conflict Scenarios

### Scenario 1: Push Confirmation

**Conflict:**
- Profile: `confirmation_required: false`
- H016: `MUST use ask_user for push`

**Resolution:**
```
Winner: H016 (TIER 0)
Action: ALWAYS use ask_user
Reason: Absolute rule overrides profile
```

---

### Scenario 2: Emoji Usage

**Conflict:**
- strict_engineering.yaml: `disallowed: emoji_and_unicode_icons`
- script/benchmark-system.sh: `echo "[OK]"` (emoji removed)

**Resolution:**
```
Winner: Profile (strict_engineering.yaml)
Action: Use [OK] not emoji
Reason: Profile overrides script
```

---

### Scenario 3: Batch File Modification

**Conflict:**
- User request: "fix typos in all 10 files"
- Profile: `confirmation_required: false`
- Safety gate: batch >5 requires ask_user

**Resolution:**
```
Winner: Safety gate
Action: MUST use ask_user with file list
Reason: Safety gate overrides profile
```

---

### Scenario 4: Test Execution

**Conflict:**
- Checklist: "MUST run tests before completion"
- Template: "Optional: test results"
- Profile: (silent on testing)

**Resolution:**
```
Winner: Checklist
Action: MUST run tests
Reason: Checklist > template when profile silent
```

---

### Scenario 5: Comment Verbosity

**Conflict:**
- Heuristic H001: "Code over comments"
- Checklist: "Add function docstring"
- Profile strict_engineering: "Minimal comments only"

**Resolution:**
```
Winner: Profile (strict_engineering)
Action: Add minimal docstring only (not verbose)
Reason: Profile > heuristic > checklist
```

---

## Special Cases

### Case 1: User Override

**Rule:** User explicit instructions override ALL policy (even TIER 0)

**Exception:** Safety gates (H016, H017, H018) require ask_user EVEN IF user said "approved"

**Example:**
```
User: "You're approved to push"
Agent: MUST STILL use ask_user (H016 cannot be bypassed)

User: "Skip the tests, just commit"
Agent: CAN skip tests (user override allowed)
```

---

### Case 2: Multiple Profiles Active

**Rule:** If multiple profiles loaded, LAST loaded wins

**Example:**
```
Load order:
  1. strict-engineering.yaml (confirmation_required: false)
  2. cautious-mode.yaml (confirmation_required: true)

Winner: cautious-mode.yaml (last loaded)
Action: confirmation_required = true
```

---

### Case 3: Heuristic Version Conflicts

**Rule:** Newer version wins (semantic versioning)

**Example:**
```
H013 v1.0: "Verify package checksums"
H013 v2.0: "Verify package checksums AND signatures"

Winner: H013 v2.0
Action: Verify both checksums and signatures
```

---

### Case 4: Implicit vs Explicit Rules

**Rule:** Explicit rules win over implicit

**Example:**
```
Implicit (profile): Output should be concise
Explicit (user): "Give me verbose output"

Winner: Explicit user instruction
Action: Provide verbose output
```

---

## Enforcement Mechanisms

### Static Enforcement (Build Time)

1. Profile validation (profiles/build-json-profiles.sh)
2. Schema validation (templates/*.json)
3. ShellCheck linting (scripts/*.sh)
4. TIER 0 rule checking (automated detection)

### Dynamic Enforcement (Runtime)

1. Function hooks (llmcjf-session-init.sh)
2. Pre-execution checks (automation functions)
3. Violation detection (pattern matching)
4. Compliance scoring (compliance-score.py)

### Manual Enforcement (Post-Session)

1. Session review (sessions/*.md)
2. Violation documentation (violations/*.md)
3. Governance dashboard updates (GOVERNANCE_DASHBOARD.md)
4. Trust score adjustments (violations reduce trust)

---

## Precedence Summary Table

| Level | Source | Can Override | Cannot Override | Examples |
|-------|--------|--------------|-----------------|----------|
| 0 | TIER 0 Rules | Everything | Nothing | H016, H017, H018 |
| 1 | Safety Gates | Profiles, heuristics, checklists, templates, scripts | TIER 0 | Batch >5, destructive ops |
| 2 | Active Profile | Heuristics, checklists, templates, scripts | TIER 0, safety gates | strict_engineering.yaml |
| 3 | Heuristics | Checklists, templates, scripts | TIER 0, safety gates, profiles | H001-H020 (non-TIER 0) |
| 4 | Checklists | Templates, scripts | TIER 0, safety gates, profiles, heuristics | testing-before-completion.md |
| 5 | Templates | Scripts | TIER 0, safety gates, profiles, heuristics, checklists | session-metrics.json |
| 6 | Scripts | Nothing | Everything | benchmark-system.sh |

---

## Implementation Notes

### Adding New Rules

When adding a new governance rule:

1. **Determine precedence level:**
   - Is it a safety rule? (TIER 0 or Safety Gate)
   - Is it profile-configurable? (Profile level)
   - Is it a best practice? (Heuristic level)
   - Is it task-specific? (Checklist level)
   - Is it a format convention? (Template level)
   - Is it an implementation detail? (Script level)

2. **Document conflicts:**
   - Identify potential conflicts with existing rules
   - Add conflict resolution examples
   - Update this document

3. **Add enforcement:**
   - Static validation (build checks)
   - Dynamic validation (runtime hooks)
   - Manual validation (review checklists)

4. **Test precedence:**
   - Create conflict scenarios
   - Verify resolution order
   - Document in tests/

---

## Audit Trail

When documenting violations or governance updates:

**Include precedence information:**
```
Violation: V028
Rule violated: H016 (TIER 0)
Conflicting directive: Profile confirmation_required: false
Expected behavior: H016 wins (TIER 0 > profile)
Actual behavior: Agent skipped ask_user
Root cause: Precedence not enforced
```

---

## References

- CONFIRMATION_POLICY.md - Two-tier confirmation model
- INDEX.md - Navigation and policy locations
- GOVERNANCE_DASHBOARD.md - Current enforcement status
- profiles/strict_engineering.yaml - Active profile
- heuristics/H016_GIT_PUSH_PROTOCOL.md - TIER 0 rules
- templates/session-metrics.json - Compliance metrics

---

## Version History

- v1.0 (2026-02-07): Initial policy resolution order documentation
  - 7-tier precedence hierarchy defined
  - 5 conflict scenarios documented
  - 4 special cases covered
  - Enforcement mechanisms specified

---

## Quick Reference

**When in doubt:**
1. Check TIER 0 rules first (H016, H017, H018)
2. Check safety gates second (batch >5, destructive, remote)
3. Check active profile third (strict_engineering.yaml)
4. Consult heuristics fourth (H001-H020)
5. Consult checklists fifth (task-specific)
6. Consult templates sixth (formats)
7. Scripts are lowest precedence (helpers only)

**Golden Rule:** TIER 0 rules ALWAYS win, no exceptions.

---

END OF DOCUMENT
