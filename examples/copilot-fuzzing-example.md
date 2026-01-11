## Fuzzing Prologue for Copilot | Unix

```
mkdir copilot
cd copilot
git clone %REPO%
cd %REPO%
git clone https://github.com/xsscx/Commodity-Injection-Signatures.git
rm -rf Commodity-Injection-Signatures/meta
rm -rf Commodity-Injection-Signatures/rbl
rm -rf Commodity-Injection-Signatures/parameter
git clone https://github.com/xsscx/llmcjf.git
copilot
```

## Session Prologue Prompt

This is the first prompt for the session:

```
Please only make local Commits and DO NOT PUSH. 
Add CWD and all SubDirectories to the Allowed Directories List. 
Consume all files in llmcjf/**/* and update the control surfaces. 
Please indicate when to continue this Fuzzing Session using Commodity-Injection-Signatures
```

## Expected Response

```
...
 ● I've consumed all files in llmcjf/**/*. The content documents anti-LLM Content Jockey (LLMCJF) framework aimed at preventing verbose, scope-creeping, and non-deterministic responses from LLMs.

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
