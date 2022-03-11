#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>
#include <string.h>
#include <unistd.h>

int smokeTotal = 0;
sem_t table;
sem_t agent;
sem_t smoker_sem[3];

void* agentThdFunc();
void* smokersThdFunc();

int main(int argc, char** argv) {

    if (argc < 3 || strcmp(argv[1], "-s") != 0) {
        printf("Expected: './project3 -s <smokeCount>'\n");
        return 1;
    }

    smokeTotal = atoi(argv[2]);
    if (smokeTotal < 3 || smokeTotal > 10) {
        printf("Invalid smoke count. (3 - 10 inclusive)\n");
        return 1;
    }

    sem_init(&agent, 0, 0);
    sem_init(&table, 0, 1);
    pthread_t agent;
    pthread_create(&agent, NULL, &agentThdFunc, NULL);

    pthread_t smokers[3];
    int       smoker_ids[] = {0, 1, 2};
    for (int i = 0; i < 3; i++) {
        sem_init(&smoker_sem[i], 0, 0);
        pthread_create(&smokers[i], NULL, &smokersThdFunc, (void *)(&smoker_ids[i]));
    }

    for (int i = 0; i < 3; i++) {
        pthread_join(smokers[i], NULL);
    }

    return 0;
}

void* agentThdFunc() {
    char* resources[] = {
        "tobacco and paper",
        "matches and tobacco",
        "matches and paper"
    };

    int timesCalled[] = {0, 0, 0};
    int done = 0;

    while (!done) {
        sem_wait(&table);
        int resource = -1;
        do {
            resource = rand() % 3;
        } while (timesCalled[resource] == smokeTotal);
        timesCalled[resource]++;
        printf("agent produced %s\n", resources[resource]);
        sem_post(&table);
        sem_post(&smoker_sem[resource]);
        done = (timesCalled[0] == smokeTotal &&
                timesCalled[1] == smokeTotal &&
                timesCalled[2] == smokeTotal);
        sem_wait(&agent);
    }
    return NULL;
}

void* smokersThdFunc(void* args) {
    const char* colors[] = {
        "\033[0;31m",
        "\033[0;32m",
        "\033[0;34m",
    };

    int id = *(int*)args;
    int smokeCount = 0;

    printf("Smoker %d starts...\n", id);

    while (smokeCount < smokeTotal) {
        sem_wait(&smoker_sem[id]);
        sem_wait(&table);
        smokeCount++;
        printf("%s", colors[id]);
        printf("Smoker: %d completed smoking cig#: %d.\n", id, smokeCount);
        printf("\033[0m");
        fflush(stdout);
        usleep(rand() % 1500000);
        sem_post(&table);
        sem_post(&agent);
    }

    printf("Smoker %d dies of cancer.\n", id);


    return NULL;
}