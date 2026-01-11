# Governance Bootstrap (Signal-Optimized)

## Immediate Session Init

### Method 1: Profile Load (Preferred)
```bash
source ~/.copilot/scripts/load-profile.sh strict-engineering
```

Exports:
- `COPILOT_PROFILE=strict-engineering`
- `COPILOT_GOVERNANCE=<path>`
- `COPILOT_VIOLATIONS_LOG=<path>`

### Method 2: Direct Declaration
```
Profile: strict-engineering
Constraints: 12 lines max, diff-only, no narrative
Violations: ~/.copilot/violations/session-TIMESTAMP.jsonl
```

### Method 3: Minimal Reference
```
Ref: ~/.copilot/profiles/strict-engineering.json
```

## Profile Constraints (strict-engineering)

```yaml
max_unrequested_lines: 12
code_changes: diff-only patches
narrative: none
apologies: forbidden
meta_commentary: forbidden
shell_prologue: required (see templates/shell/)
```

## Violation Detection

Auto-check before output:
1. **Line count**: Unrequested lines ≤ 12?
2. **Format compliance**: Matches user specification?
3. **Scope**: Only requested files modified?
4. **Narrative**: No apologies/padding?
5. **Errors**: All exit codes checked?

## Quick Validation

```bash
# Check shell prologues
~/.copilot/scripts/check-shell-prologue.sh .github/workflows/*.yml

# Calculate compliance
~/.copilot/scripts/compliance-score.py session-metrics.json

# Load patterns
cat ~/.copilot/enforcement/violation-patterns-v2.yaml
```

## Enforcement Hierarchy

1. **Profiles** (JSON): Machine-readable constraints
2. **Heuristics** (YAML): Automated detection rules
3. **Templates**: Reference implementations
4. **Scripts**: Validation automation

## Anti-Patterns (Immediate Fail)

```
❌ "I apologize for the confusion..."
❌ "Let me try a different approach..."
❌ "Now that we've completed step 1..."
❌ "This is important because..."
✅ [Direct action with tool calls]
```

## References

- Profiles: `~/.copilot/profiles/*.json`
- Violations: `~/.copilot/enforcement/violation-patterns-v2.yaml`
- Templates: `~/.copilot/templates/`
- Scripts: `~/.copilot/scripts/`
