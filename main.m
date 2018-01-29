#import <Foundation/Foundation.h>
#include <sys/sysctl.h>

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        const char *argOne = argv[1];
        const char *argTwo = argv[2];
        unsigned long long possibilities = 0;
        unsigned int numberOfThreads = 0;
        
        if (argOne) {
            possibilities = [[NSString stringWithUTF8String:argOne] longLongValue];
        }
        
        if (argTwo) {
            numberOfThreads = [[NSString stringWithUTF8String:argTwo] intValue];
        }
        
        if (!numberOfThreads) {
            size_t len = sizeof(numberOfThreads);
            sysctlbyname("hw.ncpu", &numberOfThreads, &len, NULL, 0);
        }
        
        if ((argc > 3) || !possibilities) {
            printf("Usage: %s <possibilities> [threads]\n"
                   "    'threads' defaults to the amount of machine cores\n", argv[0]);
            return 0;
        }
        
        unsigned long long execPer = possibilities/numberOfThreads;
        __block int numberOfExecutions = 0;
        CFRunLoopRef runLoop = CFRunLoopGetCurrent();
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        for (int increment = 0; increment < numberOfThreads; increment++) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                volatile unsigned long long counter = 0;
                while (counter < execPer) {
                    counter++;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    numberOfExecutions++;
                    if (numberOfExecutions == numberOfThreads) {
                        CFRunLoopStop(runLoop);
                    }
                });
            });
        }
        CFRunLoopRun();
        
        unsigned long long fixMod = execPer*numberOfThreads;
        while (fixMod < possibilities) {
            fixMod++;
        }
        
        CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
        
        NSString *spaced = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithUnsignedLongLong:fixMod] numberStyle:NSNumberFormatterDecimalStyle];
        
        CFTimeInterval totalTime = endTime-startTime;
        printf("Finished counting from 0 to %s on %d threads in %f milliseconds (%f seconds)\n", spaced.UTF8String, numberOfThreads, totalTime*1000, totalTime);
    }
    
    return 1;
}
