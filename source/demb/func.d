module demb.func;

import demb.aast;
import demb.opcode;

struct CompiledFunction {
  public:
    uint local_count;
    ubyte[] proc;
}

struct Function {
  public:
    uint local_count;
    AAST proc;
}
