//
//  YapDatabaseViewShorthandSpec.m
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright 2014 Ignition Soft. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "YapDatabaseView+Creation.h"

#import "YapModel.h"
#import "YapDatabase.h"
#import "YapDatabaseSecondaryIndex.h"
#import "YapDatabaseExtension.h"
#import "YapDatabaseManager.h"

#import "Person.h"
#import "Company.h"
#import "TestHelper.h"

SPEC_BEGIN(YapDatabaseViewCreationSpec)

describe(@"YapDatabaseView+Creation", ^{
    __block YapDatabase* database;

    void(^CreateTestRecords)(YapDatabaseConnection*) = ^(YapDatabaseConnection* connection){
        [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            for(int i = 0; i < 10; i++) {
                Person* person = [Person new];
                person.name = [NSString stringWithFormat:@"Person%d", i];
                person.age = 30 + i;
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

    context(@"+viewWithCollection:groupBy:sortBy:version:", ^{
        __block YapDatabaseConnection* connection;

        beforeEach(^{
            connection = [database newConnection];
        });

        it(@"should create a view with the specific model class", ^{
            NSString* viewName = @"viewByPerson";
            YapDatabaseView* view = [YapDatabaseView viewWithCollection:[Person collectionName]
                                                            groupByKeys:@[@"age"]
                                                             sortByKeys:@[@"age"]
                                                                version:1];
            BOOL registered = [database registerExtension:view withName:viewName];
            [[theValue(registered) should] beTrue];

            CreateTestRecords(connection);
            
            __block Person* person;
            [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                person = [[transaction ext:viewName] objectAtIndex:0 inGroup:@"30"];
            }];

            [[person should] beNonNil];
            [[theValue(person.age) should] equal:theValue(30)];
            [[person.name should] equal:@"Person0"];
            
            [database unregisterExtension:viewName];
        });
    });
});

SPEC_END
