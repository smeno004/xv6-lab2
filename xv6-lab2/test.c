//#include "types.h"
//#include "user.h"

//void testFunc(int n)
//{
//  int a = n;
//  int b = 1;
//  float c = 2;
//  char d = '3';
//  int e = 3;

//  a += 1;
//  b += 2;
//  c += 3;
//  e += 4;
//  d += 1;

  //printf(1, "hellow world: %d\n", n);
//  if (a >= 100000) {
//    return;
//  }
//  testFunc(a);

//}

//int main()
//{
//  testFunc(1);
//  exit();
//  return 0;
//}

#include "types.h"
#include "stat.h"
#include "user.h"

int test(int n)
{
   //printf(1, "%d\n", n);
   test(n+1);
   return n;
}
int main(int argc, char *argv[])
{
   int pid=0;
   pid=fork();
   if(pid==0){
   int x=1;
   printf(1, "address %x\n", &x);
   test(1);
   exit();
   }
   wait();
   exit();
}
