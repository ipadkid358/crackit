#import <Foundation/Foundation.h>
#include <sys/sysctl.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        unsigned long long possibilities = [NSString stringWithFormat:@"%s", argv[1]].longLongValue;
        unsigned int numberOfThreads = [NSString stringWithFormat:@"%s", argv[2]].intValue;
        
        int argBreak = 3;
        if (!numberOfThreads) {
            size_t len = sizeof(numberOfThreads);
            sysctlbyname("hw.ncpu", &numberOfThreads, &len, NULL, 0);
            argBreak--;
        }
        
        if (argv[argBreak] || !(possibilities)) {
            printf("Usage: %s <possibilities> [threads]\n"
                   "    'threads' defaults to the amount of machine cores\n", argv[0]);
            return 0;
        }
        
        unsigned long long execPer = possibilities/numberOfThreads;
        __block int numberOfExecutions = 0;
        CFRunLoopRef runLoop = CFRunLoopGetCurrent();
        NSDate *startTime = NSDate.date;
        
        for (int increment = 0; increment < numberOfThreads; increment++) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                unsigned long long counter = 0;
                while (counter < execPer) counter++;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    numberOfExecutions++;
                    if (numberOfExecutions == numberOfThreads) CFRunLoopStop(runLoop);
                });
            });
        }
        CFRunLoopRun();
        
        unsigned long long fixMod = execPer*numberOfThreads;
        while (fixMod < possibilities) fixMod++;
        NSDate *endTime = NSDate.date;
        
        NSNumber *numInt = [NSNumber numberWithUnsignedLong:fixMod];
        NSString *spaced = [NSNumberFormatter localizedStringFromNumber:numInt numberStyle:NSNumberFormatterDecimalStyle];
        
        NSTimeInterval totalTime = [endTime timeIntervalSinceDate:startTime];
        printf("Finished counting from 0 to %s on %d threads in %f milliseconds (%f seconds)\n", spaced.UTF8String, numberOfThreads, totalTime*1000, totalTime);
    }
    
    return 1;
}
