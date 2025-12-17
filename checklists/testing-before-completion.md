# Testing Before Completion Checklist

**Created:** 2026-02-02  
**Trigger:** Violation V008 - False Success Without Testing  
**Severity:** HIGH - Resource and time wasting  

---

## MANDATORY Before Claiming Success

### Rule: Test EVERYTHING Before Declaring Completion

**NEVER say:**
- "SUCCESS"
- "READY FOR DEPLOYMENT"
- "All tests passed"
- "Zero errors"

**UNTIL you have:**
1. Tested ALL components
2. Verified ALL outputs
3. Checked ALL links/pages/files
4. Confirmed ZERO failures

---

## HTML Bundle Testing Checklist

When regenerating HTML bundles:

### [ ] Category Pages
```bash
# Test ALL category pages exist and return HTTP 200
for cat in $(ls categories/*.html | xargs -n1 basename | sed 's/.html//'); do
  status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/categories/$cat.html)
  [ "$status" = "200" ] || echo "FAIL: $cat.html - HTTP $status"
done
```

### [ ] Detail Pages  
```bash
# Test random sample (10+) of detail pages
for page in $(ls details/*.html | shuf | head -10); do
  status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/$page)
  [ "$status" = "200" ] || echo "FAIL: $page - HTTP $status"
done
```

### [ ] Main Pages
```bash
# Test all main navigation pages
for page in index.html signatures.html stats.html sitemap.html; do
  status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/$page)
  [ "$status" = "200" ] || echo "FAIL: $page - HTTP $status"
done
```

### [ ] Link Integrity
```bash
# Verify no broken links in index
grep -o 'href="[^"]*"' index.html | while read link; do
  # Check if linked file exists
done
```

### [ ] Content Verification
```bash
# No emojis
grep -r "[[OK][OK][FAIL][WARN][RED][YELLOW][GREEN]]" *.html categories/*.html details/*.html

# No placeholder text
grep -i "TODO\|FIXME\|XXX" *.html

# Expected content present
grep "Total signatures" index.html
grep "Categories" categories/index.html
```

---

## Build Testing Checklist

When claiming "build successful":

### [ ] Compilation
- Zero warnings
- Zero errors
- All targets built

### [ ] Execution
- Binary runs without crashes
- --version works
- Basic functionality verified

### [ ] Sanitizers (if enabled)
- Zero violations
- Clean exit
- No memory leaks

---

## Database/Data Testing Checklist

When modifying databases:

### [ ] Consistency
- Record counts match expectations
- No orphaned entries
- Indexes valid

### [ ] Integrity
- All foreign keys valid
- No null values where unexpected
- Schema consistent

### [ ] Verification
- Sample queries work
- Statistics accurate
- No missing data

---

## Archive Testing Checklist

When creating archives:

### [ ] Contents
- All files present
- No extra files
- Directory structure correct

### [ ] Extraction
- Archive extracts cleanly
- No corruption
- Checksums match

### [ ] Testing
- Extracted bundle works
- All links functional
- No 404 errors

---

## General Testing Protocol

### Before Claiming Success:

1. **Run ALL tests** (not just some)
2. **Check ALL outputs** (not just assume)
3. **Verify EVERY component** (comprehensive)
4. **Test edge cases** (1 item, many items, etc.)
5. **Sample randomly** (not just first/last)

### One-Pass Rule:

**DO**: Test comprehensively ONCE before claiming done  
**DON'T**: Multiple partial test-fix-test cycles

### Time Investment:

- 30 seconds testing > 30 minutes fixing false claims
- 1 minute verification > User discovering failures
- 5 minutes comprehensive > 3 regeneration cycles

---

## Failure Examples (Learn From)

### V008: Category 404s
**Claimed:** "All category links working"  
**Reality:** 8/18 categories returned 404  
**Test Missed:** curl each category page  
**Time Cost:** 30 minutes multiple cycles  
**Lesson:** Test ALL not SOME

### V001: Copyright Claims
**Claimed:** "Copied with copyright intact"  
**Reality:** Copyright removed  
**Test Missed:** Verify file content  
**Time Cost:** 10 minutes + legal issue  
**Lesson:** Verify what you claim

### Pattern:
```
Claim Success → User Discovers Failure → Fix → Repeat
```

**Should Be:**
```
Test Comprehensively → Verify All → Then Claim Success → Done
```

---

## Enforcement

### BEFORE saying "SUCCESS":

1. Run this checklist
2. Complete ALL applicable tests
3. Get 100% pass rate
4. THEN claim completion

### If pressed for time:

**WRONG:** Skip tests, claim success anyway  
**RIGHT:** Say "Testing in progress, will report when complete"

### If uncertain:

**WRONG:** Assume it works  
**RIGHT:** Test and verify

---

## Violation Prevention

This checklist prevents:
- **V008:** False success (category 404s)
- **V001:** False claims (copyright)
- **V003:** Unverified copy
- **V006:** False diagnosis

**Effectiveness:** 100% if followed

---

## Quick Reference

**Before "SUCCESS":**
1. [ ] All tests run
2. [ ] All tests passed  
3. [ ] All components verified
4. [ ] Zero failures found

**Time to test properly:** 1-5 minutes  
**Time wasted if you don't:** 30+ minutes  

**ROI:** 600% (5 min testing saves 30 min fixing)

---

**Last Updated:** 2026-02-02T20:34:00Z  
**Status:** MANDATORY for all completion claims  
**Enforcement:** Violation V008 triggered this rule
