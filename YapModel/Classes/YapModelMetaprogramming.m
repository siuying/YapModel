//
//  YapModelMetaprogramming.m
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapModelMetaprogramming.h"
#import "YapDatabaseSecondaryIndexConfigurator.h"

BOOL ym_addIndexToClass(Class targetClass, NSString* indexName, NSDictionary* indexSelectors){
    return [YapDatabaseSecondaryIndexConfigurator registerIndexWithClass:targetClass
                                                               indexName:indexName
                                                               selectors:indexSelectors];
};