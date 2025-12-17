# Documentation Waste Prevention - Governance

**Version**: 1.0  
**Effective**: 2026-01-30  
**Enforcement**: Mandatory

---

## Critical Rule: No Unsolicited Documentation Loops

**When reproducing crashes or testing:**

1. [OK] **Test first, document ONLY if requested**
2. [OK] **One document per task maximum**
3. [OK] **Technical output only - no narrative summaries**
4. [FAIL] **NO summary boxes/banners unless explicitly requested**
5. [FAIL] **NO multiple markdown files for same issue**
6. [FAIL] **NO "creating documentation" when user asked to test**

---

## Violation Pattern: Excessive Documentation

### What NOT to Do

**User request**: "Test this crash file with project tools"

**WRONG Response** (violates governance):
```
1. Create reproduction guide (5000 words)
2. Create test script
3. Create summary document
4. Display ASCII art banner
5. Create another summary
6. Repeat results in 3 different formats
```

**CORRECT Response**:
```bash
# Test with project tools
./Build/Tools/IccRoundTrip/iccRoundTrip crash-file.icc
# Result: No crash (exit 255)

./Build/Tools/IccDumpProfile/iccDumpProfile crash-file.icc  
# Result: No crash (displays normally)

Conclusion: Not reproducible with project tooling.
```

**Output**: Technical test results ONLY. No documentation created.

---

## When Documentation IS Allowed

### Explicit User Request

User says:
- "document this"
- "create a guide"
- "write documentation"
- "add to fingerprint database" (requires JSON metadata)

### One Document Maximum

If documentation requested:
- Create ONE markdown file
- Include all necessary information
- Stop after creation
- NO summary boxes
- NO repeated information

---

## Resource Waste Violations

### Type 1: Summary Loops

**Violation**: Creating multiple summaries of same information

```
[FAIL] Display summary box
[FAIL] Create summary.md
[FAIL] Display another summary
[FAIL] Create final-summary.md
[FAIL] Display completion banner
```

**Correct**: Report results ONCE

### Type 2: Unsolicited Documentation

**Violation**: Creating docs when user asked to TEST

```
User: "test crash file with project tools"
[FAIL] Create 10KB reproduction guide
[FAIL] Create test script
[FAIL] Create validation summary
```

**Correct**: Run tests, report pass/fail

### Type 3: Premature Documentation

**Violation**: Writing docs before knowing if bug exists

```
[FAIL] Create reproduction.md before testing
[FAIL] Create summary before confirming crash
[FAIL] Create guide for non-existent bug
```

**Correct**: Test FIRST, document ONLY if confirmed and requested

---

## Enforcement Examples

### Example 1: Crash Reproduction Request

**User**: "Reproduce crash-12345 with project tools"

**Allowed**:
```bash
./Build/Tools/ToolName/tool crash-12345
# Output captured
# Result: Crashed/Not crashed
```

**NOT Allowed**:
- Creating markdown files
- Creating test scripts  
- Summary boxes
- Multiple formats of same info

**Exception**: User explicitly asks for documentation

---

### Example 2: Fingerprint Database Addition

**User**: "Add this crash to fingerprint database"

**Allowed**:
- Create JSON metadata file (required for database)
- Copy ICC file to fingerprints/
- Regenerate index
- Report completion (1-2 lines)

**NOT Allowed**:
- Creating separate .md guide
- Creating test scripts
- Summary boxes
- Repeating information 3 times

---

### Example 3: Bug Investigation

**User**: "Investigate this fuzzer finding"

**Allowed**:
- Test with tools
- Identify root cause
- Report findings (concise)

**NOT Allowed**:
- Creating comprehensive guides
- Multiple summary documents
- Test scripts
- Repeated summaries

---

## Detection Criteria

### You Are Violating This Rule If:

1. **Creating >1 file when user asked to test**
2. **Creating ANY file when user didn't request documentation**
3. **Displaying >1 summary of same information**
4. **Using ASCII art boxes for routine results**
5. **Creating "comprehensive guides" unprompted**
6. **Repeating same information in different formats**
7. **Creating test scripts when tools already exist**

### Self-Check Questions

Before creating documentation:

- [ ] Did user explicitly request documentation?
- [ ] Is this the ONLY document I'm creating?
- [ ] Am I repeating information already stated?
- [ ] Could I report this in 3 lines instead of 3000?
- [ ] Is this a summary of a summary?

If any answer is NO → Don't create the document

---

## Correct Workflows

### Workflow 1: Test Crash File

```bash
# User: "Test crash-abc with project tools"

# Step 1: Test
./Build/Tools/Tool1/tool1 crash-abc 2>&1
# Step 2: Report (1 line)
Result: No crash (exit 0)

# DONE. No files created.
```

### Workflow 2: Add to Fingerprint DB

```bash
# User: "Add crash-xyz to fingerprint database"

# Step 1: Copy file
cp crash-xyz fingerprints/category/descriptive-name.icc

# Step 2: Create metadata (required)
cat > fingerprints/category/descriptive-name.json << EOF
{
  "vuln_type": "...",
  "sha256": "..."
}
EOF

# Step 3: Regenerate index
python3 scripts/regenerate_fingerprint_index.py

# Step 4: Report (1 line)
Added to database (3 new fingerprints)

# DONE. Only required files created.
```

### Workflow 3: Document Bug (When Requested)

```bash
# User: "Document the reproduction for crash-def"

# Step 1: Create ONE markdown file
cat > BUG_NAME_REPRODUCTION.md << EOF
# Bug Name
Reproduction: ./tool crash-file
Result: Crashes at line X
EOF

# Step 2: Report (1 line)
Documentation created: BUG_NAME_REPRODUCTION.md

# DONE. ONE file created.
```

---

## Violations to Track

### Log Format

```
Date: 2026-01-30
Violation: Excessive documentation
Files created: 3 (should be 0)
Summary displays: 5 (should be 1)
User request: "test crash file"
Corrective action: Delete unnecessary files
```

---

## Summary

**Golden Rule**: Technical work = technical output. Don't create novels when user asks for a test result.

**Three Questions**:
1. Did user ask for documentation? → If NO, don't create it
2. Is this information already stated? → If YES, don't repeat it
3. Can I answer in <5 lines? → If YES, do that instead

**Resource Cost**:
- Each markdown file: ~500 tokens to create + context pollution
- Each summary: ~200 tokens + user distraction
- Repeated information: Wasted compute + harder to find actual answer

**Enforcement**: Mandatory. Track violations. Learn from patterns.

---

**Version**: 1.0  
**Created**: 2026-01-30  
**Reference**: .copilot-sessions/governance/CRASH_REPRODUCTION_GUIDE.md  
**Applies to**: All documentation creation decisions
