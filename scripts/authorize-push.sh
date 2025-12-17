#!/bin/bash
# Git Push Authorization Helper
# Creates temporary authorization file for pre-push hook
# Usage: ./scripts/authorize-push.sh

set -euo pipefail

AUTHORIZATION_FILE="/tmp/.git-push-authorized-$$"

cat <<EOF

========================================================================
Git Push Authorization Helper
========================================================================

This script authorizes the next 'git push' operation within 60 seconds.

Policy: LLMCJF Git Push Policy (TIER 0 H016)
Rule: NEVER push without explicit user authorization

EOF

# Confirm authorization
echo "Do you explicitly authorize the next git push? (yes/no)"
read -r -p "> " response

case "$response" in
    yes|YES|y|Y)
        touch "$AUTHORIZATION_FILE"
        echo ""
        echo "[OK] Push authorized for the next 60 seconds"
        echo ""
        echo "Now run: git push"
        echo ""
        echo "Authorization file: $AUTHORIZATION_FILE"
        echo "Expires: $(date -d '+60 seconds' 2>/dev/null || date -v+60S 2>/dev/null || echo '60 seconds from now')"
        ;;
    *)
        echo ""
        echo "[RED] Authorization denied - no push will occur"
        exit 1
        ;;
esac
