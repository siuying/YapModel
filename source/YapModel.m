//
//  YapModel.m
//  YapModel
//
//  Created by Francis Chong on 8/22/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <YapDatabase/YapDatabase.h>
#import "YapModel.h"
#import "YapDatabaseSecondaryIndexConfigurator.h"
#import "YapDatabaseViewConfigurator.h"
#import "YapDatabaseSearchViewConfigurator.h"

@implementation YapModel

+(void) setupDatabse:(YapDatabase*)database
{
    [YapDatabaseSecondaryIndexConfigurator setupIndicesWithDatabase:database];
    [YapDatabaseViewConfigurator setupViewsWithDatabase:database];
    [YapDatabaseSearchViewConfigurator setupViewsWithDatabase:database];
    
    [YapDatabaseViewConfigurator setupAdditionalViewsFromViewProvidersWithDatabase:database];
    
}

@end