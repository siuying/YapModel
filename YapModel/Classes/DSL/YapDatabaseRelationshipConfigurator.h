//
//  YapDatabaseRelationConfigurator.h
//  YapModel
//
//  Created by Francis Chong on 8/22/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YapDatabaseRelationshipEdge.h"

@interface YapDatabaseRelationshipConfigurator : NSObject

#pragma mark - Config

+(void) configureHasManyRelationshipWithClassName:(NSString*)className
                                         edgeName:(NSString*)edgeName
                                         childKey:(NSString*)childKey
                                  nodeDeleteRules:(NSNumber*)nodeDeleteRules;

+(void) configureHasOneRelationshipWithClassName:(NSString*)className
                                        edgeName:(NSString*)edgeName
                                        childKey:(NSString*)childKey
                                 nodeDeleteRules:(NSNumber*)nodeDeleteRules;

+(void) configureBelongsToRelationshipWithClassName:(NSString*)className
                                           edgeName:(NSString*)edgeName
                                          parentKey:(NSString*)parentKey
                                    nodeDeleteRules:(NSNumber*)nodeDeleteRules;

+(void) configureHasOneFileRelationshipWithClassName:(NSString*)className
                                            edgeName:(NSString*)edgeName
                                         filePathKey:(NSString*)filePathKey
                                     nodeDeleteRules:(NSNumber*)nodeDeleteRules;

#pragma mark - Retrieve

+(NSArray*) edgesWithInstance:(id)instance;

@end
