//
//  TestHelpers.h
//  YapModel
//
//  Created by Francis Chong on 25/2/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YapDatabase.h"
#import "YapModelManager.h"

extern YapModelManager* CreateTestYapModelManager();
extern void CleanupYapModelManager(YapModelManager* manager);

@interface TestHelpers : NSObject

@end
