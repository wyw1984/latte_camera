//
//  LXNavGalleryViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/7/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXNavGalleryViewController.h"

@interface LXNavGalleryViewController ()

@end

@implementation LXNavGalleryViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:animated];
    [super viewWillDisappear:animated];
}

@end