module demb.vm;

import demb.object;
import demb.builtin;
import demb.opcode;
import demb.compileresult;
import demb.exception;
import demb.func;
import msgpack;
import std.stdio;
import std.algorithm;
import std.array;
import std.conv;
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

    void set(uint id, DembObject obj) {
      locals[id] = obj;
    }

    DembObject get(uint id) {
      return locals[id];
    }

}

class VM {
  protected:
    Frame[] frames;
    BuiltinFunc[string] builtins;

    CompiledFunction[] func_pool;
    string[] string_pool;

    uint frame_id;

    static string[OpCode] binopmap;
    static this() {
      this.binopmap = [
        OpCode.ADD: "+",
        OpCode.SUB: "-",
        OpCode.MUL: "*",
        OpCode.DIV: "/",
        OpCode.CONCAT: "~",
      ];
    }
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


    void discardFrame() {
      frame_id--;
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

    void invoke(uint func_offset) {
      int ip = 0;
      auto codes = StreamingUnpacker(this.func_pool[func_offset].proc).array;
      this.newFrame(this.func_pool[func_offset].local_count);

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
            auto str_id = codes[ip][1].as!(uint);
            auto strobj = new StringObject(string_pool[str_id]);
            frame.push(strobj);
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

          case ASSIGN:
            auto arg1 = frame.pop();
            auto var_id = codes[ip][1].as!(uint);
            frame.set(var_id, arg1);
            break;

          case LOAD:
            auto var_id = codes[ip][1].as!(uint);
            auto v = frame.get(var_id);
            frame.push(v);
            break;

          case PRINT:
            DembObject arg1 = frame.pop();
            writeln(arg1.valueString);
            break;

          case CALL:
            auto offset = codes[ip][1].as!(uint);
            this.invoke(offset);
            break;
        }

        ip++;
      }
      discardFrame();
    }

    void run(CompileResult c) {
      string_pool = c.strs;
      func_pool = c.funcs;

      this.invoke(c.main_offset);
    }
}
