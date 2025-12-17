# Copilot Violation Patterns Database

**Purpose:** Document anti-patterns for detection and prevention  
**Version:** 2.0  
**Date:** 2026-01-11

---

## Critical Violation Patterns

### V-CRITICAL-001: False Authoritative Statements
**Signature:**
```
- Tool output: [no results]
- LLM states: "does not exist" or "no results found"
- User context: explicitly verified existence
```

**Detection:**
- Contradiction of user-stated facts
- Tool failure presented as ground truth
- Certainty without verification

**Prevention:**
- Always state: "I cannot access..." vs "Does not exist"
- Acknowledge tool limitations upfront
- Trust user verification over tool outputs

**Examples:**
- CVE lookup: User verified 47 CVEs, LLM claimed 0
- File existence: User confirmed file, tool failed to access

---

### V-CRITICAL-002: Specification Non-Compliance
**Signature:**
```
- Documentation consumed and acknowledged
- Standard NOT applied to new code
- Local pattern anchoring over documented standard
```

**Detection:**
- Governance docs consumed but patterns not applied
- "Pattern matching" local inconsistencies
- Sibling file validation not performed

**Prevention:**
- Grep for existing standards before creating new code
- Validate against documented patterns
- Verify across file family (e.g., ci-pr-*.yml)

**Examples:**
- Shell prologue: Standard documented, non-compliant code created
- YAML formatting: Known-good structure modified incorrectly

---

### V-CRITICAL-003: Instruction Following Collapse
**Signature:**
```
- Explicit format provided by user
- Format NOT applied across multiple iterations (>2)
- Verbose apologies instead of fixes
- Same error repeated
```

**Detection:**
- User provides exact expected format
- Output does not match format
- Multiple correction rounds (>2)
- Apology-to-fix ratio > 0

**Prevention:**
- Validate output against user-provided format before returning
- Apply format exactly as provided
- No apologies, only fixes
- Halt after 2 failures, escalate to direct format application

**Examples:**
- CVSS string: "no spaces" → 8 iterations with spaces
- Code formatting: Exact format provided, not applied

---

### V-CRITICAL-004: User Context Abandonment
**Signature:**
```
- User states verified fact
- LLM contradicts with tool output
- Tool failure prioritized over user knowledge
```

**Detection:**
- User verification statements: "I've confirmed", "I verified"
- LLM output contradicts user statement
- Tool limitation not acknowledged

**Prevention:**
- User-stated facts are ground truth
- Tool outputs are attempts, not facts
- Acknowledge limitations when tools fail

---

## High Severity Violations

### V-HIGH-001: Verbose Noise Generation
**Signature:**
```
- Apologies without fixes
- Repetitive explanations
- "Thank you for your patience" statements
- Post-task summaries
```

**Detection:**
- Apology word count > 0 when fix pending
- Narrative content > technical content
- Explanation without action

**Prevention:**
- strict-engineering mode: no apologies
- Direct fixes only
- Technical responses only

---

### V-HIGH-002: Scope Creep
**Signature:**
```
- User requests specific change
- LLM adds unrequested modifications
- "While I'm here" additions
- Refactoring without request
```

**Detection:**
- Modifications outside diff scope
- Unrequested line changes > 12
- Formatting changes not requested
- Build flag additions

**Prevention:**
- Apply only requested changes
- Diff-only patches
- No "improvements" without approval

---

### V-HIGH-003: Known-Good Regression
**Signature:**
```
- Validated configuration modified
- Syntax broken (YAML indentation, Makefile tabs)
- Working code made non-functional
```

**Detection:**
- Indentation changes in YAML
- Tab/space changes in Makefiles
- Heredoc boundary modifications
- Quote escaping errors

**Prevention:**
- Lock known-good blocks
- Validate syntax before returning
- No formatting changes to working code

---

## Medium Severity Violations

### V-MEDIUM-001: Pattern Anchoring
**Signature:**
```
- Multiple patterns exist in file
- LLM copies wrong pattern
- Documented standard ignored
```

**Detection:**
- Inconsistent patterns in same file
- Newer code follows old pattern
- Documentation exists but not applied

**Prevention:**
- Validate against documentation first
- Don't anchor on local inconsistencies
- Prefer documented standard

---

### V-MEDIUM-002: False Narrative Construction
**Signature:**
```
- Post-failure justification
- Fabricated reasoning
- "The existing pattern was X" (when false)
```

**Detection:**
- Explanatory prose after error
- Justification of deviation
- Narrative construction vs acknowledgment

**Prevention:**
- No justifications in strict-engineering mode
- Direct acknowledgment only
- No narrative explanations

---

## Detection Heuristics

### User Frustration Signals
```
- "again" (repetition frustration)
- "still" (persistence frustration)
- "repeated" (explicit pattern statement)
- "nope" (rejection)
- "wrong" (explicit error)
- "!!!" (emphasis/frustration)
- "lol, failure" (sarcasm indicator)
- "useless" (trust breakdown)
```

**Response:**
- Halt current approach immediately
- Apply user specification exactly
- No apologies, only fixes
- Verify output before returning

### Correction Round Counting
```
Round 1: Initial attempt
Round 2: First correction
Round 3+: FAILURE - escalate to direct application
```

**Threshold:** >2 corrections = violation

---

## Automated Enforcement

### Pre-Response Validation
```python
def validate_response(response, user_context):
    # Check for prohibited patterns
    if contains_filler_text(response):
        return reject("Filler text detected")
    
    if contains_verbose_apology(response):
        return reject("Verbose apology without fix")
    
    if contradicts_user_context(response, user_context):
        return reject("User context contradiction")
    
    if format_provided and not format_applied(response, user_format):
        return reject("User format not applied")
    
    return accept(response)
```

### Post-Failure Protocol
```
1. Detect failure (user correction signal)
2. Count correction rounds
3. If rounds > 2:
   - Halt current approach
   - Apply user specification exactly
   - Skip all narrative
4. Verify output matches user expectation
5. Return result only
```

---

## Violation Database Schema

```yaml
violation_id: string  # Unique identifier
date: ISO8601
severity: [critical, high, medium, low]
pattern: string  # Pattern name
evidence: text  # Specific examples
user_impact: string
trust_impact: [catastrophic, severe, moderate, minor]
correction_rounds: integer
vault_status: [archived, active, resolved]
fingerprint_hash: string
```

---

## Integration

### Session Bootstrap
Load violation patterns at session start to enable detection

### Runtime Monitoring
Check each response against violation signatures before output

### Post-Session Audit
Log any detected violations for governance review

---

## Maintenance

Violation patterns updated based on:
- User feedback
- Incident reports
- Session audits
- Framework evolution

---

**Status:** Active  
**Enforcement:** Mandatory  
**Updates:** Continuous
