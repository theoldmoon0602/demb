module demb.peg;

import pegged.grammar;

mixin(grammar(`
Demb:
  TopLevel < Expression / Stmt
  Stmt < PrintStmt
  PrintStmt < "print" "(" Expression ")"
  Expression < AddSubExpression
  AddSubExpression < AddExpression / SubExpression / MulDivExpression
  AddExpression < AddSubExpression "+" MulDivExpression
  SubExpression < AddSubExpression "-" MulDivExpression
  MulDivExpression < MulExpression / DivExpression / Primary
  DivExpression < MulDivExpression "/" Primary
  MulExpression < MulDivExpression "*" Primary
  Primary < Float / Integer / ("(" Expression ")")
  Float <~ digit (digit / "_")* "." digit (digit / "_")*
  Integer <~ digit (digit / "_")*
`));
