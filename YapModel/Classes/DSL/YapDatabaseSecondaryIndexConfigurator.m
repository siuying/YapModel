//
//  YapDatabaseSecondaryIndexConfigurator.m
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <YapDatabase/YapDatabase.h>
#import <YapDatabase/YapDatabaseSecondaryIndex.h>

#import "YapDatabaseSecondaryIndexConfigurator.h"
#import "YapDatabaseSecondaryIndex+Creation.h"

static NSMutableDictionary* _indicesConfiguration;

@implementation YapDatabaseSecondaryIndexConfigurator

+(void) initialize
{
    _indicesConfiguration = [NSMutableDictionary dictionary];
}

+(void) setupIndicesWithDatabase:(YapDatabase*)database
{
    NSAssert(_indicesConfiguration, @"_indices should not be nil");

    [_indicesConfiguration enumerateKeysAndObjectsUsingBlock:^(NSString* className, NSDictionary* settings, BOOL *stop) {
        [settings enumerateKeysAndObjectsUsingBlock:^(NSString* indexName, NSDictionary* selectors, BOOL *stop) {
            YapDatabaseSecondaryIndex* index = [YapDatabaseSecondaryIndex indexWithClass:NSClassFromString(className)
                                                                              properties:selectors];
            if (![database registerExtension:index withName:indexName]) {
                [NSException raise:@"error registering extension: index name = %@" format:indexName, nil];
            }
        }];
    }];
}

+(void) configureIndexWithClassName:(NSString*)className
                     indexName:(NSString*)indexName
                     selectors:(NSDictionary*)selectors
{
    NSAssert(className, @"className cannot be nil");
    NSAssert(indexName, @"indexName cannot be nil");

    NSMutableDictionary* settings = [self _indicesConfigurationWithClassName:className];
    settings[indexName] = selectors;
}

+(void) configureIndexWithClassName:(NSString*)className
                     indexName:(NSString*)indexName
                          type:(YapDatabaseSecondaryIndexType)type
                     selectors:(NSArray*)selectors
{
    NSMutableDictionary* settings = [self _indicesConfigurationWithClassName:className];
    NSMutableDictionary* selectorsDict = [NSMutableDictionary dictionary];
    [selectors enumerateObjectsUsingBlock:^(NSString* name, NSUInteger idx, BOOL *stop) {
        [selectorsDict setObject:@(type) forKey:name];
    }];
    settings[indexName] = selectorsDict;
}

+(NSDictionary*) indicesConfigurationWithClassName:(NSString*)className
{
    return [self _indicesConfigurationWithClassName:className];
}

#pragma mark - Private

+(NSMutableDictionary*) _indicesConfigurationWithClassName:(NSString*)className
{
    NSAssert(_indicesConfiguration, @"_indices should not be nil");
    NSAssert(className, @"className cannot be nil");

    NSMutableDictionary* settings = _indicesConfiguration[className];
    if (!settings) {
        settings = [NSMutableDictionary dictionary];
        _indicesConfiguration[className] = settings;
    }
    return settings;
}

@end
