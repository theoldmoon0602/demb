module demb.peg;

import pegged.grammar;

mixin(grammar(`
Demb:
  TopLevel < Expression / Stmt
  Stmt < PrintStmt
  PrintStmt < "print" "(" Expression ")"
  Expression < AddSubExpression
  AddSubExpression < AddExpression / SubExpression / MulDivExpression
  AddExpression < MulDivExpression "+" AddSubExpression
  SubExpression < MulDivExpression "-" AddSubExpression
  MulDivExpression < MulExpression / DivExpression / Primary
  DivExpression < Primary "/" MulDivExpression
  MulExpression < Primary "*" MulDivExpression
  Primary < Number / ("(" Expression ")")
  Number < digit (digit / "_")*
`));
