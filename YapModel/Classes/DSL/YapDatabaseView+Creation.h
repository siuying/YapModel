//
//  YapDatabaseView+Shorthand.h
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapDatabaseView.h"

@interface YapDatabaseView (Creation)

+(instancetype) viewWithCollection:(NSString*)collection
                       groupByKeys:(NSArray*)groupByKeys
                        sortByKeys:(NSArray*)sortByKeys
                           version:(int)version;

@end
