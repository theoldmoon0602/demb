import std.stdio;
import demb;

void main()
{
  auto vm = new VM([
      ByteCode(OpCode.PUSH, [new NumberObject(5)]),
      ByteCode(OpCode.PUSH, [new NumberObject(8)]),
      ByteCode(OpCode.ADD, []),
      ByteCode(OpCode.PRINT, []),
  ]);

  vm.run();

}
