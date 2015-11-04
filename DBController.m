//
//  DBController.m
//  SetupTest
//
//  Created by Cody Dietz on 2/5/15.
//  Copyright (c) 2015 Atomicon Software. All rights reserved.
//

#import "DBController.h"
#import "AppDelegate.h"

@implementation DBController

@synthesize dbManager;
@synthesize database1;
@synthesize database2;
@synthesize shouldCopyDatabase;

#pragma mark INIT METHODS

-(id)init{
    [NSException raise:@"Do Not Call Init" format:@"Use singleton method: [[DBController] sharedManager]"];
    return nil;
}

-(id)initHidden{
    if (self = [super init]) {
        shouldCopyDatabase = YES;
        // Allocate DBManager objects with PreConfig and Internal Databases
        database1 = [[DBManager alloc] initWithDatabaseFilename:@"ex1" shouldCopy:shouldCopyDatabase];
        database2 = [[DBManager alloc] initWithDatabaseFilename:@"ex2" shouldCopy:shouldCopyDatabase];

        // Defaults to Database 1
        dbManager = database1;
    }
    
    return self;
}

/**
 Singelton dispatcher
 
 @return Singleton DBController object
 */
+(id)sharedManager {
    static DBController *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] initHidden];
    });
    return sharedMyManager;
}

#pragma mark DATABASE METHODS

/**
 Swap between PreConfig database and Internal database
 Contains example of swappping database
 
 @param database <#database description#>
 */
-(void)swapDatabase:(NSString *)database{
    dbManager = [database isEqualToString:@"db1"] ? database1 : database2;
}

/**
 Execute query from predicate
 
 @param predicate String containing select statement
 
 @return Array of returned objects
 */
-(NSArray *)selectFromDB:(NSString *)database withQuery:(NSString *)query{
    NSArray *returnArray;
    [self swapDatabase:database];

    returnArray = [dbManager loadDataFromDB:query];

    return returnArray;
}

/**
 Execute insert on database
 
 @param predicate String containing insert statement
 */
-(void)insertIntoDB:(NSString *)database withQuery:(NSString *)query{
    [self swapDatabase:database];

    [dbManager executeQuery:query];
}

// Example Methods for simplifying multiple database select/insert
-(NSArray *)selectFromEx1:(NSString *)query{
    return [[DBController sharedManager] selectFromDB:@"db1" withQuery:query];
}

-(void)insertIntoInternal:(NSString *)query{
    [self insertIntoDB:@"db1" withQuery:query];
}

// For the case of only one database
-(NSArray *)selectFromDB1:(NSString *)query{
    NSArray *returnArray = [dbManager loadDataFromDB:query];
    return returnArray;
}
-(void)insertIntoDB1:(NSString *)query{
    [dbManager executeQuery:query];
}

@end
