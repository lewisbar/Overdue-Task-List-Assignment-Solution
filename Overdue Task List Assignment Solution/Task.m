//
//  Task.m
//  Overdue Task List Assignment Solution
//
//  Created by Lennart Wisbar on 26.10.14.
//  Copyright (c) 2014 Lennart Wisbar. All rights reserved.
//

#import "Task.h"

@implementation Task

-(Task *)initWithTitle:(NSString *)title description:(NSString *)description date:(NSDate *)date
{
    self = [super init];
    
    self.title = title;
    self.taskDescription = description;
    self.date = date;
    self.completion = NO;
    
    return self;
}

@end
