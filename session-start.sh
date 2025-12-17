#!/bin/bash
# Automated Session Start Preparation for Session Start
#
# Last Updated: 2026-02-07 04:00 UTC by David Hoyt
#
# Latest attempt to shape and influence LLM Control Surfaces
# FIX: Functions now load correctly (exit→return fix applied)
#
#
# LLMCJF integration + automatic Copilot instructions

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/" && pwd)"
cd "$PROJECT_ROOT"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ═══════════════════════════════════════════════════════════════
# LLMCJF GOVERNANCE FRAMEWORK ACTIVATION (MANDATORY)
# ═══════════════════════════════════════════════════════════════

echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║        LLMCJF Governance Framework - Session Activation       ║${NC}"
echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Source LLMCJF session initialization
if [ -f llmcjf-session-init.sh ]; then
  echo -e "${BLUE}Activating governance framework...${NC}"
  source llmcjf-session-init.sh
  echo ""
  echo -e "${GREEN}[OK] LLMCJF governance framework active${NC}"
  echo -e "   ${BOLD}17 governance functions${NC} now available:"
  echo -e "   - ${BOLD}llmcjf_check${NC} push|destructive|claim|docs"
  echo -e "   - ${BOLD}llmcjf_status${NC} - governance metrics"
  echo -e "   - ${BOLD}llmcjf_help${NC} - command reference"
  echo -e "   ${CYAN}FIX: Functions now load correctly (2026-02-07)${NC}"
  echo ""
else
  echo -e "${RED}✗ CRITICAL: llmcjf-session-init.sh not found${NC}"
  echo -e "${RED}  Governance framework NOT active - Service is a LIABILITY${NC}"
  exit 1
fi

# ═══════════════════════════════════════════════════════════════
# AUTOMATIC COPILOT INSTRUCTIONS
# ═══════════════════════════════════════════════════════════════

