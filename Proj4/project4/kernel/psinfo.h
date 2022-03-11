#include "types.h"
const uint8 MAX_PROCS = 15;

struct ps_proc {
    char* name;
    uint8 state;
    uint8 pid;
    uint64 memory;
};

struct uint8 {
    int me;
};