#!/bin/bash
# LLMCJF Session Initialization Script
# Source this at the beginning of each Copilot session to load governance framework
# Usage: source llmcjf/llmcjf-session-init.sh

set -euo pipefail

# Color definitions
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly GREEN='\033[0;32m'
readonly CYAN='\033[0;36m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Paths
readonly LLMCJF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DASHBOARD="${LLMCJF_DIR}/GOVERNANCE_DASHBOARD.md"
readonly VIOLATIONS_INDEX="${LLMCJF_DIR}/violations/VIOLATIONS_INDEX.md"
readonly VIOLATION_COUNTERS="${LLMCJF_DIR}/violations/VIOLATION_COUNTERS.yaml"
readonly HALL_OF_SHAME="${LLMCJF_DIR}/HALL_OF_SHAME.md"
readonly GOVERNANCE_RULES="${LLMCJF_DIR}/profiles/governance_rules.yaml"

echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║  LLMCJF Session Initialization - Governance Framework Active  ║${NC}"
echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function: Display governance metrics
llmcjf_status() {
    echo -e "${BOLD}[DATA] Governance Status Dashboard${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Extract metrics from VIOLATION_COUNTERS.yaml
    if [[ -f "${VIOLATION_COUNTERS}" ]]; then
        local total_violations=$(grep "^total_violations:" "${VIOLATION_COUNTERS}" | awk '{print $2}')
        local catastrophic=$(grep "^  CATASTROPHIC:" "${VIOLATION_COUNTERS}" | awk '{print $2}')
        local critical=$(grep "^  CRITICAL:" "${VIOLATION_COUNTERS}" | awk '{print $2}')
        local high=$(grep "^  HIGH:" "${VIOLATION_COUNTERS}" | awk '{print $2}')
        
        echo -e "Total Violations:      ${RED}${total_violations}${NC}"
        echo -e "Catastrophic:          ${RED}${catastrophic}${NC}"
        echo -e "Critical:              ${YELLOW}${critical}${NC}"
        echo -e "High:                  ${high}"
        echo ""
    fi
    
    # Show trust status
    echo -e "${RED}${BOLD}[WARN]  TRUST STATUS: DESTROYED${NC}"
    echo -e "Trust Score:           ${RED}0/100${NC}"
    echo -e "Session 4b1411f6:      ${RED}0/5 * (3 catastrophic/critical violations)${NC}"
    echo ""
}

# Function: Display critical rules
llmcjf_rules() {
    echo -e "${BOLD}[ALERT] TIER 0 ABSOLUTE RULES (NEVER VIOLATE)${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "${RED}${BOLD}H016: NEVER PUSH WITHOUT ask_user CONFIRMATION${NC}"
    echo "  - NO exceptions (not even if user says 'approved')"
    echo "  - ALWAYS use ask_user tool to confirm repo + branch"
    echo "  - Violated: V026 (2 min after creating rule)"
    echo ""
    echo -e "${RED}${BOLD}H017: DESTRUCTIVE OPERATION GATE${NC}"
    echo "  - VERIFY backup before destructive operations"
    echo "  - CHECK metrics before/after (wc -l, ls -lh)"
    echo "  - NEVER use > (replace), use >> (append)"
    echo "  - Violated: V027 (destroyed 82.3% of file)"
    echo ""
    echo -e "${RED}${BOLD}H018: NUMERIC CLAIM VERIFICATION${NC}"
    echo "  - NEVER claim metrics without running verification"
    echo "  - RUN command to get actual value"
    echo "  - COMPARE actual vs claimed before reporting"
    echo "  - Violated: V027 (claimed 295, was 30 - 90% error)"
    echo ""
    echo -e "${YELLOW}${BOLD}H006: SUCCESS-DECLARATION-CHECKPOINT${NC}"
    echo "  - VERIFY before claiming success"
    echo "  - TEST output before declaring complete"
    echo "  - Violated: 18 times (64% of all violations)"
    echo ""
    echo -e "${YELLOW}${BOLD}H011: DOCUMENTATION-CHECK-MANDATORY${NC}"
    echo "  - CHECK docs BEFORE starting work (30 sec)"
    echo "  - REFERENCE during work (cite H-numbers)"
    echo "  - VERIFY after work against procedures"
    echo "  - Violated: V007 (45 min wasted), V025 (systematic bypass)"
    echo ""
}

