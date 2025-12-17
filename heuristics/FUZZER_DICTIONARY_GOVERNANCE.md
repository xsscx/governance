# Fuzzer Dictionary Governance and Standards

**Document Version**: 1.0  
**Effective Date**: 2026-01-31  
**Last Updated**: 2026-01-31  
**Status**: MANDATORY

---

## Purpose

This document establishes mandatory standards and procedures for managing LibFuzzer dictionary files to prevent format violations and ensure fuzzing infrastructure reliability.

---

## Scope

This governance applies to all files matching:
- `**/*.dict`
- All LibFuzzer dictionary files in `fuzzers/` directory
- Any file used with `-dict=` flag in fuzzing campaigns

---

## Critical Rules

### Rule 1: No Inline Comments (MANDATORY)

**VIOLATION DETECTED**: 2026-01-31 12:37 UTC - Inline comments broke fuzzing infrastructure

[FAIL] **FORBIDDEN**:
```
"entry"  # Inline comment - BREAKS PARSER
"another"    # This fails
```

[OK] **REQUIRED**:
```
# Comment must be on separate line
"entry"
# Another comment
"another"
```

**Rationale**: LibFuzzer's dictionary parser does not support inline comments. Any text after a quoted string causes parse errors.

**Enforcement**: Automated pre-commit hook checks for violations.

---

### Rule 2: Hex Format for Binary Data (MANDATORY)

[FAIL] **FORBIDDEN**:
```
"\001\000\020"  # Octal format
```

[OK] **REQUIRED**:
```
"\x01\x00\x10"  # Hex format
```

**Rationale**: 
- Hex format is LibFuzzer standard
- Octal is ambiguous and error-prone
- Consistent with existing dictionaries

**Conversion Table**:
| Octal | Hex | Decimal |
|-------|-----|---------|
| \000  | \x00 | 0 |
| \001  | \x01 | 1 |
| \020  | \x10 | 16 |
| \211  | \x89 | 137 |
| \377  | \xff | 255 |

---

### Rule 3: Mandatory Testing Before Commit (MANDATORY)

**BEFORE** committing any .dict file change:

```bash
# Test 1: Dictionary must load
./any_fuzzer -dict=modified.dict -runs=1 2>&1 | grep "Dictionary:"
# Expected: "Dictionary: N entries"
# Failure: "ParseDictionaryFile: error"

# Test 2: Verify entry count
# If you added 3 entries, count should increase by 3
```

**No exceptions**. Untested dictionary changes are prohibited.

---

### Rule 4: Documentation Required (MANDATORY)

Every dictionary update MUST include:

1. **What**: Which entries were added
2. **Why**: Usage count or rationale
3. **Format**: Original format → Converted format
4. **Testing**: Evidence that dictionary loads
5. **Verification**: Entry count before/after

**Template**: See `DICTIONARY_UPDATE_TOXML_2026-01-31.md`

---

## Procedures

### Adding New Dictionary Entries

**Step 1: Prepare Entry**
```bash
# Convert octal to hex if needed
# Original: "\001\000\020"
# Converted: "\x01\x00\x10"
```

**Step 2: Examine Existing Format**
```bash
tail -20 fuzzers/core/target.dict
# Observe:
# - Comment style
# - Spacing
# - Organization
```

**Step 3: Add Entry**
```bash
# Add blank line for readability
# Add comment on separate line
# Add entry on next line

# Uses: 1234
"new_entry"
```

**Step 4: Test Loading**
```bash
# MANDATORY: Test before commit
timeout 10 ./fuzzer -dict=fuzzers/core/target.dict -runs=5
# Check output for "Dictionary: N entries"
```

**Step 5: Verify Count**
```bash
# Count entries before
grep -c '^"' fuzzers/core/target.dict

# Add entry

# Count entries after (should increase by 1)
grep -c '^"' fuzzers/core/target.dict
```

**Step 6: Document**
```bash
# Create update documentation
# Include testing evidence
# Show before/after counts
```

---

## Validation Checklist

Before committing dictionary changes, complete this checklist:

### Format Compliance
- [ ] No inline comments (checked with `grep -E '^".*".*#' *.dict`)
- [ ] Binary data in hex format (not octal)
- [ ] All entries quoted with double quotes
- [ ] Comments start with `#` on separate lines
- [ ] One entry per line

