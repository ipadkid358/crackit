#include <stdio.h>
#include <stdlib.h>
#include "BJThreadedCounting.h"

int main(int argc, const char *argv[]) {
    const char *argOne = argv[1];
    if (!argOne) {
        printf("Usage: %s <possibilities> [threads]\n\t'threads' defaults to the amount of machine cores\n", argv[0]);
        return 1;
    }
    
    unsigned int threads = 0;
    const char *argTwo = argv[2];
    if (argTwo) {
        int holdTwo = atoi(argTwo);
        if (holdTwo > 0) threads = holdTwo;
        else {
            printf("threads must be a positive number\n");
            return 1;
        }
    }
    
    long long holdOne = atoll(argOne);
    if (holdOne < 0) {
        printf("possibilities must be a positive number\n");
        return 1;
    }
    
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    countOnThreads(holdOne, threads, ^(CFTimeInterval seconds, unsigned long long check, unsigned int threads) {
        char checkChar[32];
        sprintf(checkChar, "%llu", check);
        char checkFix[32];
        
        char offset = strlen(checkChar)%3;
        unsigned int incChar = 0;
        unsigned int incFix = 0;
        char chr;
        while ((chr = checkChar[incChar])) {
            if ((incChar%3 == offset) && incChar) {
                checkFix[incFix] = ',';
                incFix++;
            }
            
            checkFix[incFix] = chr;
            
            incFix++;
            incChar++;
        }
        printf("Counted to %s on %d threads in %f seconds\n", checkFix, threads, seconds);
        CFRunLoopStop(runloop);
    });
    CFRunLoopRun();
    return 0;
}
