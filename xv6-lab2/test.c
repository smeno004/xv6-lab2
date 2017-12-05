#include "types.h"
#include "user.h"

void testFunc()
{
  char a = 0;
  int b = 0;
  uint c = 0;
  int d = 0;


  a += 1;
  b -= 1;
  c += 1;
  d -= 1;


  testFunc();

}

int main()
{
  testFunc();
  exit();
  return 0;
}
