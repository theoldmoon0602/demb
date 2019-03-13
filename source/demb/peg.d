module demb.peg;

import pegged.grammar;

mixin(grammar(`
Demb:
  TopLevel < (DefunStmt :EndDefun)+ eoi?
  DefunStmt < "func" :(Spacing+) Identifier DummyArgs BlockStmt
  DummyArgs < "(" (Identifier ",")* Identifier? ")"
  BlockStmt < "{" Stmts "}"
  Stmts < (Stmt :EndStmt)* (Stmt :EndStmt?)?
  Stmt < (PrintStmt / AssignStmt / ReturnStmt / IfStmt )
  ReturnStmt  < "return" Expression
  AssignStmt < Identifier "=" Expression
  PrintStmt < "print" "(" Expression ")"
  IfStmt < "if" "(" Expression ")" BlockStmt ("else" "if" "(" Expression ")" BlockStmt)*  Else?
  Else < ("else" BlockStmt)
  Expression < EqualityExpression
  EqualityExpression < EqualExpression / NotEqualExpression / CompareExpression
  EqualExpression < EqualityExpression "==" CompareExpression
  NotEqualExpression < EqualityExpression "!=" CompareExpression
  CompareExpression < LessThanExpression / LessThanEqualExpression / MoreThanExpression / MoreThanEqualExpression / AddSubExpression
  LessThanExpression < CompareExpression "<" AddSubExpression
  LessThanEqualExpression < CompareExpression "<=" AddSubExpression
  MoreThanExpression < CompareExpression ">" AddSubExpression
  MoreThanEqualExpression < CompareExpression ">=" AddSubExpression
  AddSubExpression < AddExpression / SubExpression / MulDivExpression
  AddExpression < AddSubExpression "+" MulDivExpression
  SubExpression < AddSubExpression "-" MulDivExpression
  MulDivExpression < MulExpression / DivExpression / CatExpression
  DivExpression < MulDivExpression "/" CatExpression
  MulExpression < MulDivExpression "*" CatExpression
  CatExpression < ConCatExpression / CallLevelExpression
  ConCatExpression < CatExpression "~" CallLevelExpression
  CallLevelExpression < CallExpression / Primary
  CallExpression < Identifier CallArgs 
  CallArgs < "(" (Expression ",")* Expression? ")"
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
