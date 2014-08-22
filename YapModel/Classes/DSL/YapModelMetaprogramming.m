//
//  YapModelMetaprogramming.m
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapModelMetaprogramming.h"
#import "YapDatabaseSecondaryIndexConfigurator.h"
#import "YapDatabaseViewConfigurator.h"
#import "YapDatabaseRelationshipConfigurator.h"

void ym_addIndexToClass(NSString* targetClassName, NSString* indexName, NSDictionary* indexSelectors){
    [YapDatabaseSecondaryIndexConfigurator configureIndexWithClassName:targetClassName
                                                             indexName:indexName
                                                             selectors:indexSelectors];
};

void ym_addTextIndexToClass(NSString* targetClassName, NSString* indexName, NSArray* indexSelectors){
    [YapDatabaseSecondaryIndexConfigurator configureIndexWithClassName:targetClassName
                                                             indexName:indexName
                                                                  type:YapDatabaseSecondaryIndexTypeText
                                                             selectors:indexSelectors];
};

void ym_addRealIndexToClass(NSString* targetClassName, NSString* indexName, NSArray* indexSelectors){
    [YapDatabaseSecondaryIndexConfigurator configureIndexWithClassName:targetClassName
                                                             indexName:indexName
                                                                  type:YapDatabaseSecondaryIndexTypeReal
                                                             selectors:indexSelectors];
};

void ym_addIntegerIndexToClass(NSString* targetClassName, NSString* indexName, NSArray* indexSelectors)
{
    [YapDatabaseSecondaryIndexConfigurator configureIndexWithClassName:targetClassName
                                                             indexName:indexName
                                                                  type:YapDatabaseSecondaryIndexTypeInteger
                                                             selectors:indexSelectors];
};

void ym_addViewToClass(NSString* targetClassName, NSString* viewName, NSDictionary* params)
{
    [YapDatabaseViewConfigurator configureViewWithClassName:targetClassName
                                                   viewName:viewName
                                                     params:params];
}

void ym_addHasMany(NSString* targetClassName, NSString* edgeName, NSString* childKey, YDB_NodeDeleteRules nodeRules)
{
    [YapDatabaseRelationshipConfigurator configureHasManyRelationshipWithClassName:targetClassName
                                                                          edgeName:edgeName
                                                                          childKey:childKey
                                                                   nodeDeleteRules:nodeRules];
}

void ym_addHasOne(NSString* targetClassName, NSString* edgeName, NSString* childKey, YDB_NodeDeleteRules nodeRules)
{
    [YapDatabaseRelationshipConfigurator configureHasOneRelationshipWithClassName:targetClassName
                                                                         edgeName:edgeName
                                                                         childKey:childKey
                                                                  nodeDeleteRules:nodeRules];
}

void ym_addBelongsTo(NSString* targetClassName, NSString* edgeName, NSString* parentKey, YDB_NodeDeleteRules nodeRules)
{
    [YapDatabaseRelationshipConfigurator configureBelongsToRelationshipWithClassName:targetClassName
                                                                            edgeName:edgeName
                                                                           parentKey:parentKey
                                                                     nodeDeleteRules:nodeRules];
}

void ym_addHasOneFile(NSString* targetClassName, NSString* edgeName, NSString* filePathKey, YDB_NodeDeleteRules nodeRules)
{
    [YapDatabaseRelationshipConfigurator configureHasOneFileRelationshipWithClassName:targetClassName
                                                                             edgeName:edgeName
                                                                          filePathKey:filePathKey
                                                                      nodeDeleteRules:nodeRules];
}

