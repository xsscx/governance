# IccAnalyzer Licensing and Copyright Reference
**Purpose**: Internal knowledge document for copyright/licensing verification  
**Status**: Reference documentation (NOT a violation)  
**Created**: 2026-02-07  
**Context**: Package review identified need for licensing knowledge update

---

## CRITICAL DISTINCTION

### iccAnalyzer Tools (David H Hoyt LLC)
**Owner**: David H Hoyt LLC  
**Copyright**: 2021-2026 David H Hoyt LLC  
**Website**: hoyt.net  
**Project Repository**: https://github.com/xsscx/research  
**Support**: GitHub Issues at project repository  
**License**: Proprietary to David H Hoyt LLC  

**Tools Under This License:**
- iccAnalyzer
- iccAnalyzer-lite
- Related security analysis tools

**Key Point**: These are NOT ICC consortium tools. They are proprietary tools developed by David H Hoyt LLC for ICC profile security analysis.

---

### ICC Consortium Tools (Different)
**Owner**: International Color Consortium  
**Repository**: https://github.com/InternationalColorConsortium/iccDEV  
**License**: BSD 3-Clause  
**Project Names**:
- Current: iccDEV
- Legacy (deprecated): DemoIccMAX, RefIccMAX

**Key Point**: Completely separate from David H Hoyt LLC tools.

---

## Correct Copyright Bannering

### For iccAnalyzer Tools

**Version Output** (CORRECT EXAMPLE):
```
=======================================================================
|                     iccAnalyzer-lite v2.9.0                         |
|                                                                     |
|             Copyright (c) 2021-2026 David H Hoyt LLC               |
|                         hoyt.net                                    |
=======================================================================
```

**PACKAGE_INFO.txt SUPPORT Section** (CORRECT FORMAT):
```
SUPPORT
───────
Report issues to: https://github.com/xsscx/research/issues
Project: https://github.com/xsscx/research
Developer: David H Hoyt LLC
Website: hoyt.net
```

**README.md Support Section** (CORRECT FORMAT):
```
## Support

Report issues via GitHub Issues:
https://github.com/xsscx/research/issues

Developer: David H Hoyt LLC
Website: hoyt.net
```

---

## INCORRECT References to Avoid

### DO NOT Reference:
- ❌ International Color Consortium (wrong owner)
- ❌ https://github.com/InternationalColorConsortium/DemoIccMAX (wrong repo)
- ❌ https://github.com/InternationalColorConsortium/iccDEV (wrong repo)
- ❌ "iccDEV development team" (wrong team)
- ❌ BSD 3-Clause license (wrong license for proprietary tools)

### DO Reference:
- ✅ David H Hoyt LLC (correct owner)
- ✅ https://github.com/xsscx/research (correct repo)
- ✅ hoyt.net (correct website)
- ✅ GitHub Issues at xsscx/research (correct support)
- ✅ Copyright (c) 2021-2026 David H Hoyt LLC

---

## Verification Checklist for Future Packages

Before creating any iccAnalyzer package, verify:

### Copyright Bannering
- [ ] Version output shows "Copyright (c) 2021-2026 David H Hoyt LLC"
- [ ] Version output shows "hoyt.net"
- [ ] NO reference to ICC consortium
- [ ] NO reference to iccDEV project

### PACKAGE_INFO.txt
- [ ] SUPPORT section references: https://github.com/xsscx/research
- [ ] Support directs to GitHub Issues
- [ ] NO reference to DemoIccMAX
- [ ] NO reference to ICC development team

### README.md
- [ ] Support section references correct repository
- [ ] Developer identified as David H Hoyt LLC
- [ ] Website listed as hoyt.net
- [ ] NO ICC consortium references

### LICENSE Files
- [ ] License reflects David H Hoyt LLC ownership
- [ ] NO incorrect BSD 3-Clause references for proprietary code
- [ ] Copyright year range accurate (2021-2026)

---

## Source Code Headers

**iccAnalyzer source files should use:**
```cpp
/**
 * iccAnalyzer - ICC Profile Security Analysis Tool
 * Copyright (c) 2021-2026 David H Hoyt LLC
 * https://github.com/xsscx/research
 * 
 * [License terms as appropriate]
 */
```

**NOT the ICC consortium header:**
```cpp
// INCORRECT - Do not use for iccAnalyzer tools:
/**
 * File: [name].cpp
 * Copyright: (c) International Color Consortium
 * [BSD 3-Clause License text]
 */
```

