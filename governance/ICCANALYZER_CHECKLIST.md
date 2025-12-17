# IccAnalyzer Governance Checklist

**Purpose**: Pre-commit validation checklist for IccAnalyzer development  
**Version**: 1.0  
**Date**: 2026-01-29

---

## Pre-Commit Checklist

### Code Quality
- [ ] No new compiler warnings
- [ ] 2-space indentation (no tabs)
- [ ] K&R bracing style
- [ ] ICC BSD 3-Clause copyright header on new files
- [ ] Include guards on all new headers (`#ifndef _ICC_ANALYZER_*_H`)
- [ ] Member variables prefixed with `m_`
- [ ] Functions have clear, descriptive names

### Build System
- [ ] CMakeLists.txt updated if new modules added
- [ ] Build succeeds: `cd Build/Cmake && make -j32 iccAnalyzer`
- [ ] Binary created: `Build/Tools/IccAnalyzer/iccAnalyzer`
- [ ] No linker errors
- [ ] Clean rebuild succeeds: `make clean && make -j32 iccAnalyzer`

### Testing
- [ ] Functional test suite passes: `./test_refactored_iccanalyzer.sh`
- [ ] All 12 operational modes tested
- [ ] New functionality has test coverage
- [ ] Regression testing on existing profiles
- [ ] Security-sensitive changes tested with attack files

### Documentation
- [ ] Module purpose documented in header file
- [ ] Public functions have brief comments
- [ ] README.md updated if new mode added
- [ ] ICCANALYZER_DEVELOPMENT_GUIDE.md updated if architecture changed
- [ ] USAGE_EXAMPLES.md updated if new use cases added

### Security Review
- [ ] Input validation on file paths and sizes
- [ ] Buffer boundaries checked for LUT operations
- [ ] No unsafe operations outside Ninja mode
- [ ] Attack surface minimized
- [ ] Fingerprint mode tested on weaponized profiles

### Governance Compliance
- [ ] Changes align with governance framework
- [ ] LLMCJF requirements followed (technical-only, minimal changes)
- [ ] Session documentation updated
- [ ] Commit message follows format: `{type}: {scope} - {description}`
- [ ] No secrets or credentials in code

### Module-Specific Checks

#### For Security Module Changes
- [ ] Heuristic count updated in documentation
- [ ] New checks added to threat scoring calculation
- [ ] False positive rate considered
- [ ] Performance impact minimal (heuristics are fast checks)

#### For LUT Module Changes
- [ ] CLUT dimension validation correct
- [ ] Integer overflow checks in place
- [ ] Both legacy (lut8/lut16) and MPE paths tested
- [ ] Binary file format (big-endian uint16) verified

#### For Fingerprint Module Changes
- [ ] Anomaly detection thresholds documented
- [ ] New attack signatures documented
- [ ] Shannon entropy calculation verified (if changed)
- [ ] NaN and 0xFF detection logic correct

#### For Comprehensive Module Changes
- [ ] Orchestration of sub-modules correct
- [ ] Error propagation handled
- [ ] Output formatting consistent
- [ ] Performance acceptable (comprehensive mode is slow but thorough)

---

## Pre-Push Checklist

- [ ] All commits have clear messages
- [ ] No work-in-progress commits
- [ ] Session summary created in `.copilot-sessions/summaries/`
- [ ] NEXT_SESSION_START.md updated via `./scripts/generate-session-start.sh`
- [ ] Governance validation passes: `./scripts/validate-session-start.sh`
- [ ] CodeQL scan clean (if applicable): `./build-for-codeql.sh`

---

## Release Checklist

### Pre-Release
- [ ] Version number updated in main.cpp
- [ ] CHANGELOG.md updated (if exists)
- [ ] Full test suite passed on multiple profiles
- [ ] Static analysis clean: `scan-build make iccAnalyzer`
- [ ] Memory leaks checked: `valgrind --leak-check=full iccAnalyzer -a test.icc`
- [ ] Sanitizer builds clean (ASan, UBSan)

### Documentation
- [ ] User documentation complete (Readme.md)
- [ ] Development guide current
- [ ] Usage examples verified
- [ ] API changes documented
- [ ] Migration guide (if breaking changes)

