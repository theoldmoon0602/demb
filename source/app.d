import std.stdio;
import std.string;

import demb;

void main()
{

  auto vm = new VM();
  vm.setBuiltins([
      new BuiltinFunc(&builtin_add_integer_integer, "+", ["Integer", "Integer"]),
      new BuiltinFunc(&builtin_sub_integer_integer, "-", ["Integer", "Integer"]),
      new BuiltinFunc(&builtin_mul_integer_integer, "*", ["Integer", "Integer"]),
      new BuiltinFunc(&builtin_div_integer_integer, "/", ["Integer", "Integer"]),
  ]);

  write("> ");

  auto tree = Demb(readln.strip);
  auto program = tree.toAST.byteCompile;
  vm.setProgram(program);

  vm.run();
}
