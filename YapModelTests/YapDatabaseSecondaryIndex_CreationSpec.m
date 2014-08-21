//
//  YapDatabaseSecondaryIndex_CreationSpec.m
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright 2014 Ignition Soft. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "YapDatabaseSecondaryIndex+Creation.h"

#import "YapModel.h"
#import "YapDatabase.h"
#import "YapDatabaseSecondaryIndex.h"
#import "YapDatabaseSecondaryIndexTransaction.h"

#import "YapDatabaseExtension.h"
#import "YapDatabaseManager.h"

#import "Person.h"
#import "Company.h"
#import "TestHelper.h"

SPEC_BEGIN(YapDatabaseSecondaryIndex_CreationSpec)

describe(@"YapDatabaseSecondaryIndex_Creation", ^{
    __block YapDatabase* database;
    
    void(^CreateTestRecords)(YapDatabaseConnection*) = ^(YapDatabaseConnection* connection){
        [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            for(int i = 0; i < 10; i++) {
                Person* person = [Person new];
                person.name = [NSString stringWithFormat:@"Person%d", i];
                person.age = 30 + i;
                person.salary = 150 * i;
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
    
    context(@"indexes", ^{
        __block YapDatabaseConnection* connection;
        __block NSString* ageIndex;
        __block NSString* salaryIndex;
        __block NSString* nameIndex;
        beforeEach(^{
            connection = [database newConnection];
            ageIndex = @"index-age";
            salaryIndex = @"index-salary";
            nameIndex = @"index-name";
            CreateTestRecords(connection);
        });
        
        context(@"+indexWithClass:properties:", ^{
            __block Person* person;
            
            it(@"should create index using a property", ^{
                YapDatabaseSecondaryIndex* index = [YapDatabaseSecondaryIndex indexWithClass:[Person class]
                                                                                  properties:@{@"age": @(YapDatabaseSecondaryIndexTypeInteger)}];
                [database registerExtension:index withName:ageIndex];
                
                YapDatabaseSecondaryIndex* index2 = [YapDatabaseSecondaryIndex indexWithClass:[Person class]
                                                                                   properties:@{@"name": @(YapDatabaseSecondaryIndexTypeText)}];
                [database registerExtension:index2 withName:nameIndex];
                
                YapDatabaseSecondaryIndex* index3 = [YapDatabaseSecondaryIndex indexWithClass:[Person class]
                                                                                   properties:@{@"salary": @(YapDatabaseSecondaryIndexTypeReal)}];
                [database registerExtension:index3 withName:salaryIndex];

                // find by age
                [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
                    YapDatabaseQuery* query = [YapDatabaseQuery queryWithFormat:@"WHERE age = ?", @33];
                    person = [Person findFirstWithIndex:ageIndex query:query transaction:transaction];
                }];
                
                [[person should] beNonNil];
                [[theValue(person.age) should] equal:theValue(33)];
                [[person.name should] equal:@"Person3"];
                
                // find by name
                [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
                    YapDatabaseQuery* query = [YapDatabaseQuery queryWithFormat:@"WHERE name = ?", @"Person8"];
                    person = [Person findFirstWithIndex:nameIndex query:query transaction:transaction];
                }];
                [[person should] beNonNil];
                [[theValue(person.age) should] equal:theValue(38)];
                [[person.name should] equal:@"Person8"];
                
                // find by salary
                [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
                    YapDatabaseQuery* query = [YapDatabaseQuery queryWithFormat:@"WHERE salary > ?", @1000];
                    person = [Person findFirstWithIndex:salaryIndex query:query transaction:transaction];
                }];
                
                [[person should] beNonNil];
                [[theValue(person.salary) should] equal:theValue(1050)];
                [[person.name should] equal:@"Person7"];
            });
            
            it(@"should create index using two property", ^{
                YapDatabaseSecondaryIndex* index = [YapDatabaseSecondaryIndex indexWithClass:[Person class]
                                                                                  properties:@{@"age": @(YapDatabaseSecondaryIndexTypeInteger), @"salary": @(YapDatabaseSecondaryIndexTypeReal)}];
                [database registerExtension:index withName:@"age-salary"];

                // find by age
                [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
                    YapDatabaseQuery* query = [YapDatabaseQuery queryWithFormat:@"WHERE age > ? and salary > ?", @38, @1000];
                    person = [Person findFirstWithIndex:@"age-salary" query:query transaction:transaction];
                }];
                
                [[person should] beNonNil];
                [[theValue(person.age) should] equal:theValue(39)];
                [[person.name should] equal:@"Person9"];
            });
        });
    });
});

SPEC_END
