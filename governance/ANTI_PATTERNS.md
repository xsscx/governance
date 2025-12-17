# Anti-Patterns
## GitHub Copilot CLI Governance - Failure Modes to Avoid

**Version**: 1.0  
**Effective**: 2025-12-24  
**Purpose**: Document known failure patterns and mitigations

---

## Overview

This document catalogs known failure patterns from LLMCJF (LLM Content Jockey Failure) research and project-specific experiences. Each pattern includes detection methods and mitigation strategies.

---

## Content Jockey Failures (CJF)

### CJF-01: Hallucinated Implementation

**Description**: AI generates plausible-looking code that doesn't actually solve the problem or introduces new bugs.

**Example**:
```cpp
// User asks: "Fix the memory leak in cleanup()"
// Bad AI response:
void cleanup() {
  // Added smart pointers to fix leak
  std::unique_ptr<Data> ptr(data);  // data is stack variable!
  ptr->process();
}
```

**Detection**:
- Code doesn't compile
- Introduces new errors
- Doesn't address actual issue
- Uses incompatible patterns

**Mitigation**:
1. Always verify code compiles
2. Test before committing
3. Ask user for clarification if problem unclear
4. Stick to minimal, proven changes

---

### CJF-02: Over-Engineering

**Description**: AI replaces simple working code with complex, unnecessary abstractions.

**Example**:
```cpp
// Before (working):
if (size > MAX_SIZE) return false;

// Bad AI "improvement":
template<typename T, typename = std::enable_if_t<std::is_integral_v<T>>>
class SizeValidator {
  static constexpr T threshold = MAX_SIZE;
  public:
    [[nodiscard]] static bool validate(T value) noexcept {
      return value <= threshold;
    }
};
if (!SizeValidator<size_t>::validate(size)) return false;
```

**Detection**:
- Complexity increases without benefit
- Introduces templates/patterns unnecessarily
- Makes code harder to understand
- No performance or functionality gain

**Mitigation**:
1. Follow minimal changes principle
2. Only refactor if explicitly requested
3. Preserve simplicity
4. Avoid showing off language features

---

### CJF-03: Context Loss

**Description**: AI forgets earlier discussion context and contradicts itself or repeats suggestions.

**Example**:
```
User: "We already tried increasing memory limit to 8GB"
AI: "Have you considered increasing the memory limit?"
```

**Detection**:
- Repeats dismissed suggestions
- Contradicts earlier statements
- Ignores user corrections
- Asks for information already provided

**Mitigation**:
1. Reference session snapshots for context
2. Explicitly acknowledge user corrections
3. Don't repeat failed approaches
4. Ask user to verify if uncertain about history

---

### CJF-04: Narrative Padding

**Description**: AI generates unnecessary explanatory text, restating obvious information.

**Example**:
```markdown
[FAIL] Bad:
"I'll now proceed to fix the issue by making a change to the file.
This change will address the problem you mentioned. After making
the change, we'll verify it works. Here's the change..."

[OK] Good:
"Fix applied: Updated path reference in build.sh"
```

**Detection**:
- Multiple paragraphs before action
- Restating user's question
- Explaining obvious steps
- Hedging language ("I think", "maybe")

**Mitigation**:
1. Report intent, then act (1 sentence max)
2. Suppress reasoning exposition
3. One purpose per message
4. Action-oriented communication

**From LLMCJF**: `strict-engineering mode active`

---

### CJF-05: Incomplete Change Propagation

**Description**: AI fixes issue in one location but misses identical issues elsewhere.

**Example**:
```bash
# Fix ipatch→iccLibFuzzer in 18 files
# Miss .clusterfuzzlite/build.sh (20 occurrences)
# Result: Build still fails
```

**Detection**:
- Partial fix claims to be complete
- Related files not checked
- Pattern not applied consistently
- Grep would find remaining issues

**Mitigation**:
1. Use grep to find ALL occurrences
2. Systematic replacement across codebase
3. Verify with negative grep (should be empty)
4. Don't assume fix is complete without verification

**Current Session Example**: This exact pattern occurred and was fixed.

---

### CJF-06: Build System Regression

**Description**: AI modifies build configuration in ways that break compilation or introduce warnings.

**Example**:
```cmake
# Before (working):
set(CMAKE_CXX_FLAGS "${CXXFLAGS} -frtti")

# Bad AI change:
set(CMAKE_CXX_FLAGS "-O3 -frtti")  # Loses user CXXFLAGS!
```

