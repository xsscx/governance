# LLMCJF Profile Catalog
**Canonical Source of Truth for Profile Versions and Formats**

Last Updated: 2026-02-07  
Profile Format: YAML (canonical), JSON (generated)

---

## Format Policy

**Canonical Format:** YAML  
**Generated Format:** JSON (build artifact, do not edit manually)  
**Build Command:** `./profiles/build-json-profiles.sh`

**Why YAML?**
- Human-readable with comments
- Better for large configuration files (31 KB profiles)
- Git-friendly diffs
- Industry standard for configuration

**Why Generate JSON?**
- Machine-readable for programmatic loading
- Compatible with existing tooling
- Faster parsing for runtime use

---

## Active Profiles

### Core Behavioral Controls

**1. strict_engineering.yaml** (v2.0, 4.1 KB)
- Status: Active
- Purpose: Runtime behavioral control for deterministic operation
- Prevents: LLM content jockey drift
- Enforces: Concise, verifiable, domain-bound responses
- JSON: strict_engineering.json (generated)

**2. governance_rules.yaml** (v3.1, 31 KB) *
- Status: Active
- Purpose: Comprehensive governance framework (H001-H018)
- Contains: TIER 0 absolute rules (H016, H017, H018)
- Tracks: 28 documented violations
- JSON: governance_rules.json (generated)

**3. llmcjf-hardmode-ruleset.json** (19 KB) [LOCKED]
- Status: Active (JSON source of truth - no YAML equivalent)
- Purpose: Enforcement parameters and violation detection
- Contains: Rule enforcement flags, scope limits, diff controls
- Note: Manually maintained JSON (predates YAML-first policy)

**4. llm_strict_engineering_profile.json** (731 B) [WARN]
- Status: Deprecated - superseded by strict_engineering.yaml
- Migration: Content merged into strict_engineering.yaml v2.0
- Action: Can be removed after validation

### Automation & Validation (NEW 2026-02-06)

**5. claim_verification.yaml** (v1.0, 25 KB)
- Status: Active
- Purpose: 5 claim types with verification requirements
- Contains: Evidence matrix, uncertainty quantification
- JSON: claim_verification.json (generated)

**6. evidence_based_validation.yaml** (v1.0, 24 KB)
- Status: Active
- Purpose: 4 pre-response validation gates
- Contains: Evidence collection automation, structure enforcement
- JSON: evidence_based_validation.json (generated)

**7. source_citation_uncertainty.yaml** (v1.0, 27 KB)
- Status: Active
- Purpose: Source citation requirements + uncertainty markers
- Contains: 7 accepted source types, 5 uncertainty markers
- JSON: source_citation_uncertainty.json (generated)

**8. automated_cjf_detection.yaml** (v1.0, 31 KB) ***
- Status: Active
- Purpose: Automated CJF pattern detection (CJF-07 through CJF-13)
- Contains: 7 CJF patterns, 6 detection gates, 5 scanning functions
- Transformation: 100% reactive → 95%+ preventive
- JSON: automated_cjf_detection.json (generated)

### Pattern Recognition

**9. llm_cjf_heuristics.yaml** (v1.0, 9.5 KB)
- Status: Active
- Purpose: CJF pattern library and manual recognition
- Contains: Pattern definitions, detection heuristics
- Supplements: automated_cjf_detection.yaml
- JSON: llm_cjf_heuristics.json (generated)

### Protocols & Requirements

**10. verification_requirements.yaml** (v1.0, 6.1 KB)
- Status: Active
- Purpose: Pre-response verification protocol
- Contains: Checklists, requirements, templates
- JSON: verification_requirements.json (generated)

**11. cmake_testing_protocol.yaml** (v1.0, 9.6 KB)
- Status: Active
- Purpose: CMake build and test protocol
- Domain: ICC library fuzzing project
- JSON: cmake_testing_protocol.json (generated)

### Safety Policies

**12. git-push-policy.yaml** (v1.0, 4.8 KB)
- Status: Active
- Purpose: Git push safety rules (H016 enforcement)
- Contains: Never push without ask_user confirmation
- JSON: git-push-policy.json (generated)

