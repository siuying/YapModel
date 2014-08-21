//
//  YapDatabaseSecondaryIndexConfiguratorSpec.m
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright 2014 Ignition Soft. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "YapDatabaseSecondaryIndexConfigurator.h"
#import "YapModelObject.h"
#import "TestHelper.h"

@interface Car : YapModelObject
@property (nonatomic, copy) NSString* name;
@property (nonatomic, assign) NSNumber* age;
@property (nonatomic, assign) NSNumber* price;
@property (nonatomic, assign) BOOL member;

@index(Car, CarAgePriceIndex, @"age": @(YapDatabaseSecondaryIndexTypeInteger), @"price": @(YapDatabaseSecondaryIndexTypeReal));

@end

@implementation Car
@end

SPEC_BEGIN(YapDatabaseSecondaryIndexConfiguratorSpec)

describe(@"YapDatabaseSecondaryIndexConfigurator", ^{
    __block YapDatabase* database;

    beforeEach(^{
        database = CreateDatabase();
    });
    
    afterEach(^{
        CleanupDatabase(database);
        database = nil;
    });
    
    context(@"+configureWithDatabase:", ^{
        it(@"should configure database by annotation", ^{
            [YapDatabaseSecondaryIndexConfigurator configureWithDatabase:database];
            NSDictionary* registeredExtensions = [database registeredExtensions];
            NSString* key = [[registeredExtensions allKeys] firstObject];
            [[key should] equal:@"CarAgePriceIndex"];
            
            YapDatabaseSecondaryIndex* index = [[registeredExtensions allValues] firstObject];
            [[index should] beKindOfClass:[YapDatabaseSecondaryIndex class]];
        });
    });
});

SPEC_END
