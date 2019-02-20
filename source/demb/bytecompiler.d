module demb.bytecompiler;

import demb.aast;
import demb.ast;
import demb.compilecontext;

AAST analyze(AST ast, CompileContext ctx) {

  return ast.analyze(ctx);
}

ubyte[] bytecompile(AAST ast) {
  return ast.compile();
}

