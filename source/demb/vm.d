module demb.vm;

import demb.object;
import demb.func;
import demb.opcode;
import demb.compilecontext;
import demb.exception;
import msgpack;
import std.stdio;
import std.algorithm;
import std.array;
import std.format;

class Frame {
  protected:
    DembObject[] locals;
    DembObject[] stack;

    uint sp;

  public:
    this(uint local_count) {
      locals = new DembObject[](local_count);
      stack = new DembObject[](10);
      sp = 0;
    }

    void push(DembObject obj) {
      while (stack.length <= sp) {
        stack.length = stack.length * 2;
      }
      stack[sp] = obj;
      sp++;
    }

    DembObject pop() {
      if (sp == 0) {
        throw new DembRuntimeException("stack is empty");
      }
      sp--;
      return stack[sp];
    }

}

class VM {
  protected:
    Frame[] frames;
    BuiltinFunc[string] builtins;
    uint frame_id;
    uint ip;
  public:
    this() {
      frames = [];
      frame_id = 0;
    }

    void setBuiltins(BuiltinFunc[] builtins) {
      foreach (f; builtins) {
        this.builtins[f.identifier] = f;
      }
    }

    string getFunctionID(string name, DembObject[] args) {
      return ([name] ~ args.map!(x => x.type).array).join("_");
    }

    DembObject invoke(string name, DembObject[] args) {
      auto f_id = getFunctionID(name, args);
      if (auto f = f_id in builtins) {
        return f.func(args);
      }

      throw new DembRuntimeException("no function %s for arguments %s".format(name, args.map!(x => x.type).array)); 
    }

    void newFrame(uint local_count) {
      if (frame_id == frames.length) {
        frames ~= new Frame(local_count);
      } else {
        frames[frame_id] = new Frame(local_count);
      }
    }

    @property Frame frame() {
      return this.frames[frame_id];
    }

    void run(Unpacked[] codes, CompileContext ctx) {
      this.ip = 0;
      this.newFrame(cast(uint)ctx.local_count);
      string[OpCode] binopmap = [
        OpCode.ADD: "+",
        OpCode.SUB: "-",
        OpCode.MUL: "*",
        OpCode.DIV: "/",
        OpCode.CONCAT: "~",
      ];


      while (ip < codes.length){
        auto opcode = cast(OpCode)(codes[ip][0].as!(uint));
        final switch(opcode) with (OpCode) {
          case PUSHI:
            frame.push(new IntegerObject(codes[ip][1].as!(long)));
            break;

          case PUSHF:
            frame.push(new FloatObject(codes[ip][1].as!(double)));
            break;
            
          case PUSHS:
            frame.push(new StringObject(ctx.getString(codes[ip][1].as!(uint))));
            break;

          case ADD:
          case SUB:
          case MUL:
          case DIV:
          case CONCAT:
            auto arg2 = frame.pop();
            auto arg1 = frame.pop();
            auto r = this.invoke(binopmap[opcode], [arg1, arg2]);
            frame.push(r);
            break;


          case PRINT:
            DembObject arg1 = frame.pop();
            writeln(arg1.valueString);
            break;
        }

        ip++;
      }
    }
}
