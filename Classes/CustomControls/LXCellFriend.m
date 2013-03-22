//
//  luxeysCellFriend.m
//  Latte
//
//  Created by Xuan Dung Bui on 9/6/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXCellFriend.h"
#import "UIImageView+loadProgress.h"
#import "LXUtils.h"

@implementation LXCellFriend
@synthesize imageUser;
@synthesize labelName;
@synthesize labelIntro;
@synthesize viewBackground;
@synthesize imageNationality;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUser:(User *)user {
    imageUser.image = [UIImage imageNamed:@"user.gif"];
    [imageUser loadProgess:user.profilePicture];
    labelIntro.text = user.introduction;
    labelName.text = user.name;
    [LXUtils setNationalityOfUser:user forImage:imageNationality nextToLabel:labelName];
}

- (void)drawRect:(CGRect)rect {
    imageUser.layer.cornerRadius = 3;
    imageUser.clipsToBounds = YES;
    
    [LXUtils globalShadow:viewBackground];
    viewBackground.layer.cornerRadius = 5.0;
    
    [super drawRect:rect];
}

@end
