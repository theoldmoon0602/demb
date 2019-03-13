module demb.object;

import demb.exception;
import std.format;

/**
 * DembObject
 */
abstract class DembObject {
  public:
    abstract string type() const pure;
    abstract string valueString() const;
}

class BuiltinType(T, string name): DembObject {
  public:
    T v;

    this(T v) pure {
      this.v = v;
    }

    static string type_static() {
      return name;
    }

    override string type() const pure {
      return name;
    }
    override string valueString() const {
      return "%s".format(v);
    }
}

alias BooleanObject = BuiltinType!(bool, "Boolean");
alias IntegerObject = BuiltinType!(long, "Integer");
alias FloatObject   = BuiltinType!(double, "Float");
alias StringObject  = BuiltinType!(string, "String");
