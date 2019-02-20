module demb.bytecode;

import std.format;
import demb.opcode;
import demb.object;
import demb.exception;

struct ByteCode {
  public:
    OpCode code;
    ubyte[] args;
}



ByteCode bytecode(T...)(OpCode code, T args) {
  ubyte[] f(U)(U x) {
    auto buf = new ubyte[](U.sizeof);
    buf.write!(U)(x, 0);
    return buf;
  }

  ubyte[] argbuf = [];
  foreach (arg; argx) {
    argbuf ~= f(arg);
  }

  return ByteCode(code, argbuf);
}