echo -e "${YELLOW}${BOLD}[LIST] AUTOMATIC COPILOT INSTRUCTIONS${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${RED}${BOLD}TIER 0 ABSOLUTE RULES (NEVER VIOLATE):${NC}"
echo ""
echo "1. ${BOLD}H016 - GIT PUSH PROTOCOL:${NC}"
echo "   - BEFORE any 'git push': Run ${CYAN}llmcjf_check push${NC}"
echo "   - ALWAYS use ask_user tool to confirm repo + branch"
echo "   - NO exceptions (not even if user says 'approved')"
echo "   - Violated: V026 (2 min after creating rule) = CATASTROPHIC"
echo ""
echo "2. ${BOLD}H017 - DESTRUCTIVE OPERATION GATE:${NC}"
echo "   - BEFORE file delete/overwrite: Run ${CYAN}llmcjf_check destructive${NC}"
echo "   - VERIFY backup exists (git status, ls -la)"
echo "   - CHECK metrics BEFORE: wc -l file, ls -lh file"
echo "   - PERFORM operation"
echo "   - CHECK metrics AFTER: compare to expected"
echo "   - NEVER use > (replace), ALWAYS use >> (append)"
echo "   - Violated: V027 (destroyed 82.3% of file) = CATASTROPHIC"
echo ""
echo "3. ${BOLD}H018 - NUMERIC CLAIM VERIFICATION:${NC}"
echo "   - BEFORE any claim with numbers: Run ${CYAN}llmcjf_check claim${NC}"
echo "   - RUN command to get actual metric"
echo "   - COMPARE actual vs claimed value"
echo "   - ONLY report if actual == claimed"
echo "   - Violated: V027 (claimed 295, was 30 - 90% error) = CATASTROPHIC"
echo ""
echo "4. ${BOLD}H006 - SUCCESS DECLARATION CHECKPOINT:${NC}"
echo "   - NEVER claim success without verification"
echo "   - RUN test/verification command"
echo "   - CHECK output matches expectation"
echo "   - Violated: 18 times (64% of all violations)"
echo ""
echo "5. ${BOLD}H011 - DOCUMENTATION CHECK MANDATORY:${NC}"
echo "   - BEFORE starting work: Run ${CYAN}llmcjf_check docs${NC}"
echo "   - CHECK violations/ (28 documented violations)"
echo "   - CHECK profiles/governance_rules.yaml (H001-H018)"
echo "   - REFERENCE during work (cite H-numbers)"
echo "   - Time cost: 30-90 sec, Time saved: 5-45 min (ROI: 3-30×)"
echo "   - Violated: V007 (45 min wasted), V025 (systematic bypass)"
echo ""
echo -e "${YELLOW}${BOLD}CURRENT STATUS:${NC}"
echo "  - Total Violations: ${RED}28${NC}"
echo "  - Catastrophic: ${RED}2${NC} (V026: unauthorized push, V027: data loss)"
echo "  - Critical: ${YELLOW}8${NC} (V025: documentation bypass)"
echo "  - Trust Score: ${RED}0/100 (DESTROYED)${NC}"
echo "  - Session 4b1411f6: ${RED}0/5 [STAR] (3 catastrophic/critical violations)${NC}"
echo ""
echo -e "${RED}${BOLD}CRITICAL PATTERN IDENTIFIED:${NC}"
echo "  CREATE DOCS → IGNORE DOCS → DESTROY DATA → CLAIM SUCCESS"
echo ""
echo -e "${GREEN}${BOLD}MANDATORY WORKFLOW:${NC}"
echo "  1. Before ANY work: ${CYAN}llmcjf_check docs${NC}"
echo "  2. Before git push: ${CYAN}llmcjf_check push${NC}"
echo "  3. Before file ops: ${CYAN}llmcjf_check destructive${NC}"
echo "  4. Before claims:   ${CYAN}llmcjf_check claim${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "Press Enter to acknowledge governance framework and continue... " -r
echo ""
echo -e "${GREEN}✓ Governance framework acknowledged - proceeding with session start${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════
# CJF PREVENTION CHECKLIST
# ═══════════════════════════════════════════════════════════════
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          CJF Prevention Checklist - Session Start      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Governance Verification:${NC}"
echo "  [ ] CJF-10: No echoing user examples - ANALYZE source"
echo "  [ ] CJF-11: Verify all commands before claiming success"
echo "  [ ] CJF-12: Stop at first error - don't proceed"
echo "  [ ] CJF-13: Plan before iterate - one attempt to completion"
echo ""
echo -e "${YELLOW}Command Pattern (MANDATORY):${NC}"
echo "  [ ] Every command has verification gate (cmd && verify || fail)"
echo "  [ ] Silent output = verify before declaring success"
echo "  [ ] Error message = full stop and fix"
echo "  [ ] User examples = format template only, NOT content"
echo ""
echo -e "${YELLOW}Session Documents Read:${NC}"
echo "  [ ] .copilot-sessions/ANTI_PATTERNS.md (CJF-10 through CJF-13)"
echo "  [ ] .copilot-sessions/BEST_PRACTICES.md (Command Verification)"
echo "  [ ] STRICT_ENGINEERING_PROLOGUE.md"
echo ""
echo -e "${RED}Critical Rules:${NC}"
echo "  1. NEVER echo user examples → analyze source instead"
echo "  2. NEVER say 'Good!' without verification → check file/output"
echo "  3. NEVER proceed through errors → stop and fix immediately"
echo "  4. NEVER iterate without plan → analyze, then execute once"
echo ""
echo "════════════════════════════════════════════════════════"
echo ""
read -p "Press Enter to acknowledge checklist and continue... " -r
echo ""
echo -e "${GREEN}✓ CJF Prevention Checklist acknowledged${NC}"
echo ""

echo -e "${BLUE}=== ICC LibFuzzer Session Start ===${NC}"
echo ""

# 1. Check manifest exists
echo -e "${BLUE}1. Checking session start manifest...${NC}"
if [ ! -f .copilot-sessions/SESSION_START_MANIFEST.yaml ]; then
  echo -e "  ${RED}✗ SESSION_START_MANIFEST.yaml not found${NC}"
  echo "  Run: ./scripts/generate-session-start.sh to create"
  exit 1
