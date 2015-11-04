//
//  AsyncController.m
//
//  Created by Cody Dietz on 3/10/15.
//  Copyright (c) 2015 Atomicon Software. All rights reserved.
//

#import "AsyncController.h"

@implementation AsyncController {
@private
    NSMutableArray *_threads;
}

@synthesize serialQueue;
@synthesize serialQueueGroup;
@synthesize cancelled;

-(id)init{
    [NSException raise:@"Do Not Call Init" format:@"Use singleton method: [[AsyncController] sharedManager]"];
    return nil;
}

-(id)initHidden{
    if(self = [super init]){
        serialQueue = dispatch_queue_create("com.atomicon.serialqueue", DISPATCH_QUEUE_SERIAL);
        serialQueueGroup = dispatch_group_create();
        _threads = [NSMutableArray new];
    }
    return self;
}

+(id)sharedManager {
    static AsyncController *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] initHidden];
    });
    return sharedMyManager;
}

#pragma mark ASYNC METHODS

-(bool)isQueueEmpty{
    dispatch_group_t group = dispatch_group_create();

    dispatch_group_enter(group);
    dispatch_async(serialQueue, ^{
        dispatch_group_leave(group);
    });

    double maxWaitTime = 0.00000005 * NSEC_PER_SEC;
    BOOL isReady = dispatch_group_wait(group, (dispatch_time_t) maxWaitTime) == 0;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    });

    return isReady;
}

/**
* Cancels async queue - Removes all dispatched items from grand central dispatch.
*   Does not affect threads, only dispatched methods
*
* @param tab - Tab that will start its activities - Posts notification with tab number
*/
-(void)cancelQueue:(NSNumber *)tab{
    [NSThread sleepForTimeInterval:0.1];
    cancelled = YES;

    // Appends this to the end of the queue so that after clearing out the queue it can continue executing anything appended after this
    dispatch_group_async(serialQueueGroup, serialQueue, ^{
        cancelled = NO;
    });
}

@end
