#!/bin/bash
# LLMCJF Automation Functions Test Suite
# Tests all 11 automation functions for correct behavior
# Usage: ./tests/test-llmcjf-functions.sh
# Exit code: 0 = all tests pass, 1 = failures detected

set -euo pipefail

# Colors for output
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test results array
declare -a FAILED_TESTS=()

# Source the functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}${BOLD}║       LLMCJF Automation Functions Test Suite                  ║${NC}"
echo -e "${BLUE}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Source the session init to get all functions
if [ -f llmcjf-session-init.sh ]; then
    echo -e "${BLUE}Loading LLMCJF functions...${NC}"
    source llmcjf-session-init.sh >/dev/null 2>&1 || {
        echo -e "${RED}Failed to source llmcjf-session-init.sh${NC}"
        exit 1
    }
    echo -e "${GREEN}[OK] Functions loaded${NC}"
    echo ""
else
    echo -e "${RED}Error: llmcjf-session-init.sh not found${NC}"
    exit 1
fi

# Helper functions
assert_exit_code() {
    local expected=$1
    local actual=$2
    local test_name=$3
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ "$actual" -eq "$expected" ]; then
        echo -e "  ${GREEN}[OK] PASS${NC}: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}[FAIL] FAIL${NC}: $test_name (expected exit $expected, got $actual)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$test_name")
        return 1
    fi
}

assert_output_contains() {
    local output="$1"
    local expected="$2"
    local test_name="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if echo "$output" | grep -q "$expected"; then
        echo -e "  ${GREEN}[OK] PASS${NC}: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}[FAIL] FAIL${NC}: $test_name (expected '$expected' in output)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$test_name")
        return 1
    fi
}

# ============================================================================
# TEST GROUP 1: Evidence-Based Validation Functions
# ============================================================================

echo -e "${BOLD}TEST GROUP 1: Evidence-Based Validation Functions${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 1.1: llmcjf_evidence - Basic evidence collection
echo "Test 1.1: llmcjf_evidence - Basic evidence collection"
output=$(llmcjf_evidence "Test claim" "echo 42" 2>&1)
assert_output_contains "$output" "LLMCJF EVIDENCE COLLECTION" "Evidence header present"
assert_output_contains "$output" "Test claim" "Claim recorded"
assert_output_contains "$output" "echo 42" "Command recorded"
assert_output_contains "$output" "42" "Command output captured"
echo ""

# Test 1.2: llmcjf_verify_claim numeric - Count verification
echo "Test 1.2: llmcjf_verify_claim numeric - Count verification"
output=$(llmcjf_verify_claim numeric "test items" "echo 10" 2>&1)
assert_output_contains "$output" "NUMERIC CLAIM VERIFICATION" "Numeric verification header"
assert_output_contains "$output" "10 test items" "Count result shown"
echo ""

# Test 1.3: llmcjf_session_claims - Claim tracking
echo "Test 1.3: llmcjf_session_claims - Claim tracking"
rm -f /tmp/llmcjf-session-claims.log
llmcjf_session_claims add "Test claim 1" "test evidence" >/dev/null 2>&1
output=$(llmcjf_session_claims list 2>&1)
assert_output_contains "$output" "Test claim 1" "Claim stored in session"
assert_output_contains "$output" "test evidence" "Evidence stored"
rm -f /tmp/llmcjf-session-claims.log
echo ""

# ============================================================================
# TEST GROUP 2: Source Citation & Uncertainty Functions
# ============================================================================

echo -e "${BOLD}TEST GROUP 2: Source Citation & Uncertainty Functions${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 2.1: llmcjf_cite_source code - Code reference validation
echo "Test 2.1: llmcjf_cite_source code - Valid file reference"
output=$(llmcjf_cite_source code "README.md:1" 2>&1)
exit_code=$?
assert_exit_code 0 $exit_code "Valid code reference accepted"
assert_output_contains "$output" "SOURCE CITATION VALIDATION" "Citation validation header"
echo ""

