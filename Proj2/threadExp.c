#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
//  Global variables
pthread_mutex_t myLock; // mutex variable
int j = 0; // global shared variable
//  Thread function, just prints the global variable five times.
void * do_process() {
    int i = 0;
    pthread_mutex_lock(&myLock);
    printf("\nThread Start\n");
    j++;
    while(i < 5) {
        printf("%d", j);
        sleep(0.5);
        i++;
    }
    printf("Thread Done\n");
    pthread_mutex_unlock(&myLock);
    return NULL;
}
int main(void)
{
    unsigned long int thdErr1, thdErr2, mtxErr;
    pthread_t thd1, thd2;
    printf("C Threading Example.\n");
    //  Initialize myLock mutex.
    mtxErr = pthread_mutex_init(&myLock, NULL);
    if (mtxErr != 0)
    perror("Mutex initialization failed.\n");
    //  Create two threads.
    thdErr1 = pthread_create(&thd1, NULL, &do_process, NULL);
    if (thdErr1 != 0)
    perror("Thread 1 fail to create.\n");
    thdErr2 = pthread_create(&thd2, NULL, &do_process, NULL);
    if (thdErr2 != 0)
    perror("Thread 2 fail to create.\n");
    //  Wait for threads to complete.
    pthread_join(thd1, NULL);
    pthread_join(thd2, NULL);
    //  Threads done, show final result.
    printf("\nFinal value of global variable: %d \n", j);
    return 0;
}