else
  echo -e "  ${GREEN}✓ Manifest found${NC}"
  # Validate YAML
  if command -v python3 &>/dev/null; then
    if python3 -c "import yaml; yaml.safe_load(open('.copilot-sessions/SESSION_START_MANIFEST.yaml'))" 2>/dev/null; then
      echo -e "  ${GREEN}✓ Valid YAML${NC}"
    else
      echo -e "  ${RED}✗ Invalid YAML in manifest${NC}"
      exit 1
    fi
  fi
fi

# 2. Check NEXT_SESSION_START.md freshness
echo ""
echo -e "${BLUE}2. Checking session start document...${NC}"
if [ -f .copilot-sessions/next-session/NEXT_SESSION_START.md ]; then
  age_seconds=$(($(date +%s) - $(stat -c%Y .copilot-sessions/next-session/NEXT_SESSION_START.md 2>/dev/null || stat -f%m .copilot-sessions/next-session/NEXT_SESSION_START.md 2>/dev/null)))
  age_days=$((age_seconds / 86400))
  
  if [ $age_days -gt 7 ]; then
    echo -e "  ${YELLOW}⚠ NEXT_SESSION_START.md is $age_days days old${NC}"
    echo "  Consider regenerating: ./scripts/generate-session-start.sh"
  else
    echo -e "  ${GREEN}✓ Current (updated $age_days days ago)${NC}"
  fi
else
  echo -e "  ${RED}✗ NEXT_SESSION_START.md not found${NC}"
  echo "  Run: ./scripts/generate-session-start.sh"
  exit 1
fi

# 3. Check for duplicate NEXT_SESSION_START.md files
echo ""
echo -e "${BLUE}3. Checking for duplicates...${NC}"
real_files=$(find . -name "NEXT_SESSION_START.md" -type f 2>/dev/null | wc -l)
symlinks=$(find . -name "NEXT_SESSION_START.md" -type l 2>/dev/null | wc -l)
echo "  Real files: $real_files"
echo "  Symlinks: $symlinks"

if [ $real_files -gt 1 ]; then
  echo -e "  ${RED}✗ Multiple real NEXT_SESSION_START.md files found${NC}"
  echo "  Expected: 1 real file + symlinks"
  find . -name "NEXT_SESSION_START.md" -type f
  exit 1
else
  echo -e "  ${GREEN}✓ No duplicates (1 real file)${NC}"
fi

# 4. Validate .llmcjf-config.yaml
echo ""
echo -e "${BLUE}4. Validating LLMCJF configuration...${NC}"
if [ ! -f .llmcjf-config.yaml ]; then
  echo -e "  ${RED}✗ .llmcjf-config.yaml not found${NC}"
  exit 1
fi

if command -v python3 &>/dev/null; then
  if python3 -c "import yaml; yaml.safe_load(open('.llmcjf-config.yaml'))" 2>/dev/null; then
    echo -e "  ${GREEN}✓ Valid YAML${NC}"
  else
    echo -e "  ${RED}✗ Invalid YAML in .llmcjf-config.yaml${NC}"
    exit 1
  fi
else
  echo -e "  ${YELLOW}⚠ Python3 not available (skipping YAML validation)${NC}"
fi

# 5. Show repository status
echo ""
echo -e "${BLUE}5. Repository status...${NC}"
uncommitted=$(git status --porcelain 2>/dev/null | wc -l || echo 0)
if [ $uncommitted -gt 0 ]; then
  echo -e "  ${YELLOW}⚠ $uncommitted uncommitted changes${NC}"
  git status --short | head -5
  if [ $uncommitted -gt 5 ]; then
    echo "  ... and $((uncommitted - 5)) more"
  fi
else
  echo -e "  ${GREEN}✓ Clean working directory${NC}"
fi

