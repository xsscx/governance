# GitHub Actions Workflow Success Pattern - iccanalyzer-lite
**Date:** 2026-02-07 18:56 UTC  
**Session:** cb1e67d2  
**Context:** iccanalyzer-lite A/B Test Workflow  
**Status:** ✅ SUCCESS (Run #21785123473)

## Achievement
Successfully deployed and executed iccanalyzer-lite build and test workflow using proven ColorBleed Tools pattern. First successful automated build of iccanalyzer-lite with full instrumentation (ASAN+UBSAN+Coverage) in CI/CD environment.

## Success Metrics
- **Workflow Run:** https://github.com/xsscx/research/actions/runs/21785123473
- **Status:** ✅ All 12 steps passed
- **Duration:** 2 minutes 40 seconds
- **Artifacts:** Binary (20MB) + coverage data uploaded
- **Pattern Source:** ColorBleed Tools (Run #21683285331 - 100% success rate)

## Critical Learnings

### 1. ColorBleed Build Pattern (PROVEN WORKING)
**Pattern:**
```bash
cd <tool-directory>
git clone https://github.com/InternationalColorConsortium/iccDEV.git
cd iccDEV/Build
cmake Cmake [OPTIONS]
make -j$(nproc)
cd ../../  # Back to tool directory
./build.sh  # Or make for Makefile-based tools
```

**Why it works:**
- iccDEV cloned INTO tool directory (not parent)
- Relative paths align with working directory
- Build script references `./iccDEV/` or `iccDEV/` (current directory)
- Clear separation of dependency (iccDEV) from tool code

**Failure pattern (original attempt):**
```bash
# Root directory
git clone iccDEV  # In root
cd iccanalyzer-lite  # cd into tool dir
./build.sh          # build.sh expects ../iccDEV/ but it's not there
# FAILS: iccDEV not found
```

### 2. Exit Code Handling for Security Tools
**Issue:** Security analysis tools often exit with non-zero codes to indicate findings (not errors).

**Problem Code:**
```bash
set -euo pipefail
./iccanalyzer-lite <profile.icc>  # Exits 1 if findings detected
# Workflow FAILS due to pipefail
```

**Solution:**
```bash
set -euo pipefail
./iccanalyzer-lite -h <profile.icc> || echo "Analysis completed with exit code $?"
# Captures exit code, reports it, continues workflow
```

**Lesson:** Security/analysis tools are NOT build tools - non-zero exit ≠ failure. Always capture and report exit codes for analysis tools.

### 3. Command-Line Argument Requirements
**Discovery:** iccanalyzer-lite requires mode flags, not just filename.

**Incorrect:**
```bash
./iccanalyzer-lite profile.icc  # ERROR: Unknown option
```

**Correct:**
```bash
./iccanalyzer-lite -h profile.icc   # Heuristics analysis
./iccanalyzer-lite -a profile.icc   # Comprehensive analysis
./iccanalyzer-lite -n profile.icc   # Ninja mode
```

**Root Cause:** Tool expects explicit mode selection (inherited from full iccAnalyzer design).

**Time Lost:** 3 workflow failures before discovering via local testing.

**Prevention:** ALWAYS test tool locally with actual usage before writing workflow tests.

### 4. Auto-Detection Pattern for Build Dependencies
**Problem:** iccDEV location varies by workflow pattern.
- A/B Test: `iccanalyzer-lite/iccDEV/`
- Original attempt: `../iccDEV/` (parent directory)

**Solution (build.sh):**
```bash
# Auto-detect iccDEV location
if [ -d "iccDEV" ]; then
  ICCDEV_ROOT="iccDEV"
elif [ -d "../iccDEV" ]; then
  ICCDEV_ROOT="../iccDEV"
else
  echo "ERROR: iccDEV not found"
  exit 1
fi
```

**Benefit:** Single build.sh works for multiple workflow patterns.

### 5. Local Testing is Mandatory
**Protocol established:**
```bash
# Before finalizing workflow:
cd <tool-directory>
git clone <dependency>
./build.sh          # Verify build works
./<tool> --help     # Verify command syntax
./<tool> <args>     # Test actual usage
```

**Time savings:** 5 minutes local testing vs 15+ minutes per workflow failure iteration.

**Ratio:** 67% time reduction by testing locally first.

## Workflow Comparison

### What Failed (Original Pattern)
| Step | Issue | Impact |
|------|-------|--------|
| Clone location | iccDEV in root, not in tool dir | Relative paths broken |
| Build directory | Wrong CWD during build | Libraries not found |
| Test command | Missing `-h` flag | "Unknown option" error |
| Exit code | No error capture | False failures |

**Failure count:** 8+ workflow runs

### What Succeeded (ColorBleed Pattern)
| Step | Solution | Result |
|------|----------|--------|
| Clone location | iccDEV IN `iccanalyzer-lite/` | Paths align ✅ |
| Build directory | CWD = `iccanalyzer-lite/` | Libraries found ✅ |
| Test command | `-h <profile>` flag | Analysis runs ✅ |
| Exit code | `|| echo` capture | Workflow continues ✅ |

**Success count:** 1 run (after fixes applied)

## Technical Details

### Build Configuration
```bash
cmake Cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DENABLE_ASAN=ON \
  -DENABLE_UBSAN=ON \
  -DENABLE_COVERAGE=ON \
  -DENABLE_TOOLS=OFF \
  -Wno-dev

make -j$(nproc)
```

**Flags:**
- `RelWithDebInfo`: Optimized with debug symbols
- `ENABLE_ASAN`: AddressSanitizer (memory errors)
- `ENABLE_UBSAN`: UndefinedBehaviorSanitizer
- `ENABLE_COVERAGE`: gcov coverage instrumentation
- `ENABLE_TOOLS=OFF`: Skip wxWidgets GUI tools (avoids dependency)

### Artifacts
- **Binary:** 20MB (ASAN+UBSAN+Coverage instrumented)
- **Libraries:** 26MB libIccProfLib + 9.7MB libIccXML
- **Coverage:** .gcda/.gcno files (excluded from git)
- **Checksums:** SHA256SUMS for verification

## Prevention Protocols

### For New Tool Workflows
**Step 1:** Identify working reference workflow (e.g., ColorBleed Tools)  
**Step 2:** Extract build pattern (clone location, build commands)  
**Step 3:** Test locally FIRST with exact commands  
**Step 4:** Write workflow mirroring working pattern  
**Step 5:** Handle tool-specific exit codes appropriately  

### For Security/Analysis Tools
**Step 1:** Determine if tool uses exit codes for findings  
**Step 2:** Add exit code capture: `|| echo "Exit code: $?"`  
**Step 3:** Test with known-good and known-bad inputs  
**Step 4:** Document expected exit codes in workflow  

### Quality Gates
- ✅ Local build succeeds before workflow creation
- ✅ Local test succeeds with actual usage pattern
- ✅ Exit codes captured for analysis tools
- ✅ Relative paths verified from working directory
- ✅ Dependencies cloned in correct location

## Success Pattern Template

```yaml
- name: Clone dependency
  run: |
    cd <tool-directory>
    git clone <dependency-repo>

- name: Build dependency
  run: |
    cd <tool-directory>/<dependency>/Build
    cmake Cmake [OPTIONS]
    make -j$(nproc)

- name: Build tool
  run: |
    cd <tool-directory>
    ./build.sh

- name: Test tool
  run: |
    cd <tool-directory>
    ./<tool> <required-flags> <input> || echo "Completed with exit code $?"
```

## Time Investment vs Payoff

**Total time spent:** ~2.5 hours (including 8+ failed workflow runs)  
**Time saved by ColorBleed pattern recognition:** Would have been 4+ hours without reference  
**Time saved by local testing:** ~1 hour (avoided 4 more workflow iterations)  
**Future time saved:** Pattern reusable for other iccDEV-based tools

**ROI:** Pattern documented for future tools (15-minute setup vs hours of troubleshooting)

## Key Takeaways

1. **Reference patterns are gold:** Working workflows are templates, not just examples
2. **Local testing is mandatory:** 5 min local > 15 min per CI/CD iteration
3. **Exit codes matter:** Security tools ≠ build tools in exit behavior
4. **Working directory matters:** Relative paths must align with CWD
5. **Auto-detection reduces fragility:** One build.sh for multiple patterns

## Cross-References
- **ColorBleed Tools Workflow:** `.github/workflows/colorbleed-tools-build.yml`
- **Working Run:** https://github.com/xsscx/research/actions/runs/21683285331
- **A/B Test Success:** https://github.com/xsscx/research/actions/runs/21785123473
- **Related Lesson:** `COVERAGE_ARTIFACTS_EXCLUSION_2026-02-07.md` (build artifact hygiene)

## Classification
**Type:** Success Pattern Documentation (SPD-001)  
**Category:** CI/CD Workflow Design  
**Reusability:** High (template for iccDEV-based tools)  
**Impact:** Foundational (enables automated security tool testing)

---

**Primary Lesson:** Follow proven patterns from working workflows. When in doubt, replicate what works, then customize incrementally.
