//
//  AsyncController.h
//
//  Created by Cody Dietz on 3/10/15.
//  Copyright (c) 2015 Atomicon Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BluetoothController;

@interface AsyncController : NSObject

// Init methods
+(id)sharedManager;

// Async methods
-(void)cancelQueue:(NSNumber *)tab;

-(bool)isQueueEmpty;

@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) dispatch_group_t serialQueueGroup;
@property (readwrite) bool cancelled;

@end
