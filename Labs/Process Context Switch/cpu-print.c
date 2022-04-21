// CS 370
// I/O Bound process

//	Does system calls in a loop and loops for a very long time...
//	Can ctrl-c to exit.

#include <unistd.h>
#include <stdio.h>
#include <sys/time.h>

int main(int argc, char *argv[]) 
{
	unsigned	int i;
	int		count = 0;
	struct timeval tv;
  
	while(1) {
		for(i = 0; i < 1000000; i++) {
			gettimeofday(&tv, NULL);
			printf("%ld sec, %ld usec\n", tv.tv_sec, tv.tv_usec);
		}
		count++;
		printf("round %d complete\n", count);
	}
}

