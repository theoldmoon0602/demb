import std.stdio;
import std.string;

import demb;

void main()
{

  auto vm = new VM();
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

  write("> ");

  auto tree = Demb(readln.strip);
  if (!tree.successful) {
    writeln(tree);
    writeln("Parse Failed");
    return;
  }
  auto program = tree.toAST.byteCompile;
  vm.setProgram(program);

  vm.run();
}
