//
//  YapDatabaseView+Shorthand.m
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapDatabaseView+Shorthand.h"
#import "YapModelObject.h"

#define YapDatabaseViewCreate(collection, groupBy, sortBy, version)

@implementation YapDatabaseView (Shorthand)

-(instancetype) initWithCollection:(NSString*)collection sortBy:(SEL)sortBySelector version:(int)version
{
    return [self initWithCollection:collection groupBy:nil sortBy:sortBySelector version:version];
}

-(instancetype) initWithCollection:(NSString*)collection groupBy:(SEL)groupBySelector sortBy:(SEL)sortBySelector version:(int)version
{
    YapDatabaseViewBlockType groupingBlockType;
    YapDatabaseViewGroupingBlock groupingBlock;
    YapDatabaseViewBlockType sortingBlockType;
    YapDatabaseViewSortingBlock sortingBlock;
    YapDatabaseViewOptions* options;

    if (groupBySelector) {
        groupingBlockType = YapDatabaseViewBlockTypeWithObject;
        groupingBlock = ^NSString*(NSString *collection, NSString *key, id object){
            id group = [object valueForKey:NSStringFromSelector(groupBySelector)];
            if ([group isMemberOfClass:[NSString class]]) {
                return group;
            } else {
                return [group description];
            }
        };
    } else {
        groupingBlockType = YapDatabaseViewBlockTypeWithKey;
        groupingBlock = ^NSString*(NSString *key, id object){
            return @"all";
        };
    }

    if (sortBySelector) {
        sortingBlockType = YapDatabaseViewBlockTypeWithObject;
        sortingBlock = ^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1, id object1,
                                           NSString *collection2, NSString *key2, id object2) {
            return [[object1 valueForKey:NSStringFromSelector(sortBySelector)] compare:[object2 valueForKey:NSStringFromSelector(sortBySelector)]];
        };
    } else {
        sortingBlockType = YapDatabaseViewBlockTypeWithKey;
        sortingBlock = ^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1,
                                           NSString *collection2, NSString *key2) {
            return [key1 compare:key2];
        };
    }

    options = [[YapDatabaseViewOptions alloc] init];
    options.allowedCollections = [NSSet setWithArray:@[collection]];

    return [[YapDatabaseView alloc] initWithGroupingBlock:groupingBlock
                                        groupingBlockType:groupingBlockType
                                             sortingBlock:sortingBlock
                                         sortingBlockType:sortingBlockType
                                                  version:version
                                                  options:options];
}

-(instancetype) initWithCollection:(NSString*)collection sortByDescriptor:(NSSortDescriptor*)sortDescriptor version:(int)version
{
    return [self initWithCollection:collection groupBy:nil sortByDescriptor:sortDescriptor version:version];
}

-(instancetype) initWithCollection:(NSString*)collection groupBy:(SEL)groupBySelector sortByDescriptor:(NSSortDescriptor*)sortDescriptor version:(int)version
{
    YapDatabaseViewBlockType groupingBlockType;
    YapDatabaseViewGroupingBlock groupingBlock;
    YapDatabaseViewBlockType sortingBlockType;
    YapDatabaseViewSortingBlock sortingBlock;
    YapDatabaseViewOptions* options;
    
    if (groupBySelector) {
        groupingBlockType = YapDatabaseViewBlockTypeWithObject;
        groupingBlock = ^NSString*(NSString *collection, NSString *key, id object){
            id group = [object valueForKey:NSStringFromSelector(groupBySelector)];
            if ([group isMemberOfClass:[NSString class]]) {
                return group;
            } else {
                return [group description];
            }
        };
    } else {
        groupingBlockType = YapDatabaseViewBlockTypeWithKey;
        groupingBlock = ^NSString*(NSString *key, id object){
            return @"all";
        };
    }
    
    if (sortDescriptor) {
        sortingBlockType = YapDatabaseViewBlockTypeWithObject;
        sortingBlock = ^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1, id object1,
                                           NSString *collection2, NSString *key2, id object2) {
            return [sortDescriptor compareObject:object1 toObject:object2];
        };
    } else {
        sortingBlockType = YapDatabaseViewBlockTypeWithKey;
        sortingBlock = ^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1,
                                           NSString *collection2, NSString *key2) {
            return [key1 compare:key2];
        };
    }
    
    options = [[YapDatabaseViewOptions alloc] init];
    options.allowedCollections = [NSSet setWithArray:@[collection]];
    
    return [[YapDatabaseView alloc] initWithGroupingBlock:groupingBlock
                                        groupingBlockType:groupingBlockType
                                             sortingBlock:sortingBlock
                                         sortingBlockType:sortingBlockType
                                                  version:version
                                                  options:options];
}

@end
