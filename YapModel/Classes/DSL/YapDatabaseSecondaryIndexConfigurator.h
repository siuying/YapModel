//
//  YapDatabaseSecondaryIndexConfigurator.h
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YapDatabase/YapDatabaseSecondaryIndex.h>

@class YapDatabase;

@interface YapDatabaseSecondaryIndexConfigurator : NSObject

/**
 * Configure secondary index based on annotation \@index on model
 * @param database The database to configure
 */
+(void) setupIndicesWithDatabase:(YapDatabase*)database;

+(void) configureIndexWithClassName:(NSString*)className
                     indexName:(NSString*)indexName
                     selectors:(NSDictionary*)selectors;

+(void) configureIndexWithClassName:(NSString*)className
                     indexName:(NSString*)indexName
                          type:(YapDatabaseSecondaryIndexType)type
                     selectors:(NSArray*)selectors;

+(NSDictionary*) indicesConfigurationWithClassName:(NSString*)className;

@end
