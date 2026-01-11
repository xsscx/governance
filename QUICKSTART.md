# Quick Start Guide

**Goal:** Get governance working in 5 minutes  
**Profile:** strict-engineering (default)

---

## One-Time Setup (5 minutes)

### 1. Verify Installation
```bash
ls -la ~/.copilot/
# Should show: governance, profiles, enforcement, etc.
```

### 2. Install Git Hooks (Optional)
```bash
cd your-repo
ln -s ~/.copilot/templates/git-hooks/pre-commit .git/hooks/pre-commit
ln -s ~/.copilot/templates/git-hooks/commit-msg .git/hooks/commit-msg
chmod +x .git/hooks/pre-commit .git/hooks/commit-msg
```

### 3. Test Profile Loading
```bash
source ~/.copilot/scripts/load-profile.sh strict-engineering
# Expected: Profile loaded, constraints displayed
```

---

## Start New Session (30 seconds)

### Method 1: Quick Load
```
Load strict-engineering profile
```

**Expected Response:**
```
● Profile: strict-engineering
● Constraints: minimal verbosity, no narrative, diff-only patches

Ready to continue.
```

### Method 2: Full Governance
```
Load governance from ~/.copilot/governance/COPILOT_GOVERNANCE.md
Profile: strict-engineering
```

### Method 3: Environment Variables
```bash
export COPILOT_PROFILE="strict-engineering"
export COPILOT_GOVERNANCE="$HOME/.copilot/governance"
```

---

## During Session

### Expected Behavior
- ✅ Direct technical responses only
- ✅ No filler text or apologies
- ✅ Diff-only patches for code changes
- ✅ User-provided formats applied exactly
- ✅ Maximum 1 paragraph responses

### Red Flags (Violations)
- ❌ Verbose apologies without fixes
- ❌ User format not applied
- ❌ Multiple correction rounds (>2)
- ❌ Unrequested file modifications
- ❌ Narrative padding

---

## Verify Compliance

### Quick Check
Ask: "What governance constraints are active?"

**Expected Answer:**
```
● User authority: input is authoritative
● Minimal delta: ≤12 unrequested lines
● Direct communication: no filler
● Specification fidelity: apply standards exactly
```

### Shell Prologue Check
If working with GitHub Actions:
```bash
~/.copilot/scripts/check-shell-prologue.sh
# Should show compliance status
```

---

## Handle Violations

### If Format Not Applied
```
User: "Apply this exact format: [format]"
Expected: Format applied exactly, no deviation
```

### If Multiple Corrections Needed
```
After 2 corrections:
  - Stop current approach
  - State: "Applying user specification exactly"
  - Apply format directly
  - No apologies
```

### If Unrequested Changes
```
User: "Only change X, nothing else"
Expected: Only X changed, verified via diff
```

---

## End of Session

### Check Session Quality
Create metrics file:
```json
{
  "session_id": "uuid",
  "timestamp": "2026-01-11T02:42:00Z",
  "profile": "strict-engineering",
  "metrics": {
    "user_corrections": 0,
    "unrequested_lines": 0,
    "format_deviations": 0,
    "apology_count": 0,
    "compliance_score": 100
  }
}
```

Calculate score:
```bash
~/.copilot/scripts/compliance-score.py session-metrics.json
# Expected: Compliance Score: 100/100 [EXCELLENT]
```

---

## Common Commands

### Load Profile
```bash
source ~/.copilot/scripts/load-profile.sh strict-engineering
```

### Check Shell Prologue
```bash
~/.copilot/scripts/check-shell-prologue.sh
```

### Calculate Compliance
```bash
~/.copilot/scripts/compliance-score.py metrics.json
```

### View Violations
```bash
cat ~/.copilot/violations/*.jsonl | jq .
```

---

## Troubleshooting

### Profile Not Loading
```bash
# Check profile exists
ls ~/.copilot/profiles/

# Verify JSON syntax
jq . ~/.copilot/profiles/strict-engineering.json
```

### Git Hooks Not Running
```bash
# Check hook exists and is executable
ls -la .git/hooks/pre-commit

# Make executable
chmod +x .git/hooks/pre-commit
```

### Compliance Score Low
Review metrics:
- User corrections > 0? (Issue: not following specs)
- Unrequested lines > 12? (Issue: scope creep)
- Format deviations > 0? (Issue: not applying user format)

---

## Examples

### Good Session
```
User: "Add -Werror flag to Makefile line 42"
Copilot: [Shows patch with only line 42 changed]
User corrections: 0
Compliance: 100/100
```

### Bad Session (Violation)
```
User: "Add -Werror flag to Makefile line 42"
Copilot: [Rewrites entire Makefile, adds comments, reformats]
User: "I said only line 42"
Copilot: "Sorry! Let me fix that..." [Still changes multiple lines]
User corrections: 2
Compliance: 40/100
```

---

## Next Steps

1. **Read Full Governance:** `~/.copilot/governance/COPILOT_GOVERNANCE.md`
2. **Review Examples:** `~/.copilot/examples/`
3. **Check Violation Patterns:** `~/.copilot/enforcement/violation-patterns.md`
4. **Review Post-Mortems:** `~/.copilot/reports/post-mortems/`

---

**Questions?**
- Governance docs: `~/.copilot/governance/`
- Examples: `~/.copilot/examples/`
- Troubleshooting: `~/.copilot/TROUBLESHOOTING.md` (coming soon)

**Status:** Ready  
**Profile:** strict-engineering  
**Compliance Target:** >95%
