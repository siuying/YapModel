//
//  YapDatabaseView+Shorthand.h
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapDatabaseView.h"

@interface YapDatabaseView (Creation)

+(instancetype) viewWithCollection:(NSString*)collection sortBy:(SEL)sortBySelector version:(int)version;

+(instancetype) viewWithCollection:(NSString*)collection groupBy:(SEL)groupBySelector sortBy:(SEL)sortBySelector version:(int)version;

+(instancetype) viewWithCollection:(NSString*)collection sortByDescriptor:(NSSortDescriptor*)sortDescriptor version:(int)version;

+(instancetype) viewWithCollection:(NSString*)collection groupBy:(SEL)groupBySelector sortByDescriptor:(NSSortDescriptor*)sortDescriptor version:(int)version;

@end
