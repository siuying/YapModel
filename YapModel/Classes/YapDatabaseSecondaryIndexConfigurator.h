//
//  YapDatabaseSecondaryIndexConfigurator.h
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YapDatabaseSecondaryIndex.h"

@class YapDatabase;

@interface YapDatabaseSecondaryIndexConfigurator : NSObject

/**
 * Configurate secondary index based on annotation \@index on model
 * @param database The database to configure
 */
+(void) configureWithDatabase:(YapDatabase*)database;

+(void) registerIndexWithClass:(Class)clazz
                     indexName:(NSString*)indexName
                     selectors:(NSDictionary*)selectors;

+(void) registerIndexWithClass:(Class)clazz
                     indexName:(NSString*)indexName
                          type:(YapDatabaseSecondaryIndexType)type
                     selectors:(NSArray*)selectors;

+(NSDictionary*) indicesWithClass:(Class)clazz;

@end
