//
//  YapDatabaseRelationConfiguratorSpec.m
//  YapModel
//
//  Created by Francis Chong on 8/22/14.
//  Copyright 2014 Ignition Soft. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "YapDatabaseRelationshipConfigurator.h"
#import "YapDatabaseSecondaryIndexConfigurator.h"
#import "YapModelObject.h"
#import "TestHelper.h"
#import <YapDatabase/YapDatabase.h>
#import <YapDatabase/YapDatabaseRelationshipEdge.h>
#import <YapDatabase/YapDatabaseRelationshipNode.h>


@interface TestTaskManager : YapModelObject
@property (nonatomic, copy) NSString* name;
@end

@implementation TestTaskManager
@end

@interface TaskList : YapModelObject
@property (nonatomic, copy) NSString* name;
@property (nonatomic, strong) NSArray* taskKeys;
@property (nonatomic, copy) NSString* taskManagerKey;
@end

@implementation TaskList
@end

@interface Task : YapModelObject
@property (nonatomic, copy) NSString* listKey;
@property (nonatomic, copy) NSString* text;
@property (nonatomic, copy) NSString* imageFilePath;
@property (nonatomic, assign) BOOL done;
@end

@implementation Task
@end

SPEC_BEGIN(YapDatabaseRelationshipConfiguratorSpec)

describe(@"YapDatabaseRelationshipConfigurator", ^{
    __block YapDatabase* database;
    
    beforeEach(^{
        database = CreateDatabase();
    });

    afterEach(^{
        CleanupDatabase(database);
        database = nil;
    });
    
    context(@"+configureHasManyRelationshipWithClassName:childKey:deleteRule:", ^{
        it(@"should config hasMany edges", ^{
            [YapDatabaseRelationshipConfigurator configureHasManyRelationshipWithClassName:@"TaskList"
                                                                              edgeName:@"task"
                                                                              childKey:@"taskKeys"
                                                                       nodeDeleteRules:(YDB_DeleteSourceIfAllDestinationsDeleted)];
            [YapDatabaseRelationshipConfigurator setupViewsWithDatabase:database];

            TaskList* taskList = [TaskList new];
            taskList.name = @"My List";
            
            Task* item1 = [Task new];
            item1.text = @"Hello";
            
            Task* item2 = [Task new];
            item2.text = @"World";
            
            taskList.taskKeys = @[item1.key, item2.key];
            
            NSArray* edges = [taskList yapDatabaseRelationshipEdges];
            [[edges should] haveCountOf:2];
            
            YapDatabaseRelationshipEdge* edge = [edges firstObject];
            [[edge.name should] equal:@"task"];
            [[edge.destinationKey should] equal:item1.key];
            [[theValue(edge.nodeDeleteRules) should] equal:theValue(YDB_DeleteSourceIfAllDestinationsDeleted)];
            
            edge = [edges lastObject];
            [[edge.name should] equal:@"task"];
            [[edge.destinationKey should] equal:item2.key];
            [[theValue(edge.nodeDeleteRules) should] equal:theValue(YDB_DeleteSourceIfAllDestinationsDeleted)];
            
        });
    });
    
    context(@"+configureHasOneRelationshipWithClassName:edgeName:childKey:nodeDeleteRules:", ^{
        it(@"should config hasMany edges", ^{
            [YapDatabaseRelationshipConfigurator configureHasOneRelationshipWithClassName:@"TaskList"
                                                                             edgeName:@"taskManager"
                                                                             childKey:@"taskManagerKey"
                                                                      nodeDeleteRules:(YDB_DeleteSourceIfAllDestinationsDeleted)];
            [YapDatabaseRelationshipConfigurator setupViewsWithDatabase:database];
            
            TestTaskManager* manager = [TestTaskManager new];
            TaskList* taskList = [TaskList new];
            taskList.name = @"My List";
            taskList.taskManagerKey = manager.key;
            
            NSArray* edges = [taskList yapDatabaseRelationshipEdges];
            [[edges should] haveCountOf:1];
            
            YapDatabaseRelationshipEdge* edge = [edges firstObject];
            [[edge.name should] equal:@"taskManager"];
            [[edge.destinationKey should] equal:manager.key];
            [[theValue(edge.nodeDeleteRules) should] equal:theValue(YDB_DeleteSourceIfAllDestinationsDeleted)];
        });
    });
    
    context(@"+configureBelongsToRelationshipWithClassName:edgeName:parentKey:nodeDeleteRules:", ^{
        it(@"should config hasMany edges", ^{
            [YapDatabaseRelationshipConfigurator configureBelongsToRelationshipWithClassName:@"Task"
                                                                                edgeName:@"list"
                                                                               parentKey:@"listKey"
                                                                         nodeDeleteRules:(YDB_DeleteDestinationIfSourceDeleted)];
            [YapDatabaseRelationshipConfigurator setupViewsWithDatabase:database];
            
            TaskList* taskList = [TaskList new];
            taskList.name = @"My List";
            
            Task* item1 = [Task new];
            item1.text = @"Hello";
            item1.listKey = taskList.key;
            
            Task* item2 = [Task new];
            item2.text = @"World";
            item2.listKey = taskList.key;

            taskList.taskKeys = @[item1.key, item2.key];
            
            NSArray* edges = [item1 yapDatabaseRelationshipEdges];
            [[edges should] haveCountOf:1];
            
            YapDatabaseRelationshipEdge* edge = [edges firstObject];
            [[edge.name should] equal:@"list"];
            [[edge.destinationKey should] equal:item1.listKey];
            [[theValue(edge.nodeDeleteRules) should] equal:theValue(YDB_DeleteDestinationIfSourceDeleted)];
        });
    });
    
    context(@"+configureHasOneFileRelationshipWithClassName:edgeName:filePathKey:nodeDeleteRules:", ^{
        it(@"should config file edges", ^{
            [YapDatabaseRelationshipConfigurator configureHasOneFileRelationshipWithClassName:@"Task"
                                                                                 edgeName:@"imageFile"
                                                                              filePathKey:@"imageFilePath"
                                                                          nodeDeleteRules:YDB_DeleteDestinationIfAllSourcesDeleted];
            [YapDatabaseRelationshipConfigurator setupViewsWithDatabase:database];
            
            Task* item1 = [Task new];
            item1.text = @"Hello";
            item1.imageFilePath = @"~/a.jpg";
            
            NSArray* edges = [item1 yapDatabaseRelationshipEdges];
            [[edges should] haveCountOf:1];
            
            YapDatabaseRelationshipEdge* edge = [edges firstObject];
            [[edge.name should] equal:@"imageFile"];
            [[edge.destinationFilePath should] equal:item1.imageFilePath];
            [[theValue(edge.nodeDeleteRules) should] equal:theValue(YDB_DeleteDestinationIfAllSourcesDeleted)];
        });
    });
});

SPEC_END
