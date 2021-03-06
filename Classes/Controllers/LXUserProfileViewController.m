//
//  LXUserProfileViewController.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 6/23/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXUserProfileViewController.h"
#import "UIImageView+loadProgress.h"
#import "LXAppDelegate.h"
#import "LatteAPIv2Client.h"
#import "LXCellDataField.h"
#import "MZFormSheetSegue.h"

@interface LXUserProfileViewController () {
    NSMutableSet *showSet;
    NSMutableArray *showField;
    NSDictionary *userDict;
}

@end

@implementation LXUserProfileViewController

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
    
    showSet = [NSMutableSet setWithObjects: @"name", @"introduction", @"gender", @"current_residence", @"hometown", @"age", @"birthdate", @"bloodtype", @"occupation", @"hobby", @"nationality", nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)setUser:(User *)user {
    _user = user;
    
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (app.currentUser && ([_user.userId integerValue] == [app.currentUser.userId integerValue])) {
        self.tableView.tableFooterView = nil;
    }
    
    NSString *url2 = [NSString stringWithFormat:@"user/%ld", [_user.userId longValue]];
    
    [[LatteAPIv2Client sharedClient] GET:url2 parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
        _buttonBlock.selected = [JSON[@"is_blocking"] boolValue];
    } failure:nil];
    
    NSString *url = [NSString stringWithFormat:@"user/%ld", [_user.userId longValue]];
    [[LatteAPIClient sharedClient] GET:url
                            parameters: nil
                               success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                   userDict = [JSON objectForKey:@"user"];
                                   
                                   _labelFollowingCount.text = [userDict[@"count_follows"] stringValue];
                                   _labelFollowerCount.text = [userDict[@"count_followers"] stringValue];
                                   _labelPictureCount.text = [userDict[@"count_pictures"] stringValue];
                                   _labelViewCount.text = [userDict[@"page_views"] stringValue];
                                   _labelLikeCount.text = [userDict[@"vote_count"] stringValue];
                                   
                                   
                                   NSSet *allField = [NSSet setWithArray:[userDict allKeys]];
                                   
                                   [showSet intersectSet:allField];
                                   showField = [NSMutableArray arrayWithArray:[showSet allObjects]];
                                   [showField removeObject:@"name"];
                                   [showField insertObject:@"name" atIndex:0];
                                   
                                   
                                   NSString *profilePic = userDict[@"profile_picture_hi"];
                                   if (!profilePic) profilePic = userDict[@"profile_picture"];
                                   
                                   if (profilePic) {
                                       [_imageProfile loadProgess:profilePic withCompletion:^(BOOL isCache) {

                                       } progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                                           _imageProgress.progress = (float)totalBytesRead/(float)totalBytesExpectedToRead;
                                       }];
                                   } else {
                                       self.tableView.tableHeaderView.frame = CGRectMake(0, 0, 320, 60);
                                       self.tableView.tableHeaderView = self.tableView.tableHeaderView;
                                   }
                                   
                                   [self.tableView reloadData];
                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   DLog(@"Something went wrong (Profile)");
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
    return [showField count] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LXCellDataField *cell = [tableView dequeueReusableCellWithIdentifier:@"Profile" forIndexPath:indexPath];
    
    if (indexPath.row == showField.count) {
        cell.labelField.text = @"URL";
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        if ([language isEqualToString:@"ja"]) {
            cell.labelDetail.text = [NSString stringWithFormat:@"http://latte.la/photo/%ld", (long)[_user.userId integerValue]];
        } else {
            cell.labelDetail.text = [NSString stringWithFormat:@"http://en.latte.la/photo/%ld", (long)[_user.userId integerValue]];
        }
        cell.labelDetail.highlighted = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        return cell;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.labelDetail.highlighted = NO;
    }
    
    cell.imageStatus.hidden = YES;
    
    NSString* strKey = [showField objectAtIndex:indexPath.row];
    if ([strKey isEqualToString:@"gender"]) {
        cell.labelField.text = NSLocalizedString(@"gender", @"性別");
        cell.imageStatus.hidden = NO;
        cell.imageStatus.image = [self imageFromStatus:[userDict[@"gender_public"] integerValue]];
    } else if ([strKey isEqualToString:@"current_residence"]) {
        cell.labelField.text = NSLocalizedString(@"current_residence", @"現住所");
        cell.imageStatus.hidden = NO;
        cell.imageStatus.image = [self imageFromStatus:[userDict[@"current_residence_public"] integerValue]];
    } else if ([strKey isEqualToString:@"hometown"]) {
        cell.labelField.text = NSLocalizedString(@"hometown", @"出身地");
        cell.imageStatus.hidden = NO;
        cell.imageStatus.image = [self imageFromStatus:[userDict[@"hometown_public"] integerValue]];
    } else if ([strKey isEqualToString:@"age"]) {
        cell.labelField.text = NSLocalizedString(@"age", @"年齢");
        cell.imageStatus.hidden = NO;
        cell.imageStatus.image = [self imageFromStatus:[userDict[@"birthyear_public"] integerValue]];
    } else if ([strKey isEqualToString:@"birthdate"]) {
        cell.labelField.text = NSLocalizedString(@"birthdate", @"誕生日");
        cell.imageStatus.hidden = NO;
        cell.imageStatus.image = [self imageFromStatus:[userDict[@"birthdate_public"] integerValue]];
    } else if ([strKey isEqualToString:@"bloodtype"]) {
        cell.labelField.text = NSLocalizedString(@"bloodtype", @"血液型");
        cell.imageStatus.hidden = NO;
        cell.imageStatus.image = [self imageFromStatus:[userDict[@"bloodtype_public"] integerValue]];
    } else if ([strKey isEqualToString:@"occupation"]) {
        cell.labelField.text = NSLocalizedString(@"occupation", @"職業");
    } else if ([strKey isEqualToString:@"hobby"]) {
        cell.labelField.text = NSLocalizedString(@"hobby", @"趣味");
    } else if ([strKey isEqualToString:@"introduction"]) {
        cell.labelField.text = NSLocalizedString(@"introduction", @"自己紹介");
    } else if ([strKey isEqualToString:@"nationality"]) {
        cell.labelField.text = NSLocalizedString(@"nationality", @"国籍");
        cell.imageStatus.hidden = NO;
        cell.imageStatus.image = [self imageFromStatus:[userDict[@"nationality_public"] integerValue]];
    } else if ([strKey isEqualToString:@"name"]) {
        cell.labelField.text = NSLocalizedString(@"username", @"ニックネーム");
    }
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    if (app.currentUser && ([_user.userId integerValue] == [app.currentUser.userId integerValue])) {
    } else {
        cell.imageStatus.hidden = YES;
    }
    
    if ([strKey isEqualToString:@"gender"]) {
        switch ([[userDict objectForKey:strKey] integerValue]) {
            case 1:
                cell.labelDetail.text = NSLocalizedString(@"male", @"男性");
                break;
            case 2:
                cell.labelDetail.text = NSLocalizedString(@"female", @"女性");
                break;
        }
    } else if ([strKey isEqualToString:@"nationality"]) {
        NSLocale *locale = [NSLocale currentLocale];
        NSString *countryCode = [userDict objectForKey:strKey];
        NSString *displayNameString = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
        cell.labelDetail.text = displayNameString;
    } else {
        cell.labelDetail.text = [userDict objectForKey:strKey];
    }
    
