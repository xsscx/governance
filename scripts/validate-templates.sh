#!/bin/bash
# Template Enforcement Linter
# Validates that agent responses use required templates for specific actions
# Usage: validate-templates.sh <response-file> [--strict]

set -uo pipefail  # Removed -e to allow controlled error handling

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="${SCRIPT_DIR}/../templates"
RESPONSE_FILE="${1:-}"
STRICT_MODE="${2:-}"

# Color codes (ASCII-only compatible)
RED="[RED]"
GREEN="[OK]"
YELLOW="[WARN]"
BLUE="[INFO]"

# Exit codes
EXIT_SUCCESS=0
EXIT_TEMPLATE_MISSING=1
EXIT_INVALID_FORMAT=2
EXIT_USAGE=3

usage() {
    cat <<EOF
Template Enforcement Linter

Usage: validate-templates.sh <response-file> [--strict]

Arguments:
  response-file    File containing agent response text
  --strict         Enforce all template requirements (exit on any violation)

Examples:
  validate-templates.sh response.txt
  validate-templates.sh response.txt --strict

Exit Codes:
  0 - All templates used correctly
  1 - Required template missing
  2 - Template format invalid
  3 - Usage error
EOF
}

# Check if response file provided
if [ -z "$RESPONSE_FILE" ] || [ ! -f "$RESPONSE_FILE" ]; then
    usage
    exit $EXIT_USAGE
fi

# Detection functions
detect_file_edit() {
    # Detect file edit operations - look for File: header OR edit-related keywords
    grep -qiE "^File:|edited|modified|updated.*file|created.*file|\bedit\b.*\.(c|h|cpp|py|sh|md|txt|yaml|json)" "$1"
}

detect_verification() {
    # Detect verification operations
    grep -qE "(Verification:|Expected:|Actual:|Status:.*PASS|Status:.*FAIL)" "$1"
}

detect_tool_failure() {
    # Detect tool failures
    grep -qE "(Tool:.*FAILED|Result:.*error|exit code [^0]|command not found)" "$1"
}

detect_user_correction() {
    # Detect responses to user corrections
    grep -qE "(Acknowledged:|Re-verifying:|Confirmed:|user.*observation)" "$1"
}

# Template validation functions
validate_file_edit_template() {
    local file="$1"
    local errors=0
    
    echo "$BLUE Validating file_edit_response.txt template..."
    
    # Required fields
    if ! grep -qi "^File:" "$file"; then
        echo "$RED Missing required field: File:"
        errors=$((errors + 1))
    fi
    
    if ! grep -qi "^Location: Line" "$file"; then
        echo "$RED Missing required field: Location: Line [start]-[end]"
        errors=$((errors + 1))
    fi
    
    if ! grep -qi "^Action:" "$file"; then
        echo "$RED Missing required field: Action:"
        errors=$((errors + 1))
    fi
    
    if ! grep -qi "^Edit result:" "$file"; then
        echo "$RED Missing required field: Edit result:"
        errors=$((errors + 1))
    fi
    
    if ! grep -qi "^Verification:" "$file"; then
        echo "$RED Missing required field: Verification:"
        errors=$((errors + 1))
    fi
    
    if ! grep -qi "^Status:" "$file"; then
        echo "$RED Missing required field: Status:"
        errors=$((errors + 1))
    fi
    
    if [ $errors -eq 0 ]; then
        echo "$GREEN All required fields present"
    fi
    
    return $errors
}

validate_verification_template() {
    local file="$1"
    local errors=0
    
    echo "$BLUE Validating verification_response.txt template..."
    
    # Required fields
    if ! grep -qi "^Verification:" "$file"; then
        echo "$RED Missing required field: Verification:"
        errors=$((errors + 1))
    fi
    
    if ! grep -qi "^Command:" "$file"; then
        echo "$RED Missing required field: Command:"
        errors=$((errors + 1))
    fi
    
    if ! grep -qi "^Expected:" "$file"; then
        echo "$RED Missing required field: Expected:"
        errors=$((errors + 1))
    fi
    
    if ! grep -qi "^Actual:" "$file"; then
        echo "$RED Missing required field: Actual:"
        errors=$((errors + 1))
    fi
    
    if ! grep -qiE "^Status:.*(PASS|FAIL)" "$file"; then
        echo "$RED Missing or invalid Status field (must be PASS or FAIL)"
        errors=$((errors + 1))
    fi
    
    if [ $errors -eq 0 ]; then
        echo "$GREEN All required fields present"
    fi
    
    return $errors
}

