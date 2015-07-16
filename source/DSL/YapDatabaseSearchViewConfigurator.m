//
//  YapDatabaseSearchViewConfigurator.m
//  YapModel
//
//  Created by Aleksei Shevchenko on 6/24/15.
//  Copyright (c) 2014 Aleksei Shevchenko. All rights reserved.
//

#import "YapDatabaseSearchViewConfigurator.h"
#import "YapDatabaseView+Creation.h"
#import "YapDatabase.h"
#import "YapModelViewProvider.h"
#import "YapDatabaseFullTextSearch.h"
#import "YapDatabaseSearchResultsView.h"

static NSMutableDictionary* _viewsConfiguration;
static NSMutableDictionary* _searchHandlerData;

NSString* const YapDatabaseFullTextSearchExtensionName = @"fts";

@implementation YapDatabaseSearchViewConfigurator

+(void) initialize
{
    _viewsConfiguration = [NSMutableDictionary dictionary];
    _searchHandlerData = [NSMutableDictionary dictionary];  // class:array
}

+(NSDictionary*) viewsConfigurationWithClassName:(NSString*)className
{
    return [self _viewsConfigurationWithClassName:className];
}

+(void) configureViewWithClassName:(NSString*)className
                          viewName:(NSString*)viewName
                            params:(NSDictionary*)params
{
    NSMutableDictionary* settings = [self _viewsConfigurationWithClassName:className];
    settings[viewName] = params;
    
    NSMutableArray * searchableProperties = [self _searchHandlerDataWithClassName:className];
    [searchableProperties addObjectsFromArray:params[@"properties"]];
}

+(void) setupViewsWithDatabase:(YapDatabase*)database
{
    NSAssert(_viewsConfiguration, @"_viewsConfiguration should not be nil");
    NSAssert(_searchHandlerData, @"_searchHandlerData should not be nil");
    
    //first configure fts extension
    YapDatabaseFullTextSearchHandler * handler = [YapDatabaseFullTextSearchHandler withObjectBlock:^(NSMutableDictionary *dict, NSString *collection, NSString *key, id object){
        
        NSString * className = NSStringFromClass([object class]);
        
        NSArray * properties = _searchHandlerData[className];
        if(!properties) return;
        
        [properties enumerateObjectsUsingBlock:^(NSString* property, NSUInteger idx, BOOL *stop) {
            id value = [object valueForKey:property];
            if(value) [dict setObject:value forKey:property];
            else [dict removeObjectForKey:property];
        }];
    }];
    
    NSMutableArray * searchableProperties = [NSMutableArray array];
    [_searchHandlerData enumerateKeysAndObjectsUsingBlock:^(id key, NSArray *properties, BOOL *stop) {
        [searchableProperties addObjectsFromArray:properties];
    }];
    
    YapDatabaseFullTextSearch *fts = [[YapDatabaseFullTextSearch alloc] initWithColumnNames:searchableProperties handler:handler];
    
    if (![database registerExtension:fts withName:YapDatabaseFullTextSearchExtensionName])
    {
        [NSException raise:@"error registering full text extension" format:nil];
    }
    
    
    
    //now create actual views and register them
    [_viewsConfiguration enumerateKeysAndObjectsUsingBlock:^(NSString* className, NSDictionary* settings, BOOL *stop) {
        
        [settings enumerateKeysAndObjectsUsingBlock:^(NSString* viewName, NSDictionary* params, BOOL *stop)
         {
             NSString * parentViewName = params[@"parent"];
             NSArray * searchableProperties = params[@"properties"];
             
             NSString * versionTag = [NSString stringWithFormat:@"v_%@",[searchableProperties componentsJoinedByString:@"!"]];
             
             YapDatabaseSearchResultsViewOptions * opts = [[YapDatabaseSearchResultsViewOptions alloc] init];
             
             YapDatabaseSearchResultsView *view = [[YapDatabaseSearchResultsView alloc] initWithFullTextSearchName:YapDatabaseFullTextSearchExtensionName
                                                                                                    parentViewName:parentViewName
                                                                                                        versionTag:versionTag
                                                                                                           options:opts];
             
             if(![database registeredExtension:parentViewName])
             {
                 [NSException raise:@"error registering extension: parent view not registered, name = %@" format:parentViewName, nil];
             }
             if (![database registerExtension:view withName:viewName])
             {
                 [NSException raise:@"error registering extension: view name = %@" format:viewName, nil];
             }
         }];
    }];
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


+(NSMutableArray*) _searchHandlerDataWithClassName:(NSString*)className
{
    NSAssert(_searchHandlerData, @"_searchHandlerData should not be nil");
    NSMutableArray* properties = _searchHandlerData[className];
    if (!properties) {
        properties = [NSMutableArray array];
        _searchHandlerData[className] = properties;
    }
    return properties;
}



@end
