//
//  luxeysRankingViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 9/4/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface luxeysRankingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *buttonDaily;
@property (strong, nonatomic) IBOutlet UIButton *buttonWeekly;
@property (strong, nonatomic) IBOutlet UIButton *buttonMonthly;
@property (strong, nonatomic) IBOutlet UITableView *tableRank;
@property (strong, nonatomic) IBOutlet UIView *viewTab;

@property (strong, nonatomic) NSMutableArray *arPics;
- (IBAction)touchTab:(UIButton*)sender;

- (void)loadRanking;
- (void)loadMore;
@end
