#include "BJThreadedCounting.h"

void countOnThreads(const unsigned long long max, unsigned int threads, void (^_Nullable completion)(CFTimeInterval seconds, unsigned long long check, unsigned int threads)) {
    // if threads is 0, set it to number of cores
    if (!threads) {
        size_t len = sizeof(threads);
        sysctlbyname("hw.ncpu", &threads, &len, NULL, 0);
    }
    // calculate how much to count up to on each thread
    unsigned const long long execPer = max/threads;
    // __block indicates the variable will be written to from inside a block
    __block int numberOfExecutions = 0;
    // mark the time we start counting
    CFAbsoluteTime const startTime = CFAbsoluteTimeGetCurrent();
    for (int increment = 0; increment < threads; increment++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            // counting on different threads
            unsigned long long counter = 0;
            // be advised, clang (and maybe GCC) optimizes this out. Use -O0
            while (counter < execPer) counter++;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // back on the main thread, check how many times a new thread has been dispatched
                numberOfExecutions++;
                // when all the threads we had wanted to spin off are done, we go into this body
                if (numberOfExecutions == threads) {
                    // if max/threads doesn't break evenly, we need to fix it, to count everyone
                    unsigned long long fixMod = execPer*threads;
                    while (fixMod < max) fixMod++;
                    // and that concludes the counting, end time
                    CFAbsoluteTime const endTime = CFAbsoluteTimeGetCurrent();
                    // for the most accurate time possible, time is calulcated afterwards
                    completion(endTime-startTime, fixMod, threads);
                }
            });
        });
    }
}

