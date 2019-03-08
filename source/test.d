import demb;

unittest {
  dembAssert(`func main() { print(10); }`, "10\n");
  dembAssert(`func hoge() { return 10; }; func main() { print(hoge() + 1); }`, "11\n"); 
  dembAssert(`func add1(x) { return x+1; }; func main() { print(add1(10)); }`, "11\n"); 
  dembAssert(`func add1tocar(x, y) { return x+1; }; func main() { print(add1tocar(10, 2)); }`, "11\n"); 
}
