//
//  DBController.h
//
//  Created by Cody Dietz on 2/5/15.
//  Copyright (c) 2015 Atomicon Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DataController.h"
#import "DataModel.h"
#import "DataSection.h"
#import "DataField.h"
#import "DBManager.h"
#import "SubmenuSection.h"
#import "SubmenuField.h"
#import "DriveModel.h"
#import "FEUtilities.h"


#define UINT32 1
#define INT32 2
#define INT8 3
#define FLOAT 4
#define UINT8 5

@interface DBController : NSObject

@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) DBManager *database1;
@property (nonatomic, strong) DBManager *database2;
@property (readwrite) BOOL shouldCopyDatabase;

+ (id)sharedManager;

- (NSArray *)selectFromDB:(NSString *)database withQuery:(NSString *)query;

- (void)insertIntoDB:(NSString *)database withQuery:(NSString *)query;

- (void)swapDatabase:(NSString *)database;

- (NSArray *)selectFromEx1:(NSString *)query;

- (void)insertIntoEx1:(NSString *)query;

- (NSArray *)selectFromDB1:(NSString *)query;

- (void)insertIntoDB1:(NSString *)query;

@end
