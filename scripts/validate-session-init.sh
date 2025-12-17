#!/bin/bash
# LLMCJF Session Initialization Validator
# Verifies that llmcjf-session-init.sh loaded successfully
# Usage: source llmcjf-session-init.sh && source llmcjf/scripts/validate-session-init.sh
# Or: Called automatically after sourcing llmcjf-session-init.sh

set -uo pipefail  # Don't use -e to allow controlled error handling

# Colors (ASCII fallback) - only set if not already defined
[[ -z "${RED:-}" ]] && RED="[RED]"
[[ -z "${GREEN:-}" ]] && GREEN="[OK]"
[[ -z "${YELLOW:-}" ]] && YELLOW="[WARN]"
[[ -z "${BLUE:-}" ]] && BLUE="[INFO]"

# Expected functions that MUST be loaded
REQUIRED_FUNCTIONS=(
    "llmcjf_check"
    "llmcjf_status"
    "llmcjf_rules"
    "llmcjf_help"
    "llmcjf_verify_claim"
    "llmcjf_track_claim"
    "llmcjf_scan_response"
)

# Expected environment variables
REQUIRED_ENV_VARS=(
    "LLMCJF_ACTIVE"
    "LLMCJF_VERSION"
    "LLMCJF_SESSION_START"
)

# Session log directory
SESSION_LOG_DIR="$HOME/.copilot/session-state/logs"
SESSION_LOG_FILE="$SESSION_LOG_DIR/llmcjf-activation-$(date +%Y%m%d-%H%M%S).log"

# Exit codes
EXIT_SUCCESS=0
EXIT_FUNCTION_MISSING=1
EXIT_ENV_VAR_MISSING=2
EXIT_VALIDATOR_MISSING=3
EXIT_AUDIT_FAILED=4

# Validation results
validation_errors=0
validation_warnings=0

# Create log directory if it doesn't exist
mkdir -p "$SESSION_LOG_DIR" 2>/dev/null || true

# Function: Log to both stdout and file
log() {
    local message="$1"
    echo -e "$message" | tee -a "$SESSION_LOG_FILE" >/dev/null 2>&1 || echo -e "$message"
}

# Function: Check if function exists
function_exists() {
    declare -f "$1" >/dev/null 2>&1
}

# Function: Check if environment variable is set
env_var_exists() {
    [[ -n "${!1:-}" ]]
}

# Banner
log ""
log "========================================"
log "  LLMCJF Activation Validator"
log "========================================"
log ""
log "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
log "Log file: $SESSION_LOG_FILE"
log ""

# Step 1: Verify required functions are loaded
log "$BLUE Checking required functions..."
log ""

for func in "${REQUIRED_FUNCTIONS[@]}"; do
    if function_exists "$func"; then
        log "  $GREEN $func - loaded"
    else
        log "  $RED $func - MISSING"
        validation_errors=$((validation_errors + 1))
    fi
done

log ""

# Step 2: Verify required environment variables are set
log "$BLUE Checking environment variables..."
log ""

for var in "${REQUIRED_ENV_VARS[@]}"; do
    if env_var_exists "$var"; then
        log "  $GREEN $var = ${!var}"
    else
        log "  $RED $var - NOT SET"
        validation_errors=$((validation_errors + 1))
    fi
done

log ""

# Step 3: Check for YAML validator (python3 or yq)
log "$BLUE Checking YAML validator availability..."
log ""

HAS_PYTHON3=false
HAS_YQ=false

if command -v python3 >/dev/null 2>&1; then
    if python3 -c "import yaml" 2>/dev/null; then
        log "  $GREEN python3 + PyYAML - available"
        HAS_PYTHON3=true
    else
        log "  $YELLOW python3 found, but PyYAML not installed"
        log "          Install: pip install pyyaml"
        validation_warnings=$((validation_warnings + 1))
    fi
else
    log "  $YELLOW python3 - not found"
fi

if command -v yq >/dev/null 2>&1; then
    log "  $GREEN yq - available"
    HAS_YQ=true
else
    log "  $YELLOW yq - not found"
fi

