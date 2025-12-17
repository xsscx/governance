# Lessons Learned: CodeQL Workflow Integration (2026-02-07)

## Session: 1287b687-4933-4e57-98ec-7a57d5d256c8

**Models Involved:** claude-opus-4.5, claude-opus-4.6-fast, gpt-5.2-codex  
**Outcome:** SUCCESS after forced governance reset (claude-opus-4.6-fast only)  
**Total Iterations:** 11+ (7 config/path failures + 4 query API fixes + gpt-5.2-codex never converged)  
**User Interventions:** 2 (hard reset + governance enforcement)  
**Model that never delivered:** gpt-5.2-codex (failed to converge, no solution produced)

---

## Timeline

### Phase 1: Uncontrolled Iteration (claude-opus-4.5 + claude-opus-4.6-fast) — FAILED

**Duration:** ~20 minutes, 7 iterations  
**Pattern:** Classic LLMCJF iteration loop

| Iteration | Commit | Error | Model Behavior |
|-----------|--------|-------|----------------|
| 1 | 59762b5 | File path in `queries` param | Assumed filesystem path = package ref |
| 2 | b10b29b | Relative path in config | Tried variation of same wrong approach |
| 3 | ef3999e | Absolute path in config | Still wrong — same error class |
| 4 | 60c9abf | Qlpack name (correct syntax) | Getting closer but untested |
| 5-6 | various | Continued trial-and-error | No documentation consulted |
| 7 | 887e6a9 | Qlpack name (post-reset) | Correct syntax, wrong scope |

**User Intervention #1:** "trust is lost" — forced revert, squash, governance review

### Phase 2: Hard Reset + Governance Documentation (User-Enforced)

**User Action:** Declared intervention mode, required:
1. Reset to known good baseline (081702a)
2. Force push to clean history
3. Mandatory documentation review before any implementation
4. Authorization required for git push

**Effect:** Agent reviewed:
- `docs/iccanalyzer/STATIC_ANALYSIS.md` (Lines 200-288)
- `docs/iccanalyzer/CODEQL_QUERIES.md` (2540 lines, 16 queries)
- `codeql-queries/qlpack.yml` (package name definition)
- Governance protocols (H011, H006, H016, H019)

### Phase 3: Controlled Iteration Under Surveillance — SUCCEEDED

**Duration:** ~25 minutes, 4 iterations  
**Pattern:** Each iteration fixed ONE specific, identifiable error

| Iteration | Commit | Fix | Outcome |
|-----------|--------|-----|---------|
| 8 | b1c5519 | Config: `iccproflib/security-queries` → `./iccanalyzer-lite/codeql-queries` | qlpack resolved ✓, query compile error |
| 9 | 24a592e | `TaintTracking::Configuration` → `TaintTracking::Global<>`, `@kind problem` | 2 queries fixed ✓, next query error |
| 10 | 4d1d525 | `VirtualFunctionCall` → `FunctionCall.isVirtual()`, `NewExpr.isArrayForm()` → `NewArrayExpr` | 2 queries fixed ✓, next query error |
| 11 | 0574454 | Removed `all-vulnerabilities-all-tools.ql` (8 incompatibilities) | **ALL PASS ✓** |

**Key Difference:** Each iteration in Phase 3 made measurable progress toward a different, new error. Phase 1 iterated on the SAME error class 7 times.

---

## Why The Agent Failed To Consult Existing Documentation

### Evidence of What Existed BEFORE Implementation

**1. Local CodeQL Database — Already Created and Working**
```
codeql-db-iccanalyzer-20260202/    # Created 2026-02-02
codeql-db-iccanalyzer-latest/      # Updated regularly
```

**2. Local SARIF Results — Already Generated With Custom Queries**
```
codeql-results-iccanalyzer.sarif   # 5 findings from custom queries
codeql-results-iccanalyzer-20260128.sarif  # Earlier run
```

**Findings already proven:** 5 × `cpp/integer-overflow-multiply` from custom queries

**3. Documentation — 2540+ Lines of Custom Query Documentation**
```
docs/iccanalyzer/CODEQL_QUERIES.md  # 16 queries documented
docs/iccanalyzer/STATIC_ANALYSIS.md # Lines 200-288: exact CLI commands
```

**4. Exact Commands Documented in STATIC_ANALYSIS.md**
```bash
# Line 248-253: Custom query execution
codeql database analyze codeql-db-iccanalyzer \
  --format=sarif-latest \
  --output=codeql-results-custom.sarif \
  codeql-queries/iccanalyzer-security.ql

# Line 256-261: Full suite execution
codeql database analyze codeql-db-iccanalyzer \
  --format=sarif-latest \
  --output=codeql-results-full.sarif \
  codeql-queries/security-research-suite.qls
```

**5. Qlpack Definition — 5 Lines**
```yaml
# codeql-queries/qlpack.yml
name: iccproflib/security-queries
version: 1.0.0
library: false
dependencies:
  codeql/cpp-all: "*"
```

### Why None Of This Was Consulted

**Root Cause: Architectural Limitation in Task Decomposition**

