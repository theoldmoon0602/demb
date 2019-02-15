module demb.bytecode;

import std.format;
import demb.opcode;
import demb.object;
import demb.exception;

struct ByteCode {
  public:
    OpCode code;
    DembObject[] args;
}

DembObject getArg(ByteCode b, uint n) {
  if (b.args.length <= n) {
    throw new DembRuntimeException("Trying to unexisting number of argument %d".format(n));
  }
  return b.args[n];
}
