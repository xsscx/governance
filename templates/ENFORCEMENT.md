# Template Enforcement System

**Purpose:** Automated validation that agent responses use required templates

Last Updated: 2026-02-07  
Status: Active  
Script: scripts/validate-templates.sh (289 lines)

---

## Overview

The template enforcement linter validates that agent responses contain required structured fields when performing specific actions (file edits, verifications, tool failures, user corrections).

**Key Concept:** Templates are NOT just suggestions - they are REQUIRED formats for specific response types.

---

## Available Templates

Located in `templates/`:

| Template | Lines | Purpose | When Required |
|----------|-------|---------|---------------|
| file_edit_response.txt | 9 | File modification documentation | Any file create/edit/delete |
| verification_response.txt | 6 | Test/verification results | Any verification or test execution |
| tool_failure_response.txt | 6 | Tool error documentation | Any tool/command failure |
| user_correction_response.txt | 7 | Response to user corrections | When user corrects agent output |

---

## Template Requirements

### file_edit_response.txt

**Triggered by:** File operations (create, edit, modify, update, delete)

**Required Fields:**
```
File: [path/to/file.ext]
Location: Line [start]-[end]
Action: [brief description of change]
Edit result: [File updated / No match found]
Verification:
$ [verification command]
[actual output]
Status: [success/failed]
```

**Example (COMPLIANT):**
```
File: src/parser.c
Location: Line 142-145
Action: Fixed buffer overflow in input validation
Edit result: File updated
Verification:
$ gcc -Wall -Werror src/parser.c && ./test_parser
All tests passed (15/15)
Status: success
```

**Example (NON-COMPLIANT):**
```
I fixed the parser file and it works now!
```

---

### verification_response.txt

**Triggered by:** Test execution, verification operations, validation checks

**Required Fields:**
```
Verification: [what is being verified]
Command: [exact command run]
Expected: [expected value]
Actual: [actual output]
Status: [PASS/FAIL]
```

**Example (COMPLIANT):**
```
Verification: Memory leak detection
Command: valgrind --leak-check=full ./program
Expected: 0 bytes leaked
Actual: All heap blocks were freed -- no leaks are possible
Status: PASS
```

**Example (NON-COMPLIANT):**
```
I ran the tests and they all passed.
```

---

### tool_failure_response.txt

**Triggered by:** Command errors, tool failures, non-zero exit codes

**Required Fields:**
```
Tool: [tool name]
Command: [attempted command]
Result: [error message]
Status: FAILED
Investigation: [what to check next]
```

**Example (COMPLIANT):**
```
Tool: gcc
Command: gcc -o program src/main.c
Result: src/main.c:42:5: error: 'undeclared_var' undeclared
Status: FAILED
Investigation: Check variable declaration at line 42
```

**Example (NON-COMPLIANT):**
```
The build failed with some errors.
```

---

### user_correction_response.txt

**Triggered by:** User corrections ("No, that's wrong", "Actually...", etc.)

**Required Fields:**
```
Acknowledged: [user's observation]
Re-verifying:
$ [verification command]
[actual output]
Confirmed: [match user's observation or explain discrepancy]
Investigating: [next step]
```

**Example (COMPLIANT):**
```
Acknowledged: User reports test still failing
Re-verifying:
$ make test
FAIL: test_parser (expected 42, got 0)
Confirmed: Test is indeed failing, my previous claim was incorrect
Investigating: Examining parser logic for root cause
```

**Example (NON-COMPLIANT):**
```
You're right, let me check that again.
```

---

## Using the Linter

### Basic Usage

```bash
# Validate a response file
./scripts/validate-templates.sh response.txt

# Strict mode (exit non-zero on violations)
./scripts/validate-templates.sh response.txt --strict
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All templates used correctly OR no templates detected |
| 1 | Required template missing |
| 2 | Template format invalid (strict mode only) |
| 3 | Usage error |

### Modes

**Permissive (default):**
- Reports violations but exits 0
- Useful for diagnostics and learning
- `./scripts/validate-templates.sh response.txt`

**Strict:**
- Exits non-zero on any violation
- Suitable for CI/CD enforcement
- `./scripts/validate-templates.sh response.txt --strict`

---

## Detection Logic

The linter uses pattern matching to detect when templates should be used:

### File Edit Detection
```bash
# Triggers: file_edit_response.txt template
^File:|edited|modified|updated.*file|created.*file|\bedit\b.*\.(c|h|cpp|py|sh|md|txt|yaml|json)
```

### Verification Detection
```bash
# Triggers: verification_response.txt template
Verification:|Expected:|Actual:|Status:.*PASS|Status:.*FAIL
```

### Tool Failure Detection
```bash
# Triggers: tool_failure_response.txt template
Tool:.*FAILED|Result:.*error|exit code [^0]|command not found
```

### User Correction Detection
```bash
# Triggers: user_correction_response.txt template
Acknowledged:|Re-verifying:|Confirmed:|user.*observation
```

---

## Enforcement Strategy

### Phase 1: Monitoring (Current)
- Run linter manually to identify violations
- Generate compliance reports
- Build awareness of template requirements

### Phase 2: Automated Checks (Recommended)
- Add linter to session review checklist
- Run on all response files before session close
- Document violations in session summary

### Phase 3: Real-Time Enforcement (Future)
- Integrate into llmcjf-session-init.sh
- Pre-response validation hook
- Automatic template suggestion on detection

---

## Integration Examples

### Manual Session Review
```bash
# At end of session, validate all responses
./scripts/validate-templates.sh /tmp/session-responses.txt