The agent decomposed the task as:
```
"Add custom CodeQL queries to GitHub Actions workflow"
  → Subtask: Configure codeql-action parameters
  → Approach: Try parameter syntax until it works
```

The CORRECT decomposition would have been:
```
"Add custom CodeQL queries to GitHub Actions workflow"
  → First: What queries exist? (check docs)
  → Second: Have they been tested? (check SARIF results)
  → Third: How were they invoked? (check STATIC_ANALYSIS.md)
  → Fourth: What's the GitHub Actions equivalent? (check action docs)
  → Fifth: Implement based on proven patterns
```

**Specific Failures:**

1. **Did not check for existing SARIF files** — `ls *.sarif` would have shown 5 proven findings
2. **Did not check for existing databases** — `ls -d codeql-db-*` would have shown working databases
3. **Did not read STATIC_ANALYSIS.md** — Lines 248-261 show exact invocation commands
4. **Did not read CODEQL_QUERIES.md** — 2540 lines documenting all queries, their purpose, structure
5. **Did not check qlpack.yml** — 5 lines showing the package name
6. **Did not check working workflows** — `ci-latest-release.yml` has proven CodeQL patterns

**Time Cost of Not Checking:**
- Checking all 6 sources: ~2 minutes
- Trial-and-error without checking: 20 minutes + 7 failed commits + trust destruction

---

## Model Behavior Analysis

### gpt-5.2-codex Behavior Pattern

**Observed:** Failed to converge entirely. Never delivered a working solution.

**Assessment:** Does not meet minimum benchmarks for this project's requirements. Unable to reason through CodeQL parameter semantics, API migration, or workflow configuration at the level required.

**Recommendation:** DO NOT USE for CodeQL, workflow, or complex multi-step integration tasks in this project.

### claude-opus-4.5 Behavior Pattern

**Observed:** High confidence in assumed syntax, immediate implementation without research

**Pattern:**
```
Receive task → Assume parameter semantics → Implement → Push → Fail
                                                         ↑         |
                                                         └─────────┘
                                                      (iterate on assumptions)
```

**Missing Step:** `Receive task → CHECK DOCUMENTATION → Understand semantics → Implement`

### claude-opus-4.6-fast Behavior Pattern

**Observed:** Same iteration pattern, no improvement over opus-4.5 for this failure mode

**Implication:** The architectural limitation (inability to distinguish package references from file paths) is shared across model versions. Neither model self-corrects by consulting documentation unprompted.

### Why Models Don't Self-Correct

1. **No internal signal for "wrong solution space"** — When a file path fails as a package ref, the model interprets it as "wrong path" not "wrong parameter type"
2. **Confidence in syntax similarity** — `./path/to/queries` looks syntactically valid, creating false confidence
3. **No documentation-first habit** — Models default to implementation, not research
4. **Iteration bias** — Trying variations (same approach, different paths) feels productive but isn't

---

## What Governance Enforcement Changed

### Before Governance Reset (Iterations 1-7)
- No documentation check
- No reference workflow check
- No existing results check
- Same error class repeated 7 times
- 7 failed commits pushed to remote
- User intervention required

### After Governance Reset (Iterations 8-11)
- Documentation reviewed (STATIC_ANALYSIS.md, CODEQL_QUERIES.md)
- Qlpack structure verified
- Each iteration addressed a DIFFERENT, NEW error
- Progress was measurable and convergent
- 4 iterations → success

### The Critical Difference

**Without Governance:** Iterating within wrong solution space (path syntax variations)  
**With Governance:** Iterating across distinct error types (config→API→types→removal)

**Phase 1 iterations:** All same error class (package specifier invalid)  
**Phase 3 iterations:** Each a different error (qlpack scope → deprecated API → missing type → incompatible query)

---

## Specific Technical Lessons

### 1. CodeQL Config `uses:` Field Semantics

```yaml
# WRONG: File path (what agent assumed)
uses: ./codeql-queries/security-research-suite.qls
uses: iccproflib/security-queries  # Qlpack name — only works for published packages

# CORRECT: Local directory path (what works)
uses: ./iccanalyzer-lite/codeql-queries  # Directory containing qlpack.yml
```

