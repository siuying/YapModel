//
//  YapDatabaseViewShorthandSpec.m
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright 2014 Ignition Soft. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "YapDatabaseView+Shorthand.h"

#import "YapModel.h"
#import "YapDatabase.h"
#import "YapDatabaseSecondaryIndex.h"
#import "YapDatabaseExtension.h"
#import "YapDatabaseManager.h"

#import "Person.h"
#import "Company.h"
#import "TestHelper.h"

SPEC_BEGIN(YapDatabaseViewShorthandSpec)

describe(@"YapDatabaseView+Shorthand", ^{
    __block YapDatabase* database;

    void(^CreateTestRecords)(YapDatabaseConnection*) = ^(YapDatabaseConnection* connection){
        [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            for(int i = 0; i < 30; i++) {
                Person* person = [Person new];
                person.name = [NSString stringWithFormat:@"Person%d", i];
                person.age = @(30 - i % 2);
                [person saveWithTransaction:transaction];
            }
            Company* company = [Company new];
            [company saveWithTransaction:transaction];
        }];
    };

    beforeEach(^{
        database = CreateDatabase();
    });

    afterEach(^{
        CleanupDatabase(database);
        database = nil;
    });

    context(@"-initWithModelClass:groupBy:sortBy:version:", ^{
        __block YapDatabaseConnection* connection;

        beforeEach(^{
            connection = [database newConnection];
        });

        it(@"should create a view with the specific model class", ^{
            NSString* viewName = @"viewByPerson";
            YapDatabaseView* view = [[YapDatabaseView alloc] initWithCollection:[Person collectionName] groupBy:@selector(age) sortBy:@selector(age) version:1];
            [database registerExtension:view withName:viewName];
            
            CreateTestRecords(connection);
            
            __block Person* person;
            [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                person = [[transaction ext:viewName] objectAtIndex:1 inGroup:@"30"];
            }];

            [[expectFutureValue(person.age) shouldEventually] equal:@30];
            [[expectFutureValue(person.name) shouldEventuallyBeforeTimingOutAfter(0.2)] equal:@"Person2"];
        });
        
        it(@"should ignore groupBy if it is nil", ^{
            
        });
    });
});

SPEC_END
