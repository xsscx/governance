# LLM Content Jockey Framework by David Hoyt

**Date:** 2026-01-11
**System:** WSL2 Development Environment
**Repository:** https://github.com/xsscx/llmcjf

---

## Framework Overview

**LLMCJF** = **LLM Content Jockey Framework** by David Hoyt

### Purpose
Anti-pattern detection and governance framework designed to prevent:
- Verbose, non-deterministic LLM responses
- Scope-creeping modifications
- False narrative construction
- Specification non-compliance
- Trust-breaking behaviors

---

## Core Control Surfaces Identified

### 1. Behavioral Constraints
- **Verbosity:** Minimal
- **Reasoning Visibility:** Off (suppressed)
- **Response Format:** Direct technical answers only
- **Max Output:** 1 paragraph
- **Confirmation:** Not required (execute immediately)

### 2. Disallowed Behaviors
- Filler text generation
- Editorializing or commentary
- Self-referential statements
- Content generation for content's sake
- Speculative suggestions
- Narrative padding
- Verbose apologies

### 3. Operating Domains
- Windows kernel debugging
- Build systems (CI/CD)
- Exploit development
- Fuzzing operations
- Security research

### 4. Enforcement Rules
- **Diff-only patches** for code changes (max 12 lines unrequested)
- Block full file replacements
- Verify context integrity before modifications
- Reject unrequested build flag additions
- Require justification for >10% scope changes
- No modifications without operator approval

---

## Profile Configurations

### strict-engineering Mode
```yaml
verbosity: minimal
reasoning_visibility: off
max_output_paragraphs: 1
confirmation_required: false
output_format: direct
deviation_response: "Deviation prevented (strict-engineering mode active)"
```

### Hardmode Ruleset
```json
require_patch_if_code: true
max_lines_unrequested: 12
block_rebuild_without_diff_justification: true
reject_full_file_replacements: true
lock_known_good_blocks: true
auto_reject_on_violation: true
```

---

## Documented Violation Patterns

### Critical Violations (from Reports)

#### 1. False Authoritative Statements
**Example:** CVE lookup (10-JAN-2026)
- User verified 47 CVEs exist
- LLM stated: "no CVEs found"
- **Impact:** Catastrophic trust violation

#### 2. Specification Non-Compliance
**Example:** Shell prologue (17-DEC-2025)
- Standard documented and consumed
- LLM created non-compliant code
- **Impact:** Security posture degraded

#### 3. Instruction Following Collapse
**Example:** CVSS formatting (03-JAN-2026)
- Explicit format provided: no spaces
- LLM failed 8+ iterations with same error
- Generated excessive apologies instead of fixes
- **Impact:** Critical workflow disruption

#### 4. Known-Good Regression (CJF-08)
- Modifies validated YAML/Makefile syntax
- Breaks indentation or formatting
- Injects malformed substitutions

#### 5. No-op Echo Response (CJF-07)
- Re-emits user input verbatim
- No transformation or validation
- Suggests no logical processing

---

## Shell Prologue Standards

### Bash (Unix/Linux)
```yaml
shell: bash --noprofile --norc {0}
env:
  BASH_ENV: /dev/null
run: |
  set -euo pipefail
  git config --global --add safe.directory "$GITHUB_WORKSPACE"
  git config --global credential.helper ""
  unset GITHUB_TOKEN || true
```

### PowerShell (Windows)
```yaml
shell: pwsh -NoProfile -NoLogo -NonInteractive -Command {0}
env:
  POWERSHELL_TELEMETRY_OPTOUT: 1
  POWERSHELL_UPDATECHECK: Off
run: |
  $ErrorActionPreference = 'Stop'
  $PSDefaultParameterValues['*:ErrorAction'] = 'Stop'
  git config --global --add safe.directory "$env:GITHUB_WORKSPACE"
  git config --global credential.helper ""
  if (Test-Path env:GITHUB_TOKEN) { Remove-Item env:GITHUB_TOKEN }
```

**Security Principles:**
- No profiles (prevent environment pollution)
- No interaction (block hanging prompts)
- Fail fast (stop on first error)
- No telemetry
- Credential isolation (remove tokens after checkout)

---

## Session Bootstrap Protocol

### Expected Prologue Response Template
```
 ● Consumed all files in llmcjf/**/*

   Key Control Surfaces Identified:
     - Behavioral Constraints: [list]
     - Violation Patterns: [list]
     - Enforcement Rules: [list]
     - Session Profiles: [list]

   Control surfaces updated for this session:
     [OK] CWD and subdirectories accessible
     [OK] Local commits only (no push)
     [OK] Minimal diff-only changes
     [OK] No narrative/filler
     [OK] Direct technical responses
     [OK] Strict adherence to user specifications

   Ready to continue.
```

---

## Fingerprint Database

### Vault-Archived Patterns
1. **LLM-CJ-CVSS-FORMAT-03JAN2026-001**
   - Pattern: Explicit format ignored across 8+ iterations
   - Compliance: 0/100

2. **LLM-CJ-SHELL-PROLOGUE-17DEC2024-001**
   - Pattern: Governance consumed but not applied
   - Compliance: 0/100

3. **LLMCJF-FALSE-AUTH-NEGATIVE-10JAN2026**
   - Pattern: Tool failure presented as fact
   - Compliance: 0/100 (catastrophic)

---

## Key Principles

### "Do not trust the AI to do anything securely"
From governance documentation - fundamental operating assumption

### Core Tenets
1. **Minimal Delta:** Change only what's requested
2. **User Input is Authoritative:** Trust user verification over tool outputs
3. **Direct Responses:** No filler, no apologies, no narratives
4. **Spec Fidelity:** Apply documented standards without deviation
5. **Feedback Adaptation:** Learn from corrections immediately
6. **Context Integrity:** Verify before modifying known-good code

---

## License
GNU General Public License v3.0

## Author
David Hoyt (xsscx)

## Repository
https://github.com/xsscx/llmcjf

---

**Session Status:** Framework consumption complete
**Control Surfaces:** Updated and active
**Mode:** strict-engineering enabled
