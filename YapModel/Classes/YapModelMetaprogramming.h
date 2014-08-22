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
        NSDictionary* indexSpecs = @{ __VA_ARGS__ }; \
        ym_addIndexToClass(targetClass, @#NAME, indexSpecs); \
    } \
    \
    @interface CLASS ()

#define indexText(CLASS, NAME, ...) \
    property (nonatomic, readonly) unsigned char metamacro_concat(NAME, _ym_text_index_marker); \
    @end \
    \
    __attribute__((constructor)) \
    static void metamacro_concat(ym_text_index_apply, NAME) (void) { \
        Class targetClass = objc_getClass(# CLASS); \
        NSArray* indexes = @[ __VA_ARGS__ ]; \
        ym_addTextIndexToClass(targetClass, @#NAME, indexes); \
    } \
    \
    @interface CLASS ()

#define indexReal(CLASS, NAME, ...) \
    property (nonatomic, readonly) unsigned char metamacro_concat(NAME, _ym_real_index_marker); \
    @end \
    \
    __attribute__((constructor)) \
    static void metamacro_concat(ym_real_index_apply, NAME) (void) { \
        Class targetClass = objc_getClass(# CLASS); \
        NSArray* indexes = @[ __VA_ARGS__ ]; \
        ym_addRealIndexToClass(targetClass, @#NAME, indexes); \
    } \
    \
    @interface CLASS ()

#define indexInteger(CLASS, NAME, ...) \
    property (nonatomic, readonly) unsigned char metamacro_concat(NAME, _ym_int_index_marker); \
    @end \
    \
    __attribute__((constructor)) \
    static void metamacro_concat(ym_int_index_apply, NAME) (void) { \
        Class targetClass = objc_getClass(# CLASS); \
        NSArray* indexes = @[ __VA_ARGS__ ]; \
        ym_addIntegerIndexToClass(targetClass, @#NAME, indexes);\
    } \
    \
    @interface CLASS ()

void ym_addIndexToClass(id targetClass, NSString* indexName, NSDictionary* indexSelectors);
void ym_addTextIndexToClass(id targetClass, NSString* indexName, NSArray* indexSelectors);
void ym_addRealIndexToClass(id targetClass, NSString* indexName, NSArray* indexSelectors);
void ym_addIntegerIndexToClass(id targetClass, NSString* indexName, NSArray* indexSelectors);