### Testing
- [ ] Dictionary loads without parse errors
- [ ] "Dictionary: N entries" appears in fuzzer output
- [ ] Entry count matches expectation
- [ ] Fuzzer executes at least 5 iterations successfully

### Documentation
- [ ] Update reason documented
- [ ] Usage count or rationale provided
- [ ] Format conversion documented (if applicable)
- [ ] Testing evidence captured
- [ ] Before/after entry counts recorded

### Code Review
- [ ] Changes reviewed by second person
- [ ] Testing verified independently
- [ ] No violations of governance rules

---

## Automated Enforcement

### Pre-commit Hook (REQUIRED)

Install in `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Fuzzer Dictionary Governance Enforcement
# Version: 1.0
# Date: 2026-01-31

echo "🔍 Checking fuzzer dictionaries for governance violations..."

# Get all modified .dict files
DICT_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dict$')

if [ -z "$DICT_FILES" ]; then
  echo "[OK] No dictionary files modified"
  exit 0
fi

VIOLATIONS=0

for dict in $DICT_FILES; do
  echo "Checking: $dict"
  
  # Rule 1: Check for inline comments
  if grep -qE '^"[^"]*"[^"]*#' "$dict"; then
    echo "[FAIL] VIOLATION: Inline comments detected in $dict"
    echo "   LibFuzzer dictionaries do not support inline comments"
    echo "   Comments must be on separate lines"
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
  
  # Rule 2: Check for octal escapes (common patterns)
  if grep -qE '\\[0-7]{3}' "$dict"; then
    echo "[WARN]  WARNING: Possible octal escapes in $dict"
    echo "   Use hex format: \\xNN instead of \\NNN"
    echo "   Verify format is correct"
  fi
  
  # Rule 3: Verify file is loadable (basic syntax)
  # Check for balanced quotes
  QUOTE_COUNT=$(grep -c '^"' "$dict" 2>/dev/null || echo 0)
  BALANCED=$(grep -c '^"[^"]*"$' "$dict" 2>/dev/null || echo 0)
  
  if [ "$QUOTE_COUNT" -ne "$BALANCED" ]; then
    echo "[FAIL] VIOLATION: Unbalanced quotes detected in $dict"
    echo "   Each entry must be: \"string\""
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
done

if [ $VIOLATIONS -gt 0 ]; then
  echo ""
  echo "[FAIL] COMMIT BLOCKED: $VIOLATIONS governance violation(s) detected"
  echo ""
  echo "See FUZZER_DICTIONARY_GOVERNANCE.md for rules"
  echo "Required fixes:"
  echo "  1. Move inline comments to separate lines"
  echo "  2. Convert octal escapes to hex format"
  echo "  3. Balance all quotes"
  echo "  4. Test dictionary with: ./fuzzer -dict=file.dict -runs=1"
  exit 1
fi

echo "[OK] All dictionary files passed governance checks"
exit 0
```

**Installation**:
```bash
chmod +x .git/hooks/pre-commit
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Fuzzer Dictionary Validation

on:
  pull_request:
    paths:
      - '**/*.dict'

jobs:
  validate-dictionaries:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Check Dictionary Format
        run: |
          # Check for inline comments
          if grep -rE '^"[^"]*"[^"]*#' fuzzers/**/*.dict; then
            echo "[FAIL] Inline comments detected"
            exit 1
          fi
          
          # Check for octal escapes
          if grep -rE '\\[0-7]{3}' fuzzers/**/*.dict; then
            echo "[WARN]  Octal escapes detected - should use hex"
          fi
          
      - name: Build Fuzzers
        run: ./build-fuzzers-local.sh
        
      - name: Test Dictionaries Load
        run: |
          for dict in fuzzers/**/*.dict; do
            # Find any fuzzer
            FUZZER=$(find fuzzers-local -name "*fuzzer" -type f | head -1)
            
            # Test dictionary loads
            timeout 10 $FUZZER -dict="$dict" -runs=1 || {
              echo "[FAIL] Dictionary failed to load: $dict"
              exit 1
            }
          done
```

---

## Dictionary Organization Standards

