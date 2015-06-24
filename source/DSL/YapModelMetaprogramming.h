//
//  YapModelMetaprogramming.h
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

@import Foundation;
#import <libextobjc/extobjc.h>
#import <YapDatabase/YapDatabaseRelationshipEdge.h>

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

#define hasMany(CLASS, KEY, EDGE, ID) \
    property (nonatomic, readonly) unsigned char metamacro_concat(EDGE, _ym_has_many_marker); \
    @property (nonatomic, strong) NSArray* KEY; \
    @end \
    \
    __attribute__((constructor)) \
    static void metamacro_concat(ym_has_many_apply, EDGE) (void) { \
        ym_addHasMany(@#CLASS, @#KEY, @#EDGE, ID);\
    } \
    \
    @interface CLASS ()

#define hasOne(CLASS, KEY, EDGE, ID) \
    property (nonatomic, readonly) unsigned char metamacro_concat(EDGE, _ym_has_one_marker); \
    @property (nonatomic, copy) NSString* KEY; \
    @end \
    \
    __attribute__((constructor)) \
    static void metamacro_concat(ym_has_one_apply, EDGE) (void) { \
        ym_addHasOne(@#CLASS, @#KEY, @#EDGE, ID);\
    } \
    \
    @interface CLASS ()

#define belongsTo(CLASS, KEY, EDGE, ID) \
    property (nonatomic, readonly) unsigned char metamacro_concat(EDGE, _ym_belongs_to__marker); \
    @property (nonatomic, copy) NSString* KEY; \
    @end \
    \
    __attribute__((constructor)) \
    static void metamacro_concat(ym_belongs_to_apply, EDGE) (void) { \
        ym_addBelongsTo(@#CLASS, @#KEY, @#EDGE, ID);\
    } \
    \
    @interface CLASS ()

#define hasOneFile(CLASS, KEY, EDGE, ID) \
    property (nonatomic, readonly) unsigned char metamacro_concat(EDGE, _ym_has_one_file_marker); \
    @property (nonatomic, copy) NSString* KEY; \
    @end \
    \
    __attribute__((constructor)) \
    static void metamacro_concat(ym_has_one_file_apply, EDGE) (void) { \
        ym_addHasOneFile(@#CLASS, @#KEY, @#EDGE, ID);\
    } \
    \
    @interface CLASS ()


void ym_addHasMany(NSString* targetClassName, NSString* childKey, NSString* edgeName, YDB_NodeDeleteRules nodeRules);

void ym_addHasOne(NSString* targetClassName, NSString* childKey, NSString* edgeName, YDB_NodeDeleteRules nodeRules);

void ym_addBelongsTo(NSString* targetClassName, NSString* parentKey, NSString* edgeName,YDB_NodeDeleteRules nodeRules);

void ym_addHasOneFile(NSString* targetClassName, NSString* filePathKey, NSString* edgeName, YDB_NodeDeleteRules nodeRules);



#define searchView(CLASS, NAME, ...) \
property (nonatomic, readonly) unsigned char metamacro_concat(NAME, _ym_grp_marker); \
@end \
\
__attribute__((constructor)) \
static void metamacro_concat(ym_grp_apply, NAME) (void) { \
NSString* className = [NSString stringWithUTF8String:#CLASS]; \
NSDictionary* params = @{ __VA_ARGS__ }; \
ym_addSearchResultsViewToClass(className, @#NAME, params);\
} \
\
@interface CLASS ()
void ym_addSearchResultsViewToClass(NSString* targetClassName, NSString* viewName, NSDictionary* properties);