# Test 2.2: llmcjf_check_uncertainty - Speculation detection
echo "Test 2.2: llmcjf_check_uncertainty - Detects speculation"
output=$(llmcjf_check_uncertainty "This probably works" 2>&1)
exit_code=$?
assert_exit_code 1 $exit_code "Speculation trigger detected"
assert_output_contains "$output" "SPECULATION DETECTED" "Detection message shown"
assert_output_contains "$output" "[SPECULATIVE]" "Marker suggested"
echo ""

# Test 2.3: llmcjf_track_claim - Session state tracking
echo "Test 2.3: llmcjf_track_claim - Claim tracking without contradiction"
rm -f /tmp/llmcjf-session-state.json
output=$(llmcjf_track_claim "test_entity" "value1" "test source" 2>&1)
exit_code=$?
assert_exit_code 0 $exit_code "First claim tracked successfully"
assert_output_contains "$output" "CLAIM TRACKING" "Tracking header shown"
rm -f /tmp/llmcjf-session-state.json
echo ""

# ============================================================================
# TEST GROUP 3: Automated CJF Detection Functions
# ============================================================================

echo -e "${BOLD}TEST GROUP 3: Automated CJF Detection Functions${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 3.1: llmcjf_scan_response - Clean response
echo "Test 3.1: llmcjf_scan_response - Clean response passes"
output=$(llmcjf_scan_response "This is a clean response without violations" 2>&1)
exit_code=$?
assert_exit_code 0 $exit_code "Clean response accepted"
assert_output_contains "$output" "No CJF patterns detected" "Clean message shown"
echo ""

# Test 3.2: llmcjf_check_intent_mismatch - Aligned intent
echo "Test 3.2: llmcjf_check_intent_mismatch - Aligned intent"
output=$(llmcjf_check_intent_mismatch "Test the fuzzer" "Running fuzzer tests" 2>&1)
exit_code=$?
assert_exit_code 0 $exit_code "Aligned intent accepted"
echo ""

# Test 3.3: llmcjf_check_exit_code - Hard crash (128+)
echo "Test 3.3: llmcjf_check_exit_code - Hard crash classification"
output=$(llmcjf_check_exit_code 139 "segmentation fault" 2>&1)
exit_code=$?
assert_exit_code 0 $exit_code "Hard crash accepted"
assert_output_contains "$output" "HARD CRASH" "Hard crash classification"
assert_output_contains "$output" "SIGSEGV" "Signal identified"
echo ""

# Test 3.4: llmcjf_check_exit_code - Soft failure (1-127) blocks crash claim
echo "Test 3.4: llmcjf_check_exit_code - Soft failure classification"
output=$(llmcjf_check_exit_code 1 "crash" 2>&1)
exit_code=$?
assert_exit_code 1 $exit_code "False crash claim blocked"
assert_output_contains "$output" "CJF-13 DETECTED" "CJF-13 pattern identified"
assert_output_contains "$output" "SOFT FAILURE" "Soft failure classification"
echo ""

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}TEST SUMMARY${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "Tests run:    ${BOLD}$TESTS_RUN${NC}"
echo -e "Tests passed: ${GREEN}${BOLD}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}${BOLD}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}${BOLD}[OK] ALL TESTS PASSED${NC}"
    echo ""
    echo "Functions tested (11 total):"
    echo "  [OK] llmcjf_evidence (evidence collection)"
    echo "  [OK] llmcjf_verify_claim (numeric)"
    echo "  [OK] llmcjf_session_claims (claim tracking)"
    echo "  [OK] llmcjf_cite_source (code citations)"
    echo "  [OK] llmcjf_check_uncertainty (speculation detection)"
    echo "  [OK] llmcjf_track_claim (contradiction detection)"
    echo "  [OK] llmcjf_scan_response (CJF pattern scanning)"
    echo "  [OK] llmcjf_check_intent_mismatch (TEST vs DOCUMENT)"
    echo "  [OK] llmcjf_check_exit_code (crash classification)"
    echo ""
    exit 0
else
    echo -e "${RED}${BOLD}[FAIL] TESTS FAILED${NC}"
    echo ""
    echo "Failed tests:"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "  ${RED}•${NC} $test"
    done
    echo ""
    exit 1
fi
