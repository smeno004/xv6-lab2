#include "types.h"
#include "user.h"

void testFunc()
{
	char a;
	int b;
	int c;
	uint d;


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