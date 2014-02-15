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

SPEC_BEGIN(YapModelObjectCRUDSpec)

describe(@"YapModelObject+CRUD", ^{
    context(@"Default Transaction", ^{
        __block YapDatabaseConnection* connection;
        beforeEach(^{
            connection = [[YapModelManager sharedManager] connection];
            [[connection shouldNot] beNil];
        });
        
        afterEach(^{
            [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                [transaction removeAllObjectsInAllCollections];
            }];
        });
        
        context(@"+find:", ^{
            it(@"should find the object with key", ^{
                [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    Person* john = [Person new];
                    john.name = @"John";
                    john.key = @"1";
                    [john saveWithTransaction:transaction];
                }];
                
                Person* john = [Person find:@"1"];
                [[john.name should] equal:@"John"];
            });
        });
        
        context(@"+findWithKeys:", ^{
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
                
                NSArray* people = [Person findWithKeys:@[@"1"]];
                [[theValue([people count]) should] equal:theValue(1)];
                
                [people enumerateObjectsUsingBlock:^(Person* person, NSUInteger idx, BOOL *stop) {
                    [[@[@"John"] should] containObjects:person.name, nil];
                }];
            });
        });
        
        context(@"-count", ^{
            it(@"should return 0 when no objects",  ^{
                [[theValue([Person count]) should] equal:theValue(0)];
            });
            
            it(@"should return 1 when there is one object", ^{
                [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    Person* john = [[Person alloc] init];
                    john.key = [[NSUUID UUID] UUIDString];
                    [transaction setObject:john forKey:john.key inCollection:[Person collectionName]];
                }];

                NSUInteger count = [Person count];
                [[theValue(count) should] equal:theValue(1)];
            });
        });
        
        context(@"-save", ^{
            it(@"should save an object with a new key", ^{
                [[theBlock(^{
                    Person* john = [Person new];
                    john.name = @"John";
                    john.age = 22;
                    john.member = NO;
                    [john save];
                    
                    [[john.key shouldNot] beNil];
                }) should] change:^NSInteger{
                    return [Person count];
                } by:1];
            });
            
            it(@"should update an object with existing UUID", ^{
                [[theBlock(^{
                    Person* john = [Person new];
                    john.name = @"John";
                    john.age = 22;
                    john.member = NO;
                    [john save];
                    
                    NSString* key = john.key;
                    [john save];
                    [[key should] equal:john.key];
                }) should] change:^NSInteger{
                    return [Person count];
                } by:1];
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
                [[theBlock(^{
                    [john delete];
                }) should] change:^NSInteger{
                    return [Person count];
                } by:-1];
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
                [[theValue([Person count]) should] equal:theValue(10)];
                [Person deleteAll];
                [[theValue([Person count]) should] equal:theValue(0)];
                [[theValue([Company count]) should] equal:theValue(1)];
            });
        });
        
        context(@"-create", ^{
            it(@"should create a new object with key set", ^{
                [[theBlock(^{
                    Person* newPerson = [Person create];
                    [[newPerson.key shouldNot] beNil];
                }) should] change:^NSInteger{
                    return [Person count];
                } by:1];
            });
        });
        
        context(@"-create:", ^{
            it(@"should create a new object with parameters", ^{
                [[theBlock(^{
                    Person* john = [Person create:@{@"name": @"John", @"age": @20}];
                    [[john shouldNot] beNil];
                    [[john.key shouldNot] beNil];
                    [[john.name should] equal:@"John"];
                    [[theValue(john.age) should] equal:theValue(20)];
                }) should] change:^NSInteger{
                    return [Person count];
                } by:1];
            });
        });
        
        context(@"-update:", ^{
            __block Person* john;
            beforeEach(^{
                john = [Person create:@{@"name": @"John", @"age": @20}];
            });
            
            it(@"should update existing object", ^{
                // create object
                [john update:@{@"age": @21}];
                [[theValue(john.age) should] equal:theValue(21)];
            });
        });
        
        context(@"-all", ^{
            beforeEach(^{
                // create some people
                for(int i = 0; i < 10; i++) {
                    Person* person = [Person new];
                    person.name = [NSString stringWithFormat:@"Person%d", i];
                    [person save];
                }
                
                Company* company = [Company new];
                [company save];
            });
            
            it(@"should get all objects of the class in database", ^{
                NSArray* all = [Person all];
                [[theValue(all.count) should] equal:theValue(10)];
                [all enumerateObjectsUsingBlock:^(Person* person, NSUInteger idx, BOOL *stop) {
                    [[[person name] shouldNot] beNil];
                }];
            });
        });
    });

    context(@"Custom Transaction", ^{
        __block YapDatabaseConnection* connection;
        beforeEach(^{
            connection = [[YapModelManager sharedManager] connection];
            [[connection shouldNot] beNil];
        });
        
        afterEach(^{
            [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                [transaction removeAllObjectsInAllCollections];
            }];
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
