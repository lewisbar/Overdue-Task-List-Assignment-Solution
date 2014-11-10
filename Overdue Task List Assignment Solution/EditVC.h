//
//  EditVC.h
//  Overdue Task List Assignment Solution
//
//  Created by Lennart Wisbar on 26.10.14.
//  Copyright (c) 2014 Lennart Wisbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

// Protocol adopted by DetailVC. DetailVC updates its own displayed information and passes the updated task on to ListVC, which holds the task list and cares about sorting and persistance.
@protocol EditVCDelegate <NSObject>

@required
-(void)didCancelEditing;
-(void)didSaveEditingTask:(Task *)task;

@end


@interface EditVC : UIViewController <UITextFieldDelegate>

// Instance variables
@property (weak, nonatomic) id <EditVCDelegate> delegate;
@property (strong, nonatomic) Task *task;

// IBActions
- (IBAction)cancelPressed:(UIBarButtonItem *)sender;
- (IBAction)donePressed:(UIBarButtonItem *)sender;
- (IBAction)completionButtonPressed:(UIButton *)sender;

// IBOutlets
@property (strong, nonatomic) IBOutlet UITextField *titleTextfield;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIButton *completionButton;

@end