//    CGRect frame = cell.detailTextLabel.frame;
//    CGSize size = [cell.detailTextLabel.text sizeWithFont:cell.labelDetail.font
//                                    constrainedToSize:CGSizeMake(212.0, CGFLOAT_MAX)
//                                        lineBreakMode:NSLineBreakByWordWrapping];
//    frame.size.height = size.height;
//    cell.labelDetail.frame = frame;
    
    return cell;
}

- (UIImage*)imageFromStatus:(NSInteger)status {
    switch (status) {
        case PictureStatusPublic:
            return [UIImage imageNamed:@"icon28-status40-brown.png"];
            break;
        case PictureStatusMember:
            return [UIImage imageNamed:@"icon28-status30-brown.png"];
            break;
        case PictureStatusFriendsOnly:
            return [UIImage imageNamed:@"icon28-status10-brown.png"];
            break;
        case PictureStatusPrivate:
            return [UIImage imageNamed:@"icon28-status0-brown.png"];
            break;
        default:
            break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == showField.count) {
        return 30;
    }
    NSString* strKey = [showField objectAtIndex:indexPath.row];
    
    if ([strKey isEqualToString:@"hobby"] || [strKey isEqualToString:@"introduction"]) {
        CGSize size = [[userDict objectForKey:strKey] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]
                                                 constrainedToSize:CGSizeMake(212.0, CGFLOAT_MAX)
                                                     lineBreakMode:NSLineBreakByWordWrapping];
        return size.height + 12;
    } else {
        return 30;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == showField.count) {
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        if ([language isEqualToString:@"ja"]) {
            NSString *url = [NSString stringWithFormat:@"http://latte.la/photo/%ld", (long)[_user.userId integerValue]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        } else {
            NSString *url = [NSString stringWithFormat:@"http://en.latte.la/photo/%ld", (long)[_user.userId integerValue]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)touchBlock:(id)sender {
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        [_parent showBlockUser];
    }];
}

- (IBAction)touchReport:(id)sender {
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        [_parent showReport];
    }];
}
@end
