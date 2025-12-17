# H019: Context Verification Mandatory

**Created:** 2026-02-07  
**Trigger:** V028 (Wrong repository push attempt)  
**Severity:** TIER 1 (Hard Stop)  
**Category:** Pre-Operation Verification  

## Rule Statement

**BEFORE ANY `git push` OPERATION:**

MUST verify ALL of:
1. Working directory (pwd)
2. Current branch (git branch --show-current)
3. Remote URL (git remote -v)
4. Object count (reasonable scale check)

MUST include ALL context in ask_user confirmation.

## Implementation

### Pre-Push Checklist

```bash
# MANDATORY - Run before every git push
echo "Context Verification (H019):"
echo "  Directory: $(pwd)"
echo "  Branch: $(git branch --show-current)"
echo "  Remote: $(git remote -v | grep push)"
echo "  Commits ahead: $(git rev-list --count @{u}..HEAD 2>/dev/null || echo 'N/A')"
```

### ask_user Template

```
Confirm git push:
- Repository: [name] ([parent/submodule/standalone])
- Directory: [full path]
- Current branch: [branch]
- Target: [remote] [branch]
- Commits: [count]
- Estimated objects: [count]

Proceed?
```

### Scale Sanity Checks

**STOP and investigate if:**
- Object count > 1,000 for routine commit
- Object count > 10,000 for any push
- Compressing > 40,000 objects (entire repository)

**Red Flags:**
- "Enumerating objects: 83501" ← WRONG (should be < 100)
- "Compressing objects: 43055" ← WRONG (entire repo)
- Different branch name than expected

## Violation Triggers

### V028 Example

**What Agent Did:**
```bash
# From: /home/xss/copilot/iccLibFuzzer
git push origin master --force-with-lease
# Enumerating objects: 83501 ← RED FLAG IGNORED
```

**What Should Have Happened:**
```bash
# Step 1: Verify context
pwd  # /home/xss/copilot/iccLibFuzzer
git branch --show-current  # master
# [WARN] MISMATCH: Need to push llmcjf (main), not iccLibFuzzer (master)

# Step 2: Navigate to correct repo
cd llmcjf
pwd  # /home/xss/copilot/iccLibFuzzer/llmcjf
git branch --show-current  # main [OK]

# Step 3: ask_user with full context
# [Include all verification output]

# Step 4: Push
git push origin main --force-with-lease
```

## Related Heuristics

- **H016:** NEVER push without ask_user (provides confirmation)
- **H019:** CONTEXT-VERIFICATION-MANDATORY (provides correct context for H016)
- **H011:** DOCUMENTATION-CHECK-MANDATORY (check status before action)

**Relationship:** H019 ensures H016 asks the RIGHT question.

## Pattern Prevention

This rule prevents:
- Wrong repository push (V028)
- Wrong branch push (V020)
- Wrong scale push (V028 - 83,501 objects)
- Directory confusion
- Submodule vs parent confusion

## Enforcement

**TIER 1 - NEVER VIOLATE:**
- NO git push without context verification
- NO exceptions for "simple" pushes
- NO assumptions about current directory
- NO reliance on memory - ALWAYS verify

## Quick Reference

**Every git push MUST start with:**
```bash
pwd && git branch --show-current && git remote -v
```

**Then include output in ask_user before push.**

**If object count > 1000, STOP and investigate.**

---
*Created in response to V028: Wrong repository push attempt (83,501 objects to wrong repo/branch). Third git push failure in recent sessions.*
