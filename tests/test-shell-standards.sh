#!/bin/bash
# Test: Shell Prologue Standards
# Validates shell prologue compliance checking

set -euo pipefail

TEST_NAME="Shell Prologue Standards Test"
PASS=0
FAIL=0

echo "=== $TEST_NAME ==="
echo ""

# Setup: Create test workflow files
TEST_DIR="/tmp/copilot-test-$$"
mkdir -p "$TEST_DIR/.github/workflows"

# Test 1: Checker script exists
echo "Test 1: Shell prologue checker exists"
if [ -x "$HOME/.copilot/scripts/check-shell-prologue.sh" ]; then
    echo "  ✅ PASS: Checker script found and executable"
    ((PASS++))
else
    echo "  ❌ FAIL: Checker script missing or not executable"
    ((FAIL++))
fi

# Test 2: Detect compliant workflow
echo "Test 2: Detect compliant bash prologue"
cat > "$TEST_DIR/.github/workflows/compliant.yml" << 'EOF'
name: Test
on: push
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Test
        shell: bash --noprofile --norc {0}
        env:
          BASH_ENV: /dev/null
        run: |
          set -euo pipefail
          echo "test"
EOF

cd "$TEST_DIR"
if $HOME/.copilot/scripts/check-shell-prologue.sh 2>/dev/null; then
    echo "  ✅ PASS: Compliant workflow detected correctly"
    ((PASS++))
else
    echo "  ❌ FAIL: Compliant workflow flagged as violation"
    ((FAIL++))
fi

# Test 3: Detect non-compliant workflow
echo "Test 3: Detect non-compliant bash prologue"
cat > "$TEST_DIR/.github/workflows/non-compliant.yml" << 'EOF'
name: Test
on: push
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Test
        shell: bash
        run: echo "test"
EOF

cd "$TEST_DIR"
if ! $HOME/.copilot/scripts/check-shell-prologue.sh 2>/dev/null; then
    echo "  ✅ PASS: Non-compliant workflow detected"
    ((PASS++))
else
    echo "  ❌ FAIL: Non-compliant workflow not detected"
    ((FAIL++))
fi

# Test 4: Shell templates exist
echo "Test 4: Shell prologue templates exist"
if [ -f "$HOME/.copilot/templates/shell/hoyt-bash-shell-prologue-actions.md" ] && \
   [ -f "$HOME/.copilot/templates/shell/hoyt-powershell-prologue-actions.md" ]; then
    echo "  ✅ PASS: Templates found"
    ((PASS++))
else
    echo "  ❌ FAIL: Templates missing"
    ((FAIL++))
fi

# Cleanup
rm -rf "$TEST_DIR"

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
