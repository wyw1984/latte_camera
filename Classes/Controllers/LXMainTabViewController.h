//
//  luxeysTabBarViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/14/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAnimationDuration .3

@interface LXMainTabViewController : UITabBarController<UINavigationControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) NSMutableArray *notifies;
@property (strong, nonatomic) UIBarButtonItem *sharedRightButton;

- (void)showSetting:(id)sender;
- (void)toggleNotify:(id)sender;
- (void)showNotify;

@end
