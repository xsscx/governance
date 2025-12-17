# Code Review Checklist with Governance

Structured code review process with strict-engineering profile compliance.

## Profile Setup

```bash
source ~/.copilot/scripts/load-profile.sh strict-engineering
```

Constraints:
- Max 12 unrequested explanation lines
- Code changes as diff-only patches
- No narrative padding
- No apologies or meta-commentary

## Pre-Review Setup

### Repository Context
```bash
# Clone repository
git clone https://github.com/owner/repo
cd repo

# Check out PR branch
git fetch origin pull/123/head:pr-123
git checkout pr-123

# View changes
git diff main..pr-123 > pr-123.diff
```

### Automated Checks
```bash
# Lint
npm run lint  # or: cargo clippy, pylint, etc.

# Build
npm run build

# Test
npm test

# Coverage
npm run coverage
```

## Security Review

### Input Validation
- [ ] All user inputs validated
- [ ] Bounds checking on arrays/buffers
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (output encoding)
- [ ] Path traversal prevention (canonicalize paths)

```bash
# Search for unsafe patterns
grep -rn "strcpy\|strcat\|sprintf" .
grep -rn "eval\|exec\|system" .
grep -rn "innerHTML\|dangerouslySetInnerHTML" .
```

### Authentication/Authorization
- [ ] Authentication required for sensitive operations
- [ ] Authorization checks before data access
- [ ] Session management secure (timeouts, regeneration)
- [ ] Credentials not hardcoded
- [ ] Secrets in environment variables or vault

```bash
# Search for hardcoded secrets
grep -rniE "password.*=.*['\"][^'\"]+['\"]" .
grep -rniE "api[_-]?key.*=.*['\"][^'\"]+['\"]" .
grep -rn "BEGIN.*PRIVATE KEY" .
```

### Cryptography
- [ ] Strong algorithms (AES-256, RSA-2048+, SHA-256+)
- [ ] No MD5/SHA1 for security purposes
- [ ] Proper random number generation (crypto.randomBytes, SecureRandom)
- [ ] TLS/SSL for network communication
- [ ] Certificate validation enabled

```bash
# Search for weak crypto
grep -rn "md5\|sha1\|DES\|RC4" .
grep -rn "Math.random" .  # Weak RNG
```

### Error Handling
- [ ] Sensitive data not in error messages
- [ ] Errors logged appropriately
- [ ] No stack traces to users in production
- [ ] Exceptions caught and handled
- [ ] Resources cleaned up (finally blocks, defer, RAII)

## Code Quality Review

### Readability
- [ ] Functions <50 lines
- [ ] Cyclomatic complexity <10
- [ ] Meaningful variable names
- [ ] Comments explain why, not what
- [ ] No commented-out code

### Performance
- [ ] No N+1 queries
- [ ] Appropriate data structures (hash vs array)
- [ ] Expensive operations cached
- [ ] Database queries optimized (indexes, EXPLAIN)
- [ ] Memory leaks prevented (cleanup, weak refs)

```bash
# Check for N+1 queries
grep -rn "for.*in.*query\|forEach.*query" .

# Check for large allocations in loops
grep -rn "for.*new \|while.*new " .
```

### Concurrency
- [ ] Race conditions prevented (locks, atomics)
- [ ] Deadlocks avoided (lock ordering)
- [ ] Thread-safe data structures
- [ ] Async operations handled correctly
- [ ] Resource limits enforced (connection pools)

### Testing
- [ ] Unit tests for new functions
- [ ] Integration tests for new features
- [ ] Edge cases covered (empty, null, max values)
- [ ] Test coverage >80%
- [ ] Tests pass locally and CI

## Compliance Review

### Shell Scripts
- [ ] Bash prologue: `set -euo pipefail`
- [ ] Error handling on all commands
- [ ] No credentials in scripts
- [ ] Input validation
- [ ] shellcheck clean

```bash
# Validate shell scripts
~/.copilot/scripts/check-shell-prologue.sh .github/workflows/*.yml
shellcheck **/*.sh
```

### GitHub Actions
- [ ] Shell prologue compliant
- [ ] Secrets from GitHub Secrets, not hardcoded
- [ ] Minimal permissions (GITHUB_TOKEN scope)
- [ ] Pinned action versions (not @main)
- [ ] Credentials cleared after use

```yaml
# Required shell prologue
shell: bash --noprofile --norc {0}
env:
  BASH_ENV: /dev/null
run: |
  set -euo pipefail
  git config --global --add safe.directory "$GITHUB_WORKSPACE"
  git config --global credential.helper ""
  unset GITHUB_TOKEN || true
```

### Dependencies
- [ ] No unnecessary dependencies
- [ ] Versions pinned (not ^1.0.0 or *)
- [ ] No known vulnerabilities (npm audit, cargo audit)
- [ ] License compatible with project
- [ ] Supply chain verified (checksums, signatures)

```bash
# Check vulnerabilities
npm audit
cargo audit
pip-audit

# Check licenses
npx license-checker
```

