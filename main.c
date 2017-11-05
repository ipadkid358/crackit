#include <stdio.h>
#include "BJThreadedCounting.h"
#include <CoreFoundation/CoreFoundation.h>
#include <stdlib.h>

int main(int argc, const char *argv[]) {
    if (!argv[1]) {
        printf("Usage: %s <possibilities> [threads]\n\t'threads' defaults to the amount of machine cores\n", argv[0]);
        return 1;
    }
    unsigned int threads = 0;
    if (argv[2]) threads = atoi(argv[2]);
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    countOnThreads(atoi(argv[1]), threads, ^(CFTimeInterval seconds, unsigned long long check, unsigned int threads) {
        printf("Counted to %llu on %d threads in %f seconds\n", check, threads, seconds);
        CFRunLoopStop(runloop);
    });
    CFRunLoopRun();
    return 0;
}

