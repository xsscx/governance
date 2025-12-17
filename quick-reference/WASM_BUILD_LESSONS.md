# WASM Build Quick Reference

**Created**: 2026-02-03  
**Result**: 100% success (16/16 tools)

## Critical Fixes

### 1. Emscripten IS Unix → Exclude from Unix-Only Code
```cmake
# [OK] CORRECT
if(UNIX AND NOT EMSCRIPTEN)
  target_include_directories(${TARGET} PRIVATE /usr/include)
endif()
```

### 2. No Hardening Flags for WASM
```cmake
# [OK] CORRECT
if(NOT EMSCRIPTEN)
  add_compile_options(-fPIE -fstack-protector-strong)
  add_compile_definitions(_FORTIFY_SOURCE=2)
endif()
```

### 3. WASM Testing = Async Factory API
```javascript
// [OK] CORRECT
const createModule = require('./tool.js');
createModule().then(m => console.log('Loaded'));
```

## Before Claiming WASM Success

1. Check logs: `grep "Built target" build.log | wc -l`
2. Count tools: `find Build-WASM/Tools -name "*.wasm" | wc -l`
3. Test properly: Use async factory API from README
4. Report with evidence: Paste counts and sample output

## Expected: 16 tools (15 + iccAnalyzer-lite)

**Full docs**: `WASM_BUILD_100_PERCENT_SUCCESS.md`
