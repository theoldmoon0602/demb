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
      return new PrintAST([p.children[0].toAST]);

    case "Demb.AddExpression":
      return new AddAST([p.children[0].toAST, p.children[1].toAST]);

    case "Demb.SubExpression":
      return new SubAST([p.children[0].toAST, p.children[1].toAST]);

    case "Demb.MulExpression":
      return new MulAST([p.children[0].toAST, p.children[1].toAST]);

    case "Demb.DivExpression":
      return new DivAST([p.children[0].toAST, p.children[1].toAST]);

    case "Demb.ConCatExpression":
      return new CatAST([p.children[0].toAST, p.children[1].toAST]);

    case "Demb.Primary":
      return p.children[0].toAST;

    case "Demb.Integer":
      return new IntegerAST(p.matches[0].to!long);
      
    case "Demb.Float":
      return new FloatAST(p.matches[0].to!double);

    case "Demb.String":
      return new StringAST(p.matches[0]);
  }
}
