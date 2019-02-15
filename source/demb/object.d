module demb.object;

import demb.exception;
import std.format;

/**
 * DembObject
 */
abstract class DembObject {
  public:
    abstract string type() const pure;
    abstract string valueString() const pure;
    abstract bool isTrue() const pure;
    abstract DembObject binOp(string op, DembObject rhs) const pure;
}

class NumberObject : DembObject {
  protected:
    long v;
  public:
    this(long v) pure {
      this.v = v;
    }

    override string type() const pure {
      return "Number";
    }
    override string valueString() const pure {
      return "%d".format(v);
    }
    unittest {
      assert((new NumberObject(0)).valueString == "0");
      assert((new NumberObject(-1000)).valueString == "-1000");
    }
    override bool isTrue() const pure {
      return true;
    }
    override DembObject binOp(string op, DembObject rhs) const pure {
      if (op == "+") {
        if (auto number = cast(NumberObject)rhs) {
          return new NumberObject(this.v + number.v);
        }
      }
      else if (op == "-") {
        if (auto number = cast(NumberObject)rhs) {
          return new NumberObject(this.v - number.v);
        }
      }
      else if (op == "*") {
        if (auto number = cast(NumberObject)rhs) {
          return new NumberObject(this.v * number.v);
        }
      }
      else if (op == "/") {
        if (auto number = cast(NumberObject)rhs) {
          return new NumberObject(this.v / number.v);
        }
      }

      throw new DembRuntimeException("invalid operator %s or rhs".format(op));
    }
    unittest {
      import std.exception;
      auto r = (new NumberObject(2)).binOp("+", new NumberObject(3));
      assert(cast(NumberObject)r !is null);
      assert((cast(NumberObject)r).v == 5);
    }
}
