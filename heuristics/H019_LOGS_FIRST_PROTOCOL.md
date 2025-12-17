# H019: Logs-First-Protocol

**Created**: 2026-02-03  
**Severity**: TIER 1 (Hard Stop)  
**Trigger**: Any claim about build/test success or failure  
**Purpose**: Prevent false success/failure claims by checking evidence first

---

## The Rule

**BEFORE** claiming any build or test status (success OR failure):

```
MANDATORY SEQUENCE:
1. Find relevant logs (5 seconds)
2. Check logs for actual status (10 seconds)
3. Find artifacts with find command (5 seconds)
4. If discrepancy → investigate cause (don't assume)
5. Report with evidence from logs

Total overhead: 20 seconds
Benefit: Prevents false claims (16+ minutes saved per violation)
```

---

## Triggers

This heuristic applies to ANY statement containing:

### Build Status Claims
- "build failed"
- "build succeeded"  
- "compilation error"
- "make succeeded"
- "artifacts created"
- "artifacts missing"

### Test Status Claims
- "all tests pass"
- "tests failed"
- "no failures detected"
- "found X errors"

### Artifact Claims
- "file not found"
- "directory empty"
- "no WASM builds"
- "tools missing"
- "binaries don't exist"

---

## Protocol Steps

### Step 1: Find Logs (5s)
```bash
# Find relevant build/test logs
find . -name "*build*.log" -o -name "*make*.log" -o -name "*test*.log" \
  -mtime -7 | head -10
```

### Step 2: Check Log Status (10s)
```bash
# Check for success/failure indicators
grep -i "error\|failed\|success\|built target\|100%\|complete" <logfile> | tail -20
```

### Step 3: Find Artifacts (5s)
```bash
# Use find, not ls or glob
find Build-WASM -name "*.wasm" -type f 2>/dev/null
```

### Step 4: Investigate Discrepancies
If logs say SUCCESS but artifacts missing → Check if directory was cleaned

### Step 5: Report With Evidence
Include log file name, status lines, and artifact counts in response

---

## Cost-Benefit

- **Without H019**: 23+ minutes (V018 actual cost)
- **With H019**: 3.3 minutes  
- **Savings**: 20 minutes per claim
- **ROI**: 60× return on 20-second investment

---

## Enforcement: TIER 1 (Hard Stop)

**Why TIER 1**:
1. 64% of violations are false success
2. 16-45 min wasted per violation
3. Pattern persists despite documentation
4. H011 was violated within 24 hours
5. 20 seconds prevents hours of waste

**NO EXCEPTIONS ALLOWED**

---

**Status**: ACTIVE  
**Next Review**: After 10 build/test status claims
