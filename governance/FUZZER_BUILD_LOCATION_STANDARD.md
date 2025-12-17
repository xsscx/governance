# Fuzzer Build Location Standard
**Date Established:** 2026-02-03  
**Governance Rule:** G-FUZZER-BUILD-001

## Standard Build Location

**Current (2026-02-03+):**
```
Output directory: fuzzers-local/combined/
Build script:     build-fuzzers-local.sh
Sanitizers:       -fsanitize=address,undefined,fuzzer-no-link
```

## Rationale

**Previous architecture (deprecated):**
- Separate builds for address/ and undefined/ sanitizers
- Total disk usage: 2.7G for duplicate fuzzer binaries
- Build time: 2x (redundant library compilation)

**Current architecture:**
- Single build with combined sanitizers
- Total disk usage: ~400MB (after all 17 fuzzers built)
- Build time: 50% faster (single library build)
- Detection capability: Identical (both sanitizers active)

## Build Script Behavior

The `build-fuzzers-local.sh` script:
1. Builds to `fuzzers-local/combined/` (hardcoded line 16)
2. Automatically cleans old binaries before build (line 52)
3. Preserves seed corpus directories (critical for fuzzing progress)
4. Builds libraries once, links 17 fuzzers

## Directory Structure

```
fuzzers-local/
├── combined/              ← ACTIVE BUILD LOCATION
│   ├── icc_*_fuzzer      (binaries, rebuilt as needed)
│   └── *_seed_corpus/    (preserved between builds)
├── address/              ← DEPRECATED (binaries removed 2026-02-03)
│   └── *_seed_corpus/    (preserved, may contain unique findings)
└── undefined/            ← DEPRECATED (binaries removed 2026-02-03)
    └── *_seed_corpus/    (preserved, may contain unique findings)
```

## Seed Corpus Management

**Critical:** Seed corpus directories contain fuzzing progress and must NEVER be deleted.

Current locations:
- `fuzzers-local/combined/*_seed_corpus/` - Active corpus for new builds
- `fuzzers-local/address/*_seed_corpus/` - Historical corpus (34 dirs, 1.3G)
- `fuzzers-local/undefined/*_seed_corpus/` - Historical corpus (34 dirs, 856M)

Corpus directories may be merged/deduplicated in future, but currently preserved as-is.

## Build Verification

After running `build-fuzzers-local.sh`:
1. All binaries should be in `fuzzers-local/combined/`
2. No fuzzer binaries should exist in `address/` or `undefined/`
3. Seed corpus directories preserved in all locations
4. Test with: `ls -lh fuzzers-local/combined/icc_*_fuzzer`

## Cleanup Protocol

To remove obsolete binaries from deprecated locations:
```bash
cd fuzzers-local
rm -f address/icc_*_fuzzer undefined/icc_*_fuzzer
```

**DO NOT remove seed corpus directories** - they contain valuable fuzzing data.

## Integration with Library Updates

When updating library from source-of-truth/:
1. Run library sync (see LIBRARY_UPDATE_PROTOCOL.md)
2. Run `./build-fuzzers-local.sh` to rebuild fuzzers
3. Verify output in `fuzzers-local/combined/`
4. Test sample fuzzer execution

## References

- Build script: `build-fuzzers-local.sh`
- Cleanup report: `FUZZER_ARTIFACT_CLEANUP_2026-02-03.md`
- Library update: `LIBRARY_UPDATE_PROTOCOL.md`

## Change History

- **2026-02-03:** Established single-location standard, cleaned deprecated builds
- **2026-01-30:** Simplified from dual-build to combined sanitizers
