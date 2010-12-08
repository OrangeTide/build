#include <stdio.h>
#include "e.h"
void example(void) {
	fprintf(stderr, "%s:%d:Hello World!\n", __FILE__, __LINE__);
}
