//
//  YapDatabaseViewConfigurator.m
//  YapModel
//
//  Created by Francis Chong on 8/22/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapDatabaseViewConfigurator.h"
#import "YapDatabaseView+Creation.h"
#import "YapDatabase.h"
#import "YapModelViewProvider.h"

static NSMutableDictionary* _viewsConfiguration;
static NSMutableArray* _viewsProviders;

NSString* const YapDatabaseViewConfiguratorGroupKey = @"group";
NSString* const YapDatabaseViewConfiguratorSortKey = @"sort";

@implementation YapDatabaseViewConfigurator

+(void) initialize
{
    _viewsConfiguration = [NSMutableDictionary dictionary];
    _viewsProviders = [NSMutableArray array];
}

+(NSDictionary*) viewsConfigurationWithClassName:(NSString*)className
{
    return [self _viewsConfigurationWithClassName:className];
}

+(void) configureViewWithClassName:(NSString*)targetClassName
                          viewName:(NSString*)viewName
                            params:(NSDictionary*)params
{
    NSMutableDictionary* settings = [self _viewsConfigurationWithClassName:targetClassName];
    settings[viewName] = params;
}

+(void) setupViewsWithDatabase:(YapDatabase*)database
{
    NSAssert(_viewsConfiguration, @"_viewsConfiguration should not be nil");
    
    [_viewsConfiguration enumerateKeysAndObjectsUsingBlock:^(NSString* className, NSDictionary* settings, BOOL *stop) {
        [settings enumerateKeysAndObjectsUsingBlock:^(NSString* viewName, NSDictionary* params, BOOL *stop) {
            id groupBy = params[YapDatabaseViewConfiguratorGroupKey];
            id sortBy = params[YapDatabaseViewConfiguratorSortKey];
            
            if (groupBy && [groupBy isKindOfClass:[NSString class]]) {
                groupBy = @[groupBy];
            }
            if (sortBy && [sortBy isKindOfClass:[NSString class]]) {
                sortBy = @[sortBy];
            }
            YapDatabaseView* view = [YapDatabaseView viewWithCollection:className groupByKeys:groupBy sortByKeys:sortBy];
            if (![database registerExtension:view withName:viewName]) {
                [NSException raise:@"error registering extension: view name = %@" format:viewName, nil];
            }
        }];
    }];
}

+(void) setupAdditionalViewsFromViewProvidersWithDatabase:(YapDatabase*)database
{
    [_viewsProviders enumerateObjectsUsingBlock:^(NSString * className, NSUInteger idx, BOOL *stop) {
        Class<YapModelViewProvider> generator = NSClassFromString(className);
        if([(id)generator respondsToSelector:@selector(registerViewsWithDatabase:)]) {
            [generator registerViewsWithDatabase:database];
        }
    }];
}


+(void) registerViewProviderWithClassName:(NSString*)className
{
    if(![_viewsProviders containsObject:className]) {
        [_viewsProviders addObject:className];
    }
}

#pragma mark - Private

+(NSMutableDictionary*) _viewsConfigurationWithClassName:(NSString*)className
{
    NSAssert(_viewsConfiguration, @"_viewsConfiguration should not be nil");
    NSMutableDictionary* settings = _viewsConfiguration[className];
    if (!settings) {
        settings = [NSMutableDictionary dictionary];
        _viewsConfiguration[className] = settings;
    }
    return settings;
}

@end
