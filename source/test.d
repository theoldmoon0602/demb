import demb;

unittest {
  dembAssert(`func main() { print(10); }`, "10\n");
  dembAssert(`func hoge() { return 10; }; func main() { print(hoge() + 1); }`, "11\n"); 
  dembAssert(`func add1(x) { return x+1; }; func main() { print(add1(10)); }`, "11\n"); 
  dembAssert(`func add1tocar(x, y) { return x+1; }; func main() { print(add1tocar(10, 2)); }`, "11\n"); 
  dembAssert(`func hoge(s) { print(s); return 1; }; func main() { print(hoge(1) + hoge(2)); }`, "1\n2\n2\n"); 
  dembAssert(`func main() { x = 9; if (x < 10) { print("A"); } else { print("B"); }; }`, "A\n"); 
  dembAssert(`func main() { x = 10; if (x < 10) { print("A"); } else { print("B"); }; }`, "B\n"); 
  dembAssert(`func main() { x = 1; if (x == 1) { print("A"); } else if (x > 10) { print("B") } else { print("C"); }; }`, "A\n"); 
  dembAssert(`func main() { x = 100; if (x == 1) { print("A"); } else if (x > 10) { print("B") } else { print("C"); }; }`, "B\n"); 
  dembAssert(`func main() { x = 9; if (x == 1) { print("A"); } else if (x > 10) { print("B") } else { print("C"); }; }`, "C\n");
  dembAssert(`func fib(x) { if (x <= 2) { return 1; }; return fib(x-1) + fib(x-2); }; func main() { print(fib(5)); }`, "5\n");
}
