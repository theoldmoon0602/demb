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

class IntegerObject : DembObject {
  public:
    long v;

    this(long v) pure {
      this.v = v;
    }

    static string type_static() {
      return "Integer";
    }

    override string type() const pure {
      return "Integer";
    }
    override string valueString() const {
      return "%d".format(v);
    }
}

class FloatObject : DembObject {
  public:
    double v;

    this(double v) pure {
      this.v = v;
    }

    static string type_static() {
      return "Float";
    }

    override string type() const pure {
      return "Float";
    }
    override string valueString() const {
      return "%f".format(v);
    }
}
