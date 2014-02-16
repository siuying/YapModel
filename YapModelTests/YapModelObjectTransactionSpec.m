//
//  YapModelObjectSpec.m
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright 2014 Ignition Soft. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "YapModel.h"
#import "YapDatabase.h"

#import "Person.h"
#import "Company.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

SPEC_BEGIN(YapModelObjectTransactionSpec)

describe(@"YapModelObject+Transaction", ^{
    __block YapDatabaseConnection* connection;

    beforeAll(^{
        connection = [[YapModelManager sharedManager] connection];
        [[connection shouldNot] beNil];
    });
    
    afterAll(^{
        [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [transaction removeAllObjectsInAllCollections];
        }];
    });

    context(@"+transaction:", ^{
        it(@"should create a transaction", ^{
            [Person transaction:^(YapDatabaseReadWriteTransaction* transaction){
                Person* john = [Person create:@{@"key": @"1", @"name": @"Leo"}];
                john.name = @"John";
                [john save];
            }];                Person* john = [Person find:@"1"];
            [[john.name should] equal:@"John"];
        });
    });
    
    context(@"+asyncTransaction:", ^{
        it(@"should create a transaction and run asynchronously", ^{
            __block BOOL completed = NO;
            [Person asyncTransaction:^(YapDatabaseReadWriteTransaction* transaction){
                Person* john = [Person create:@{@"key": @"1", @"name": @"Leo"}];
                john.name = @"John";
                [john save];
                completed = YES;
            }];
            [[expectFutureValue(theValue(completed)) shouldEventually] equal:theValue(YES)];
        });
    });
    
    context(@"+asyncTransaction:completion:", ^{
        it(@"should create a transaction and run asynchronously, and run the completion block", ^{
            __block BOOL completed = NO;
            __block BOOL completionBlockExecuted = NO;
            [Person asyncTransaction:^(YapDatabaseReadWriteTransaction* transaction){
                Person* john = [Person create:@{@"key": @"1", @"name": @"Leo"}];
                john.name = @"John";
                [john save];
                completed = YES;
            } completion:^{
                completionBlockExecuted = YES;
            }];
            [[expectFutureValue(theValue(completed)) shouldEventually] equal:theValue(YES)];
            [[expectFutureValue(theValue(completionBlockExecuted)) shouldEventually] equal:theValue(YES)];
        });
    });
    
    context(@"+asyncTransaction:completion:completionQueue:", ^{
        it(@"should create a transaction and run asynchronously, and run the completion block", ^{
            __block BOOL completed = NO;
            __block BOOL completionBlockExecuted = NO;
            [Person asyncTransaction:^(YapDatabaseReadWriteTransaction* transaction){
                Person* john = [Person create:@{@"key": @"1", @"name": @"Leo"}];
                john.name = @"John";
                [john save];
                completed = YES;
            } completion:^{
                completionBlockExecuted = YES;
            } completionQueue:dispatch_get_main_queue()];
            [[expectFutureValue(theValue(completed)) shouldEventually] equal:theValue(YES)];
            [[expectFutureValue(theValue(completionBlockExecuted)) shouldEventually] equal:theValue(YES)];
        });
    });
});

SPEC_END
