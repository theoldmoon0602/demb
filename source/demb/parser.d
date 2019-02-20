module demb.parser;

import pegged.grammar;
import demb.peg;
import demb.ast;
import std.algorithm;
import std.array;
import std.conv;

AST toAST(ParseTree p) {
  final switch (p.name) {
    case "Demb":
    case "Demb.TopLevel":
    case "Demb.Stmt":
    case "Demb.Expression":
    case "Demb.AddSubExpression":
    case "Demb.MulDivExpression":
    case "Demb.CatExpression":
      return p.children[0].toAST;

    case "Demb.Stmts":
      return new StmtsAST(p.children.map!(x => x.toAST).array);

    case "Demb.PrintStmt":
      return new PrintAST(p.children[0].toAST);

    case "Demb.AssignStmt":
      return new AssignAST(cast(IdentifierAST)(p.children[0].toAST), p.children[1].toAST);

    case "Demb.AddExpression":
      return new BinAddAST(p.children[0].toAST, p.children[1].toAST);

    case "Demb.SubExpression":
      return new BinSubAST(p.children[0].toAST, p.children[1].toAST);

    case "Demb.MulExpression":
      return new BinMulAST(p.children[0].toAST, p.children[1].toAST);

    case "Demb.DivExpression":
      return new BinDivAST(p.children[0].toAST, p.children[1].toAST);

    case "Demb.ConCatExpression":
      return new BinCatAST(p.children[0].toAST, p.children[1].toAST);

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
  }
}
