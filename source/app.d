import std.stdio;
import std.string;
import demb;

void main()
{
  write("> ");

  auto tree = Demb(readln.strip);
  auto program = tree.toAST.byteCompile;
  auto vm = new VM(program);

  vm.run();
}
