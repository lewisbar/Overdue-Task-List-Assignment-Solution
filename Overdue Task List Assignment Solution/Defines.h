//
//  Defines.h
//  Overdue Task List Assignment Solution
//
//  Created by Lennart Wisbar on 10.11.14.
//  Copyright (c) 2014 Lennart Wisbar. All rights reserved.
//
// #defines that are used in more than one class

#ifndef Overdue_Task_List_Assignment_Solution_Defines_h
#define Overdue_Task_List_Assignment_Solution_Defines_h
#endif

// Dictionary keys
#define TASK_TITLE @"title"
#define TASK_DESCRIPTION @"description"
#define TASK_DATE @"date"
#define TASK_COMPLETION @"completion"

// Time intervals
#define TIME_INTERVAL_OVERDUE 0     // now
#define TIME_INTERVAL_SOON 24*60*60 // in the next 24 hrs

// Color coding
#define COLOR_COMPLETED [UIColor grayColor]  // gray
#define COLOR_OVERDUE [UIColor colorWithRed:1 green:0.2 blue:0.2 alpha:1]  // red
#define COLOR_SOON [UIColor colorWithRed:0.9 green:0.9 blue:0.3 alpha:1]  // yellow
#define COLOR_LATER [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]  // white