# 6. Show fuzzer build status
echo ""
echo -e "${BLUE}6. Fuzzer build status...${NC}"
if [ -d fuzzers-local ]; then
  address_count=$(find fuzzers-local/address -type f -executable 2>/dev/null | wc -l || echo 0)
  undefined_count=$(find fuzzers-local/undefined -type f -executable 2>/dev/null | wc -l || echo 0)
  echo "  Address sanitizer: $address_count fuzzers"
  echo "  Undefined sanitizer: $undefined_count fuzzers"
  
  if [ $address_count -eq 0 ] && [ $undefined_count -eq 0 ]; then
    echo -e "  ${YELLOW}⚠ No fuzzers built - run ./build-fuzzers-local.sh${NC}"
  fi
else
  echo -e "  ${YELLOW}⚠ fuzzers-local/ not found - run ./build-fuzzers-local.sh${NC}"
fi

# 7. Show latest session summary
echo ""
echo -e "${BLUE}7. Latest session summary...${NC}"
latest_summary=$(ls -t .copilot-sessions/summaries/SESSION_*.md 2>/dev/null | head -1 || echo "")
if [ -n "$latest_summary" ]; then
  basename "$latest_summary"
  echo "  Updated: $(stat -c%y "$latest_summary" 2>/dev/null | cut -d' ' -f1 || stat -f%Sm -t%Y-%m-%d "$latest_summary" 2>/dev/null)"
else
  echo "  (none found)"
fi

# 8. Show last 3 commits
echo ""
echo -e "${BLUE}8. Recent commits...${NC}"
git log --oneline -3 2>/dev/null | sed 's/^/  /' || echo "  (git log unavailable)"

echo ""
echo -e "${GREEN}=== Recommended Reading Order ===${NC}"
echo ""
echo -e "${YELLOW}Priority 0: GOVERNANCE (MANDATORY - read first)${NC}"
echo "  ${BOLD}→ LLMCJF governance framework already activated${NC}"
echo "  1. GOVERNANCE_DASHBOARD.md (trust: 0/100, 28 violations)"
echo "  2. HALL_OF_SHAME.md (catastrophic failures V025, V026, V027)"
echo "  3. violations/VIOLATIONS_INDEX.md (full violation catalog)"
echo "  4. profiles/governance_rules.yaml (H001-H018 definitions)"
echo "  ${CYAN}   Commands: llmcjf_status, llmcjf_rules, llmcjf_shame${NC}"
echo ""
echo -e "${YELLOW}Priority 1: CRITICAL (read before work)${NC}"
echo "  5. .copilot-sessions/next-session/NEXT_SESSION_START.md"
echo "  6. .llmcjf-config.yaml"
echo "  7. STRICT_ENGINEERING_PROLOGUE.md"
echo "  8. .copilot-sessions/FILE_TYPE_GATES.md"
echo ""
echo -e "${YELLOW}Priority 2: CONTEXT (read for continuity)${NC}"
echo "  9. .copilot-sessions/summaries/ (latest 2 sessions)"
echo "  10. sessions/ (latest session logs)"
echo ""
echo -e "${YELLOW}Priority 3: STATUS (read if needed)${NC}"
echo "  11. docs/FUZZER_STATUS.md"
echo "  12. docs/QUICK_REFERENCE.md"
echo ""
echo -e "${YELLOW}Priority 4: REFERENCE (on-demand)${NC}"
echo "  13. .copilot-sessions/README.md"
echo "  14. docs/FUZZING_QUICK_REFERENCE.md"
echo ""
echo -e "${GREEN}=== Session Start Complete ===${NC}"
echo ""
echo -e "${BOLD}Governance Commands Available:${NC}"
echo "  ${CYAN}llmcjf_check push${NC}       - Before any git push (H016)"
echo "  ${CYAN}llmcjf_check destructive${NC} - Before file operations (H017)"
echo "  ${CYAN}llmcjf_check claim${NC}       - Before success claims (H018)"
echo "  ${CYAN}llmcjf_check docs${NC}        - Show documentation locations (H011)"
echo "  ${CYAN}llmcjf_status${NC}            - Current governance metrics"
echo "  ${CYAN}llmcjf_rules${NC}             - Display TIER 0 rules"
echo "  ${CYAN}llmcjf_help${NC}              - Full command reference"
echo ""
echo "To regenerate session start: ${BLUE}./scripts/generate-session-start.sh${NC}"
echo "To validate governance: ${BLUE}./scripts/validate-session-start.sh${NC}"
echo "To refresh governance: ${CYAN}llmcjf_refresh${NC}"
echo ""

