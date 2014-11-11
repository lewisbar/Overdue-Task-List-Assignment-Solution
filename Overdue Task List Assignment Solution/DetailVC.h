//
//  DetailVC.h
//  Overdue Task List Assignment Solution
//
//  Created by Lennart Wisbar on 26.10.14.
//  Copyright (c) 2014 Lennart Wisbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditVC.h"
#import "Defines.h"

// Protocol is adopted by ListVC, originally to be able to pass the changes made in EditVC to ListVC via DetailVC. But since it has become possible to edit the completion state in DetailVC, DetailVC is no longer only the messenger between EditVC and ListVC, but also the author of messages. The nature of those messages hasn't changed, though. It's always just the updated version of a task that has been edited either in DetailVC or in EditVC.
@protocol DetailVCDelegate <NSObject>

@required
-(void)didEditTask:(Task *)task;

@end


@interface DetailVC : UIViewController <EditVCDelegate>

// Instance variables
@property (weak, nonatomic) id <DetailVCDelegate> delegate;
@property (strong, nonatomic) Task *task;

// IBOutlets
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *completionButton;

// IBActions
- (IBAction)completionButtonPressed:(UIButton *)sender;

@end
