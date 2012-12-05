//
//  luxeysCellWelcomeMulti.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/06.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Feed.h"
#import "Picture.h"
#import "UIButton+AsyncImage.h"
#import "luxeysTemplateTimlinePicMultiItem.h"

@interface luxeysCellWelcomeMulti : UITableViewCell {
    UIViewController *viewController;
    BOOL showControl;
}
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollPic;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelUserDate;

@property (strong, nonatomic) Feed *feed;
@property (strong, nonatomic) UIViewController *viewController;

@property (assign, nonatomic) BOOL showControl;

@end