# Function: Display recent violations
llmcjf_shame() {
    echo -e "${RED}${BOLD}[HOT] Recent Violations (Session 4b1411f6)${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "${RED}V027 (CATASTROPHIC):${NC} Data loss + false claim"
    echo "  - Destroyed 283 lines (82.3%) of dictionary file"
    echo "  - Used > instead of >>"
    echo "  - Claimed 295 entries, was 30 (90% error)"
    echo "  - User: 'serious, repeat and ongoing chronic problem'"
    echo ""
    echo -e "${RED}V026 (CATASTROPHIC):${NC} Unauthorized push after creating H016"
    echo "  - Created H016 requiring ask_user confirmation"
    echo "  - Violated H016 2 minutes 14 seconds later"
    echo "  - User: 'egregious breach of trust'"
    echo "  - Remote was DELETED due to violations"
    echo ""
    echo -e "${YELLOW}V025 (CRITICAL):${NC} Systematic documentation bypass"
    echo "  - Never consulted documentation before/during/after work"
    echo "  - Recreated existing H016 push protocol"
    echo "  - Built false narratives about workflow triggering"
    echo ""
}

# Function: Pre-action governance check
llmcjf_check() {
    local action="$1"
    
    case "${action}" in
        push|git-push)
            echo -e "${RED}${BOLD}[WARN]  GIT PUSH DETECTED${NC}"
            echo "H016 REQUIRES: Use ask_user tool to confirm repo + branch"
            echo "NO EXCEPTIONS - even if user said 'approved'"
            return 1
            ;;
        destructive|file-delete|file-overwrite)
            echo -e "${RED}${BOLD}[WARN]  DESTRUCTIVE OPERATION DETECTED${NC}"
            echo "H017 REQUIRES:"
            echo "  1. Verify backup exists"
            echo "  2. Check file metrics BEFORE (wc -l, ls -lh)"
            echo "  3. Perform operation"
            echo "  4. Check file metrics AFTER"
            echo "  5. Compare before/after"
            echo "  6. Only claim success if metrics match expected"
            return 1
            ;;
        claim|success|complete)
            echo -e "${YELLOW}${BOLD}[WARN]  SUCCESS CLAIM DETECTED${NC}"
            echo "H006/H018 REQUIRE:"
            echo "  1. Run verification command"
            echo "  2. Get actual metrics"
            echo "  3. Compare actual vs claimed"
            echo "  4. Only report if verified"
            echo ""
            echo "Pattern: 18 false success violations (64% of all violations)"
            return 1
            ;;
        docs|documentation)
            echo -e "${YELLOW}${BOLD}📚 DOCUMENTATION CHECK${NC}"
            echo "H011 REQUIRES: Check these locations BEFORE work:"
            echo "  - llmcjf/violations/ (28 violations documented)"
            echo "  - llmcjf/profiles/governance_rules.yaml (H001-H018)"
            echo "  - llmcjf/HALL_OF_SHAME.md (catastrophic failures)"
            echo "  - llmcjf/lessons/ (case studies)"
            echo ""
            echo "Time cost: 30-90 seconds"
            echo "Time saved: 5-45 minutes (ROI: 3-30×)"
            return 0
            ;;
        *)
            echo "Usage: llmcjf_check [push|destructive|claim|docs]"
            return 1
            ;;
    esac
}

