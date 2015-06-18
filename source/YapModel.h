//
//  YapModel.h
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapModelObject.h"
#import "YapDatabaseView+Creation.h"
#import "YapDatabaseSecondaryIndex+Creation.h"
#import "YapModelObject+CRUD.h"
#import "YapModelMetaprogramming.h"
#import "YapModelViewProvider.h"

@class YapDatabase;

@interface YapModel : NSObject
+(void) setupDatabse:(YapDatabase*)database;
@end

