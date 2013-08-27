//
//  LXModalNavigationController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 8/22/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXModalNavigationController.h"
#import "LXButtonBrown30.h"
#import "LXButtonBack.h"

@interface LXModalNavigationController ()

@end

@implementation LXModalNavigationController

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
    self.delegate = self;
	// Do any additional setup after loading the view.
}

- (void)closeModal:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)popViewController:(id)sender {
    [self popViewControllerAnimated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!viewController.navigationItem.rightBarButtonItem) {
        LXButtonBrown30 *buttonClose = [[LXButtonBrown30 alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
        [buttonClose setTitle:NSLocalizedString(@"CLOSE", @"CLOSE") forState:UIControlStateNormal];
        viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonClose];
        [buttonClose addTarget:self action:@selector(closeModal:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (navigationController.viewControllers[0] != viewController) {
        LXButtonBack *buttonBack = [[LXButtonBack alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
        [buttonBack setTitle:NSLocalizedString(@"back", @"BACK") forState:UIControlStateNormal];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
        [buttonBack addTarget:self action:@selector(popViewController:) forControlEvents:UIControlEventTouchUpInside];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end