//
//  YapDatabaseSecondaryIndex+Creation.m
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapDatabaseSecondaryIndex+Creation.h"
#import "YapModelObject.h"

@implementation YapDatabaseSecondaryIndex (Creation)

+(YapDatabaseSecondaryIndex*) indexWithClass:(Class)clazz
                                  properties:(NSDictionary*)properties
{
    YapDatabaseSecondaryIndexSetup *setup = [ [YapDatabaseSecondaryIndexSetup alloc] init];
    [properties enumerateKeysAndObjectsUsingBlock:^(NSString* property, NSNumber* typeValue, BOOL *stop) {
        YapDatabaseSecondaryIndexType type = (YapDatabaseSecondaryIndexType) typeValue.integerValue;
        [setup addColumn:property withType:type];
    }];
    
    YapDatabaseSecondaryIndexWithObjectBlock handlerBlock = ^(NSMutableDictionary *dict, NSString *collection, NSString *key, id object) {
        if ([object isMemberOfClass:clazz]) {
            [properties enumerateKeysAndObjectsUsingBlock:^(NSString* property, NSNumber* typeValue, BOOL *stop) {
                id indexedValue = [object valueForKey:property];
                if ([indexedValue isKindOfClass:[NSNumber class]] || [indexedValue isKindOfClass:[NSString class]]) {
                    [dict setObject:indexedValue forKey:property];
                } else if ([indexedValue isKindOfClass:[NSDate class]]) {
                    [dict setObject:@([(NSDate*)indexedValue timeIntervalSince1970]) forKey:property];
                } else {
                    [dict setObject:[indexedValue description] forKey:property];
                }
            }];
            return;
        }
    };
    YapDatabaseSecondaryIndexHandler * handler = [YapDatabaseSecondaryIndexHandler withObjectBlock:handlerBlock];
    
    return [[YapDatabaseSecondaryIndex alloc] initWithSetup:setup handler:handler];
}

@end