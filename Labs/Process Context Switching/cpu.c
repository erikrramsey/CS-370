// CS 370
// Compute bound process

//	Does irrelevant calculations in an infinite loop.
//	Must ctrl-c to exit.

#include <unistd.h>
#include <stdio.h>

int main(int argc, char *argv[]) 
{
	unsigned	long	i,j;

	while(1) {
		j = 1;
		for(i = 1; i <= 10; i++) {
			j = j*i;
		}
	}
}

