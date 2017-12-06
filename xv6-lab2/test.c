#include "types.h"
#include "user.h"
#include "memlayout.h"
void testFunc(int n)
{
  int a = n;
  int b = 1;
  float c = 2;
  char d = '3';
  int e = 3;

  a += 1;
  b += 2;
  c += 3;
  e += 4;
  d += 1;

  //printf(1, "hellow world: %d\n", n);
  if (a >= 100000) {
    return;
  }
  testFunc(a);

}

int main()
{
  testFunc(1);
  exit();
  return 0;
}
