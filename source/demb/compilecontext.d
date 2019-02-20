module demb.compilecontext;


// TODO: add namespace
// TODO: distinguish local variable id with global variable id
class CompileContext {
  protected:
    uint[string] var_ids;
    uint[string] string_ids;
    CompileContext parent;

  public:
    this(CompileContext parent = null) {
      this.parent = parent;
    }

    bool hasLocalvar(string key) {
      return cast(bool)(key in var_ids);
    }

    bool hasVar(string key) {
      if (key in var_ids) {
        return true;
      }
      if (parent !is null) {
        return parent.hasVar(key);
      }
      return false;
    }

    uint addVar(string key) {
      var_ids[key] = cast(uint)var_ids.length;
      return var_ids[key];
    }

    uint getVarId(string key) {
      return var_ids[key];
    }

    uint addString(string s) {
      if (parent is null) {
        if (s in string_ids) {
          return string_ids[s];
        }
        string_ids[s] = cast(uint)string_ids.length;
        return string_ids[s];
      }
      return parent.addString(s);
    }
}
