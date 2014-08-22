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
#import "YapDatabaseViewConfigurator.h"
#import "YapDatabaseRelationshipConfigurator.h"

#import "YapModelObject.h"
#import "TestHelper.h"
#import "YapDatabaseRelationshipEdge.h"

@interface Driver : YapModelObject
@property (nonatomic, strong) NSString* name;

@hasMany(Driver, carsKey, cars, YDB_DeleteDestinationIfSourceDeleted);
@hasOne(Driver, licenseKey, license, YDB_DeleteDestinationIfSourceDeleted);
@belongsTo(Driver, companyKey, company, YDB_DeleteDestinationIfSourceDeleted);
@hasOneFile(Driver, pictureFilePath, picture, YDB_DeleteDestinationIfSourceDeleted);

@end

@implementation Driver
@end

@interface Car : YapModelObject
@property (nonatomic, copy) NSString* name;
@property (nonatomic, assign) NSUInteger age;
@property (nonatomic, assign) CGFloat price;
@property (nonatomic, assign) BOOL member;

// index meta programming
@index(Car, CarAgePriceIndex, @"age": @(YapDatabaseSecondaryIndexTypeInteger), @"price": @(YapDatabaseSecondaryIndexTypeReal));
@indexText(Car, CarNameIndex, @"name");
@indexInteger(Car, CarAgeIndex, @"age");
@indexReal(Car, CarPriceIndex, @"price");
@indexInteger(Car, CarAgeMemberIndex, @"age", @"member");

// view meta programming
@view(Car, CarView, @"group": @[@"age"], @"sort": @[@"price"]);
@end

@implementation Car
@end

SPEC_BEGIN(YapModelMetaprogrammingSpec)

describe(@"YapModelMetaprogramming", ^{
    describe(@"YapDatabaseSecondaryIndexConfigurator", ^{
        context(@"+indicesConfigurationWithClass:", ^{
            it(@"should return settings from metaprogramming", ^{
                NSDictionary* indices = [YapDatabaseSecondaryIndexConfigurator indicesConfigurationWithClassName:NSStringFromClass([Car class])];
                [[(indices[@"CarAgePriceIndex"]) should] equal:@{@"age": @(YapDatabaseSecondaryIndexTypeInteger), @"price": @(YapDatabaseSecondaryIndexTypeReal)}];
                [[(indices[@"CarNameIndex"]) should] equal:@{@"name": @(YapDatabaseSecondaryIndexTypeText)}];
                [[(indices[@"CarAgeIndex"]) should] equal:@{@"age": @(YapDatabaseSecondaryIndexTypeInteger)}];
                [[(indices[@"CarPriceIndex"]) should] equal:@{@"price": @(YapDatabaseSecondaryIndexTypeReal)}];
                [[(indices[@"CarAgeMemberIndex"]) should] equal:@{@"age": @(YapDatabaseSecondaryIndexTypeInteger), @"member": @(YapDatabaseSecondaryIndexTypeInteger)}];
            });
        });
    });
    
    describe(@"YapDatabaseViewConfigurator", ^{
        context(@"+viewsConfigurationWithClass:", ^{
            it(@"should return config from metaprogramming", ^{
                NSDictionary* viewConfig = [YapDatabaseViewConfigurator viewsConfigurationWithClassName:NSStringFromClass([Car class])];
                NSDictionary* carViewConfig = viewConfig[@"CarView"];
                [[carViewConfig[@"group"] should] equal:@[@"age"]];
                [[carViewConfig[@"sort"] should] equal:@[@"price"]];
            });
        });
    });
    
    describe(@"YapDatabaseRelationshipConfigurator", ^{
        context(@"+viewsConfigurationWithClass:", ^{
            it(@"should return config from metaprogramming", ^{
                NSDictionary* relation = [YapDatabaseRelationshipConfigurator relationshipConfigurationWithClassName:NSStringFromClass([Driver class])];
                [[relation[@"cars"] should] equal:@{@"type": @"has_many",
                                                    @"key": @"carsKey",
                                                    @"rule": @(YDB_DeleteDestinationIfSourceDeleted),
                                                    @"edge": @"cars"}];
                [[relation[@"license"] should] equal:@{@"type": @"has_one",
                                                       @"key": @"licenseKey",
                                                       @"rule": @(YDB_DeleteDestinationIfSourceDeleted),
                                                       @"edge": @"license"}];
                [[relation[@"company"] should] equal:@{@"type": @"belongs_to",
                                                       @"key": @"companyKey",
                                                       @"rule": @(YDB_DeleteDestinationIfSourceDeleted),
                                                       @"edge": @"company"}];
                [[relation[@"picture"] should] equal:@{@"type": @"has_one_file",
                                                       @"key": @"pictureFilePath",
                                                       @"rule": @(YDB_DeleteDestinationIfSourceDeleted),
                                                       @"edge": @"picture"}];

            });
            
            it(@"should add property to class", ^{
                Driver* driver = [Driver new];
                driver.carsKey = @[@"c1"];
                driver.licenseKey = @"1";
                driver.companyKey = @"2";
                driver.pictureFilePath = @"/tmp/1.png";

                [[driver.carsKey should] equal:@[@"c1"]];
                [[driver.licenseKey should] equal:@"1"];
                [[driver.companyKey should] equal:@"2"];
                [[driver.pictureFilePath should] equal:@"/tmp/1.png"];
            });
        });
    });
});

SPEC_END
