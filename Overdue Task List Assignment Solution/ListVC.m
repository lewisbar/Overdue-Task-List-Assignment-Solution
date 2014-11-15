//
//  ViewController.m
//  Overdue Task List Assignment Solution
//
//  Created by Lennart Wisbar on 26.10.14.
//  Copyright (c) 2014 Lennart Wisbar. All rights reserved.
//

#import "ListVC.h"

@interface ListVC ()

@end

@implementation ListVC
#define AUTOMATIC_SORT_MODE NO
#define MANUAL_SORT_MODE YES
#define TASK_LIST @"task list"
#define SORT_MODE @"sort mode"
#define TASK_ORDER_HAS_AT_LEAST_ONCE_BEEN_EDITED @"task order has at least once been edited"

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // Uncomment to reset the app (deletes all tasks and settings, makes the tutorial AlertView appear again):
    // [self setTheWholeAppBackToOriginalState];
    
    // Load the saved task list
    [self loadTaskList];
    
    // Retrieve the saved sort mode (automatic or manual)
    self.sortMode = [[[NSUserDefaults standardUserDefaults] objectForKey:SORT_MODE] boolValue];
    
    // Prepare the RefreshControl - pull down to sort by due date (and switch to automatic sort mode if in manual mode)
    [self createRefreshControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy Instantiation of Properties
-(NSMutableArray *)taskList
{
    if (!_taskList) {
        _taskList = [[NSMutableArray alloc] init];
    }
    return _taskList;
}

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[AddVC class]]) {
        AddVC *targetVC = segue.destinationViewController;
        targetVC.delegate = self;
    }
    else if ([segue.destinationViewController isKindOfClass:[DetailVC class]] && [sender isKindOfClass:[UITableViewCell class]]) {
        DetailVC *targetVC = segue.destinationViewController;
        NSIndexPath *path = [self.tableView indexPathForCell:sender];
        targetVC.task = self.taskList[path.row];
        targetVC.delegate = self;
    }
}

#pragma mark - Table View Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // If task list is empty
    if (self.taskList.count < 1) {
        // Show background message
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = @"Tap \"+\" to start adding tasks.";
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [messageLabel sizeToFit];
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        // Disable Edit button
        self.navigationItem.leftBarButtonItem.enabled = NO;
        
        // Remove RefreshControl
        // endRefreshing must be called in case the user has just pulled the list down, which is easy to happen accidently. Just a tiny bit suffices for a warning in the console.
        [self.refreshControl endRefreshing];
        self.refreshControl = nil;
        
        return 0;
    }
    
    // If task list is not empty
    // Remove background message
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    //Enable Edit button
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    return self.taskList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Task *task = self.taskList[indexPath.row];
    
    // Strikethrough completed tasks, remove strikethrough if a task gets uncompleted again
    NSString *dateString = [self stringFromDate:task.date];
    if (task.completion) {
        cell.textLabel.attributedText = [self strikethroughString:task.title];
        cell.detailTextLabel.attributedText = [self strikethroughString:dateString];
    }
    else {
        cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:task.title];
        cell.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:dateString];
    }
    
    // Color coding by completion or due date
    cell.backgroundColor = [self colorForTask:task];
    
    return cell;
}

// Deleting tasks
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.taskList removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self saveTaskList];
    }
}

// Allow reordering
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    Task *task = self.taskList[sourceIndexPath.row];
    [self.taskList removeObject:task];
    [self.taskList insertObject:task atIndex:destinationIndexPath.row];
    [self makeSortModeManual];
    
    // Show tutorial message the first time tasks are reordered manually
    if (![[NSUserDefaults standardUserDefaults] objectForKey:TASK_ORDER_HAS_AT_LEAST_ONCE_BEEN_EDITED]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hint" message:@"By reordering tasks, you switch the sort mode to manual. Pull down to switch back to automatic ordering by due date." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:TASK_ORDER_HAS_AT_LEAST_ONCE_BEEN_EDITED];
    }
}

// Allow conditional reordering
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Only uncompleted tasks are allowed to be reordered. Completed tasks should remain at the bottom of the list.
    if ([self.taskList[indexPath.row] completion]) return NO;
    else return YES;
}

// Only allow certain target while reordering
-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    // If target index is out of bounds: Reduce it.
    if (proposedDestinationIndexPath.row > self.taskList.count-1) {
        proposedDestinationIndexPath = [NSIndexPath indexPathForRow:self.taskList.count-1 inSection:proposedDestinationIndexPath.section];
    }
    
    // Move task above any completed tasks, if necessary
    while ([self.taskList[proposedDestinationIndexPath.row] completion]) {
        proposedDestinationIndexPath = [NSIndexPath indexPathForRow:proposedDestinationIndexPath.row-1 inSection:proposedDestinationIndexPath.section];
    }

    return proposedDestinationIndexPath;
}