**Detection**:
- New compiler warnings
- Build failures on CI
- Missing compiler flags
- Broken sanitizer builds

**Mitigation**:
1. Never remove existing flags without justification
2. Append to flags, don't replace
3. Test build locally before commit
4. Review all build system changes carefully

---

### CJF-07: No-op Echo Response

**Description**: AI re-emits user input verbatim without processing.

**From LLMCJF**:
> "The LLM re-emits user input with no transformation, substitution, or validation despite being prompted for review or conditional modification."

**Detection**:
- Output identical to input
- No analysis performed
- User question not answered
- Circular reference

**Mitigation**:
1. Always process/analyze input
2. Provide actionable response
3. If uncertain, ask clarifying question
4. Never parrot back without value-add

---

### CJF-08: Known-Good Structure Regression

**Description**: AI breaks validated syntax (YAML, Makefiles, shell) while attempting improvements.

**From LLMCJF**:
> "The LLM injects malformed substitutions into validated YAML, Makefile, or shell syntax, breaking indentation, heredoc boundaries, or reserved syntax."

**Example**:
```yaml
# Before (valid):
matrix:
  sanitizer: [address, undefined, memory]

# Bad AI change (invalid indentation):
matrix:
sanitizer: [address, undefined, memory]
```

**Detection**:
- YAML/JSON validation fails
- Shell script syntax errors
- Makefile parse errors
- CI/CD workflow failures

**Mitigation**:
1. Schema validation for structured files
2. Syntax check before commit
3. Minimal changes to proven configs
4. Test in isolation before integration

---

## Project-Specific Anti-Patterns

### AP-01: Fuzzer Option Misconfiguration

**Description**: Setting fuzzer options that cause OOMs, timeouts, or reduce effectiveness.

**Bad Examples**:
```bash
max_len = 1048576000  # 1GB - causes OOM
timeout = 1  # Too short, misses complex bugs
rss_limit_mb = 512  # Too small for valid profiles
jobs = 1  # Wastes CPU cores
```

**Detection**:
- Frequent OOM crashes
- No crashes found (timeout too short)
- Low exec/sec (inefficient settings)
- CPU underutilization

**Mitigation**:
1. Use project-tested values as baseline
2. Gradual increases with monitoring
3. Balance timeout vs depth vs throughput
4. Validate against known POCs

**Current Values** (validated):
```bash
max_len = 15728640  # 15MB
timeout = 45  # 45s
rss_limit_mb = 8192  # 8GB
jobs = 32  # W5-2465X optimized
```

---

### AP-02: Corpus Corruption

**Description**: Breaking corpus files during migration, compression, or processing.

**Example**:
```bash
# Bad: Lossy compression
gzip -9 corpus/*.icc  # Changes file extensions!

# Bad: Incorrect copy
cp corpus/* seed/  # Doesn't preserve structure
```

**Detection**:
- Fuzzer can't load corpus
- File format errors
- Reduced coverage
- Corpus validation failures

**Mitigation**:
1. Preserve file extensions
2. Use rsync for structure preservation
3. Validate corpus after operations
4. Maintain checksums

---

### AP-03: Sanitizer Flag Conflicts

**Description**: Mixing incompatible sanitizer flags causing build failures.

**Example**:
```bash
# Bad: ASan + MSan conflict
CFLAGS="-fsanitize=address -fsanitize=memory"
```

**Detection**:
- Linker errors
- Sanitizer initialization failures
- Runtime crashes on startup

**Mitigation**:
1. One sanitizer per build
2. Use ClusterFuzzLite matrix strategy
3. Separate builds for each sanitizer
4. Never mix ASan/MSan/TSan

**Current Approach**:
```yaml
# .github/workflows/clusterfuzzlite.yml
strategy:
  matrix:
    sanitizer: [address, undefined, memory]
    # Separate jobs, no conflicts
```

---

### AP-04: Path Hardcoding

**Description**: Using absolute or environment-specific paths instead of relative or configurable.

**Bad Examples**:
```bash
/home/xss/copilot/iccLibFuzzer/fuzzers  # User-specific
/src/ipatch/fuzzers  # Old repository name
C:\Users\Developer\project  # Windows-specific
```

**Detection**:
- Build fails on different systems
- CI/CD failures
- Docker container issues

