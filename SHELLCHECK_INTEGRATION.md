# ShellCheck CI/CD Integration for LLMCJF

## Purpose

Automated validation of all Bash scripts in llmcjf/ using ShellCheck to prevent:
- Syntax errors
- Common Bash pitfalls
- Unsafe patterns
- Compatibility issues

## ShellCheck Configuration

### Local Installation

```bash
# Ubuntu/Debian
sudo apt-get install shellcheck

# macOS
brew install shellcheck

# Verify installation
shellcheck --version
```

### GitHub Actions Workflow

Create `.github/workflows/shellcheck.yml`:

```yaml
name: ShellCheck Validation

on:
  push:
    paths:
      - 'llmcjf/**/*.sh'
      - 'scripts/**/*.sh'
  pull_request:
    paths:
      - 'llmcjf/**/*.sh'
      - 'scripts/**/*.sh'

jobs:
  shellcheck:
    name: Shellcheck
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run ShellCheck
        uses: ludeeus/action-shellcheck@master
        with:
          scandir: './llmcjf'
          severity: 'warning'
          format: 'gcc'
          
      - name: Check scripts directory
        uses: ludeeus/action-shellcheck@master
        with:
          scandir: './scripts'
          severity: 'warning'
          format: 'gcc'
```

### Pre-commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Pre-commit hook: Run ShellCheck on staged .sh files

if ! command -v shellcheck >/dev/null 2>&1; then
    echo "Warning: shellcheck not installed, skipping validation"
    exit 0
fi

# Get staged .sh files
staged_files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sh$')

if [ -z "$staged_files" ]; then
    exit 0
fi

echo "Running ShellCheck on staged files..."

failed=0
for file in $staged_files; do
    if [ -f "$file" ]; then
        shellcheck "$file"
        if [ $? -ne 0 ]; then
            failed=1
        fi
    fi
done

if [ $failed -eq 1 ]; then
    echo ""
    echo "ShellCheck found issues. Please fix before committing."
    exit 1
fi

exit 0
```

## Local Validation Commands

### Check all scripts

```bash
# Check llmcjf session init
shellcheck governance/llmcjf-session-init.sh

# Check test suite
shellcheck governance/tests/test-llmcjf-functions.sh

# Check session start
shellcheck scripts/session-start.sh

# Check all .sh files recursively
find . -name '*.sh' -type f -exec shellcheck {} +
```

### Common ShellCheck Warnings

**SC2086**: Double quote to prevent globbing and word splitting
```bash
# Bad
cmd $var

# Good
cmd "$var"
```

**SC2164**: Use 'cd ... || exit' in case cd fails
```bash
# Bad
cd "$dir"

# Good
cd "$dir" || exit 1
```

**SC2155**: Declare and assign separately to avoid masking return values
```bash
# Bad
local var=$(command)

# Good
local var
var=$(command)
```

## Excluded Checks

Some checks may be disabled for specific scripts:

```bash
# Disable specific check for entire file
# shellcheck disable=SC2086
source_file="$1"

# Disable for single line
# shellcheck disable=SC2086
echo $unquoted_var  # Intentionally unquoted
```

## Integration with LLMCJF Testing

### Test Script Validation

```bash
# Validate test script before running
shellcheck governance/tests/test-llmcjf-functions.sh && \
./governance
/tests/test-llmcjf-functions.sh
```

### Continuous Validation

```bash
# Watch for changes and validate
while inotifywait -e modify governance/**/*.sh; do
    shellcheck governance/**/*.sh
done
```

## Metrics

Track ShellCheck compliance:

```bash
# Count total scripts
total_scripts=$(find governance scripts -name '*.sh' | wc -l)

# Count scripts passing ShellCheck
passing_scripts=$(find governance scripts -name '*.sh' -exec shellcheck {} + 2>&1 | grep -c "^$" || echo 0)

# Compliance rate
echo "Compliance: $passing_scripts/$total_scripts"
```

## Current Status (2026-02-06)

**Scripts in llmcjf/:**
- llmcjf-session-init.sh (848 lines)
- tests/test-llmcjf-functions.sh (236 lines)

**Target:** 100% ShellCheck compliance before deployment

## References

- **ShellCheck Wiki:** https://www.shellcheck.net/wiki/
- **ShellCheck GitHub:** https://github.com/koalaman/shellcheck
- **GitHub Action:** https://github.com/ludeeus/action-shellcheck
