//
//  AddVC.h
//  Overdue Task List Assignment Solution
//
//  Created by Lennart Wisbar on 26.10.14.
//  Copyright (c) 2014 Lennart Wisbar. All rights reserved.
//

#import <UIKit/UIKit.h>

// Protocol is adopted by ListVC. Saved tasks are passed to ListVC this way.
@protocol AddVCDelegate <NSObject>

@required
-(void)didCancel;
-(void)didSaveTaskWithTitle:(NSString *)title description:(NSString *)description date:(NSDate *)date;

@end


@interface AddVC : UIViewController <UITextFieldDelegate>

// Instance variables
@property (weak, nonatomic) id <AddVCDelegate> delegate;

// IBOutlets
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

// IBActions
- (IBAction)cancelPressed:(UIBarButtonItem *)sender;
- (IBAction)donePressed:(UIBarButtonItem *)sender;

@end
