//
//  main.m
//  crackit
//
//  Created by ipad_kid on 8/12/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        unsigned long possibilities = [NSString stringWithFormat:@"%s", argv[1]].longLongValue;
        __block int numberOfThreads = [NSString stringWithFormat:@"%s", argv[2]].intValue;
        
        if (argv[3] || !(possibilities && numberOfThreads)) {
            printf("Usage: %s <possibilities> <threads>\n", argv[0]);
            exit(-1);
        }
        
        double timeMulti = 100000;
        unsigned long execPer = possibilities/numberOfThreads;
        __block CFRunLoopRef runLoop = CFRunLoopGetCurrent();
        __block int numberOfExecutions = 0;
        
        NSUInteger startTime = llrint([NSDate.date timeIntervalSince1970] * timeMulti);
        
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
        
        NSUInteger endTime = llrint([NSDate.date timeIntervalSince1970] * timeMulti);
        NSUInteger totalTime = endTime-startTime;
        printf("Finished adding from 0 to %lu on %d threads in %f milliseconds (%f seconds)\n",
               execPer*numberOfThreads, numberOfThreads, totalTime/100.0, totalTime/timeMulti);
    }
    
    return 0;
}