---

## Package Documentation Standards

### Every iccAnalyzer package MUST include:

1. **PACKAGE_INFO.txt** with:
   - Correct copyright holder: David H Hoyt LLC
   - Correct project URL: https://github.com/xsscx/research
   - Support via GitHub Issues

2. **README.md** with:
   - Developer attribution to David H Hoyt LLC
   - Correct support channels
   - Website: hoyt.net

3. **Version output** showing:
   - Copyright (c) 2021-2026 David H Hoyt LLC
   - Website: hoyt.net

---

## Repository Context

### iccLibFuzzer Repository
**Location**: /home/xss/copilot/iccLibFuzzer  
**Purpose**: Contains both:
- ICC consortium tools (iccDEV - BSD 3-Clause)
- David H Hoyt LLC tools (iccAnalyzer - Proprietary)

**Important**: These are different tools with different licenses in the same workspace.

**Verification Protocol**:
When working on files, determine:
1. Is this an ICC consortium tool? → Use ICC copyright
2. Is this a David H Hoyt LLC tool? → Use David H Hoyt LLC copyright
3. Check file headers and attribution before modifying

---

## Common Mistakes to Avoid

### Mistake 1: Assuming All Tools are ICC Tools
**Wrong**: "This is in iccLibFuzzer so it's an ICC tool"  
**Right**: "iccAnalyzer is David H Hoyt LLC proprietary, even though it's in the same workspace"

### Mistake 2: Using Wrong Repository URLs
**Wrong**: Pointing to InternationalColorConsortium repos for iccAnalyzer  
**Right**: https://github.com/xsscx/research for iccAnalyzer

### Mistake 3: Mixing Licenses
**Wrong**: Applying BSD 3-Clause to proprietary tools  
**Right**: Verify ownership before applying license

### Mistake 4: Incorrect Support Channels
**Wrong**: "Report to iccDEV development team"  
**Right**: "Report to https://github.com/xsscx/research/issues"

---

## Future Package Creation Protocol

### Before Creating Package:
1. Review this document
2. Verify copyright holder (David H Hoyt LLC)
3. Check all documentation references
4. Ensure no ICC consortium references
5. Test version output copyright banner
6. Verify PACKAGE_INFO.txt SUPPORT section

### During Package Creation:
1. Use templates with correct attribution
2. Double-check all URLs
3. Verify support channels
4. Check license references

### After Package Creation (H013 Testing):
1. Extract package
2. Check --version output for copyright
3. Review PACKAGE_INFO.txt SUPPORT section
4. Verify README.md attribution
5. Grep for "International Color Consortium" (should be 0)
6. Grep for "DemoIccMAX" (should be 0)
7. Grep for "David H Hoyt LLC" (should be present)

---

## Governance Integration

### This is NOT a Violation
This documentation update is a knowledge improvement, not a violation record.
Future packages should reference this document during H013 verification.

### H013 Enhancement
Add to H013 verification protocol:
- [ ] Verify copyright attribution correct
- [ ] Verify repository URLs correct
- [ ] Verify support channels correct
- [ ] Check against licensing reference document

### File Type Gate Addition
Add to FILE_TYPE_GATES.md:
- Pattern: PACKAGE_INFO.txt, README.md in packages
- Required Doc: iccanalyzer-licensing-reference.md
- Prevention: Incorrect copyright/licensing attribution

---

## Quick Reference Card

```
Tool:        iccAnalyzer / iccAnalyzer-lite
Owner:       David H Hoyt LLC
Copyright:   2021-2026 David H Hoyt LLC
Repository:  https://github.com/xsscx/research
Support:     GitHub Issues at above repository
Website:     hoyt.net
License:     Proprietary (NOT BSD 3-Clause)

DO NOT REFERENCE:
- International Color Consortium
- iccDEV project
- DemoIccMAX repository
- BSD 3-Clause (for these tools)
```

---

## Document History

**Version 1.0** (2026-02-07)
- Initial creation from package review feedback
- Established licensing distinction
- Created verification checklists
- Documented correct attribution formats

**Purpose**: Internal reference for future package creation and verification

**Status**: Active reference documentation

---

**Last Updated**: 2026-02-07  
**Maintained by**: Session governance documentation  
**Review**: Before every iccAnalyzer package creation
