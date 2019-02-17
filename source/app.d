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

  string source = "";
  foreach (line; stdin.byLine) {
    source ~= line.strip ~ "\r\n";
  }

  auto tree = Demb(source);
  if (!tree.successful) {
    writeln(tree);
    writeln("Parse Failed");
    writeln(source);
    return;
  }
  auto program = tree.toAST.byteCompile;
  vm.setProgram(program);

  vm.run();
}
