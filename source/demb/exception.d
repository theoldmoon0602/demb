module demb.exception;

import std.exception;

static class DembRuntimeException : Exception
{
  mixin basicExceptionCtors;
}

