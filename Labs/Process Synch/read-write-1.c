// CS 370
// A simple readers/writers program using a one-word shared memory.

#include <sys/types.h>				// for pid_t
#include <unistd.h>				// for fork
#include <stdio.h>				// for printf
#include <sys/mman.h>				// for mmap
#include <sys/wait.h>				// for waitpid
#include <stdlib.h>				// for exit

#define	SIZE sizeof(int)			// size of [int] integer
#define	run_length 10				// number of iterations in test run

int main (void)
{
	pid_t	pid;				// variable to record process id of child
	caddr_t	shared_memory;			// shared memory base address
	int	i_parent, i_child;		// index variables
	int	value;				// value read by child


	// set up shared memory segment
	shared_memory = mmap(0, SIZE, PROT_READ | PROT_WRITE,
				MAP_ANONYMOUS | MAP_SHARED, -1, 0);

	if (shared_memory == (caddr_t) -1) {
		perror ("error in mmap while allocating shared memory\n");
		exit (1);
	}

	*shared_memory = -1;

	if ((pid = fork()) < 0) {
		// apply fork and check for error
		perror ("error in fork");
		exit (1);
	}

	if (0 == pid) {
		// processing for child

		printf("\033[0;31mThe child process begins.\033[0m\n");
		for (i_child = 0; i_child < run_length; i_child++) {

			// wait for memory to be updated
//			sleep(1);
			while (*shared_memory == -1) {}

			value = *shared_memory;

			printf("\033[0;31mChild's report:  current value = %2d\033[0m\n", value);
			*shared_memory = -1;
		}
		printf("\033[0;31mThe child is done.\033[0m\n");

	} else {

		// processing for parent
		printf("\033[0;32mThe parent process begins.\033[0m\n");

		for (i_parent = 0; i_parent < run_length; i_parent++) {

			// square into shared memory
			*shared_memory = i_parent * i_parent;

			printf("\033[0;32mParent's report: current value = %2d\033[0m\n", i_parent);

			// wait for child to read value
//			sleep(1);
			while (*shared_memory != -1) {}
		}
		waitpid(pid, NULL, 0);

		// deallocate shared memory
		munmap (shared_memory, SIZE);

		printf("\033[0;32mThe parent is done.\033[0m\n");
	}

	exit(0);
}

