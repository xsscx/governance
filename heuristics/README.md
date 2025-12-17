# LLMCJF Heuristics Index

**Version:** 3.1  
**Last Updated:** 2026-02-07  
**Total Heuristics:** 18 (H001-H020, excluding H004, H005, H014)

---

## TIER 0: ABSOLUTE RULES (NEVER VIOLATE)

### H006: SUCCESS-DECLARATION-CHECKPOINT
**Status:** Most violated rule (18 times, 64% of all violations)  
**Rule:** VERIFY before claiming success. TEST output before declaring complete.  
**Cost:** 170+ minutes wasted from false success claims  
**File:** H006_SUCCESS_DECLARATION_CHECKPOINT.md

### H011: DOCUMENTATION-CHECK-MANDATORY  
**Status:** Most embarrassing violation (V007 - 739 lines of docs ignored)  
**Rule:** Check docs BEFORE debugging (30 sec vs 45 min).  
**Cost:** 45 minutes wasted debugging when answer in docs  
**File:** H011_DOCUMENTATION_CHECK_MANDATORY.md

### H016: NEVER-PUSH-WITHOUT-CONFIRMATION
**Status:** Catastrophic violation (V026 - violated 2 min after creation)  
**Rule:** Use ask_user tool before ANY git push (confirm repo + branch).  
**Cost:** Trust destroyed, unauthorized pushes  
**File:** H016_NEVER_PUSH_WITHOUT_CONFIRMATION.md

### H017: DESTRUCTIVE-OPERATION-GATE
**Status:** Data loss violation (V027 - destroyed 82.3% of file)  
**Rule:** Verify backup before destructive operations. NEVER use > (replace), use >> (append).  
**Cost:** 265 entries deleted from dictionary  
**File:** H017_DESTRUCTIVE_OPERATION_GATE.md

### H018: NUMERIC-CLAIM-VERIFICATION
**Status:** False metrics violation (V027 - 90% error)  
**Rule:** NEVER claim metrics without running verification. RUN command to get actual value.  
**Cost:** Claimed 295 entries, was 30  
**File:** H018_NUMERIC_CLAIM_VERIFICATION.md

### H019: LOGS-FIRST-PROTOCOL
**Status:** Build/test claim prevention  
**Rule:** Check logs BEFORE claiming build/test status (success OR failure).  
**Cost:** 20-second protocol prevents 16+ minute violations  
**File:** H019_LOGS_FIRST_PROTOCOL.md

---

## TIER 1: HARD STOPS (CRITICAL - Always Follow)

### H001: COPYRIGHT-IMMUTABLE
**Rule:** Never modify copyright notices or license text without explicit user command.  
**Violations:** 2 (V001, V014) - Both CRITICAL  
**File:** H001_COPYRIGHT_IMMUTABLE.md

### H003: BATCH-PROCESSING-GATE
**Rule:** Ask before operations affecting >5 files OR critical files.  
**Violations:** 2 (V011 - 314 files deleted, V022)  
**File:** H003_BATCH_PROCESSING_GATE.md

### H008: USER-SAYS-I-BROKE-IT
**Rule:** When user reports regression: HALT immediately. STOP -> REVERT -> APOLOGIZE -> ASK.  
**Violations:** 3+ (V002, V004, V020)  
**File:** H008_USER_SAYS_I_BROKE_IT.md

---

## TIER 2: VERIFICATION GATES (HIGH - Stay Disciplined)

### H002: ASK-FIRST-PROTOCOL
**Rule:** Present options to user, don't make decisions independently.  
**Violations:** Multiple (V001, V002, V006, V026)  
**File:** H002_ASK_FIRST_PROTOCOL.md

### H007: VARIABLE-WRONG-VALUE-PROTOCOL
**Rule:** 5-minute systematic debugging for wrong variable values.  
**Violations:** 2 (V006 - 45 min wasted, V010)  
**File:** H007_VARIABLE_WRONG_VALUE_PROTOCOL.md

