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

+(void) configureWithDatabase:(YapDatabase*)database
{
    [_indices enumerateKeysAndObjectsUsingBlock:^(NSString* className, NSDictionary* settings, BOOL *stop) {
        [settings enumerateKeysAndObjectsUsingBlock:^(NSString* indexName, NSArray* selectors, BOOL *stop) {
            YapDatabaseSecondaryIndex* index = [YapDatabaseSecondaryIndex indexWithClass:NSClassFromString(className)
                                                                              properties:selectors];
            if (![database registerExtension:index withName:indexName]) {
                [NSException raise:@"error registering extension: index name = %@" format:indexName, nil];
            }
        }];
    }];
}

+(BOOL) registerIndexWithClass:(Class)clazz
                     indexName:(NSString*)indexName
                     selectors:(NSArray*)selectors
{
    NSMutableDictionary* settings = _indices[NSStringFromClass(clazz)];
    if (!settings) {
        settings = [NSMutableDictionary dictionary];
        _indices[NSStringFromClass(clazz)] = settings;
    }
    settings[indexName] = selectors;
    return YES;
}

#pragma mark - private

+(void) initialize
{
    _indices = [NSMutableDictionary dictionary];
}

@end
