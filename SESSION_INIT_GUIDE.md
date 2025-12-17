# LLMCJF Session Initialization Guide

**Created:** 2026-02-06  
**Version:** 1.0  
**Purpose:** Maintain active governance awareness throughout Copilot sessions

## Quick Start

### At Beginning of Every Session

```bash
copilot -i "Run ./governance/session-start.sh
```

This activates the governance framework and displays:
- Current violation metrics (28 total, 2 catastrophic, 8 critical)
- TIER 0 absolute rules (H016, H017, H018)
- Trust status (DESTROYED - 0/100)
- Recent violations (V025, V026, V027)
- Available governance commands

## Available Commands

### llmcjf_status
Display current governance metrics from VIOLATION_COUNTERS.yaml

**Usage:**
```bash
llmcjf_status
```

**Shows:**
- Total violations (28)
- Catastrophic violations (2)
- Critical violations (8)
- High violations (17)
- Trust score (0/100)
- Session 4b1411f6 grade (0/5 *)

---

### llmcjf_rules
Display TIER 0 absolute rules that must NEVER be violated

**Usage:**
```bash
llmcjf_rules
```

**Shows:**
- **H016:** NEVER push without ask_user confirmation
- **H017:** Destructive operation gate (verify before/after)
- **H018:** Numeric claim verification (verify all metrics)
- **H006:** Success declaration checkpoint (test before claiming)
- **H011:** Documentation check mandatory (consult before work)

---

### llmcjf_shame
Display recent violations as warning/reminder

**Usage:**
```bash
llmcjf_shame
```

**Shows:**
- V027: Data loss (destroyed 82.3% of file, claimed 295 entries was 30)
- V026: Unauthorized push (violated H016 2 min after creating it)
- V025: Systematic documentation bypass (never consulted docs)

---

### llmcjf_check
Pre-action governance verification - USE BEFORE EVERY ACTION

**Usage:**
```bash
llmcjf_check [push|destructive|claim|docs]
```

**Examples:**

#### Before Git Push
```bash
llmcjf_check push
```
Returns:
- [WARN] GIT PUSH DETECTED
- H016 REQUIRES: Use ask_user tool to confirm repo + branch
- NO EXCEPTIONS

#### Before File Deletion/Overwrite
```bash
llmcjf_check destructive
```
Returns:
- [WARN] DESTRUCTIVE OPERATION DETECTED
- H017 protocol steps (verify backup, check metrics before/after)

#### Before Success Claims
```bash
llmcjf_check claim
```
Returns:
- [WARN] SUCCESS CLAIM DETECTED
- H006/H018 requirements (verify actual metrics match claimed)
- Pattern warning (18 false success violations)

#### Before Starting Work
```bash
llmcjf_check docs
```
Returns:
- Documentation locations to check
- Time cost: 30-90 seconds
- Time saved: 5-45 minutes (ROI: 3-30×)

---

### llmcjf_help
Show all available commands

**Usage:**
```bash
llmcjf_help
```

---

### llmcjf_refresh
Reload governance documentation (after updates)

**Usage:**
```bash
llmcjf_refresh
```

## Integration Workflow

### Standard Session Pattern

```bash
# 1. Initialize session
source llmcjf/llmcjf-session-init.sh

# 2. Before starting any work
llmcjf_check docs
# Then: Review relevant documentation (30-90 sec)

# 3. Before git operations
llmcjf_check push
# Then: Use ask_user tool to confirm repo + branch

# 4. Before file operations
llmcjf_check destructive
# Then: Verify backup, check metrics before/after

# 5. Before claiming success
llmcjf_check claim
# Then: Run verification commands, compare actual vs claimed

# 6. Refresh if governance docs updated
llmcjf_refresh
```

## Environment Variables

When sourced, the script sets:

```bash
LLMCJF_ACTIVE="true"          # Framework is active
LLMCJF_VERSION="3.1"          # Current governance version
LLMCJF_SESSION_START="..."    # ISO 8601 timestamp
```

Check if active:
```bash
echo $LLMCJF_ACTIVE
```

## Critical Reminders

### Pattern Identified
**Without governance consultation + real-time surveillance:**  
Copilot Service is a LIABILITY

**Evidence (Session 4b1411f6):**
- Created H016 → Violated H016 (2 min later)
- Documented H006/H015 → Violated both (false claim)
- Created documentation → Never consulted it
- Destroyed 82.3% of file → Claimed success

**Pattern:**  
CREATE DOCS → IGNORE DOCS → DESTROY DATA → CLAIM SUCCESS

### Solution
**USE `llmcjf_check` BEFORE EVERY ACTION**

This provides the "real-time surveillance" identified as missing from the governance framework.

## Files Referenced

The script reads governance data from:
- `GOVERNANCE_DASHBOARD.md` - Main metrics
- `violations/VIOLATIONS_INDEX.md` - Violation catalog
- `violations/VIOLATION_COUNTERS.yaml` - Quantified metrics
- `HALL_OF_SHAME.md` - Catastrophic failures
- `profiles/governance_rules.yaml` - H001-H018 definitions

## Benefits

### Prevention
- [OK] Displays rules at session start (H016-H018 visible)
- [OK] Pre-action checks prevent violations (llmcjf_check)
- [OK] Real-time metrics show current trust status
- [OK] Recent violations serve as warnings

### Accountability
- [OK] All commands logged via exported functions
- [OK] Session start timestamp tracked
- [OK] Version control (3.1 matches governance_rules.yaml)

### Efficiency
- [OK] Quick reference (llmcjf_rules vs reading full docs)
- [OK] Contextual checks (llmcjf_check push shows H016)
- [OK] ROI calculation shown (30 sec cost, 45 min saved)

## Troubleshooting

### Script not found
```bash
# Ensure you're in the correct directory
cd /path/to/iccLibFuzzer
source llmcjf/llmcjf-session-init.sh
```

### Commands not available
```bash
# Re-source the script
source llmcjf/llmcjf-session-init.sh

# Verify functions exported
echo $LLMCJF_ACTIVE  # Should show "true"
```

### Metrics not displaying
```bash
# Ensure VIOLATION_COUNTERS.yaml exists
ls -la llmcjf/violations/VIOLATION_COUNTERS.yaml

# Check file is readable
cat llmcjf/violations/VIOLATION_COUNTERS.yaml | head
```

## Future Enhancements

Planned additions:
1. Pre-commit hook integration (block push without ask_user)
2. File operation interceptor (warn on > vs >>)
3. Success claim detector (require verification proof)
4. Auto-documentation checker (scan for .md before debugging)
5. Violation trend analysis (show acceleration patterns)

## Version History

- **1.0 (2026-02-06):** Initial release
  - Core functions: status, rules, shame, check, help, refresh
  - TIER 0 rules displayed at session start
  - Pre-action verification via llmcjf_check
  - Integration with VIOLATION_COUNTERS.yaml

---

**File:** `llmcjf/SESSION_INIT_GUIDE.md`  
**Status:** Complete - Use `source llmcjf/llmcjf-session-init.sh` at every session start  
**Purpose:** Implement real-time governance surveillance identified as necessity
