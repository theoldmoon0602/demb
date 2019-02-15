import std.stdio;
import std.string;
import demb;

void main()
{
  auto program = Demb(readln.strip).toAST.byteCompile;
  auto vm = new VM(program);

  vm.run();

}
