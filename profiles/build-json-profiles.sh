#!/bin/bash
# Build JSON profiles from canonical YAML sources
# Generates machine-readable JSON from human-editable YAML
# Usage: ./profiles/build-json-profiles.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

echo -e "${BLUE}Building JSON profiles from YAML sources...${NC}"
echo ""

# Check Python YAML support
if ! python3 -c "import yaml" 2>/dev/null; then
    echo -e "${YELLOW}Warning: PyYAML not installed${NC}"
    echo "Install with: pip3 install pyyaml"
    echo "Skipping JSON generation"
    exit 1
fi

BUILD_COUNT=0
SKIP_COUNT=0

# Convert YAML to JSON
convert_yaml_to_json() {
    local yaml_file="$1"
    local json_file="${yaml_file%.yaml}.json"
    
    # Skip if JSON is newer than YAML
    if [ -f "$json_file" ] && [ "$json_file" -nt "$yaml_file" ]; then
        echo -e "  ${GREEN}[OK]${NC} Skipped: $json_file (up to date)"
        SKIP_COUNT=$((SKIP_COUNT + 1))
        return
    fi
    
    python3 << PYTHON
import yaml
import json
import sys

try:
    with open('$yaml_file', 'r') as f:
        data = yaml.safe_load(f)
    
    with open('$json_file', 'w') as f:
        json.dump(data, f, indent=2)
    
    print("  \033[0;32m[OK]\033[0m Generated: $json_file")
    sys.exit(0)
except Exception as e:
    print(f"  \033[0;31m[FAIL]\033[0m Failed: $yaml_file - {e}", file=sys.stderr)
    sys.exit(1)
PYTHON
    
    if [ $? -eq 0 ]; then
        BUILD_COUNT=$((BUILD_COUNT + 1))
    fi
}

# Process all YAML files
for yaml_file in *.yaml; do
    [ -f "$yaml_file" ] || continue
    convert_yaml_to_json "$yaml_file"
done

echo ""
echo -e "${GREEN}Build complete:${NC}"
echo "  Generated: $BUILD_COUNT files"
echo "  Skipped: $SKIP_COUNT files (up to date)"
echo ""
echo "Generated JSON files are build artifacts - do not edit manually"
echo "Modify YAML sources and re-run this script"
