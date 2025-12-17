
## NEW RULE: Branch/Repository Structure Verification

**Added:** 2026-02-06 (Post-V010)

### When Working Across Multiple Repos/Branches

**BEFORE making changes, verify:**

```bash
# 1. Which branch am I on?
git branch --show-current

# 2. Which branch has the working code?
git branch -a
git log --oneline --graph --all | head -20

# 3. Does this file/directory exist on this branch?
ls -la .clusterfuzzlite/  # or whatever you're modifying
ls -la .github/workflows/

# 4. When was the last commit on this branch vs others?
git log --all --oneline --graph | head -30
```

**Common Mistakes:**
- [FAIL] Assuming master has latest code (might be feature branch)
- [FAIL] Working on wrong repo (action-testing vs user-controllable-input)
- [FAIL] Not checking if file exists on current branch before editing

**Time Investment:** 60 seconds  
**Time Saved:** Potentially hours of failed attempts

---

**Violation Reference:** V010 - 10+ failed CFL attempts on master when cfl branch had working code
