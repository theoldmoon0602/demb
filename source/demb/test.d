module demb.test;

import demb;
import core.exception;
import std.exception;


unittest {
  dembAssert(`func main() { print(10); }`, "10\n");
  dembAssert(`func hoge() { return 10; }; func main() { print(hoge() + 1); }`, "11\n"); 

}

void dembAssert(string src, string expected, string file = __FILE__, size_t line = __LINE__) {
  import std.outbuffer;
  import std.format;

  auto buf = new OutBuffer();
  auto vm = newVM(buf);
  vm.registerBuiltinFunctions();

  ubyte[] bytecode;
  try {
    bytecode = assertNotThrown!DembCompileException(compileString(src));
  }
  catch (DembCompileException e) {
    throw new AssertError("dembAssert failed: %s".format(e.msg), file, line);
  }

  try {
    vm.runBytecode(bytecode);
  }
  catch (DembRuntimeException e) {
    throw new AssertError("dembAssert failed: %s".format(e.msg), file, line);
  }

  auto result = buf.toString();
  if (result != expected) {
    throw new AssertError("dembAssert failed: \"%s\" is expected but got \"%s\"".format(expected, result), file, line);
  }
}
