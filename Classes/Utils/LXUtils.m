//
//  luxeysImageUtils.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/24/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXUtils.h"
#import <Foundation/Foundation.h>

#import "User.h"
#import "Picture.h"
#import "Feed.h"
#import "Comment.h"

#import "LXAppDelegate.h"

@implementation LXUtils

+ (void)globalShadow:(UIView*)view {
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    view.layer.shadowOpacity = 0.3;
    view.layer.shadowRadius = 3.0;
    view.layer.shadowPath = shadowPath.CGPath;
}

+ (void)globalRoundShadow:(UIView*)view {
    view.layer.cornerRadius = 5;
    view.clipsToBounds = YES;
}

+ (void)toggleLike:(UIButton*)sender ofPicture:(Picture*)pic {
    [LXUtils toggleLike:sender ofPicture:pic setCount:nil];
}

+ (void)toggleLike:(UIButton*)sender ofPicture:(Picture*)pic setCount:(UILabel*)labelCount {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (!app.currentUser) {
        sender.enabled = NO;
    }
    
    pic.isVoted = !pic.isVoted;
    sender.selected = pic.isVoted;
    
    BOOL increase = pic.isVoted;

    pic.voteCount = [NSNumber numberWithInteger:[pic.voteCount integerValue] + (increase?1:-1)];
    if (labelCount != nil) {
        labelCount.text = [pic.voteCount stringValue];
    } else {
        [sender setTitle:[pic.voteCount stringValue] forState:UIControlStateNormal];
    }
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           @"1", @"vote_type",
                           nil];
    if (app.currentUser != nil) {
        [param setObject:[app getToken] forKey:@"token"];
    }
    
    
    NSString *url = [NSString stringWithFormat:@"picture/%d/vote_post", [pic.pictureId integerValue]];
    [[LatteAPIClient sharedClient] postPath:url
                                 parameters:param
                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                        TFLog(@"Submited like");
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                        message:error.localizedDescription
                                                                                       delegate:nil
                                                                              cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                              otherButtonTitles:nil];
                                        [alert show];
                                        TFLog(@"Something went wrong (Vote)");
                                    }];
}

+ (Picture *)picFromPicID:(long)picID of:(NSArray *)feeds {
    for (Feed *feed in feeds) {
        if ([feed.model integerValue] == 1) {
            for (Picture *pic in feed.targets) {
                if ([pic.pictureId integerValue] == picID) {
                    return pic;
                }
            }
        }
    }
    return nil;
}

+ (Feed *)feedFromPicID:(long)picID of:(NSArray *)feeds {
    for (Feed *feed in feeds) {
        for (Picture *pic in feed.targets) {
            if ([pic.pictureId integerValue] == picID) {
                return feed;
            }
        }
    }
    return nil;
}

+ (CGSize)newSizeOfPicture:(Picture*)picture withWidth:(CGFloat)width {
    return CGSizeMake(width, width*[picture.height floatValue]/[picture.width floatValue]);
}


+ (NSString *)stringFromNotify:(NSDictionary *)notify {
    NSString * stringUsers = @"";
    NSMutableArray *users = [User mutableArrayFromDictionary:notify withKey:@"users"];

    for (int i = 0; i < users.count; i++) {
        User* user = users[i];
        if (i > 0)
            stringUsers= [stringUsers stringByAppendingString:NSLocalizedString(@"and", @"と")];
        
        if (user.name != nil) {
            stringUsers = [stringUsers stringByAppendingString:user.name];
        } else {
            stringUsers = [stringUsers stringByAppendingString:NSLocalizedString(@"guest", @"ゲスト") ];
        }
        
        if (i < users.count-1) {
            stringUsers = [stringUsers stringByAppendingString:NSLocalizedString(@"subfix", @"さん") ];
        }
    }
    
    NSString * notifyString;
    NotifyKind notifyKind = [[notify objectForKey:@"kind"] integerValue];
    switch (notifyKind) {
        case kNotifyKindComment: {
            notifyString = [NSString stringWithFormat:NSLocalizedString(@"notify_commented", @"が、あなたの写真にコメントしました。"), stringUsers];
            break;
        }
        case kNotifyKindLike: {
            NotifyTarget notifyTarget = [[notify objectForKey:@"target_model"] integerValue];
            switch (notifyTarget) {
                case kNotifyTargetComment: {
                    Comment *comment = [Comment instanceFromDictionary:[notify objectForKey:@"target"]];
                    notifyString = [NSString stringWithFormat:NSLocalizedString(@"notify_like_comment", @"が、あなたのコメントを「いいね！」と評価しました。"), stringUsers, comment.descriptionText];
                    break;
                }
                case kNotifyTargetPicture:
                    notifyString = [NSString stringWithFormat:NSLocalizedString(@"notify_like_photo", @"が、あなたの写真を「いいね！」と評価しました。"), stringUsers];
                    break;
                default:
                    break;
            }
            break;
        }
        case kNotifyKindFollow: // target update
        {
            User *user = [User instanceFromDictionary:[notify objectForKey:@"target"]];
            notifyString = [NSString stringWithFormat:NSLocalizedString(@"apns_user_follow", @""), user.name];
            break;
        }
        default:
            notifyString = @"target update";
            break;
    }
    return notifyString;
}

