module demb.func;

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