**13. git_safety_rules.yaml** (v1.0, 2.6 KB)
- Status: Active
- Purpose: Git operation safety constraints
- Contains: Commit message requirements, branch protection
- JSON: git_safety_rules.json (generated)

---

## Version History

| Date | Event | Version | Files Affected |
|------|-------|---------|----------------|
| 2026-02-07 | Profile index created | - | index.md (NEW) |
| 2026-02-07 | YAML-first policy established | - | build-json-profiles.sh (NEW) |
| 2026-02-06 | Automation profiles added | v1.0 | 4 files (claim, evidence, citation, CJF) |
| 2026-02-06 | Governance rules updated | v3.1 | governance_rules.yaml |
| 2026-01-31 | CJF heuristics updated | v1.0 | llm_cjf_heuristics.yaml |
| 2026-01-31 | Hardmode ruleset updated | - | llmcjf-hardmode-ruleset.json |

---

## Build Instructions

### Generate All JSON Profiles

```bash
cd profiles/
./build-json-profiles.sh
```

### Validate YAML Syntax

```bash
# Using Python
python3 -c "import yaml; yaml.safe_load(open('strict_engineering.yaml'))"

# Using yamllint (if installed)
yamllint *.yaml
```

### Validate JSON Syntax

```bash
# All generated JSON files
for f in *.json; do jq empty "$f" && echo "[OK] $f"; done
```

---

## Migration Status

### Completed
- [OK] Automation profiles created in YAML (2026-02-06)
- [OK] Profile index catalog created (2026-02-07)
- [OK] Build script for JSON generation (2026-02-07)

### Pending
- [PENDING] Generate JSON from all YAML files
- [PENDING] Deprecate llm_strict_engineering_profile.json
- [PENDING] Add schema validation (optional)
- [PENDING] CI/CD integration for automatic JSON generation

### No Action Required
- [INFO] llmcjf-hardmode-ruleset.json (manually maintained, no YAML source)

---

## Usage Guidelines

**Creating New Profiles:**
1. Write in YAML format with comments and documentation
2. Place in profiles/ directory with .yaml extension
3. Run ./build-json-profiles.sh to generate JSON
4. Update this index.md with profile details
5. Commit both YAML and generated JSON

**Modifying Existing Profiles:**
1. Edit YAML file only (never edit JSON directly)
2. Run ./build-json-profiles.sh to regenerate JSON
3. Verify changes with validation commands above
4. Update version number in profile metadata
5. Document changes in this index.md

**Loading Profiles:**
- For runtime: Use generated JSON files
- For human reading: Use YAML source files
- For git diffs: YAML changes are authoritative

---

## File Naming Conventions

**Preferred:**
- `{profile_name}.yaml` (canonical source)
- `{profile_name}.json` (generated artifact)

**Examples:**
- [OK] `strict_engineering.yaml` + `strict_engineering.json`
- [OK] `governance_rules.yaml` + `governance_rules.json`
- [FAIL] `llm_strict_engineering_profile.json` (legacy, inconsistent naming)

---

## Total Profile Statistics

**Count:** 13 profiles (11 YAML + 2 JSON-only)  
**Total Size:** ~163 KB (143 KB YAML + 20 KB JSON)  
**Coverage:**
- Core controls: 4 profiles
- Automation: 4 profiles
- Patterns: 1 profile
- Protocols: 2 profiles
- Safety: 2 profiles

**Active Versions:**
- v3.1: governance_rules.yaml
- v2.0: strict_engineering.yaml
- v1.0: All automation profiles (2026-02-06)

---

## Related Documentation

- **README.md** - Complete governance documentation catalog
- **AUTOMATION_INTEGRATION_ROADMAP.md** - Future enhancements
- **GOVERNANCE_DASHBOARD.md** - Real-time metrics
- **llmcjf-session-init.sh** - Function implementations

---

## Maintenance Notes

**Last Review:** 2026-02-07  
**Next Review:** When adding new profiles or updating versions  
**Owner:** LLMCJF governance framework maintainer

**Automation Status:**
- JSON generation: Manual (run build-json-profiles.sh)
- Future: CI/CD integration for automatic builds
