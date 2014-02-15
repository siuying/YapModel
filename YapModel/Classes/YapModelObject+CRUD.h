//
//  YapModelObject+CRUD.h
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapModelObject.h"

@interface YapModelObject (CRUD)

#pragma mark - Default Transaction

+ (instancetype)findWithKey:(NSString*)key;

+ (instancetype)find:(NSString*)key;

+ (NSArray*)findWithKeys:(NSArray*)keys;

+ (NSArray*)findWithFilter:(BOOL (^)(NSString *key))filter;

- (void)save;

- (void)delete;

+ (void)deleteAll;

+ (instancetype)create;

+ (instancetype)create:(NSDictionary *)attributes;

- (void)update:(NSDictionary *)attributes;

+ (NSArray *)all;

+ (NSUInteger)count;

#pragma mark - Custom Transaction

+ (instancetype)findWithKey:(NSString*)key transaction:(YapDatabaseReadTransaction*)transaction;

+ (instancetype)find:(NSString*)key withTransaction:(YapDatabaseReadTransaction*)transaction;

+ (NSArray*)findWithKeys:(NSArray*)keys transaction:(YapDatabaseReadTransaction*)transaction;

- (void)saveWithTransaction:(YapDatabaseReadWriteTransaction*)transaction;

- (void)deleteWithTransaction:(YapDatabaseReadWriteTransaction*)transaction;

+ (void)deleteAllWithTransaction:(YapDatabaseReadWriteTransaction*)transaction;

+ (instancetype)createWithTransaction:(YapDatabaseReadWriteTransaction*)transaction;

+ (instancetype)create:(NSDictionary *)attributes withTransaction:(YapDatabaseReadWriteTransaction*)transaction;

- (void)update:(NSDictionary *)attributes withTransaction:(YapDatabaseReadWriteTransaction*)transaction;

+ (NSArray *)allWithTransaction:(YapDatabaseReadTransaction*)transaction;

+ (NSUInteger)countWithTransaction:(YapDatabaseReadTransaction*)transaction;

@end
