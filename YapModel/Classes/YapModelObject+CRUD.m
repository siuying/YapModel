//
//  YapModelObject+CRUD.m
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapModelObject+CRUD.h"
#import "YapModelManager.h"
#import "YapDatabaseSecondaryIndexTransaction.h"

@implementation YapModelObject (CRUD)

#pragma mark - Default Transaction

+ (instancetype)find:(NSString *)key
{
    __block YapModelObject* object;
    YapDatabaseReadWriteTransaction* transaction = [YapModelManager transactionForCurrentThread];
    if (transaction) {
        object = [self find:key withTransaction:transaction];
    } else {
        [[[YapModelManager sharedManager] connection] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            object = [self find:key withTransaction:transaction];
        }];
    }
    return object;
}

+ (NSArray*)where:(BOOL (^)(id object))filter
{
    __block NSArray* objects;
    YapDatabaseReadWriteTransaction* transaction = [YapModelManager transactionForCurrentThread];
    if (transaction) {
        objects = [self where:filter withTransaction:transaction];
    } else {
        [[[YapModelManager sharedManager] connection] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            objects = [self where:filter withTransaction:transaction];
        }];
    }
    return objects;
}

+ (NSArray*)findWithKeys:(NSArray*)keys
{
    __block NSArray* objects;
    YapDatabaseReadWriteTransaction* transaction = [YapModelManager transactionForCurrentThread];
    if (transaction) {
        objects = [self findWithKeys:keys transaction:transaction];
    } else {
        [[[YapModelManager sharedManager] connection] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            objects = [self findWithKeys:keys transaction:transaction];
        }];
    }
    return objects;
}

+ (NSArray*)findWithIndex:(NSString*)indexName query:(YapDatabaseQuery*)query
{
    __block NSArray* objects;
    YapDatabaseReadWriteTransaction* transaction = [YapModelManager transactionForCurrentThread];
    if (transaction) {
        objects = [self findWithIndex:indexName query:query transaction:transaction];
    } else {
        [[[YapModelManager sharedManager] connection] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            objects = [self findWithIndex:indexName query:query transaction:transaction];
        }];
    }
    return objects;
}

- (void)save
{
    YapDatabaseReadWriteTransaction* transaction = [YapModelManager transactionForCurrentThread];
    if (transaction) {
        [self saveWithTransaction:transaction];
    } else {
        [[[YapModelManager sharedManager] connection] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [self saveWithTransaction:transaction];
        }];
    }
}

- (void)delete
{
    YapDatabaseReadWriteTransaction* transaction = [YapModelManager transactionForCurrentThread];
    if (transaction) {
        [self deleteWithTransaction:transaction];
    } else {
        [[[YapModelManager sharedManager] connection] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [self deleteWithTransaction:transaction];
        }];
    }
}

+ (void)deleteAll
{
    YapDatabaseReadWriteTransaction* transaction = [YapModelManager transactionForCurrentThread];
    if (transaction) {
        [self deleteAllWithTransaction:transaction];
    } else {
        [[[YapModelManager sharedManager] connection] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [self deleteAllWithTransaction:transaction];
        }];
    }
}

+ (instancetype)create
{
    __block YapModelObject* object;
    YapDatabaseReadWriteTransaction* transaction = [YapModelManager transactionForCurrentThread];
    if (transaction) {
        object = [self createWithTransaction:transaction];
    } else {
        [[[YapModelManager sharedManager] connection] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            object = [self createWithTransaction:transaction];
        }];
    }
    return object;
}

+ (instancetype)create:(NSDictionary *)attributes
{
    __block YapModelObject* object;
    YapDatabaseReadWriteTransaction* transaction = [YapModelManager transactionForCurrentThread];
    if (transaction) {
        object = [self create:attributes withTransaction:transaction];
    } else {
        [[[YapModelManager sharedManager] connection] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            object = [self create:attributes withTransaction:transaction];
        }];
    }
    return object;
}

- (void)update:(NSDictionary *)attributes
{
    YapDatabaseReadWriteTransaction* transaction = [YapModelManager transactionForCurrentThread];
    if (transaction) {
        [self update:attributes withTransaction:transaction];
    } else {
        [[[YapModelManager sharedManager] connection] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [self update:attributes withTransaction:transaction];
        }];
    }
}

+ (NSArray *)all
{
    __block NSArray* allObjects;
    YapDatabaseReadWriteTransaction* transaction = [YapModelManager transactionForCurrentThread];
    if (transaction) {
        allObjects = [self allWithTransaction:transaction];
    } else {
        [[[YapModelManager sharedManager] connection] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            allObjects = [self allWithTransaction:transaction];
        }];
    }
    return allObjects;
}

