#!/bin/bash
# Shell Prologue Compliance Checker

set -euo pipefail
VIOLATIONS=0

check_bash_prologue() {
    local file="$1"
    grep -q "bash --noprofile --norc" "$file" || ((VIOLATIONS++))
    grep -q "BASH_ENV: /dev/null" "$file" || ((VIOLATIONS++))
    grep -q "set -euo pipefail" "$file" || ((VIOLATIONS++))
}

for workflow in .github/workflows/*.yml 2>/dev/null; do
    [ -f "$workflow" ] && check_bash_prologue "$workflow"
done

[ $VIOLATIONS -eq 0 ] && echo "✅ Compliant" || echo "❌ $VIOLATIONS violations"
exit $VIOLATIONS
