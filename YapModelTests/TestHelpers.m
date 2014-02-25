//
//  TestHelpers.m
//  YapModel
//
//  Created by Francis Chong on 25/2/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "TestHelpers.h"
#import <math.h>

YapModelManager* CreateTestYapModelManager() {
    YapModelManager* manager = [[YapModelManager alloc] init];
    manager.databaseName = [NSString stringWithFormat:@"testing-%d.sqlite", arc4random()];
    return manager;
}

void CleanupYapModelManager(YapModelManager* manager) {
    NSError* error;
    YapDatabase* database = manager.database;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[database databasePath] error:&error];
    if (error) {
        NSLog(@"error: %@", error);
    }
}

@implementation TestHelpers
@end
