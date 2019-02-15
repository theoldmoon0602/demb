module demb.vm;

import demb.exception;
import demb.object;
import demb.bytecode;
import demb.opcode;
import std.stdio;

/**
 * Virtual Machine
 *  executing bytecode sequence
 *  having variables
 */
class VM {
  protected:
    DembObject[] stack;
    ByteCode[] program;
    uint sp = 0;
    uint ip = 0;

  public:
    this(ByteCode[] program) {
      this.stack = new DembObject[](1);
      this.program = program;
    }

    void push(DembObject o) {
      if (this.stack.length <= sp) {
        this.stack.length = this.stack.length * 2;
      }
      this.stack[sp] = o;
      sp++;
    }

    DembObject pop() {
      import std.stdio;
      if (this.sp == 0) {
        throw new DembRuntimeException("stack is empty");
      }
      return this.stack[--sp];
    }

    void run() {
      while (ip < program.length) {
        // fetch
        final switch (program[ip].code) {
          case OpCode.PUSH:
            // get argument from bytecode and push it to the stack
            DembObject obj = program[ip].getArg(0);
            this.push(obj);
            break;

          case OpCode.ADD:
            // pop two arguments from the stack and call opBinary(+), then push returned value
            DembObject arg2 = this.pop();
            DembObject arg1 = this.pop();
            this.push(arg1.binOp("+", arg2));
            break;
            
          case OpCode.SUB:
            // pop two arguments from the stack and call opBinary(-), then push returned value
            DembObject arg2 = this.pop();
            DembObject arg1 = this.pop();
            this.push(arg1.binOp("-", arg2));
            break;

          case OpCode.MUL:
            // pop two arguments from the stack and call opBinary(*), then push returned value
            DembObject arg2 = this.pop();
            DembObject arg1 = this.pop();
            this.push(arg1.binOp("*", arg2));
            break;

          case OpCode.DIV:
            // pop two arguments from the stack and call opBinary(/), then push returned value
            DembObject arg2 = this.pop();
            DembObject arg1 = this.pop();
            this.push(arg1.binOp("/", arg2));
            break;
            
          case OpCode.PRINT:
            // pop an argument from the stack and print it to outputstream
            DembObject arg1 = this.pop();
            writeln(arg1.valueString);
            break;
        }
        ip++;
      }
    }
}
