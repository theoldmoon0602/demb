import std.stdio;
import std.string;
import std.array;
import demb;
import msgpack;

void main()
{
  auto vm = newVM(stdout.lockingTextWriter);
  vm.registerBuiltinFunctions();

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
