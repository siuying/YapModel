//
//  YapModelSpec.m
//  YapModel
//
//  Created by Francis Chong on 2/26/14.
//  Copyright 2014 Ignition Soft. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "YapModel.h"
#import "Person.h"
#import "Employee.h"

SPEC_BEGIN(YapModelSpec)

describe(@"YapModel", ^{
    context(@"AutoCoding supports", ^{
        context(@"+codableProperties", ^{
            it(@"should include key and other properties", ^{
                NSDictionary* properties = [Person codableProperties];
                [[[properties allKeys] should] containObjects:@"name", @"age", @"member", nil];
                [[[properties allKeys] should] containObjects:@"key", nil];
            });
            
            it(@"should include key and other properties from super class", ^{
                NSDictionary* properties = [Employee codableProperties];
                [[[properties allKeys] should] containObjects:@"name", @"age", @"member", nil];
                [[[properties allKeys] should] containObjects:@"key", nil];
                [[[properties allKeys] should] containObjects:@"employeeID", nil];
            });
        });
    });
});

SPEC_END
