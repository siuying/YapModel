//
//  TestHelpers.m
//  YapModel
//
//  Created by Francis Chong on 25/2/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "TestHelpers.h"
#import <math.h>
#import "YapDatabaseManager.h"

YapModelManager* CreateTestYapModelManager() {
    YapModelManager* manager = [[YapModelManager alloc] init];
    manager.databaseName = [NSString stringWithFormat:@"testing-%d.sqlite", arc4random()];
    [YapModelManager setSharedManager:manager];
    return manager;
}

void CleanupTestYapModelManager() {
    YapModelManager* manager = [YapModelManager sharedManager];
    NSString* path = manager.database.databasePath;
    [YapModelManager setSharedManager:nil];
    [YapDatabaseManager deregisterDatabaseForPath:path];

    NSError* error;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* directory = [path stringByDeletingLastPathComponent];
    NSString* filenamePrefix = [[path lastPathComponent] stringByDeletingPathExtension];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:directory
                                                         error:&error];
   
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self CONTAINS %@", filenamePrefix];
    for (NSString *filename in [contents filteredArrayUsingPredicate:predicate]) {
        NSLog(@"filename = %@", filename);
        [fileManager removeItemAtPath:[directory stringByAppendingPathComponent:filename]
                                error:&error];
    }
}

@implementation TestHelpers
@end
