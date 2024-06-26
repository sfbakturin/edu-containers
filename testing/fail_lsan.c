#include <stdlib.h>

int main(void)
{
	int *not_freed = malloc(sizeof(int) * 1024);
	not_freed = NULL;
	return 0;
}
