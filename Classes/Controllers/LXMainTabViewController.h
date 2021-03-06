//
//  luxeysTabBarViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/14/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXCanvasViewController.h"
#import "SocketIO.h"

#define kAnimationDuration .3

@interface LXMainTabViewController : UITabBarController<UINavigationControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UITabBarControllerDelegate, LXImagePickerDelegate, SocketIODelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) NSMutableArray *notifies;

- (void)showSetting:(id)sender;
- (void)showNotify;

@end
