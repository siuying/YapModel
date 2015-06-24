//
//  YapDatabaseViewConfigurator.h
//  YapModel
//
//  Created by Francis Chong on 8/22/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YapDatabaseView;
@class YapDatabase;

extern NSString* const YapDatabaseViewConfiguratorGroupKey;
extern NSString* const YapDatabaseViewConfiguratorSortKey;

@interface YapDatabaseViewConfigurator : NSObject

/**
 * Setup view based on annotation \@view on model
 * @param database The database to configure
 */
+(void) setupViewsWithDatabase:(YapDatabase*)database;

/**
 *  Setup additional views from view providers
 *
 *  @param database The database to configure
 */
+(void) setupAdditionalViewsFromViewProvidersWithDatabase:(YapDatabase*)database;

+(NSDictionary*) viewsConfigurationWithClassName:(NSString*)className;

+(void) configureViewWithClassName:(NSString*)className
                          viewName:(NSString*)viewName
                            params:(NSDictionary*)params;


+(void) registerViewProviderWithClassName:(NSString*)className;

@end
