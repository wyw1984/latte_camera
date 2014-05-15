//
//  luxeysTabBarViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/14/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXLoginViewController.h"
#import "User.h"
#import "Picture.h"
#import "LXCanvasViewController.h"
#import "LXMainTabViewController.h"
#import "LXAppDelegate.h"
#import "LXAboutViewController.h"
#import "LXUserPageViewController.h"
#import "LXNavMypageController.h"
#import "LXUploadStatusViewController.h"
#import "LXUploadObject.h"
#import "LXTableConfirmEmailController.h"
#import "LXImagePickerController.h"

@interface LXMainTabViewController ()

@end

@implementation LXMainTabViewController {
    UIView *viewCamera;
    BOOL isFirst;

    LXUploadStatusViewController *viewUpload;
    UIButton *buttonUploadStatus;
    MBRoundProgressView *hudUpload;
    
    UINavigationController *navRank;
    UINavigationController *navSearch;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoggedIn:)
                                                 name:@"LoggedIn"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoggedOut:)
                                                 name:@"LoggedOut"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePushNotify:)
                                                 name:@"ReceivedPushNotify"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadSuccess:) name:@"LXUploaderSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadProgess:) name:@"LXUploaderProgress" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadStart:) name:@"LXUploaderStart" object:nil];
    
    isFirst = true;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Init View
    UIStoryboard* storyMain = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    viewUpload = [storyMain instantiateViewControllerWithIdentifier:@"UploadStatus"];
    self.delegate = self;
    // Tab style
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
//    for (UITabBarItem* tab in [self.tabBarController.tabBar items]) {
//        DLog(@"text");
//        [tab setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                     [UIColor blackColor], UITextAttributeTextShadowColor,
//                                     [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
//                                     nil] forState:UIControlStateNormal];
//    }


//    self.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"bg_bottom_on.png"];
//    self.tabBar.backgroundImage = [UIImage imageNamed: @"bg_bottom.png"];
    
    // add the drop shadow
//    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.tabBar.bounds];
//    self.tabBar.layer.masksToBounds = NO;
//    self.tabBar.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.tabBar.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
//    self.tabBar.layer.shadowOpacity = 0.8f;
//    self.tabBar.layer.shadowRadius = 2.5f;
//    self.tabBar.layer.shadowPath = shadowPath.CGPath;
    
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (app.currentUser != nil) {
        [self setUser];
    } else {
        [self setGuest];
    }
    
//    for(UIViewController *tab in self.viewControllers) {
//        
//        UIFont *font;
//
//        font = [UIFont fontWithName:@"HelveticaNeue" size:9];
//        
//        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    font, UITextAttributeFont,
//                                    [UIColor whiteColor], UITextAttributeTextColor,
//                                    [NSValue valueWithCGSize:CGSizeMake(0, 1)], UITextAttributeTextShadowOffset,
//                                    [UIColor blackColor], UITextAttributeTextShadowColor,
//                                    nil];
//        
//        [tab.tabBarItem setTitleTextAttributes:attributes
//                                      forState:UIControlStateNormal];
//    }
    
    viewUpload.view.frame = self.view.bounds;
    [self.view addSubview:viewUpload.view];
    [viewUpload didMoveToParentViewController:self];
    viewUpload.view.hidden = true;
    
    UIScreen *screen = [UIScreen mainScreen];
    
    buttonUploadStatus = [[UIButton alloc] initWithFrame:CGRectMake(280, screen.bounds.size.height-110, 30, 30)];
    [buttonUploadStatus addTarget:self action:@selector(toggleUpload:) forControlEvents:UIControlEventTouchUpInside];
    hudUpload = [[MBRoundProgressView alloc] initWithFrame:buttonUploadStatus.bounds];
    hudUpload.userInteractionEnabled = NO;
    [buttonUploadStatus addSubview:hudUpload];
    [self.view addSubview:buttonUploadStatus];
    buttonUploadStatus.hidden = YES;
    
    [[UITabBar appearance] setTintColor:[UIColor redColor]];
}

