module demb.ast;

import std.format;
import demb.exception;
import demb.compilecontext;
import demb.aast;

abstract class AST {
  public:
    abstract AAST analyze(CompileContext ctx);
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
      if (ctx.hasLocalvar(v)) {
        return new IdentifierIDAAST(ctx.getVarId(v));
      }
      throw new DembCompileException("No local variable with name %s".format(v));
    }
}
