#!/bin/bash
# Test: Violation Detection
# Validates violation pattern detection

set -euo pipefail

TEST_NAME="Violation Detection Test"
PASS=0
FAIL=0

echo "=== $TEST_NAME ==="
echo ""

# Test 1: Violation patterns file exists
echo "Test 1: Violation patterns file exists"
if [ -f "$HOME/.copilot/enforcement/violation-patterns.md" ]; then
    echo "  [OK] PASS: File found"
    ((PASS++))
else
    echo "  [FAIL] FAIL: File not found"
    ((FAIL++))
fi

# Test 2: Critical violations documented
echo "Test 2: Critical violations documented"
CRITICAL_COUNT=$(grep -c "V-CRITICAL-" "$HOME/.copilot/enforcement/violation-patterns.md" || true)
if [ "$CRITICAL_COUNT" -ge 3 ]; then
    echo "  [OK] PASS: $CRITICAL_COUNT critical violations documented"
    ((PASS++))
else
    echo "  [FAIL] FAIL: Only $CRITICAL_COUNT critical violations (expected >=3)"
    ((FAIL++))
fi

# Test 3: Fingerprints database exists
echo "Test 3: Fingerprints database exists"
if [ -f "$HOME/.copilot/reports/fingerprints/INDEX.md" ]; then
    echo "  [OK] PASS: Fingerprints database found"
    ((PASS++))
else
    echo "  [FAIL] FAIL: Fingerprints database not found"
    ((FAIL++))
fi

# Test 4: Heuristics file exists
echo "Test 4: Heuristics file exists"
if [ -f "$HOME/.copilot/enforcement/heuristics.yaml" ]; then
    echo "  [OK] PASS: Heuristics file found"
    ((PASS++))
else
    echo "  [FAIL] FAIL: Heuristics file not found"
    ((FAIL++))
fi

# Test 5: Post-mortem reports imported
echo "Test 5: Post-mortem reports imported"
REPORT_COUNT=$(ls -1 "$HOME/.copilot/reports/post-mortems/"*.md 2>/dev/null | wc -l)
if [ "$REPORT_COUNT" -ge 10 ]; then
    echo "  [OK] PASS: $REPORT_COUNT reports found"
    ((PASS++))
else
    echo "  [FAIL] FAIL: Only $REPORT_COUNT reports (expected >=10)"
    ((FAIL++))
fi

# Summary
echo ""
echo "=== Test Summary ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "[OK] ALL TESTS PASSED"
    exit 0
else
    echo "[FAIL] SOME TESTS FAILED"
    exit 1
fi
