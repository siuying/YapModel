//
//  YapModelObject.h
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AutoCoding.h"
#import "YapModelMetaprogramming.h"
#import "YapDatabase.h"

@interface YapModelObject : NSObject

@property (nonatomic, copy) NSString* key;

+(NSString*) collectionName;

@end

#import "YapModelObject+CRUD.h"
