module demb.compilecontext;

// TODO: add namespace
// TODO: distinguish local variable id with global variable id
class CompileContext {
  protected:
    string current_scope;
    uint[string] string_pool;
    string[uint] rev_string_pool;

    uint[string] var_pool;

  public:
    this() {
      this.current_scope = "";
    }

    // DELETEME
    ulong local_count() {
      return this.var_pool.length;
    }

    // DELETEME
    string getString(uint key) {
      return rev_string_pool[key];
    }

    bool hasVar(string key) {
      return cast(bool)(key in var_pool);
    }

    uint addVar(string key) {
      if (! this.hasVar(key)) {
        var_pool[key] = cast(uint)var_pool.length;
      }
      return var_pool[key];
    }

    uint getVarId(string key) {
      return var_pool[key];
    }

    uint addString(string s) {
      if (s in string_pool) {
        return string_pool[s];
      }
      string_pool[s] = cast(uint)string_pool.length;
      rev_string_pool[string_pool[s]] = s;
      return string_pool[s];
    }
}
