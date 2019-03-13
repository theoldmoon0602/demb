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
import std.range;

class Frame {
  protected:
    DembObject[] locals;
    DembObject[] stack;

    uint sp;

  public:
    this(uint local_count, DembObject[] args) {
      locals = new DembObject[](local_count);
      this.locals[0..args.length] = args;

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

class VM(R) {
  protected:
    R outrange;

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
        OpCode.EQ: "==",
        OpCode.NEQ: "!=",
        OpCode.LT: "<",
        OpCode.LE: "<=",
        OpCode.GT: ">",
        OpCode.GE: ">=",
      ];
    }
  public:
    this(R)(R outrange)
      if (isOutputRange!(R, char))
    {
      frames = [];
      frame_id = 0;

      this.outrange = outrange;
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
      assert(frame_id > 0);
      frame_id--;
    }

    void newFrame(uint local_count, DembObject[] args) {
      assert(frame_id <= frames.length);

      if (frame_id == frames.length) {
        frames ~= new Frame(local_count, args);
      } else {
        frames[frame_id] = new Frame(local_count, args);
      }

      frame_id++;
    }

    @property Frame frame() {
      return this.frames[frame_id-1];
    }

    void invoke(uint func_offset, DembObject[] args) {
      int ip = 0;
      auto codes = StreamingUnpacker(this.func_pool[func_offset].proc).array;
      this.newFrame(this.func_pool[func_offset].local_count, args);

      while (ip < codes.length) {
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

          case EQ: case NEQ:
          case LT: case LE: case GT: case GE:
          case ADD: case SUB: case MUL: case DIV:
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
            outrange.put(arg1.valueString ~ "\n");
            break;

          case CALL:
            auto f_offset = codes[ip][1].as!(uint);
            auto numof_args = codes[ip][2].as!(uint);
            auto f_args = new DembObject[](numof_args);
            foreach_reverse (i; 0..numof_args) {
              f_args[i] = this.frame.pop();
            }
            this.invoke(f_offset, f_args);
            break;

          case RETURN:
            auto r = frame.pop();
            discardFrame();
            frame.push(r);
            return;

          case JUMP:
            auto offset = codes[ip][1].as!(uint);
            ip += offset;
            ip--;
            break;

          case JIF:
            auto offset = codes[ip][1].as!(uint);
            auto cond = frame.pop();
            if (auto cond_b = cast(BooleanObject)(cond)) {
              if (cond_b.v) {
                ip += offset;
                ip--;
              }
            } else {
              throw new DembRuntimeException("Boolen expected");
            }
            break;
        }

        ip++;
      }
      discardFrame();
    }

    void run(CompileResult c) {
      string_pool = c.strs;
      func_pool = c.funcs;

      this.invoke(c.main_offset, []);
    }
}

auto newVM(R)(R outrange) {
  return new VM!(R)(outrange);
}