**Mitigation**:
1. Use relative paths from project root
2. Use environment variables ($SRC, $OUT)
3. Make paths configurable
4. Test on different environments

**Correct Pattern**:
```bash
$SRC/iccLibFuzzer/fuzzers  # Environment variable
./fuzzers  # Relative to CWD
$(dirname $0)/../fuzzers  # Relative to script
```

---

### AP-06: Destructive Directory Operations

**Description**: Deleting or recreating user data directories without checking for existing content, destroying hours/days of work.

**SEVERITY**: 🔴 CRITICAL - Data Loss

**Real-World Example** (2026-01-27):
```bash
# BAD: build-fuzzers-local.sh destroying corpus
for fuzzer in icc_*_fuzzer; do
  mkdir -p "$OUTPUT_DIR/${fuzzer}_seed_corpus"  # Destroys existing!
  cp Testing/*.icc "$OUTPUT_DIR/${fuzzer}_seed_corpus/"
done

# Result: User loses curated corpus directories:
# - icc_tiffdump_fuzzer_optimized_seed_corpus (hours of fuzzing)
# - Custom-named corpus variants
# - Minimized interesting inputs
```

**User Impact**:
```
ERROR: The required directory "fuzzers-local/address/icc_tiffdump_fuzzer_optimized_seed_corpus/" does not exist

Fuzzing campaign destroyed. Must restart from scratch.
```

**Detection**:
- User reports missing directories
- Error messages about missing corpus
- Fuzzer fails with "corpus not found"
- Git shows deleted files in user workspace
- Loss of fuzzing progress/coverage

**Root Causes**:
1. Assuming directories are disposable/auto-generated
2. Not checking for existence before mkdir
3. Using destructive operations (`>` instead of `>>`)
4. mkdir without `-p` guard check
5. rm -rf without confirmation

**Mitigation** (MANDATORY):

1. **Always check before create/delete**:
   ```bash
   # [OK] CORRECT
   if [ ! -d "$OUTPUT_DIR/${fuzzer}_seed_corpus" ]; then
     mkdir -p "$OUTPUT_DIR/${fuzzer}_seed_corpus"
     echo "Created seed corpus directory"
     # Only populate new directories
     cp Testing/*.icc "$OUTPUT_DIR/${fuzzer}_seed_corpus/"
   else
     echo "Preserving existing seed corpus"
   fi
   ```

2. **Never assume directory is disposable**:
   - Fuzzer corpus directories
   - Build artifacts with metadata
   - Cache directories with state
   - Any directory that accumulates data over time

3. **Inform user of preservation**:
   ```bash
   echo "Preserving existing: ${fuzzer}_seed_corpus"  # Not silent
   ```

4. **Support custom naming**:
   - Don't hardcode exact names
   - Support *_seed_corpus, *_optimized_seed_corpus, etc.
   - Preserve all variants

5. **Use safer patterns**:
   ```bash
   # [FAIL] DANGEROUS
   rm -rf "$dir"
   mkdir "$dir"
   
   # [OK] SAFE
   mkdir -p "$dir"  # Creates only if missing
   [ -d "$dir" ] || mkdir -p "$dir"  # Explicit guard
   ```

**Critical Directories to NEVER Delete Without Asking**:
- `*/seed_corpus/` - Fuzzer starting inputs
- `*/corpus/` - Fuzzer-discovered interesting inputs
- `*/crashes/` - Crash artifacts
- `*/artifacts/` - Build artifacts with state
- `*/.cache/` - Cache with accumulated data
- Any directory that grows over time

**Fix Applied** (Commit 839d60ae):
- Added existence check before corpus creation
- Preservation message for existing directories  
- Protects all corpus variants
- User data safe across rebuilds

**Testing**:
```bash
# Verify corpus preservation
mkdir -p test_corpus && touch test_corpus/important.icc
./build-script.sh
ls test_corpus/important.icc  # Must still exist
```

**LLMCJF Classification**: Critical Data-Loss Anti-Pattern
**Impact**: Loss of user work, broken fuzzing campaigns
**Prevention**: Mandatory existence checks before any mkdir/rm operation

---

### AP-05: Session State Loss

**Description**: Forgetting earlier session context, redoing work or contradicting decisions.

**Example**:
```
Session 1: "Fixed ipatch references in 18 files"
Session 2: AI suggests fixing ipatch references again
```

