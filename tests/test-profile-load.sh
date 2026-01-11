#!/bin/bash
# Test: Profile Loading
# Validates profile loading functionality

set -euo pipefail

TEST_NAME="Profile Load Test"
PASS=0
FAIL=0

echo "=== $TEST_NAME ==="
echo ""

# Test 1: Profile file exists
echo "Test 1: strict-engineering profile exists"
if [ -f "$HOME/.copilot/profiles/strict-engineering.json" ]; then
    echo "  ✅ PASS: Profile file found"
    ((PASS++))
else
    echo "  ❌ FAIL: Profile file not found"
    ((FAIL++))
fi

# Test 2: Profile is valid JSON
echo "Test 2: Profile is valid JSON"
if python3 -c "import json; json.load(open('$HOME/.copilot/profiles/strict-engineering.json'))" 2>/dev/null; then
    echo "  ✅ PASS: Valid JSON"
    ((PASS++))
else
    echo "  ❌ FAIL: Invalid JSON"
    ((FAIL++))
fi

# Test 3: Profile has required fields
echo "Test 3: Profile has required fields"
REQUIRED_FIELDS=("profile" "behavioral_constraints" "code_modification_rules")
FIELDS_OK=true

for field in "${REQUIRED_FIELDS[@]}"; do
    if ! grep -q "\"$field\"" "$HOME/.copilot/profiles/strict-engineering.json"; then
        echo "  ❌ Missing field: $field"
        FIELDS_OK=false
    fi
done

if $FIELDS_OK; then
    echo "  ✅ PASS: All required fields present"
    ((PASS++))
else
    echo "  ❌ FAIL: Missing required fields"
    ((FAIL++))
fi

# Test 4: Load profile script exists
echo "Test 4: Load profile script exists and is executable"
if [ -x "$HOME/.copilot/scripts/load-profile.sh" ]; then
    echo "  ✅ PASS: Script exists and is executable"
    ((PASS++))
else
    echo "  ❌ FAIL: Script missing or not executable"
    ((FAIL++))
fi

# Test 5: Security research profile exists
echo "Test 5: security-research profile exists"
if [ -f "$HOME/.copilot/profiles/security-research.json" ]; then
    echo "  ✅ PASS: Profile file found"
    ((PASS++))
else
    echo "  ❌ FAIL: Profile file not found"
    ((FAIL++))
fi

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
