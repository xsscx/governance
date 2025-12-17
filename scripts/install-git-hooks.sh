#!/bin/bash
# Install LLMCJF Git Hooks
# Installs pre-push hook to enforce git-push-policy.yaml
# Usage: ./scripts/install-git-hooks.sh [--force]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LLMCJF_DIR="$REPO_ROOT/llmcjf"
GIT_HOOKS_DIR="$REPO_ROOT/.git/hooks"

FORCE_INSTALL="${1:-}"

# Colors
GREEN="[OK]"
RED="[RED]"
YELLOW="[WARN]"
BLUE="[INFO]"

echo ""
echo "========================================"
echo "  LLMCJF Git Hooks Installer"
echo "========================================"
echo ""

# Check if we're in a git repository
if [ ! -d "$REPO_ROOT/.git" ]; then
    echo "$RED Not a git repository"
    exit 1
fi

# Check if llmcjf directory exists
if [ ! -d "$LLMCJF_DIR" ]; then
    echo "$RED llmcjf directory not found: $LLMCJF_DIR"
    exit 1
fi

# Install pre-push hook
echo "$BLUE Installing pre-push hook..."

if [ -f "$GIT_HOOKS_DIR/pre-push" ] && [ "$FORCE_INSTALL" != "--force" ]; then
    echo "$YELLOW Pre-push hook already exists"
    echo ""
    echo "Existing hook:"
    head -3 "$GIT_HOOKS_DIR/pre-push" | sed 's/^/  /'
    echo ""
    echo "To replace, run: $0 --force"
    echo ""
else
    cp "$LLMCJF_DIR/hooks/pre-push" "$GIT_HOOKS_DIR/pre-push"
    chmod +x "$GIT_HOOKS_DIR/pre-push"
    echo "$GREEN Pre-push hook installed"
fi

# Verify installation
echo ""
echo "$BLUE Verifying installation..."

if [ -x "$GIT_HOOKS_DIR/pre-push" ]; then
    echo "$GREEN Pre-push hook is executable"
else
    echo "$RED Pre-push hook is not executable"
    chmod +x "$GIT_HOOKS_DIR/pre-push"
    echo "$GREEN Fixed permissions"
fi

# Show hook details
echo ""
echo "========================================== "
echo "  Installation Complete"
echo "=========================================="
echo ""
echo "Hook installed: $GIT_HOOKS_DIR/pre-push"
echo "Source: $LLMCJF_DIR/hooks/pre-push"
echo "Policy: llmcjf/profiles/git-push-policy.yaml"
echo ""
echo "The pre-push hook will:"
echo "  1. Check for authorization file (/tmp/.git-push-authorized-\$\$)"
echo "  2. Check for 'do not push' markers"
echo "  3. Require interactive confirmation if no authorization"
echo "  4. Log violations to llmcjf/violations/"
echo ""
echo "To authorize a push:"
echo "  ./llmcjf/scripts/authorize-push.sh"
echo "  git push"
echo ""
echo "To bypass (testing only):"
echo "  git push --no-verify"
echo ""
echo "TIER 0 H016 enforcement is now ACTIVE"
echo ""
