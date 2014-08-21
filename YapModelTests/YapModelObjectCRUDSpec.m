//
//  YapModelObjectSpec.m
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright 2014 Ignition Soft. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <math.h>

#import "YapModel.h"
#import "YapDatabase.h"
#import "YapDatabaseSecondaryIndex.h"
#import "YapDatabaseExtension.h"
#import "YapDatabaseManager.h"

#import "Person.h"
#import "Company.h"

@interface YapDatabaseExtension(Private)
- (BOOL)supportsDatabase:(YapDatabase *)database withRegisteredExtensions:(NSDictionary *)registeredExtensions;
@end

SPEC_BEGIN(YapModelObjectCRUDSpec)

describe(@"YapModelObject+CRUD", ^{
    __block YapDatabase* database;

    void(^SetupDatabaseIndex)(YapDatabase*) = ^(YapDatabase* database){
        YapDatabaseSecondaryIndexSetup *setup = [ [YapDatabaseSecondaryIndexSetup alloc] init];
        [setup addColumn:@"age" withType:YapDatabaseSecondaryIndexTypeInteger];

        YapDatabaseSecondaryIndexBlockType blockType = YapDatabaseSecondaryIndexBlockTypeWithObject;
        YapDatabaseSecondaryIndexWithObjectBlock block = ^(NSMutableDictionary *dict, NSString *collection, NSString *key, id object){
            if ([object isKindOfClass:[Person class]]) {
                Person *person = (Person *)object;
                [dict setObject:@(person.age) forKey:@"age"];
            }
        };
        YapDatabaseSecondaryIndex* index = [[YapDatabaseSecondaryIndex alloc] initWithSetup:setup block:block blockType:blockType];
        
        // for some reason the method return NO in test
        [index stub:@selector(supportsDatabase:withRegisteredExtensions:) andReturn:@YES];
        BOOL registered = [database registerExtension:index withName:@"index"];
        if (!registered) {
            NSLog(@"failed register extension: %@", index);
        }
    };
    
    void(^CreateTestRecords)(YapDatabaseConnection*) = ^(YapDatabaseConnection* connection){
        [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            for(int i = 0; i < 10; i++) {
                Person* person = [Person new];
                person.name = [NSString stringWithFormat:@"Person%d", i];
                person.age = i * 5;
                [person saveWithTransaction:transaction];
            }
            Company* company = [Company new];
            [company saveWithTransaction:transaction];
        }];
    };
    
    YapDatabase*(^CreateDatabase)(void) = ^{
        NSString* databaseName = [NSString stringWithFormat:@"testing-%d.sqlite", arc4random()];
        NSURL* documentDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                           inDomains:NSUserDomainMask] lastObject];
        NSString *databaseDir = [[documentDirectory path] stringByAppendingPathComponent:databaseName];
        return [[YapDatabase alloc] initWithPath:databaseDir];
    };
    
    beforeEach(^{
        database = CreateDatabase();
    });
    
    afterEach(^{
        NSError* error;
        NSString* path = database.databasePath;
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSString* directory = [path stringByDeletingLastPathComponent];
        NSString* filenamePrefix = [[path lastPathComponent] stringByDeletingPathExtension];
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:directory
                                                             error:&error];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self CONTAINS %@", filenamePrefix];
        for (NSString *filename in [contents filteredArrayUsingPredicate:predicate]) {
            NSLog(@"filename = %@", filename);
            [fileManager removeItemAtPath:[directory stringByAppendingPathComponent:filename]
                                    error:&error];
        }
    });

    context(@"Custom Transaction", ^{
        __block YapDatabaseConnection* connection;

        beforeEach(^{
            connection = [database newConnection];
        });

        afterEach(^{
            connection = nil;
        });

        context(@"+find:withTransaction:", ^{
            it(@"should find the object with key", ^{
                [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    Person* john = [Person new];
                    john.name = @"John";
                    john.key = @"1";
                    [john saveWithTransaction:transaction];
                }];

                [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
                    Person* john = [Person find:@"1" withTransaction:transaction];
                    [[john.name should] equal:@"John"];
                }];
            });
        });

        context(@"+findWithKeys:transaction:", ^{
            it(@"should find the object with key", ^{
                [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    Person* john = [Person new];
                    john.name = @"John";
                    john.key = @"1";
                    [john saveWithTransaction:transaction];
                    
                    Person* peter = [Person new];
                    peter.name = @"Peter";
                    peter.key = @"2";
                    [peter saveWithTransaction:transaction];
                }];

                [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
                    NSArray* people = [Person findWithKeys:@[@"1"] transaction:transaction];
                    [[theValue([people count]) should] equal:theValue(1)];
                    
                    [people enumerateObjectsUsingBlock:^(Person* person, NSUInteger idx, BOOL *stop) {
                        [[@[@"John"] should] containObjects:person.name, nil];
                    }];
                }];
            });
        });
        
        context(@"-findWithIndex:query:transaction:", ^{
            beforeEach(^{
                SetupDatabaseIndex(database);
                CreateTestRecords(connection);
            });
            
            afterEach(^{
                [database unregisterExtension:@"index"];
            });
            
            it(@"should find people with age < 16",  ^{
                [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
                    NSArray* people = [Person findWithIndex:@"index"
                                                      query:[YapDatabaseQuery queryWithFormat:@"WHERE age < ?", @(16)]
                                                transaction:transaction];
                    [[theValue([people count]) should] equal:theValue(4)];
                    
                    [people enumerateObjectsUsingBlock:^(Person* person, NSUInteger idx, BOOL *stop) {
                        [[theValue(person.age) should] beLessThan:theValue(16)];
                    }];
                }];
            });
        });
        
        context(@"-findFirstWithIndex:query:transaction:", ^{
            beforeEach(^{
                SetupDatabaseIndex(database);
                CreateTestRecords(connection);
            });
            
            afterEach(^{
                [database unregisterExtension:@"index"];
            });
            
            it(@"should find first person with age < 16",  ^{
                [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
                    Person* person = [Person findFirstWithIndex:@"index"
                                                          query:[YapDatabaseQuery queryWithFormat:@"WHERE age < ?", @(16)]
                                                    transaction:transaction];
                    [[theValue(person.age) should] equal:theValue(0)];
                }];
            });
        });
        
        context(@"+where:withTransaction:", ^{
            beforeEach(^{
                // create some people
                CreateTestRecords(connection);
            });
            
            it(@"should find the object with filter", ^{
                [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    NSArray* people = [Person where:^BOOL(Person* person) {
                        return person.age < 30;
                    } withTransaction:transaction];
                    [[theValue([people count]) should] equal:theValue(6)];
                }];
            });
        });

        context(@"-countWithTransaction:", ^{
            it(@"should return 0 when no objects",  ^{
                [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
                    [[theValue([Person countWithTransaction:transaction]) should] equal:theValue(0)];
                }];
            });
            
            it(@"should return 1 when there is one object", ^{
                [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    Person* john = [[Person alloc] init];
                    john.key = [[NSUUID UUID] UUIDString];
                    [transaction setObject:john forKey:john.key inCollection:[Person collectionName]];
                    
                    NSUInteger count = [Person countWithTransaction:transaction];
                    [[theValue(count) should] equal:theValue(1)];
                }];
            });
        });
        
        context(@"-saveWithTransaction:", ^{
            it(@"should save an object with a new key", ^{
                [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    [[theBlock(^{
                        Person* john = [Person new];
                        john.name = @"John";
                        john.age = 22;
                        john.member = NO;
                        [john saveWithTransaction:transaction];
                        
                        [[john.key shouldNot] beNil];
                    }) should] change:^NSInteger{
                        return [Person countWithTransaction:transaction];
                    } by:1];
                }];
            });
            
            it(@"should update an object with existing UUID", ^{
                [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    [[theBlock(^{
                        Person* john = [Person new];
                        john.name = @"John";
                        john.age = 22;
                        john.member = NO;
                        [john saveWithTransaction:transaction];
                        
                        NSString* key = john.key;
                        [john saveWithTransaction:transaction];
                        [[key should] equal:john.key];
                    }) should] change:^NSInteger{
                        return [Person countWithTransaction:transaction];
                    } by:1];
                }];
            });
        });
        
        context(@"-deleteWithTransaction:", ^{
            __block Person* john;

            beforeEach(^{
                [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    john = [Person new];
                    john.name = @"John";
                    john.age = 22;
                    john.member = NO;
                    [john saveWithTransaction:transaction];
                }];
            });

            it(@"should delete an object", ^{
                [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    [[theBlock(^{
                        [john deleteWithTransaction:transaction];
                    }) should] change:^NSInteger{
                        return [Person countWithTransaction:transaction];
                    } by:-1];
                }];
            });
        });
        
        context(@"+deleteAllWithTransaction:", ^{
            beforeEach(^{
                // create some people
                [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    for(int i = 0; i < 10; i++) {
                        Person* person = [Person new];
                        person.name = [NSString stringWithFormat:@"Person%d", i];
                        [person saveWithTransaction:transaction];
                    }

                    Company* company = [Company new];
                    [company saveWithTransaction:transaction];
                }];
            });

            it(@"should delete all objects of the class", ^{
                [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    [[theValue([Person countWithTransaction:transaction]) should] equal:theValue(10)];
                    [Person deleteAllWithTransaction:transaction];
                    [[theValue([Person countWithTransaction:transaction]) should] equal:theValue(0)];
                    [[theValue([Company countWithTransaction:transaction]) should] equal:theValue(1)];
                }];
            });
        });
        
        context(@"-createWithTransaction:", ^{
            it(@"should create a new object with key set", ^{
                [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    [[theBlock(^{
                        Person* newPerson = [Person createWithTransaction:transaction];
                        [[newPerson.key shouldNot] beNil];
                    }) should] change:^NSInteger{
                        return [Person countWithTransaction:transaction];
                    } by:1];
                }];
            });
        });
        
        context(@"-create:withTransaction:", ^{
            it(@"should create a new object with parameters", ^{
                [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    [[theBlock(^{
                        Person* john = [Person create:@{@"name": @"John", @"age": @20} withTransaction:transaction];
                        [[john shouldNot] beNil];
                        [[john.key shouldNot] beNil];
                        [[john.name should] equal:@"John"];
                        [[theValue(john.age) should] equal:theValue(20)];
                    }) should] change:^NSInteger{
                        return [Person countWithTransaction:transaction];
                    } by:1];
                }];
            });
        });
        
        context(@"-update:withTransaction:", ^{
            __block Person* john;
            beforeEach(^{
                // create object
                [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    john = [Person create:@{@"name": @"John", @"age": @20} withTransaction:transaction];
                }];
            });
            
            it(@"should update existing object", ^{
                // create object
                [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    [john update:@{@"age": @21} withTransaction:transaction];
                }];
                [[theValue(john.age) should] equal:theValue(21)];
            });
        });
        
        context(@"-allWithTransaction:", ^{
            beforeEach(^{
                // create some people
                CreateTestRecords(connection);
            });

            it(@"should get all objects of the class in database", ^{
                // create object
                [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    NSArray* all = [Person allWithTransaction:transaction];
                    [[theValue(all.count) should] equal:theValue(10)];
                    [all enumerateObjectsUsingBlock:^(Person* person, NSUInteger idx, BOOL *stop) {
                        [[[person name] shouldNot] beNil];
                    }];
                }];
            });
        });
    });
});

SPEC_END
