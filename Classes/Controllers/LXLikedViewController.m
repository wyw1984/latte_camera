//
//  luxeysFav2ViewController.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/01.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXLikedViewController.h"

@interface LXLikedViewController ()

@end

@implementation LXLikedViewController

@synthesize buttonNavRight;
@synthesize loadIndicator;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [app.tracker sendView:@"Liked Screen"];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sub_back.png"]];
    // Do any additional setup after loading the view.
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [self.tableView addSubview:refreshHeaderView];
    
    //Init sidebar
    UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:app.revealController action:@selector(revealGesture:)];
    [self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
    [buttonNavRight addTarget:app.revealController action:@selector(revealLeft:) forControlEvents:UIControlEventTouchUpInside];
    
    [self reloadFav];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)reloadFav {
    [loadIndicator startAnimating];
    LXAppDelegate* app = (LXAppDelegate*)[UIApplication sharedApplication].delegate;
    [[LatteAPIClient sharedClient] getPath:@"picture/user/me/voted"
                                parameters: [NSDictionary dictionaryWithObjectsAndKeys:
                                             [app getToken], @"token", nil]
                                   success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                       pics = [Picture mutableArrayFromDictionary:JSON withKey:@"pictures"];
                                       [self.tableView reloadData];
                                       
                                       [self doneLoadingTableViewData];
                                       [loadIndicator stopAnimating];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       TFLog(@"Something went wrong (Fav)");
                                       
                                       [self doneLoadingTableViewData];
                                       [loadIndicator stopAnimating];
                                   }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return pics.count / 4 + (pics.count%4>0?1:0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavRow"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FavRow"];
    }
    
    for (UIView *subview in cell.subviews) {
        [subview removeFromSuperview];
    }
    
    for (int i = 0; i < 4; i++) {
        NSInteger idx = indexPath.row * 4 + i;
        if (idx < pics.count) {
            UIButton *buttonPic = [[UIButton alloc] initWithFrame:CGRectMake(6 + i * 78, 0, 74, 74)];
            Picture *pic = pics[idx];
            buttonPic.tag = [pic.pictureId integerValue];
            
            buttonPic.layer.borderColor = [[UIColor whiteColor] CGColor];
            buttonPic.layer.borderWidth = 3;
            UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:buttonPic.bounds];
            buttonPic.layer.masksToBounds = NO;
            buttonPic.layer.shadowColor = [UIColor blackColor].CGColor;
            buttonPic.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
            buttonPic.layer.shadowOpacity = 0.5f;
            buttonPic.layer.shadowRadius = 1.5f;
            buttonPic.layer.shadowPath = shadowPathPic.CGPath;

            [buttonPic loadBackground:pic.urlSquare];
            [buttonPic addTarget:self action:@selector(showPic:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:buttonPic];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 78;
}

- (void)showPic:(UIButton *)button {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXPicDetailViewController *viewPicDetail = [mainStoryboard instantiateViewControllerWithIdentifier:@"PictureDetail"];
    viewPicDetail.pic = [[pics filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"pictureId == %d", button.tag]]] lastObject];

    [self.navigationController pushViewController:viewPicDetail animated:YES];
}

#pragma mark - Table view delegate

- (void)reloadTableViewDataSource{
    reloading = YES;
}

- (void)doneLoadingTableViewData{
    reloading = NO;
    [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
    
    [self reloadFav];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 6;
}
- (void)viewDidUnload {
    [self setLoadIndicator:nil];
    [super viewDidUnload];
}
@end