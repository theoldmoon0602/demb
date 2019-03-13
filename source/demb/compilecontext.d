module demb.compilecontext;

import std.algorithm;

class MiniScope {
  protected:
    uint[string] var_pool;
    MiniScope parent;

  public:
    this(MiniScope parent=null) {
      this.parent = parent;
    }

    MiniScope getParent() {
      return this.parent;
    }

    uint local_count() {
      return cast(uint)(this.var_pool.length) + ((parent is null) ? 0 : parent.local_count());
    }

    bool hasVar(string key) {
      return cast(bool)(key in var_pool) || ((parent is null) ? false : parent.hasVar(key));
    }

    uint addVar(string key) {
      if (! this.hasVar(key)) {
        var_pool[key] = this.local_count();
      }
      return var_pool[key];
    }

    uint getVarId(string key) {
      if (key in var_pool) {
        return var_pool[key];
      }
      return parent.getVarId(key);
    }
}

// TODO: add namespace
class CompileContext {
  protected:
    string current_scope;

    uint[string] string_pool;
    string[uint] rev_string_pool;
    uint[string] global_pool;

    MiniScope locals;

  public:
    this() {
      this.current_scope = "";
      this.locals = new MiniScope();
    }

    void newContext(string scope_name) {
      this.current_scope = scope_name;
      locals = new MiniScope(null);
    }

    void newScope() {
      locals = new MiniScope(locals);
    }

    void scopeout() {
      locals = locals.getParent();
    }

    // DELETEME
    ulong local_count() {
      return this.locals.local_count();
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
      return locals.hasVar(key);
    }
    uint addVar(string key) {
      return locals.addVar(key);
    }
    uint getVarId(string key) {
      return locals.getVarId(key);
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
