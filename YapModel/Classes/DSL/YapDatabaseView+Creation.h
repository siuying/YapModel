//
//  YapDatabaseView+Shorthand.h
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapDatabaseView.h"

@interface YapDatabaseView (Creation)

/**
 * Create a view for a collection, use the supplied keys to group and sort.
 * @param collection name of the collection
 * @param groupByKeys [NSArray<String>] keys for properties used to group the view. the group name will be string joined by all values in order.
 * @param sortByKeys [NSArray<String>] keys for properties used to sort the view.
 * @param versionTag version of the view
 *
 */
+(instancetype) viewWithCollection:(NSString*)collection
                       groupByKeys:(NSArray*)groupByKeys
                        sortByKeys:(NSArray*)sortByKeys
                        versionTag:(NSString*)versionTag;

/**
 * Create a view for a collection, use the supplied keys to group and sort. Automatically create version based on groupByKeys and sortByKeys
 *
 * @param collection name of the collection
 * @param groupByKeys [NSArray<String>] keys for properties used to group the view. the group name will be string joined by all values in order.
 * @param sortByKeys [NSArray<String>] keys for properties used to sort the view.
 *
 * @see viewWithCollection:groupByKeys:sortByKeys:versionTag:
 */
+(instancetype) viewWithCollection:(NSString*)collection
                       groupByKeys:(NSArray*)groupByKeys
                        sortByKeys:(NSArray*)sortByKeys;

@end
