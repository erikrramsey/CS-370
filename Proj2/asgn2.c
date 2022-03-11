#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <string.h>

pthread_mutex_t myLock;
int             numThreads = 0;
int             happyNums = 0;
int             limit = 0;

int argCheck(int argc, char** argv) {
    int error = 0;
    if (argc < 5 || strcmp(argv[1], "-t") != 0 || strcmp(argv[3], "-l") != 0) {
        printf("invalid command line arguments.\n");
        error = 1;
    } else {
        int threads = atoi(argv[2]);
        if (threads < 5 && threads > 0)
            numThreads = threads;
        else {
            printf("invalid thread count.\n");
            error = 1;
        }

        unsigned int localLimit = atoi(argv[4]);
        if (localLimit >= 100) {
            limit = localLimit;
        } else {
            printf("limit must be > 100.\n");
            error = 1;
        }
    }

    return error;
}

void incHappyNums(int amount) {
    pthread_mutex_lock(&myLock);
    happyNums += amount;
    pthread_mutex_unlock(&myLock);
}

int isHappyNum(int num) {
    int isHappy = -1;
    int sum = 0;
    while (isHappy == -1) {
        if (num == 1 || num == 0) isHappy = 1;
        if (num == 4) isHappy = 0;
        while (num != 0) {
            int digit = num % 10;
            sum += digit * digit;
            num /= 10;
        }
        num = sum;
        sum = 0;
    }
    return isHappy;
}

void* findHappyNums(void* a_threadNum) {
    int threadNum = *(int*)a_threadNum;
    int localHappyNums = 0;
    for (int i = threadNum; i < limit; i += numThreads) {
        if (isHappyNum(i)) {
            localHappyNums++;
        }
    }

    incHappyNums(localHappyNums);
    return NULL;
}

int main(int argc, char** argv) {
    int error = argCheck(argc, argv);
    if (error) return error;

    printf("Count of Happy and Sad numbers from 1 to 10000000\n");
    printf("Please wait. Running...\n\n");

    if (pthread_mutex_init(&myLock, NULL))
        printf("Mutex initialization failed.\n");

    pthread_t* threads = malloc(sizeof(pthread_t) * numThreads);
    int*     threadIds = malloc(sizeof(int) * numThreads);
    
    for(int arg = 0; arg < numThreads; arg++) {
        threadIds[arg] = arg;
        if (pthread_create(&threads[arg], NULL, &findHappyNums, (void*)&threadIds[arg]))
            printf("Error creating thread %d\n", arg);
    }

    for (int i = 0; i < numThreads; i++) {
        pthread_join(threads[i], NULL);
    }

    free(threads);
    free(threadIds);

    printf("Count of happy numbers: %d\n", happyNums);
    printf("Count of sad numbers: %d\n", limit - happyNums);

    return 0;
}