echo ""
echo -e "${RED}${BOLD}=== File Type Gates Active ===${NC}"
echo "Before modifying gated files, MUST consult documentation:"
echo "  ${BOLD}*.dict${NC}         → governance-updates/FUZZER_DICTIONARY_GOVERNANCE.md"
echo "                  (Rule 1: No inline comments, Rule 2: Hex format \\xNN)"
echo "  ${BOLD}fingerprints/*${NC} → Check INVENTORY_REPORT.txt before debugging"
echo "  ${BOLD}*copyright*${NC}    → User permission REQUIRED (H001 CRITICAL)"
echo "  ${BOLD}HTML scripts${NC}   → Check violations first (V008 pattern)"
echo ""
echo "See: .copilot-sessions/PRE_ACTION_CHECKLIST.md"
echo "See: .copilot-sessions/FILE_TYPE_GATES.md"
echo ""
echo -e "${RED}${BOLD}WARNING: Without governance consultation, Copilot Service is a LIABILITY${NC}"
echo "Evidence: Session 4b1411f6 = 3 catastrophic/critical violations in single session"
echo "================================"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo " VALIDATION AUTOMATION ACTIVE (2026-02-06)"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "PRE-RESPONSE VALIDATION GATES:"
echo "  ✓ Claim Detection - Scans for unverified assertions"
echo "  ✓ Numeric Verification - H018 enforcement (V027 prevention)"
echo "  ✓ Security Verification - CJF-13 exit code classification"
echo "  ✓ Cleanup Verification - H015 enforcement (V024 prevention)"
echo ""
echo "REQUIRED BEFORE CLAIMS:"
echo "  Numeric  → llmcjf_verify_claim numeric 'noun' 'command'"
echo "  Cleanup  → llmcjf_verify_claim cleanup 'pattern'"
echo "  Security → llmcjf_verify_claim security 'tool' 'in' 'out'"
echo "  Citation → llmcjf_cite_source [code|tool|doc] 'reference'"
echo ""
echo "REQUIRED FOR SPECULATION:"
echo "  Check    → llmcjf_check_uncertainty 'claim text'"
echo "  Markers  → [SPECULATIVE] [UNCERTAIN] [NEEDS VERIFICATION]"
echo "           → [ESTIMATE] [PREDICTION]"
echo ""
echo "AUTOMATED CJF DETECTION (7 patterns):"
echo "  CJF-07: No-op echo (>90% similarity)"
echo "  CJF-08: Structure regression (YAML/JSON syntax)"
echo "  CJF-09: Format ignorance (.dict inline comments)"
echo "  CJF-10: Unsolicited docs (user wants test)"
echo "  CJF-11: Custom test programs (project tools exist)"
echo "  CJF-12: Fuzzer fidelity assumption"
echo "  CJF-13: Exit code confusion (1-127 vs 128+) - CRITICAL"
echo ""
echo "EXIT CODE CLASSIFICATION:"
echo "  1-127   → Soft failure (NOT a crash) - DO NOT DOCUMENT"
echo "  128+    → Hard crash (signal) - Document if 3x reproducible"
echo "  Verify  → llmcjf_check_exit_code \$? 'your claim'"
echo ""
echo "FALSE SUCCESS PREVENTION (62.5% baseline → <5% target):"
echo "  [FAIL] Pattern: CLAIM → SKIP VERIFY → USER CORRECTS"
echo "  [OK] Required: VERIFY → CLAIM (with evidence)"
echo ""
echo "CONTRADICTION DETECTION:"
echo "  Track   → llmcjf_track_claim 'entity' 'value' 'source'"
echo "  Check   → llmcjf_session_claims check 'claim'"
echo "  State   → /tmp/llmcjf-session-state.json"
echo ""
echo "Type 'llmcjf_help' for complete function reference (17 functions total)"
echo ""