if [[ "$HAS_PYTHON3" == false && "$HAS_YQ" == false ]]; then
    log "  $RED NO YAML validator available"
    log "  $RED Governance YAML files cannot be validated"
    log "  $RED RECOMMENDATION: Install python3 + PyYAML OR yq"
    validation_errors=$((validation_errors + 1))
fi

log ""

# Step 4: Test a sample function call
log "$BLUE Testing function execution..."
log ""

if function_exists llmcjf_check; then
    # Capture output to avoid cluttering the terminal
    if llmcjf_check docs >/dev/null 2>&1; then
        log "  $GREEN llmcjf_check docs - executed successfully"
    else
        log "  $YELLOW llmcjf_check docs - executed but returned non-zero"
        validation_warnings=$((validation_warnings + 1))
    fi
else
    log "  $RED llmcjf_check - not available for testing"
    validation_errors=$((validation_errors + 1))
fi

log ""

# Step 5: Record acknowledgment state
log "$BLUE Recording acknowledgment state..."
log ""

ACKNOWLEDGMENT_FILE="$HOME/.copilot/session-state/llmcjf-acknowledged-$(date +%Y%m%d).state"

cat > "$ACKNOWLEDGMENT_FILE" <<EOF
# LLMCJF Governance Framework Acknowledgment
# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)

timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
version: ${LLMCJF_VERSION:-unknown}
functions_loaded: ${#REQUIRED_FUNCTIONS[@]}
validation_errors: $validation_errors
validation_warnings: $validation_warnings
yaml_validator: $(if [[ "$HAS_PYTHON3" == true ]]; then echo "python3+PyYAML"; elif [[ "$HAS_YQ" == true ]]; then echo "yq"; else echo "NONE"; fi)
session_log: $SESSION_LOG_FILE

# Loaded functions:
$(for func in "${REQUIRED_FUNCTIONS[@]}"; do
    if function_exists "$func"; then
        echo "  - $func: loaded"
    else
        echo "  - $func: MISSING"
    fi
done)

# Environment variables:
$(for var in "${REQUIRED_ENV_VARS[@]}"; do
    if env_var_exists "$var"; then
        echo "  - $var: ${!var}"
    else
        echo "  - $var: NOT SET"
    fi
done)

# Validation result:
status: $(if [[ $validation_errors -eq 0 ]]; then echo "PASS"; else echo "FAIL"; fi)
EOF

log "  $GREEN Acknowledgment recorded: $ACKNOWLEDGMENT_FILE"
log ""

# Step 6: Display summary
log "========================================"
log "  Validation Summary"
log "========================================"
log ""
log "Functions checked:     ${#REQUIRED_FUNCTIONS[@]}"
log "Environment variables: ${#REQUIRED_ENV_VARS[@]}"
log "Errors:                $validation_errors"
log "Warnings:              $validation_warnings"
log ""

if [[ $validation_errors -eq 0 ]]; then
    log "$GREEN =========================================="
    log "$GREEN  LLMCJF ACTIVATION VERIFIED"
    log "$GREEN =========================================="
    log ""
    log "All required functions and environment variables loaded."
    log "Governance framework is ACTIVE and ready for use."
    log ""
    log "Available commands:"
    log "  llmcjf_check <action>  - Pre-action validation"
    log "  llmcjf_status          - Show governance metrics"
    log "  llmcjf_help            - Command reference"
    log ""
    return $EXIT_SUCCESS
else
    log "$RED =========================================="
    log "$RED  LLMCJF ACTIVATION FAILED"
    log "$RED =========================================="
    log ""
    log "Errors detected: $validation_errors"
    log "Governance framework activation INCOMPLETE."
    log ""
    log "Action required:"
    log "  1. Check that llmcjf-session-init.sh sourced correctly"
    log "  2. Verify llmcjf/ directory structure is intact"
    log "  3. Re-run: source llmcjf/llmcjf-session-init.sh"
    log ""
    log "If problems persist, see:"
    log "  llmcjf/SESSION_INIT_GUIDE.md"
    log "  llmcjf/CANONICAL_QUICK_START.md"
    log ""
    return $EXIT_FUNCTION_MISSING
fi
