//
//  LXLeftSideUserViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/22/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXLeftSideUserViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageProfilepic;
@property (strong, nonatomic) IBOutlet UILabel *labelUsername;
@property (strong, nonatomic) IBOutlet UIView *viewBanner;
- (IBAction)touchBanner:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *buttonBanner;

@end
