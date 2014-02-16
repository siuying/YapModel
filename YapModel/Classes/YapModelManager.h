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

+ (instancetype)sharedManager;

+ (void)setSharedManager:(YapModelManager*)sharedManager;

+ (YapDatabaseReadWriteTransaction*)transactionForCurrentThread;

+ (void)setTransactionForCurrentThread:(YapDatabaseReadWriteTransaction*)transaction;

- (YapDatabaseConnection*) connection;

- (void) setDatabase:(YapDatabase *)database;

- (YapDatabase*) database;

- (NSString*) sqliteStorePath;

@end
