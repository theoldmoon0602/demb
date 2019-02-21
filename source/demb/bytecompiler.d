module demb.bytecompiler;

import demb.aast;
import demb.ast;
import demb.func;
import demb.compilecontext;
import demb.compileresult;
import std.algorithm;
import std.typecons;
import msgpack;

CompileResult compile(TopLevelAST ast) {
  auto ctx = new CompileContext();
  AAST[uint] func_with_id;
  uint[uint] local_count_with_id;
  uint main_id;

  foreach (defun; ast.defuns) {
    ctx.newContext(defun.name.v);

    auto defun_aast = defun.analyze(ctx); 
    auto id = ctx.getGlobalId(defun.name.v);
    assert(cast(bool)(id !in func_with_id),  "function id collision");
    func_with_id[id] = defun_aast;
    local_count_with_id[id] = cast(uint)ctx.local_count;
    if (defun.name.v == "main") {
      main_id = id;
    }
  }
  
  uint main_offset;
  CompiledFunction[] funcs = [];
  foreach (k; func_with_id.keys.sort) {
    if (k == main_id) {
      main_offset = cast(uint)funcs.length;
    }
    funcs ~= CompiledFunction(local_count_with_id[k], func_with_id[k].bytecompile);
  }
  string[] strs = ctx.stringPool;

  return CompileResult(main_offset, strs, funcs);
}



AAST analyze(AST ast, CompileContext ctx) {
  return ast.analyze(ctx);
}

ubyte[] bytecompile(AAST ast) {
  return ast.compile();
}
