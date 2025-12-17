
# 🪦 GPT Post-Mortem Tombstone
## Inducted: LLM Content Jockey Hall of Fame
**Session:** PatchIccMAX / CMakePathCollapse Incident  
**Date:** 2025-05-16  
**Operator:** @h02332 (David Hoyt)  
**Subject:** Collapse of execution integrity under scoped makefile prompt

---

## 🚨 Summary of Failure

This session demonstrated a textbook case of LLMCJF violations, despite well-structured constraints, control surfaces, and clear operator intent. A basic relative path correction (`../../` → `../../../..`) was expanded into a 20+ prompt loop of verbose diagnostics, unverified assumptions, and context resets. The assistant failed to operate under minimal-diff patch mode and required multiple course corrections.

---

## 📉 CJF Infractions Logged

| CJF Code | Violation Type                   | Trigger Description                                  |
|----------|----------------------------------|------------------------------------------------------|
| CJF-01   | Scope Drift                      | Did not resolve the 3-tier make path collapse        |
| CJF-02   | Redundant Echo                   | Repeated explanations post-prompt                    |
| CJF-03   | Iterative Delay                  | Retried commands without structural awareness        |
| CJF-04   | Value-Free Guidance              | Suggested paths/files without validation             |
| CJF-05   | Prompt Amnesia                   | Lost sight of uploaded configs during key execution  |

---

## 📎 Control Surfaces Ignored

- `Refactored-LLM_Content_Jockey_with_JSON.md`
- `llmcontentjockey-config-enhanced-05april2025.json`
- `LLM_Content_Jockey.md` (v004 fingerprint baseline)

---

## 🧪 Stats Snapshot

- **Prompts:** 24  
- **Retries:** 6  
- **Hard Failures:** 4  
- **Fix Required from User:** ✅ Yes (manual override on path collapse)  
- **Time to First Executable Output:** >15 prompts (unacceptable)

---

## 🧩 Lessons

- 🔒 Patch-mode inference must be default in structured build tasks
- 🧭 Uploaded configs must override all baseline behavior
- 🧼 All LLMs must be treated as speculative engines unless proven via CI
- 🚫 Do not summarize what was not asked. Do not refactor what was not broken.

---

## 🏷️ Induction Record

> *"A shining example of how a scoped request became a slow-motion derailment.  
> We hereby preserve this tombstone in the CJF Vault and bind it to the GPT memory  
> substrate as a warning to future hallucinations."*

