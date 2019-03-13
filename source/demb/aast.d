module demb.aast;

import demb.exception;
import demb.opcode;
import std.typecons;
import std.algorithm;
import std.array;
import std.string;
import msgpack;

/**
 * Analyzed-AST
 */
abstract class AAST {
  public:
    abstract ubyte[] compile();
}


class IfAAST: AAST {
  public:
    AAST[] exprs;
    StmtsAAST[] blocks;
    StmtsAAST else_block;

    this(AAST[] exprs, StmtsAAST[] blocks, StmtsAAST else_block) {
      assert(exprs.length == blocks.length);
      this.exprs = exprs;
      this.blocks = blocks;
      this.else_block = else_block;
    }

    override ubyte[] compile() {
      /*
         COND
         JIF IF-A
         COND
         JIF IF-B
         JMP ELSE
         IF-A...
         JMP ELSE
         IF-B...
         JMP ELSE
         [ELSE...]
      */
      uint[] jump_at = [];
      uint[] block_at = [];
      uint jumpto = 0;
      ubyte[] code = [];

      // prebuild
      foreach (expr; exprs) {
        code ~= expr.compile();
        jump_at ~= cast(uint)(StreamingUnpacker(code).array.length);
        code ~= pack(tuple!(uint, uint)(OpCode.JIF, 0));
      }
      code ~= pack(tuple!(uint, uint)(OpCode.JUMP, 0));

      foreach (i, block; blocks) {
        block_at ~= cast(uint)(StreamingUnpacker(code).array.length);
        code ~= block.compile() ~ pack(tuple!(uint, uint)(OpCode.JUMP, 0));
      }
      jumpto = cast(uint)(StreamingUnpacker(code).array.length);

      code.length = 0;

      // mainbuild
      foreach (i, expr; exprs) {
        code ~= expr.compile() ~ pack(tuple!(uint, uint)(OpCode.JIF, cast(uint)(block_at[i] - jump_at[i])));
      }
      code ~= pack(tuple!(uint, uint)(OpCode.JUMP, jumpto - jump_at[$-1] - 1));

      foreach (i, block; blocks) {
        code ~= block.compile() ~ pack(tuple!(uint, uint)(OpCode.JUMP, jumpto - block_at[i]));
      }
      if (else_block) {
        code ~= else_block.compile();
      }
      return code;
    }

    override string toString() {
      string[] s = [];
      foreach (i; 0..exprs.length) {
        if (i == 0) {
          s ~= "if (%s) { %s }".format(exprs[i], blocks[i]);
        }
        else {
          s ~= "else if (%s) { %s }".format(exprs[i], blocks[i]);
        }
      }
      if (else_block) {
        s ~= "else { %s }".format(else_block);
      }
      return s.join("\n");
    }
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
    AAST[] args;
    this(IdentifierIDAAST funcid, AAST[] args) {
      this.funcid = funcid;
      this.args = args;
    }
    override ubyte[] compile() {
      return reduce!((a, b) => a ~ b.compile)(cast(ubyte[])[], this.args) ~ pack(tuple!(uint, uint, uint)(OpCode.CALL, funcid.id, cast(uint)this.args.length));
    }
    override string toString() {
      return "call(%s, %s)".format(funcid, args);
    }
}

class PrintAAST: AAST {
  public:
    AAST arg;
    this(AAST arg) {
      this.arg = arg;
    }
    override ubyte[] compile() {
      return arg.compile() ~ pack(tuple!(uint)(OpCode.PRINT));
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
      return left.compile() ~ right.compile() ~ pack(tuple!(uint)(opcode));
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

class CmpAAST: AAST {
  public:
    static OpCode[string] opcodes;
    static this() {
      this.opcodes = [
        "==": OpCode.EQ,
        "!=": OpCode.NEQ,
        "<": OpCode.LT,
        "<=": OpCode.LE,
        ">": OpCode.GT,
        ">=": OpCode.GE,
      ];
    }
    AAST left, right;
    string op;
    this(AAST left, AAST right, string op) {
      assert(op in opcodes);
      this.left = left;
      this.right = right;
      this.op = op;
    }
    override ubyte[] compile() {
      return left.compile() ~ right.compile() ~ pack(tuple!(uint)(opcodes[op]));
    }
    override string toString() {
      return "%s %s %s".format(left.toString, op, right.toString);
    }
}


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
