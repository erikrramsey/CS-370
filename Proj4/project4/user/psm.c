#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/psinfo.h"
#include "user/user.h"

void print_proc(struct ps_proc* pr);

int main(int argc, char** argv) {
    struct ps_proc* procs = malloc(sizeof(struct ps_proc) * 15);
    int total = ps(procs);
    printf("Process Status\n");
    char* header = "pid     state     prior memory  process name    ";
    char* div    = "------------------------------------------------";
    printf("%s\n%s\n", header, div);

    for (int i = 0; i < total; i++) {
        print_proc(&procs[i]);
        printf("\n");
    }

    exit(0);
}

void print_proc(struct ps_proc* pr) {
    char* state;
    switch (pr->state) {
        case 1:
            state = "USED      ";
            break;
        case 2:
            state = "SLEEPING  ";
            break;
        case 3:
            state = "RUNANBLE  ";
            break;
        case 4:
            state = "RUNNING   ";
            break;
        case 5:
            state = "ZOMBIE    ";
            break;
        default:
            state = "ERROR";
            break;
    }

    printf("%d       %s%d     %d   %s", pr->pid, state, pr->priority, pr->memory, pr->name);
}
