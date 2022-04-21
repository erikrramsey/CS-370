#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char** argv) {
    printf("Hello world (from Erik)\n");
    prtpgtbl();
    exit(0);
}