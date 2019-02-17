module demb.bytecompiler;

import demb.ast;
import demb.bytecode;
import demb.opcode;
import demb.object;
import std.format;

ByteCode[] byteCompile(AST ast) {
  ByteCode[] codes = [];

  if (auto integerAST = cast(IntegerAST)ast) {
    codes ~= ByteCode(OpCode.PUSH, [new IntegerObject(integerAST.v)]);
  }
  else if (auto floatAST = cast(FloatAST)ast) {
    codes ~= ByteCode(OpCode.PUSH, [new FloatObject(floatAST.v)]);
  }
  else if (auto stringAST = cast(StringAST)ast) {
    codes ~= ByteCode(OpCode.PUSH, [new StringObject(stringAST.v)]);
  }
  else if (auto addAST = cast(AddAST)ast) {
    assert(addAST.args.length == 2, "bad number of arguments %d for operator +".format(addAST.args.length));
    foreach (arg; addAST.args) {
      codes ~= arg.byteCompile;
    }
    codes ~= ByteCode(OpCode.ADD, []);
  }
  else if (auto subAST = cast(SubAST)ast) {
    assert(subAST.args.length == 2, "bad number of arguments %d for operator -".format(subAST.args.length));
    foreach (arg; subAST.args) {
      codes ~= arg.byteCompile;
    }
    codes ~= ByteCode(OpCode.SUB, []);
  }
  else if (auto mulAST = cast(MulAST)ast) {
    assert(mulAST.args.length == 2, "bad number of arguments %d for operator *".format(mulAST.args.length));
    foreach (arg; mulAST.args) {
      codes ~= arg.byteCompile;
    }
    codes ~= ByteCode(OpCode.MUL, []);
  }
  else if (auto divAST = cast(DivAST)ast) {
    assert(divAST.args.length == 2, "bad number of arguments %d for operator /".format(divAST.args.length));
    foreach (arg; divAST.args) {
      codes ~= arg.byteCompile;
    }
    codes ~= ByteCode(OpCode.DIV, []);
  }
  else if (auto catAST = cast(CatAST)ast) {
    assert(catAST.args.length == 2, "bad number of arguments %d for operator ~".format(catAST.args.length));
    foreach (arg; catAST.args) {
      codes ~= arg.byteCompile;
    }
    codes ~= ByteCode(OpCode.CONCAT, []);
  }
  else if (auto printAST = cast(PrintAST)ast) {
    assert(printAST.args.length == 1, "bad number of arguments %d for print".format(printAST.args.length));
    foreach (arg; printAST.args) {
      codes ~= arg.byteCompile;
    }
    codes ~= ByteCode(OpCode.PRINT, []);
  }
  else if (auto stmtsAST = cast(StmtsAST)ast) {
    foreach (stmt; stmtsAST.stmts) {
      codes ~= stmt.byteCompile;
    }
  }
  else {
    assert(false, "unimplemented AST: %s".format(ast));
  }

  return codes;
}