### File Naming
- Core dictionaries: `fuzzers/core/icc_<component>_core.dict`
- Specialized dictionaries: `fuzzers/specialized/icc_<component>_fuzzer.dict`
- Use symlinks for shared dictionaries

### Content Organization

```
# ICC <Component> Fuzzer Dictionary
# High-frequency patterns from fuzzing operations
# Format: LibFuzzer dictionary (hex escapes for binary data)

# Section 1: Binary patterns (high usage)
"\x00\x00\x00\x00"
"\x01\x00\x00\x00"

# Section 2: Tag signatures
"acsp"
"mntr"
"scnr"

# Section 3: Recommended patterns (YYYY-MM-DD)
# Uses: 1234
"\xNN\xNN\xNN\xNN"
```

### Version Control
- Keep V1.0 backups: `filename.dict.v1.0.bak`
- Exclude `.bak` files from loading
- Document migration in commit message

---

## Violation Response Procedure

### When Violation is Detected

**Step 1: Immediate Actions**
1. Stop fuzzing campaigns using affected dictionary
2. Identify scope of impact (which fuzzers failed)
3. Estimate downtime and coverage loss

**Step 2: Fix**
1. Correct format violation
2. Test fix with actual fuzzer
3. Verify entry count matches expectation

**Step 3: Document**
1. Create violation report (see `DICTIONARY_FORMAT_VIOLATION_2026-01-31.md`)
2. Include root cause analysis
3. Document lessons learned
4. Update governance if needed

**Step 4: Communicate**
1. Notify affected stakeholders
2. Report downtime and impact
3. Confirm fix deployment

**Step 5: Prevent Recurrence**
1. Update automation
2. Add test case
3. Review governance rules
4. Train team members

---

## Incident History

### 2026-01-31: Inline Comment Violation

**Incident**: Added dictionary entries with inline comments  
**Impact**: LibFuzzer parse error, all fuzzing failed  
**Downtime**: ~3-4 minutes  
**Root Cause**: Did not test dictionary with actual fuzzer  

**Corrective Actions**:
1. [OK] Fixed format immediately
2. [OK] Created this governance document
3. [OK] Implemented mandatory testing rule
4. [OK] Created pre-commit hook
5. [OK] Added CI/CD validation

**Prevention**: Rule 1 (no inline comments) + Rule 3 (mandatory testing)

---

## Training Requirements

### All Contributors Must

1. **Read** this governance document
2. **Understand** LibFuzzer dictionary format
3. **Follow** mandatory testing procedures
4. **Document** all dictionary changes

### Before First Dictionary Modification

1. Review LibFuzzer documentation: https://llvm.org/docs/LibFuzzer.html#dictionaries
2. Examine 3 existing dictionaries to understand format
3. Practice adding test entry and verifying it loads
4. Complete governance checklist

---

## References

### LibFuzzer Documentation
- Dictionary format: https://llvm.org/docs/LibFuzzer.html#dictionaries
- Command line options: https://llvm.org/docs/LibFuzzer.html#options

### Project Documentation
- `LOCAL_FUZZING_GUIDE.md` - Fuzzing workflows
- `DICTIONARY_FORMAT_VIOLATION_2026-01-31.md` - Violation details
- `DICTIONARY_UPDATE_TOXML_2026-01-31.md` - Correct update example

### Tools
- `scripts/pre-commit-governance.sh` - Pre-commit validation
- `.git/hooks/pre-commit` - Git hook installation

---

## Updates and Amendments

### Version History
| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2026-01-31 | Initial governance document | System |

### Amendment Process
1. Propose change via pull request
2. Document rationale
3. Review by 2+ contributors
4. Test impact on existing dictionaries
5. Update version number
6. Communicate to all contributors

---

## Acknowledgment

By modifying dictionary files in this project, you acknowledge:
1. You have read and understood this governance document
2. You will follow all mandatory rules and procedures
3. You will test changes before committing
4. You will document all modifications
5. You accept responsibility for violations

---

## Contact

**Questions**: See `LOCAL_FUZZING_GUIDE.md`  
**Violations**: Document in `DICTIONARY_FORMAT_VIOLATION_*.md`  
**Updates**: Submit pull request with rationale

---

**Status**: ACTIVE  
**Enforcement**: MANDATORY  
**Review Schedule**: Quarterly or after each violation  
**Next Review**: 2026-04-30  