#pragma mark - Table View Delegate
// Complete or uncomplete tasks by touching the cell
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task *task = self.taskList[indexPath.row];
    NSString *dateString = [self stringFromDate:task.date];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (task.completion) {
        task.completion = NO;
        cell.textLabel.attributedText = [self removeStrikethroughFromString:cell.textLabel.attributedText];
        cell.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:dateString];
        [self addUncompletedTaskAtCorrectPosition:task];
    }
    else {
        task.completion = YES;
        cell.textLabel.attributedText = [self strikethroughString:cell.textLabel.text];
        cell.detailTextLabel.attributedText = [self strikethroughString:dateString];
        [self moveCompletedTaskToCorrectPosition:task];
    }
    [self saveTaskList];
    [self.tableView reloadData];

    // "return nil" means that the tapped cell won't be selected. I don't want it to stay highlighted after tapping, so I return nil.
    return nil;
}

#pragma mark - AddVC Delegate
// No task added: Just remove the AddVC
-(void)didCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// New task added
-(void)didSaveTaskWithTitle:(NSString *)title description:(NSString *)description date:(NSDate *)date
{
    // Re-create RefreshControl if task list has been empty
    if (self.taskList.count == 0) {
        [self createRefreshControl];
    }
    
    // Create task with data from AddVC
    Task *task = [[Task alloc] initWithTitle:title description:description date:date];
    
    // Add task to list according to due date (in automatic/default mode) or to top of list (in manual mode)
    if (self.sortMode == AUTOMATIC_SORT_MODE) [self addUncompletedTaskAtCorrectPosition:task];
    else if (self.sortMode == MANUAL_SORT_MODE) [self.taskList insertObject:task atIndex:0];
    
    [self saveTaskList];

    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
}

#pragma mark - DetailVC Delegate
// EditVC's delegate is DetailVC, DetailsVCs delegate is ListVC (self). If a task is edited in EditVC, EditVC tells DetailVC, which passes the news on to ListVC (self). Furthermore, this method is called when the user changes the completion state of a task in DetailVC.
-(void)didEditTask:(Task *)task
{
    // In automatic sort mode, update the list position of the added task. In manual mode, skip this part and just save and update the view.
    if (self.sortMode == AUTOMATIC_SORT_MODE) {
        if (task.completion) [self moveCompletedTaskToCorrectPosition:task];
        else [self addUncompletedTaskAtCorrectPosition:task];
    }

    [self saveTaskList];
    [self.tableView reloadData];
}

