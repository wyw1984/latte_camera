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
#import "LatteAPIClient.h"

#import "mach/mach.h"

#import "NSDate+TKCategory.h"
#import "NSDate+CalendarGrid.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@implementation LXUtils

+ (void)setNationalityOfUser:(User *)user forImage:(UIImageView*)imageNationality nextToLabel:(UILabel*)label {
    if (user.nationality.length > 0) {
        NSString *filename = [NSString stringWithFormat:@"%@.png", [user.nationality uppercaseString]];
        imageNationality.image = [UIImage imageNamed:filename];
        imageNationality.hidden = false;
    } else {
        imageNationality.hidden = true;
    }
}

+ (void)globalShadow:(UIView*)view {
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    view.layer.shadowOpacity = 0.25;
    view.layer.shadowRadius = 1.0;
    view.layer.shadowPath = shadowPath.CGPath;
}

+ (void)globalRoundShadow:(UIView*)view {
    view.layer.cornerRadius = 5;
    view.clipsToBounds = YES;
}


+ (void)toggleLike:(UIButton*)sender ofPicture:(Picture*)pic {
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    if (!app.currentUser) {
        sender.enabled = NO;
    }
    
    pic.isVoted = !pic.isVoted;
    sender.selected = pic.isVoted;
    
    BOOL increase = pic.isVoted;

    pic.voteCount = [NSNumber numberWithInteger:[pic.voteCount integerValue] + (increase?1:-1)];

    [sender setTitle:[pic.voteCount stringValue] forState:UIControlStateNormal];
    
    NSDictionary *param = @{@"vote_type": [NSNumber numberWithInteger:1]};
    
    NSString *url = [NSString stringWithFormat:@"picture/%ld/vote_post", (long)[pic.pictureId integerValue]];
    [[LatteAPIClient sharedClient] POST:url
                                 parameters:param
                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                        DLog(@"Submited like");
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", "Error")
                                                                                        message:error.localizedDescription
                                                                                       delegate:nil
                                                                              cancelButtonTitle:NSLocalizedString(@"close", "Close")
                                                                              otherButtonTitles:nil];
                                        [alert show];
                                        DLog(@"Something went wrong (Vote)");
                                    }];
        
    //Animation
    sender.imageView.transform = CGAffineTransformIdentity;

    [UIView animateWithDuration:0.3 animations:^{
        sender.imageView.transform = CGAffineTransformMakeScale(0.3, 0.3);
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
    NSNumber *count = notify[@"count"];

    for (int i = 0; i < users.count; i++) {
        User* user = users[i];
        if (i > 0)
            stringUsers = [stringUsers stringByAppendingString:NSLocalizedString(@"and", @"と")];
        
        if (user.name != nil) {
            stringUsers = [stringUsers stringByAppendingString:user.name];
        } else {
            stringUsers = [stringUsers stringByAppendingString:NSLocalizedString(@"guest", @"ゲスト") ];
        }
        
        if (i < users.count) {
            stringUsers = [stringUsers stringByAppendingString:NSLocalizedString(@"subfix", @"さん") ];
        }
    }
    
    if ([count integerValue] > 2) {
        stringUsers = [stringUsers stringByAppendingString:NSLocalizedString(@"and", @"と")];
        stringUsers = [stringUsers stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"x_others", "%d others"), ([count integerValue] - 2)]];
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
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
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
    return [LXUtils dateFromJSON:aDate timezone:YES];
}

+ (NSDate *)dateFromJSON:(NSString *)aDate timezone:(BOOL)timezone {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    
    if (timezone) {
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"JST"];
        [dateFormatter setTimeZone:gmt];
    }

    NSDate *date = [dateFormatter dateFromString:aDate];
    
    return date;
}

