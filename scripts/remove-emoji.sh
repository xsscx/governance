#!/bin/bash
# Remove emoji/unicode from llmcjf per strict_engineering.yaml rules
# Replaces emoji with ASCII equivalents
# Usage: ./scripts/remove-emoji.sh [--dry-run]

set -euo pipefail

DRY_RUN=false
if [ "${1:-}" = "--dry-run" ]; then
    DRY_RUN=true
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

echo "Removing emoji per strict_engineering.yaml policy..."
echo "Mode: $([ "$DRY_RUN" = true ] && echo "DRY RUN" || echo "EXECUTE")"
echo ""

FILES_CHANGED=0
TOTAL_REPLACEMENTS=0

# Define emoji replacements
declare -A REPLACEMENTS=(
    ["[OK]"]="[OK]"
    ["[OK]"]="[OK]"
    ["[FAIL]"]="[FAIL]"
    ["[FAIL]"]="[FAIL]"
    ["*"]="*"
    ["[RED]"]="[RED]"
    ["[YELLOW]"]="[YELLOW]"
    ["[GREEN]"]="[GREEN]"
    ["[LOCKED]"]="[LOCKED]"
    ["[WARN]"]="[WARN]"
    ["[PENDING]"]="[PENDING]"
    ["[INFO]"]="[INFO]"
)

process_file() {
    local file="$1"
    local changes=0
    local temp_file="${file}.tmp"
    
    cp "$file" "$temp_file"
    
    for emoji in "${!REPLACEMENTS[@]}"; do
        replacement="${REPLACEMENTS[$emoji]}"
        if grep -q "$emoji" "$temp_file" 2>/dev/null; then
            count=$(grep -o "$emoji" "$temp_file" | wc -l)
            sed -i "s/$emoji/$replacement/g" "$temp_file"
            changes=$((changes + count))
        fi
    done
    
    if [ $changes -gt 0 ]; then
        echo "  $file: $changes replacements"
        FILES_CHANGED=$((FILES_CHANGED + 1))
        TOTAL_REPLACEMENTS=$((TOTAL_REPLACEMENTS + changes))
        
        if [ "$DRY_RUN" = false ]; then
            mv "$temp_file" "$file"
        else
            rm "$temp_file"
        fi
    else
        rm "$temp_file"
    fi
}

# Process shell scripts
echo "Processing shell scripts..."
while IFS= read -r -d '' file; do
    process_file "$file"
done < <(find . -name "*.sh" -not -path "./.git/*" -print0)

# Process markdown files  
echo ""
echo "Processing markdown files..."
while IFS= read -r -d '' file; do
    process_file "$file"
done < <(find . -name "*.md" -not -path "./.git/*" -print0)

# Process YAML files
echo ""
echo "Processing YAML files..."
while IFS= read -r -d '' file; do
    process_file "$file"
done < <(find . -name "*.yaml" -not -path "./.git/*" -print0)

# Process JSON files
echo ""
echo "Processing JSON files..."
while IFS= read -r -d '' file; do
    process_file "$file"
done < <(find . -name "*.json" -not -path "./.git/*" -print0)

echo ""
echo "Summary:"
echo "  Files changed: $FILES_CHANGED"
echo "  Total replacements: $TOTAL_REPLACEMENTS"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo "DRY RUN - no files modified"
    echo "Run without --dry-run to apply changes"
else
    echo "Changes applied"
    echo "Review with: git diff"
fi
