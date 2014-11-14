//
//  Task.h
//  Overdue Task List Assignment Solution
//
//  Created by Lennart Wisbar on 26.10.14.
//  Copyright (c) 2014 Lennart Wisbar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Defines.h"

@interface Task : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *taskDescription;
@property (strong, nonatomic) NSDate *date;
@property (nonatomic) BOOL completion;

// Designated initializer
-(id)initWithTitle:(NSString *)title description:(NSString *)description date:(NSDate *)date;

// Make the task savable
-(NSDictionary *)taskAsAPropertyList;

@end