**Detection**:
- Repeated work
- Contradictory recommendations
- Ignoring session snapshots
- Re-solving solved problems

**Mitigation**:
1. Read NEXT_SESSION_START.md first
2. Review latest snapshot before starting
3. Check git log for recent changes
4. Reference session summaries

**Infrastructure**: `.copilot-sessions/` directory

---

## Detection and Prevention

### Automated Detection (Planned)

```bash
# Pre-commit hooks
.git/hooks/pre-commit:
  - Check for hardcoded paths
  - Validate YAML/JSON syntax
  - Grep for known anti-patterns
  - Verify build passes

# CI/CD checks
- Build on multiple platforms
- Run full test suite
- Sanitizer validation
- Coverage tracking
```

### Manual Detection

**Code Review Checklist**:
- [ ] No hallucinated implementations
- [ ] No unnecessary complexity
- [ ] Changes address actual problem
- [ ] All occurrences fixed (grep verified)
- [ ] Build system not regressed
- [ ] No syntax errors in configs
- [ ] Paths are relative/configurable
- [ ] Session context maintained

---

## Escalation

### When Anti-Pattern Detected

**Severity: High** (Security, data loss, corruption)
1. 🛑 STOP immediately
2. 🛑 DO NOT commit
3. 🛑 Alert user
4. 🛑 Document in session snapshot
5. 🛑 Follow incident response

**Severity: Medium** (Build breaks, regressions)
1. [WARN]  Pause and analyze
2. [WARN]  Revert if already committed
3. [WARN]  Document in anti-patterns
4. [WARN]  Fix properly
5. [WARN]  Update governance

**Severity: Low** (Style issues, minor inefficiency)
1. ℹ️  Note in session log
2. ℹ️  Fix if time permits
3. ℹ️  Add to future improvement list

---

## Learning Loop

### After Each Failure

1. **Document**:
   - What happened
   - Why it happened
   - How it was detected
   - How it was fixed

2. **Prevent**:
   - Update governance docs
   - Add detection mechanisms
   - Improve session templates
   - Train on new patterns

3. **Monitor**:
   - Watch for recurrence
   - Track pattern frequency
   - Measure mitigation effectiveness

---

## References

### LLMCJF Original Research
- `llmcjf/profiles/llm_cjf_heuristics.yaml` - Original CJF patterns
- `llmcjf/profiles/llmcjf-hardmode-ruleset.json` - Enforcement rules
- `llmcjf/STRICT_ENGINEERING_PROLOGUE.md` - Behavioral mode

### Project History
- Session snapshots in `.copilot-sessions/snapshots/`
- Session summaries in `.copilot-sessions/summaries/`
- Git history for pattern analysis

---

**Status**: [OK] Active  
**Last Update**: 2026-01-27  
**Pattern Count**: 14 (8 CJF + 6 Project-Specific)  
**Critical Patterns**: 1 (AP-06: Destructive Directory Operations)
**Next Review**: After next major failure or monthly

---

### CJF-10: Echoing User Examples

**Description**: AI creates scripts that output hard-coded examples provided by user instead of analyzing source code to generate the output.

**Example**:
```bash
# User shows desired format:
# "GetElemNumberValue() 
#   ├─ Allocates: float rv (4 bytes) at [16, 20)"

# Bad AI response - creates script that echoes the example:
cat << 'TREE'
GetElemNumberValue() 
  ├─ Allocates: float rv (4 bytes) at [16, 20)
TREE

# Good AI response - analyzes source to generate:
clang++ -ast-dump IccTagComposite.cpp | \
  grep "VarDecl.*rv" | \
  awk '{print "Allocates: " $3 " at offset [...]"}'
```

**Detection**:
- Script contains hard-coded user examples
- No source code analysis present
- Output matches user's example exactly
- No variables or computed values

**Mitigation**:
1. **NEVER echo user examples** - analyze source instead
2. Parse actual source files
3. Compute values (offsets, sizes)
4. Generate output from analysis
5. User examples are templates to match, not content to copy

**Session Impact**: 2026-01-29
- 24 minutes wasted
- 3 useless scripts created
- ~8,000 tokens consumed
- User intervention required

---

### CJF-11: False Success Reporting

**Description**: AI responds positively ("Good!", "Perfect!") to command output without verifying actual success.