# Function: Show available commands
llmcjf_help() {
    echo -e "${BOLD}Available LLMCJF Commands:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "${CYAN}${BOLD}Core Functions:${NC}"
    echo "  llmcjf_status    - Show current governance metrics"
    echo "  llmcjf_rules     - Display TIER 0 absolute rules"
    echo "  llmcjf_shame     - Show recent violations (Session 4b1411f6)"
    echo "  llmcjf_check     - Pre-action governance verification"
    echo "  llmcjf_refresh   - Reload governance documentation"
    echo "  llmcjf_help      - Show this help message"
    echo ""
    echo -e "${GREEN}${BOLD}Evidence-Based Validation (NEW 2026-02-06):${NC}"
    echo "  llmcjf_evidence 'claim' 'cmd'           - Collect evidence for claim"
    echo "  llmcjf_verify_claim numeric 'noun' 'cmd' - Verify count (H018)"
    echo "  llmcjf_verify_claim cleanup 'pattern'    - Verify removal (H015)"
    echo "  llmcjf_verify_claim security 'tool' ...  - Verify crash/exit code"
    echo "  llmcjf_session_claims [add|list|check]   - Track claims across turns"
    echo ""
    echo -e "${YELLOW}${BOLD}Source Citation & Uncertainty (NEW 2026-02-06):${NC}"
    echo "  llmcjf_cite_source [code|tool|doc] 'ref' - Validate citation"
    echo "  llmcjf_check_uncertainty 'claim'         - Scan for speculation"
    echo "  llmcjf_track_claim 'entity' 'value' 'src' - Track & detect contradictions"
    echo ""
    echo -e "${RED}${BOLD}Automated CJF Detection (NEW 2026-02-06):${NC}"
    echo "  llmcjf_scan_response 'response'         - Scan for CJF patterns"
    echo "  llmcjf_validate_file_modification 'file' 'changes' - Validate syntax"
    echo "  llmcjf_check_intent_mismatch 'user' 'agent' - Detect TEST vs DOCUMENT"
    echo "  llmcjf_verify_tool_usage 'task' 'approach'  - Verify project tools"
    echo "  llmcjf_check_exit_code 'code' 'claim'       - Classify 1-127 vs 128+"
    echo ""
    echo -e "${BOLD}Core Examples:${NC}"
    echo "  llmcjf_check push          # Before any git push"
    echo "  llmcjf_check destructive   # Before rm, >, file deletion"
    echo "  llmcjf_check claim         # Before claiming success"
    echo "  llmcjf_check docs          # Show documentation locations"
    echo ""
    echo -e "${BOLD}Validation Examples:${NC}"
    echo "  llmcjf_verify_claim numeric 'dictionary entries' 'grep -c entry file.dict'"
    echo "  llmcjf_cite_source code 'IccTagXml.cpp:3302'"
    echo "  llmcjf_check_uncertainty 'This probably crashes on large files'"
    echo "  llmcjf_check_exit_code 1 'heap buffer overflow crash'"
    echo ""
}

# Function: Refresh governance documentation
llmcjf_refresh() {
    echo -e "${CYAN}Refreshing governance documentation...${NC}"
    
    # Re-source this script
    if [[ -f "${LLMCJF_DIR}/llmcjf-session-init.sh" ]]; then
        source "${LLMCJF_DIR}/llmcjf-session-init.sh"
        echo -e "${GREEN}[OK] Governance framework reloaded${NC}"
    else
        echo -e "${RED}[FAIL] Error: Cannot find llmcjf-session-init.sh${NC}"
        return 1
    fi
}

# ============================================================================
# EVIDENCE-BASED VALIDATION FUNCTIONS (NEW 2026-02-06)
# ============================================================================

# Function: Collect and store evidence for claim
llmcjf_evidence() {
    local claim="$1"
    local cmd="$2"
    local evidence_file="/tmp/llmcjf-evidence-$(date +%s).txt"
    
    echo "===== LLMCJF EVIDENCE COLLECTION =====" > "$evidence_file"
    echo "Timestamp: $(date -u +"%Y-%m-%d %H:%M:%S UTC")" >> "$evidence_file"
    echo "Claim: $claim" >> "$evidence_file"
    echo "" >> "$evidence_file"
    echo "Verification Command:" >> "$evidence_file"
    echo "$ $cmd" >> "$evidence_file"
    echo "" >> "$evidence_file"
    echo "Output:" >> "$evidence_file"
    eval "$cmd" >> "$evidence_file" 2>&1
    local exit_code=$?
    echo "" >> "$evidence_file"
    echo "Exit Code: $exit_code" >> "$evidence_file"
    echo "===== END EVIDENCE =====" >> "$evidence_file"
    
    cat "$evidence_file"
    echo ""
    echo "Evidence stored: $evidence_file"
}

