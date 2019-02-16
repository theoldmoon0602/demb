module demb.bytecompiler;

import demb.ast;
import demb.bytecode;
import demb.opcode;
import demb.object;
import std.format;

ByteCode[] byteCompile(AST ast) {
  ByteCode[] codes = [];

  if (auto numberAST = cast(IntegerAST)ast) {
    codes ~= ByteCode(OpCode.PUSH, [new IntegerObject(numberAST.v)]);
  }
  else if (auto addAST = cast(AddAST)ast) {
    assert(addAST.args.length == 2, "bad number of arguments for operator +");
    foreach (arg; addAST.args) {
      codes ~= arg.byteCompile;
    }
    codes ~= ByteCode(OpCode.ADD, []);
  }
  else if (auto subAST = cast(SubAST)ast) {
    assert(subAST.args.length == 2, "bad number of arguments for operator -");
    foreach (arg; subAST.args) {
      codes ~= arg.byteCompile;
    }
    codes ~= ByteCode(OpCode.SUB, []);
  }
  else if (auto mulAST = cast(MulAST)ast) {
    assert(mulAST.args.length == 2, "bad number of arguments for operator *");
    foreach (arg; mulAST.args) {
      codes ~= arg.byteCompile;
    }
    codes ~= ByteCode(OpCode.MUL, []);
  }
  else if (auto divAST = cast(DivAST)ast) {
    assert(divAST.args.length == 2, "bad number of arguments for operator /");
    foreach (arg; divAST.args) {
      codes ~= arg.byteCompile;
    }
    codes ~= ByteCode(OpCode.DIV, []);
  }
  else if (auto printAST = cast(PrintAST)ast) {
    assert(printAST.args.length == 1, "bad number of arguments for print");
    foreach (arg; printAST.args) {
      codes ~= arg.byteCompile;
    }
    codes ~= ByteCode(OpCode.PRINT, []);
  }
  else {
    assert(false, "unimplemented AST: %s".format(ast));
  }

  return codes;
}
