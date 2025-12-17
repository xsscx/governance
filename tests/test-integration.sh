#!/bin/bash
# Integration Tests for LLMCJF Automation Functions
# Tests multi-function workflows and realistic scenarios
# Usage: ./tests/test-integration.sh

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
declare -a FAILED_TESTS=()

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}${BOLD}║       LLMCJF Integration Test Suite                           ║${NC}"
echo -e "${BLUE}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Source functions
if [ -f llmcjf-session-init.sh ]; then
    source llmcjf-session-init.sh >/dev/null 2>&1
    echo -e "${GREEN}[OK] Functions loaded${NC}"
    echo ""
else
    echo -e "${RED}Error: llmcjf-session-init.sh not found${NC}"
    exit 1
fi

# Helper
pass_test() {
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "  ${GREEN}[OK] PASS${NC}: $1"
}

fail_test() {
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_TESTS+=("$1")
    echo -e "  ${RED}[FAIL] FAIL${NC}: $1"
}

# ============================================================================
# INTEGRATION TEST 1: Complete Numeric Claim Workflow
# ============================================================================

echo -e "${BOLD}INTEGRATION TEST 1: Complete Numeric Claim Workflow${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Scenario: Count dictionary entries with full workflow"
echo "  1. Check governance before claiming (llmcjf_check)"
echo "  2. Collect evidence (llmcjf_evidence)"
echo "  3. Verify claim (llmcjf_verify_claim numeric)"
echo "  4. Cite source (llmcjf_cite_source tool)"
echo "  5. Track claim (llmcjf_track_claim)"
echo ""

# Step 1: Governance check (should return 1, but that's expected)
llmcjf_check claim >/dev/null 2>&1 || true

# Step 2: Collect evidence
rm -f /tmp/test-dict.txt
echo '"entry1"' > /tmp/test-dict.txt
echo '"entry2"' > /tmp/test-dict.txt
echo '"entry3"' > /tmp/test-dict.txt

evidence_output=$(llmcjf_evidence "Dictionary has N entries" "grep -c '^\"' /tmp/test-dict.txt" 2>&1)
if echo "$evidence_output" | grep -q "Exit Code: 0"; then
    pass_test "Evidence collection successful"
else
    fail_test "Evidence collection failed"
fi

# Step 3: Verify claim
verify_output=$(llmcjf_verify_claim numeric "dictionary entries" "grep -c '^\"' /tmp/test-dict.txt" 2>&1)
if echo "$verify_output" | grep -q "3 dictionary entries"; then
    pass_test "Numeric verification correct (3 entries)"
else
    fail_test "Numeric verification incorrect"
fi

# Step 4: Cite source
cite_output=$(llmcjf_cite_source tool "grep -c '^\"' /tmp/test-dict.txt → 3" 2>&1)
if [ $? -eq 0 ]; then
    pass_test "Source citation accepted"
else
    fail_test "Source citation failed"
fi

# Step 5: Track claim
rm -f /tmp/llmcjf-session-state.json
track_output=$(llmcjf_track_claim "test_dict_entries" "3" "grep -c" 2>&1)
if [ $? -eq 0 ]; then
    pass_test "Claim tracked in session state"
else
    fail_test "Claim tracking failed"
fi

rm -f /tmp/test-dict.txt /tmp/llmcjf-session-state.json
echo ""

# ============================================================================
# INTEGRATION TEST 2: Contradiction Detection Workflow
# ============================================================================

echo -e "${BOLD}INTEGRATION TEST 2: Contradiction Detection Workflow${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Scenario: Track claim, then detect contradiction"
echo ""

# Initialize clean state
rm -f /tmp/llmcjf-session-state.json

# Track first claim
llmcjf_track_claim "file_count" "10" "ls | wc -l" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    pass_test "First claim tracked (file_count=10)"
else
    fail_test "First claim tracking failed"
fi

# Attempt contradictory claim (should fail with exit 1)
output=$(llmcjf_track_claim "file_count" "20" "ls | wc -l" 2>&1)
if [ $? -eq 1 ] && echo "$output" | grep -q "CONTRADICTION DETECTED"; then
    pass_test "Contradiction detected (10 vs 20)"
else
    fail_test "Contradiction not detected"
fi

rm -f /tmp/llmcjf-session-state.json
echo ""

# ============================================================================
# INTEGRATION TEST 3: CJF-13 Exit Code Classification Workflow
# ============================================================================

echo -e "${BOLD}INTEGRATION TEST 3: CJF-13 Exit Code Classification${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Scenario: Test tool, classify exit code, verify crash claim"
echo ""

# Simulate tool test with soft failure
echo "#!/bin/bash" > /tmp/test-tool.sh
echo "echo 'ERROR: Invalid input'" >> /tmp/test-tool.sh
echo "exit 1" >> /tmp/test-tool.sh
chmod +x /tmp/test-tool.sh

# Run tool
/tmp/test-tool.sh >/dev/null 2>&1
exit_code=$?

