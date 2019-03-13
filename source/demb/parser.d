module demb.parser;

import pegged.grammar;
import demb.peg;
import demb.ast;
import demb.exception;
import std.algorithm;
import std.array;
import std.conv;
import std.format;

AST toAST(ParseTree p) {
  switch (p.name) {
    case "Demb":
    case "Demb.Stmt":
    case "Demb.BlockStmt":
    case "Demb.Expression":
    case "Demb.EqualityExpression":
    case "Demb.CompareExpression":
    case "Demb.AddSubExpression":
    case "Demb.MulDivExpression":
    case "Demb.CallLevelExpression":
    case "Demb.CatExpression":
    case "Demb.Else":
      return p.children[0].toAST;

    case "Demb.TopLevel":
      return new TopLevelAST(p.children.map!(x => cast(DefunAST)x.toAST).array);

    case "Demb.IfStmt":
      AST[] exprs;
      StmtsAST[] blocks;
      StmtsAST else_block = null;
      
      foreach (i, p2; p.children) {
        if (p2.name == "Demb.Else") {
          else_block = cast(StmtsAST)(p2.toAST);
        }
        else if (i % 2 == 0) {
          exprs ~= p2.toAST;
        }
        else {
          blocks ~= cast(StmtsAST)(p2.toAST);
        }
      }
      return new IfAST(exprs, blocks, else_block);

    case "Demb.DefunStmt":
      return new DefunAST(
          cast(IdentifierAST)p.children[0].toAST, // func name
          cast(DummyArgsAST)p.children[1].toAST,  // dummy args
          cast(StmtsAST)p.children[2].toAST);     // body

    case "Demb.DummyArgs":
      return new DummyArgsAST(p.children.map!(x => cast(IdentifierAST)(x.toAST)).array);

    case "Demb.Stmts":
      return new StmtsAST(p.children.map!(x => x.toAST).array);

    case "Demb.PrintStmt":
      return new PrintAST(p.children[0].toAST);

    case "Demb.AssignStmt":
      return new AssignAST(cast(IdentifierAST)(p.children[0].toAST), p.children[1].toAST);

    case "Demb.ReturnStmt":
      return new ReturnAST(p.children[0].toAST);

    case "Demb.EqualExpression":
    case "Demb.NotEqualExpression":
    case "Demb.LessThanExpression":
    case "Demb.LessThanEqualExpression":
    case "Demb.MoreThanExpression":
    case "Demb.MoreThanEqualExpression":
    case "Demb.AddExpression":
    case "Demb.SubExpression":
    case "Demb.MulExpression":
    case "Demb.DivExpression":
    case "Demb.ConCatExpression":
      return new BinopAST(p.children[0].toAST, p.children[2].toAST, p.children[1].matches[0]);

    case "Demb.CallExpression":
      return new CallAST(
          cast(IdentifierAST)p.children[0].toAST,
          cast(CallArgsAST)p.children[1].toAST);

    case "Demb.CallArgs":
      return new CallArgsAST(p.children.map!(toAST).array);

    case "Demb.Primary":
      return p.children[0].toAST;

    case "Demb.Integer":
      return new IntegerAST(p.matches[0].to!long);

    case "Demb.Float":
      return new FloatAST(p.matches[0].to!double);

    case "Demb.String":
      return new StringAST(p.matches[0]);

    case "Demb.Identifier":
      return new IdentifierAST(p.matches[0]);

    default:
      auto pos = p.position;
      throw new DembCompileException("unexpected character %s at (%d,%d)".format((pos.index < p.input.length) ? p.input[pos.index..pos.index+1]: "EOF", pos.line, pos.col));
  }
}
