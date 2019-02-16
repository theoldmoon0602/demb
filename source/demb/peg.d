module demb.peg;

import pegged.grammar;

mixin(grammar(`
Demb:
  TopLevel < (Expression / Stmt)
  Stmt < PrintStmt
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
  Primary < Float / Integer / String / ("(" Expression ")")
  String <~ :doublequote Char* :doublequote
  Char <~ (backslash doublequote / backslash backslash / (!doublequote .))
  Float <~ digit (digit / :"_")* "." digit (digit / :"_")*
  Integer <~ digit (digit / :"_")*
`));
