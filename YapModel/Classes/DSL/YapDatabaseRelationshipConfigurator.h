//
//  YapDatabaseRelationConfigurator.h
//  YapModel
//
//  Created by Francis Chong on 8/22/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YapDatabaseRelationshipEdge.h"

@class YapDatabase;

@interface YapDatabaseRelationshipConfigurator : NSObject

+(void) setupViewsWithDatabase:(YapDatabase*)database;

+(NSDictionary*) relationshipConfigurationWithClassName:(NSString*)className;

+(BOOL) hasRelationshipConfigurationWithClassName:(NSString*)className;

#pragma mark - Config

+(void) configureHasManyRelationshipWithClassName:(NSString*)className
                                         edgeName:(NSString*)edgeName
                                         childKey:(NSString*)childKey
                                  nodeDeleteRules:(YDB_NodeDeleteRules)nodeDeleteRules;

+(void) configureHasOneRelationshipWithClassName:(NSString*)className
                                        edgeName:(NSString*)edgeName
                                        childKey:(NSString*)childKey
                                 nodeDeleteRules:(YDB_NodeDeleteRules)nodeDeleteRules;

+(void) configureBelongsToRelationshipWithClassName:(NSString*)className
                                           edgeName:(NSString*)edgeName
                                          parentKey:(NSString*)parentKey
                                    nodeDeleteRules:(YDB_NodeDeleteRules)nodeDeleteRules;

+(void) configureHasOneFileRelationshipWithClassName:(NSString*)className
                                            edgeName:(NSString*)edgeName
                                         filePathKey:(NSString*)filePathKey
                                     nodeDeleteRules:(YDB_NodeDeleteRules)nodeDeleteRules;

#pragma mark - Retrieve

+(NSArray*) edgesWithInstance:(id)instance;

@end
