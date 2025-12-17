#!/bin/bash
# Test Suite Runner
# Runs all governance tests

set -euo pipefail

echo "======================================"
echo "Copilot Governance Test Suite"
echo "======================================"
echo ""

TOTAL_PASS=0
TOTAL_FAIL=0

# Run all tests
for test in "$HOME/.copilot/tests/test-"*.sh; do
    if [ -x "$test" ]; then
        echo "Running: $(basename $test)"
        if bash "$test"; then
            ((TOTAL_PASS++))
        else
            ((TOTAL_FAIL++))
        fi
        echo ""
        echo "--------------------------------------"
        echo ""
    fi
done

# Final summary
echo "======================================"
echo "Final Test Summary"
echo "======================================"
echo "Test Suites Passed: $TOTAL_PASS"
echo "Test Suites Failed: $TOTAL_FAIL"
echo ""

if [ $TOTAL_FAIL -eq 0 ]; then
    echo "✅ ALL TEST SUITES PASSED"
    exit 0
else
    echo "❌ SOME TEST SUITES FAILED"
    exit 1
fi
