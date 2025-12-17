#!/bin/bash
# Enable Performance Mode for Governance

echo "=== Enabling Performance Mode ==="

# Use RAM disk for violation logs
export COPILOT_VIOLATIONS_LOG="/dev/shm/violations-$(date +%s).jsonl"
echo "✓ Violation logging: RAM disk (/dev/shm)"

# Set parallel workers
export COPILOT_MAX_WORKERS=32
echo "✓ Max workers: 32"

# Fast profile mode
export COPILOT_FAST_MODE=1
echo "✓ Fast mode: enabled"

# Disable telemetry/logging overhead
export COPILOT_MINIMAL_LOGGING=1
echo "✓ Minimal logging: enabled"

echo ""
echo "Performance mode active for this session."
echo ""
echo "To persist, add to ~/.bashrc:"
echo "  source ~/.copilot/scripts/enable-performance-mode.sh"
