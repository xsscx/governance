# Canonical Quick Start Guide
**Single Source of Truth for Session Initialization**

Last Updated: 2026-02-07  
Status: Authoritative reference for all session startup procedures

---

## Session Initialization (Single Command)

```bash
copilot -i "Run ./governance/session-start.sh
```

**Location:** LLMCJF repository root (`~/`)  
**NOT** in scripts/ subdirectory

---

## What This Does

1. [OK] Sources `governance/llmcjf-session-init.sh` (activates 17 automation functions)
2. [OK] Displays LLMCJF governance framework status
3. [OK] Shows validation automation requirements (4 gates, 7 CJF patterns)
4. [OK] Displays TIER 0 rules (H016, H017, H018)
5. [OK] Shows violation history and trust score
6. [OK] Provides reading order for governance documentation
7. [OK] Generates Copilot prompt with all necessary context

---

## Automation Functions Available

After running session-start.sh, these functions are available:

### Core Functions (6)
- `llmcjf_status` - Show governance status
- `llmcjf_rules` - Display active rules
- `llmcjf_shame` - Show violation history
- `llmcjf_check` - Pre-action governance check
- `llmcjf_help` - Complete function reference
- `llmcjf_refresh` - Reload governance docs

### Evidence & Verification (3)
- `llmcjf_evidence` - Collect verification evidence
- `llmcjf_verify_claim` - Type-specific claim verification
- `llmcjf_session_claims` - Cross-turn consistency tracking

### Source Citation & Uncertainty (3)
- `llmcjf_cite_source` - Validate source citations
- `llmcjf_check_uncertainty` - Detect speculation triggers
- `llmcjf_track_claim` - Session state tracking with contradiction detection

### Automated CJF Detection (5)
- `llmcjf_scan_response` - Pre-response CJF pattern scan
- `llmcjf_validate_file_modification` - Syntax/format validation
- `llmcjf_check_intent_mismatch` - TEST vs DOCUMENT detection
- `llmcjf_verify_tool_usage` - Project tools requirement verification
- `llmcjf_check_exit_code` - Exit code classification (CJF-13 prevention)

**Total:** 17 functions (6 core + 11 automation)

---

## Key Governance Requirements

### TIER 0 Rules (Absolute - Never Violate)

**H016:** Never push to remote without ask_user confirmation  
**H017:** Destructive operations require evidence-based verification  
**H018:** Numeric claims require verification before stating

### Pre-Response Workflow (Mandatory)

```
1. llmcjf_check <action>        → Check governance rules
2. Collect evidence              → Run commands, capture output
3. llmcjf_verify_claim           → Verify numeric claims
4. llmcjf_cite_source            → Cite evidence source
5. Make claim with evidence      → State results
```

### Required Patterns

[OK] **CORRECT:** VERIFY → CITE → CLAIM (with evidence)  
[FAIL] **WRONG:** CLAIM → SKIP VERIFY → USER CORRECTS

---

## Environment Variables Set

After session-start.sh runs:

```bash
LLMCJF_ACTIVE=true
LLMCJF_VERSION=3.1
LLMCJF_GOVERNANCE_ROOT=<path to governance/>
LLMCJF_AUTOMATION_ACTIVE=true
```

---

## Documentation Reading Order

**Start here for new sessions:**

1. **STRICT_ENGINEERING_PROLOGUE.md** - Core behavioral constraints
2. **profiles/governance_rules.yaml** - H001-H018 rules (v3.1)
3. **GOVERNANCE_DASHBOARD.md** - Violation history, trust score, metrics
4. **HALL_OF_SHAME.md** - Critical violation examples
5. **README_CLAIM_VERIFICATION.md** - Automation usage guide

**For specific tasks:**
- Modifying dictionaries → FUZZER_DICTIONARY_GOVERNANCE.md
- Exit code interpretation → CJF-13 documentation (automated_cjf_detection.yaml)
- Numeric claims → H018 + llmcjf_verify_claim examples

---

## Quick Reference Commands

```bash
# Show all available functions
llmcjf_help

# Check if action allowed
llmcjf_check "modify dictionary"

# Verify numeric claim before stating
llmcjf_verify_claim numeric "entries" "wc -l dict.txt"

# Classify exit code (prevents CJF-13)
llmcjf_check_exit_code $? "crash claim"

# Track claim for contradiction detection
llmcjf_track_claim "file_count" "42" "ls | wc -l"

# Check for speculation in response
llmcjf_check_uncertainty "This probably improves coverage"
```

---

## Common Mistakes to Avoid

[FAIL] Running from governance/ subdirectory  
[OK] Run from main repository root

[FAIL] Manually sourcing llmcjf-session-init.sh  
[OK] Use session-start.sh (does this automatically)

[FAIL] Claiming numbers without verification  
[OK] Use llmcjf_verify_claim before stating

[FAIL] Assuming exit code 1 = crash  
[OK] Use llmcjf_check_exit_code (1-127 = soft, 128+ = crash)

[FAIL] Creating documentation without request  
[OK] Read/consult docs (required), but don't create (prohibited)

---

## Testing Infrastructure

**Unit Tests:** `cd llmcjf && ./tests/test-llmcjf-functions.sh`  
**Integration Tests:** `cd llmcjf && ./tests/test-integration.sh`  
**Coverage:** 35 tests total (20 unit + 15 integration)

---

## Related Documentation

- **README.md** - Complete governance documentation catalog
- **SESSION_INIT_GUIDE.md** - Detailed initialization guide
- **QUICK_START.md** - Alternative quick start (use this document instead)
- **AUTOMATION_INTEGRATION_ROADMAP.md** - Future enhancement roadmap
- **GOVERNANCE_DASHBOARD.md** - Real-time metrics and status

**Note:** All other quick start sections should reference this document as the canonical source.

---

## Version History

- **2026-02-07:** Created as canonical quick start reference (deduplication effort)
- **Purpose:** Single source of truth to replace scattered startup instructions
