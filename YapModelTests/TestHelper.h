//
//  TestHelper.h
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

@import Foundation;
#import <YapDatabase/YapDatabase.h>


extern YapDatabase*(^CreateDatabase)(void);
extern void(^CleanupDatabase)(YapDatabase*);
extern void(^SetupDatabaseIndex)(YapDatabase*);

@interface TestHelper : NSObject
@end

@interface YapDatabaseExtension(Private)
- (BOOL)supportsDatabase:(YapDatabase *)database withRegisteredExtensions:(NSDictionary *)registeredExtensions;
@end
