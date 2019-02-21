module demb.compilecontext;

import std.algorithm;

// TODO: add namespace
// TODO: distinguish local variable id with global variable id
class CompileContext {
  protected:
    string current_scope;

    uint[string] string_pool;
    string[uint] rev_string_pool;

    uint[string] global_pool;

    uint[string] var_pool;

  public:
    this() {
      this.current_scope = "";
    }

    void newContext(string scope_name) {
      this.current_scope = scope_name;
      var_pool.clear();
    }

    // DELETEME
    ulong local_count() {
      return this.var_pool.length;
    }

    // DELETEME
    string getString(uint key) {
      return rev_string_pool[key];
    }

    string[] stringPool() {
      string[] r = [];
      foreach (k; rev_string_pool.keys.sort) {
        r ~= rev_string_pool[k];
      }
      return r;
    }

    uint addString(string s) {
      if (s in string_pool) {
        return string_pool[s];
      }
      string_pool[s] = cast(uint)string_pool.length;
      rev_string_pool[string_pool[s]] = s;
      return string_pool[s];
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
    
    uint hasGlobal(string key) {
      return cast(bool)(key in global_pool);
    }

    uint addGlobal(string key) {
      if (! this.hasVar(key)) {
        global_pool[key] = cast(uint)global_pool.length;
      }
      return global_pool[key];
    }

    uint getGlobalId(string key) {
      return global_pool[key];
    }
}
