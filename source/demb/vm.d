module demb.vm;

import demb.exception;
import demb.object;
import demb.bytecode;
import demb.opcode;
import demb.func;
import std.stdio;
import std.format;
import std.algorithm;
import std.array;

/**
 * Virtual Machine
 *  executing bytecode sequence
 *  having variables
 */
class VM {
  protected:
    BuiltinFunc[string] builtins;
    DembObject[] stack;
    ByteCode[] program;
    uint sp = 0;
    uint ip = 0;

  public:
    this() {
      this.stack = new DembObject[](1);
    }

    void setBuiltins(BuiltinFunc[] builtins) {
      foreach (f; builtins) {
        this.builtins[f.identifier] = f;
      }
    }

    void setProgram(ByteCode[] program) {
      this.program = program;
      this.ip = 0;
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

    string callIdentifier(string name, DembObject[] args) {
      return ([name] ~ args.map!(x => x.type).array).join("_");
    }

    DembObject invoke(string name, DembObject[] args) {
      auto f_id = callIdentifier(name, args);
      if (auto f = f_id in builtins) {
        return f.func(args);
      }

      throw new DembRuntimeException("no function %s for arguments %s".format(name, args.map!(x => x.type).array)); 
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
            auto r = this.invoke("+", [arg1, arg2]);
            this.push(r);
            break;
            
          case OpCode.SUB:
            // pop two arguments from the stack and call opBinary(-), then push returned value
            DembObject arg2 = this.pop();
            DembObject arg1 = this.pop();
            auto r = this.invoke("-", [arg1, arg2]);
            this.push(r);
            break;

          case OpCode.MUL:
            // pop two arguments from the stack and call opBinary(*), then push returned value
            DembObject arg2 = this.pop();
            DembObject arg1 = this.pop();
            auto r = this.invoke("*", [arg1, arg2]);
            this.push(r);
            break;

          case OpCode.DIV:
            // pop two arguments from the stack and call opBinary(/), then push returned value
            DembObject arg2 = this.pop();
            DembObject arg1 = this.pop();
            auto r = this.invoke("/", [arg1, arg2]);
            this.push(r);
            break;

          case OpCode.CONCAT:
            // pop two arguments from the stack and call opBinary(~), then push returned value
            DembObject arg2 = this.pop();
            DembObject arg1 = this.pop();
            auto r = this.invoke("~", [arg1, arg2]);
            this.push(r);
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
