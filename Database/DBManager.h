//
//  DBManager.h
//
//  Created by Cody Dietz on 2/10/15.
//  Copyright (c) 2015 Atomicon Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SqlView.h"
#import "SqlPreConfig.h"

@interface DBManager : NSObject

@property (nonatomic, strong) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename;
-(void)copyDatabaseIntoDocumentsDirectory;
-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable;
-(NSArray *)loadDataFromDB:(NSString *)query;
-(void)executeQuery:(NSString *)query;

@end
