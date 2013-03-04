//
//  luxeysRightSideViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/17/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXAppDelegate.h"
#import "LatteAPIClient.h"
#import "LXCellFriendRequest.h"
#import "LXCellNotify.h"
#import "UIButton+AsyncImage.h"
#import "LXPicDetailViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "User.h"
#import "Picture.h"

typedef enum {
    kNotifyTargetPhoto = 10,
    k = 12,
    kTimelineFollowing = 13,
} LatteTimeline;

@interface LXNotifySideViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate> {
    NSMutableArray *notifies;
    NSMutableArray *fbfriends;
    
    int page;
    int limit;
    EGORefreshTableHeaderView *refreshHeaderView;
    BOOL reloading;
}


@property (strong, nonatomic) IBOutlet UITableView *tableNotify;

@end