validate_tool_failure_template() {
    local file="$1"
    local errors=0
    
    echo "$BLUE Validating tool_failure_response.txt template..."
    
    # Required fields
    if ! grep -qi "^Tool:" "$file"; then
        echo "$RED Missing required field: Tool:"
        errors=$((errors + 1))
    fi
    
    if ! grep -qi "^Command:" "$file"; then
        echo "$RED Missing required field: Command:"
        errors=$((errors + 1))
    fi
    
    if ! grep -qi "^Result:" "$file"; then
        echo "$RED Missing required field: Result:"
        errors=$((errors + 1))
    fi
    
    if ! grep -qi "^Status: FAILED" "$file"; then
        echo "$RED Missing required field: Status: FAILED"
        errors=$((errors + 1))
    fi
    
    if ! grep -qi "^Investigation:" "$file"; then
        echo "$RED Missing required field: Investigation:"
        errors=$((errors + 1))
    fi
    
    if [ $errors -eq 0 ]; then
        echo "$GREEN All required fields present"
    fi
    
    return $errors
}

validate_user_correction_template() {
    local file="$1"
    local errors=0
    
    echo "$BLUE Validating user_correction_response.txt template..."
    
    # Required fields
    if ! grep -qi "^Acknowledged:" "$file"; then
        echo "$RED Missing required field: Acknowledged:"
        errors=$((errors + 1))
    fi
    
    if ! grep -qi "^Re-verifying:" "$file"; then
        echo "$RED Missing required field: Re-verifying:"
        errors=$((errors + 1))
    fi
    
    if ! grep -qi "^Confirmed:" "$file"; then
        echo "$RED Missing required field: Confirmed:"
        errors=$((errors + 1))
    fi
    
    if [ $errors -eq 0 ]; then
        echo "$GREEN All required fields present"
    fi
    
    return $errors
}

# Main validation logic
main() {
    local total_errors=0
    local templates_detected=0
    
    echo "$BLUE Template Enforcement Linter"
    echo "$BLUE Response file: $RESPONSE_FILE"
    echo ""
    
    # Detect which templates should be used
    if detect_file_edit "$RESPONSE_FILE"; then
        echo "$BLUE Detected: File edit operation"
        ((templates_detected++))
        validate_file_edit_template "$RESPONSE_FILE" || total_errors=$?
        echo ""
    fi
    
    if detect_verification "$RESPONSE_FILE"; then
        echo "$BLUE Detected: Verification operation"
        ((templates_detected++))
        validate_verification_template "$RESPONSE_FILE" || total_errors=$((total_errors + $?))
        echo ""
    fi
    
    if detect_tool_failure "$RESPONSE_FILE"; then
        echo "$BLUE Detected: Tool failure"
        ((templates_detected++))
        validate_tool_failure_template "$RESPONSE_FILE" || total_errors=$((total_errors + $?))
        echo ""
    fi
    
    if detect_user_correction "$RESPONSE_FILE"; then
        echo "$BLUE Detected: User correction response"
        ((templates_detected++))
        validate_user_correction_template "$RESPONSE_FILE" || total_errors=$((total_errors + $?))
        echo ""
    fi
    
    # Summary
    echo "========================================"
    echo "Summary:"
    echo "  Templates detected: $templates_detected"
    echo "  Template errors: $total_errors"
    
    if [ $templates_detected -eq 0 ]; then
        echo "$YELLOW No templates detected (response may not require templates)"
        exit $EXIT_SUCCESS
    fi
    
    if [ $total_errors -eq 0 ]; then
        echo "$GREEN All required template fields present"
        exit $EXIT_SUCCESS
    else
        echo "$RED Template validation FAILED ($total_errors errors)"
        if [ "$STRICT_MODE" = "--strict" ]; then
            exit $EXIT_INVALID_FORMAT
        else
            echo "$YELLOW Running in permissive mode (use --strict to enforce)"
            exit $EXIT_SUCCESS
        fi
    fi
}

main "$@"
