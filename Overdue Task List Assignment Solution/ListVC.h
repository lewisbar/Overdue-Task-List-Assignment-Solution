//
//  ViewController.h
//  Overdue Task List Assignment Solution
//
//  Created by Lennart Wisbar on 26.10.14.
//  Copyright (c) 2014 Lennart Wisbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import "AddVC.h"
#import "DetailVC.h"

#define MANUAL_SORT_MODE YES
#define AUTOMATIC_SORT_MODE NO

@interface ListVC : UITableViewController <AddVCDelegate, DetailVCDelegate>

@property (strong, nonatomic) NSMutableArray *taskList;
@property (nonatomic) BOOL sortMode;

- (IBAction)editPressed:(UIBarButtonItem *)sender;

@end

