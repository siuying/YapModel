//
//  YapModelObject.m
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapModelObject.h"
#import "YapModelManager.h"
#import "YapDatabase.h"
#import "AutoCoding.h"

@implementation YapModelObject

-(instancetype) init
{
    self = [super init];
    _key = [[NSUUID UUID] UUIDString];
    return self;
}

+(NSString*) collectionName
{
    return NSStringFromClass([self class]);
}

@end
