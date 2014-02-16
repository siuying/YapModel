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

+(void) transaction:(void (^)(YapDatabaseReadWriteTransaction *transaction))block
{
    [[[YapModelManager sharedManager] connection] readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [YapModelManager setTransactionForCurrentThread:transaction];
        block(transaction);
        [YapModelManager setTransactionForCurrentThread:nil];
    }];
}

+(void) asyncTransaction:(void (^)(YapDatabaseReadWriteTransaction *transaction))block
{
    [self asyncTransaction:block completion:nil completionQueue:nil];
}

+(void) asyncTransaction:(void (^)(YapDatabaseReadWriteTransaction *transaction))block completion:(void (^)(void))completion
{
    [self asyncTransaction:block completion:completion completionQueue:nil];
}

+(void) asyncTransaction:(void (^)(YapDatabaseReadWriteTransaction *transaction))block completion:(void (^)(void))completion completionQueue:(dispatch_queue_t)completionQueue
{
    [[[YapModelManager sharedManager] connection] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [YapModelManager setTransactionForCurrentThread:transaction];
        block(transaction);
        [YapModelManager setTransactionForCurrentThread:nil];
    } completionBlock:completion completionQueue:completionQueue];
}

@end