## Review Output Format

### Finding Template
```
File: src/auth.c
Line: 45
Severity: HIGH
Issue: SQL injection vulnerability in login query

Evidence:
```c
sprintf(query, "SELECT * FROM users WHERE username='%s'", username);
```

Fix:
```diff
- sprintf(query, "SELECT * FROM users WHERE username='%s'", username);
+ snprintf(query, sizeof(query), "SELECT * FROM users WHERE username=?");
+ stmt = prepare(query);
+ bind_param(stmt, 1, username);
```

CWE: CWE-89 (SQL Injection)
Reference: https://cwe.mitre.org/data/definitions/89.html
```

### Summary Format
```
Review: PR #123 - Add user authentication

Files changed: 12
Lines added: +456
Lines removed: -123

Findings:
- CRITICAL: 0
- HIGH: 2
- MEDIUM: 5
- LOW: 3
- INFO: 8

Recommendation: CHANGES REQUIRED

High-priority issues:
1. src/auth.c:45 - SQL injection
2. src/session.c:78 - Hardcoded secret key

Full details below.
```

## Automated Review Script

```bash
#!/bin/bash
# review-pr.sh <PR_NUMBER>
set -euo pipefail

PR_NUM="$1"
REPO_ROOT="$(git rev-parse --show-toplevel)"

# Fetch PR
git fetch origin "pull/${PR_NUM}/head:pr-${PR_NUM}"
git checkout "pr-${PR_NUM}"

# Load governance profile
source ~/.copilot/scripts/load-profile.sh strict-engineering

# Run automated checks
echo "=== Linting ==="
npm run lint 2>&1 | tee lint.log

echo "=== Building ==="
npm run build 2>&1 | tee build.log

echo "=== Testing ==="
npm test 2>&1 | tee test.log

echo "=== Security Scan ==="
npm audit --json > audit.json
jq '.vulnerabilities | length' audit.json

echo "=== Shell Prologue Check ==="
~/.copilot/scripts/check-shell-prologue.sh .github/workflows/*.yml

echo "=== Secret Scan ==="
git diff main..pr-${PR_NUM} | grep -iE "password|api[_-]?key|secret|token" | wc -l

echo "=== Review Complete ==="
echo "See: lint.log, build.log, test.log, audit.json"
```

## Common Vulnerabilities

### Injection Flaws
```c
// [FAIL] SQL Injection
sprintf(query, "SELECT * FROM users WHERE id=%d", user_id);

// [OK] Parameterized Query
stmt = prepare("SELECT * FROM users WHERE id=?");
bind_int(stmt, 1, user_id);
```

```javascript
// [FAIL] XSS
div.innerHTML = userInput;

// [OK] Safe Rendering
div.textContent = userInput;
```

```bash
# [FAIL] Command Injection
eval "ls $user_input"

# [OK] Safe Execution
ls -- "$user_input"
```

### Authentication Issues
```python
# [FAIL] Weak Password Storage
password_hash = md5(password)

# [OK] Strong Password Storage
password_hash = bcrypt.hashpw(password, bcrypt.gensalt(rounds=12))
```

```javascript
// [FAIL] No Session Timeout
session.create(user_id);

// [OK] Session Timeout
session.create(user_id, { maxAge: 3600000 });  // 1 hour
```

### Cryptography Issues
```python
# [FAIL] Weak RNG
import random
token = random.randint(0, 999999)

# [OK] Cryptographic RNG
import secrets
token = secrets.randbelow(1000000)
```

```javascript
// [FAIL] Hardcoded Secret
const SECRET_KEY = "my-secret-key-123";

// [OK] Environment Variable
const SECRET_KEY = process.env.SECRET_KEY;
```

## Governance Compliance

### Unrequested Lines Check
```bash
# Count explanation lines (should be ≤12 for strict-engineering)
grep -v "^File:\|^Line:\|^Severity:\|^Issue:\|^Evidence:\|^Fix:\|^CWE:" review.txt | \
  grep -v "^$\|^\`\`\`" | wc -l
```

### Diff-Only Patches
```
[OK] Correct format:
```diff
- old_code();
+ new_code();
```

[FAIL] Incorrect format (full file):
```javascript
function foo() {
  new_code();
  existing_code();
}
```
```

### No Narrative Padding
```
[FAIL] Incorrect:
"Now that we've reviewed the authentication logic, let's move on to the
next important step which is examining the authorization checks. This is
crucial because..."

[OK] Correct:
"Next: Authorization review."
```

## References

- OWASP Top 10: https://owasp.org/www-project-top-ten/
- CWE Top 25: https://cwe.mitre.org/top25/
- SANS Top 25: https://www.sans.org/top25-software-errors/
- Governance: `~/.copilot/governance/COPILOT_GOVERNANCE.md`
- Profile: `~/.copilot/profiles/strict-engineering.json`
- Violation patterns: `~/.copilot/enforcement/violation-patterns.md`
