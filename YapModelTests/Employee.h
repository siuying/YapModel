//
//  Employee.h
//  YapModel
//
//  Created by Francis Chong on 2/26/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapModelObject.h"
#import "Person.h"

@interface Employee : Person

@property (nonatomic, copy) NSString* employeeID;

@end
