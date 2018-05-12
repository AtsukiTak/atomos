int main() {
  *((char*) 0xb8000) = 'X';
  return 0;
}