+ (NSUInteger)count
{
    __block NSUInteger count = 0;
    YapDatabaseReadWriteTransaction* transaction = [YapModelManager transactionForCurrentThread];
    if (transaction) {
        count = [self countWithTransaction:transaction];
    } else {
        [[[YapModelManager sharedManager] connection] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            count = [self countWithTransaction:transaction];
        }];
    }
    return count;
}

+ (NSUInteger)countWithIndex:(NSString*)index query:(YapDatabaseQuery*)query
{
    __block NSUInteger count = 0;
    YapDatabaseReadWriteTransaction* transaction = [YapModelManager transactionForCurrentThread];
    if (transaction) {
        [[transaction ext:index] getNumberOfRows:&count matchingQuery:query];
    } else {
        [[[YapModelManager sharedManager] connection] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            [[transaction ext:index] getNumberOfRows:&count matchingQuery:query];
        }];
    }
    return count;
}

#pragma mark - Custom Transaction

+ (instancetype)find:(NSString*)key withTransaction:(YapDatabaseReadTransaction*)transaction
{
    return [transaction objectForKey:key inCollection:[self collectionName]];
}

+ (NSArray*)findWithKeys:(NSArray*)keys transaction:(YapDatabaseReadTransaction*)transaction
{
    __block NSMutableArray* allObjects = [NSMutableArray array];
    [transaction enumerateKeysAndObjectsInCollection:[self collectionName] usingBlock:^(NSString *key, id object, BOOL *stop) {
        [allObjects addObject:object];
    } withFilter:^BOOL(NSString *key) {
        return [keys containsObject:key];
    }];
    return [allObjects copy];
}

+ (NSArray*)where:(BOOL (^)(id object))filter withTransaction:(YapDatabaseReadTransaction*)transaction
{
    __block NSMutableArray* allObjects = [NSMutableArray array];
    [transaction enumerateKeysAndObjectsInCollection:[self collectionName] usingBlock:^(NSString *key, id object, BOOL *stop) {
        [allObjects addObject:object];
    } withFilter:^BOOL(NSString *key) {
        id object = [transaction objectForKey:key inCollection:[self collectionName]];
        return filter(object);
    }];
    return [allObjects copy];
}

+ (NSArray*)findWithIndex:(NSString*)indexName query:(YapDatabaseQuery*)query transaction:(YapDatabaseReadTransaction*)transaction
{
    __block NSMutableArray* allObjects = [NSMutableArray array];
    [[transaction ext:indexName] enumerateKeysAndObjectsMatchingQuery:query usingBlock:^(NSString *collection, NSString *key, id object, BOOL *stop) {
        if ([collection isEqualToString:[self collectionName]]) {
            [allObjects addObject:object];
        }
    }];
    return [allObjects copy];
}

- (void)saveWithTransaction:(YapDatabaseReadWriteTransaction*)transaction
{
    if (!self.key) {
        self.key = [[NSUUID UUID] UUIDString];
    }
    [transaction setObject:self forKey:self.key inCollection:[[self class] collectionName]];
}

- (void)deleteWithTransaction:(YapDatabaseReadWriteTransaction*)transaction
{
    [transaction removeObjectForKey:self.key inCollection:[[self class] collectionName]];
}

+ (void)deleteAllWithTransaction:(YapDatabaseReadWriteTransaction*)transaction
{
    [transaction removeAllObjectsInCollection:[self collectionName]];
}

+ (instancetype)createWithTransaction:(YapDatabaseReadWriteTransaction*)transaction
{
    return [self create:@{} withTransaction:transaction];
}

+ (instancetype)create:(NSDictionary *)attributes withTransaction:(YapDatabaseReadWriteTransaction*)transaction
{
    YapModelObject* model = [[self alloc] init];
    model.key = [[NSUUID UUID] UUIDString];
    [attributes enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL *stop) {
        [model setValue:obj forKey:key];
    }];
    [transaction setObject:model forKey:model.key inCollection:[self collectionName]];
    return model;
}

- (void)update:(NSDictionary *)attributes withTransaction:(YapDatabaseReadWriteTransaction*)transaction
{
    [attributes enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
    [transaction setObject:self forKey:self.key inCollection:[[self class] collectionName]];
}

+ (NSArray *)allWithTransaction:(YapDatabaseReadTransaction*)transaction
{
    NSMutableArray* allObjects = [NSMutableArray array];
    [transaction enumerateKeysAndObjectsInCollection:[self collectionName] usingBlock:^(NSString *key, id object, BOOL *stop) {
        [allObjects addObject:object];
    }];
    return [allObjects copy];
}

+ (NSUInteger)countWithTransaction:(YapDatabaseReadTransaction*)transaction
{
    return [transaction numberOfKeysInCollection:[self collectionName]];
}

+ (NSUInteger)countWithIndex:(NSString*)index query:(YapDatabaseQuery*)query transaction:(YapDatabaseReadTransaction*)transaction
{
    NSUInteger count;
    [[transaction ext:index] getNumberOfRows:&count matchingQuery:query];
    return count;
}

@end
