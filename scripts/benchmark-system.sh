#!/bin/bash
# System Performance Benchmark Script

echo "=== WSL2 Performance Benchmark ==="
echo ""

echo "1. CPU Info:"
echo "  Cores: $(nproc --all)"
echo "  Model: $(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
echo ""

echo "2. Memory:"
free -h | grep -E "Mem|Swap"
echo ""

echo "3. Disk Performance (Quick Test):"
echo "  Testing /tmp (1GB sequential write)..."
dd if=/dev/zero of=/tmp/test.dat bs=1M count=1024 oflag=direct 2>&1 | grep -E "copied|MB/s"
rm /tmp/test.dat
echo ""

echo "4. /dev/shm (RAM disk):"
df -h /dev/shm | tail -1
echo ""

echo "5. DNS Performance (if BIND running):"
if service named status 2>/dev/null | grep -q "running"; then
    echo "  BIND status: Running"
    echo "  Testing 100 queries..."
    time for i in {1..100}; do
        dig @127.0.0.1 google.com +short > /dev/null 2>&1
    done
else
    echo "  BIND status: Not running"
fi
echo ""

echo "6. Governance Script Speed:"
time source ~/.copilot/scripts/load-profile.sh strict-engineering 2>/dev/null
echo ""

echo "=== Benchmark Complete ==="
