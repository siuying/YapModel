//
//  YapDatabaseManagerSpec.m
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright 2014 Ignition Soft. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "YapModelManager.h"

SPEC_BEGIN(YapModelManagerSpec)

describe(@"YapModelManager", ^{
    describe(@"+sharedManager", ^{
        it(@"should return shared instance of database manager", ^{
            YapModelManager* dbm = [YapModelManager sharedManager];
            YapModelManager* dbm2 = [YapModelManager sharedManager];
            [dbm shouldNotBeNil];
            [[dbm should] equal:dbm2];
        });

        it(@"should have the database name same as app name + .sqlite", ^{
            YapModelManager* dbm = [YapModelManager sharedManager];
            [dbm shouldNotBeNil];
            [[dbm.databaseName should] equal:@"YapModel.sqlite"];
        });

        it(@"should create a database", ^{
            YapModelManager* dbm = [YapModelManager sharedManager];
            YapDatabase* db = [dbm database];
            YapDatabase* db2 = [dbm database];
            [[db should] equal:db2];

            [[[db databasePath] should] containString:@"YapModel.sqlite"];
        });
    });
});

SPEC_END
