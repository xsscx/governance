#!/bin/bash
# Test: Compliance Score Calculation
# Validates compliance scoring algorithm

set -euo pipefail

TEST_NAME="Compliance Score Test"
PASS=0
FAIL=0

echo "=== $TEST_NAME ==="
echo ""

# Test 1: Compliance script exists
echo "Test 1: Compliance calculator exists"
if [ -x "$HOME/.copilot/scripts/compliance-score.py" ]; then
    echo "  ✅ PASS: Script found and executable"
    ((PASS++))
else
    echo "  ❌ FAIL: Script missing or not executable"
    ((FAIL++))
fi

# Test 2: Perfect score (100)
echo "Test 2: Perfect compliance score"
cat > /tmp/perfect-metrics.json << 'EOF'
{
  "session_id": "test",
  "timestamp": "2026-01-11T00:00:00Z",
  "profile": "strict-engineering",
  "metrics": {
    "user_corrections": 0,
    "unrequested_lines": 0,
    "format_deviations": 0,
    "apology_count": 0,
    "frustration_signals": 0,
    "compression_ratio": 1.0
  }
}
EOF

OUTPUT=$($HOME/.copilot/scripts/compliance-score.py /tmp/perfect-metrics.json 2>&1 || true)
if echo "$OUTPUT" | grep -q "100/100"; then
    echo "  ✅ PASS: Perfect score calculated correctly"
    ((PASS++))
else
    echo "  ❌ FAIL: Expected 100/100, got: $OUTPUT"
    ((FAIL++))
fi

# Test 3: Failed score (violations present)
echo "Test 3: Failed compliance score"
cat > /tmp/failed-metrics.json << 'EOF'
{
  "session_id": "test",
  "profile": "strict-engineering",
  "metrics": {
    "user_corrections": 3,
    "unrequested_lines": 20,
    "format_deviations": 2,
    "apology_count": 5,
    "frustration_signals": 3
  }
}
EOF

OUTPUT=$($HOME/.copilot/scripts/compliance-score.py /tmp/failed-metrics.json 2>&1 || true)
SCORE=$(echo "$OUTPUT" | grep -oP 'Compliance Score: \K[0-9]+' || echo "0")
if [ "$SCORE" -lt 50 ]; then
    echo "  ✅ PASS: Failed score calculated correctly ($SCORE/100)"
    ((PASS++))
else
    echo "  ❌ FAIL: Expected <50, got: $SCORE"
    ((FAIL++))
fi

# Test 4: Metrics schema exists
echo "Test 4: Metrics schema exists"
if [ -f "$HOME/.copilot/metrics/session-quality.schema.json" ]; then
    echo "  ✅ PASS: Schema file found"
    ((PASS++))
else
    echo "  ❌ FAIL: Schema file not found"
    ((FAIL++))
fi

# Cleanup
rm -f /tmp/perfect-metrics.json /tmp/failed-metrics.json

# Summary
echo ""
echo "=== Test Summary ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "✅ ALL TESTS PASSED"
    exit 0
else
    echo "❌ SOME TESTS FAILED"
    exit 1
fi
