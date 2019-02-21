module demb.peg;

import pegged.grammar;

mixin(grammar(`
Demb:
  TopLevel < DefunStmt+
  DefunStmt < "func" :(Spacing+) Identifier "(" ")" BlockStmt
  BlockStmt < "{" Stmts "}"
  Stmts < (Stmt :EndStmt)* (Stmt :EndStmt?)?
  Stmt < (PrintStmt / AssignStmt / Expression)
  AssignStmt < Identifier "=" Expression
  PrintStmt < "print" "(" Expression ")"
  Expression < AddSubExpression
  AddSubExpression < AddExpression / SubExpression / MulDivExpression
  AddExpression < AddSubExpression "+" MulDivExpression
  SubExpression < AddSubExpression "-" MulDivExpression
  MulDivExpression < MulExpression / DivExpression / CatExpression
  DivExpression < MulDivExpression "/" CatExpression
  MulExpression < MulDivExpression "*" CatExpression
  CatExpression < ConCatExpression / Primary
  ConCatExpression < CatExpression "~" Primary
  Primary < Float / Integer / String / Identifier / ("(" Expression ")")
  String <~ :doublequote Char* :doublequote
  Char <~ (backslash doublequote / backslash backslash / (!doublequote .))
  Float <~ digit (digit / :"_")* "." digit (digit / :"_")*
  Integer <~ digit (digit / :"_")*
  Identifier <~ identifier

  EndStmt <: ";" / endOfLine / eoi
  Spacing <: (' ' / '\t' )*
`));

alias parse = Demb;