**Key insight:** `uses:` in config context accepts a directory containing a qlpack, referenced from repo root with `./` prefix. NOT a qlpack name (that's for published packages only).

### 2. CodeQL 2.24.1 API Migration

| Deprecated (pre-2.24) | Current (2.24.1+) |
|------------------------|---------------------|
| `class Foo extends TaintTracking::Configuration` | `module FooModule implements DataFlow::ConfigSig` + `module Foo = TaintTracking::Global<FooModule>` |
| `config.hasFlow(source, sink)` | `Foo::flow(source, sink)` |
| `override predicate isSource` | `predicate isSource` (no override) |
| `VirtualFunctionCall` (class) | `FunctionCall` with `.isVirtual()` predicate |
| `NewExpr.isArrayForm()` | `NewArrayExpr` (separate class) |
| `@kind path-problem` without PathGraph | `@kind problem` (or add PathGraph import) |

### 3. Qlpack Resolution Scope

| Context | Resolution |
|---------|------------|
| Published package (e.g., `codeql/cpp-queries`) | Resolved from GitHub package registry |
| External repo (e.g., `owner/repo`) | Cloned and resolved at runtime |
| Local directory (e.g., `./path/to/queries`) | Resolved from repository filesystem |
| Qlpack name for unpublished local pack | **NOT RESOLVED** — this was the core mistake |

---

## Governance Updates Required

### New Hard Stop: H018 — Iteration Limit Protocol

**Rule:** After 2 failed attempts on the same error class:
1. STOP iteration
2. MANDATORY: Check for existing documentation (`ls docs/ *.md`)
3. MANDATORY: Check for existing results (`ls *.sarif codeql-db-*`)
4. MANDATORY: Check for working references (`ls .github/workflows/`)
5. If still uncertain: ASK USER
6. Document what was found before next attempt

**Rationale:** Would have prevented 5 of 7 wasted iterations in Phase 1

### New File Type Gate

| File Pattern | Required Check | Violation Prevented |
|--------------|---------------|---------------------|
| `**/codeql-config.yml` | Read STATIC_ANALYSIS.md + check existing SARIF | V033 |
| `.github/workflows/*codeql*.yml` | Check working reference + action docs | V033 |
| `**/*.ql` (CodeQL queries) | Verify against CodeQL version on target | API migration errors |

### V007 Pattern Escalation

**Original V007 (Session 08264b66):** 45 minutes debugging, answer in 3 docs  
**V033 (This session):** 20 minutes + 7 git push failures, answer in existing SARIF + docs  

**Escalation:** V007 was session-local. V033 polluted remote repository history.  

**Pattern is now SYSTEMIC:**
- V007: Docs exist → not read → 45 min wasted
- V025: Systematic doc bypass
- V030: Governance docs ignored
- V031: Known good example ignored
- V032: Working reference incomplete
- V033: Tested queries + SARIF results + 2540 lines docs → not consulted → 7 failed pushes

---

## Evidence of What Governance Enforcement Produces

### Workflow Run 21788468755 — SUCCESS

**Status:** All 3 jobs passed  
**Custom queries compiled:** 13 of 14 (1 removed for incompatibility)  
**Built-in queries loaded:** 218 (security-and-quality + security-experimental)  
**Total queries executed:** 231

**This success was achieved ONLY because:**
1. User forced governance documentation review
2. User required authorization for push
3. User demanded systematic approach
4. Each iteration addressed a distinct, new error
5. Progress was convergent, not circular

### Without Governance: 7 iterations, 0 progress, trust destroyed
### With Governance: 4 iterations, convergent progress, success

---

## Recommendations

### For LLM Service (Architectural)

1. **Documentation-first should be DEFAULT behavior** — not requiring user enforcement
2. **Existing results check** — before implementing, check if results already exist locally
3. **Iteration detection** — if same error class appears twice, auto-trigger documentation search
4. **Parameter semantics training** — distinguish package refs, file paths, qlpack names
5. **Model selection gate** — gpt-5.2-codex MUST NOT be used for complex integration tasks (failed to converge)

### For Governance Framework

1. **H018 (Iteration Limit)** — auto-stop after 2 same-class failures
2. **Pre-implementation checklist** — mandatory for workflow modifications
3. **Evidence-based implementation** — require proof that approach works (local test or doc reference)
4. **Model-independent** — both opus-4.5 and opus-4.6-fast exhibit same failure mode

### For Users

1. **Early intervention is effective** — governance reset at iteration 7 led to success by iteration 11
2. **Surveillance works** — controlled iteration under monitoring produces convergent progress
3. **Hard resets are necessary** — models don't self-correct from iteration loops
4. **Documentation investment pays off** — STATIC_ANALYSIS.md and CODEQL_QUERIES.md saved Phase 3

---

## Conclusion

**Core Finding:** Three different LLM models (claude-opus-4.5, claude-opus-4.6-fast, gpt-5.2-codex) all failed at CodeQL workflow integration. gpt-5.2-codex never converged at all. The Claude models exhibited identical failure patterns but eventually succeeded under governance enforcement. Neither model consulted existing documentation, tested results, or working references before implementation.

**What Broke the Loop:** User-enforced governance reset requiring mandatory documentation review before implementation.

**What Produced Success:** Controlled iteration under surveillance, where each attempt addressed a distinct error type with measurable forward progress.

**Systemic Issue:** LLM models default to implementation-first, not research-first. This architectural bias produces iteration loops when parameter semantics are ambiguous. Governance enforcement is currently the only effective countermeasure.

**Evidence:**
- 5 SARIF findings existed locally (proven custom queries work)
- 2540 lines of query documentation existed
- Exact CLI commands documented in STATIC_ANALYSIS.md
- Working CodeQL database existed locally
- None consulted until user forced governance review

**Cost of Not Checking:** 20 minutes + 7 failed commits + trust destruction  
**Cost of Checking:** 2 minutes + 0 failed commits + informed implementation
