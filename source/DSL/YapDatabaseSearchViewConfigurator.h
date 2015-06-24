//
//  YapDatabaseSearchViewConfigurator.h
//  YapModel
//
//  Created by Aleksei Shevchenko on 6/24/15.
//  Copyright (c) 2014 Aleksei Shevchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YapDatabase;

extern NSString* const YapDatabaseFullTextSearchExtensionName;

@interface YapDatabaseSearchViewConfigurator : NSObject

/**
 * Setup view based on annotation \@searchView on model
 * @param database The database to configure
 */
+(void) setupViewsWithDatabase:(YapDatabase*)database;

+(NSDictionary*) viewsConfigurationWithClassName:(NSString*)className;

+(void) configureViewWithClassName:(NSString*)className
                          viewName:(NSString*)viewName
                            params:(NSDictionary*)params;

@end
