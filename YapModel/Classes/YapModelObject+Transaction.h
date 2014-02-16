//
//  YapModelObject+Transaction.h
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapModelObject.h"

@interface YapModelObject (Transaction)

/**
 * Create and execute a YapDatabaseReadWriteTransaction in a block synchronously. Any shorthand methods in the block
 * will use the new transaction.
 *
 * @param block A block to execute database code.
 */
+(void) transaction:(void (^)(YapDatabaseReadWriteTransaction *transaction))block;

/**
 * Create and execute a YapDatabaseReadWriteTransaction in a block asynchronously. Any shorthand methods in the block
 * will use the new transaction.
 *
 * This block is synchronous.
 *
 * @param block A block to execute database code.
 */
+(void) asyncTransaction:(void (^)(YapDatabaseReadWriteTransaction *transaction))block;

/**
 * Create and execute a YapDatabaseReadWriteTransaction in a block asynchronously. Any shorthand methods in the block
 * will use the new transaction.
 *
 * This block is synchronous.
 *
 * @param block A block to execute database code.
 * @param completion a block to be called upon completion of the transaction.
 */
+(void) asyncTransaction:(void (^)(YapDatabaseReadWriteTransaction *transaction))block completion:(void (^)(void))completion;

/**
 * Create and execute a YapDatabaseReadWriteTransaction in a block asynchronously. Any shorthand methods in the block
 * will use the new transaction.
 *
 * This block is synchronous.
 *
 * @param block A block to execute database code.
 * @param completion a block to be called upon completion of the transaction.
 * @param completionQueue the queue to run the completion code.
 */
+(void) asyncTransaction:(void (^)(YapDatabaseReadWriteTransaction *transaction))block completion:(void (^)(void))completion completionQueue:(dispatch_queue_t)completionQueue;

@end