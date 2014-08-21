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

+(YapDatabaseSecondaryIndex*) indexWithClass:(Class)clazz properties:(NSArray*)properties
{
    NSDictionary* mappings = [self secondaryIndexTypeMappingsWithClass:clazz];
    YapDatabaseSecondaryIndexSetup *setup = [ [YapDatabaseSecondaryIndexSetup alloc] init];
    [properties enumerateObjectsUsingBlock:^(NSString* property, NSUInteger idx, BOOL *stop) {
        NSNumber* type = mappings[property];
        if (!type) {
            [NSException exceptionWithName:NSInvalidArgumentException
                                    reason:[NSString stringWithFormat:@"type for property %@ not found", property]
                                  userInfo:nil];
        }
        [setup addColumn:property withType:[type integerValue]];
    }];
    
    YapDatabaseSecondaryIndexBlockType blockType = YapDatabaseSecondaryIndexBlockTypeWithObject;
    YapDatabaseSecondaryIndexWithObjectBlock block = ^(NSMutableDictionary *dict, NSString *collection, NSString *key, id object){
        if ([object isMemberOfClass:clazz]) {
            [properties enumerateObjectsUsingBlock:^(NSString* property, NSUInteger idx, BOOL *stop) {
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
    return [[YapDatabaseSecondaryIndex alloc] initWithSetup:setup block:block blockType:blockType];
}

+(NSDictionary*) secondaryIndexTypeMappingsWithClass:(Class)clazz
{
    unsigned int propertyCount;
    __autoreleasing NSMutableDictionary *codableProperties = [NSMutableDictionary dictionary];
    objc_property_t *properties = class_copyPropertyList(clazz, &propertyCount);
    for (unsigned int i = 0; i < propertyCount; i++)
    {
        //get property name
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        __autoreleasing NSString *key = @(propertyName);
        
        //get property type
        YapDatabaseSecondaryIndexType indexType;
        char *typeEncoding = property_copyAttributeValue(property, "T");
        switch (typeEncoding[0])
        {
            case '@':
            {
                if (strlen(typeEncoding) >= 3)
                {
                    char *className = strndup(typeEncoding + 2, strlen(typeEncoding) - 3);
                    __autoreleasing NSString *name = @(className);
                    NSRange range = [name rangeOfString:@"<"];
                    if (range.location != NSNotFound)
                    {
                        name = [name substringToIndex:range.location];
                    }
                    
                    if ([name isEqualToString:NSStringFromClass([NSNumber class])] ||
                        [name isEqualToString:NSStringFromClass([NSDate class])]) {
                        indexType = YapDatabaseSecondaryIndexTypeReal;
                    } else {
                        indexType = YapDatabaseSecondaryIndexTypeText;
                    }
                    free(className);
                }
                break;
            }
            case 'c': // char
            case 'i': // int
            case 's': // short
            case 'l': // long
            case 'q': // long long
            case 'C': // unsigned int
            case 'I': // unsigned int
            case 'S': // unsigned short
            case 'B': // BOOL
            {
                indexType = YapDatabaseSecondaryIndexTypeInteger;
                break;
            }
            case 'f': // float
            case 'd': // double
            {
                indexType = YapDatabaseSecondaryIndexTypeReal;
                break;
            }
            case '{':
            {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unsupported type" userInfo:nil];
                break;
            }
        }
        free(typeEncoding);
        
        //see if there is a backing ivar
        char *ivar = property_copyAttributeValue(property, "V");
        if (ivar)
        {
            //check if ivar has KVC-compliant name
            __autoreleasing NSString *ivarName = @(ivar);
            if ([ivarName isEqualToString:key] || [ivarName isEqualToString:[@"_" stringByAppendingString:key]])
            {
                //no setter, but setValue:forKey: will still work
                codableProperties[key] = @(indexType);
            }
            free(ivar);
        }
    }
    
    free(properties);
    return codableProperties;
}


@end