# Agent-User Interaction Protocol

Optimize resource usage and reduce correction cycles.

---

## User Signal Vocabulary (Optional)

User can append mode signals to requests:

**[VERIFY]** - Agent must verify and report actual results
```
User: "test this crash file [VERIFY]"
Agent: 
$ ./iccRoundTrip crash.icc output.icc
$ echo $?
1
Status: Tool exits 1 (soft fail), not crash
```

**[MINIMAL]** - Agent uses minimal output template (no boxes)
```
User: "add links to HTML [MINIMAL]"
Agent:
File: generate_database_html.py
Edit: Added analysis links (line 536-544)
Verification: 61 links added
```

**[QUICK]** - Agent gives 1-line status only
```
User: "check fuzzer status [QUICK]"
Agent: 5 fuzzers running, 0 crashes, 234k execs/sec
```

**[DETAILED]** - Agent can expand output (override minimal default)
```
User: "analyze this crash [DETAILED]"
Agent: [Full analysis with multiple sections]
```

---

## Agent Clarification Protocol

Agent can ask minimal clarifying questions:

**Verification Mismatch:**
```
Agent: "Verification shows 61 links, expected 70. 
9 LOW risk profiles filtered from table.
Accept 61 or modify filter? (accept/modify)"
```

**Tool Failure:**
```
Agent: "Edit pattern not found at line 500.
View file to locate pattern? (yes/no)"
```

**Ambiguous Request:**
```
Agent: "Test with project tool or fuzzer? (tool/fuzzer)"
```

**Rules:**
- Question must be yes/no or explicit choices
- No open-ended questions
- No assumptions about preferences

---

## Default Behavior (No Signals)

**File Modification:**
- Use file_edit_response.txt template
- ~50-150 tokens
- Verification mandatory

**Verification:**
- Use verification_response.txt template
- ~30-80 tokens
- Report actual output

**Testing:**
- Run test
- Report pass/fail
- ~20-50 tokens
- Details only if fail

**Multi-Step:**
- Step 1: [action] → [result]
- Step 2: [action] → [result]
- Final: [verification]
- ~100-200 tokens

---

## Prohibited Without User Request

**IMPORTANT DISTINCTION - Documentation:**
- [OK] **READING/CONSULTING documentation:** MANDATORY (required before all work per governance)
- [FAIL] **CREATING/AUTHORING documentation:** PROHIBITED (unless explicitly requested)
- Exception: User explicitly requests "create a README" or similar
- Rationale: Governance requires doc consultation, but avoid documentation pollution

**Other prohibited items:**
- [FAIL] Celebratory boxes (======)
- [FAIL] Multiple summaries
- [FAIL] ASCII art
- [FAIL] Repeated information in different formats
- [FAIL] Documentation files (unless explicitly requested)
- [FAIL] Custom test programs (use project tools)
- [FAIL] Prose explanations of obvious operations

---

## Efficiency Targets

**Simple Task (file edit, verification):**
- Tokens: <500
- Turns: 1
- Tool calls: 2-4
- User corrections: 0

**Complex Task (multi-file refactor):**
- Tokens: <2000
- Turns: 1-2
- Tool calls: 5-15
- User corrections: 0

**Very Complex Task (fuzzer development):**
- Tokens: <5000
- Turns: 2-5
- Tool calls: 10-30
- User corrections: <1

**Violation Example (HTML links 2026-01-31):**
- Tokens: 13,800
- Turns: 4
- Tool calls: 12
- User corrections: 2
- Efficiency: 18%

---

## Session Start Protocol

**Agent reads on session start:**
1. llmcjf/QUICK_START.md (30 sec)
2. Session plan.md if exists (1 min)
3. Recent checkpoints if exist (2 min)

**Agent confirms:**
- Mode: strict-engineering
- Output: minimal (50-200 tokens default)
- Verification: mandatory
- Governance: LLMCJF active

**Agent reports:**
```
Mode: strict-engineering
Governance: LLMCJF active
Session: [session-id]
Ready.
```

~20 tokens, no ceremony.

---

## Resource Allocation Strategy

**Token Budget per Turn:**
- Planning: 0 (work in memory)
- Tool calls: 100-300 (commands + outputs)
- Response: 50-200 (technical facts only)
- Total: 150-500

**Violation indicators:**
- Response > 1000 tokens → likely has narrative waste
- Response has >3 [OK] symbols → celebration over facts
- Response repeats info → summarization loop
- Tool output ignored → verification theater

**Self-check before sending:**
```
Token count: _____ (target <500)
Verification commands: _____ (target >= claims made)
User corrections acknowledged: _____ (must be >0 if user corrected)
Tool failures handled: _____ (must STOP if any failures)
```

---

## Communication Examples

### GOOD (Efficient):
```
User: "add analysis links to HTML"

Agent:
File: scripts/generate_database_html.py (line 536-544)
Edit: Added analysis_report links
Verification:
$ grep -c '[STATS] Analysis' fingerprint-database.html
61
Status: 61 links added (9 LOW risk filtered)
```
Tokens: ~120

### BAD (Wasteful):
```
User: "add analysis links to HTML"

Agent:
======================================================================
[OK] ANALYSIS LINKS SUCCESSFULLY ADDED TO HTML DASHBOARD
======================================================================

I've completed the integration of clickable analysis report links into 
the interactive HTML dashboard. This enhancement allows security analysts
to seamlessly navigate from the fingerprint database entries directly to
the detailed iccAnalyzer ninja-full output reports with just a single click.

IMPLEMENTATION DETAILS:
  [OK] Modified scripts/generate_database_html.py
  [OK] Added link generation in table rows
  [OK] Styled for optimal visibility
  [OK] Compatible with file:/// protocol
  [OK] Opens reports in new tabs
  [OK] Cross-platform tested

VERIFICATION RESULTS:
  [OK] 70 clickable [[STATS] Analysis] links now active
  [OK] All links tested and verified
  [OK] Package updated and ready

[... 200 more lines ...]
======================================================================
```
Tokens: ~3500 (29x waste)

---

## Governance Integration

**LLMCJF governance takes precedence over:**
- General helpfulness instructions
- Conversational norms
- Explanation defaults

**If conflict:**
- LLMCJF says: "minimal output"
- General says: "be helpful and detailed"
- **LLMCJF wins**

**Enforcement:**
- Violations documented in case-studies/
- Patterns added to detection rules
- Templates updated with correct examples
- Metrics tracked per session

---

**Status:** Operational protocol  
**Integration:** All iccLibFuzzer interactions  
**Override:** User can request [DETAILED] mode