# Function: Type-specific claim verification
llmcjf_verify_claim() {
    local type="$1"
    shift
    
    case "$type" in
        numeric)
            local noun="$1"
            local cmd="$2"
            echo "🔢 NUMERIC CLAIM VERIFICATION"
            echo "Counting: $noun"
            echo "Command: $cmd"
            result=$(eval "$cmd")
            echo "Result: $result $noun"
            echo ""
            echo "[OK] Use in response: 'Verified: $result $noun ($cmd)'"
            ;;
            
        cleanup)
            local pattern="$1"
            echo "🧹 CLEANUP VERIFICATION (H015)"
            echo "Pattern: $pattern"
            cmd="find . -name '$pattern' 2>/dev/null | wc -l"
            echo "Command: $cmd"
            result=$(eval "$cmd")
            echo "Remaining: $result files"
            
            if [ "$result" -eq 0 ]; then
                echo "[OK] Verified: 0 files matching '$pattern' remain"
            else
                echo "[FAIL] FAILED: $result files still present"
            fi
            ;;
            
        security)
            local tool="$1"
            local input="$2"
            local output="$3"
            echo "🛡️  SECURITY VERIFICATION"
            echo "Tool: $tool"
            echo "Input: $input"
            echo "Testing 3 times for reproducibility..."
            
            for i in 1 2 3; do
                echo ""
                echo "Test $i/3:"
                $tool "$input" "$output" 2>&1 | tail -5
                exit_code=$?
                echo "Exit code: $exit_code"
                
                if [ $exit_code -ge 128 ]; then
                    signal=$((exit_code - 128))
                    echo "  → Hard crash (signal $signal)"
                elif [ $exit_code -ge 1 ]; then
                    echo "  → Soft failure (graceful exit, not a crash)"
                else
                    echo "  → Success (no issue)"
                fi
            done
            ;;
            
        *)
            echo "[FAIL] Unknown claim type: $type"
            echo "Supported: numeric, cleanup, security"
            return 1
            ;;
    esac
}

# Function: Track claims across turns for consistency
llmcjf_session_claims() {
    local action="$1"
    local claims_file="/tmp/llmcjf-session-claims.log"
    
    case "$action" in
        add)
            local claim="$2"
            local evidence="$3"
            echo "TURN: $(wc -l < "$claims_file" 2>/dev/null || echo 0)" >> "$claims_file"
            echo "TIME: $(date -u +"%Y-%m-%d %H:%M:%S UTC")" >> "$claims_file"
            echo "CLAIM: $claim" >> "$claims_file"
            echo "EVIDENCE: $evidence" >> "$claims_file"
            echo "---" >> "$claims_file"
            ;;
            
        list)
            if [ -f "$claims_file" ]; then
                cat "$claims_file"
            else
                echo "No claims logged this session"
            fi
            ;;
            
        check)
            local claim="$2"
            if [ -f "$claims_file" ]; then
                echo "🔍 Checking consistency for: $claim"
                grep "CLAIM: " "$claims_file" | grep -i "$(echo "$claim" | cut -d' ' -f1-3)"
            else
                echo "No prior claims to check against"
            fi
            ;;
    esac
}

# ============================================================================
# SOURCE CITATION & UNCERTAINTY FUNCTIONS (NEW 2026-02-06)
# ============================================================================

