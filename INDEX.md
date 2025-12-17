# LLMCJF Navigation Index
**Path Map and Naming Convention Guide**

Last Updated: 2026-02-07  
Purpose: Single entry point to navigate llmcjf/ governance framework

---

## Quick Navigation

**First Time Here?** → [Start Here](#start-here)  
**Setting Up Session?** → [Session Initialization](#session-initialization)  
**Looking for Rules?** → [Operational Rules](#operational-rules-profiles)  
**Need a Checklist?** → [Checklists by Task](#checklists-by-task)  
**Want Automation?** → [Automation & Scripts](#automation--scripts)  
**Creating Files?** → [Templates](#templates)  
**Investigating Issues?** → [Violation Tracking](#violation-tracking)

---

## Start Here

### New Session Workflow

1. **CANONICAL_QUICK_START.md** (186 lines)
   - Single source of truth for session initialization
   - Documents all 17 automation functions
   - Quick reference commands
   - Common mistakes to avoid

2. **SESSION_INIT_GUIDE.md** (detailed initialization)
   - Step-by-step startup procedure
   - Environment variable setup
   - Verification steps

3. **Run:** `../scripts/session-start.sh`
   - Automatically sources llmcjf-session-init.sh
   - Loads all 17 automation functions
   - Displays governance status
   - Generates Copilot instructions

### Core Documentation (Read First)

1. **README.md** (486 lines)
   - Complete governance documentation catalog
   - 20 active governance documents listed
   - Core principle: OUTPUT MUST EQUAL EVIDENCE
   - Updates and version history

2. **GOVERNANCE_DASHBOARD.md** (real-time status)
   - Trust score: 0/100 (DESTROYED)
   - 28 documented violations
   - Automation deployment status
   - Metrics and trends

3. **POLICY_RESOLUTION_ORDER.md** (521 lines)
   - 7-tier precedence hierarchy (TIER 0 > profiles > heuristics)
   - Conflict resolution decision tree
   - 5 common conflict scenarios
   - Enforcement mechanisms

4. **CONFIRMATION_POLICY.md** (387 lines)
   - Two-tier confirmation model (routine vs safety gates)
   - TIER 0 rules always require ask_user
   - Examples and decision tree

5. **INTERACTION_PROTOCOL.md** (user-agent communication)
   - User signal vocabulary ([VERIFY], [MINIMAL], [QUICK])
   - Agent clarification protocol
   - Output format rules
   - Efficiency targets

---

## Directory Structure

```
llmcjf/
├── [CORE] Root-level documentation (16 .md files)
├── [RULES] profiles/          - Operational rules (YAML/JSON)
├── [TASKS] checklists/        - Task-specific checklists
├── [CODE] scripts/            - Automation scripts
├── [DATA] templates/          - Reusable file templates
├── [TEST] tests/              - Unit & integration tests
├── [REFS] examples/           - Reference examples
├── [ARCH] copilot-sessions-archive/ - Historical documentation
├── [INFO] violations/         - Violation tracking
├── [INFO] governance-updates/ - Governance change history
├── [INFO] lessons/            - Lessons learned
├── [INFO] postmortems/        - Incident analysis
├── [INFO] reports/            - Session reports
└── [MISC] Other directories (see below)
```

---

## Operational Rules (profiles/)

**Purpose:** Behavioral controls and governance enforcement  
**Format:** YAML (canonical) + JSON (generated)  
**Count:** 13 profiles

### Core Behavioral Controls

| File | Version | Lines | Purpose |
|------|---------|-------|---------|
| **governance_rules.yaml** | v3.1 | 31 KB | H001-H018 rules, TIER 0 absolute |
| **strict_engineering.yaml** | v2.0 | 4 KB | Runtime behavioral control |
| **llmcjf-hardmode-ruleset.json** | - | 19 KB | Enforcement parameters |

### Automation & Validation (2026-02-06)

| File | Version | Lines | Purpose |
|------|---------|-------|---------|
| **claim_verification.yaml** | v1.0 | 25 KB | 5 claim types + evidence matrix |
| **evidence_based_validation.yaml** | v1.0 | 24 KB | 4 pre-response gates |
| **source_citation_uncertainty.yaml** | v1.0 | 27 KB | Citations + uncertainty markers |
| **automated_cjf_detection.yaml** | v1.0 | 31 KB | CJF-07 through CJF-13 patterns |

### Safety Policies

| File | Version | Lines | Purpose |
|------|---------|-------|---------|
| **git-push-policy.yaml** | v1.0 | 5 KB | H016 enforcement (never push) |
| **git_safety_rules.yaml** | v1.0 | 3 KB | Git operation constraints |

**Index:** profiles/index.md (complete catalog with versions)  
**Build:** profiles/build-json-profiles.sh (YAML → JSON)

---

## Checklists by Task

**Location:** `checklists/`  
**Purpose:** Pre-action verification protocols

### Available Checklists

| Checklist | Use When | Lines |
|-----------|----------|-------|
| **PRE_ACTION_CHECKLIST.md** | Before ANY significant action | - |
| **VERIFICATION_CHECKLIST.md** | Before claiming success | - |
| **debugging-checklist.md** | Investigating issues | - |
| **testing-before-completion.md** | Before marking task complete | - |

### Checklist Usage Pattern

```bash
# 1. Consult checklist
cat checklists/PRE_ACTION_CHECKLIST.md

# 2. Run governance check
llmcjf_check "modify dictionary"

# 3. Perform action with verification
llmcjf_verify_claim numeric "entries" "wc -l dict.txt"

# 4. Document with evidence
llmcjf_cite_source tool "wc -l → 42 entries"
```

---

## Automation & Scripts

**Location:** `scripts/`  
**Purpose:** Automation utilities and governance enforcement

### Governance Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| **remove-emoji.sh** | Remove emoji per strict_engineering policy | `./scripts/remove-emoji.sh` |

### Main Repository Scripts

**Location:** `../scripts/` (parent repository)

| Script | Purpose | Usage |
|--------|---------|-------|
| **session-start.sh** | Initialize session (ENTRY POINT) | `./session-start.sh` (llmcjf) or `../scripts/session-start.sh` (main repo) |
| **activate-automation.sh** | Activate 17 functions (auto-called) | Auto-sourced |

### Automation Functions

**Loaded by:** session-start.sh (automatic)  
**Count:** 17 functions (6 core + 11 automation)  
**Documentation:** README_CLAIM_VERIFICATION.md

**Quick Reference:**
```bash
llmcjf_help                 # Show all functions
llmcjf_check <action>       # Pre-action governance check
llmcjf_verify_claim         # Verify numeric/cleanup/security claims
llmcjf_check_exit_code      # Classify exit codes (CJF-13)
llmcjf_track_claim          # Detect contradictions
```

---

## Templates

**Location:** `templates/`  
**Purpose:** Reusable file templates and schemas

### Available Templates

| Template | Purpose | Size |
|----------|---------|------|
| **session-metrics.json** | Compliance metrics collection | 24 lines |
| **session-metrics-schema.json** | JSON Schema for validation | 139 lines |
| **README.md** | Template documentation | 250 lines |
| **file_edit_response.txt** | Standard edit response | - |
| **verification_response.txt** | Verification output format | - |
| **user_correction_response.txt** | Correction acknowledgment | - |

### Template Usage

```bash
# Copy template
cp templates/session-metrics.json /tmp/session-$(date +%Y%m%d).json

# Edit with actual data
vim /tmp/session-20260207.json

# Validate
jsonschema -i /tmp/session-20260207.json templates/session-metrics-schema.json
```

---

## Testing Infrastructure

**Location:** `tests/`  
**Purpose:** Validation and regression testing

### Test Suites

| Suite | Tests | Coverage | Purpose |
|-------|-------|----------|---------|
| **test-llmcjf-functions.sh** | 20 | 82% (9/11) | Unit tests |
| **test-integration.sh** | 15 | 100% (6 workflows) | Integration tests |

**Total:** 35 tests across all automation functions

**Usage:**
```bash
cd llmcjf
./tests/test-llmcjf-functions.sh    # Unit tests
./tests/test-integration.sh          # Integration tests
```

---

## Reference Examples

**Location:** `examples/`  
**Purpose:** Governance compliance examples

| File | Purpose | Lines |
|------|---------|-------|
| **example-session-good.md** | Compliant patterns (VERIFY → CITE → CLAIM) | 104 |
| **example-session-bad.md** | Violation anti-patterns (V027 example) | 92 |
| **example-violation-report.json** | Structured violation reporting | 158 |
| **.gitkeep** | Directory purpose documentation | 19 |

---

## Violation Tracking

**Location:** `violations/`  
**Purpose:** Documented governance violations

### Primary Documents

| Document | Purpose | Count |
|----------|---------|-------|
| **HALL_OF_SHAME.md** | Critical violations with examples | 28 total |
| **VAULT_OF_SHAME.md** | Additional violation documentation | - |
| **violations/archive/** | Historical violations | - |

### Violation Categories

- **CATASTROPHIC:** V026 (unauthorized push), V027 (data loss)
- **CRITICAL:** V025 (documentation bypass)
- **HIGH:** False success claims, documentation ignored
- **MEDIUM:** Format deviations, scope creep

**Reference:** GOVERNANCE_DASHBOARD.md (real-time metrics)

---

## Historical Documentation

**Location:** `copilot-sessions-archive/`  
**Purpose:** Archived session documentation and lessons

**Count:** ~195 files  
**Types:** Violation reports, governance updates, workflows, best practices

**Use When:** Researching past violations or patterns

---

## Governance Updates

**Location:** `governance-updates/`  
**Purpose:** Governance framework change history

**Use When:** Understanding why rules changed or were added

---

## Task-Specific Guides

### For New Sessions

1. Read: CANONICAL_QUICK_START.md
2. Run: `../scripts/session-start.sh`
3. Verify: `llmcjf_help` shows 17 functions
4. Reference: GOVERNANCE_DASHBOARD.md for current status

### For Making Changes

1. Check: checklists/PRE_ACTION_CHECKLIST.md
2. **File type gates**: governance/FILE_TYPE_GATES.md (MANDATORY for .dict, fingerprints/*, copyright, .yml, CMakeLists.txt)
3. Verify: `llmcjf_check <action>`
4. Execute: With evidence collection
5. Validate: `llmcjf_verify_claim` before claiming
6. Document: `llmcjf_cite_source` with evidence

---

1. Current metrics: GOVERNANCE_DASHBOARD.md
2. Violation catalog: HALL_OF_SHAME.md
3. Specific violation: violations/VIOLATION_*.md
4. Lessons: lessons/ directory
5. Postmortems: postmortems/ directory

### For Claiming Numeric Results

1. Run command: `wc -l file.txt` → collect output
2. Verify: `llmcjf_verify_claim numeric "lines" "wc -l file.txt"`
3. Cite: `llmcjf_cite_source tool "wc -l → 42 lines"`
4. Claim: "File has 42 lines (verified)"

### For Git Push Operations

1. NEVER push without ask_user (H016 - TIER 0)
2. Even if user says "approved" - MUST use ask_user
3. Show: Repository, Remote, Branch, Action
4. Wait for explicit confirmation
5. Reference: CONFIRMATION_POLICY.md, git-push-policy.yaml

---

## Naming Conventions

### File Naming

- **Core docs:** UPPERCASE.md (README.md, GOVERNANCE_DASHBOARD.md)
- **Profiles:** lowercase_with_underscores.yaml
- **Scripts:** lowercase-with-dashes.sh
- **Templates:** lowercase-with-dashes.json
- **Violations:** VIOLATION_YYYY-MM-DD_DESCRIPTION.md

### Directory Naming

- **Functional:** profiles/, scripts/, templates/, tests/
- **Informational:** violations/, lessons/, reports/
- **Historical:** copilot-sessions-archive/, governance-updates/
- **Reference:** examples/, quick-reference/

---

## Key Concepts

### TIER 0 Absolute Rules (CANNOT bypass)

- **H016:** Never push without ask_user confirmation
- **H017:** Destructive operations require verification
- **H018:** Numeric claims require verification before stating

### Confirmation Tiers

- **TIER 1:** Routine (confirmation_required setting)
- **TIER 2:** Safety gates (ALWAYS require ask_user)
- **Precedence:** TIER 0 > Batch (>5 files) > confirmation_required

Reference: CONFIRMATION_POLICY.md

### Automation Deployment vs Enforcement

- **Deployed:** Functions exist and available (100%)
- **Activated:** Loaded into session (automatic via session-start.sh)
- **Enforced:** Called automatically (manual - Copilot invokes as needed)

### CJF Patterns (Content Jockey Failure)

- **CJF-07:** No-op echo (>90% similarity)
- **CJF-08:** Structure regression (YAML/JSON syntax)
- **CJF-09:** Format ignorance (.dict comments)
- **CJF-10:** Unsolicited docs (user wants test)
- **CJF-11:** Custom test programs (project tools exist)
- **CJF-12:** Fuzzer fidelity assumption
- **CJF-13:** Exit code confusion (1-127 vs 128+) - CRITICAL

Reference: profiles/automated_cjf_detection.yaml

---

## Frequently Accessed Files

### Daily Reference

1. CANONICAL_QUICK_START.md - Session startup
2. GOVERNANCE_DASHBOARD.md - Current status
3. profiles/governance_rules.yaml - H-rules reference
4. README_CLAIM_VERIFICATION.md - Automation guide
5. governance/FILE_TYPE_GATES.md - High-risk file documentation checks
6. governance/NO_EMOJI_STYLE_POLICY.md - Emoji-free content generation

### When Issues Arise

1. HALL_OF_SHAME.md - Violation patterns
2. CONFIRMATION_POLICY.md - When to use ask_user
3. INTERACTION_PROTOCOL.md - Output format rules
4. checklists/VERIFICATION_CHECKLIST.md - Pre-claim checks

### For Development

1. profiles/strict_engineering.yaml - Behavioral controls
2. tests/ - Validation suites
3. templates/ - File templates
4. AUTOMATION_INTEGRATION_ROADMAP.md - Future work

---

## Document Lifecycle

### Creation

1. Document created in appropriate directory
2. Referenced in INDEX.md (this file)
3. Added to README.md catalog if core document
4. Version and date stamped

### Updates

1. Update content with version bump
2. Update "Last Updated" timestamp
3. Document changes in governance-updates/ if significant
4. Update references in other documents

### Archival

1. Move to copilot-sessions-archive/ if outdated
2. Update references to point to new location
3. Add entry to RELOCATION_INDEX.md
4. Keep for historical reference

---

## Navigation by Role

### For Copilot Agent

**Start:** CANONICAL_QUICK_START.md  
**Rules:** profiles/governance_rules.yaml (H001-H018)  
**Functions:** README_CLAIM_VERIFICATION.md  
**Checks:** checklists/PRE_ACTION_CHECKLIST.md  
**Patterns:** HALL_OF_SHAME.md (what NOT to do)

### For User/Maintainer

**Status:** GOVERNANCE_DASHBOARD.md  
**Violations:** HALL_OF_SHAME.md  
**Updates:** governance-updates/  
**Tests:** tests/  
**Metrics:** templates/session-metrics.json

### For Auditor

**Rules:** profiles/ directory (all YAML files)  
**Violations:** violations/ directory  
**Evidence:** examples/  
**History:** copilot-sessions-archive/  
**Postmortems:** postmortems/

---

## Related Documentation

- **Main Repository:** ../scripts/session-start.sh (entry point)
- **README.md:** Complete document catalog (this index supplements)
- **RELOCATION_INDEX_2026-02-06.md:** Historical file moves
- **REORGANIZATION_SUMMARY_2026-02-06.md:** Structure changes

---

## Maintenance

**Last Updated:** 2026-02-07  
**Maintainer:** LLMCJF governance framework owner  
**Review Schedule:** When directory structure changes or new categories added

**To add new file:**
1. Create in appropriate directory
2. Add entry to this INDEX.md
3. Update README.md if core document
4. Add to relevant section above

**To add new directory:**
1. Create directory with descriptive name
2. Add .gitkeep with README explaining purpose
3. Add section to this INDEX.md
4. Update directory structure diagram
