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
                                    selector:(SEL)selector
                                        type:(YapDatabaseSecondaryIndexType)type
{
    YapDatabaseSecondaryIndexSetup *setup = [ [YapDatabaseSecondaryIndexSetup alloc] init];
    [setup addColumn:NSStringFromSelector(selector) withType:type];

    YapDatabaseSecondaryIndexBlockType blockType = YapDatabaseSecondaryIndexBlockTypeWithObject;
    YapDatabaseSecondaryIndexWithObjectBlock block = ^(NSMutableDictionary *dict, NSString *collection, NSString *key, id object){
        if ([object isMemberOfClass:clazz]) {
            [dict setObject:[object valueForKey:NSStringFromSelector(selector)]
                     forKey:NSStringFromSelector(selector)];
            return;
        }
    };
    return [[YapDatabaseSecondaryIndex alloc] initWithSetup:setup block:block blockType:blockType];
}

+(YapDatabaseSecondaryIndex*) indexWithClass:(Class)clazz selector:(SEL)selector
{
    YapDatabaseSecondaryIndexSetup *setup = [ [YapDatabaseSecondaryIndexSetup alloc] init];
    NSDictionary* properties = [clazz codableProperties];
    Class propertyType = properties[NSStringFromSelector(selector)];
    if ([propertyType isSubclassOfClass:[NSNumber class]]) {
        [setup addColumn:NSStringFromSelector(selector) withType:YapDatabaseSecondaryIndexTypeReal];
    } else if ([propertyType isSubclassOfClass:[NSString class]]) {
        [setup addColumn:NSStringFromSelector(selector) withType:YapDatabaseSecondaryIndexTypeText];
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"unexpected field type for field: %@, should be number or NSString", NSStringFromSelector(selector)]
                                     userInfo:nil];
    }

    YapDatabaseSecondaryIndexBlockType blockType = YapDatabaseSecondaryIndexBlockTypeWithObject;
    YapDatabaseSecondaryIndexWithObjectBlock block = ^(NSMutableDictionary *dict, NSString *collection, NSString *key, id object){
        if ([object isMemberOfClass:clazz]) {
            [dict setObject:[object valueForKey:NSStringFromSelector(selector)]
                     forKey:NSStringFromSelector(selector)];
            return;
        }
    };
    return [[YapDatabaseSecondaryIndex alloc] initWithSetup:setup block:block blockType:blockType];
}

@end