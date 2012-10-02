#import "LuxeysUser.h"

@implementation LuxeysUser

@synthesize age;
@synthesize birthdate;
@synthesize birthdatePublic;
@synthesize birthyearPublic;
@synthesize countFollows;
@synthesize countFriends;
@synthesize countPictures;
@synthesize currentResidence;
@synthesize currentResidencePublic;
@synthesize gender;
@synthesize genderPublic;
@synthesize hobby;
@synthesize hometown;
@synthesize hometownPublic;
@synthesize luxeysUserId;
@synthesize introduction;
@synthesize isUnregister;
@synthesize name;
@synthesize occupation;
@synthesize pictureStatus;
@synthesize profilePicture;
@synthesize voteCount;

+ (LuxeysUser *)instanceFromDictionary:(NSDictionary *)aDictionary {

    LuxeysUser *instance = [[LuxeysUser alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;

}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary {

    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self setValuesForKeysWithDictionary:aDictionary];

}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

    if ([key isEqualToString:@"birthdate_public"]) {
        [self setValue:value forKey:@"birthdatePublic"];
    } else if ([key isEqualToString:@"birthyear_public"]) {
        [self setValue:value forKey:@"birthyearPublic"];
    } else if ([key isEqualToString:@"count_follows"]) {
        [self setValue:value forKey:@"countFollows"];
    } else if ([key isEqualToString:@"count_friends"]) {
        [self setValue:value forKey:@"countFriends"];
    } else if ([key isEqualToString:@"count_pictures"]) {
        [self setValue:value forKey:@"countPictures"];
    } else if ([key isEqualToString:@"current_residence"]) {
        [self setValue:value forKey:@"currentResidence"];
    } else if ([key isEqualToString:@"current_residence_public"]) {
        [self setValue:value forKey:@"currentResidencePublic"];
    } else if ([key isEqualToString:@"gender_public"]) {
        [self setValue:value forKey:@"genderPublic"];
    } else if ([key isEqualToString:@"hometown_public"]) {
        [self setValue:value forKey:@"hometownPublic"];
    } else if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"luxeysUserId"];
    } else if ([key isEqualToString:@"is_unregister"]) {
        [self setValue:value forKey:@"isUnregister"];
    } else if ([key isEqualToString:@"picture_status"]) {
        [self setValue:value forKey:@"pictureStatus"];
    } else if ([key isEqualToString:@"profile_picture"]) {
        [self setValue:value forKey:@"profilePicture"];
    } else if ([key isEqualToString:@"vote_count"]) {
        [self setValue:value forKey:@"voteCount"];
    } else {
        [super setValue:value forUndefinedKey:key];
    }

}



@end
