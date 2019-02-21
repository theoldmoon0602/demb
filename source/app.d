import std.stdio;
import std.string;
import std.array;
import demb;
import msgpack;

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

  auto tree = parse(source);
  if (!tree.successful) {
    writeln(tree);
    writeln("Parse Failed");
    writeln(source);
    return;
  }
  auto program = compile(cast(TopLevelAST)tree.toAST).pack;
  auto compileresult = program.unpack!(CompileResult);

  vm.run(compileresult);
}
