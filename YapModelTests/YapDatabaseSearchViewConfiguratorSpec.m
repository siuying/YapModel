//
//  YapDatabaseSearchViewConfiguratorSpec.m
//  YapModel
//
//  Created by Aleksei Shevchenko on 6/24/15.
//  Copyright (c) 2014 Aleksei Shevchenko. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "YapDatabaseSearchViewConfigurator.h"
#import "YapDatabaseViewConfigurator.h"
#import <YapDatabase/YapDatabaseView.h>
#import <YapDatabase/YapDatabaseSearchResultsView.h>
#import "YapModelObject.h"
#import "TestHelper.h"

@interface SearchItemForView : YapModelObject
@property (nonatomic, copy) NSString* name;
@end

@implementation SearchItemForView
@end

SPEC_BEGIN(YapDatabaseSearchViewConfiguratorSpec)

describe(@"YapDatabaseSearchViewConfigurator", ^{
    __block YapDatabase* database;
    NSString * viewName = @"ItemView";
    NSString * searchViewName = @"ItemSearchView";
    
    NSString * objectClassName = @"SearchItemForView";
    
    beforeEach(^{
        database = CreateDatabase();
    });
    
    afterEach(^{
        CleanupDatabase(database);
        database = nil;
    });
    
    context(@"+setupViewsWithDatabase:", ^{
        
        it(@"should configure database with search view", ^{
            
            //otherwise YapModelSpec will fail
//            if(![database registeredExtension:viewName])
//            {
//                [YapDatabaseViewConfigurator configureViewWithClassName:objectClassName
//                                                               viewName:viewName
//                                                                 params:@{@"group": @[], @"sort": @[@"name"]}];
//            }
//            
            
            [YapDatabaseSearchViewConfigurator configureViewWithClassName:objectClassName
                                                                 viewName:searchViewName
                                                                   params:@{@"parent":viewName, @"properties":@[@"name"]}];
            
            [YapDatabaseSearchViewConfigurator setupViewsWithDatabase:database];

            NSDictionary* registeredExtensions = [database registeredExtensions];
            NSArray* keys = [registeredExtensions allKeys];
            [[keys should] containsObject:viewName];

            YapDatabaseView* view = registeredExtensions[viewName];
            [[view should] beKindOfClass:[YapDatabaseSearchResultsView class]];
        });
//        
//        it(@"should configure database with view using a string value", ^{
//            [YapDatabaseSearchViewConfigurator configureViewWithClassName:@"ItemForView"
//                                                           viewName:@"ItemView2"
//                                                             params:@{@"sort": @"name"}];
//            [YapDatabaseSearchViewConfigurator setupViewsWithDatabase:database];
//            
//            NSDictionary* registeredExtensions = [database registeredExtensions];
//            NSArray* keys = [registeredExtensions allKeys];
//            [[keys should] containObjects:@"ItemView2", nil];
//            
//            YapDatabaseView* view = registeredExtensions[@"ItemView2"];
//            [[view should] beKindOfClass:[YapDatabaseView class]];
//        });
//        
//        it(@"should configure database with view using a string value with reverse sort marker", ^{
//            [YapDatabaseSearchViewConfigurator configureViewWithClassName:@"ItemForView"
//                                                           viewName:@"ItemView2Reverse"
//                                                             params:@{@"sort": @"-name"}];
//            [YapDatabaseSearchViewConfigurator setupViewsWithDatabase:database];
//            
//            NSDictionary* registeredExtensions = [database registeredExtensions];
//            NSArray* keys = [registeredExtensions allKeys];
//            [[keys should] containObjects:@"ItemView2Reverse", nil];
//            
//            YapDatabaseView* view = registeredExtensions[@"ItemView2Reverse"];
//            [[view should] beKindOfClass:[YapDatabaseView class]];
//        });
        
    });
});

SPEC_END
