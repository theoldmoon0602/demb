module demb.parser;

import pegged.grammar;
import demb.peg;
import demb.ast;
import std.conv;
import std.string;

AST toAST(ParseTree p) {
  final switch (p.name) {
    case "Demb":
    case "Demb.TopLevel":
    case "Demb.Stmt":
    case "Demb.Expression":
    case "Demb.AddSubExpression":
    case "Demb.MulDivExpression":
      return p.children[0].toAST;

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

    case "Demb.Primary":
      return p.children[0].toAST;

    case "Demb.Integer":
      return new IntegerAST(p.matches[0].replace("_", "").to!long);
      
    case "Demb.Float":
      return new FloatAST(p.matches[0].replace("_", "").to!double);
  }
}
