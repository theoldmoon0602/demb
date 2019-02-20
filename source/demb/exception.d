module demb.exception;

import std.exception;

static class DembCompileException : Exception
{
  mixin basicExceptionCtors;
}

static class DembRuntimeException : Exception
{
  mixin basicExceptionCtors;
}

