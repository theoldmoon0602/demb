module demb.compileresult;

import demb.func;

struct CompileResult {
  public:
    uint main_offset;
    string[] strs;
    CompiledFunction[] funcs;
}
