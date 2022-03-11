// CS 370 -> Infinite CPU Bound Program

#include <sys/time.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

// Infinite CPU bound program
// Stops only when interrupted or killed.
// Every ITERATIONS times through its loop it prints a report of how
// long (in microseconds) it took to do the last ITERATIONS iterations.
// The time is elapsed (wall clock) time (so only an estimate).

static const long int ITERATIONS = 500000000;

int main(int argc, char *argv[])
{
	long		diff=0;
	timeval		start, stop;

	while(1) {						// do test until killed
    
		if(gettimeofday(&start, 0) < 0) {		// get start time
			perror("gettimeofday");
			exit(1);
		}

		for(long i = ITERATIONS; i > 0; i--) {		// the actual 'test'
			// do nothing
		}

		if(gettimeofday(&stop, 0) < 0) {		// get end time
			perror("gettimeofday");
			exit(1);
		}

		diff = stop.tv_sec - start.tv_sec;
		diff *= 1000000; // microseconds per second
		diff += stop.tv_usec - start.tv_usec;
		printf("%ld usecs\n", diff);
	}

	return 0;
}

