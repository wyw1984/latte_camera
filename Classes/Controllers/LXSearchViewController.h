//
//  LXSearchViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/8/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXGalleryViewController.h"

@interface LXSearchViewController : UITableViewController<LXGalleryViewControllerDataSource>
@property (strong, nonatomic) IBOutlet UIButton *buttonSearchPeople;
@property (strong, nonatomic) IBOutlet UIButton *buttonSearchPhoto;
@property (strong, nonatomic) IBOutlet UIView *viewSearchBox;
@property (strong, nonatomic) IBOutlet UITextField *textKeyword;
- (IBAction)touchTab:(UIButton *)sender;
- (IBAction)textChanged:(id)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityLoad;

@end