+ (NSDate *)dateFromString:(NSString *)aDate {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    
    NSDate *date = [dateFormatter dateFromString:aDate];
    
    return date;
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

vm_size_t usedMemory(void) {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
}

vm_size_t freeMemory(void) {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;
    
    host_page_size(host_port, &pagesize);
    (void) host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    return vm_stat.free_count * pagesize;
}

+(void)logMemUsage {
    // compute memory usage and log if different by >= 100k
    static long prevMemUsage = 0;
    long curMemUsage = usedMemory();
    long memUsageDiff = curMemUsage - prevMemUsage;
    
    if (memUsageDiff > 100000 || memUsageDiff < -100000) {
        prevMemUsage = curMemUsage;
        NSLog(@"Memory used %7.1f (%+5.0f), free %7.1f kb", curMemUsage/1000.0f, memUsageDiff/1000.0f, freeMemory()/1000.0f);
    }
}

+ (NSArray*) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday timeZone:(NSTimeZone*)timeZone{
	
	NSDate *firstDate, *lastDate;
	
	NSDateComponents *info = [date dateComponentsWithTimeZone:timeZone];
	
	info.day = 1;
	info.hour = info.minute = info.second = 0;
	
	NSDate *currentMonth = [NSDate dateWithDateComponents:info];
	info = [currentMonth dateComponentsWithTimeZone:timeZone];
	
	
	NSDate *previousMonth = [currentMonth previousMonthWithTimeZone:timeZone];
	NSDate *nextMonth = [currentMonth nextMonthWithTimeZone:timeZone];
	
	if(info.weekday > 1 && sunday){
		
		NSDateComponents *info2 = [previousMonth dateComponentsWithTimeZone:timeZone];
		
		NSInteger preDayCnt = [previousMonth daysBetweenDate:currentMonth];
		info2.day = preDayCnt - info.weekday + 2;
		firstDate = [NSDate dateWithDateComponents:info2];
		
		
	}else if(!sunday && info.weekday != 2){
		
		NSDateComponents *info2 = [previousMonth dateComponentsWithTimeZone:timeZone];
		NSInteger preDayCnt = [previousMonth daysBetweenDate:currentMonth];
		if(info.weekday==1){
			info2.day = preDayCnt - 5;
		}else{
			info2.day = preDayCnt - info.weekday + 3;
		}
		firstDate = [NSDate dateWithDateComponents:info2];
		
		
		
	}else{
		firstDate = currentMonth;
	}
	
	
	
	NSInteger daysInMonth = [currentMonth daysBetweenDate:nextMonth];
	info.day = daysInMonth;
	NSDate *lastInMonth = [NSDate dateWithDateComponents:info];
	NSDateComponents *lastDateInfo = [lastInMonth dateComponentsWithTimeZone:timeZone];
    
	
	
	if(lastDateInfo.weekday < 7 && sunday){
		
		lastDateInfo.day = 7 - lastDateInfo.weekday;
		lastDateInfo.month++;
		lastDateInfo.weekday = 0;
		if(lastDateInfo.month>12){
			lastDateInfo.month = 1;
			lastDateInfo.year++;
		}
		lastDate = [NSDate dateWithDateComponents:lastDateInfo];
        
	}else if(!sunday && lastDateInfo.weekday != 1){
		
		
		lastDateInfo.day = 8 - lastDateInfo.weekday;
		lastDateInfo.month++;
		if(lastDateInfo.month>12){ lastDateInfo.month = 1; lastDateInfo.year++; }
        
		
		lastDate = [NSDate dateWithDateComponents:lastDateInfo];
        
	}else{
		lastDate = lastInMonth;
	}
	
	
	
	return @[firstDate,lastDate];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)showFBAuthError:(NSError*)error {
    NSString *alertMessage;
    
    if (error.fberrorShouldNotifyUser) {
        if ([[error userInfo][FBErrorLoginFailedReason]
             isEqualToString:FBErrorLoginFailedReasonSystemDisallowedWithoutErrorValue]) {
            // Show a different error message
            alertMessage = NSLocalizedString(@"Go to Settings > Facebook and turn ON Latte camera.", @"");
            // Perform any additional customizations
        } else {
            // If the SDK has a message for the user, surface it.
            alertMessage = error.fberrorUserMessage;
        }
    } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
        // The user has cancelled a login. You can inspect the error
        // for more context. For this sample, we will simply ignore it.
        NSLog(@"user cancelled login");
    } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
        // It is important to handle session closures since they can happen
        // outside of the app. You can inspect the error for more context
        // but this sample generically notifies the user.
        alertMessage = NSLocalizedString(@"Your current session is no longer valid. Please log in again.", @"");
    } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
        NSInteger underlyingSubCode = [[error userInfo]
                                       [@"com.facebook.sdk:ParsedJSONResponseKey"]
                                       [@"body"]
                                       [@"error"]
                                       [@"error_subcode"] integerValue];
        if (underlyingSubCode == 458) {
            alertMessage = NSLocalizedString(@"The app was removed. Please log in again.", @"");
        } else {
            alertMessage = NSLocalizedString(@"Your current session is no longer valid. Please log in again.", @"");
        }
    } else {
        // For simplicity, this sample treats other errors blindly.
        alertMessage = NSLocalizedString(@"Error. Please try again later.", @"");
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"")
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"close", @"")
                          otherButtonTitles:nil] show];
    }
}

+ (UIImage*)imageNamed:(NSString*)name {
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [documentPath objectAtIndex:0];
    NSString *tonesPath = [documentFolder stringByAppendingPathComponent:@"Assets"];
    NSString *tonePath = [tonesPath stringByAppendingPathComponent:name];
    if (![[NSFileManager defaultManager] fileExistsAtPath:tonePath])
        return [UIImage imageNamed:name];
    else
        return [UIImage imageWithContentsOfFile:tonePath];
}

+ (void)saveImageDateToLib:(NSData*)imageData metadata:(NSDictionary *)metadata {
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageDataToSavedPhotosAlbum:imageData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL saveToAlbum;
        if ([defaults objectForKey:@"LatteSaveToAlbum"]) {
            saveToAlbum = [defaults boolForKey:@"LatteSaveToAlbum"];
        } else {
            saveToAlbum = YES;
        }
        
        if (saveToAlbum) {
            [library addAssetURL:assetURL toAlbum:@"Latte camera" withCompletionBlock:^(NSError *error) {
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"C")
                                                                    message:error.localizedDescription
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }
        
        
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"cannot_save_photo", @"Cannot save to Camera Roll")
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

+ (void)saveImageRefToLib:(CGImageRef)imageRef metadata:(NSDictionary *)metadata {
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageToSavedPhotosAlbum:imageRef metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL saveToAlbum;
        if ([defaults objectForKey:@"LatteSaveToAlbum"]) {
            saveToAlbum = [defaults boolForKey:@"LatteSaveToAlbum"];
        } else {
            saveToAlbum = YES;
        }
        
        if (saveToAlbum) {
            [library addAssetURL:assetURL toAlbum:@"Latte camera" withCompletionBlock:^(NSError *error) {
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"C")
                                                                    message:error.localizedDescription
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }
        
        
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"cannot_save_photo", @"Cannot save to Camera Roll")
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}


@end
