module demb.ast;

abstract class AST {
}

class PrintAST : AST {
  public:
    AST[] args;
    this(AST[] args) {
      this.args = args;
    }
}

class AddAST : AST {
  public:
    AST[] args;
    this(AST[] args) {
      this.args = args;
    }
}

class NumberAST : AST {
  public:
    long v;
    this(long v) {
      this.v = v;
    }
}
