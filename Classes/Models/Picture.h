#import <Foundation/Foundation.h>
#import "ModelObject.h"
#import "User.h"
#import "LXUtils.h"

@interface Picture : ModelObject {

    BOOL canComment;
    BOOL canVote;
    BOOL canEdit;
    NSNumber *commentCount;
    NSMutableArray *comments;
    NSDate *createdAt;
    NSString *descriptionText;
    NSNumber *height;
    BOOL isVoted;
    BOOL isOwner;
    NSNumber *latitude;
    NSNumber *longitude;
    NSString *model;
    NSNumber *pageviews;
    NSDate *takenAt;
    NSNumber *pictureId;
    NSNumber *userId;
    NSString *title;
    NSString *urlLarge;
    NSString *urlMedium;
    NSString *urlSmall;
    NSString *urlSquare;
    NSNumber *voteCount;
    NSNumber *width;
    NSNumber *status;
    NSDictionary *exif;
    NSArray *tags;
}

@property (nonatomic, assign) BOOL canComment;
@property (nonatomic, assign) BOOL canVote;
@property (nonatomic, assign) BOOL canEdit;
@property (nonatomic, copy) NSNumber *commentCount;
@property (nonatomic, retain) NSMutableArray *comments;
@property (nonatomic, copy) NSDate *createdAt;
@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, copy) NSNumber *height;
@property (nonatomic, assign) BOOL isVoted;
@property (nonatomic, assign) BOOL isOwner;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSNumber *pageviews;
@property (nonatomic, copy) NSDate *takenAt;
@property (nonatomic, copy) NSNumber *pictureId;
@property (nonatomic, copy) NSNumber *userId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *urlLarge;
@property (nonatomic, copy) NSString *urlMedium;
@property (nonatomic, copy) NSString *urlSmall;
@property (nonatomic, copy) NSString *urlSquare;
@property (nonatomic, copy) NSNumber *voteCount;
@property (nonatomic, copy) NSNumber *width;
@property (nonatomic, copy) NSNumber *status;
@property (nonatomic, copy) NSDictionary *exif;
@property (nonatomic, copy) NSArray *tags;

+ (Picture *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
