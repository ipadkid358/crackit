#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <math.h>
#include <sys/time.h>

// function referenced by pthread_create to execute on background thread
void *eachCountTo(volatile unsigned long long *execOn) {
    volatile unsigned long long counter = *execOn;
    while (counter) {
        counter--;
    }
    return NULL;
}


/// Formats an unsigned long long to a char * using commas, caller is responsible for freeing the return value
char *formatllu(unsigned long long n) {
    char largestllu[22];
    int fixModLen = sprintf(largestllu, "%llu", n);
    int commas = fixModLen/3;
    if (commas) {
        commas--;
    }
    
    char *ret = malloc(fixModLen+commas+1);
    int offset = fixModLen%3;
    char *lchr = largestllu;
    char *rchr = ret;
    
    for (int i = 0; i < fixModLen; i++) {
        if ((i%3 == offset) && i) {
            *rchr = ',';
            rchr++;
        }
        
        *rchr = *lchr;
        
        rchr++;
        lchr++;
    }
    *rchr = '\0';
    return ret;
}

/// Formats a double to a char * using commas, caller is responsible for freeing the return value
char *formatDouble(double n) {
    double lv = floor(n);
    char largestBuff[36];
    
    char *front = formatllu((unsigned long long)lv);
    unsigned int realLen = sprintf(largestBuff, "%s %f", front, n-lv)-2;
    free(front);
    
    char *ret = malloc(realLen+1);
    char *b = largestBuff;
    char *r = ret;
    
    for (int i = 0; i < realLen; i++) {
        if (*b == ' ') {
            b += 2;
        }
        *r = *b;
        r++;
        b++;
    }
    *r = '\0';
    return ret;
}

// Thanks https://stackoverflow.com/a/7918955
double absoluteCurrentTime() {
    struct timeval t;
    gettimeofday(&t, NULL);
    return (1.0e-6 * t.tv_usec) + t.tv_sec;
}

int main(int argc, const char *argv[]) {
    const char *argOne = argv[1];
    const char *argTwo = argv[2];
    unsigned long long possibilities = 0;
    long numberOfThreads = 0;
    
    if (argOne) {
        long long check = atoll(argOne);
        if (check < 0) {
            puts("possibilities can not be a negative number");
            return 1;
        }
        possibilities = check;
    }
    
    if (argTwo) {
        long check = atol(argTwo);
        if (check < 0) {
            puts("threads can not be a negative number");
            return 1;
        }
        numberOfThreads = check;
    }
    
    // if the numberOfThreads arg was not provided, set it to the number of device cores
    if (!numberOfThreads) {
        // Thanks https://stackoverflow.com/a/4586471
        numberOfThreads = sysconf(_SC_NPROCESSORS_ONLN);
    }
    
    if ((argc > 3) || !possibilities) {
        printf("Usage: %s <possibilities> [threads]\n"
               "    'threads' defaults to the amount of machine cores\n", argv[0]);
        return 1;
    }
    
    // calculate how much to count on each thread
    unsigned long long execPer = possibilities/numberOfThreads;
    
    // store the current time to calculate later
    double startTime = absoluteCurrentTime();
    
    // create an array of threadIDs with the amount of threads to use
    pthread_t threads[numberOfThreads];
    
    // kick off the amount of threads specified
    for (unsigned int thread = 0; thread < numberOfThreads; thread++) {
        pthread_create(&threads[thread], NULL, (void *)eachCountTo, &execPer);
    }
    
    // fix any remainders caused by the original mod operation
    // executed on main thread while background threads are potentially still running
    unsigned long long fixMod = execPer*numberOfThreads;
    while (fixMod < possibilities) {
        fixMod++;
    }
    
    // go through each of the threads and wait until they are finished
    for (unsigned int thread = 0; thread < numberOfThreads; thread++) {
        pthread_join(threads[thread], NULL);
    }
    
    // store the time after all counting operations have finished
    double endTime = absoluteCurrentTime();
    
    // this timing mechanism has been tested extensively using radare2 (?t !crackit <number>) and is reliable
    double totalTime = endTime-startTime;
    
    printf("Count to:  %s\n"
           "Threads:   %ld\n"
           "Millisecs: %f\n"
           "Seconds:   %f\n"
           "Per sec:   %s\n",
           formatllu(fixMod),
           numberOfThreads,
           totalTime*1000,
           totalTime,
           formatDouble(fixMod/totalTime));
    
    return 0;
}
