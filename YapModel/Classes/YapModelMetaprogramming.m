//
//  YapModelMetaprogramming.m
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapModelMetaprogramming.h"
#import "YapDatabaseSecondaryIndexConfigurator.h"

void ym_addIndexToClass(Class targetClass, NSString* indexName, NSDictionary* indexSelectors){
    [YapDatabaseSecondaryIndexConfigurator registerIndexWithClass:targetClass
                                                        indexName:indexName
                                                        selectors:indexSelectors];
};

void ym_addTextIndexToClass(id targetClass, NSString* indexName, NSArray* indexSelectors){
    [YapDatabaseSecondaryIndexConfigurator registerIndexWithClass:targetClass
                                                        indexName:indexName
                                                             type:YapDatabaseSecondaryIndexTypeText
                                                        selectors:indexSelectors];
};

void ym_addRealIndexToClass(id targetClass, NSString* indexName, NSArray* indexSelectors){
    [YapDatabaseSecondaryIndexConfigurator registerIndexWithClass:targetClass
                                                        indexName:indexName
                                                             type:YapDatabaseSecondaryIndexTypeReal
                                                        selectors:indexSelectors];
};

void ym_addIntegerIndexToClass(id targetClass, NSString* indexName, NSArray* indexSelectors)
{
    [YapDatabaseSecondaryIndexConfigurator registerIndexWithClass:targetClass
                                                        indexName:indexName
                                                             type:YapDatabaseSecondaryIndexTypeInteger
                                                        selectors:indexSelectors];
};