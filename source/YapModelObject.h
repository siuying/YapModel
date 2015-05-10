//
//  YapModelObject.h
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YapModelMetaprogramming.h"



@interface YapModelObject : NSObject

@property (nonatomic, copy) NSString* key;

+(NSString*) collectionName;

/**
 * Return relationship edges based on YapDatabaseRelationshipConfigurator
 *
 * @see YapDatabaseRelationshipConfigurator
 */
-(NSArray*) yapDatabaseRelationshipEdges;

@end

#import "YapModelObject+CRUD.h"
