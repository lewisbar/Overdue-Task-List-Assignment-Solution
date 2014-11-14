//
//  Task.m
//  Overdue Task List Assignment Solution
//
//  Created by Lennart Wisbar on 26.10.14.
//  Copyright (c) 2014 Lennart Wisbar. All rights reserved.
//

#import "Task.h"

@implementation Task

-(id)initWithTitle:(NSString *)title description:(NSString *)description date:(NSDate *)date
{
    self = [super init];
    
    if (self) {
        _title = title;
        _taskDescription = description;
        _date = date;
        _completion = NO;
    }
    
    return self;
}

-(id)init
{
    self = [self initWithTitle:nil description:nil date:nil];
    return self;
}

// Make a task savable by transforming it to an NSDictionary
-(NSDictionary *)taskAsAPropertyList
{
    NSDictionary *dictionary = @{TASK_TITLE : self.title,
                                 TASK_DESCRIPTION : self.taskDescription,
                                 TASK_DATE : self.date,
                                 TASK_COMPLETION : @(self.completion)};
    return dictionary;
}

@end