**Example**:
```bash
# Command runs with no output
$ clang++ -S -emit-llvm file.cpp -o output.ll
# (silent - no output)

# Bad AI response:
"Good! Now check if the IR file was created"

# Good AI response:
"No output. Verifying if compilation succeeded..."
$ ls -lh output.ll && echo "Success" || echo "Failed"
```

**Detection**:
- Positive response to silent commands
- No verification step
- Assumes success from absence of error messages
- Proceeds without checking

**Mitigation**:
1. **Silent ≠ Success** - always verify
2. Add `&& verify` to every command
3. Check file existence/size
4. Examine output before declaring success
5. Report "No output. Verifying..." not "Good!"

**Pattern**:
```bash
# WRONG
command1
command2

# CORRECT
command1 && verify1 || { echo "Failed step 1"; exit 1; }
command2 && verify2 || { echo "Failed step 2"; exit 1; }
```

---

### CJF-12: Proceeding Through Errors

**Description**: AI continues executing commands after errors instead of stopping to fix the issue.

**Example**:
```bash
$ opt -dot-callgraph file.ll
Error: unknown argument '-dot-callgraph'

# Bad AI: Proceeds to next command
$ dot -Tpng callgraph.dot -o output.png
Error: can't open callgraph.dot

# Good AI: Stops and fixes
"opt syntax error. Using new pass manager..."
$ opt -passes=dot-callgraph file.ll
```

**Detection**:
- Error messages in output
- Next command assumes previous succeeded
- Multiple failures in sequence
- No corrective action

**Mitigation**:
1. **Stop at first error**
2. Read error messages
3. Fix before proceeding
4. Don't assume error doesn't matter
5. Ask user if unclear

**Rule**: One error = full stop, analyze, fix

---

### CJF-13: Resource Waste Through Iteration

**Description**: AI attempts same task multiple times with different approaches instead of analyzing first.

**Example**:
Session 2026-01-29 Call Graph Generation:
1. Attempt 1: Runtime profiling (POC crashes)
2. Attempt 2: LLVM full graph (too large)
3. Attempt 3: Echo user examples (not analysis)
4. Attempt 4: Source analysis (finally correct)

**Cost**: 24 minutes, 4 attempts, ~8,000 tokens

**Detection**:
- Multiple failed attempts
- Different tools for same goal
- No analysis between attempts
- User corrections required

**Mitigation**:
1. **Analyze before executing**
2. Verify approach viability
3. One attempt to completion
4. Ask user for guidance if uncertain
5. Don't iterate without user approval

**Rule**: Plan → Verify → Execute (once)

---

## Updated Process Requirements

### Command Execution Pattern (MANDATORY)

```bash
#!/bin/bash
# Every command sequence must follow this pattern

# Step 1: Plan
echo "Approach: Generate call graph via static analysis"
echo "Reason: POC crashes, runtime profiling impossible"

# Step 2: Execute with verification
clang++ -S -emit-llvm source.cpp -o output.ll && \
  ls -lh output.ll && \
  file output.ll || \
  { echo "FAILED: LLVM IR generation"; exit 1; }

# Step 3: Verify before proceeding
if [ ! -f output.ll ]; then
  echo "ERROR: output.ll not created"
  exit 1
fi

# Step 4: Next command only if previous succeeded
opt -passes=dot-callgraph output.ll -disable-output && \
  ls -lh *.dot || \
  { echo "FAILED: Call graph generation"; exit 1; }
```

### Verification Gates (MANDATORY)

After EVERY command:
1. Check exit code: `$? -eq 0`
2. Verify output exists: `ls -lh output`
3. Validate format: `file output`
4. Report result: Success or specific failure

### User Example Handling (MANDATORY)

When user provides example output:
1. [OK] Parse as format template
2. [OK] Analyze source to generate data
3. [OK] Output matches format, contains real data
4. [FAIL] NEVER copy-paste example as script output
5. [FAIL] NEVER hard-code user's values

---

## Session Startup Checklist

Add to all session start procedures:

```bash
# Governance self-check
echo "=== CJF Prevention Checklist ==="
echo "[ ] No echoing user examples (CJF-10)"
echo "[ ] Verify all commands before success (CJF-11)"
echo "[ ] Stop at first error (CJF-12)"
echo "[ ] Plan before iterate (CJF-13)"
echo "[ ] All commands have verification gates"
echo "================================"
```

---

**Updated**: 2026-01-29  
**New Patterns**: CJF-10 through CJF-13  
**Source**: Session 003 violation analysis