#pragma mark - Helper Methods
#pragma mark Persistance
// Saving
-(void)saveTaskList
{
    // Make tasklist savable
    NSMutableArray *savableTaskList = [[NSMutableArray alloc] init];
    for (Task *task in self.taskList) [savableTaskList addObject:[task taskAsAPropertyList]];
    
    // Save tasklist
    [[NSUserDefaults standardUserDefaults] setObject:savableTaskList forKey:TASK_LIST];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// Loading
-(void)loadTaskList
{
    NSMutableArray *mutableArray = [[NSUserDefaults standardUserDefaults] objectForKey:TASK_LIST];
    for (NSDictionary *dictionary in mutableArray) {
        Task *task = [[Task alloc] init];
        task.title = dictionary[TASK_TITLE];
        task.taskDescription = dictionary[TASK_DESCRIPTION];
        task.date = dictionary[TASK_DATE];
        task.completion = [dictionary[TASK_COMPLETION] boolValue];
        [self.taskList addObject:task];
    }
}

#pragma mark Formatting
// Strikethrough text and remove strikethrough from text (needed for task completion; REUSABLE FOR FUTURE PROJECTS)
-(NSAttributedString *)strikethroughString:(NSString *)string
{
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange range = NSMakeRange(0, string.length);
    [mutableAttributedString addAttribute:NSStrikethroughStyleAttributeName value:(NSNumber *)kCFBooleanTrue range:range];
    return [mutableAttributedString copy];
}

-(NSAttributedString *)removeStrikethroughFromString:(NSAttributedString *)attributedString
{
    NSMutableAttributedString *mutableAttributedString = [attributedString mutableCopy];
    NSRange range = NSMakeRange(0, mutableAttributedString.length);
    [mutableAttributedString removeAttribute:NSStrikethroughStyleAttributeName range:range];
    return [mutableAttributedString copy];
}

// String from Date
-(NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    return [formatter stringFromDate:date];
}

// Color coding by completion or due date
-(UIColor *)colorForTask:(Task *)task
{
    UIColor *color = [[UIColor alloc] init];
    
    if (task.completion) color = COLOR_COMPLETED;
    else if ([task.date timeIntervalSinceNow] <= TIME_INTERVAL_OVERDUE) color = COLOR_OVERDUE;
    else if ([task.date timeIntervalSinceNow] <= TIME_INTERVAL_SOON) color = COLOR_SOON;
    else color = COLOR_LATER;
    
    return color;
}

#pragma mark Sorting
// Single uncompleted task
-(void)addUncompletedTaskAtCorrectPosition:(Task *)task
{
    // If the task is already in the list: Remove it before inserting it in the right place.
    if ([self.taskList containsObject:task]) {
        [self.taskList removeObject:task];
    }

    // If this is the first/only task: Just add it to the list, nothing else.
    if (self.taskList.count < 1) {
        [self.taskList addObject:task];
        return;
    }
    
    // Find the correct place for the task
    for (int i = 0; i < self.taskList.count; i++) {
        Task *comparedTask = self.taskList[i];
        if ([task.date timeIntervalSinceReferenceDate] <= [comparedTask.date timeIntervalSinceReferenceDate] || comparedTask.completion) {
            [self.taskList insertObject:task atIndex:i];
            break;
        }
        // If the correct place is at the end of the list:
        else if ([self.taskList indexOfObject:comparedTask] == self.taskList.count-1) {
            [self.taskList addObject:task];
            break;
        }
    }
}

// Single completed task
-(void)moveCompletedTaskToCorrectPosition:(Task *)task
{
    if (self.taskList.count > 1) {
        [self.taskList removeObject:task];
        
        for (int i = 0; i < self.taskList.count; i++) {
            Task *comparedTask = self.taskList[i];
            if (comparedTask.completion) {
                [self.taskList insertObject:task atIndex:i];
                break;
            }
            else if ([self.taskList indexOfObject:comparedTask] == self.taskList.count-1) {
                [self.taskList addObject:task];
                break;
            }
        }
    }
}

// Sort the whole list (which also switches to automatic sort mode). This method is called when the list is pulled down.
-(void)sortTaskListByDateAndSwitchToAutomaticSorting
{
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Sorting by date"];
    
    NSArray *unsortedTaskList = [self.taskList copy];
    self.taskList = nil;
    for (Task *task in unsortedTaskList) {
        if (!task.completion) {
            [self addUncompletedTaskAtCorrectPosition:task];
        }
        else {
            [self.taskList addObject:task];
        }
    }
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
    [self saveTaskList];
    
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull down to sort by date"];
    
    [self makeSortModeAutomatic];
}

// Switch sort mode
-(void)makeSortModeManual
{
    self.sortMode = MANUAL_SORT_MODE;
    [[NSUserDefaults standardUserDefaults] setObject:@(self.sortMode) forKey:SORT_MODE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)makeSortModeAutomatic
{
    self.sortMode = AUTOMATIC_SORT_MODE;
    [[NSUserDefaults standardUserDefaults] setObject:@(self.sortMode) forKey:SORT_MODE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)createRefreshControl
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull down to sort by date"];
    self.refreshControl = refreshControl;
    [self.refreshControl addTarget:self action:@selector(sortTaskListByDateAndSwitchToAutomaticSorting) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - IBActions
- (IBAction)editPressed:(UIBarButtonItem *)sender
{
    // Put table in editing mode
    [self.tableView setEditing:YES animated:YES];
    
    // Switch Edit button to Done button
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)];
    self.navigationItem.leftBarButtonItem = doneButtonItem;
    
    // Disable the plus button
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (IBAction)donePressed:(UIBarButtonItem *)sender
{
    // Exit editing mode
    [self.tableView setEditing:NO animated:YES];
    
    // Switch Done button back to Edit button
    UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPressed:)];
    self.navigationItem.leftBarButtonItem = editButtonItem;
    
    // Re-enable the plus button
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    // Save the new order
    [self saveTaskList];
}

// Reset the app
- (void)setTheWholeAppBackToOriginalState
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TASK_LIST];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SORT_MODE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TASK_ORDER_HAS_AT_LEAST_ONCE_BEEN_EDITED];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reset" message:@"The app has been reset. Remove the call to setTheWholeAppBackToOriginalState from viewDidLoad in ListVC.m to persist your future data." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
}

@end
