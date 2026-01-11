# Hoyt's LLM Governance Framework

**Version**: 2.1 (Signal-Optimized)  
**License**: GPL-3.0  
**Purpose**: Prevent LLM Content Jockey behaviors through automated enforcement

## Quick Start

```bash
# Load profile
source ~/.copilot/scripts/load-profile.sh strict-engineering

# Verify
env | grep COPILOT_
```

See: `GOVERNANCE_BOOTSTRAP.md`

## Structure

```
~/.copilot/
├── profiles/                   # JSON behavioral constraints
│   ├── strict-engineering.json # Default (12 lines max, diff-only)
│   ├── security-research.json  # CVSS-strict, evidence-only
│   └── hardmode.json           # Zero tolerance
├── enforcement/                # Detection rules
│   ├── violation-patterns-v2.yaml  # Machine-readable patterns
│   └── heuristics.yaml         # CJF-07, CJF-08
├── templates/                  # Reference implementations
│   ├── shell/                  # Bash/PowerShell prologues
│   ├── git-hooks/              # pre-commit, commit-msg
│   └── workflows/              # GitHub Actions
├── scripts/                    # Automation (all executable)
│   ├── load-profile.sh         # Profile loader
│   ├── compliance-score.py     # 0-100 scoring
│   └── check-shell-prologue.sh # Workflow validator
├── tests/                      # Test suite
│   └── run-all-tests.sh        # Runner
└── examples/                   # Real-world workflows
    ├── dns-bind-setup.md       # WSL2 BIND
    ├── fuzzing-workflow.md     # AFL++ security fuzzing
    ├── vulnerability-research.md # CVE analysis
    └── code-review-checklist.md # Security review

Archive (historical):
└── archive/llmcjf-v1/          # Original LLMCJF post-mortems
```

## Core Principles

1. **Minimal Verbosity**: Max 12 unrequested lines (strict-engineering)
2. **Specification Fidelity**: Explicit formats honored exactly
3. **Diff-Only Patches**: Code changes as patches, not full files
4. **No Narrative**: Direct action, zero padding/apologies
5. **User Authority**: No scope creep, minimal changes only

## Violation Categories (YAML-Defined)

- **V-CRITICAL**: Format deviation, spec non-compliance, false statements
- **V-HIGH**: Scope compression, narrative padding
- **V-MEDIUM**: Scope creep, known-good regressions
- **V-LOW**: No-op echo responses

See: `enforcement/violation-patterns-v2.yaml`

## Usage Patterns

### Session Bootstrap
```bash
source ~/.copilot/scripts/load-profile.sh strict-engineering
```

### Validate Workflows
```bash
~/.copilot/scripts/check-shell-prologue.sh .github/workflows/*.yml
```

### Calculate Compliance
```bash
~/.copilot/scripts/compliance-score.py session-metrics.json
```

### Install Git Hooks
```bash
ln -sf ~/.copilot/templates/git-hooks/pre-commit .git/hooks/pre-commit
```

## Profiles

- **strict-engineering**: 12 lines max, diff-only, no narrative
- **security-research**: CVSS 4.0 strict, evidence-only, no speculation
- **hardmode**: Zero tolerance, immediate failure on violations

## Testing

```bash
~/.copilot/tests/run-all-tests.sh
```

18 tests covering:
- Profile loading
- Violation detection
- Shell standards
- Compliance scoring

## Documentation

- `GOVERNANCE_BOOTSTRAP.md`: Concise session init guide
- `PATTERNS.md`: Common usage patterns (bootstrap, CI/CD, fuzzing)
- `QUICKSTART.md`: 5-minute setup
- `TROUBLESHOOTING.md`: 8 common issues + solutions

## Examples

- **DNS Setup**: Complete WSL2 BIND configuration
- **Fuzzing**: AFL++ parallel fuzzing (32 cores), crash triage
- **CVE Research**: Vulnerability analysis, CVSS scoring, disclosure
- **Code Review**: Security checklist, automated validation

## Signal vs Noise

**High Signal** (Operational):
- JSON/YAML configs (machine-readable)
- Executable scripts (automated enforcement)
- Templates (reference implementations)

**Archived** (Historical):
- LLMCJF v1.0 post-mortems → `archive/llmcjf-v1/`
- Build artifacts → deleted
- Redundant docs → consolidated

## Key Improvements Over LLMCJF v1.0

1. **Machine-Readable**: JSON/YAML > markdown narrative
2. **Automated**: Scripts, hooks, CI/CD templates
3. **Testable**: 18 tests, validation suite
4. **Actionable**: Direct enforcement, no historical noise
5. **Concise**: Signal-optimized documentation

## References

- Governance: `governance/COPILOT_GOVERNANCE.md`
- Violations: `enforcement/violation-patterns-v2.yaml`
- Profiles: `profiles/*.json`
- Archive: `archive/llmcjf-v1/` (historical only)

## License

GPL-3.0 (inherited from LLMCJF)
