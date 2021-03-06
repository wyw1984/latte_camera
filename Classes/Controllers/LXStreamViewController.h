//
//  LXStreamViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/4/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTCollectionViewWaterfallLayout.h"
#import "LXGalleryViewController.h"

@interface LXStreamViewController : UICollectionViewController <CHTCollectionViewDelegateWaterfallLayout, LXGalleryViewControllerDataSource>
@property (strong, nonatomic) IBOutlet UIButton *buttonCountry;

- (IBAction)showMenu:(id)sender;
- (IBAction)touchCountry:(id)sender;

@end
