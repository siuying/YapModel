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