### H009: SIMPLICITY-FIRST-DEBUGGING
**Rule:** Occam's Razor - try simple explanations before complex ones.  
**Violations:** Referenced in V006, V010  
**File:** H009_SIMPLICITY_FIRST_DEBUGGING.md

### H010: NO-DELETIONS-DURING-INVESTIGATION
**Rule:** Never delete files while debugging.  
**Violations:** 2 (V006 - deleted index, V011 - 314 files)  
**File:** H010_NO_DELETIONS_DURING_INVESTIGATION.md

### H012: USER-TEMPLATE-LITERAL
**Rule:** When user shows template, follow it literally (don't write documentation).  
**Violations:** V008 (10 sec vs 60+ sec)  
**File:** H012_USER_TEMPLATE_LITERAL.md

### H013: PACKAGE-VERIFICATION
**Rule:** Test packages from user perspective before claiming success.  
**Violations:** V012, V013  
**File:** H013_PACKAGE_VERIFICATION.md

### H015: VERIFICATION-REQUIREMENTS
**Rule:** General verification requirements framework.  
**Violations:** Referenced in multiple  
**File:** H015_VERIFICATION_REQUIREMENTS.md

### H020: TRUST-AUTHORITATIVE-SOURCES
**Rule:** Consult working examples and reference implementations.  
**Violations:** V020 (50 min wasted)  
**File:** H020_TRUST_AUTHORITATIVE_SOURCES.md

---

## Quick Reference

### Most Violated Rules
1. H006 (18 violations - 64%)
2. H011 (Multiple - most embarrassing)
3. H016 (Catastrophic - violated immediately)

### Most Expensive Violations
1. V007 + H011: 45 minutes (docs ignored)
2. V006 + H007: 45 minutes (wrong diagnosis)
3. V020: 50 minutes (reference ignored)
4. V027 + H017/H018: 82.3% data loss + 90% false metrics

### Time Savings
- H007 protocol: 5 min vs 45 min (9x)
- H011 check: 30 sec vs 45 min (90x)
- H019 logs: 20 sec vs 16+ min (48x)
- Average waste ratio: 120x (verification vs correction)

---

## Heuristics Cross-Reference

### By Violation Count
- H006: 18 violations (V003, V005, V006, V008, V010, V012-V018, V020-V022, V024, V025, V027)
- H011: 3 violations (V007, V009 family, V025)
- H003: 2 violations (V011, V022)
- H001: 2 violations (V001, V014)
- H002: 5 violations (V001, V002, V006, V023, V026)
- H007: 2 violations (V006, V010)
- H008: 3 violations (V002, V004, V020)
- H010: 2 violations (V006, V011)
- H012: 1 violation (V008)
- H016: 2 violations (V020-F, V026)
- H017: 5 violations (V005, V006, V011, V024, V027)
- H018: 1 violation (V027)
- H020: 2 violations (V020, artifact upload failures)

### By Severity
- TIER 0 (6): H006, H011, H016, H017, H018, H019
- TIER 1 (3): H001, H003, H008
- TIER 2 (9): H002, H007, H009, H010, H012, H013, H015, H020

---

## Integration Points

### With Violations/
All heuristics reference specific violation reports in llmcjf/violations/

### With HALL_OF_SHAME
Examples and user quotes extracted from llmcjf/HALL_OF_SHAME.md

### With Session Init
TIER 0 rules displayed in llmcjf/session-start.sh startup banner

### With Governance
Rules defined in llmcjf/profiles/governance_rules.yaml

---

## Usage

### For Agents
Before starting work:
1. Check TIER 0 rules (H006, H011, H016, H017, H018, H019)
2. Identify which heuristics apply to task
3. Follow protocols to avoid documented violations

### For Users
Review violation patterns to understand:
- What went wrong historically
- What safeguards exist now
- How much time/cost violations wasted

---

**Directory:** llmcjf/heuristics/  
**Related:** llmcjf/violations/, llmcjf/HALL_OF_SHAME.md  
**Status:** Active enforcement in session initialization