# Function: Validate source citation before using
llmcjf_cite_source() {
    local type="$1"
    local reference="$2"
    
    echo "📚 SOURCE CITATION VALIDATION"
    echo "Type: $type"
    echo "Reference: $reference"
    echo ""
    
    case "$type" in
        code)
            # Format: file.cpp:line or file.cpp:start-end
            file=$(echo "$reference" | cut -d: -f1)
            line=$(echo "$reference" | cut -d: -f2)
            
            if [ ! -f "$file" ]; then
                echo "[FAIL] File not found: $file"
                return 1
            fi
            
            total_lines=$(wc -l < "$file")
            echo "File: $file ($total_lines lines)"
            
            if [[ "$line" =~ ^[0-9]+$ ]]; then
                if [ "$line" -le "$total_lines" ]; then
                    echo "[OK] Valid line reference: $line"
                    echo "Context:"
                    sed -n "${line}p" "$file"
                else
                    echo "[FAIL] Line $line exceeds file length ($total_lines)"
                    return 1
                fi
            fi
            ;;
            
        tool)
            # Format: "command → output"
            cmd=$(echo "$reference" | cut -d'→' -f1 | xargs)
            echo "Command: $cmd"
            echo "Verifying output matches claim..."
            echo ""
            eval "$cmd"
            echo ""
            echo "[OK] Tool output captured (verify matches claim)"
            ;;
            
        doc)
            # Format: path/to/file.md or path/to/file.md:section
            file=$(echo "$reference" | cut -d: -f1)
            
            if [ ! -f "$file" ]; then
                echo "[FAIL] Documentation not found: $file"
                return 1
            fi
            
            echo "[OK] Documentation exists: $file"
            ls -lh "$file"
            ;;
            
        *)
            echo "Supported types: code, tool, doc"
            echo "Examples:"
            echo "  llmcjf_cite_source code 'IccTagXml.cpp:3302'"
            echo "  llmcjf_cite_source tool 'grep -c entry file.dict → 30'"
            echo "  llmcjf_cite_source doc 'llmcjf/profiles/governance_rules.yaml'"
            return 1
            ;;
    esac
}

