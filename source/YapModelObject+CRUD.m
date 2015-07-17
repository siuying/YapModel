//
//  YapModelObject+CRUD.m
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapModelObject+CRUD.h"
#import <YapDatabase/YapDatabase.h>
#import <YapDatabase/YapDatabaseSecondaryIndexTransaction.h>

@implementation YapModelObject (CRUD)

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

+ (instancetype)findFirstWithIndex:(NSString*)indexName query:(YapDatabaseQuery*)query transaction:(YapDatabaseReadTransaction*)transaction
{
    __block YapModelObject* firstObject = nil;
    [[transaction ext:indexName] enumerateKeysAndObjectsMatchingQuery:query usingBlock:^(NSString *collection, NSString *key, id object, BOOL *stop) {
        if ([collection isEqualToString:[self collectionName]]) {
            firstObject = object;
            *stop = YES;
        }
    }];
    return firstObject;
}

- (void)saveWithTransaction:(YapDatabaseReadWriteTransaction*)transaction
{
    [self saveWithTransaction:transaction keepMetadata:YES];
}

- (void)saveWithTransaction:(YapDatabaseReadWriteTransaction*)transaction keepMetadata:(BOOL)keepMetadata
{
    if (!self.key) {
        self.key = [[NSUUID UUID] UUIDString];
    }
    if(keepMetadata)
    {
        id metadata = nil;
        [transaction getObject:NULL metadata:&metadata forKey:self.key inCollection:[[self class] collectionName]];
        [transaction setObject:self forKey:self.key inCollection:[[self class] collectionName] withMetadata:metadata];
    }
    else
    {
        [transaction setObject:self forKey:self.key inCollection:[[self class] collectionName]];
    }
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
    [self update:attributes withTransaction:transaction keepMetadata:YES];
}

- (void)update:(NSDictionary *)attributes withTransaction:(YapDatabaseReadWriteTransaction*)transaction keepMetadata:(BOOL)keepMetadata
{
    [attributes enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
    
    if(keepMetadata)
    {
        id metadata = nil;
        [transaction getObject:NULL metadata:&metadata forKey:self.key inCollection:[[self class] collectionName]];
        [transaction setObject:self forKey:self.key inCollection:[[self class] collectionName]];
    }
    else
    {
        [transaction setObject:self forKey:self.key inCollection:[[self class] collectionName]];
    }
    
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
