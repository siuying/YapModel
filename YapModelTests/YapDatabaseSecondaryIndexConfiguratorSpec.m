//
//  YapDatabaseSecondaryIndexConfiguratorSpec.m
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright 2014 Ignition Soft. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <YapDatabase/YapDatabaseSecondaryIndex.h>
#import "YapDatabaseSecondaryIndexConfigurator.h"
#import "YapModelObject.h"
#import "TestHelper.h"

@interface IndexableItem : YapModelObject
@property (nonatomic, copy) NSString* name;
@end

@implementation IndexableItem
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
    
    context(@"+setupIndexWithDatabase:", ^{
        it(@"should configure database by registered index", ^{
            [YapDatabaseSecondaryIndexConfigurator configureIndexWithClassName:@"IndexableItem"
                                                                     indexName:@"ItemNameIndex"
                                                                     selectors:@{@"name": @(YapDatabaseSecondaryIndexTypeText)}];
            [YapDatabaseSecondaryIndexConfigurator setupIndicesWithDatabase:database];
            NSDictionary* registeredExtensions = [database registeredExtensions];
            NSArray* keys = [registeredExtensions allKeys];
            [[keys should] containObjects:@"ItemNameIndex", nil];

            YapDatabaseSecondaryIndex* index = [[registeredExtensions allValues] firstObject];
            [[index should] beKindOfClass:[YapDatabaseSecondaryIndex class]];
        });
    });
});

SPEC_END