### Integration
- [ ] Fuzzer integration tested
- [ ] CI/CD pipelines passing
- [ ] Cross-platform build verified (Linux, macOS, Windows)
- [ ] Backward compatibility checked

---

## Common Issues Checklist

### Build Failures
- [ ] Check CMakeLists.txt syntax
- [ ] Verify all source files exist
- [ ] Check include paths
- [ ] Clean build directory: `rm -rf Build/Cmake/build_*`
- [ ] Regenerate: `cd Build/Cmake && cmake .`

### Test Failures
- [ ] Compare with backup version: `iccAnalyzer.cpp.backup`
- [ ] Check for logic changes during refactoring
- [ ] Verify test profile paths correct
- [ ] Check exit codes and return values
- [ ] Review stderr output for warnings

### Sanitizer Errors
- [ ] Expected in Ninja mode (bypasses validation)
- [ ] Unexpected in validated modes - investigate
- [ ] Check buffer boundaries
- [ ] Verify integer overflow checks
- [ ] Test with attack profiles in `poc-archive/`

### Performance Regressions
- [ ] Profile with `perf` or `valgrind --tool=callgrind`
- [ ] Compare module size before/after
- [ ] Check for unnecessary copying
- [ ] Verify LTO applied: `-flto` in release builds

---

## Module Addition Checklist

When adding a new module:

1. **Planning**
   - [ ] Module purpose clearly defined
   - [ ] Single responsibility principle verified
   - [ ] Dependency graph remains acyclic
   - [ ] No circular dependencies

2. **Implementation**
   - [ ] Create `IccAnalyzer{ModuleName}.h`
   - [ ] Create `IccAnalyzer{ModuleName}.cpp`
   - [ ] Add ICC copyright header (full BSD 3-Clause)
   - [ ] Include guards added
   - [ ] Functions declared in header
   - [ ] Implementation in .cpp file

3. **Integration**
   - [ ] Add to CMakeLists.txt SOURCES
   - [ ] Include in IccAnalyzerCommon.h (if widely used)
   - [ ] Add CLI flag in main.cpp (if user-facing)
   - [ ] Update dependency graph documentation

4. **Testing**
   - [ ] Build succeeds
   - [ ] Module functions work in isolation
   - [ ] Integration with other modules verified
   - [ ] Test case added to test suite

5. **Documentation**
   - [ ] Module documented in ICCANALYZER_DEVELOPMENT_GUIDE.md
   - [ ] Usage examples added (if user-facing)
   - [ ] Update dependency graph
   - [ ] Add to quick reference

---

## Emergency Response

### Security Issue Detected
1. **STOP** - Do not commit or push
2. Document issue in `.copilot-sessions/governance/VIOLATION_*`
3. Assess severity and impact
4. Create fix in isolated branch
5. Test thoroughly with attack files
6. Review with security focus
7. Update security documentation

### Build Breakage
1. Revert to last known good commit
2. Verify backup files exist (`iccAnalyzer.cpp.backup`)
3. Identify breaking change via `git diff`
4. Fix in minimal patch
5. Test thoroughly before re-commit

### Test Regression
1. Bisect to identify breaking commit: `git bisect`
2. Compare output with original
3. Verify logic preservation during refactoring
4. Fix regression with minimal change
5. Add test case to prevent recurrence

---

## Metrics Tracking

Track these metrics for quality assurance:

- **Code Size**: Total LOC per module (target: <1000 lines)
- **Test Coverage**: Modes tested / Total modes (target: 100%)
- **Build Time**: Time to compile iccAnalyzer (monitor for regressions)
- **Binary Size**: Release build size (monitor for bloat)
- **Compiler Warnings**: Count (target: 0)
- **Static Analysis**: Issues found (target: 0)
- **Sanitizer Errors**: Count in validated modes (target: 0)

---

## Sign-Off

Before committing, verify:

```
✓ Code quality checks passed
✓ Build system updated
✓ Tests pass (12/12 modes)
✓ Documentation current
✓ Security reviewed
✓ Governance compliant
```

**Commit**: `git commit -m "{type}: {scope} - {description}"`

---

## Version History

- **1.0** (2026-01-29): Initial checklist for modular iccAnalyzer governance
