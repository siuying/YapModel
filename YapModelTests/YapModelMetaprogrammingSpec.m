//
//  YapModelMetaprogrammingSpec.m
//  YapModel
//
//  Created by Francis Chong on 8/22/14.
//  Copyright 2014 Ignition Soft. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "YapModelMetaprogramming.h"

#import "YapDatabaseSecondaryIndexConfigurator.h"
#import "YapModelObject.h"
#import "TestHelper.h"

@interface Car : YapModelObject
@property (nonatomic, copy) NSString* name;
@property (nonatomic, assign) NSNumber* age;
@property (nonatomic, assign) NSNumber* price;
@property (nonatomic, assign) BOOL member;

// index meta programming
@index(Car, CarAgePriceIndex, @"age": @(YapDatabaseSecondaryIndexTypeInteger), @"price": @(YapDatabaseSecondaryIndexTypeReal));
@indexText(Car, CarNameIndex, @"name");
@indexInteger(Car, CarAgeIndex, @"age");
@indexReal(Car, CarPriceIndex, @"price");
@indexInteger(Car, CarAgeMemberIndex, @"age", @"member");

// view meta programming
//@view(Car, CarView, @"group" => @[], @"sort" => @[]);

@end

@implementation Car
@end

SPEC_BEGIN(YapModelMetaprogrammingSpec)

describe(@"YapModelMetaprogramming", ^{
    describe(@"Index", ^{
        context(@"+indicesWithClass:", ^{
            it(@"should return settings from metaprogramming", ^{
                NSDictionary* indices = [YapDatabaseSecondaryIndexConfigurator indicesWithClass:[Car class]];
                [[(indices[@"CarAgePriceIndex"]) should] equal:@{@"age": @(YapDatabaseSecondaryIndexTypeInteger), @"price": @(YapDatabaseSecondaryIndexTypeReal)}];
                [[(indices[@"CarNameIndex"]) should] equal:@{@"name": @(YapDatabaseSecondaryIndexTypeText)}];
                [[(indices[@"CarAgeIndex"]) should] equal:@{@"age": @(YapDatabaseSecondaryIndexTypeInteger)}];
                [[(indices[@"CarPriceIndex"]) should] equal:@{@"price": @(YapDatabaseSecondaryIndexTypeReal)}];
                [[(indices[@"CarAgeMemberIndex"]) should] equal:@{@"age": @(YapDatabaseSecondaryIndexTypeInteger), @"member": @(YapDatabaseSecondaryIndexTypeInteger)}];
            });
        });
    });

});

SPEC_END
