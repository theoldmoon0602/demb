module demb.peg;

import pegged.grammar;

mixin(grammar(`
Demb:
  TopLevel < (DefunStmt :EndDefun)+ eoi?
  DefunStmt < "func" :(Spacing+) Identifier "(" ")" BlockStmt
  BlockStmt < "{" Stmts "}"
  Stmts < (Stmt :EndStmt)* (Stmt :EndStmt?)?
  Stmt < (PrintStmt / AssignStmt / ReturnStmt)
  ReturnStmt  < "return" Expression
  AssignStmt < Identifier "=" Expression
  PrintStmt < "print" "(" Expression ")"
  Expression < AddSubExpression
  AddSubExpression < AddExpression / SubExpression / MulDivExpression
  AddExpression < AddSubExpression "+" MulDivExpression
  SubExpression < AddSubExpression "-" MulDivExpression
  MulDivExpression < MulExpression / DivExpression / CatExpression
  DivExpression < MulDivExpression "/" CatExpression
  MulExpression < MulDivExpression "*" CatExpression
  CatExpression < ConCatExpression / CallLevelExpression
  ConCatExpression < CatExpression "~" CallLevelExpression
  CallLevelExpression < CallExpression / Primary
  CallExpression < Identifier "(" ")"
  Primary < Float / Integer / String / Identifier / ("(" Expression ")")
  String <~ :doublequote Char* :doublequote
  Char <~ (backslash doublequote / backslash backslash / (!doublequote .))
  Float <~ digit (digit / :"_")* "." digit (digit / :"_")*
  Integer <~ digit (digit / :"_")*
  Identifier <~ identifier

  EndDefun < ";" / endOfLine / eoi
  EndStmt < ";" / endOfLine
  Spacing <: (' ' / '\t' )*
`));

alias parse = Demb;
