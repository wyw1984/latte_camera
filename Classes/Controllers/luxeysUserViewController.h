//
//  luxeysUserViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface luxeysUserViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *viewScroll;
@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelVote;
@property (strong, nonatomic) IBOutlet UILabel *labelPhoto;
@property (strong, nonatomic) IBOutlet UILabel *labelFriend;
@property (strong, nonatomic) IBOutlet UIView *viewStats;
@property (strong, nonatomic) IBOutlet UIView *viewContent;
@property (strong, nonatomic) IBOutlet NSDictionary *dictUser;
@property (strong, nonatomic) IBOutlet UIButton *buttonProfile;
@property (strong, nonatomic) IBOutlet UIButton *buttonCalendar;
@property (strong, nonatomic) IBOutlet UIButton *buttonMap;
- (IBAction)touchTab:(UIButton *)sender;

@end
