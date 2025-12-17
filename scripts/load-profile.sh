#!/bin/bash
# Profile Loader for Copilot Governance
# Usage: source ~/.copilot/scripts/load-profile.sh [profile-name]

PROFILE="${1:-strict-engineering}"
COPILOT_DIR="$HOME/.copilot"
PROFILE_FILE="$COPILOT_DIR/profiles/$PROFILE.json"

if [ ! -f "$PROFILE_FILE" ]; then
    echo "[FAIL] Profile not found: $PROFILE"
    echo "Available profiles:"
    ls -1 "$COPILOT_DIR/profiles/" | sed 's/\.json$//'
    return 1
fi

echo "● Loading profile: $PROFILE"

# Set environment variables
export COPILOT_PROFILE="$PROFILE"
export COPILOT_GOVERNANCE="$COPILOT_DIR/governance"
export COPILOT_VIOLATIONS_LOG="$COPILOT_DIR/violations/session-$(date +%Y%m%d-%H%M%S).jsonl"

# Display active constraints
echo "● Constraints:"
jq -r '.behavioral_constraints | to_entries[] | "  - \(.key): \(.value)"' "$PROFILE_FILE" 2>/dev/null || echo "  (profile loaded)"

echo "● Enforcement:"
jq -r '.code_modification_rules | to_entries[] | select(.value == true) | "  - \(.key)"' "$PROFILE_FILE" 2>/dev/null | head -5

echo ""
echo "Ready to continue."
echo ""
echo "To enable violation logging:"
echo "  export COPILOT_VIOLATIONS_LOG=\"$COPILOT_VIOLATIONS_LOG\""
