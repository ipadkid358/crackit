#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        unsigned long possibilities = [NSString stringWithFormat:@"%s", argv[1]].longLongValue;
        __block int numberOfThreads = [NSString stringWithFormat:@"%s", argv[2]].intValue;
        
        if (argv[3] || !(possibilities && numberOfThreads)) {
            printf("Usage: %s <possibilities> <threads>\n", argv[0]);
            return 0;
        }
        
        double timeMulti = 100000;
        unsigned long execPer = possibilities/numberOfThreads;
        __block CFRunLoopRef runLoop = CFRunLoopGetCurrent();
        __block int numberOfExecutions = 0;
        NSUInteger startTime = llrint(NSDate.date.timeIntervalSince1970 * timeMulti);
        
        for (int increment = 0; increment < numberOfThreads; increment++) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                unsigned long counter = 0;
                while (counter < execPer) counter++;
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    numberOfExecutions++;
                    if (numberOfExecutions == numberOfThreads) CFRunLoopStop(runLoop);
                });
                
            });
        }
        CFRunLoopRun();
        
        unsigned long fixMod = execPer*numberOfThreads;
        while (fixMod < possibilities) fixMod++;
        NSUInteger endTime = llrint(NSDate.date.timeIntervalSince1970 * timeMulti);
        
        NSString *formatNumber = [NSString stringWithFormat:@"%lu", fixMod];
        NSUInteger numLength = formatNumber.length;
        NSUInteger firstDigits = numLength%3;
        NSMutableString *spaced = NSMutableString.new;
        if (firstDigits) [spaced appendFormat:@" %@", [formatNumber substringToIndex:firstDigits]];
        formatNumber = [formatNumber substringFromIndex:firstDigits];
        while (numLength) {
            [spaced appendFormat:@" %@", [formatNumber substringToIndex:3]];
            formatNumber = [formatNumber substringFromIndex:3];
            numLength = formatNumber.length;
        }
        
        NSUInteger totalTime = endTime-startTime;
        printf("Finished adding from 0 to%s on %d threads in %f milliseconds (%f seconds)\n", spaced.UTF8String, numberOfThreads, totalTime/100.0, totalTime/timeMulti);
    }
    
    return 1;
}
