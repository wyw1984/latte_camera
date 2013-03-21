//
//  LXPicDetailTabViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/6/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXPicDetailTabViewController.h"

#import "LXPicInfoViewController.h"
#import "LXPicCommentViewController.h"


@interface LXPicDetailTabViewController () {
    NSInteger currentTab;
}

@end

@implementation LXPicDetailTabViewController {
    LXPicInfoViewController *viewInfo;
}

@synthesize scrollTab;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    currentTab = 2;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    scrollTab.contentSize = CGSizeMake(960, screenRect.size.height);
    scrollTab.contentOffset = CGPointMake(320, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Vote"]) {
        _viewVote = segue.destinationViewController;
    } else if ([segue.identifier isEqualToString:@"Comment"]) {
        _viewComment = segue.destinationViewController;
    } else if ([segue.identifier isEqualToString:@"Info"]) {
        viewInfo = segue.destinationViewController;
        viewInfo.parent = _parent;
        if (_picture != nil) {
            viewInfo.picture = _picture;
        }
    }
}

- (void)setPicture:(Picture *)picture {
    _picture = picture;
    _viewComment.picture = picture;
    viewInfo.picture = picture;
    
    // Switch to comment
    if (!_picture.isOwner && currentTab == 1) {
        [self setTab:2];
    }
}

- (void)setTab:(NSInteger)tab {
    currentTab = tab;
    [scrollTab  setContentOffset:CGPointMake((tab-1)*320, 0) animated:YES];
}

@end
