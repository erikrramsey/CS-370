#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char* argv[]) {
    int start = timeins();
    sleep(100);
    start = timeins() - start;
    printf("Time in Seconds: %d\n", start);
    exit(0);
}