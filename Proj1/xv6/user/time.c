#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char* argv[]) {
    int pid = fork();
    if (pid > 0) {
        int time = uptime();
        int* status = malloc(sizeof(int));
        pid = wait(status);
        time = uptime() - time;
        if (*status == 0) {
            printf("Real-time in ticks: %d\n", time);
            exit(0);
        } else {
            exit(1);
        }
    } else if (pid == 0) {
        close(0);
        exec(argv[1], &argv[1]);
        printf("Error: %s: command not found.\n", argv[1]);
        exit(1);
    } else {
        printf("Error: could not fork process.");
        exit(1);
    }
}