//
//  luxeysImageUtils.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/24/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>

@class Feed, Picture, User;

@interface LXUtils : NSObject

+ (NSInteger)heightFromWidth:(CGFloat)newwidth width:(CGFloat)width height:(CGFloat)height;
+ (NSString *)timeDeltaFromNow:(NSDate *)aDate;
+ (NSDate *)dateFromJSON:(NSString *)aDate;
+ (NSDictionary *)getGPSDictionaryForLocation:(CLLocation *)location;
+ (NSString *)dateToString:(NSDate*)aDate;
+ (NSString *)stringFromNotify:(NSDictionary *)notify;
+ (CGSize)newSizeOfPicture:(Picture *)picture withWidth:(CGFloat)width;
+ (Picture *)picFromPicID:(long)picID of:(NSArray *)feeds;
+ (Feed *)feedFromPicID:(long)picID of:(NSArray *)feeds;
+ (void)toggleLike:(UIButton*)sender ofPicture:(Picture*)pic;

@end
