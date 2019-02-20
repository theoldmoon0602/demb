module demb.vm;

import demb.object;

class Frame {
  protected:
    DembObject[] locals;
    DembObject[] stack;

    uint sp;

  public:
    this(uint local_count) {

    }


}

class VM {
  protected:
    uint ip;
    uint sp;
  public:
    this() {
    }
}
