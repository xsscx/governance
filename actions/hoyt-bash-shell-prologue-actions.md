# Hoyt's BASH Shell Prologue Examples for Actions

## Configure Git Environment

```
      - name: Configure Git Environment
        shell: bash --noprofile --norc {0}
        env:
          BASH_ENV: /dev/null
        run: |
          set -euo pipefail
          git config --add safe.directory "$PWD"
          git config --global credential.helper ""
          unset GITHUB_TOKEN || true
```

## Template for ENV:GITHUB_WORKSPACE

```
        shell: bash --noprofile --norc {0}
        env:
          BASH_ENV: /dev/null
        run: |
          set -euo pipefail
          git config --global --add safe.directory "$GITHUB_WORKSPACE"
          git config --global credential.helper ""
          unset GITHUB_TOKEN || true
```
## Summary

[Do not trust the `AI` to do anything securely](https://github.com/xsscx/macos-research/blob/main/llmcjf/LLMCJF_PostMortem_17DEC2025.md).
