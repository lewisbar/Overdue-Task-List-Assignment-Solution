//
//  DetailVC.m
//  Overdue Task List Assignment Solution
//
//  Created by Lennart Wisbar on 26.10.14.
//  Copyright (c) 2014 Lennart Wisbar. All rights reserved.
//

#import "DetailVC.h"

@interface DetailVC ()

@end

@implementation DetailVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[EditVC class]]) {
        // Pass the current task on to EditVC and make self the delegate
        EditVC *targetVC = segue.destinationViewController;
        targetVC.task = self.task;
        targetVC.delegate = self;
    }
}

#pragma mark - EditVC Delegate
-(void)didCancelEditing
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didSaveEditingTask:(Task *)task
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self reloadData];
    // Share the information with ListVC, which holds the task list and will also care about persistance and sorting
    [self.delegate didEditTask:task];
}

#pragma mark - Helper Methods
// The exact same method as in ListVC. I could have made it a class method and reuse it, but it's possible that I want a different format here than in ListVC in the future, so I just copied it to make it easier to change the format in each of the two VCs seperately.
-(NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    return [formatter stringFromDate:date];
}

// Update the displayed information
-(void)reloadData
{
    // Labels
    self.titleLabel.text = self.task.title;
    self.descriptionLabel.text = self.task.taskDescription;
    self.dateLabel.text = [self stringFromDate:self.task.date];
    
    // Checkbox
    if (self.task.completion) {
        [self.completionButton setImage:[UIImage imageNamed:@"checkBoxMarked.png"] forState:UIControlStateNormal];
    }
    else {
        [self.completionButton setImage:[UIImage imageNamed:@"checkBox.png"] forState:UIControlStateNormal];
    }
    
    // Background color
    if (self.task.completion) {
        self.view.backgroundColor = [UIColor grayColor]; // completed: gray
    }
    else if ([self.task.date timeIntervalSinceNow] <= 0) {
        self.view.backgroundColor = [UIColor colorWithRed:1 green:0.2 blue:0.2 alpha:1]; // overdue: red
    }
    else if ([self.task.date timeIntervalSinceNow] <= 24*60*60) {
        self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.3 alpha:1]; // due in the next 24 hrs: yellow
    }
    else {
        self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]; // due later: white
    }
}

#pragma mark - IBActions
// Complete (or uncomplete) a task by tapping on the checkbox
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
    [self reloadData];
    [self.delegate didEditTask:self.task];
}

@end
