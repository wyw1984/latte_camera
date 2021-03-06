#import "User.h"
#import "LXAppDelegate.h"

@implementation User

@synthesize age;
@synthesize birthdate;
@synthesize birthdatePublic;
@synthesize birthyearPublic;
@synthesize bloodType;
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
@synthesize userId;
@synthesize introduction;
@synthesize isUnregister;
@synthesize name;
@synthesize occupation;
@synthesize pictureStatus;
@synthesize profilePicture;
@synthesize voteCount;

@synthesize isFollowing;
@synthesize isFriend;

@synthesize notifyAccepts;
@synthesize mailAccepts;

+ (User *)instanceFromDictionary:(NSDictionary *)aDictionary {

    User *instance = [[User alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;

}

+ (NSMutableArray *)mutableArrayFromDictionary:(NSDictionary *)aDictionary withKey:(NSString *)aKey {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (NSDictionary *user in [aDictionary objectForKey:aKey])
        [ret addObject:[User instanceFromDictionary:user]];
    return ret;
}


- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary {

    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self setValuesForKeysWithDictionary:aDictionary];

}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"mail_accepts"]) {
        mailAccepts = [[UserMailAccept alloc] init];
        [mailAccepts setValuesForKeysWithDictionary:value];
    } else if ([key isEqualToString:@"app_notify_accepts"]) {
        notifyAccepts = [[UserPushAccept alloc] init];
        [notifyAccepts setValuesForKeysWithDictionary:value];
    }
    else {
        [super setValue:value forKey:key];
    }

}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

    if ([key isEqualToString:@"birthdate_public"]) {
        [self setValue:value forKey:@"birthdatePublic"];
    } else if ([key isEqualToString:@"birthyear_public"]) {
        [self setValue:value forKey:@"birthyearPublic"];
    } else if ([key isEqualToString:@"bloodtype"]) {
        [self setValue:value forKey:@"bloodType"];
    } else if ([key isEqualToString:@"bloodtype_public"]) {
        [self setValue:value forKey:@"_bloodTypePublic"];
    } else if ([key isEqualToString:@"count_follows"]) {
        [self setValue:value forKey:@"countFollows"];
    } else if ([key isEqualToString:@"count_followers"]) {
        [self setValue:value forKey:@"_countFollowers"];
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
        [self setValue:value forKey:@"userId"];
    } else if ([key isEqualToString:@"is_unregister"]) {
        [self setValue:value forKey:@"isUnregister"];
    } else if ([key isEqualToString:@"picture_status"]) {
        [self setValue:value forKey:@"pictureStatus"];
    } else if ([key isEqualToString:@"profile_picture"]) {
        [self setValue:value forKey:@"profilePicture"];
    } else if ([key isEqualToString:@"profile_picture_hi"]) {
        [self setValue:value forKey:@"_profilePictureHi"];
    } else if ([key isEqualToString:@"vote_count"]) {
        [self setValue:value forKey:@"voteCount"];
    } else if ([key isEqualToString:@"page_views"]) {
        [self setValue:value forKey:@"_pageViews"];
    } else if ([key isEqualToString:@"is_following"]) {
        [self setValue:value forKey:@"isFollowing"];
    } else if ([key isEqualToString:@"is_friend"]) {
        [self setValue:value forKey:@"isFriend"];
    } else if ([key isEqualToString:@"stealth_mode"]) {
        [self setValue:value forKey:@"_stealthMode"];
    } else if ([key isEqualToString:@"default_show_gps"]) {
        [self setValue:value forKey:@"_defaultShowGPS"];
    } else if ([key isEqualToString:@"default_show_exif"]) {
        [self setValue:value forKey:@"_defaultShowEXIF"];
    } else if ([key isEqualToString:@"default_show_taken_at"]) {
        [self setValue:value forKey:@"_defaultShowTakenAt"];
    } else if ([key isEqualToString:@"default_show_large"]) {
        [self setValue:value forKey:@"_defaultShowLarge"];
    } else if ([key isEqualToString:@"nationality"]) {
        [self setValue:value forKey:@"_nationality"];
    } else if ([key isEqualToString:@"country"]) {
        [self setValue:value forKey:@"_country"];
    } else if ([key isEqualToString:@"nationality_public"]) {
        [self setValue:value forKey:@"_nationalityPublic"];
    } else if ([key isEqualToString:@"picture_auto_facebook_upload"]) {
        [self setValue:value forKey:@"_pictureAutoFacebookUpload"];
    } else if ([key isEqualToString:@"picture_auto_tweet"]) {
        [self setValue:value forKey:@"_pictureAutoTweet"];
    } else if ([key isEqualToString:@"verified"]) {
        [self setValue:value forKey:@"_verified"];
    } else if ([key isEqualToString:@"is_locked"]) {
        [self setValue:value forKey:@"_isLocked"];
    } else if ([key isEqualToString:@"mail"]) {
        [self setValue:value forKey:@"_mail"];
    }
    
    else {
        [super setValue:value forUndefinedKey:key];
    }

}

