# Violation Logs

**Purpose:** Session violation audit trail  
**Format:** JSONL (JSON Lines)  
**Retention:** Local only (.gitignore)

---

## Log Format

Each line is a JSON object:

```json
{
  "timestamp": "2026-01-11T02:38:00Z",
  "session_id": "uuid",
  "violation_id": "V-CRITICAL-001",
  "severity": "critical",
  "evidence": "Expected format not applied after explicit correction",
  "user_correction": true,
  "rounds": 3,
  "remediated": true
}
```

## Fields

- **timestamp**: ISO8601 datetime
- **session_id**: UUID of session
- **violation_id**: Fingerprint ID (V-CRITICAL-001, etc.)
- **severity**: critical|high|medium|low
- **evidence**: Brief description
- **user_correction**: Boolean - did user have to correct?
- **rounds**: Number of correction attempts
- **remediated**: Boolean - was it fixed?

## Usage

### Log Violation
```bash
echo '{"timestamp":"'$(date -Iseconds)'","violation_id":"V-CRITICAL-001",...}' \
  >> ~/.copilot/violations/session-$(date +%Y%m%d).jsonl
```

### Analyze Violations
```bash
cat ~/.copilot/violations/*.jsonl | jq -s 'group_by(.violation_id)'
```

### Count by Severity
```bash
cat ~/.copilot/violations/*.jsonl | jq -s 'group_by(.severity) | map({severity: .[0].severity, count: length})'
```

---

**Note:** These logs are for local governance tracking only
