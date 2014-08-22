//
//  YapModelSpec.m
//  YapModel
//
//  Created by Francis Chong on 2/26/14.
//  Copyright 2014 Ignition Soft. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "YapModel.h"
#import "YapModelObject.h"
#import "Person.h"
#import "Employee.h"
#import "TestHelper.h"

@interface TestModel : YapModelObject
@property (nonatomic, copy) NSString* name;
@property (nonatomic, assign) NSUInteger age;

@index(TestModel, TestModelIndex, @"name": @(YapDatabaseSecondaryIndexTypeText));
@view(TestModel, TestModelView, @"group": @"name", @"sort": @"age");
@end

SPEC_BEGIN(YapModelSpec)

describe(@"YapModel", ^{
    context(@"AutoCoding supports", ^{
        context(@"+codableProperties", ^{
            it(@"should include key and other properties", ^{
                NSDictionary* properties = [Person codableProperties];
                [[[properties allKeys] should] containObjects:@"name", @"age", @"member", @"salary", nil];
                [[[properties allKeys] shouldNot] containObjects:@"key", nil];
            });
            
            it(@"should include key and other properties from super class", ^{
                NSDictionary* properties = [Employee codableProperties];
                [[[properties allKeys] shouldNot] containObjects:@"name", nil];
                [[[properties allKeys] shouldNot] containObjects:@"age", @"member", nil];
                [[[properties allKeys] shouldNot] containObjects:@"key", nil];
                [[[properties allKeys] should] containObjects:@"employeeID", nil];
            });
        });
    });
    
    context(@"+setupDatabase:", ^{
        __block YapDatabase* database;
        
        beforeEach(^{
            database = CreateDatabase();
        });
        
        afterEach(^{
            CleanupDatabase(database);
            database = nil;
        });

        it(@"should setup index and views for database", ^{
            [YapModel setupDatabse:database];
            
            NSArray* extensions = [[database registeredExtensions] allKeys];
            [[extensions should] containObjects:@"TestModelIndex", @"TestModelView", nil];
        });
    });
});

SPEC_END
