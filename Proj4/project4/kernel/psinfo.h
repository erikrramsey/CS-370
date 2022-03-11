#include "types.h"

const int MAX_PROCS = 15;

struct ps_proc {
    char name[16];
    int state;
    int pid;
    int priority;
    unsigned long memory;
};