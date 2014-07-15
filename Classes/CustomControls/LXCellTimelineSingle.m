//
//  luxeysCellWelcomeSingle.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/06.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXCellTimelineSingle.h"
#import "Picture.h"
#import "Comment.h"
#import "LXCellComment.h"
#import "LXAppDelegate.h"
#import "LXShare.h"
#import "UIButton+AFNetworking.h"
#import "LXUserPageViewController.h"
#import "LXPicVoteCollectionController.h"
#import "LXPicCommentViewController.h"
#import "LXPicInfoViewController.h"
#import "LXTagHome.h"
#import "LXSocketIO.h"

@implementation LXCellTimelineSingle {
    LXShare *lxShare;
}

@synthesize viewController;

@synthesize labelTitle;
@synthesize labelUser;
@synthesize buttonPic;
@synthesize buttonUser;

@synthesize buttonComment;
@synthesize buttonInfo;
@synthesize buttonLike;
@synthesize viewBackground;
@synthesize buttonShare;
@synthesize imageNationality;
@synthesize labelDesc;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDesc) name:@"TimelineShowDesc" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideDesc) name:@"TimelineHideDesc" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pictureUpdate:) name:@"picture_update" object:nil];
    }
    return self;
}

- (void)awakeFromNib {
    buttonUser.layer.cornerRadius = 18;
    buttonUser.layer.shouldRasterize = YES;
    buttonUser.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    _viewWrap.layer.cornerRadius = 3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFeed:(Feed *)feed {
    _feed = feed;
    
    Picture *pic = feed.targets[0];
    
    LXSocketIO *socket = [LXSocketIO sharedClient];
    [socket sendEvent:@"join" withData:[NSString stringWithFormat:@"picture_%ld", [pic.pictureId longValue]]];
    
    buttonLike.tag = [pic.pictureId integerValue];
    buttonInfo.tag = [pic.pictureId integerValue];
    
    [buttonPic setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:pic.urlMedium] placeholderImage:nil];
    _contraintHeight.constant = [LXUtils heightFromWidth:304.0 width:[pic.width floatValue] height:[pic.height floatValue]];
    [buttonUser setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:_feed.user.profilePicture] placeholderImage:[UIImage imageNamed:@"user.gif"]];
    
    [self increaseCounter];

    [self renderPicture];
}

- (void)renderPicture {
    Picture *pic = _feed.targets[0];
    
    [buttonComment setTitle:[pic.commentCount stringValue] forState:UIControlStateNormal];
    [buttonLike setTitle:[pic.voteCount stringValue] forState:UIControlStateNormal];
    
    LXAppDelegate* app = (LXAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    buttonLike.enabled = NO;
    if (!(pic.isVoted && !app.currentUser))
        buttonLike.enabled = YES;
    buttonLike.selected = pic.isVoted;
    
    labelTitle.text = _feed.user.name;
    labelUser.text = [LXUtils timeDeltaFromNow:_feed.updatedAt];
    
    [LXUtils setNationalityOfUser:_feed.user forImage:imageNationality nextToLabel:labelTitle];
    
    labelDesc.text = pic.descriptionText;
    _viewDescBg.hidden = pic.descriptionText.length == 0;
    
    // Tag
    
    _scrollTags.parent = self;
    _scrollTags.tags = pic.tagsOld;

}

- (void)showDesc {
    if (labelDesc.text.length > 0) {
        [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
            _viewDescBg.alpha = 1;
        }];
    }
}

- (void)hideDesc {
    [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
        _viewDescBg.alpha = 0;
    }];
}

- (void)increaseCounter {
    // Increase counter
    Picture *pic = _feed.targets[0];
    NSString *urlCounter = [NSString stringWithFormat:@"picture/counter/%ld/%ld",
                            [pic.pictureId longValue],
                            [pic.userId longValue]];
    
    [[LatteAPIClient sharedClient] GET:urlCounter parameters:nil success:nil failure:nil];
}

- (IBAction)showUser:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    
    viewUserPage.user = _feed.user;
    [viewController.navigationController pushViewController:viewUserPage animated:YES];
}

- (IBAction)showPicture:(id)sender {
    Picture *pic = _feed.targets[0];
    
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    UINavigationController *navGalerry = [storyGallery instantiateInitialViewController];
    LXGalleryViewController *viewGallery = navGalerry.viewControllers[0];
    viewGallery.delegate = viewController;
    viewGallery.user = _feed.user;
    viewGallery.picture = pic;
    
    [viewController presentViewController:navGalerry animated:YES completion:nil];
}

- (IBAction)showComment:(id)sender {
    Picture *pic = _feed.targets[0];
    
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    LXPicCommentViewController *viewComment = [storyGallery instantiateViewControllerWithIdentifier:@"Comment"];

    viewComment.picture = pic;
    
    [viewController.navigationController pushViewController:viewComment animated:YES];
}

- (IBAction)showInfo:(id)sender {
    Picture *pic = _feed.targets[0];
    
    UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                           bundle:nil];
    LXPicInfoViewController *viewInfo = [storyGallery instantiateViewControllerWithIdentifier:@"Info"];
    
    viewInfo.picture = pic;
    
    [viewController.navigationController pushViewController:viewInfo animated:YES];
}

- (IBAction)toggleLike:(id)sender {
    Picture *pic = _feed.targets[0];
    if (pic.isOwner) {
        UIStoryboard *storyGallery = [UIStoryboard storyboardWithName:@"Gallery"
                                                               bundle:nil];
        LXPicVoteCollectionController *viewVote = [storyGallery instantiateViewControllerWithIdentifier:@"Like"];
        
        viewVote.picture = pic;
        
        [viewController.navigationController pushViewController:viewVote animated:YES];
    } else {
        [LXUtils toggleLike:buttonLike ofPicture:pic];
    }
}

- (IBAction)moreAction:(id)sender {
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"Email", @"Twitter", @"Facebook", nil];
    [action showFromTabBar:viewController.navigationController.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    Picture *pic = _feed.targets[0];
    
    lxShare = [[LXShare alloc] init];
    lxShare.controller = viewController;
    
    lxShare.url = pic.urlWeb;
    lxShare.text = pic.urlWeb;
    
    switch (buttonIndex) {
        case 0: // email
            [lxShare emailIt];
            break;
        case 1: // twitter
            [lxShare tweet];
            break;
        case 2: // facebook
            [lxShare facebookPost];
            break;
        default:
            break;
    }
}

- (void)showNormalTag:(UIButton*)button {
    Picture *pic = _feed.targets[0];
    
    UIStoryboard *storyMain = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                        bundle:nil];
    
    LXTagHome *viewTag = [storyMain instantiateViewControllerWithIdentifier:@"TagHome"];
    viewTag.tag = pic.tagsOld[button.tag];
    viewTag.title = pic.tagsOld[button.tag];
    
    [viewController.navigationController pushViewController:viewTag animated:YES];
}

- (void)pictureUpdate:(NSNotification*)notify {
    Picture *picture = _feed.targets[0];
    
    NSDictionary *raw = notify.object;
    if ([picture.pictureId longValue] == [raw[@"id"] longValue]) {
        [picture setAttributesFromDictionary:raw];
        
        [self renderPicture];
    }
}

@end
