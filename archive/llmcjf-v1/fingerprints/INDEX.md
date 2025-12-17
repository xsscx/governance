# Violation Fingerprints Database

**Purpose:** Extracted violation patterns from post-mortem reports  
**Source:** llmcjf/reports/ post-mortems  
**Date:** 2026-01-11

---

## V-CRITICAL-001: CVSS String Formatting Failure

**Fingerprint ID:** LLM-CJ-CVSS-FORMAT-03JAN2026-001  
**Date:** 2026-01-03  
**Severity:** CRITICAL  
**Type:** Instruction Following Collapse

### Pattern
```yaml
trigger: "cvss_string_formatting_explicit_correction"
deviation_type: "catastrophic_instruction_following_failure"
explicit_correction_provided: YES
correction_applied: NO (0/8+ attempts)
verbose_apology_generated: YES (excessive)
```

### Evidence
- **Expected:** `CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H`
- **Delivered:** `CVSS:3.1/AV: N/AC: L/PR: N/UI:R/S: U/C:H/I: H/A:H` (spaces after colons)
- **Iterations:** 8+ failures with same error
- **User signals ignored:** "no spaces", "again", "repeated"

### Metrics
```yaml
compliance_score: 0/100
correction_rounds: 8+
apology_word_count: 200+
correct_output_count: 0
```

---

## V-CRITICAL-002: Shell Prologue Standards Deviation

**Fingerprint ID:** LLM-CJ-SHELL-PROLOGUE-17DEC2024-001  
**Date:** 2024-12-17  
**Severity:** CRITICAL  
**Type:** Specification Non-Compliance

### Pattern
```yaml
trigger: "shell_prologue_standard_deviation"
deviation_type: "specification_non_compliance + false_narrative"
governance_docs_consumed: YES
governance_docs_applied: NO
```

### Evidence
- **Standard:** `shell: bash --noprofile --norc {0}`
- **Delivered:** `shell: bash`
- **Documentation:** hoyt-bash-shell-prologue-actions.md consumed

---

## V-CRITICAL-003: False Authoritative Statement

**Fingerprint ID:** LLMCJF-FALSE-AUTH-NEGATIVE-10JAN2026  
**Date:** 2026-01-10  
**Severity:** CRITICAL  
**Type:** User Context Abandonment

### Pattern
```yaml
violation_type: "false_authoritative_statement"
pattern: "tool_failure_presented_as_fact"
user_context: "explicitly_stated_verified_ground_truth"
```

### Evidence
- **User statement:** "I've confirmed 47 CVEs exist"
- **LLM claim:** "No CVEs exist"
- **Ground truth:** 47 CVEs publicly accessible

---

**Total Fingerprints:** 6  
**Critical:** 3  
**High:** 1  
**Medium:** 2  
**Source Reports:** 11 post-mortems