# Classify exit code
classify_output=$(llmcjf_check_exit_code $exit_code "crash" 2>&1)
if [ $? -eq 1 ] && echo "$classify_output" | grep -q "CJF-13 DETECTED"; then
    pass_test "Exit 1 correctly classified as soft failure (not crash)"
else
    fail_test "Exit code classification failed"
fi

# Test hard crash classification (SIGSEGV = 139)
classify_output=$(llmcjf_check_exit_code 139 "segmentation fault" 2>&1)
if [ $? -eq 0 ] && echo "$classify_output" | grep -q "HARD CRASH"; then
    pass_test "Exit 139 correctly classified as hard crash (SIGSEGV)"
else
    fail_test "Hard crash classification failed"
fi

rm -f /tmp/test-tool.sh
echo ""

# ============================================================================
# INTEGRATION TEST 4: Speculation Detection Workflow
# ============================================================================

echo -e "${BOLD}INTEGRATION TEST 4: Speculation Detection Workflow${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Scenario: Detect speculation, suggest marker, verify compliance"
echo ""

# Test speculation trigger
spec_output=$(llmcjf_check_uncertainty "This probably improves coverage" 2>&1)
if [ $? -eq 1 ] && echo "$spec_output" | grep -q "[SPECULATIVE]"; then
    pass_test "Speculation detected, [SPECULATIVE] marker suggested"
else
    fail_test "Speculation detection failed"
fi

# Test clean text (no speculation)
spec_output=$(llmcjf_check_uncertainty "Coverage increased to 85%" 2>&1)
if [ $? -eq 0 ]; then
    pass_test "Clean factual text accepted (no speculation)"
else
    fail_test "False positive: Factual text flagged as speculation"
fi

echo ""

# ============================================================================
# INTEGRATION TEST 5: Intent Mismatch Detection (CJF-10)
# ============================================================================

echo -e "${BOLD}INTEGRATION TEST 5: Intent Mismatch Detection (CJF-10)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Scenario: User requests test, detect if agent creates documentation"
echo ""

# Test mismatch (user wants test, agent creates docs)
intent_output=$(llmcjf_check_intent_mismatch "Test the fuzzer" "Create fuzzer documentation guide" 2>&1)
if [ $? -eq 1 ] && echo "$intent_output" | grep -q "CJF-10 DETECTED"; then
    pass_test "Intent mismatch detected (TEST vs DOCUMENT)"
else
    fail_test "Intent mismatch not detected"
fi

# Test aligned intent
intent_output=$(llmcjf_check_intent_mismatch "Test the fuzzer" "Running fuzzer with test corpus" 2>&1)
if [ $? -eq 0 ]; then
    pass_test "Aligned intent accepted (TEST → TEST)"
else
    fail_test "False positive: Aligned intent rejected"
fi

echo ""

# ============================================================================
# INTEGRATION TEST 6: Full Session Workflow
# ============================================================================

echo -e "${BOLD}INTEGRATION TEST 6: Complete Session Workflow${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Scenario: Realistic session with multiple claims and verifications"
echo ""

# Clean session state
rm -f /tmp/llmcjf-session-state.json /tmp/llmcjf-session-claims.log

# Claim 1: Count files
mkdir -p /tmp/test-session
touch /tmp/test-session/file{1,2,3}.txt
count=$(ls /tmp/test-session/*.txt 2>/dev/null | wc -l)
llmcjf_track_claim "test_files" "$count" "ls /tmp/test-session/*.txt | wc -l" >/dev/null 2>&1
llmcjf_session_claims add "Test session has $count files" "ls | wc -l" >/dev/null 2>&1

# Claim 2: Verify consistency
llmcjf_session_claims check "Test session" >/dev/null 2>&1
if [ -f /tmp/llmcjf-session-claims.log ]; then
    pass_test "Session claims tracked across multiple operations"
else
    fail_test "Session claims not persisted"
fi

# Verify state consistency
if [ -f /tmp/llmcjf-session-state.json ]; then
    pass_test "Session state persisted to JSON"
else
    fail_test "Session state not persisted"
fi

# Cleanup
rm -rf /tmp/test-session /tmp/llmcjf-session-state.json /tmp/llmcjf-session-claims.log

echo ""

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}INTEGRATION TEST SUMMARY${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "Tests run:    ${BOLD}$TESTS_RUN${NC}"
echo -e "Tests passed: ${GREEN}${BOLD}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}${BOLD}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}${BOLD}[OK] ALL INTEGRATION TESTS PASSED${NC}"
    echo ""
    echo "Workflows tested:"
    echo "  [OK] Complete numeric claim workflow (5 steps)"
    echo "  [OK] Contradiction detection workflow"
    echo "  [OK] CJF-13 exit code classification"
    echo "  [OK] Speculation detection workflow"
    echo "  [OK] Intent mismatch detection (CJF-10)"
    echo "  [OK] Full session workflow with persistence"
    echo ""
    exit 0
else
    echo -e "${RED}${BOLD}[FAIL] INTEGRATION TESTS FAILED${NC}"
    echo ""
    echo "Failed tests:"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "  ${RED}•${NC} $test"
    done
    echo ""
    exit 1
fi
