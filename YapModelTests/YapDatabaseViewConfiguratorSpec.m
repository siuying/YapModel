//
//  YapDatabaseViewConfiguratorSpec.m
//  YapModel
//
//  Created by Francis Chong on 8/22/14.
//  Copyright 2014 Ignition Soft. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "YapDatabaseViewConfigurator.h"
#import "YapDatabaseView.h"
#import "YapModelObject.h"
#import "TestHelper.h"

@interface ItemForView : YapModelObject
@property (nonatomic, copy) NSString* name;
@end

@implementation ItemForView
@end

SPEC_BEGIN(YapDatabaseViewConfiguratorSpec)

describe(@"YapDatabaseViewConfigurator", ^{
    __block YapDatabase* database;
    
    beforeEach(^{
        database = CreateDatabase();
    });
    
    afterEach(^{
        CleanupDatabase(database);
        database = nil;
    });
    
    context(@"+setupViewsWithDatabase:", ^{
        it(@"should configure database with view using array value", ^{
            [YapDatabaseViewConfigurator configureViewWithClassName:@"ItemForView"
                                                           viewName:@"ItemView"
                                                             params:@{@"group": @[], @"sort": @[@"name"]}];
            [YapDatabaseViewConfigurator setupViewsWithDatabase:database];

            NSDictionary* registeredExtensions = [database registeredExtensions];
            NSArray* keys = [registeredExtensions allKeys];
            [[keys should] containObjects:@"ItemView", nil];

            YapDatabaseView* view = registeredExtensions[@"ItemView"];
            [[view should] beKindOfClass:[YapDatabaseView class]];
        });
        
        it(@"should configure database with view using a string value", ^{
            [YapDatabaseViewConfigurator configureViewWithClassName:@"ItemForView"
                                                           viewName:@"ItemView2"
                                                             params:@{@"sort": @"name"}];
            [YapDatabaseViewConfigurator setupViewsWithDatabase:database];
            
            NSDictionary* registeredExtensions = [database registeredExtensions];
            NSArray* keys = [registeredExtensions allKeys];
            [[keys should] containObjects:@"ItemView2", nil];
            
            YapDatabaseView* view = registeredExtensions[@"ItemView2"];
            [[view should] beKindOfClass:[YapDatabaseView class]];
        });
    });
});

SPEC_END
