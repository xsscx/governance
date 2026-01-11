# Hoyt's PowerShell Prologue Examples for Actions

## Configure Git Environment

```yaml
      - name: Configure Git Environment
        shell: pwsh -NoProfile -NoLogo -NonInteractive -Command {0}
        env:
          POWERSHELL_TELEMETRY_OPTOUT: 1
          POWERSHELL_UPDATECHECK: Off
        run: |
          $ErrorActionPreference = 'Stop'
          $PSDefaultParameterValues['*:ErrorAction'] = 'Stop'
          git config --add safe.directory "$PWD"
          git config --global credential.helper ""
          if (Test-Path env:GITHUB_TOKEN) { Remove-Item env:GITHUB_TOKEN }
```

## Template for ENV:GITHUB_WORKSPACE

```yaml
      - name: Configure Git Environment
        shell: pwsh -NoProfile -NoLogo -NonInteractive -Command {0}
        env:
          POWERSHELL_TELEMETRY_OPTOUT: 1
          POWERSHELL_UPDATECHECK: Off
        run: |
          $ErrorActionPreference = 'Stop'
          $PSDefaultParameterValues['*:ErrorAction'] = 'Stop'
          git config --global --add safe.directory "$env:GITHUB_WORKSPACE"
          git config --global credential.helper ""
          if (Test-Path env:GITHUB_TOKEN) { Remove-Item env:GITHUB_TOKEN }
```

## Standard Build Step Template

```yaml
      - name: Build Project
        shell: pwsh -NoProfile -NoLogo -NonInteractive -Command {0}
        env:
          POWERSHELL_TELEMETRY_OPTOUT: 1
          POWERSHELL_UPDATECHECK: Off
        run: |
          $ErrorActionPreference = 'Stop'
          $PSDefaultParameterValues['*:ErrorAction'] = 'Stop'
          cmake --build build -- /m /maxcpucount
```

## Security Hardening Flags

### Shell Configuration
- **`pwsh`**: Use PowerShell Core (cross-platform, modern)
- **`-NoProfile`**: Prevents profile script execution
- **`-NoLogo`**: Suppresses startup banner (cleaner logs)
- **`-NonInteractive`**: Disables interactive prompts
- **`-Command {0}`**: Executes command string

### Environment Variables
- **`POWERSHELL_TELEMETRY_OPTOUT: 1`**: Disables telemetry
- **`POWERSHELL_UPDATECHECK: Off`**: Disables update checks

### Error Handling
- **`$ErrorActionPreference = 'Stop'`**: Fail fast on errors
- **`$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'`**: Global fail-fast

### Security Controls
- **`Remove-Item env:GITHUB_TOKEN`**: Unset GitHub token after checkout
- **`git config --global credential.helper ""`**: Clear credential helper

## Windows PowerShell (Legacy) Alternative

For environments requiring Windows PowerShell 5.1:

```yaml
      - name: Configure Git Environment
        shell: powershell -NoProfile -NonInteractive -Command {0}
        env:
          POWERSHELL_TELEMETRY_OPTOUT: 1
        run: |
          $ErrorActionPreference = 'Stop'
          $PSDefaultParameterValues['*:ErrorAction'] = 'Stop'
          git config --global --add safe.directory "$env:GITHUB_WORKSPACE"
          git config --global credential.helper ""
          if (Test-Path env:GITHUB_TOKEN) { Remove-Item env:GITHUB_TOKEN }
```

**Note:** Prefer `pwsh` over `powershell` for consistency with cross-platform workflows.

## Complete Example Workflow Step

```yaml
      - name: Checkout code
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
        with:
          fetch-depth: 1
          persist-credentials: false
      
      - name: Configure Git Environment
        shell: pwsh -NoProfile -NoLogo -NonInteractive -Command {0}
        env:
          POWERSHELL_TELEMETRY_OPTOUT: 1
          POWERSHELL_UPDATECHECK: Off
        run: |
          $ErrorActionPreference = 'Stop'
          $PSDefaultParameterValues['*:ErrorAction'] = 'Stop'
          git config --global --add safe.directory "$env:GITHUB_WORKSPACE"
          git config --global credential.helper ""
          if (Test-Path env:GITHUB_TOKEN) { Remove-Item env:GITHUB_TOKEN }
      
      - name: Install Dependencies
        shell: pwsh -NoProfile -NoLogo -NonInteractive -Command {0}
        env:
          POWERSHELL_TELEMETRY_OPTOUT: 1
          POWERSHELL_UPDATECHECK: Off
        run: |
          $ErrorActionPreference = 'Stop'
          $PSDefaultParameterValues['*:ErrorAction'] = 'Stop'
          vcpkg integrate install
          vcpkg install
      
      - name: Build
        shell: pwsh -NoProfile -NoLogo -NonInteractive -Command {0}
        env:
          POWERSHELL_TELEMETRY_OPTOUT: 1
          POWERSHELL_UPDATECHECK: Off
        run: |
          $ErrorActionPreference = 'Stop'
          $PSDefaultParameterValues['*:ErrorAction'] = 'Stop'
          cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
          cmake --build build -- /m /maxcpucount
```

