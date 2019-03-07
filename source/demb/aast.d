module demb.aast;

import demb.exception;
import demb.opcode;
import std.typecons;
import std.string;
import msgpack;

/**
 * Analyzed-AST
 */
abstract class AAST {
  public:
    abstract ubyte[] compile();
}


class StmtsAAST: AAST {
  public:
    AAST[] stmts;
    this(AAST[] stmts) {
      this.stmts = stmts;
    }
    override ubyte[] compile() {
      ubyte[] codes = [];
      foreach (stmt; stmts) {
        codes ~= stmt.compile;
      }
      return codes;
    }

    override string toString() {
      string[] s = [];
      foreach (stmt; stmts) {
        s ~= stmt.toString.replace("\n", "\n  ");
      }
      return s.join("\n");
    }
}

class AssignAAST: AAST {
  public:
    IdentifierIDAAST ident;
    AAST expr;

    this(IdentifierIDAAST ident, AAST expr) {
      this.ident = ident;
      this.expr = expr;
    }
    override ubyte[] compile() {
      return expr.compile() ~ pack(tuple!(uint, uint)(OpCode.ASSIGN, ident.id));
    }
    override string toString() {
      return ident.toString ~ " = " ~ expr.toString;
    }
}

class ReturnAAST: AAST {
  public:
    AAST expr;

    this(AAST expr) {
      this.expr = expr;
    }
    override ubyte[] compile() {
      return this.expr.compile() ~ pack(tuple!(uint)(OpCode.RETURN));
    }
    override string toString() {
      return "return %s".format(expr.toString);
    }
}

class CallAAST: AAST {
  public:
    IdentifierIDAAST funcid;
    this(IdentifierIDAAST funcid) {
      this.funcid = funcid;
    }
    override ubyte[] compile() {
      return pack(tuple(OpCode.CALL, funcid.id));
    }
    override string toString() {
      return "call(" ~ funcid.toString ~ ")";
    }
}

class PrintAAST: AAST {
  public:
    AAST arg;
    this(AAST arg) {
      this.arg = arg;
    }
    override ubyte[] compile() {
      return arg.compile() ~ pack(tuple!(int)(OpCode.PRINT));
    }
    override string toString() {
      return "print(" ~ arg.toString ~ ")";
    }
}

class BinopAAST(OpCode opcode): AAST {
  public:
    AAST left, right;
    this(AAST left, AAST right) {
      this.left = left;
      this.right = right;
    }
    override ubyte[] compile() {
      return left.compile() ~ right.compile() ~ pack(tuple!(int)(opcode));
    }
    override string toString() {
      return "%s %s %s".format(left.toString, opcode, right.toString);
    }
}

alias BinAddAAST = BinopAAST!(OpCode.ADD);
alias BinSubAAST = BinopAAST!(OpCode.SUB);
alias BinMulAAST = BinopAAST!(OpCode.MUL);
alias BinDivAAST = BinopAAST!(OpCode.DIV);
alias BinCatAAST = BinopAAST!(OpCode.CONCAT);


class LiteralAAST(T, OpCode opcode): AAST {
  public:
    T v;
    this(T v) {
      this.v = v;
    }
    override ubyte[] compile() {
      return pack(tuple(opcode, v));
    }
    override string toString() {
      return "%s".format(v);
    }
}
alias IntegerAAST = LiteralAAST!(long, OpCode.PUSHI);
alias FloatAAST = LiteralAAST!(double, OpCode.PUSHF);

class StringAAST: AAST {
  public:
    uint id;
    this(uint id) {
      this.id = id;
    }
    override ubyte[] compile() {
      return pack(tuple(OpCode.PUSHS, this.id));
    }
    override string toString() {
      return "string(id=%d)".format(this.id);
    }
}

class IdentifierIDAAST: AAST {
  public:
    uint id;
    this(uint id) {
      this.id = id;
    }
    override ubyte[] compile() {
      return pack(tuple(OpCode.LOAD, this.id));
    }
    override string toString() {
      return "name(id=%d)".format(this.id);
    }
}
