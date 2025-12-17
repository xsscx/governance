#!/usr/bin/env python3
"""Compliance Score Calculator"""
import json, sys

def calculate_compliance(m):
    score = 100
    score -= m.get('user_corrections', 0) * 20
    score -= m.get('unrequested_lines', 0) * 2
    score -= m.get('format_deviations', 0) * 15
    score -= m.get('apology_count', 0) * 5
    score -= m.get('frustration_signals', 0) * 10
    return max(0, min(100, score))

if __name__ == "__main__":
    data = json.load(open(sys.argv[1]))
    score = calculate_compliance(data.get('metrics', {}))
    print(f"Compliance Score: {score}/100")
    sys.exit(0 if score >= 60 else 1)
