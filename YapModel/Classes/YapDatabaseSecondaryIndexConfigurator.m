//
//  YapDatabaseSecondaryIndexConfigurator.m
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapDatabaseSecondaryIndexConfigurator.h"
#import "YapDatabaseSecondaryIndex.h"
#import "YapDatabaseSecondaryIndex+Creation.h"
#import "YapDatabase.h"

static NSMutableDictionary* _indices;

@implementation YapDatabaseSecondaryIndexConfigurator

+(void) initialize
{
    _indices = [NSMutableDictionary dictionary];
}

+(void) configureWithDatabase:(YapDatabase*)database
{
    NSAssert(_indices, @"_indices should not be nil");

    [_indices enumerateKeysAndObjectsUsingBlock:^(NSString* className, NSDictionary* settings, BOOL *stop) {
        [settings enumerateKeysAndObjectsUsingBlock:^(NSString* indexName, NSDictionary* selectors, BOOL *stop) {
            YapDatabaseSecondaryIndex* index = [YapDatabaseSecondaryIndex indexWithClass:NSClassFromString(className)
                                                                              properties:selectors];
            if (![database registerExtension:index withName:indexName]) {
                [NSException raise:@"error registering extension: index name = %@" format:indexName, nil];
            }
        }];
    }];
}

+(void) registerIndexWithClass:(Class)clazz
                     indexName:(NSString*)indexName
                     selectors:(NSDictionary*)selectors
{
    NSMutableDictionary* settings = [self _indicesWithClass:clazz];
    settings[indexName] = selectors;
}

+(void) registerIndexWithClass:(Class)clazz
                     indexName:(NSString*)indexName
                          type:(YapDatabaseSecondaryIndexType)type
                     selectors:(NSArray*)selectors
{
    NSMutableDictionary* settings = [self _indicesWithClass:clazz];
    NSMutableDictionary* selectorsDict = [NSMutableDictionary dictionary];
    [selectors enumerateObjectsUsingBlock:^(NSString* name, NSUInteger idx, BOOL *stop) {
        [selectorsDict setObject:@(type) forKey:name];
    }];
    settings[indexName] = selectorsDict;
}

+(NSDictionary*) indicesWithClass:(Class)clazz
{
    return [self _indicesWithClass:clazz];
}

#pragma mark - Private

+(NSMutableDictionary*) _indicesWithClass:(Class)clazz
{
    NSAssert(_indices, @"_indices should not be nil");
    NSMutableDictionary* settings = _indices[NSStringFromClass(clazz)];
    if (!settings) {
        settings = [NSMutableDictionary dictionary];
        _indices[NSStringFromClass(clazz)] = settings;
    }
    return settings;
}

@end
