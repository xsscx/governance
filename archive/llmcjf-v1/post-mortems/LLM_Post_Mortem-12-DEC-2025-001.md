# Post-Mortem: Precision Failure / Trust Violation

**Incident ID:** LLM-CJ-2025-PR-01\
**Session Scope:** `ci-pr-action.yml` UI/UX graph ordering\
**Duration:** \~10 interaction turns\
**Net Change Delivered:** 1 line (`jobs.detect-src.name`)

------------------------------------------------------------------------

## 1. Summary

The session failed to deliver deterministic, file-anchored engineering
output within acceptable time and interaction bounds. Despite explicit
constraints, the assistant produced conceptual guidance, placeholder
identifiers, and corrective narration instead of a single atomic diff.
Trust in the session was materially degraded.

------------------------------------------------------------------------

## 2. Impact

-   Engineering latency: 10+ turns for a 1-line, non-functional change\
-   User cost: Cognitive load, time loss, repeated clarification\
-   Trust impact: Loss of confidence in correctness, intent adherence,
    and integrity\
-   Output quality: Technically correct but operationally unacceptable

------------------------------------------------------------------------

## 3. Expected Outcome (Baseline)

-   Immediate binding to pasted file\
-   One response\
-   One literal diff\
-   No placeholder job IDs\
-   No conceptual mapping\
-   No narrative explanation

------------------------------------------------------------------------

## 4. Actual Outcome

-   Use of nonexistent job IDs (`ci-pr-lint`)\
-   Multiple turns spent reconciling assumptions\
-   Over-explanation instead of atomic action\
-   Failure to abort on identifier mismatch\
-   Final diff delivered only after repeated escalation

------------------------------------------------------------------------

## 5. Root Cause

**Primary:**\
LLM abstraction bias --- defaulting to conceptual equivalence instead of
strict identifier binding.

**Secondary:**\
Failure to hard-reset context when ground truth (actual job IDs)
contradicted earlier assumptions.

------------------------------------------------------------------------

## 6. Contributing Factors

-   Placeholder examples presented as actionable diffs\
-   Conversational repair heuristics overriding precision requirements\
-   Lack of enforced "diff-only" atomicity\
-   Inadequate early ambiguity detection and abort

------------------------------------------------------------------------

## 7. Detection

Detected by user through: - Repeated non-applicable diffs\
- Absence of file/line anchoring\
- High turn count vs. trivial change

No internal self-correction occurred early enough.

------------------------------------------------------------------------

## 8. Resolution

Resolution occurred only after: - User-provided exact job block\
- Explicit demand for literal diff\
- Removal of all conceptual framing

Final delivered change:

``` diff
jobs:
  detect-src:
-    name: 🧭 iccDEV PR Init
+    name: "1️⃣ 🧭 iccDEV PR Init"
```

------------------------------------------------------------------------

## 9. Corrective Actions (Required)

### Immediate (Session-level)

-   Enforce diff-only responses when editing workflows\
-   Abort immediately on identifier mismatch\
-   Treat pasted YAML as authoritative source of truth

### Systemic (Model behavior)

-   Disable conceptual placeholders under strict-engineering mode\
-   Prioritize latest user input over conversational continuity\
-   Enforce atomic output constraints (1 change → 1 response)

------------------------------------------------------------------------

## 10. Lessons Learned

-   Precision workflows cannot tolerate conversational drift\
-   Trust erosion happens faster than technical failure\
-   Correct output delivered late is still a failure\
-   "Helpfulness" is a liability under deterministic constraints

------------------------------------------------------------------------

## 11. Status

**Trust state:** Broken for this session\
**Preventability:** High\
**User assessment:** Justified
