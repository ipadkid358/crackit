#import <Foundation/Foundation.h>
#import <sys/sysctl.h>

#define fastNumberToChar(n) [[NSNumberFormatter localizedStringFromNumber:(n) numberStyle:NSNumberFormatterDecimalStyle] UTF8String]

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
        
        // if the numberOfThreads arg was not provided, set it to the number of device cores
        if (!numberOfThreads) {
            size_t len = sizeof(numberOfThreads);
            sysctlbyname("hw.ncpu", &numberOfThreads, &len, NULL, 0);
        }
        
        if ((argc > 3) || !possibilities) {
            printf("Usage: %s <possibilities> [threads]\n"
                   "    'threads' defaults to the amount of machine cores\n", argv[0]);
            return 1;
        }
        
        unsigned long long execPer = possibilities/numberOfThreads;
        __block int numberOfExecutions = 0;
        CFRunLoopRef runLoop = CFRunLoopGetCurrent();
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        for (int increment = 0; increment < numberOfThreads; increment++) {
            // for each numberOfThreads, kick off a new background thread
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                volatile unsigned long long counter = execPer;
                // this should be the lightest weight on the CPU
                while (counter) {
                    counter--;
                }
                
                // keep track of how many times this is finished on the main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    numberOfExecutions++;
                    // and when it's done, stop the runloop
                    if (numberOfExecutions == numberOfThreads) {
                        // once RunLoopStop is called, the code after RunLoopRun is executed
                        CFRunLoopStop(runLoop);
                    }
                });
            });
        }
        CFRunLoopRun();
        
        // fix any remainders caused by the original mod operation
        unsigned long long fixMod = execPer*numberOfThreads;
        while (fixMod < possibilities) {
            fixMod++;
        }
        
        // make sure that we get this time as soon as possible
        CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
        
        CFTimeInterval totalTime = endTime-startTime;
        
        printf("Count to:  %s\n"
               "Threads:   %d\n"
               "Millisecs: %f\n"
               "Seconds:   %f\n"
               "Per sec:   %s\n",
               fastNumberToChar([NSNumber numberWithUnsignedLongLong:fixMod]),
               numberOfThreads,
               totalTime*1000,
               totalTime,
               fastNumberToChar([NSNumber numberWithDouble:fixMod/totalTime]));
    }
    
    return 0;
}
