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

class SubAST : AST {
  public:
    AST[] args;
    this(AST[] args) {
      this.args = args;
    }
}

class MulAST : AST {
  public:
    AST[] args;
    this(AST[] args) {
      this.args = args;
    }
}

class DivAST : AST {
  public:
    AST[] args;
    this(AST[] args) {
      this.args = args;
    }
}

class CatAST : AST {
  public:
    AST[] args;
    this(AST[] args) {
      this.args = args;
    }
}

class IntegerAST : AST {
  public:
    long v;
    this(long v) {
      this.v = v;
    }
}

class FloatAST : AST {
  public:
    double v;
    this(double v) {
      this.v = v;
    }
}

class StringAST : AST {
  public:
    string v;
    this(string v) {
      this.v = v;
    }
}
