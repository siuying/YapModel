//
//  YapModelObject+Transaction.m
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapModelObject+Transaction.h"
#import "YapModelManager.h"

@implementation YapModelObject (Transaction)

+(void) transaction:(void (^)(void))block
{
    [[[YapModelManager sharedManager] connection] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [YapModelManager sharedManager].transaction = transaction;
        block();
        [YapModelManager sharedManager].transaction = nil;
    }];
}

+(void) asyncTransaction:(void (^)(void))block
{
    [self asyncTransaction:block completion:nil];
}

+(void) asyncTransaction:(void (^)(void))block completion:(void (^)(void))completion
{
    [[[YapModelManager sharedManager] connection] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [YapModelManager sharedManager].transaction = transaction;
        block();
        [YapModelManager sharedManager].transaction = nil;
    } completionBlock:completion];
}

@end
