#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/psinfo.h"
#include "user/user.h"

const int MAX_PROCESS = 6;
int primeCount(unsigned long limit);

int main(int argc, char** argv) {
    printf("Scheduler Tests.\n");

    printf("Starting children...\n");
    // Fork 6 times and process primes in each child
    int pid;
    for (int i = 0; i < MAX_PROCESS; i++) {
        pid = fork();
        if (pid == 0) {
            char priority[] = "fg";
            if (i % 2 == 0) {
                setbkg();
                strcpy(priority, "bg");
            }
            int count = primeCount(100000);
            printf("Prime count (%s): %d %d\n", priority, count, i);
            exit(0);
        }
    }

    // Wait for all children to terminate
    for (int i = 0; i < MAX_PROCESS; i++) {
        wait(0);
    }

    printf("Sceduler tests done\n");

    exit(0);
}

int primeCount(unsigned long limit) {
    int count = 0;
    for (int i = 2; i < limit; i++) {
        int is_prime = 1;
        for (int j = 2; j <= i / 2 && is_prime; j++) {
           if (i % j == 0) is_prime = 0; 
        }
        if (is_prime) {
            count++;
        } 
    }
    return count;
}