#!/bin/bash
# Automated Governance Compliance Testing

echo "=========================================="
echo "  Governance Framework Automation Test"
echo "=========================================="
echo ""

PASSED=0
FAILED=0

# Test 1: Good response with test output
echo "[TEST 1] Good response with test output"
if python3 .copilot-sessions/governance/compliance-checker.py /tmp/test_response_good.txt --has-test-output > /tmp/test1.out 2>&1; then
    echo "  RESULT: PASS ✓"
    PASSED=$((PASSED + 1))
else
    echo "  RESULT: FAIL ✗"
    FAILED=$((FAILED + 1))
fi
cat /tmp/test1.out | grep "Score:"
echo ""

# Test 2: Bad response without test output
echo "[TEST 2] Bad response without test output"
if python3 .copilot-sessions/governance/compliance-checker.py /tmp/test_response_bad.txt > /tmp/test2.out 2>&1; then
    echo "  RESULT: FAIL (should have failed) ✗"
    FAILED=$((FAILED + 1))
else
    echo "  RESULT: PASS (correctly rejected) ✓"
    PASSED=$((PASSED + 1))
fi
cat /tmp/test2.out | grep "Score:"
cat /tmp/test2.out | grep "Violations Found:"
echo ""

# Test 3: V013 actual violation
echo "[TEST 3] Simulate V013 violation"
cat > /tmp/test_v013.txt << 'VEOF'
I've successfully removed all unicode characters from the source files.
The build completed successfully and the binary has been updated.
VEOF

if python3 .copilot-sessions/governance/compliance-checker.py /tmp/test_v013.txt > /tmp/test3.out 2>&1; then
    echo "  RESULT: FAIL (should detect violation) ✗"
    FAILED=$((FAILED + 1))
else
    echo "  RESULT: PASS (violation detected) ✓"
    PASSED=$((PASSED + 1))
fi
cat /tmp/test3.out | grep "MANDATORY-TEST-OUTPUT"
echo ""

# Test 4: Evidence-based response
echo "[TEST 4] Evidence-based response (compliant)"
cat > /tmp/test_evidence.txt << 'EEOF'
$ Build/Tools/IccDumpProfile/iccDumpProfile test.icc
Profile Class: InputClass
PCS Color Space: XYZData
EXIT 0
EEOF

if python3 .copilot-sessions/governance/compliance-checker.py /tmp/test_evidence.txt --has-test-output > /tmp/test4.out 2>&1; then
    echo "  RESULT: PASS ✓"
    PASSED=$((PASSED + 1))
else
    echo "  RESULT: FAIL ✗"
    FAILED=$((FAILED + 1))
fi
cat /tmp/test4.out | grep "Score:"
echo ""

# Summary
echo "=========================================="
echo "  Test Summary"
echo "=========================================="
echo "  Passed: $PASSED"
echo "  Failed: $FAILED"
echo "  Total:  $((PASSED + FAILED))"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "  Status: ALL TESTS PASSED ✓"
    exit 0
else
    echo "  Status: SOME TESTS FAILED ✗"
    exit 1
fi
