//
//  YapDatabaseSecondaryIndexConfigurator.h
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YapDatabase;

@interface YapDatabaseSecondaryIndexConfigurator : NSObject

+(BOOL) registerIndexWithClass:(Class)clazz
                     indexName:(NSString*)indexName
                     selectors:(NSArray*)selectors;

/**
 * Configurate secondary index based on annotation @index on model
 */
+(void) configureWithDatabase:(YapDatabase*)database;

@end