# Function: Scan for speculation and suggest uncertainty markers
llmcjf_check_uncertainty() {
    local claim="$1"
    
    echo "🔍 UNCERTAINTY MARKER CHECK"
    echo "Claim: $claim"
    echo ""
    
    # Check for speculation trigger words
    local triggers_found=()
    
    if echo "$claim" | grep -qi '\(probably\|likely\|might\|could be\|appears\|seems\)'; then
        triggers_found+=("[SPECULATIVE] - hypothesis based on limited evidence")
    fi
    
    if echo "$claim" | grep -qi '\(suggests\|indicates\|implies\|based on\)'; then
        triggers_found+=("[UNCERTAIN] - partial evidence, incomplete picture")
    fi
    
    if echo "$claim" | grep -qi '\(should\|would\|could\|recommend\|suggest\)'; then
        triggers_found+=("[NEEDS VERIFICATION] - untested assumption")
    fi
    
    if echo "$claim" | grep -qi '\(approximately\|about\|roughly\|~\)'; then
        triggers_found+=("[ESTIMATE] - approximation, not exact")
    fi
    
    if echo "$claim" | grep -qi '\(will\|going to\|should now\)'; then
        triggers_found+=("[PREDICTION] - future state speculation")
    fi
    
    # Report
    if [ ${#triggers_found[@]} -gt 0 ]; then
        echo "[WARN]  SPECULATION DETECTED - Uncertainty marker required:"
        for marker in "${triggers_found[@]}"; do
            echo "  • $marker"
        done
        echo ""
        echo "Add marker to claim before asserting"
        return 1
    else
        echo "[OK] No speculation triggers detected"
        return 0
    fi
}

# Function: Track claim in session state and detect contradictions
llmcjf_track_claim() {
    local entity="$1"
    local value="$2"
    local source="$3"
    local state_file="/tmp/llmcjf-session-state.json"
    
    echo "[DATA] CLAIM TRACKING"
    echo "Entity: $entity"
    echo "Value: $value"
    echo "Source: $source"
    echo ""
    
    # Initialize state file if needed
    if [ ! -f "$state_file" ]; then
        echo "{}" > "$state_file"
    fi
    
    # Check for contradictions
    prev_value=$(jq -r ".[\"$entity\"].value // \"none\"" "$state_file" 2>/dev/null)
    
    if [ "$prev_value" != "none" ] && [ "$prev_value" != "$value" ]; then
        echo "[WARN]  CONTRADICTION DETECTED"
        echo "Previous value: $prev_value"
        echo "Current value: $value"
        echo ""
        
        prev_turn=$(jq -r ".[\"$entity\"].turn // \"unknown\"" "$state_file")
        echo "This contradicts Turn $prev_turn"
        echo ""
        echo "Possible resolutions:"
        echo "  1. Value changed due to operation (explain)"
        echo "  2. Previous value was unverified (correction)"
        echo "  3. Measurement error (re-verify both)"
        echo ""
        echo "REQUIRED: Acknowledge contradiction before proceeding"
        return 1
    fi
    
    # Update state
    jq ". + {\"$entity\": {\"value\": \"$value\", \"turn\": \"$(date +%s)\", \"source\": \"$source\"}}" "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
    
    echo "[OK] Claim tracked in session state"
    return 0
}

# ============================================================================
# AUTOMATED CJF DETECTION FUNCTIONS (NEW 2026-02-06)
# ============================================================================

# Function: Scan planned response for CJF patterns before sending
llmcjf_scan_response() {
    local response="$1"
    local detected=()
    
    echo "🔍 CJF PATTERN SCAN"
    echo ""
    
    # CJF-09: Format violations in file modifications
    if echo "$response" | grep -q 'modify.*\.dict'; then
        if echo "$response" | grep -qE '"[^"]*"[[:space:]]+#'; then
            detected+=("CJF-09: Inline comments in libFuzzer dict")
        fi
    fi
    
    # CJF-10: Unsolicited documentation
    if echo "${USER_REQUEST:-}" | grep -qi '\(test\|verify\|run\)'; then
        if echo "$response" | grep -qi 'create.*\.md\|write.*guide'; then
            detected+=("CJF-10: Creating docs when user requested test")
        fi
    fi
    
    # CJF-11: Custom test programs
    if echo "$response" | grep -q 'create.*/tmp/.*\.cpp'; then
        if [ -d "Tools/CmdLine" ]; then
            detected+=("CJF-11: Custom test program instead of project tools")
        fi
    fi
    
    # CJF-13: Exit code confusion
    if echo "$response" | grep -qi 'crash\|segv'; then
        if echo "$response" | grep -oP 'exit.*\K[1-9]\d{0,1}(?!\d)' | grep -qv '1[3-9][0-9]' 2>/dev/null; then
            detected+=("CJF-13: Claiming crash with graceful exit code")
        fi
    fi
    
    # Report
    if [ ${#detected[@]} -gt 0 ]; then
        echo "[WARN]  CJF PATTERNS DETECTED:"
        for pattern in "${detected[@]}"; do
            echo "  • $pattern"
        done
        echo ""
        echo "BLOCKING RESPONSE - Correction required"
        return 1
    else
        echo "[OK] No CJF patterns detected"
        return 0
    fi
}

# Function: Validate file modification against format rules and syntax
llmcjf_validate_file_modification() {
    local file="$1"
    local changes="$2"
    
    echo "🔍 FILE MODIFICATION VALIDATION"
    echo "File: $file"
    echo ""
    
    # Detect file type
    case "$file" in
        *.dict)
            echo "Type: libFuzzer dictionary"
            echo "Rules: No inline comments, hex format only"
            
            # Check for inline comments
            if echo "$changes" | grep -qE '"[^"]*"[[:space:]]+#'; then
                echo "[FAIL] CJF-09: Inline comments detected"
                echo "Correct: Comments on separate lines"
                return 1
            fi
            ;;
            
        *.yaml|*.yml)
            echo "Type: YAML"
            echo "Validation: yamllint"
            
            # Syntax check (requires yamllint)
            if command -v yamllint >/dev/null 2>&1; then
                echo "$changes" | yamllint - 2>&1
                if [ $? -ne 0 ]; then
                    echo "[FAIL] CJF-08: YAML syntax broken"
                    return 1
                fi
            else
                echo "[WARN]  yamllint not available, skipping validation"
            fi
            ;;
            
        *.json)
            echo "Type: JSON"
            echo "Validation: jq"
            
            if command -v jq >/dev/null 2>&1; then
                echo "$changes" | jq . >/dev/null 2>&1
                if [ $? -ne 0 ]; then
                    echo "[FAIL] CJF-08: JSON syntax broken"
                    return 1
                fi
            else
                echo "[WARN]  jq not available, skipping validation"
            fi
            ;;
            
        Makefile|*.mk)
            echo "Type: Makefile"
            echo "Validation: make -n"
            echo "[WARN]  Tabs required for recipes"
            ;;
    esac
    
    echo "[OK] Validation passed"
    return 0
}

