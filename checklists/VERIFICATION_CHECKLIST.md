# Pre-Success Declaration Verification Checklist

**USE THIS BEFORE EVERY "[OK]" DECLARATION**

## For HTML Deliverables

Before declaring "HTML reports generated successfully":

```bash
# 1. Check file exists
ls -lh dist/index.html

# 2. Verify content matches requirement
grep -A10 "Top Bug Categories" dist/index.html | head -20

# 3. Check for known-bad patterns
grep -i "unknown.*73" dist/index.html  # Should be EMPTY
grep -i "error.*404" dist/index.html   # Should be EMPTY

# 4. Verify data accuracy
# Example: If we reclassified UNKNOWN → other categories
# Then HTML should NOT show UNKNOWN category
```

## For Database Updates

Before declaring "Database updated successfully":

```bash
# 1. Count entries
jq '.signatures | length' SIGNATURE_DATABASE.json

# 2. Verify specific requirement met
# Example: No UNKNOWN categories
jq -r '.signatures[].metadata.bug_category' SIGNATURE_DATABASE.json | grep -c "UNKNOWN"
# Should output: 0

# 3. Spot-check sample entries
jq '.signatures[0]' SIGNATURE_DATABASE.json
```

## For Packages

Before declaring "Final package created":

```bash
# 1. Extract and verify
unzip -q package.zip -d /tmp/verify
grep -i "known_bad_pattern" /tmp/verify/index.html
rm -rf /tmp/verify

# 2. Check file size makes sense
ls -lh package.zip
# If it's 6MB but should be 24MB → something's wrong

# 3. Verify SHA256 generated
test -f package.zip.sha256 && echo "OK" || echo "MISSING"
```

## General Rule

**Before claiming success:**
1. Show the command that verifies it
2. Show the output proving it
3. Then declare success

**NOT:**
1. Run script
2. Assume it worked
3. Declare success [FAIL]

---

**Created:** 2026-02-01  
**Reason:** Double package failure - shipped 2 broken packages as "final"  
**Cost of violation:** 8 min user time, 6000 tokens, moderate trust damage
