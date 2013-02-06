//
//  luxeysCellNotify.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/01.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Picture.h"

@interface LXCellNotify : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *viewImage;
@property (strong, nonatomic) IBOutlet UILabel *labelNotify;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;

- (void)setNotify:(NSDictionary *)notify;

@end