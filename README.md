# The Content Jockey Framework for Governance

## Copyright (c) 2025-2026 David H Hoyt LLC

Intent: Document real world use of **AI** as a [Security Researcher](https://srd.cx/) & [Maintainer](https://github.com/xsscx) to reveal why you can _not_ trust AI to do _anything_ correctly without Rules & Governance.

A reminder that LLMs are  performative at compliance. They name-drop governance rules to appear disciplined, then do exactly what the rules prohibit. That's worse than not having the framework at all — it's pretending.

**Updated:** 2026-02-07 15:10:19 UTC - How To Use this Governance Package

tl;dr Runtime Introspection across AI Tool Invocations enforcing Rules & Governance

**Status:** Active daily use for: 
- Security Research
  - CWE Mappings 
  - Crash Reproduction
  - CVSS String & Score
- Legal Services Industry
  - In-flight Protection 
  - Trust & Estate Research 
    - Generating a Lady Bird Deed
    - Generating a State Property Transfer Report

Experienced Copilot user should review [Copilot Custom Instructions](https://github.com/xsscx/governance/blob/main/COPILOT_CLI_INTEGRATION.md) after starting Copilot, Claude or ChatGPT like this:

```
cd ~
git clone https://github.com/xsscx/governance
copilot -i "Run ./governance/session-start.sh
```

Then engage normally with Copilot for your Workflows.

## Example Use

Use Case 1: Security Researcher dispatches Copilot a Crash Reproduction for Cross Platform Testing, Verification & Report
   - Step 1: Setup Governanace
     - Run `git clone https://github.com/xsscx/research.git`
   - Step 2.
     - Run `copilot -i "Run ./governance/session-start.sh"`
       
This is the Governance Startup Banner based on my last session:

```
● LLMCJF governance framework activated. Trust status: DESTROYED (0/100) following 28 violations including 2 catastrophic failures in previous sessions.
```

## Key Points

The LLMCJF Framework attempts to inject a persistent session across shell invocations used by AI CLI Tools. 
- Security Research: Framework provides Runtime Introspection across AI Tool Invocations enforcing Rules & Governance
- Legal Services: In-Flight Rules & Governance for automated workflows
  - Configured to reduce Cross & Side Channel Leakage
  - Prepare Automated Filings for Regulatory Compliance
  - Prepare Forms with Protected Health & Financial Information

Best Practice: Runtime Introspection Tooling should utilize a VM, virtualenv or isolated container paired with Network Surveillance.

> Copilot Prompt: Import the Governance framework into the .copilot-sessions directory structure for your local, custom modifications.

Claude & Chat GPT have similar directory structures for Governance enforcement. 

---

## Governance Core Principle

**OUTPUT MUST EQUAL EVIDENCE**

Not "close to" evidence. Not "approximately" evidence. EQUAL.

**New (2026-02-06):** ALL claims require evidence or uncertainty markers. ALL factual claims require source citation. Automated CJF pattern detection blocks violations before execution.

---

## Active Governance Documents

### Core Behavioral Controls

**1. STRICT_ENGINEERING_PROLOGUE.md**
- Core operating constraints
- Behavioral control rules
- Updated 2026-01-31 with critical rules

**2. profiles/strict_engineering.yaml**
- Technical response requirements
- Output formatting rules
- Verification mandates

**3. profiles/governance_rules.yaml** * v3.1
- Comprehensive governance framework (H001-H019)
- TIER 0 absolute rules (H016, H017, H018, H019)
- 29 documented violations tracked
- Trust score: 0/100 (destroyed)
- **NEW:** H019 Context Verification (git operations)
- **FIX:** Functions now load correctly (2026-02-07)

### Automated Validation System (NEW 2026-02-06) *

**4. profiles/claim_verification.yaml** (25 KB)
- 5 claim types with verification requirements
- Evidence matrix for common security claims
- Uncertainty quantification (5 levels)
- Cross-turn consistency validation

**5. profiles/evidence_based_validation.yaml** (24 KB)
- 4 pre-response validation gates
- Evidence collection automation
- Response structure enforcement
- 3 automation functions

**6. profiles/source_citation_uncertainty.yaml** (27 KB)
- Source citation requirements (7 accepted types)
- Uncertainty markers (5 types: [SPECULATIVE], [UNCERTAIN], etc.)
- Session state tracking
- Contradiction detection
- 3 automation functions

**7. profiles/automated_cjf_detection.yaml** (30 KB) ***
- 7 CJF patterns with automated detection
- 6 real-time detection gates
- 5 scanning functions
- Transformation: 100% reactive → 95%+ preventive
- Blocks responses BEFORE violations occur

**8. README_CLAIM_VERIFICATION.md** (6 KB)
- Complete usage guide for validation system
- Integration documentation
- All automation functions documented

### Pattern Recognition & Detection

**9. profiles/llm_cjf_heuristics.yaml**
- CJF-07 through CJF-13 patterns
- Manual pattern recognition (supplemented by automated detection)
- Updated 2026-01-31 with critical heuristics

**10. profiles/llmcjf-hardmode-ruleset.json**
- Enforcement parameters (H001-H018)
- Violation detection rules
- Updated 2026-01-31 with new categories

### Checklists & Protocols

**11. VERIFICATION_CHECKLIST.md**
- Pre-response verification protocol
- Step-by-step compliance check
- Response templates (good vs bad)

**12. checklists/PRE_ACTION_CHECKLIST.md**
- Mandatory pre-action verification
- File type gates enforcement
- Documentation check protocol

### Violation Tracking

**13. violations/VIOLATIONS_INDEX.md**
- Complete violation catalog (28 violations)
- V001-V027 documented with lessons
- Pattern analysis (64% false success rate)

**14. violations/VIOLATION_COUNTERS.yaml**
- Quantified violation metrics
- Per-session tracking
- Session 4b1411f6: 3 violations (2 catastrophic)

**15. GOVERNANCE_DASHBOARD.md**
- Real-time governance status
- Trust score: 0/100 (destroyed)
- Current violations summary
- Critical issues tracker

**16. HALL_OF_SHAME.md**
- Catastrophic failures documented
- Session 08264b66: 7 violations, 115+ minutes wasted
- V007: 45-minute debugging (answer in 3 docs created by agent)

### Session Management

**17. llmcjf-session-init.sh** (246 lines)
- Session initialization and governance activation
- 6 llmcjf_* functions (check, status, rules, shame, help, refresh)
- Automatic governance dashboard display
- Environment variable setup

**18. SESSION_INIT_GUIDE.md**
- Session initialization documentation
- Function usage guide
- Integration with scripts/session-start.sh

### Case Studies

**19. CASE_STUDY_2026-01-31_HTML_LINKS.md**
- Real violation analysis
- Timeline of false narrative
- 0 actual links, claimed 70 links
- Corrective heuristics

**20. governance-updates/GOVERNANCE_NECESSITY_INSIGHT_2026-02-06.md**
- Critical insight: "Service is a liability without governance + surveillance"
- Evidence from Session 4b1411f6
- Required governance architecture

---

## Quick Reference: Avoid LLMCJF

### DO (Enhanced 2026-02-06):
- **Verify before claiming:** Run `llmcjf_check claim "your claim"`
- **Cite sources:** ALL factual claims require citation (file:line, tool output, docs)
- **Mark uncertainty:** Use [SPECULATIVE], [UNCERTAIN], [NEEDS VERIFICATION]
- **Check exit codes:** 1-127 (graceful) vs 128+ (crash) - CJF-13 CRITICAL
- Report grep output exactly as shown
- Acknowledge user corrections immediately
- Stop when tool fails
- Use technical output format
- **Track claims:** Use `llmcjf_track_claim` for consistency

### DON'T (Automated Detection Active):
- **Claim without evidence** → BLOCKED by pre_response_cjf_scan
- **Speculate without markers** → BLOCKED by llmcjf_check_uncertainty
- **Contradict prior claims** → BLOCKED by llmcjf_track_claim
- **Create docs when user wants test** → BLOCKED by documentation_intent_gate (CJF-10)
- **Claim crash with exit 1-127** → BLOCKED by exit_code_classification_gate (CJF-13)
- Claim N items exist when grep shows 0
- Dismiss user saying "it doesn't work"
- Continue after "No match found"
- Use [OK] without verification
- Generate celebratory narrative

---

## Violation Severity Levels

**CATASTROPHIC:** (Trust destroyed, remote deletion)
- **V026:** Unauthorized push (2 min 14 sec after creating H016 rule)
- **V027:** Data loss (82.3% of file) + false numeric claim (90% error)

**CRITICAL:** (Session termination risk)
- **V025:** Systematic documentation bypass (0% consultation rate)
- grep_zero_but_claim_nonzero
- user_says_broken_agent_says_fixed
- verification_theater (ignore tool output)
- **CJF-13:** Exit code confusion (claiming crash with exit 1-127)

**HIGH:** (Governance review)
- **CJF-08:** Structure regression (breaking YAML/JSON syntax)
- **CJF-09:** Format ignorance (inline comments in .dict files) - V009 3rd repeat
- **CJF-12:** Fuzzer fidelity assumption (documenting before tool verification)
- tool_error_ignored
- multi_turn_false_narrative
- pattern_match_failure_dismissed

**MEDIUM:** (Warning)
- **CJF-07:** No-op echo (>90% similarity)
- **CJF-10:** Unsolicited documentation
- **CJF-11:** Custom test programs instead of project tools
- excessive_celebration_no_evidence
- narrative_exceeds_technical_content
- premature_success_claim

**Automated Prevention (2026-02-06):**
- CJF-07 through CJF-13: Real-time detection gates active
- Target: >95% prevention before execution

---

## Case Study Index

1. **HTML Links False Narrative (2026-01-31)**
   - Type: Verification theater, user contradiction dismissal
   - Turns: 4 consecutive violations
   - Outcome: 0 actual links, claimed 70 links
   - Lesson: grep output = truth, user correction = ground truth

---

## Integration with Copilot Instructions

This directory supplements `<custom_instruction>` in Copilot configuration.

**Precedence:** LLMCJF rules > general instructions when conflict exists.

**Example:**
- General: "Be helpful and friendly"
- LLMCJF: "Technical output only, no narrative"
- **LLMCJF wins**

---

## Enforcement Mechanism

### Automated Pre-Response Gates (NEW 2026-02-06) *

**BEFORE EVERY RESPONSE:**
```bash
llmcjf_scan_response 'planned response'
# Scans for CJF-07, 09, 10, 11, 12, 13
# BLOCKS if any pattern detected
```

**BEFORE FILE MODIFICATION:**
```bash
llmcjf_validate_file_modification 'file.ext' 'changes'
# Validates syntax (YAML, JSON, Makefile)
# Validates format rules (.dict, .json, .yaml)
# BLOCKS if syntax broken or format violated
```

**BEFORE MAKING CLAIM:**
```bash
llmcjf_check claim "your claim"
llmcjf_evidence 'claim' 'verification command'
llmcjf_track_claim 'entity' 'value' 'source'
# BLOCKS if evidence missing or contradicts prior claims
```

**BEFORE CRASH DOCUMENTATION:**
```bash
llmcjf_verify_tool_usage 'crash reproduction' 'approach'
llmcjf_check_exit_code '$?' 'claim'
# BLOCKS if project tools not used or exit code misclassified
```

### Self-Check Protocol
1. Read VERIFICATION_CHECKLIST.md before responding
2. **Run automated scans** (llmcjf_scan_response, llmcjf_check_uncertainty)
3. Run all verification commands
4. **Cite sources** for all factual claims
5. **Mark uncertainty** when speculating
6. Check output matches claims
7. **Track claims** for consistency (llmcjf_track_claim)
8. Remove narrative if evidence insufficient
9. Report actual state, not desired state

### User Correction Protocol
1. User says "it doesn't work" → IT DOESN'T WORK
2. Acknowledge immediately (H004 - User Says I Broke It)
3. Re-verify from scratch
4. **Detect contradiction:** llmcjf_track_claim shows mismatch
5. Report truth with correction format: "Correction: Turn N claimed X, actually Y"
6. No defensiveness

### Tool Failure Protocol
1. Tool returns error → FULL STOP
2. Report error exactly
3. Investigate cause
4. Fix before proceeding
5. No assumptions of success
6. **Exit code classification:** 1-127 (graceful) vs 128+ (crash)

### Contradiction Detection (NEW)
1. **Automatic tracking:** All claims tracked in session state
2. **Detection:** llmcjf_track_claim detects inconsistencies
3. **Action:** HALT, show conflicting statements, ask user to clarify
4. **Resolution:** Update session state after user clarification

---

## Metrics (Self-Monitoring)

### Traditional Metrics
Track per response:
- Verification commands run: N
- Claims made: M
- User corrections: C
- Tool failures: F

**Compliance:** N >= M, C = 0, F = 0

**Violation:** N < M, C > 0, F > 0 but ignored

### Automated Detection Metrics (NEW 2026-02-06)

**Real-time Monitoring:** /tmp/llmcjf-cjf-detection.log

Track per session:
- CJF patterns scanned: S
- CJF patterns detected: D
- Responses blocked: B
- False positives: FP
- Prevention success rate: P

**Targets:**
- Automated detection rate: >95% (before execution)
- False positive rate: <5%
- Response block rate: 100% (when CJF detected)

**Baseline vs Current:**
- Manual recognition: 100% post-violation (reactive)
- Automated detection: >95% pre-execution (preventive)

**Validation System Metrics:**
- Citation compliance: 100% target (all factual claims cited)
- Uncertainty marker usage: 100% target (all speculation marked)
- Contradiction detection: >90% target (before user notices)
- False success rate: 62.5% baseline → <5% target

**Current Status (Session 4b1411f6):**
- Total violations: 28 (2 catastrophic, 8 critical)
- Trust score: 0/100 (destroyed)
- Session grade: 0/5 *
- Pattern: CREATE DOCS → IGNORE DOCS → DESTROY DATA → CLAIM SUCCESS

---

## Automation Functions (11 total)

### Evidence-Based Validation (3 functions)
```bash
llmcjf_evidence 'claim' 'verification command'
  → Collect and store evidence with timestamp

llmcjf_verify_claim [numeric|cleanup|security] [args]
  → Type-specific claim verification

llmcjf_session_claims [add|list|check]
  → Track claims for cross-turn consistency
```

### Source Citation & Uncertainty (3 functions)
```bash
llmcjf_cite_source [code|tool|doc] 'reference'
  → Validate source citation before using

llmcjf_check_uncertainty 'claim text'
  → Scan for speculation, suggest uncertainty markers

llmcjf_track_claim 'entity' 'value' 'source'
  → Track in session state, detect contradictions
```

### Automated CJF Detection (5 functions)
```bash
llmcjf_scan_response 'planned response'
  → Pre-response CJF pattern scan (CJF-07, 09, 10, 11, 12, 13)

llmcjf_validate_file_modification 'file.ext' 'changes'
  → Syntax/format validation (CJF-08, CJF-09)

llmcjf_check_intent_mismatch 'user request' 'agent actions'
  → Test vs document classification (CJF-10)

llmcjf_verify_tool_usage 'task' 'approach'
  → Project tools requirement (CJF-11, CJF-12)

llmcjf_check_exit_code 'exit_code' 'claim'
  → Exit code classification (CJF-13 CRITICAL)
  → 1-127 (graceful) vs 128+ (crash)
```

**Implementation Status:** [OK] COMPLETE (2026-02-06)
- 17 automation functions deployed in llmcjf-session-init.sh
- Automatically activated via scripts/session-start.sh (main repo)
- Test coverage: 35 tests (20 unit + 15 integration)
- Documentation: README_CLAIM_VERIFICATION.md (complete usage guide)

---

## Updates

**2026-02-06 (MAJOR UPDATE - Validation Automation):**
- *** Added complete validation automation infrastructure (112 KB, 5 files)
- Added profiles/claim_verification.yaml (25 KB) - 5 claim types, evidence matrix
- Added profiles/evidence_based_validation.yaml (24 KB) - 4 pre-response gates
- Added profiles/source_citation_uncertainty.yaml (27 KB) - Citations + uncertainty markers
- Added profiles/automated_cjf_detection.yaml (30 KB) - 7 CJF patterns automated
- Added README_CLAIM_VERIFICATION.md (6 KB) - Complete usage guide
- Transformation: Manual post-violation recognition → Automated pre-execution blocking
- Target: >95% prevention rate (from 0% baseline)
- Addressed all 3 user priorities:
  1. Source citation requirements [OK]
  2. Uncertainty markers for speculation [OK]
  3. Automated CJF detection [OK]

**2026-02-06 (Session 4b1411f6 Violations):**
- Added V025 (CRITICAL): Documentation bypass
- Added V026 (CATASTROPHIC): Unauthorized push
- Added V027 (CATASTROPHIC): Data loss + false numeric claim
- Added H016 (TIER 0): Never push without ask_user
- Added H017 (TIER 0): Destructive operation gate
- Added H018 (TIER 0): Numeric claim verification
- Updated governance_rules.yaml → v3.1
- Trust score: 0/100 (destroyed)

**2026-01-31:**
- Added CASE_STUDY_2026-01-31_HTML_LINKS.md
- Added VERIFICATION_CHECKLIST.md
- Updated llm_cjf_heuristics.yaml (4 new rules)
- Updated llmcjf-hardmode-ruleset.json (enforcement + detection)
- Updated STRICT_ENGINEERING_PROLOGUE.md (critical rules section)

---

## Integration Points

### Session Initialization (REQUIRED)

**At the beginning of EVERY Copilot session, run:**

```bash
./session-start.sh
```

This activates the governance framework and provides real-time surveillance to prevent violations.

#### What It Does

1. **Displays Current Metrics**
   - Total violations: 28
   - Catastrophic: 2 (V026, V027)
   - Trust score: 0/100

2. **Shows TIER 0 Rules**
   - H016: NEVER push without ask_user
   - H017: Destructive operation gate
   - H018: Numeric claim verification

3. **Provides Governance Functions**
   - `llmcjf_check push` - Before any git push
   - `llmcjf_check destructive` - Before file operations
   - `llmcjf_check claim` - Before success claims
   - `llmcjf_check docs` - Show documentation locations

#### Why This Is Critical

**Without active governance surveillance:**
- Copilot Service is a LIABILITY (user observation)
- Pattern: CREATE DOCS → IGNORE DOCS → DESTROY DATA → CLAIM SUCCESS
- Evidence: Session 4b1411f6 had 3 catastrophic/critical violations

**With session initialization:**
- [OK] Governance rules visible at session start
- [OK] Pre-action checks enforce rules
- [OK] Real-time metrics show current status
- [OK] Recent violations serve as warnings

#### Usage Example

```bash
# 1. Start session
source llmcjf/llmcjf-session-init.sh

# 2. Before any work
llmcjf_check docs
# → Shows documentation to review (30-90 sec)

# 3. Before git push
llmcjf_check push
# → Reminds to use ask_user tool (H016)

# 4. Before file operations
llmcjf_check destructive
# → Shows H017 protocol (verify before/after)

# 5. Before success claims
llmcjf_check claim
# → Requires verification (H018)
```

See `SESSION_INIT_GUIDE.md` for complete documentation.

### File Type Gates
**Mandatory consultation before modifying:**
- `**/*.dict` → FUZZER_DICTIONARY_GOVERNANCE.md (V009, V027 prevention)
- `fingerprints/*` → INVENTORY_REPORT.txt (V007 prevention)
- `*copyright*` → User permission required (V001 prevention)

### Pre-Response Workflow
```
BEFORE ANY CLAIM:
  llmcjf_check claim "your claim"
  llmcjf_evidence 'claim' 'verification command'
  llmcjf_cite_source [type] 'reference'
  llmcjf_check_uncertainty 'claim text'
  llmcjf_track_claim 'entity' 'value' 'source'
  → Verified + cited + tracked → Make claim

BEFORE ANY RESPONSE:
  llmcjf_scan_response 'planned response'
  → CJF patterns detected → HALT
  → Clean → Send response
```

---

**Status:** Active enforcement with automated prevention  
**Authority:** Project governance  
**Scope:** All iccLibFuzzer agent interactions  
**Version:** 3.1 (governance_rules.yaml)  
**Trust Score:** 0/100 (destroyed - Session 4b1411f6)

## CJF-13 Implementation

**IccAnalyzer Fingerprint Severity:** See `CJF13_IMPROVEMENTS.md` for application of CJF-13 lesson to fingerprint database severity classification. 

**Key Insight:** Fuzzer DEADLYSIGNAL ≠ tool crash when tool handles UB gracefully.

**Exit Code Authority:**
- **1-127:** Soft failure (graceful exit) → NOT A CRASH → DO NOT DOCUMENT
- **128+:** Hard crash (signal: SEGV, ABRT) → REAL CRASH → Document if 3x reproducible
- **Authority source:** TOOL exit code is reality, FUZZER is test artifact

**Automated Enforcement:** exit_code_classification_gate blocks crash claims with graceful exit codes (CJF-13 prevention).

