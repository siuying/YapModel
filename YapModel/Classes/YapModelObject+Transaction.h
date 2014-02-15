//
//  YapModelObject+Transaction.h
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapModelObject.h"

@interface YapModelObject (Transaction)

+(void) transaction:(void (^)(void))block;

+(void) asyncTransaction:(void (^)(void))block;

+(void) asyncTransaction:(void (^)(void))block completion:(void (^)(void))completion;

@end
