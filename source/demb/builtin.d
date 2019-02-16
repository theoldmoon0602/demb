module demb.builtin;

import demb.object;

DembObject builtin_add_integer_integer(DembObject[] args) {
  auto arg1 = cast(IntegerObject)(args[0]);
  auto arg2 = cast(IntegerObject)(args[1]);

  return new IntegerObject(arg1.v + arg2.v);
}
DembObject builtin_sub_integer_integer(DembObject[] args) {
  auto arg1 = cast(IntegerObject)(args[0]);
  auto arg2 = cast(IntegerObject)(args[1]);

  return new IntegerObject(arg1.v - arg2.v);
}
DembObject builtin_mul_integer_integer(DembObject[] args) {
  auto arg1 = cast(IntegerObject)(args[0]);
  auto arg2 = cast(IntegerObject)(args[1]);

  return new IntegerObject(arg1.v * arg2.v);
}
DembObject builtin_div_integer_integer(DembObject[] args) {
  auto arg1 = cast(IntegerObject)(args[0]);
  auto arg2 = cast(IntegerObject)(args[1]);

  return new IntegerObject(arg1.v / arg2.v);
}
