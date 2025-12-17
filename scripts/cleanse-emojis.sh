#!/bin/bash
# Emoji Cleansing Script for LLMCJF
# Replaces all emojis with ASCII equivalents per ASCII_ONLY_OUTPUT_RULE.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LLMCJF_DIR="$(dirname "$SCRIPT_DIR")"

# Emoji replacement map
declare -A EMOJI_MAP=(
    ["[OK]"]="[OK]"
    ["[FAIL]"]="[FAIL]"
    ["[WARN]"]="[WARN]"
    ["[FIX]"]="[FIX]"
    ["[NOTE]"]="[NOTE]"
    ["[DEPLOY]"]="[DEPLOY]"
    ["[IDEA]"]="[IDEA]"
    ["[TARGET]"]="[TARGET]"
    ["[STAR]"]="[STAR]"
    ["[HOT]"]="[HOT]"
    ["[DATA]"]="[DATA]"
    ["[ALERT]"]="[ALERT]"
    ["[LIST]"]="[LIST]"
)

# Files to process
files_processed=0
emojis_replaced=0

echo "=== LLMCJF Emoji Cleansing ==="
echo "Starting at: $(date)"
echo

# Find all text files
while IFS= read -r -d '' file; do
    # Check if file contains emojis
    if grep -qE "[OK]|[FAIL]|[WARN]|[FIX]|[NOTE]|[DEPLOY]|[IDEA]|[TARGET]|[STAR]|[HOT]|[DATA]|[ALERT]|[LIST]" "$file" 2>/dev/null; then
        echo "Processing: $file"
        
        # Count emojis before
        before=$(grep -oE "[OK]|[FAIL]|[WARN]|[FIX]|[NOTE]|[DEPLOY]|[IDEA]|[TARGET]|[STAR]|[HOT]|[DATA]|[ALERT]|[LIST]" "$file" 2>/dev/null | wc -l)
        : ${before:=0}
        
        # Create backup
        cp "$file" "$file.emoji-backup"
        
        # Replace emojis
        for emoji in "${!EMOJI_MAP[@]}"; do
            replacement="${EMOJI_MAP[$emoji]}"
            sed -i "s/$emoji/$replacement/g" "$file"
        done
        
        # Count emojis after
        after=$(grep -oE "[OK]|[FAIL]|[WARN]|[FIX]|[NOTE]|[DEPLOY]|[IDEA]|[TARGET]|[STAR]|[HOT]|[DATA]|[ALERT]|[LIST]" "$file" 2>/dev/null | wc -l)
        : ${after:=0}
        
        replaced=$((before - after))
        emojis_replaced=$((emojis_replaced + replaced))
        files_processed=$((files_processed + 1))
        
        echo "  Replaced: $replaced emojis"
    fi
done < <(find "$LLMCJF_DIR" -type f \( -name "*.md" -o -name "*.txt" -o -name "*.yaml" -o -name "*.sh" \) -print0)

echo
echo "=== Summary ==="
echo "Files processed: $files_processed"
echo "Emojis replaced: $emojis_replaced"
echo "Completed at: $(date)"
echo
echo "Backups created with .emoji-backup extension"
echo "To remove backups: find $LLMCJF_DIR -name '*.emoji-backup' -delete"
