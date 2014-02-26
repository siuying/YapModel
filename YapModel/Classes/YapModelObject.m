//
//  YapModelObject.m
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapModelObject.h"
#import "YapModelManager.h"
#import "YapDatabase.h"
#import "AutoCoding.h"
#import <objc/runtime.h>

@implementation YapModelObject

-(instancetype) init
{
    self = [super init];
    _key = [[NSUUID UUID] UUIDString];
    return self;
}

+(NSString*) collectionName
{
    return NSStringFromClass([self class]);
}

+(NSDictionary*) codableProperties
{
    Class superclass = [self superclass];
    
    // add codable properties of superclass
    NSMutableDictionary* codableProperties;
    if ([superclass respondsToSelector:@selector(codableProperties)]) {
        codableProperties = [[superclass codableProperties] mutableCopy];
    } else {
        codableProperties = [NSMutableDictionary dictionary];
    }

    // add codable properties of this class
    [codableProperties addEntriesFromDictionary:[self codablePropertiesWithClass:self]];
    return codableProperties;
}

+(NSDictionary*) codablePropertiesWithClass:(Class)clazz
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
        Class propertyClass = nil;
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
                    propertyClass = NSClassFromString(name) ?: [NSObject class];
                    free(className);
                }
                break;
            }
            case 'c':
            case 'i':
            case 's':
            case 'l':
            case 'q':
            case 'C':
            case 'I':
            case 'S':
            case 'f':
            case 'd':
            case 'B':
            {
                propertyClass = [NSNumber class];
                break;
            }
            case '{':
            {
                propertyClass = [NSValue class];
                break;
            }
        }
        free(typeEncoding);
        
        if (propertyClass)
        {
            //see if there is a backing ivar
            char *ivar = property_copyAttributeValue(property, "V");
            if (ivar)
            {
                //check if ivar has KVC-compliant name
                __autoreleasing NSString *ivarName = @(ivar);
                if ([ivarName isEqualToString:key] || [ivarName isEqualToString:[@"_" stringByAppendingString:key]])
                {
                    //no setter, but setValue:forKey: will still work
                    codableProperties[key] = propertyClass;
                }
                free(ivar);
            }
        }
    }
    
    free(properties);
    return codableProperties;
}

@end
