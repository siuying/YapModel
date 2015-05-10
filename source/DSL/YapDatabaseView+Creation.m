//
//  YapDatabaseView+Shorthand.m
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapDatabaseView+Creation.h"

#define YapDatabaseViewCreate(collection, groupBy, sortBy, version)
static NSString * const kParamsSplitter = @"!";
static NSString * const kReverseSortOrderPrefix = @"-";

@implementation YapDatabaseView (Creation)

+(instancetype) viewWithCollection:(NSString*)collection groupByKeys:(NSArray*)groupByKeys sortByKeys:(NSArray*)sortByKeys versionTag:(NSString*)versionTag
{
    return [[self alloc] initWithCollection:collection groupByKeys:groupByKeys sortByKeys:sortByKeys versionTag:versionTag];
}

+(instancetype) viewWithCollection:(NSString*)collection
                       groupByKeys:(NSArray*)groupByKeys
                        sortByKeys:(NSArray*)sortByKeys
{
    NSString* groupByTag = groupByKeys ? [groupByKeys componentsJoinedByString:kParamsSplitter] : @"all";
    NSString* sortByTag = sortByKeys ? [sortByKeys componentsJoinedByString:kParamsSplitter] : @"none";
    NSString* versionTag = [[groupByTag stringByAppendingString:kParamsSplitter] stringByAppendingString:sortByTag];
    return [[self alloc] initWithCollection:collection groupByKeys:groupByKeys sortByKeys:sortByKeys versionTag:versionTag];
}

#pragma mark - Private

-(instancetype) initWithCollection:(NSString*)collection groupByKeys:(NSArray*)groupByKeys sortByKeys:(NSArray*)originalSortByKeys versionTag:(NSString*)versionTag
{
    YapDatabaseViewOptions* options;    
    YapDatabaseViewGrouping * grouping;
    YapDatabaseViewSorting * sorting;
    
    NSMutableIndexSet * reverseSortKeys = [NSMutableIndexSet new];
    NSMutableArray * sortByKeys = [NSMutableArray array];
    [originalSortByKeys enumerateObjectsUsingBlock:^(NSString* key, NSUInteger idx, BOOL *stop) {
        NSString * actualKey = key;
        if([actualKey hasPrefix:kReverseSortOrderPrefix])
        {
            [reverseSortKeys addIndex:idx];
            actualKey = [actualKey substringFromIndex:1];
        }
        [sortByKeys addObject:actualKey];
    }];
    
    
    if (groupByKeys && groupByKeys.count > 0) {
        grouping = [YapDatabaseViewGrouping withObjectBlock:^NSString *(NSString *collection, NSString *key, id object) {
            NSMutableArray* groupByValues = [NSMutableArray array];
            [groupByKeys enumerateObjectsUsingBlock:^(NSString* groupBySelector, NSUInteger idx, BOOL *stop) {
                id group = [object valueForKey:groupBySelector];
                if ([group isMemberOfClass:[NSString class]]) {
                    [groupByValues addObject:group];
                } else if(group!=nil){
                    [groupByValues addObject:[group description]];
                }
            }];
            return [groupByValues componentsJoinedByString:kParamsSplitter];
        }];
    } else {
        grouping = [YapDatabaseViewGrouping withKeyBlock:^NSString *(NSString *collection, NSString *key) {
            return @"all";
        }];
    }
    
    if (sortByKeys && sortByKeys.count > 0) {
        sorting = [YapDatabaseViewSorting withObjectBlock:^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1, id object1, NSString *collection2, NSString *key2, id object2) {
            __block NSComparisonResult result = NSOrderedSame;
            
            [sortByKeys enumerateObjectsUsingBlock:^(NSString* sortBySelector, NSUInteger idx, BOOL *stop) {
                NSComparisonResult _result = [[object1 valueForKey:sortBySelector] compare:[object2 valueForKey:sortBySelector]];
                
                if (_result != NSOrderedSame) {
                    //flip result if order is reversed
                    if([reverseSortKeys containsIndex:idx]) _result = (_result== NSOrderedAscending) ? NSOrderedDescending : NSOrderedAscending;
                    result = _result;
                    *stop = YES;
                }
            }];
            return result;
        }];
    } else {
        sorting = [YapDatabaseViewSorting withKeyBlock:^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1, NSString *collection2, NSString *key2) {
            return NSOrderedSame;
        }];
    }

    options = [[YapDatabaseViewOptions alloc] init];
    options.allowedCollections = [[YapWhitelistBlacklist alloc] initWithWhitelist:[NSSet setWithArray:@[collection]]];
    
    return [[YapDatabaseView alloc] initWithGrouping:grouping
                                             sorting:sorting
                                          versionTag:versionTag
                                             options:options];
}

@end
