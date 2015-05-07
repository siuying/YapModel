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
                person.salary = 1000 * (i % 3);
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

    context(@"+viewWithCollection:groupBy:sortBy:versionTag:", ^{
        __block YapDatabaseConnection* connection;

        beforeEach(^{
            connection = [database newConnection];
        });

        it(@"should create a view", ^{
            NSString* viewName = @"viewByPerson";
            YapDatabaseView* view = [YapDatabaseView viewWithCollection:[Person collectionName]
                                                            groupByKeys:@[@"age"]
                                                             sortByKeys:@[@"age"]
                                                             versionTag:@"1"];
            [[view.versionTag should] equal:@"1"];
            BOOL registered = [database registerExtension:view withName:viewName];
            [[theValue(registered) should] beTrue];

            CreateTestRecords(connection);
            
            __block Person* person;
            [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                [[[[transaction ext:viewName] allGroups] should] containObjects:@"30", nil];
                person = [[transaction ext:viewName] objectAtIndex:0 inGroup:@"30"];
            }];

            [[person should] beNonNil];
            [[theValue(person.age) should] equal:theValue(30)];
            [[person.name should] equal:@"Person0"];
            
            [database unregisterExtensionWithName:viewName];
        });
        
        it(@"should create a view with multiple sort by keys", ^{
            NSString* viewName = @"viewByPerson2";
            YapDatabaseView* view = [YapDatabaseView viewWithCollection:[Person collectionName]
                                                            groupByKeys:@[@"salary"]
                                                             sortByKeys:@[@"salary", @"name"]
                                                             versionTag:@"1"];
            [[view.versionTag should] equal:@"1"];

            BOOL registered = [database registerExtension:view withName:viewName];
            [[theValue(registered) should] beTrue];
            
            CreateTestRecords(connection);
            
            __block Person* person;
            [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                person = [[transaction ext:viewName] objectAtIndex:0 inGroup:@"2000"];
            }];
            
            [[person should] beNonNil];
            [[theValue(person.age) should] equal:theValue(32)];
            [[theValue(person.salary) should] equal:theValue(2000)];
            [[person.name should] equal:@"Person2"];
            
            [database unregisterExtensionWithName:viewName];
        });
    });
    
    context(@"+viewWithCollection:groupBy:sortBy:", ^{
        __block YapDatabaseConnection* connection;
        
        beforeEach(^{
            connection = [database newConnection];
        });
        
        it(@"should create a view", ^{
            NSString* viewName = @"viewByPerson";
            YapDatabaseView* view = [YapDatabaseView viewWithCollection:[Person collectionName]
                                                            groupByKeys:@[@"age"]
                                                             sortByKeys:@[@"age"]];
            [[view.versionTag should] equal:@"age-age"];

            BOOL registered = [database registerExtension:view withName:viewName];
            [[theValue(registered) should] beTrue];
            
            CreateTestRecords(connection);
            
            __block Person* person;
            [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                [[[[transaction ext:viewName] allGroups] should] containObjects:@"30", nil];
                person = [[transaction ext:viewName] objectAtIndex:0 inGroup:@"30"];
            }];
            
            [[person should] beNonNil];
            [[theValue(person.age) should] equal:theValue(30)];
            [[person.name should] equal:@"Person0"];
            
            [database unregisterExtensionWithName:viewName];
        });
        
        it(@"should create a view with multiple sort by keys", ^{
            NSString* viewName = @"viewByPerson2";
            YapDatabaseView* view = [YapDatabaseView viewWithCollection:[Person collectionName]
                                                            groupByKeys:@[@"salary"]
                                                             sortByKeys:@[@"salary", @"name"]];
            [[view.versionTag should] equal:@"salary-salary-name"];

            BOOL registered = [database registerExtension:view withName:viewName];
            [[theValue(registered) should] beTrue];
            
            CreateTestRecords(connection);
            
            __block Person* person;
            [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                person = [[transaction ext:viewName] objectAtIndex:0 inGroup:@"2000"];
            }];
            
            [[person should] beNonNil];
            [[theValue(person.age) should] equal:theValue(32)];
            [[theValue(person.salary) should] equal:theValue(2000)];
            [[person.name should] equal:@"Person2"];
            
            [database unregisterExtensionWithName:viewName];
        });
        
        it(@"should use a default versionTag when no keys supplied", ^{
            YapDatabaseView* view = [YapDatabaseView viewWithCollection:[Person collectionName]
                                                            groupByKeys:nil
                                                             sortByKeys:nil];
            [[view.versionTag shouldNot] beNil];
        });
    });

});

SPEC_END
