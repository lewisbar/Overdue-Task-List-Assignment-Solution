//
//  AddVC.m
//  Overdue Task List Assignment Solution
//
//  Created by Lennart Wisbar on 26.10.14.
//  Copyright (c) 2014 Lennart Wisbar. All rights reserved.
//

#import "AddVC.h"

@interface AddVC ()

@end

@implementation AddVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleTextField.delegate = self;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    // Tapping on the background will dismiss the keyboard
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
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
    [self.delegate didCancel];
}

// Passing the saved task on to the delegate (ListVC)
- (IBAction)donePressed:(UIBarButtonItem *)sender
{
    NSString *title = self.titleTextField.text;
    NSString *description = self.descriptionTextView.text;
    NSDate *date = self.datePicker.date;
    [self.delegate didSaveTaskWithTitle:title description:description date:date];
}

#pragma mark - TextFieldDelegate
// Dismiss keyboard by pressing the return key in the titleTextField. This could also be done in the descriptionTextView, but then the user wouldn't be able to enter line breaks. The keyboard is also dismissed by tapping or panning on the view.
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

@end