+ (NSInteger)heightFromWidth:(CGFloat)newwidth width:(CGFloat)width height:(CGFloat)height {
    return (NSInteger)(newwidth*height/width);
}

+ (NSString *)timeDeltaFromNow:(NSDate*)aDate {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    [dateFormatter setDoesRelativeDateFormatting:YES];
    return [dateFormatter stringFromDate:aDate];
}

+ (NSString *)dateToString:(NSDate*)aDate {
    return [NSDateFormatter localizedStringFromDate:aDate
                                          dateStyle:NSDateFormatterShortStyle
                                          timeStyle:NSDateFormatterShortStyle];
}


+ (NSDate *)dateFromJSON:(NSString *)aDate {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    return [dateFormatter dateFromString:aDate];
}

+ (NSDictionary *)getGPSDictionaryForLocation:(CLLocation *)location {
    NSMutableDictionary *gps = [NSMutableDictionary dictionary];

    // GPS tag version
    [gps setObject:@"2.2.0.0" forKey:(NSString *)kCGImagePropertyGPSVersion];

    // Time and date must be provided as strings, not as an NSDate object
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss.SSSSSS"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSTimeStamp];
    [formatter setDateFormat:@"yyyy:MM:dd"];
    [gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSDateStamp];

    // Latitude
    CGFloat latitude = location.coordinate.latitude;
    if (latitude < 0) {
        latitude = -latitude;
        [gps setObject:@"S" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    } else {
        [gps setObject:@"N" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    }
    [gps setObject:[NSNumber numberWithFloat:latitude] forKey:(NSString *)kCGImagePropertyGPSLatitude];

    // Longitude
    CGFloat longitude = location.coordinate.longitude;
    if (longitude < 0) {
        longitude = -longitude;
        [gps setObject:@"W" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    } else {
        [gps setObject:@"E" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    }
    [gps setObject:[NSNumber numberWithFloat:longitude] forKey:(NSString *)kCGImagePropertyGPSLongitude];

    // Altitude
    CGFloat altitude = location.altitude;
    if (!isnan(altitude)){
        if (altitude < 0) {
            altitude = -altitude;
            [gps setObject:@"1" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        } else {
            [gps setObject:@"0" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        }
        [gps setObject:[NSNumber numberWithFloat:altitude] forKey:(NSString *)kCGImagePropertyGPSAltitude];
    }

    // Speed, must be converted from m/s to km/h
    if (location.speed >= 0){
        [gps setObject:@"K" forKey:(NSString *)kCGImagePropertyGPSSpeedRef];
        [gps setObject:[NSNumber numberWithFloat:location.speed*3.6] forKey:(NSString *)kCGImagePropertyGPSSpeed];
    }

    // Heading
    if (location.course >= 0){
        [gps setObject:@"T" forKey:(NSString *)kCGImagePropertyGPSTrackRef];
        [gps setObject:[NSNumber numberWithFloat:location.course] forKey:(NSString *)kCGImagePropertyGPSTrack];
    }

    return gps;
}

@end
