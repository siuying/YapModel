//
//  YapModelMetaprogramming.h
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libextobjc/extobjc.h>
#import "YapDatabaseRelationshipEdge.h"

#define index(CLASS, NAME, ...) \
    property (nonatomic, readonly) unsigned char metamacro_concat(NAME, _ym_index_marker); \
    @end \
    \
    __attribute__((constructor)) \
    static void metamacro_concat(ym_index_apply, NAME) (void) { \
        NSString* className = [NSString stringWithUTF8String:#CLASS]; \
        NSDictionary* indexSpecs = @{ __VA_ARGS__ }; \
        ym_addIndexToClass(className, @#NAME, indexSpecs); \
    } \
    \
    @interface CLASS ()

#define indexText(CLASS, NAME, ...) \
    property (nonatomic, readonly) unsigned char metamacro_concat(NAME, _ym_text_index_marker); \
    @end \
    \
    __attribute__((constructor)) \
    static void metamacro_concat(ym_text_index_apply, NAME) (void) { \
        NSString* className = [NSString stringWithUTF8String:#CLASS]; \
        NSArray* indexes = @[ __VA_ARGS__ ]; \
        ym_addTextIndexToClass(className, @#NAME, indexes); \
    } \
    \
    @interface CLASS ()

#define indexReal(CLASS, NAME, ...) \
    property (nonatomic, readonly) unsigned char metamacro_concat(NAME, _ym_real_index_marker); \
    @end \
    \
    __attribute__((constructor)) \
    static void metamacro_concat(ym_real_index_apply, NAME) (void) { \
        NSString* className = [NSString stringWithUTF8String:#CLASS]; \
        NSArray* indexes = @[ __VA_ARGS__ ]; \
        ym_addRealIndexToClass(className, @#NAME, indexes); \
    } \
    \
    @interface CLASS ()

#define indexInteger(CLASS, NAME, ...) \
    property (nonatomic, readonly) unsigned char metamacro_concat(NAME, _ym_int_index_marker); \
    @end \
    \
    __attribute__((constructor)) \
    static void metamacro_concat(ym_int_index_apply, NAME) (void) { \
        NSString* className = [NSString stringWithUTF8String:#CLASS]; \
        NSArray* indexes = @[ __VA_ARGS__ ]; \
        ym_addIntegerIndexToClass(className, @#NAME, indexes);\
    } \
    \
    @interface CLASS ()

void ym_addIndexToClass(NSString* targetClassName, NSString* indexName, NSDictionary* indexSelectors);
void ym_addTextIndexToClass(NSString* targetClassName, NSString* indexName, NSArray* indexSelectors);
void ym_addRealIndexToClass(NSString* targetClassName, NSString* indexName, NSArray* indexSelectors);
void ym_addIntegerIndexToClass(NSString* targetClassName, NSString* indexName, NSArray* indexSelectors);

#define view(CLASS, NAME, ...) \
    property (nonatomic, readonly) unsigned char metamacro_concat(NAME, _ym_grp_marker); \
    @end \
    \
    __attribute__((constructor)) \
    static void metamacro_concat(ym_grp_apply, NAME) (void) { \
        NSString* className = [NSString stringWithUTF8String:#CLASS]; \
        NSDictionary* params = @{ __VA_ARGS__ }; \
        ym_addViewToClass(className, @#NAME, params);\
    } \
    \
    @interface CLASS ()
void ym_addViewToClass(NSString* targetClassName, NSString* viewName, NSDictionary* params);

#define hasMany(CLASS, EDGE, KEY, ID) \
    property (nonatomic, readonly) unsigned char metamacro_concat(EDGE, _ym_has_many_marker); \
    @end \
    \
    __attribute__((constructor)) \
    static void metamacro_concat(ym_has_many_apply, EDGE) (void) { \
        ym_addHasMany(@#CLASS, @#EDGE, @#KEY, ID);\
    } \
    \
    @interface CLASS ()

#define hasOne(CLASS, EDGE, KEY, ID) \
    property (nonatomic, readonly) unsigned char metamacro_concat(EDGE, _ym_has_one_marker); \
    @end \
    \
    __attribute__((constructor)) \
    static void metamacro_concat(ym_has_one_apply, EDGE) (void) { \
        ym_addHasOne(@#CLASS, @#EDGE, @#KEY, ID);\
    } \
    \
    @interface CLASS ()

#define belongsTo(CLASS, EDGE, KEY, ID) \
    property (nonatomic, readonly) unsigned char metamacro_concat(EDGE, _ym_belongs_to__marker); \
    @end \
    \
    __attribute__((constructor)) \
    static void metamacro_concat(ym_belongs_to_apply, EDGE) (void) { \
        ym_addBelongsTo(@#CLASS, @#EDGE, @#KEY, ID);\
    } \
    \
    @interface CLASS ()

#define hasOneFile(CLASS, EDGE, KEY, ID) \
    property (nonatomic, readonly) unsigned char metamacro_concat(EDGE, _ym_has_one_file_marker); \
    @end \
    \
    __attribute__((constructor)) \
    static void metamacro_concat(ym_has_one_file_apply, EDGE) (void) { \
        ym_addHasOneFile(@#CLASS, @#EDGE, @#KEY, ID);\
    } \
    \
    @interface CLASS ()


void ym_addHasMany(NSString* targetClassName, NSString* edgeName, NSString* childKey, YDB_NodeDeleteRules nodeRules);

void ym_addHasOne(NSString* targetClassName, NSString* edgeName, NSString* childKey, YDB_NodeDeleteRules nodeRules);

void ym_addBelongsTo(NSString* targetClassName, NSString* edgeName, NSString* parentKey, YDB_NodeDeleteRules nodeRules);

void ym_addHasOneFile(NSString* targetClassName, NSString* edgeName, NSString* filePathKey, YDB_NodeDeleteRules nodeRules);

