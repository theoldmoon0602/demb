module demb.util;

import demb;
import msgpack;

ubyte[] compileString(string source) {
  auto tree = parse(source);
  auto ast = tree.toAST;
  auto aast = compile(cast(TopLevelAST)ast);
  auto bytecode = aast.pack;

  return bytecode;
}

void runBytecode(T)(VM!T vm, ubyte[] bytecode) {
  auto program = bytecode.unpack!(CompileResult);
  vm.run(program);
}

void registerBuiltinFunctions(T)(VM!T vm) {
  vm.setBuiltins([
      mixin(generate_bin_arith!(IntegerObject, IntegerObject, IntegerObject)("+")),
      mixin(generate_bin_arith!(IntegerObject, IntegerObject, IntegerObject)("-")),
      mixin(generate_bin_arith!(IntegerObject, IntegerObject, IntegerObject)("*")),
      mixin(generate_bin_arith!(IntegerObject, IntegerObject, IntegerObject)("/")),

      mixin(generate_bin_arith!(FloatObject, IntegerObject, FloatObject)("+")),
      mixin(generate_bin_arith!(FloatObject, IntegerObject, FloatObject)("-")),
      mixin(generate_bin_arith!(FloatObject, IntegerObject, FloatObject)("*")),
      mixin(generate_bin_arith!(FloatObject, IntegerObject, FloatObject)("/")),

      mixin(generate_bin_arith!(IntegerObject, FloatObject, FloatObject)("+")),
      mixin(generate_bin_arith!(IntegerObject, FloatObject, FloatObject)("-")),
      mixin(generate_bin_arith!(IntegerObject, FloatObject, FloatObject)("*")),
      mixin(generate_bin_arith!(IntegerObject, FloatObject, FloatObject)("/")),

      mixin(generate_bin_arith!(FloatObject, FloatObject, FloatObject)("+")),
      mixin(generate_bin_arith!(FloatObject, FloatObject, FloatObject)("-")),
      mixin(generate_bin_arith!(FloatObject, FloatObject, FloatObject)("*")),
      mixin(generate_bin_arith!(FloatObject, FloatObject, FloatObject)("/")),

      mixin(generate_bin_arith!(StringObject, StringObject, StringObject)("~")),
  ]);
}
