//
//  EditVC.m
//  Overdue Task List Assignment Solution
//
//  Created by Lennart Wisbar on 26.10.14.
//  Copyright (c) 2014 Lennart Wisbar. All rights reserved.
//

#import "EditVC.h"

@interface EditVC ()

@end

@implementation EditVC

- (void)viewDidLoad {
    [super viewDidLoad];

    // Fill the view with the properties of the current task
    self.titleTextfield.text = self.task.title;
    self.descriptionTextView.text = self.task.taskDescription;
    self.datePicker.date = self.task.date;
    if (self.task.completion)
        [self.completionButton setImage:[UIImage imageNamed:@"checkBoxMarked.png"] forState:UIControlStateNormal];
    else
        [self.completionButton setImage:[UIImage imageNamed:@"checkBox.png"] forState:UIControlStateNormal];
    
    // UITextFieldDelegate (to dismiss the keyboard on pressing return)
    self.titleTextfield.delegate = self;
    
    // Tapping on the background will dismiss the keyboard
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    
    // Background color
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBActions
- (IBAction)cancelPressed:(UIBarButtonItem *)sender
{
    [self.delegate didCancelEditing];
}

- (IBAction)donePressed:(UIBarButtonItem *)sender
{
    // Update the task and send it to the delegate
    self.task.title = self.titleTextfield.text;
    self.task.taskDescription = self.descriptionTextView.text;
    self.task.date = self.datePicker.date;
    [self.delegate didSaveEditingTask:self.task];
}

// Complete or uncomplete tasks by tapping the checkbox
- (IBAction)completionButtonPressed:(UIButton *)sender
{
    if (self.task.completion) {
        self.task.completion = NO;
        [self.completionButton setImage:[UIImage imageNamed:@"checkBox.png"] forState:UIControlStateNormal];
    }
    else {
        self.task.completion = YES;
        [self.completionButton setImage:[UIImage imageNamed:@"checkBoxMarked.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - TextFieldDelegate
// Dismiss keyboard by pressing the return key
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

@end
