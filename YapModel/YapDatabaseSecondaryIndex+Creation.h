//
//  YapDatabaseSecondaryIndex+Creation.h
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapDatabaseSecondaryIndex.h"

@interface YapDatabaseSecondaryIndex (Creation)

+(YapDatabaseSecondaryIndex*) indexWithClass:(Class)clazz selector:(SEL)selector type:(YapDatabaseSecondaryIndexType)type;

+(YapDatabaseSecondaryIndex*) indexWithClass:(Class)clazz selector:(SEL)selector;

@end