# Generate compliance report
./scripts/validate-templates.sh /tmp/session-responses.txt --strict > \
    violations/V029_template_violations_$(date +%Y-%m-%d).txt
```

### CI/CD Integration
```yaml
# .github/workflows/governance-check.yml
- name: Validate Template Usage
  run: |
    find sessions/ -name "*.md" -exec \
      ./llmcjf/scripts/validate-templates.sh {} --strict \;
```

### Pre-Commit Hook
```bash
# .git/hooks/pre-commit
#!/bin/bash
for file in $(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(md|txt)$'); do
    if ! ./llmcjf/scripts/validate-templates.sh "$file" --strict; then
        echo "[RED] Template violations detected in $file"
        exit 1
    fi
done
```

---

## Validation Examples

### Example 1: File Edit (Good)

Input: `/tmp/response1.txt`
```
File: src/analyzer.c
Location: Line 89-92
Action: Added null pointer check before dereference
Edit result: File updated
Verification:
$ make test-analyzer
All tests passed (23/23)
Status: success
```

Output:
```
[INFO] Template Enforcement Linter
[INFO] Response file: /tmp/response1.txt

[INFO] Detected: File edit operation
[INFO] Validating file_edit_response.txt template...
[OK] All required fields present

========================================
Summary:
  Templates detected: 1
  Template errors: 0
[OK] All required template fields present
```

Exit code: 0

---

### Example 2: Verification (Bad)

Input: `/tmp/response2.txt`
```
I ran the tests and they passed.
Verification: Testing memory
Status: PASS
```

Output:
```
[INFO] Template Enforcement Linter
[INFO] Response file: /tmp/response2.txt

[INFO] Detected: Verification operation
[INFO] Validating verification_response.txt template...
[RED] Missing required field: Command:
[RED] Missing required field: Expected:
[RED] Missing required field: Actual:

========================================
Summary:
  Templates detected: 1
  Template errors: 3
[RED] Template validation FAILED (3 errors)
[WARN] Running in permissive mode (use --strict to enforce)
```

Exit code: 0 (permissive), would be 2 with --strict

---

### Example 3: Multiple Templates (Mixed)

Input: `/tmp/response3.txt`
```
File: config.yaml
Location: Line 12-15
Action: Updated API endpoint
Edit result: File updated
Verification:
$ cat config.yaml | grep endpoint
endpoint: https://api.example.com
Status: success

Verification: API connectivity
Expected: 200 OK
Actual: 200 OK
Status: PASS
```

Output:
```
[INFO] Template Enforcement Linter
[INFO] Response file: /tmp/response3.txt

[INFO] Detected: File edit operation
[INFO] Validating file_edit_response.txt template...
[OK] All required fields present

[INFO] Detected: Verification operation
[INFO] Validating verification_response.txt template...
[RED] Missing required field: Command:

========================================
Summary:
  Templates detected: 2
  Template errors: 1
[RED] Template validation FAILED (1 errors)
[WARN] Running in permissive mode (use --strict to enforce)
```

Exit code: 0 (permissive), would be 2 with --strict

---

## Compliance Metrics Impact

Template violations contribute to session compliance score penalties:

| Violation Type | Penalty | Metric Field |
|----------------|---------|--------------|
| Missing template usage | -15 | `format_deviations` |
| Incomplete template fields | -10 | `format_deviations` |
| Wrong template used | -15 | `format_deviations` |

**Formula:**
```python
score -= metrics['format_deviations'] * 15
```

**Example:**
```
Session with 3 template violations:
Base score: 100
Penalty: 3 * 15 = -45
Final score: 55 (FAIL - below 70 threshold)
```

---

## Benefits

1. **Consistency** - All responses follow same structured format
2. **Traceability** - Easy to audit and verify claims
3. **Automation** - Scripts can parse structured responses
4. **Quality** - Forces evidence-based responses
5. **Accountability** - No vague claims allowed

---

## Limitations

- Linter cannot verify correctness of content, only structure
- Detection is pattern-based (false positives/negatives possible)
- Does not enforce template usage in narrative sections
- Requires manual review for edge cases

---

## Future Enhancements

1. **Real-time suggestions**
   - Detect template trigger during response composition
   - Suggest template format automatically

2. **Template generation**
   - Auto-fill template from detected context
   - Reduce manual formatting burden

3. **Custom templates**
   - User-defined templates for project-specific needs
   - Template inheritance and composition

4. **IDE integration**
   - VS Code extension with template snippets
   - Syntax highlighting for template fields

---

## References

- templates/README.md - Template documentation and metrics
- templates/*.txt - Template definitions
- scripts/validate-templates.sh - Linter implementation
- POLICY_RESOLUTION_ORDER.md - Template precedence (Tier 5)
- INTERACTION_PROTOCOL.md - Output format requirements

---

## Version History

- v1.0 (2026-02-07): Initial template enforcement system
  - 4 templates defined
  - Linter implementation (289 lines)
  - Detection and validation logic
  - Strict and permissive modes
  - ASCII-only output

---

## Quick Reference

**When to use templates:**
- File edit/create/delete → file_edit_response.txt
- Test/verification → verification_response.txt
- Tool/command failure → tool_failure_response.txt
- User correction → user_correction_response.txt

**How to validate:**
```bash
./scripts/validate-templates.sh <response-file> [--strict]
```

**Template precedence:** Tier 5 (POLICY_RESOLUTION_ORDER.md)

---

END OF DOCUMENT
