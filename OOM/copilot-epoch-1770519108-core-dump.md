## OOM Error Example

Workaround: export NODE_OPTIONS="--max-old-space-size=8192"

```
<--- Last few GCs --->

[200426:0x13dd7000]  2069815 ms: Scavenge 273.5 (333.2) -> 262.4 (333.2) MB, pooled: 11 MB, 8.74 / 5.54 ms  (average mu = 0.985, current mu = 0.975) task;
[200426:0x13dd7000]  2070640 ms: Mark-Compact (reduce) 401.6 (462.2) -> 381.2 (387.9) MB, pooled: 0 MB, 81.10 / 1.50 ms  (+ 0.0 ms in 2 steps since start of marking, biggest step 0.0 ms, walltime since start of marking 183 ms) (average mu = 0.977, current
FATAL ERROR: Reached heap limit Allocation failed - JavaScript heap out of memory
----- Native stack trace -----

 1: 0x72be1c node::OOMErrorHandler(char const*, v8::OOMDetails const&) [copilot]
 2: 0xb9dc10  [copilot]
 3: 0xb9dcff  [copilot]
 4: 0xe367e5  [copilot]
 5: 0xe4796c  [copilot]
 6: 0xe4837c  [copilot]
 7: 0x10849da  [copilot]
 8: 0x10852bc  [copilot]
 9: 0xe0aafa  [copilot]
10: 0xbbede7 v8::ArrayBuffer::New(v8::Isolate*, unsigned long, v8::BackingStoreInitializationMode) [copilot]
11: 0x80341f node::AliasedBufferBase<double, v8::Float64Array>::AliasedBufferBase(v8::Isolate*, unsigned long, unsigned long const*) [copilot]
12: 0x89406d node::fs::GetReqWrap(v8::FunctionCallbackInfo<v8::Value> const&, int, bool) [copilot]
13: 0x8b8edb  [copilot]
14: 0x194b1be  [copilot]
Aborted (core dumped)
```