## Input Validation Pattern

```yaml
      - name: Validate User Input
        shell: pwsh -NoProfile -NoLogo -NonInteractive -Command {0}
        env:
          POWERSHELL_TELEMETRY_OPTOUT: 1
          POWERSHELL_UPDATECHECK: Off
          USER_INPUT: ${{ github.event.inputs.build_type }}
        run: |
          $ErrorActionPreference = 'Stop'
          $PSDefaultParameterValues['*:ErrorAction'] = 'Stop'
          
          $BuildType = if ([string]::IsNullOrEmpty($env:USER_INPUT)) { 'Release' } else { $env:USER_INPUT }
          
          $ValidTypes = @('Debug', 'Release', 'RelWithDebInfo', 'MinSizeRel')
          if ($BuildType -notin $ValidTypes) {
            Write-Error "Invalid build type: $BuildType"
            exit 1
          }
          
          echo "VALIDATED_BUILD_TYPE=$BuildType" >> $env:GITHUB_ENV
```

## Path Safety Pattern

```yaml
      - name: Safe Path Operations
        shell: pwsh -NoProfile -NoLogo -NonInteractive -Command {0}
        env:
          POWERSHELL_TELEMETRY_OPTOUT: 1
          POWERSHELL_UPDATECHECK: Off
          USER_PATH: ${{ github.event.inputs.install_path }}
        run: |
          $ErrorActionPreference = 'Stop'
          $PSDefaultParameterValues['*:ErrorAction'] = 'Stop'
          
          # Validate and normalize path
          $InstallPath = if ([string]::IsNullOrEmpty($env:USER_PATH)) { 
            Join-Path $env:GITHUB_WORKSPACE 'install' 
          } else { 
            $env:USER_PATH 
          }
          
          # Prevent path traversal
          $ResolvedPath = [System.IO.Path]::GetFullPath($InstallPath)
          $WorkspacePath = [System.IO.Path]::GetFullPath($env:GITHUB_WORKSPACE)
          
          if (-not $ResolvedPath.StartsWith($WorkspacePath)) {
            Write-Error "Path traversal detected: $ResolvedPath"
            exit 1
          }
          
          New-Item -ItemType Directory -Path $ResolvedPath -Force | Out-Null
          echo "VALIDATED_INSTALL_PATH=$ResolvedPath" >> $env:GITHUB_ENV
```

## Credential Isolation Pattern

```yaml
      - name: Execute Build with Credential Isolation
        shell: pwsh -NoProfile -NoLogo -NonInteractive -Command {0}
        env:
          POWERSHELL_TELEMETRY_OPTOUT: 1
          POWERSHELL_UPDATECHECK: Off
        run: |
          $ErrorActionPreference = 'Stop'
          $PSDefaultParameterValues['*:ErrorAction'] = 'Stop'
          
          # Clear all potential credential sources
          if (Test-Path env:GITHUB_TOKEN) { Remove-Item env:GITHUB_TOKEN }
          if (Test-Path env:GH_TOKEN) { Remove-Item env:GH_TOKEN }
          if (Test-Path env:ACTIONS_RUNTIME_TOKEN) { Remove-Item env:ACTIONS_RUNTIME_TOKEN }
          
          git config --global credential.helper ""
          git config --system --unset credential.helper 2>$null
          
          # Execute build
          cmake --build build
```

## Comparison: Bash vs PowerShell Prologue

| Feature | Bash | PowerShell |
|---------|------|------------|
| Shell flags | `bash --noprofile --norc {0}` | `pwsh -NoProfile -NoLogo -NonInteractive -Command {0}` |
| Environment | `BASH_ENV: /dev/null` | `POWERSHELL_TELEMETRY_OPTOUT: 1` |
| Error handling | `set -euo pipefail` | `$ErrorActionPreference = 'Stop'` |
| Token removal | `unset GITHUB_TOKEN \|\| true` | `if (Test-Path env:GITHUB_TOKEN) { Remove-Item env:GITHUB_TOKEN }` |
| Git safe.directory | `git config --add safe.directory "$PWD"` | `git config --add safe.directory "$env:GITHUB_WORKSPACE"` |

## Summary

**Do not trust the `AI` to do anything securely.**

Reference: [LLMCJF PostMortem 17-DEC-2025](https://github.com/xsscx/macos-research/blob/main/llmcjf/LLMCJF_PostMortem_17DEC2025.md)

### Key Principles
1. **No profiles**: Prevents environment pollution
2. **No interaction**: Blocks hanging on prompts
3. **Fail fast**: Stop on first error
4. **No telemetry**: Privacy and performance
5. **Credential isolation**: Remove tokens after checkout
6. **Input validation**: Never trust user-controlled data
7. **Path safety**: Prevent traversal attacks

### When to Use
- All PowerShell steps in GitHub Actions workflows
- Windows-based CI/CD pipelines
- Cross-platform builds using PowerShell Core
- Security-sensitive build operations

---

**Last Updated:** 2025-12-20  
**Author:** David Hoyt (adapted from Bash standard)  
**License:** Same as parent repository
