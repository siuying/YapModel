//
//  YapModelObject.h
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YapDatabase.h"

@interface YapModelObject : NSObject

@property (nonatomic, copy) NSString* key;

#pragma mark - Default Transaction

- (BOOL)save;

- (void)delete;

+ (void)deleteAll;

+ (id)create;

+ (id)create:(NSDictionary *)attributes;

- (void)update:(NSDictionary *)attributes;

+ (NSArray *)all;

+ (NSUInteger)count;

#pragma mark - Custom Transaction

- (BOOL)saveWithConnection:(YapDatabaseConnection*)connection;

- (void)deleteWithConnection:(YapDatabaseConnection*)connection;

+ (void)deleteAllWithConnection:(YapDatabaseConnection*)connection;

+ (id)createWithConnection:(YapDatabaseConnection*)connection;

+ (id)create:(NSDictionary *)attributes withConnection:(YapDatabaseConnection*)connection;

- (void)update:(NSDictionary *)attributes withConnection:(YapDatabaseConnection*)connection;

+ (NSArray *)allWithConnection:(YapDatabaseConnection*)connection;

+ (NSUInteger)countWithConnection:(YapDatabaseConnection*)connection;

@end
