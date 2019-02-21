module demb.builtin;

import demb.object;
import std.array;

alias FuncT = DembObject function(DembObject[]);
class BuiltinFunc {
  public:
    FuncT func;
    string name;
    string[] arg_types;

    this(FuncT func, string name, string[] arg_types) {
      this.func = func;
      this.name = name;
      this.arg_types = arg_types;
    }

    string identifier() const pure {
      return ([this.name] ~ arg_types).join("_");
    }
}

string generate_bin_arith(T, U, V)(string op) {
  import std.traits;
  import std.format;

  return `
    new BuiltinFunc(function DembObject(DembObject[] args) {
        auto arg1 = cast(%1$s)(args[0]);
        auto arg2 = cast(%2$s)(args[1]);

        return new %3$s(arg1.v %4$s arg2.v);
    }, "%4$s", ["%5$s", "%6$s"])`.format(T.stringof, U.stringof, V.stringof, op, T.type_static, U.type_static);
}
