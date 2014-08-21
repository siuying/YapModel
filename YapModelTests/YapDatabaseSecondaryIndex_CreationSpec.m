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
        __block NSString* ageIndex2;
        __block NSString* nameIndex;
        beforeEach(^{
            connection = [database newConnection];
            ageIndex = @"index-age";
            ageIndex2 = @"index-age2";
            nameIndex = @"index-name";
            CreateTestRecords(connection);
        });
        
        context(@"+indexWithClass:selector:type", ^{
            __block Person* person;
            
            it(@"should create a view with the specific model class", ^{
                YapDatabaseSecondaryIndex* index = [YapDatabaseSecondaryIndex indexWithClass:[Person class]
                                                                                    selector:@selector(age)
                                                                                        type:YapDatabaseSecondaryIndexTypeInteger];
                [database registerExtension:index withName:ageIndex];
                
                YapDatabaseSecondaryIndex* index2 = [YapDatabaseSecondaryIndex indexWithClass:[Person class]
                                                                                     selector:@selector(name)
                                                                                         type:YapDatabaseSecondaryIndexTypeText];
                [database registerExtension:index2 withName:nameIndex];
                
                YapDatabaseSecondaryIndex* index3 = [YapDatabaseSecondaryIndex indexWithClass:[Person class]
                                                                                     selector:@selector(age)
                                                                                         type:YapDatabaseSecondaryIndexTypeReal];
                [database registerExtension:index3 withName:ageIndex2];

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
                
                // find by age (using Real number index)
                [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
                    YapDatabaseQuery* query = [YapDatabaseQuery queryWithFormat:@"WHERE age = ?", @33];
                    person = [Person findFirstWithIndex:ageIndex2 query:query transaction:transaction];
                }];
                
                [[person should] beNonNil];
                [[theValue(person.age) should] equal:theValue(33)];
                [[person.name should] equal:@"Person3"];
            });
        });
    });
});

SPEC_END
