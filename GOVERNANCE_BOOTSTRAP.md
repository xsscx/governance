# Governance Bootstrap

## Immediate Session Init

Use Case: Security Research on Ubuntu24 beginning in home directory:

```
git clone https://github.com/xsscx/governance.git
```

Then, begin your Copilot, Claude or ChatGPT Session with this Prompt:

```
copilot -i "Run ./governance/session-start.sh
```

Then continue your Copilot Workflow.

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
[FAIL] "I apologize for the confusion..."
[FAIL] "Let me try a different approach..."
[FAIL] "Now that we've completed step 1..."
[FAIL] "This is important because..."
[OK] [Direct action with tool calls]
```

## References

- Profiles: `~/.copilot/profiles/*.json`
- Violations: `~/.copilot/enforcement/violation-patterns-v2.yaml`
- Templates: `~/.copilot/templates/`
- Scripts: `~/.copilot/scripts/`

