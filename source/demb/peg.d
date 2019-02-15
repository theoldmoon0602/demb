module demb.peg;

import pegged.grammar;

mixin(grammar(`
Demb:
  TopLevel < Expression / Stmt
  Stmt < PrintStmt
  PrintStmt < "print" "(" Expression ")"
  Expression < AddExpression / Primary
  AddExpression < Expression "+" Expression
  Primary < Number
  Number < digit (digit / "_")*
`));
