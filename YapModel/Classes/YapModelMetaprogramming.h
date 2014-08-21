//
//  YapModelMetaprogramming.h
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libextobjc/extobjc.h>

#define index(CLASS, NAME, ...) \
    property (nonatomic, readonly) unsigned char metamacro_concat(NAME, _ym_index_marker); \
    @end \
    \
    __attribute__((constructor)) \
    static void metamacro_concat(ym_index_apply, NAME) (void) { \
        Class targetClass = objc_getClass(# CLASS); \
        id indexSpec = @[ __VA_ARGS__ ]; \
        \
        if (!ym_addIndexToClass(targetClass, @#NAME, indexSpec)) { \
            NSLog(@"*** Failed to apply annotation %@ at %s:%lu", indexSpec, __FILE__, (unsigned long)__LINE__); \
        } \
    } \
    \
    @interface CLASS ()

BOOL ym_addIndexToClass(id targetClass, NSString* indexName, NSArray* indexSelectors);
