//
//  YapDatabaseRelationConfigurator.m
//  YapModel
//
//  Created by Francis Chong on 8/22/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapDatabaseRelationshipConfigurator.h"
#import "YapDatabaseRelationshipEdge.h"
#import "YapDatabaseRelationship.h"
#import "YapDatabase.h"
#import <objc/runtime.h>

static NSMutableDictionary* _configuration;

@implementation YapDatabaseRelationshipConfigurator

+(void) initialize
{
    _configuration = [NSMutableDictionary dictionary];
}

+(NSDictionary*) relationshipConfigurationWithClassName:(NSString*)className
{
    return [self _configurationWithClassName:className];
}

+(BOOL) hasRelationshipConfigurationWithClassName:(NSString*)className
{
    NSAssert(_configuration, @"_configuration should not be nil");
    return _configuration[className] != nil;
}

+(void) setupViewsWithDatabase:(YapDatabase*)database
{
    NSAssert(_configuration, @"_configuration should not be nil");
    if ([[[database registeredExtensions] allKeys] containsObject:@"relationship"]) {
        [database registerExtension:[[YapDatabaseRelationship alloc] init] withName:@"relationship"];
    }
    
    [_configuration enumerateKeysAndObjectsUsingBlock:^(NSString* className, NSDictionary* settings, BOOL *stop) {
        Class class = NSClassFromString(className);
        NSAssert(class, @"class should not be nil");
        class_addProtocol(class, @protocol(YapDatabaseRelationshipNode));
    }];
}

+(void) configureHasManyRelationshipWithClassName:(NSString*)className
                                         edgeName:(NSString*)edgeName
                                         childKey:(NSString*)childKey
                                  nodeDeleteRules:(YDB_NodeDeleteRules)nodeDeleteRules
{
    NSMutableDictionary* config = [self _configurationWithClassName:className];
    config[edgeName] = @{@"type": @"has_many", @"key": childKey, @"rule": @(nodeDeleteRules), @"edge": edgeName ?: childKey};
}

+(void) configureHasOneRelationshipWithClassName:(NSString*)className
                                        edgeName:(NSString*)edgeName
                                        childKey:(NSString*)childKey
                                 nodeDeleteRules:(YDB_NodeDeleteRules)nodeDeleteRules
{
    NSMutableDictionary* config = [self _configurationWithClassName:className];
    config[edgeName] = @{@"type": @"has_one", @"key": childKey, @"rule": @(nodeDeleteRules), @"edge": edgeName ?: childKey};
}

+(void) configureBelongsToRelationshipWithClassName:(NSString*)className
                                           edgeName:(NSString*)edgeName
                                          parentKey:(NSString*)parentKey
                                    nodeDeleteRules:(YDB_NodeDeleteRules)nodeDeleteRules
{
    NSMutableDictionary* config = [self _configurationWithClassName:className];
    config[edgeName] = @{@"type": @"belongs_to", @"key": parentKey, @"rule": @(nodeDeleteRules), @"edge": edgeName ?: parentKey};
}


+(void) configureHasOneFileRelationshipWithClassName:(NSString*)className
                                            edgeName:(NSString*)edgeName
                                         filePathKey:(NSString*)filePathKey
                                     nodeDeleteRules:(YDB_NodeDeleteRules)nodeDeleteRules
{
    NSMutableDictionary* config = [self _configurationWithClassName:className];
    config[edgeName] = @{@"type": @"has_one_file", @"key": filePathKey, @"rule": @(nodeDeleteRules), @"edge": edgeName ?: filePathKey};
}

+(NSArray*) edgesWithInstance:(id)instance
{
    NSString* className = NSStringFromClass([instance class]);
    if (![self hasRelationshipConfigurationWithClassName:className]) {
        return nil;
    }

    NSDictionary* config = [self _configurationWithClassName:className];
    NSMutableArray* edges = [NSMutableArray array];
    [config enumerateKeysAndObjectsUsingBlock:^(NSString* k, NSDictionary* setting, BOOL *stop) {
        NSString* type = setting[@"type"];
        NSString* edgeName = setting[@"edge"];
        NSString* keyName = setting[@"key"];
        NSNumber* rule = setting[@"rule"];

        if ([type isEqualToString:@"has_many"]) {
            NSArray* childKeys = [instance valueForKey:keyName];
            if (childKeys) {
                if (![childKeys isKindOfClass:[NSArray class]]) {
                    [NSException raise:NSInternalInconsistencyException format:@"the key (%@) is not an array", keyName];
                }
                
                for (NSString *childKey in childKeys) {
                    YapDatabaseRelationshipEdge *edge = [YapDatabaseRelationshipEdge edgeWithName:edgeName
                                                                                   destinationKey:childKey
                                                                                       collection:nil
                                                                                  nodeDeleteRules:rule.integerValue];
                    
                    [edges addObject:edge];
                }
            }
        }
        
        if ([type isEqualToString:@"has_one"]) {
            NSString* childKey = [instance valueForKey:keyName];
            if (childKey) {
                if (![childKey isKindOfClass:[NSString class]]) {
                    [NSException raise:NSInternalInconsistencyException format:@"the key (%@) is not a key", keyName];
                }
                
                YapDatabaseRelationshipEdge *edge = [YapDatabaseRelationshipEdge edgeWithName:edgeName
                                                                               destinationKey:childKey
                                                                                   collection:nil
                                                                              nodeDeleteRules:rule.integerValue];
                
                [edges addObject:edge];
            }
        }
        
        if ([type isEqualToString:@"belongs_to"]) {
            NSString* parentKey = [instance valueForKey:keyName];
            if (parentKey) {
                if (![parentKey isKindOfClass:[NSString class]]) {
                    [NSException raise:NSInternalInconsistencyException format:@"the key (%@) is not a key", keyName];
                }
                
                YapDatabaseRelationshipEdge *edge = [YapDatabaseRelationshipEdge edgeWithName:edgeName
                                                                               destinationKey:parentKey
                                                                                   collection:nil
                                                                              nodeDeleteRules:rule.integerValue];
                [edges addObject:edge];
            }
        }
        
        if ([type isEqualToString:@"has_one_file"]) {
            NSString* file = [instance valueForKey:keyName];
            if (file) {
                if (![file isKindOfClass:[NSString class]]) {
                    [NSException raise:NSInternalInconsistencyException format:@"the file (%@) is not string", file];
                }

                YapDatabaseRelationshipEdge *edge = [YapDatabaseRelationshipEdge edgeWithName:edgeName
                                                                          destinationFilePath:file
                                                                              nodeDeleteRules:rule.integerValue];

                [edges addObject:edge];
            }
        }

    }];

    if ([config count] == 0) {
        return nil;
    }

    return edges;
}

#pragma mark - Private

+(NSMutableDictionary*) _configurationWithClassName:(NSString*)className
{
    NSAssert(_configuration, @"_configuration should not be nil");
    NSMutableDictionary* settings = _configuration[className];
    if (!settings) {
        settings = [NSMutableDictionary dictionary];
        _configuration[className] = settings;
    }
    return settings;
}
@end
