# H020: Trust Authoritative Sources

**Category:** Information Verification  
**Severity:** HIGH  
**First Identified:** 2026-02-03 (Session e99391ed)  
**Type:** Positive Learning (Correction Cycle)

## Pattern Description

When making claims about system capabilities or limitations, verify against authoritative sources in this order:

1. **GitHub Actions workflows** (`.github/workflows/*.yml`) - CI/CD configuration is executable truth
2. **CMakeLists.txt / build scripts** - Implementation is authoritative over assumptions
3. **Official documentation** - Project docs, library docs, language specs
4. **Source code** - Code doesn't lie
5. **Assumptions** - Lowest priority, always verify

## Case Study: WASM ASAN Support

### Initial Incorrect Assessment
**Claim:** "WASM ASAN not supported by Emscripten"  
**Basis:** Assumption based on common WASM limitations

### User Correction
**Source:** `https://github.com/InternationalColorConsortium/iccDEV/actions/workflows/wasm-latest-matrix.yml`  
**Evidence:** Workflow explicitly tests WASM with `-fsanitize=address`

### Verification Process
1. Read GitHub Actions workflow (authoritative source)
2. Test build with ASAN flags
3. Verify instrumentation in output binaries
4. Confirm runtime behavior
5. Document findings

### Results
- [OK] WASM ASAN fully supported via Emscripten
- [OK] Binary instrumentation confirmed (`__asan_loadN`, `__asan_storeN`)
- [OK] All 14 tools built and tested successfully
- [OK] Size overhead: 11MB vs 575KB (19x, expected for sanitizer)

## Implementation

### Before Making Claims
```bash
# CHECK authoritative sources FIRST
git ls-files | grep -E '\.(yml|yaml)$' | xargs grep -i "asan\|ubsan\|sanitizer"
grep -r "CMAKE_BUILD_TYPE\|ENABLE_ASAN" CMakeLists.txt
cat .github/workflows/*.yml
```

### When User Corrects You
1. **Acknowledge** - User provided authoritative source
2. **Verify** - Test against that source directly
3. **Document** - Record findings for future reference
4. **Update** - Adjust mental model and governance if needed

### Correction Cycle (Healthy Pattern)
```
User Request → Initial Assessment → User Correction (with source)
       ↓                                      ↓
Verify Source → Test Implementation → Confirm Results → Document
```

This is **NOT a violation** - it's iterative refinement. The key is:
- Accept corrections gracefully
- Verify against authoritative sources
- Update understanding
- Document for future

## Authoritative Source Hierarchy

### CI/CD Configuration (HIGHEST AUTHORITY)
- `.github/workflows/*.yml` - What actually builds in CI
- `.gitlab-ci.yml`, `Jenkinsfile`, etc.
- These files represent **tested, working configurations**

**Why authoritative:** If it's in CI, it's been tested repeatedly and must work.

### Build System Configuration
- `CMakeLists.txt` - What the build system does
- `Makefile`, `build.gradle`, `package.json` scripts
- Compiler/linker flags in actual use

**Why authoritative:** Implementation defines capability, not documentation.

### Official Documentation
- Project README, CONTRIBUTING guides
- Library/framework official docs
- Language specifications

**Why useful:** Intended design and usage patterns.

### Source Code
- Actual implementation
- Test files showing usage
- Example code

**Why authoritative:** Code is ground truth for what exists.

### Assumptions (LOWEST PRIORITY)
- "I think X doesn't support Y"
- "Typically Z isn't available in W"
- "Usually this doesn't work"

**Why risky:** Assumptions can be outdated, incomplete, or wrong.

## Red Flags (Check Sources)

Watch for these phrases that indicate unverified claims:
- "WASM doesn't support..."
- "Emscripten can't handle..."
- "This platform doesn't have..."
- "I don't think X works with Y..."

**Action:** Search authoritative sources BEFORE making negative claims.

## Examples

### Good: Checking Before Claiming
```bash
# User asks: "Does this project support WASM ASAN?"
# GOOD: Check workflow first
cat .github/workflows/wasm-*.yml | grep -i asan
# Found: -DENABLE_ASAN=ON in matrix
# Answer: "Yes, confirmed in CI workflow"
```

### Bad: Assuming Without Checking
```bash
# User asks: "Does this project support WASM ASAN?"
# BAD: Assume based on typical limitations
# Answer: "No, WASM typically doesn't support ASAN"
# Result: User has to correct you with workflow file
```

## Benefits

1. **Accuracy** - Claims backed by evidence, not assumptions
2. **Efficiency** - Avoid correction cycles by checking first
3. **Trust** - User confidence in responses
4. **Learning** - Build accurate mental model of project

## Cost of Not Following

- User wastes time correcting you
- Loss of credibility
- Potential wrong decisions based on incorrect info
- Need to redo work based on wrong assumptions

## Related Heuristics

- **H007:** Variable debugging protocol (check reality, not assumptions)
- **H009:** Simplicity-first debugging (Occam's Razor)
- **H011:** Documentation-check-mandatory (RTFM before debugging)

## Integration with LLMCJF

This is a **positive pattern** to adopt, not a violation to avoid. Add to pre-action checklist:

```markdown
## Before Making Capability Claims

- [ ] Checked GitHub Actions workflows for evidence
- [ ] Reviewed CMakeLists.txt or equivalent build config
- [ ] Searched codebase for existing usage
- [ ] If claim is negative ("X doesn't support Y"), verified against authoritative sources
```

## Correction Cycle: Healthy vs Unhealthy

### Healthy (This Case)
```
User: "Does WASM ASAN work?"
Agent: "Checking... no, typically not supported"
User: "Actually, see this workflow file - it does"
Agent: "You're right, verifying... confirmed! Updating docs."
```

**Outcome:** Learning, documentation, better future performance

### Unhealthy (Violation Pattern)
```
User: "Does WASM ASAN work?"
Agent: "Checking... no, not supported [deletes ASAN build files]"
User: "Wait, why did you delete working files?!"
Agent: "Assumed they were broken, didn't check workflow"
```

**Outcome:** Data loss, violation, user frustration

## Key Difference

**Correction cycle** = Normal iterative process, builds knowledge  
**Violation** = Breaking established rules, causing harm/waste

This heuristic captures the **positive** correction cycle pattern.

---

## Summary

**Always verify claims against authoritative sources in priority order:**
1. CI/CD workflows (executable truth)
2. Build system config (implementation truth)
3. Official docs (design truth)
4. Source code (ground truth)
5. Assumptions (lowest priority)

**When corrected with authoritative source:**
- Verify source
- Test implementation
- Document findings
- Update governance if pattern worth capturing

This prevents wrong decisions and builds accurate project understanding through evidence-based claims.
