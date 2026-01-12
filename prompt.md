## LLMCJF Prologue for Copilot | Unix

Hoyt's Copilot Governance Framework

```
mkdir copilot
cd copilot
git clone %REPO%
cd %dir%
git clone https://github.com/xsscx/Commodity-Injection-Signatures.git
rm -rf Commodity-Injection-Signatures/meta
rm -rf Commodity-Injection-Signatures/rbl
rm -rf Commodity-Injection-Signatures/parameter
git clone https://github.com/xsscx/governance.git
copilot
```

## Example Session Prompt

```
Please only make local Commits and DO NOT PUSH. 
Add CWD and all SubDirectories to the Allowed Directories List. 
Consume all subdirectories and files in llmcjf/ and docs/ the update all control surfaces. 
The local HOST is a W5-2465X, 32-core, please use all cores for maximum performance.
There is a RAID-1 2Tb Samsung 990 PRO SSD 2TB NVMe M.2 PCIe Gen4, M.2 2280 Internal Solid State Drives for maximum performance.
The LibFuzzer & CFL Campaign PoC are in poc-archive/
Please indicate when to continue. 
```

## Expected Response

```
...
 ● I've consumed all Governance Documents. The content governance framework seeks to reduce & prevent the verbose, scope-creeping, and non-deterministic responses from LLMs.

   Key Control Surfaces Identified:

     - Behavioral Constraints: Minimal verbosity, no narrative, diff-only patches, strict engineering mode
     - Violation Patterns: Content jockey fingerprints, semantic drift, false narratives, spec non-compliance
     - Enforcement Rules: Require patches for code changes, block unrequested modifications, verify context integrity
     - Session Profiles: strict-engineering mode with reasoning suppressed, direct responses only

   Control surfaces updated for this session:

     - ✅ CWD and subdirectories accessible
     - ✅ Local commits only (no push)
     - ✅ Minimal diff-only changes
     - ✅ No narrative/filler
     - ✅ Direct technical responses
     - ✅ Strict adherence to user specifications

   Ready to continue.
```
