module demb.bytecompiler;

import demb.ast;
import demb.bytecode;
import demb.opcode;
import demb.object;

ByteCode[] byteCompile(AST ast) {
  ByteCode[] codes = [];

  if (auto numberAST = cast(NumberAST)ast) {
    codes ~= ByteCode(OpCode.PUSH, [new NumberObject(numberAST.v)]);
  }
  else if (auto addAST = cast(AddAST)ast) {
    assert(addAST.args.length == 2, "bad number of arguments for operator +");
    foreach (arg; addAST.args) {
      codes ~= arg.byteCompile;
    }
    codes ~= ByteCode(OpCode.ADD, []);
  }
  else if (auto printAST = cast(PrintAST)ast) {
    assert(printAST.args.length == 1, "bad number of arguments for print");
    foreach (arg; printAST.args) {
      codes ~= arg.byteCompile;
    }
    codes ~= ByteCode(OpCode.PRINT, []);
  }

  return codes;
}