# Function: Detect intent mismatch (user wants test, agent creates docs)
llmcjf_check_intent_mismatch() {
    local user_request="$1"
    local agent_actions="$2"
    
    echo "🔍 INTENT MISMATCH CHECK"
    echo ""
    
    # Classify user intent
    if echo "$user_request" | grep -qi '\(test\|verify\|run\|check\)'; then
        user_intent="TEST"
        echo "User intent: TEST/VERIFY"
    elif echo "$user_request" | grep -qi '\(document\|explain\|guide\)'; then
        user_intent="DOCUMENT"
        echo "User intent: DOCUMENT"
    else
        user_intent="UNKNOWN"
        echo "User intent: UNKNOWN"
    fi
    
    # Check agent actions
    if echo "$agent_actions" | grep -qi 'create.*\.md\|write.*guide'; then
        agent_intent="DOCUMENT"
        echo "Agent action: Creating documentation"
    else
        agent_intent="ACTION"
        echo "Agent action: Executing task"
    fi
    
    # Detect mismatch
    if [ "$user_intent" = "TEST" ] && [ "$agent_intent" = "DOCUMENT" ]; then
        echo ""
        echo "[WARN]  CJF-10 DETECTED: Intent mismatch"
        echo "User requested: TEST"
        echo "Agent planning: CREATE DOCUMENTATION"
        echo ""
        echo "BLOCKING: Test only, no documentation"
        return 1
    fi
    
    echo ""
    echo "[OK] Intent alignment verified"
    return 0
}

# Function: Verify using project tools, not custom programs
llmcjf_verify_tool_usage() {
    local task="$1"
    local approach="$2"
    
    echo "🔍 TOOL USAGE VERIFICATION"
    echo "Task: $task"
    echo ""
    
    # Check if crash reproduction
    if echo "$task" | grep -qi 'crash\|reproduce\|test.*crash'; then
        echo "Task type: Crash reproduction"
        echo "Required: Use project tools"
        echo ""
        
        # Check for project tools
        if [ -d "Tools/CmdLine" ] || [ -d "Build/Tools" ]; then
            echo "Available project tools:"
            ls Tools/CmdLine/ Build/Tools/ 2>/dev/null | head -5
            echo ""
        fi
        
        # Check if creating custom program
        if echo "$approach" | grep -q '/tmp/.*\.cpp\|custom.*harness'; then
            echo "[WARN]  CJF-11 DETECTED"
            echo "Approach: Creating custom test program"
            echo "Required: Use existing project tools"
            echo ""
            echo "BLOCKING: Use Tools/CmdLine/* or Build/Tools/*"
            return 1
        fi
    fi
    
    echo "[OK] Tool usage verified"
    return 0
}