+(void)getLastUserInformation:(void (^)(id))success
                      failure:(void (^)(NSError *))failure
{
    [[LatteAPIClient sharedClient] GET:@"user/me"
                            parameters:nil
                               success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                   if (success) {
                                       success(JSON);
                                   }
                               }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   if(failure) {
                                       failure(error);
                                   }
                               }];
}


+ (void)updatePermission:(NSNumber *)value
                     forObject:(NSString *)name
                        success:(void (^)(id))success
                        failure:(void (^)(NSError *))failure {
    NSDictionary *dict = @{name: value};
    [[LatteAPIClient sharedClient] POST:@"user/me/update"
                             parameters: dict
                                success:^(AFHTTPRequestOperation *operation, NSDictionary *JSON) {
                                    if ([[JSON objectForKey:@"status"] integerValue] == 0) {
                                        if (failure) {
                                            NSString *error_content = @"";
                                            NSDictionary *errors = [JSON objectForKey:@"errors"];
                                            for (NSString *tmp in [JSON objectForKey:@"errors"]) {
                                                error_content = [error_content stringByAppendingFormat:@"\n%@", [errors objectForKey:tmp]];
                                            }
                                            NSMutableDictionary* details = [NSMutableDictionary dictionary];
                                            [details setValue:error_content forKey:NSLocalizedDescriptionKey];
                                            // populate the error object with the details
                                            NSError *error = [NSError errorWithDomain:@"latte" code:0 userInfo:details];
                                            failure(error);
                                        }
                                    } else {
                                        if (success) {
                                            success(JSON);
                                        }
                                    }
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    if (failure) {
                                        failure(error);
                                    }
                                }];
}


@end


@implementation UserMailAccept

@synthesize comment;
@synthesize vote;

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary {
    
    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    [self setValuesForKeysWithDictionary:aDictionary];
    
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    if ([key isEqualToString:@"comment"]) {
        [self setValue:value forKey:@"comment"];
    } else if ([key isEqualToString:@"vote"]) {
        [self setValue:value forKey:@"vote"];
    } else if ([key isEqualToString:@"follow"]) {
        [self setValue:value forKey:@"_follow"];
    }
    else {
        [super setValue:value forUndefinedKey:key];
    }
}

@end

@implementation UserPushAccept

@synthesize comment;
@synthesize vote;

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary {
    
    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    [self setValuesForKeysWithDictionary:aDictionary];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    if ([key isEqualToString:@"comment"]) {
        [self setValue:value forKey:@"_comment"];
    } else if ([key isEqualToString:@"vote"]) {
        [self setValue:value forKey:@"vote"];
    } else if ([key isEqualToString:@"follow"]) {
        [self setValue:value forKey:@"_follow"];
    }
    else {
        [super setValue:value forUndefinedKey:key];
    }
}

@end