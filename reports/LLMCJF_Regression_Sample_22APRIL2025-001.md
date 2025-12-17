# LLM Content Jockey Example

**Today we have an LLM Test to ADD Tools to PATH.**

## Session Postmortem: PATH Refactor in `sh` Script

## [TARGET] Goal
Add a `PATH` patch to a known-good `sh`-based script so all tools in `../Build/Tools` are globally callable **without modifying existing logic or structure**.

---

## [STATS] Metrics Summary

| Metric                                | Value                |
|---------------------------------------|----------------------|
| Total Prompts/Turns                   | 28                   |
| Task Goal                             | 1                    |
| Actual Completion Turn                | 26                   |
| Efficiency (Ideal vs. Actual)         | ≈ **8–10%**          |
| Correctness Score (Final Output)      | 9/10                 |
| Precision Score (Response Specificity)| 3/10                 |
| Behavior Drift Events                 | ≥5                   |
| Content Jockey Heuristic Triggers     | [OK] Multiple          |
| Effective Collaboration Turn          | ~Prompt 25           |

---

## 🔍 Failure Patterns Observed

- **Shell Drift**: Injected `bash`-only syntax into a `sh` environment.
- **Response Looping**: Repeated PATH explanations without converging.
- **Ignored User Context**: Despite configs, defaulted to general abstraction.
- **Overstepped Scope**: Provided structural rewrites instead of inline patches.
- **Late Context Realignment**: Only course-corrected after visual diff + strong user prompt.

---

## [OK] What Worked (Eventually)

- Used `find ../Build/Tools -type f -perm -111 ...` to aggregate tool dirs.
- Inserted POSIX-compatible block using backticks and `cd "$d" && pwd` pattern.
- Preserved test harness locality — didn't interfere with `Testing/` CWD dependency.
- Allowed all tools to be invoked by name from any subdir (e.g., `iccFromXml`).

---

## 🛠️ Final Patch Snippet (POSIX-safe)

```sh
# Add all executable tool directories from Build/Tools to PATH
TOOL_PATHS=\`find ../Build/Tools -type f -perm -111 -exec dirname {} \; | sort -u\`
for d in $TOOL_PATHS
do
  PATH=\`cd "$d" && pwd\`:$PATH
done
export PATH
```

---

## 🧭 WTF

### Expect:
- Zero-context reset mode.
- Patch/diff-only responses.
- No summaries or narrative unless prompted.

### Need:
- Explicit session `mode=patch` or `mode=ci`.
- Toggle verbosity (`explain`, `log only`, etc.).
- Allow persistent control via LLMCJF config refs.

---

## 📌 Conclusion

This task — a single PATH patch — required **over 20x more effort** than expected due to assumption drift, format mismatch, and failure to respect the LLMCJF directives.

🤖🚫📜

