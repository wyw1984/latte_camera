//
//  LXPicDetailViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "LXCellComment.h"
#import "LXAppDelegate.h"
#import "LXUtils.h"
#import "LXUserPageViewController.h"
#import "LXButtonBrown30.h"

#import "LatteAPIClient.h"
#import "LXPicInfoViewController.h"
#import "LXPicEditViewController.h"
#import "LXPicMapViewController.h"
#import "Picture.h"
#import "User.h"
#import "Comment.h"
#import "MBProgressHUD.h"
#import "UIImageView+loadProgress.h"
#import "UIButton+AsyncImage.h"

@class LXCellComment, LXButtonBrown30;

@interface LXPicDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, EGORefreshTableHeaderDelegate> {
    EGORefreshTableHeaderView *refreshHeaderView;
    Picture *pic;
    NSInteger picID;
    //User *user;
    BOOL reloading;
    BOOL loaded;
    NSMutableArray *comments;
    MBProgressHUD *HUD;
}

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureTap;
@property (strong, nonatomic) IBOutlet UIView *viewTextbox;
@property (strong, nonatomic) IBOutlet UITextField *textComment;
@property (strong, nonatomic) IBOutlet LXButtonBrown30 *buttonSend;
@property (strong, nonatomic) IBOutlet UITableView *tablePic;
@property (strong, nonatomic) IBOutlet LXButtonBrown30 *buttonEdit;

@property (strong, nonatomic) IBOutlet UIImageView *imagePic;
@property (strong, nonatomic) IBOutlet UIView *viewStats;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelAccess;
@property (strong, nonatomic) IBOutlet UILabel *labelComment;
@property (strong, nonatomic) IBOutlet UILabel *labelLike;
@property (strong, nonatomic) IBOutlet UILabel *labelAuthor;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UIButton *buttonLike;
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UIButton *buttonComment;
@property (strong, nonatomic) IBOutlet UIButton *buttonInfo;
@property (strong, nonatomic) IBOutlet UIButton *buttonMap;
@property (strong, nonatomic) IBOutlet UIView *viewSubBg;
@property (strong, nonatomic) IBOutlet UIView *viewSubPic;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicatorComment;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollVotes;

- (IBAction)touchBackground:(id)sender;
- (IBAction)touchBack:(id)sender;
- (IBAction)changeText:(id)sender;
- (IBAction)touchSend:(id)sender;
- (IBAction)touchEdit:(id)sender;
- (IBAction)touchLike:(id)sender;
- (IBAction)showUser:(UIButton *)sender;
- (IBAction)showInfo:(UIButton *)sender;
- (IBAction)showMap:(UIButton *)sender;
- (IBAction)showKeyboard:(id)sender;

@property (strong, nonatomic) Picture *pic;
@property (assign, nonatomic) NSInteger picID;
//@property (strong, nonatomic) User *user;

//- (void)setPictureID:(int)aPicID;
- (void)reloadView;

@end