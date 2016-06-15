//
//  YapModelObject.m
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <YapDatabase/YapDatabase.h>
#import <AutoCoding/AutoCoding.h>

#import "YapModelObject.h"
#import "YapDatabaseRelationshipConfigurator.h"

@implementation YapModelObject

-(instancetype) init
{
    self = [super init];
    _key = [[NSUUID UUID] UUIDString];
    return self;
}

+(NSString*) collectionName
{
    return NSStringFromClass([self class]);
}

-(NSArray*) yapDatabaseRelationshipEdges {
    if (![YapDatabaseRelationshipConfigurator hasRelationshipConfigurationWithClassName:NSStringFromClass([self class])]) {
        return nil;
    }

    return [YapDatabaseRelationshipConfigurator edgesWithInstance:self];
}

@end
