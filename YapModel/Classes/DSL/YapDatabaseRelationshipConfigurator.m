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

NSArray* _yapDatabaseRelationshipEdgesWithConfiguration(id self, SEL cmd) {
    return [YapDatabaseRelationshipConfigurator edgesWithInstance:self];
}

@implementation YapDatabaseRelationshipConfigurator

+(void) initialize
{
    _configuration = [NSMutableDictionary dictionary];
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
        
        // implement YapDatabaseRelationshipNode protocol and replace default implementation with _yapDatabaseRelationshipEdgesWithConfiguration
        class_addProtocol(class, @protocol(YapDatabaseRelationshipNode));
        class_replaceMethod(class, @selector(yapDatabaseRelationshipEdges), (IMP)_yapDatabaseRelationshipEdgesWithConfiguration, "@@:");
    }];
}

+(void) configureHasManyRelationshipWithClassName:(NSString*)className
                                         edgeName:(NSString*)edgeName
                                         childKey:(NSString*)childKey
                                  nodeDeleteRules:(NSNumber*)nodeDeleteRules
{
    NSMutableDictionary* config = [self _configurationWithClassName:className];
    config[childKey] = @{@"type": @"has_many", @"key": childKey, @"rule": nodeDeleteRules, @"edge": edgeName ?: childKey};
}

+(void) configureHasOneRelationshipWithClassName:(NSString*)className
                                        edgeName:(NSString*)edgeName
                                        childKey:(NSString*)childKey
                                 nodeDeleteRules:(NSNumber*)nodeDeleteRules
{
    NSMutableDictionary* config = [self _configurationWithClassName:className];
    config[childKey] = @{@"type": @"has_one", @"key": childKey, @"rule": nodeDeleteRules, @"edge": edgeName ?: childKey};
}

+(void) configureBelongsToRelationshipWithClassName:(NSString*)className
                                           edgeName:(NSString*)edgeName
                                          parentKey:(NSString*)parentKey
                                    nodeDeleteRules:(NSNumber*)nodeDeleteRules
{
    NSMutableDictionary* config = [self _configurationWithClassName:className];
    config[parentKey] = @{@"type": @"belongs_to", @"key": parentKey, @"rule": nodeDeleteRules, @"edge": edgeName ?: parentKey};
}


+(void) configureHasOneFileRelationshipWithClassName:(NSString*)className
                                            edgeName:(NSString*)edgeName
                                         filePathKey:(NSString*)filePathKey
                                     nodeDeleteRules:(NSNumber*)nodeDeleteRules
{
    NSMutableDictionary* config = [self _configurationWithClassName:className];
    config[filePathKey] = @{@"type": @"has_one_file", @"key": filePathKey, @"rule": nodeDeleteRules, @"edge": edgeName ?: filePathKey};
}

+(NSArray*) edgesWithInstance:(id)instance
{
    NSString* className = NSStringFromClass([instance class]);
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
