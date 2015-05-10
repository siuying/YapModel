//
//  YapDatabaseSecondaryIndex+Creation.h
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <YapDatabase/YapDatabaseSecondaryIndex.h>

@interface YapDatabaseSecondaryIndex (Creation)

/**
 * @param clazz the class this index should target
 * @param [NSDictionary<NSString, NSNumber>] properties A dictionary with property as key and YapDatabaseSecondaryIndexBlockType (in NSNumber) as the value.
 */
+(YapDatabaseSecondaryIndex*) indexWithClass:(Class)clazz
                                  properties:(NSDictionary*)properties;

@end
