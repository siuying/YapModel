//
//  YapDatabaseManagerSpec.m
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright 2014 Ignition Soft. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "YapModelManager.h"

#import "DDLog.h"
#import "DDTTYLogger.h"

SPEC_BEGIN(YapModelManagerSpec)

describe(@"YapModelManager", ^{
    beforeAll(^{
        [DDLog removeAllLoggers];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
    });
    
    afterAll(^{
        [DDLog flushLog];
        [DDLog removeAllLoggers];
    });

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
    
    describe(@"-database", ^{
        it(@"should return default database", ^{
            YapModelManager* manager = [YapModelManager sharedManager];
            YapDatabase* db = [manager database];
            [[db shouldNot] beNil];
            [[[db databasePath] should] containString:@"YapModel.sqlite"];
        });
        
        it(@"should return database based on databaseName", ^{
            YapModelManager* manager = [[YapModelManager alloc] init];
            manager.databaseName = @"Hello.sqlite";
            YapDatabase* db = [manager database];
            [[db shouldNot] beNil];
            [[[db databasePath] should] containString:@"Hello.sqlite"];
        });
    });
    
    describe(@"-setDatabase:", ^{
        it(@"should set the db to a new db", ^{
            NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentPath = [searchPaths lastObject];
            NSString *databasePath = [documentPath stringByAppendingPathComponent:@"TestSetDatabase.sqlite"];
            YapDatabase* database = [[YapDatabase alloc] initWithPath:databasePath];
            YapModelManager* manager = [[YapModelManager alloc] init];
            [manager setDatabase:database];

            [[manager.database shouldNot] beNil];
            [[[manager.database databasePath] should] containString:@"TestSetDatabase.sqlite"];
            [[manager.connection shouldNot] beNil];
            [[[[[manager connection] database] databasePath] should] containString:@"TestSetDatabase.sqlite"];
        });
    });
});

SPEC_END
