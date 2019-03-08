module demb.ast;

import std.format;
import demb.exception;
import demb.compilecontext;
import demb.aast;

abstract class AST {
  public:
    abstract AAST analyze(CompileContext ctx);
}

class TopLevelAST: AST {
  public:
    DefunAST[] defuns;

    this(DefunAST[] defuns) {
      this.defuns = defuns;
    }
    override AAST analyze(CompileContext ctx) {
      throw new DembCompileException("Unexpected Call");
    }
}

class DefunAST: AST {
  public:
    IdentifierAST name;
    DummyArgsAST args;
    StmtsAST proc;

    this(IdentifierAST name, DummyArgsAST args, StmtsAST proc) {
      this.name = name;
      this.args = args;
      this.proc = proc;
    }

    override AAST analyze(CompileContext ctx) {
      ctx.addGlobal(name.v);
      foreach (arg; args.dummy_args) {
        if (ctx.hasVar(arg.v)) {
          throw new DembCompileException("Argument name %s is already defiend".format(arg.v));
        }
        ctx.addVar(arg.v);
      }
      return proc.analyze(ctx);
    }
}

class DummyArgsAST: AST {
  public:
    IdentifierAST[] dummy_args;

    this(IdentifierAST[] dummy_args) {
      this.dummy_args = dummy_args;
    }

    override AAST analyze(CompileContext ctx) {
      throw new DembCompileException("Unexpected Call");
    }
}

class StmtsAST : AST {
  public:
    AST[] stmts;
    this(AST[] stmts) {
      this.stmts = stmts;
    }
    override AAST analyze(CompileContext ctx) {
      AAST[] a_stmts = [];
      foreach (ast; stmts) {
        a_stmts ~= ast.analyze(ctx);
      }
      return new StmtsAAST(a_stmts);
    }
}

class ReturnAST: AST {
  public:
    AST expr;
    this(AST expr) {
      this.expr = expr;
    }

    override AAST analyze(CompileContext ctx) {
      return new ReturnAAST(this.expr.analyze(ctx));
    }
}

class AssignAST: AST {
  public:
    IdentifierAST ident;
    AST expr;
    this(IdentifierAST ident, AST expr) {
      this.ident = ident;
      this.expr = expr;
    }
    override AAST analyze(CompileContext ctx) {
      if (!ctx.hasVar(ident.v)) {
        ctx.addVar(ident.v);
      }

      auto y = expr.analyze(ctx);  // analyze expr before analyzing identifier (for name resolution)
      auto x = ident.analyze(ctx);
      return new AssignAAST(cast(IdentifierIDAAST)x, y);      
    }
}

class CallAST: AST{ 
  public:
    IdentifierAST name;
    CallArgsAST args;
    this(IdentifierAST name, CallArgsAST args) {
      this.name = name;
      this.args = args;
    }
    override AAST analyze(CompileContext ctx) {
      if (!ctx.hasGlobal(name.v)) {
        throw new DembCompileException("No such function %s".format(name.v));
      }
      AAST[] args_aast = [];
      foreach (arg; this.args.args) {
        args_aast ~= arg.analyze(ctx);
      }
      return new CallAAST(new IdentifierIDAAST(ctx.getGlobalId(name.v)), args_aast);
    }
}

class CallArgsAST: AST {
  public:
    AST[] args;
    this(AST[] args) {
      this.args = args;
    }

    override AAST analyze(CompileContext ctx) {
      throw new DembCompileException("Unexpected Call");
    }
}

class PrintAST : AST {
  public:
    AST arg;
    this(AST arg) {
      this.arg = arg;
    }
    override AAST analyze(CompileContext ctx) {
      return new PrintAAST(arg.analyze(ctx));
    }
}

class BinopAST(T) : AST {
  public:
    AST left, right;
    this(AST left, AST right) {
      this.left = left;
      this.right = right;
    }
    override AAST analyze(CompileContext ctx) {
      auto l = left.analyze(ctx);
      auto r = right.analyze(ctx);

      return new T(l, r);
    }
}

alias BinAddAST = BinopAST!BinAddAAST;
alias BinSubAST = BinopAST!BinSubAAST;
alias BinMulAST = BinopAST!BinMulAAST;
alias BinDivAST = BinopAST!BinDivAAST;
alias BinCatAST = BinopAST!BinCatAAST;

class LiteralAST(T, U): AST {
  public:
    T v;
    this(T v) {
      this.v = v;
    }
    override AAST analyze(CompileContext ctx) {
      return new U(this.v);
    }
}
alias IntegerAST = LiteralAST!(long, IntegerAAST);
alias FloatAST = LiteralAST!(double, FloatAAST);

class StringAST: AST {
  public:
    string v;
    this(string v) {
      this.v = v;
    }
    override AAST analyze(CompileContext ctx) {
      auto id = ctx.addString(v);
      return new StringAAST(id);
    }
}

class IdentifierAST : AST {
  public:
    string v;
    this(string v) {
      this.v = v;
    }
    override AAST analyze(CompileContext ctx) {
      if (ctx.hasVar(v)) {
        return new IdentifierIDAAST(ctx.getVarId(v));
      }
      throw new DembCompileException("No local variable with name %s".format(v));
    }
}
