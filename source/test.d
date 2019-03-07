import demb;

unittest {
  dembAssert(`func main() { print(10); }`, "10\n");
  dembAssert(`func hoge() { return 10; }; func main() { print(hoge() + 1); }`, "11\n"); 
}