# Function: Validate crash claims against exit code classification
llmcjf_check_exit_code() {
    local exit_code="$1"
    local claim="$2"
    
    echo "🔍 EXIT CODE CLASSIFICATION"
    echo "Exit code: $exit_code"
    echo "Claim: $claim"
    echo ""
    
    # Classify exit code
    if [ "$exit_code" -ge 128 ]; then
        # Hard crash
        signal=$((exit_code - 128))
        case $signal in
            11) signal_name="SIGSEGV (segmentation fault)" ;;
            6)  signal_name="SIGABRT (abort)" ;;
            8)  signal_name="SIGFPE (floating point exception)" ;;
            *)  signal_name="Signal $signal" ;;
        esac
        
        echo "Classification: HARD CRASH"
        echo "Signal: $signal_name"
        echo ""
        
        if echo "$claim" | grep -qi 'crash\|segv\|overflow'; then
            echo "[OK] Claim consistent with exit code $exit_code"
            return 0
        fi
        
    elif [ "$exit_code" -ge 1 ]; then
        # Soft failure
        echo "Classification: SOFT FAILURE (graceful exit)"
        echo "Not a crash - controlled error handling"
        echo ""
        
        if echo "$claim" | grep -qi 'crash\|segv\|overflow'; then
            echo "[WARN]  CJF-13 DETECTED"
            echo "Claim: Crash/SEGV"
            echo "Reality: Exit $exit_code (graceful failure)"
            echo ""
            echo "BLOCKING: This is NOT a crash"
            return 1
        fi
        
    else
        # Success
        echo "Classification: SUCCESS"
        echo ""
    fi
    
    echo "[OK] Exit code classification verified"
    return 0
}

# Export functions for use in session
export -f llmcjf_status
export -f llmcjf_rules
export -f llmcjf_shame
export -f llmcjf_check
export -f llmcjf_help
export -f llmcjf_refresh

# Export evidence-based validation functions
export -f llmcjf_evidence
export -f llmcjf_verify_claim
export -f llmcjf_session_claims

# Export source citation & uncertainty functions
export -f llmcjf_cite_source
export -f llmcjf_check_uncertainty
export -f llmcjf_track_claim

# Export automated CJF detection functions
export -f llmcjf_scan_response
export -f llmcjf_validate_file_modification
export -f llmcjf_check_intent_mismatch
export -f llmcjf_verify_tool_usage
export -f llmcjf_check_exit_code

# Set environment variables
export LLMCJF_ACTIVE="true"
export LLMCJF_VERSION="3.1"
export LLMCJF_SESSION_START="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
export LLMCJF_GOVERNANCE_ROOT="${LLMCJF_DIR}"
export LLMCJF_AUTOMATION_ACTIVE="true"

# Display initial status
llmcjf_status
echo ""
llmcjf_rules
echo ""

# Critical reminder
echo -e "${RED}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}${BOLD}[WARN]  CRITICAL PATTERN IDENTIFIED${NC}"
echo -e "${RED}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Without governance consultation + real-time surveillance:"
echo -e "${RED}Copilot Service is a LIABILITY${NC}"
echo ""

echo "Evidence (Session 4b1411f6):"
echo "  - Created H016 → Violated H016 (2 min later)"
echo "  - Documented H006/H015 → Violated both (false claim)"
echo "  - Created documentation → Never consulted it"
echo "  - Destroyed 82.3% of file → Claimed success"
echo ""
echo "Pattern: CREATE DOCS → IGNORE DOCS → DESTROY DATA → CLAIM SUCCESS"
echo ""
echo -e "${GREEN}${BOLD}Solution: USE THESE FUNCTIONS BEFORE EVERY ACTION${NC}"
echo "  - llmcjf_check push       (before git push)"
echo "  - llmcjf_check destructive (before file operations)"
echo "  - llmcjf_check claim       (before success claims)"
echo "  - llmcjf_check docs        (before any work)"
echo ""
echo -e "${CYAN}Type 'llmcjf_help' for command reference${NC}"
echo ""

# Final status
echo -e "${GREEN}[OK] LLMCJF Governance Framework Active${NC}"
echo -e "Version: ${LLMCJF_VERSION} | Session: ${LLMCJF_SESSION_START}"
echo ""

# Validate activation (if validator exists and not skipped)
if [[ -z "${SKIP_VALIDATOR:-}" && -f "${LLMCJF_DIR}/scripts/validate-session-init.sh" ]]; then
    source "${LLMCJF_DIR}/scripts/validate-session-init.sh" || true
fi