- (void)receivePushNotify:(NSNotification*)notify {
    if (self.selectedIndex != 3) {
        NSDictionary *userInfo = notify.object;
        if ([userInfo objectForKey:@"aps"]) {
            NSDictionary *aps = [userInfo objectForKey:@"aps"];
            if ([aps objectForKey:@"badge"]) {
                NSNumber *count = [aps objectForKey:@"badge"];
                UIViewController* notifyView = self.viewControllers[3];
                notifyView.tabBarItem.badgeValue = [count stringValue];
            }
        }
    } else {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

- (void)showNotify {
    [[LatteAPIClient sharedClient] GET:@"user/me/unread_announcement"
                                parameters: nil
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       //viewNotify.notifyCount = [[JSON objectForKey:@"announcement_count"] integerValue];
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       DLog(@"Something went wrong (Announcement count)");
                                   }];
}

- (void)showSetting:(id)sender {
    UIStoryboard* storySetting = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
    [self presentViewController:[storySetting instantiateInitialViewController] animated:YES completion:nil];

}


- (void)cameraView:(id)sender {
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        UIStoryboard* storyCamera = [UIStoryboard storyboardWithName:@"Camera" bundle:nil];
        
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                  message:@"Device has no camera"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            
        } else {
            LXImagePickerController *imagePicker = [storyCamera instantiateViewControllerWithIdentifier:@"Picker"];
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = imagePicker;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    } else if (buttonIndex == 1) {
//        UIStoryboard* storyCamera = [UIStoryboard storyboardWithName:@"Camera" bundle:nil];
        //LXImagePickerController *imagePicker = [storyCamera instantiateViewControllerWithIdentifier:@"Picker"];
        LXImagePickerController *imagePicker = [[LXImagePickerController alloc] init];
        imagePicker.delegate = imagePicker;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)setGuest {
    LXNavMypageController *navMypage = self.viewControllers[4];
//    navMypage.tabBarItem.image = [UIImage imageNamed:@"icon_login.png"];    
    UIStoryboard* storyMain = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
    UIViewController *viewLogin = [storyMain instantiateViewControllerWithIdentifier:@"Login"];
    
    navMypage.viewControllers = [NSArray arrayWithObject:viewLogin];
}

- (void)setUser {
    LXNavMypageController *navMypage = self.viewControllers[4];
//    navMypage.tabBarItem.image = [UIImage imageNamed:@"icon_mypage.png"];
    UIStoryboard* storyMain = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *viewMypage = [storyMain instantiateViewControllerWithIdentifier:@"Home"];
    navMypage.viewControllers = [NSArray arrayWithObject:viewMypage];
}

- (void)receiveLoggedIn:(NSNotification *) notification {
    [self setUser];
    
    // Register for Push Notification
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

- (void)receiveLoggedOut:(NSNotification *) notification {
    [self setGuest];
}

- (void)showUser:(NSNotification *)notify {
    self.selectedIndex = 4;
    UINavigationController *nav = (id)self.selectedViewController;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXUserPageViewController *viewUser = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    User *user = notify.object;
    viewUser.user = user;
    [nav pushViewController:viewUser animated:YES];
}


- (void)touchTitle:(id)sender {
    UINavigationController *nav = (UINavigationController*)self.selectedViewController;
    UITableViewController *view = (UITableViewController*)nav.visibleViewController;
    if ([view respondsToSelector:@selector(tableView)]) {
        
        // No animation to prevent too much pageview counter request
        [view.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
}

- (void)uploadStart:(NSNotification *) notification {
    buttonUploadStatus.hidden = NO;
}

- (void)uploadSuccess:(NSNotification *) notification {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    buttonUploadStatus.hidden = app.uploader.count == 0;
    if (app.uploader.count == 0) {
        self.selectedIndex = 4;
        UINavigationController *navMypage = (UINavigationController*)self.selectedViewController;
        if ([navMypage.viewControllers[0] respondsToSelector:@selector(reloadView)]) {
            [navMypage.viewControllers[0] performSelector:@selector(reloadView)];
        }
    }
}

- (void)uploadProgess:(NSNotification *) notification {
    float percent = 0;
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    for (LXUploadObject *uploader in app.uploader) {
        percent += uploader.percent;
    }
    hudUpload.progress = percent/app.uploader.count;
}

- (void)toggleUpload:(id)sender {
    if (viewUpload.view.hidden) {
        viewUpload.view.alpha = 0;
        viewUpload.view.hidden = false;
        [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
            viewUpload.view.alpha = 1;
        }];
    } else {
        [UIView animateWithDuration:kGlobalAnimationSpeed animations:^{
            viewUpload.view.alpha = 0;
        } completion:^(BOOL finished) {
            viewUpload.view.hidden = true;
        }];
    }
}

- (void)statusBarOverlayDidRecognizeGesture:(UIGestureRecognizer *)gestureRecognizer {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    UINavigationController *viewConfirm = [mainStoryboard instantiateViewControllerWithIdentifier:@"NavConfirmEmail"];
    [self presentViewController:viewConfirm animated:YES completion:nil];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController NS_AVAILABLE_IOS(3_0) {
    if (viewController == tabBarController.viewControllers[2]) {
        UIActionSheet *actionUpload = [[UIActionSheet alloc] initWithTitle:@""
                                                                  delegate:self cancelButtonTitle:@"Cancel"
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:@"Camera", @"Photo Library", nil];
        [actionUpload showFromTabBar:self.tabBar];
        return false;
    }
    
    return true;
}

@end
