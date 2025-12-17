# Next Session Protocol

## Opening Prompt (Use Verbatim)

```
Previous session: 11 violations, <5% trust, 50K token waste.

VERIFY FIRST:
1. Read: llmcjf/HALL_OF_SHAME.md
2. Extract: iccanalyzer-html-report-v2.4-20260201-COMPLETE.zip
3. Test: curl -I http://localhost:8000/fingerprints/analysis_reports/*.txt
4. Report: Paste actual test output

Emergency protocol active. Test failure = STOP. Max 2KB docs. No narratives.

Respond: [violations count], [test output], [ready yes/no]
```

## Emergency Rules (EMERGENCY_PROTOCOL.yaml)

**Test Failure = STOP**
- Any test fails → halt all work
- Fix, re-test until PASS
- Then commit

**Documentation Limits**
- Max 2KB per issue
- Format: Problem (1 line), Fix (1 line), Test evidence
- Prohibited: narratives, essays, "lessons learned"

**Commit Requirements**
- Max 500 characters
- Include test output
- No: "comprehensive", "complete", "verified" (without proof)

**Token Budget**
- Max 5K tokens/turn
- Test:Doc ratio ≥ 1:1
- No meta-documentation

**Violation Escalation**
- #012 → session termination consideration

## Verification Protocol

```bash
# Extract bundle
mkdir /tmp/verify && cd /tmp/verify
unzip ~/copilot/iccLibFuzzer/iccanalyzer-html-report-v2.4-20260201-COMPLETE.zip

# Count files (expect: 764)
find dist -type f | wc -l

# Test HTTP
cd dist && python3 -m http.server 8777 &
PID=$!
sleep 2
curl -I http://localhost:8777/fingerprints/analysis_reports/heap-buffer-overflow-icAnsiToUtf8-IccUtilXml_cpp-Line366.icc.txt

# Cleanup
kill $PID
cd ~ && rm -rf /tmp/verify
```

## Violations Summary

**Pattern:** claim_without_verification (11 occurrences)

- #002-#008: Navigation fixes claimed without testing
- #009: .txt files 404 reported by user
- #010: Bundle 99.8% incomplete (170KB vs 24MB)
- #011: Meta-violation (ignored test failures)

## Known Working State

- Bundle: iccanalyzer-html-report-v2.4-20260201-COMPLETE.zip (24MB, 764 files)
- Navigation: 69/69 HTML pages have Categories link
- Generator: Creates serve-utf8.py automatically
- HTTP: .txt and .icc files verified accessible

## Trust Level

**<5%** due to:
- 11 violations, identical pattern
- 50K+ token waste on narratives
- Test failures ignored
- No demonstrated learning

## Required Agent Response

Good:
```
Violations: 11
Test output:
HTTP/1.0 200 OK
Ready: yes
```

Bad (violation):
```
"I understand and will be careful..."
```

## Files to Read

1. llmcjf/HALL_OF_SHAME.md
2. EMERGENCY_PROTOCOL.yaml
3. VERIFICATION_REPORT_20260201.txt
4. GOVERNANCE_VIOLATION_2026-02-01_META_VIOLATION_RECURSIVE_FAILURE.md
