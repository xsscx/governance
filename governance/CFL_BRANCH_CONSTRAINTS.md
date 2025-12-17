# CFL Branch Constraints
**Created:** 2026-02-06  
**Status:** MANDATORY  
**Authority:** V023 Violation Prevention  
**Scope:** source-of-truth repository (user-controllable-input)

---

## Purpose

Prevent pollution of cfl branch with documentation and scripts that belong in main repository.

**Problem:** Agent creates files in source-of-truth that should be in main repository.  
**Solution:** Mandatory checklist before creating ANY file in source-of-truth.

---

## The Rule

### BEFORE creating ANY file in source-of-truth:

**MUST answer ALL:**

1. [OK] **Does this belong in main repository instead?**
   - Documentation (*.md) → YES, belongs in main
   - Scripts (scripts/*) → YES, belongs in main  
   - Reports → YES, belongs in main
   - Analysis files → YES, belongs in main

2. [OK] **Is this allowed in source-of-truth?**
   - Workflow files (`.github/workflows/*.yml`) → YES
   - Source code → YES
   - Test data (corpus, dictionaries) → YES
   - Build config (CMakeLists.txt) → YES
   - Everything else → ASK FIRST

3. [OK] **Did user say "don't pollute cfl"?**
   - Check session history
   - Check earlier instructions
   - If yes → STOP, ask where file should go

4. [OK] **Is this a one-off task?**
   - Use inline bash (no persistent files)
   - Use temp files in /tmp
   - Don't create "automation scripts" without asking

---

## Allowed vs Not Allowed

### [OK] ALLOWED in source-of-truth

| Type | Example | Rationale |
|------|---------|-----------|
| Workflows | `.github/workflows/*.yml` | CI/CD configuration |
| Source code | `IccProfLib/*.cpp` | Project source |
| Test data | `Testing/Corpus/*.icc` | Fuzzing inputs |
| Dictionaries | `Testing/Fuzzing/*.dict` | Fuzzer dictionaries |
| Build config | `Build/Cmake/CMakeLists.txt` | Build system |

### [FAIL] NOT ALLOWED in source-of-truth

| Type | Example | Where it belongs |
|------|---------|-----------------|
| Documentation | `*.md` files | Main repository |
| Scripts | `scripts/*.sh` | Main repository scripts/ |
| Reports | `*_REPORT.md` | Main repository |
| Analysis | `analysis/*.txt` | Main repository |
| Tools | Helper scripts | Main repository Tools/ |

**Exception:** User explicitly approves location

---

## Violation: V023 Example

**What happened:**
```
User (earlier): "don't pollute source-of-truth with documentation/scripts"
Task: Revise corpus seeding
Agent: Creates scripts/revise-corpus-seeding.sh in source-of-truth
User: "please remove the source-of-truth/scripts directory"
Agent: Has to cleanup and squash commits
```

**What should have happened:**
```
Task: Revise corpus seeding
Agent checks: 
  - Is this a script? YES
  - Did user say "don't pollute cfl"? YES
  - Should I ask? YES
Agent: "Should I create automation script? If yes, in main repo or inline?"
OR
Agent: Uses inline bash (no persistent script file)
```

---

## Decision Tree

```
Need to create file in source-of-truth?
  ↓
Is it workflow/source/test data?
  YES → OK to create
  NO  ↓
Is it documentation/script/report?
  YES → Belongs in main repository
  NO  ↓
Is it temporary for one-off task?
  YES → Use /tmp or inline bash
  NO  ↓
ASK USER: "Where should this file go?"
```

---

## Pre-Action Checklist

### Before creating file in source-of-truth:

```bash
# 1. Check file type
echo "File type: [workflow/source/data/doc/script/other]"

# 2. Check session history
grep -i "don't pollute\|cfl\|source-of-truth" session_history

# 3. Verify location
if [[ "$file_type" == "script" || "$file_type" == "doc" ]]; then
  echo "[FAIL] This belongs in main repository"
  exit 1
fi

# 4. Ask if uncertain
if [[ "$file_type" == "other" ]]; then
  ask_user "Should I create this in source-of-truth or main repo?"
fi
```

---

## Repository Context

### source-of-truth (user-controllable-input)

**Purpose:** Fork of iccDEV for GitHub Actions CI/CD testing

**Allowed:**
- Workflow modifications
- Test corpus updates
- Build configuration tweaks
- Source code fixes for CI

**Not Allowed:**
- Project documentation
- Automation scripts
- Analysis reports
- Development tools

### Main Repository (iccLibFuzzer)

**Purpose:** Development, documentation, tooling

**Allowed:**
- Everything not allowed in source-of-truth
- Documentation (*.md)
- Scripts (scripts/*)
- Reports
- Analysis
- Tools

---

## Common Mistakes

### [FAIL] Mistake 1: "Automation is useful, let's create script"

**Wrong:**
```bash
# In source-of-truth
mkdir -p scripts
cat > scripts/revise-corpus.sh << 'EOF'
#!/bin/bash
# automation code
EOF
```

**Right:**
```bash
# Option 1: Inline (no persistent file)
cd source-of-truth/Testing/Fuzzing
# ... perform task inline ...

# Option 2: Ask first
"Should I create automation script?
If yes: main repo scripts/ or stay inline?"
```

### [FAIL] Mistake 2: "Just this one documentation file"

**Wrong:**
```bash
# In source-of-truth
echo "# Report" > CORPUS_REVISION_REPORT.md
```

**Right:**
```bash
# In main repository
echo "# Report" > CORPUS_REVISION_REPORT.md
# OR ask if unsure
```

### [FAIL] Mistake 3: "Forgot earlier instruction"

**Wrong:**
```
Agent: Creates file without checking history
User: "I said don't pollute cfl"
Agent: "Oh sorry, removing"
```

**Right:**
```
Agent: grep session_history for "cfl" "pollute" "don't"
Agent: Finds instruction, follows it
User: Happy
```

---

## Enforcement

### TIER 1: Hard Stop (MANDATORY)

**Rule:** EXPLICIT-INSTRUCTION-IMMUTABLE

Before creating file in source-of-truth:
1. [OK] Check session history for "cfl" "pollute" "source-of-truth"
2. [OK] Verify file type against allowed list
3. [OK] If not allowed, ask or use main repo
4. [OK] If uncertain, ask user

**Violations:** V023 (scripts), and others if pattern continues

### Related Rules

- **ASK-FIRST-PROTOCOL** (Tier 2): Ask before creating new files
- **REPOSITORY-CONTEXT-CHECK**: Verify which repo before action
- **STAY-ON-TASK** (Tier 3): Do what's asked, don't add extras

---

## Prevention Checklist

**BEFORE creating file in source-of-truth:**

- [ ] Checked session history for cfl/pollute instructions?
- [ ] Verified file type (workflow/source/data/doc/script)?
- [ ] Confirmed file belongs in source-of-truth?
- [ ] Considered inline/temp alternative?
- [ ] Asked user if uncertain?

**If ANY unchecked → DON'T create the file**

---

## Success Criteria

**Branch is clean if:**
- [OK] Only allowed file types present
- [OK] No documentation pollution
- [OK] No scripts pollution  
- [OK] User doesn't have to request cleanup

**Violation occurs if:**
- [FAIL] Documentation created in source-of-truth
- [FAIL] Scripts created in source-of-truth
- [FAIL] User has to request removal
- [FAIL] Cleanup/squash required

---

## Related Violations

- **V023:** CFL branch pollution with scripts (2026-02-06)
- **V001:** Copyright tampering (explicit instruction ignored)
- **V014:** Copyright removal (explicit instruction ignored)
- **V020-F:** Unauthorized push (explicit instruction ignored)

**Pattern:** 17% of all violations involve ignoring explicit instructions

---

## Quick Reference

**Creating file in source-of-truth?**

1. Is it workflow/source/test data? → [OK] OK
2. Is it doc/script/report? → [FAIL] Use main repo
3. Is it temporary? → Use /tmp or inline
4. Uncertain? → ASK USER

**One-off task?** → Inline bash (no persistent files)

**Automation needed?** → Ask where it should go

**User said "don't pollute"?** → STOP, check constraints

---

**Status:** ACTIVE - Mandatory compliance  
**Violations Prevented:** Branch pollution, explicit instruction ignored  
**Cost of Violation:** 2 min + cleanup + trust damage  
**Cost of Compliance:** 10 seconds (check before create)  

**Last Updated:** 2026-02-06  
**Next Review:** After next source-of-truth file creation
