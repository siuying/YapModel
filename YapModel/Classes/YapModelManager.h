//
//  YapDatabaseManager.h
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YapDatabase.h"

@interface YapModelManager : NSObject

@property (nonatomic, copy) NSString* databaseName;

@property (nonatomic, readwrite) YapDatabase* database;

@property (nonatomic, readonly) YapDatabaseConnection* connection;

+ (instancetype)sharedManager;

+ (YapDatabaseReadWriteTransaction*)transactionForCurrentThread;

+ (void)setTransactionForCurrentThread:(YapDatabaseReadWriteTransaction*)transaction;

- (NSString*) sqliteStorePath;

@end
