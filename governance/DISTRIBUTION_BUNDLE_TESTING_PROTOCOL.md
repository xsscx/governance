# Distribution Bundle Testing Protocol

**Required Testing Before Any Bundle Claim**

This protocol MUST be followed before claiming any distribution bundle is ready.

## Mandatory Verification Steps

### 1. Extract Bundle to Temporary Directory
```bash
cd /tmp
rm -rf test-bundle-verification
mkdir test-bundle-verification
cd test-bundle-verification
unzip /path/to/bundle.zip
```

### 2. Verify Critical Files Present
```bash
# Check directory structure
ls -la dist/

# Verify required files
test -f dist/serve-utf8.py && echo "✓ UTF-8 server" || echo "✗ MISSING"
test -f dist/index.html && echo "✓ Index page" || echo "✗ MISSING"
test -f dist/stats.html && echo "✓ Stats page" || echo "✗ MISSING"
test -d dist/categories && echo "✓ Categories dir" || echo "✗ MISSING"
test -d dist/details && echo "✓ Details dir" || echo "✗ MISSING"
test -d dist/css && echo "✓ CSS dir" || echo "✗ MISSING"
test -d dist/js && echo "✓ JS dir" || echo "✗ MISSING"

# Count HTML files
find dist -name "*.html" -type f | wc -l
```

### 3. Test Server Script Launches
```bash
cd dist
python3 serve-utf8.py &
SERVER_PID=$!
sleep 2

# Test index page accessible
curl -s http://localhost:8000/ | grep -o "<title>.*</title>"

# Cleanup
kill $SERVER_PID
```

### 4. Verify Claimed Features in Generated HTML

For each claimed feature, grep the actual HTML files:

```bash
# Example: Verify navigation links
grep -n "Categories" dist/categories/null-pointer-dereference.html

# Example: Verify search boxes
grep -n "searchBox" dist/signatures-high.html

# Example: Verify collapsible sections
grep -n "<details" dist/details/*.html | head -5

# Example: Verify footer timestamps
grep -n "Generated:" dist/index.html
```

### 5. Document Test Results

Create verification report with:
- All tests performed
- Pass/fail status for each
- Actual output snippets proving features work
- File counts and sizes

## Automatic Bundle Regeneration

**Bundle generation MUST happen after code changes:**

```bash
# 1. Make code changes to generator
vim scripts/generate_static_site_simple.py

# 2. Regenerate site
python3 scripts/generate_static_site_simple.py

# 3. Delete old bundle
rm -f iccanalyzer-html-report-*.zip

# 4. Create new bundle with timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
zip -r iccanalyzer-html-report-v2.4-${TIMESTAMP}.zip dist/ -x "dist/fingerprints/*"

# 5. VERIFY bundle (see steps 1-4 above)

# 6. Only commit if verification passes
git add scripts/ dist/ iccanalyzer-html-report-*.zip
git commit -m "Description of change with verification proof"
```

## Required Documentation in Commit Messages

Every commit with bundle changes MUST include:

```
Add [feature name] to HTML reports

Verification:
- Extracted bundle to /tmp/test-bundle-verification
- Verified [feature] present in [specific files]
- Tested [functionality] works as expected
- Server script launches: PASS
- File count: [N] HTML files
- Bundle size: [N]K

Files tested:
- dist/categories/null-pointer-dereference.html (line 15)
- dist/index.html (line 42)
```

## LLMCJF Violation Prevention

**NEVER:**
- Claim bundle ready without extraction test
- Assume generation == verification
- Skip server launch test
- Commit bundle without verification proof

**ALWAYS:**
- Extract and inspect bundle contents
- Test server script runs
- Grep actual HTML for claimed features
- Document what was tested and results

## Checklist (Copy to Commit Message)

```
Distribution Bundle Verification Checklist:
- [ ] Bundle extracted to /tmp/test-bundle-verification
- [ ] serve-utf8.py present and launches
- [ ] Server serves index page successfully
- [ ] All claimed features verified in actual HTML files
- [ ] Navigation links tested (grepped for presence)
- [ ] File counts match expectations
- [ ] Test results documented below

Test Results:
[paste actual test output here]
```

## Example Verification Session

```bash
# Full verification example
cd /tmp && rm -rf test-bundle-verification && mkdir test-bundle-verification
cd test-bundle-verification
unzip /home/user/project/bundle.zip

# Verify structure
ls -la dist/ | grep -E "categories|css|js|serve-utf8"

# Test server
cd dist && python3 serve-utf8.py &
sleep 2 && curl -s http://localhost:8000/ | grep "<title>"
kill %1

# Verify features
grep "Categories" dist/categories/*.html | wc -l  # Should match category count
grep "searchBox" dist/signatures-*.html | wc -l   # Should be 3 (high/med/low)
grep "<details" dist/details/*.html | head -3     # Should show collapsible sections

# Document results
echo "✓ All tests passed" > verification-results.txt
```

---

**Last Updated:** 2026-02-01  
**Reason:** LLMCJF Violation #002 - Missing UTF-8 server in bundle  
**Enforcement:** MANDATORY before any distribution bundle claims
