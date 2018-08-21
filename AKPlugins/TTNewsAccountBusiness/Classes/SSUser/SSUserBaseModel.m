//
//  SSUserModel.m
//  Article
//
//  Created by Dianwei on 14-5-21.
//
//

#import "SSUserBaseModel.h"
#import <NSDictionary+TTAdditions.h>
#import "TTAccountManager.h"



@interface SSUserBaseModel()

@end

@implementation SSUserBaseModel

- (void)dealloc
{
    self.connects = nil;
    self.authorBadgeList = nil;
    self.name = nil;
    self.media_id = nil;
    self.avatarURLString = nil;
    self.avatarLargeURLString = nil;
    self.userDescription = nil;
    self.userDecoration = nil;
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
    }
    @catch (NSException *exception) {
        NSLog(@"==SSUserBaseModel dealloc removeObserver exception ==!!== ");
        
    }
    @finally {
        
    }
}

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    
    if ([object isKindOfClass:[SSUserBaseModel class]]) {
        return ([self hash] == [object hash]);
    }
    
    return NO;
}

- (NSUInteger)hash
{
    return [self.ID hash];
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        if ([dict objectForKey:@"user_id"]) {
            self.ID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"user_id"]];
        } else if ([dict objectForKey:@"id"]) {
            self.ID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
        }
        
        if ([dict valueForKey:@"user_auth_info"]) {
            self.userAuthInfo = [dict tt_stringValueForKey:@"user_auth_info"];
        }
        
        if ([dict objectForKey:@"screen_name"]) {
            self.screen_name = [dict objectForKey:@"screen_name"];
        }
        
        if ([dict objectForKey:@"name"]) {
            self.name = [dict objectForKey:@"name"];
        }
        
        if (isEmptyString(self.name)) {
            self.name = self.screen_name;
        }
        
        if ([dict objectForKey:@"gender"]) {
            self.gender = [dict objectForKey:@"gender"];
        }
        
        if ([dict objectForKey:@"area"]) {
            self.area = [dict stringValueForKey:@"area" defaultValue:nil];
        }
        
        if ([dict objectForKey:@"birthday"]) {
            self.birthday = [dict stringValueForKey:@"birthday" defaultValue:nil];
        }
        
        self.avatarURLString = [dict tt_stringValueForKey:@"avatar_url"];
        self.avatarLargeURLString = [dict tt_stringValueForKey:@"avatar_large_url"];
        self.bgImageURLString = [dict tt_stringValueForKey:@"bg_img_url"];
        
        self.userDescription = [dict tt_stringValueForKey:@"description"];
        self.userDecoration = [dict tt_stringValueForKey:@"user_decoration"];
        self.shareURL = [dict tt_stringValueForKey:@"share_url"];
        
        if ([dict objectForKey:@"connects"]) {
            NSArray *connectsData = [dict objectForKey:@"connects"];
            
            NSMutableArray *connects = [NSMutableArray arrayWithCapacity:connectsData.count];
            for (NSDictionary *dict in connectsData) {
                TTThirdPartyAccountInfoBase *accountInfo = [AccountInfoFactory accountInfoWithDictionary:dict];
                if (accountInfo) {
                    [connects addObject:accountInfo];
                }
            }
            
            self.connects = connects;
        }
        
        if ([dict objectForKey:@"author_badge"]) {
            self.authorBadgeList = [dict arrayValueForKey:@"author_badge" defaultValue:nil];
        }
        
        NSString *mediaID = [dict objectForKey:@"media_id"];
        if ([mediaID isKindOfClass:[NSString class]]) {
            self.media_id = mediaID;
        } else if ([mediaID isKindOfClass:[NSNumber class]]) {
            self.media_id = [NSString stringWithFormat:@"%@", mediaID];
        }
        //        self.followingCount = [dict tt_longlongValueForKey:@"followings_count"];
        //        self.followerCount  = [dict tt_longlongValueForKey:@"followers_count"];
        //        self.visitorCount   = [dict tt_longlongValueForKey:@"visit_count_recent"];
        //        self.momnetCount = [dict tt_longlongValueForKey:@"dongtai_count"];
        
        if ([dict objectForKey:@"is_blocked"]) {
            self.isBlocked = [[dict objectForKey:@"is_blocked"] boolValue];
        }
        
        if ([dict objectForKey:@"is_blocking"]) {
            self.isBlocking = [[dict objectForKey:@"is_blocking"] boolValue];
        }
        
        if ([dict objectForKey:@"verified_reason"]) {
            self.verifiedReason = [dict tt_stringValueForKey:@"verified_reason"];
        } else if ([dict objectForKey:@"verified_content"]) {
            self.verifiedReason = [dict tt_stringValueForKey:@"verified_content"]; //兼容处理..有些接口是verified_content
        }
        self.isFollowing = [[dict objectForKey:@"is_following"] boolValue];
        self.isFollowed = [[dict objectForKey:@"is_followed"] boolValue];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockUnblockUserNotificationHandler:) name:@"kHasBlockedUnblockedUserNotification" object:nil];
    }
    
    return self;
}

- (void)updateWithDictionary:(NSDictionary*)dict
{
    if ([dict objectForKey:@"screen_name"]) {
        self.screen_name = [dict stringValueForKey:@"screen_name"
                                      defaultValue:nil];
    }
    
    if ([dict objectForKey:@"name"]) {
        self.name = [dict stringValueForKey:@"name"
                               defaultValue:nil];
    }
    
    if ([dict objectForKey:@"avatar_url"]) {
        self.avatarURLString = [dict stringValueForKey:@"avatar_url"
                                          defaultValue:nil];
    }
    
    if ([dict objectForKey:@"avatar_large_url"]) {
        self.avatarLargeURLString = [dict stringValueForKey:@"avatar_large_url"
                                               defaultValue:nil];
    }
    
    if ([dict objectForKey:@"bg_img_url"]) {
        self.bgImageURLString = [dict stringValueForKey:@"bg_img_url"
                                           defaultValue:nil];
    }
    
    if ([dict objectForKey:@"description"]) {
        self.userDescription = [dict stringValueForKey:@"description"
                                          defaultValue:nil];
    }
    
    if ([dict objectForKey:@"user_decoration"]) {
        self.userDecoration = [dict stringValueForKey:@"user_decoration"
                                          defaultValue:nil];
    }
    
    if ([dict objectForKey:@"share_url"]) {
        self.shareURL = [dict tt_stringValueForKey:@"share_url"];
    }
    
    if ([dict objectForKey:@"gender"]) {
        self.gender = [dict stringValueForKey:@"gender"
                                 defaultValue:nil];
    }
    
    if ([dict objectForKey:@"area"]) {
        self.area = [dict stringValueForKey:@"area" defaultValue:nil];
    }
    
    if ([dict objectForKey:@"birthday"]) {
        self.birthday = [dict stringValueForKey:@"birthday" defaultValue:nil];
    }
    
    if ([dict objectForKey:@"author_badge"]) {
        self.authorBadgeList = [dict arrayValueForKey:@"author_badge"
                                         defaultValue:nil];
    }
    
    NSString *mediaID = [dict objectForKey:@"media_id"];
    if ([mediaID isKindOfClass:[NSString class]]) {
        self.media_id = mediaID;
    } else if ([mediaID isKindOfClass:[NSNumber class]]) {
        self.media_id = [NSString stringWithFormat:@"%@", mediaID];
    }
    
    self.followingCount = [dict tt_longlongValueForKey:@"followings_count"];
    self.followerCount  = [dict tt_longlongValueForKey:@"followers_count"];
    self.visitorCount   = [dict tt_longlongValueForKey:@"visit_count_recent"];
    self.momnetCount    = [dict tt_longlongValueForKey:@"dongtai_count"];
}

- (NSDictionary *)toDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.ID forKey:@"user_id"];
    [dict setValue:self.userAuthInfo forKey:@"user_auth_info"];
    [dict setValue:self.name forKey:@"name"];
    [dict setValue:self.screen_name forKey:@"screen_name"];
    [dict setValue:self.avatarURLString forKey:@"avatar_url"];
    [dict setValue:self.avatarLargeURLString forKey:@"avatar_large_url"];
    [dict setValue:self.bgImageURLString forKey:@"bg_img_url"];
    [dict setValue:self.userDescription forKey:@"description"];
    [dict setValue:self.userDecoration forKey:@"user_decoration"];
    [dict setValue:@(self.isBlocked) forKey:@"is_blocked"];
    [dict setValue:@(self.isBlocking) forKey:@"is_blocking"];
    [dict setValue:self.verifiedReason forKey:@"verified_reason"];
    return [dict copy];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.userAuthInfo = [aDecoder decodeObjectForKey:@"user_auth_info"];
        self.ID = [aDecoder decodeObjectForKey:@"id"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.screen_name = [aDecoder decodeObjectForKey:@"screen_name"];
        self.avatarURLString = [aDecoder decodeObjectForKey:@"avatar_url_string"];
        self.avatarLargeURLString = [aDecoder decodeObjectForKey:@"avatar_large_url_string"];
        self.bgImageURLString = [aDecoder decodeObjectForKey:@"bg_image_url_string"];
        self.userDescription = [aDecoder decodeObjectForKey:@"user_description"];
        self.userDecoration = [aDecoder decodeObjectForKey:@"user_decoration"];
        self.gender = [aDecoder decodeObjectForKey:@"gender"];
        self.area = [aDecoder decodeObjectForKey:@"area"];
        self.birthday = [aDecoder decodeObjectForKey:@"birthday"];
        
        self.isBlocked = [[aDecoder decodeObjectForKey:@"is_blocked"] boolValue];
        self.isBlocking = [[aDecoder decodeObjectForKey:@"is_blocking"] boolValue];
        self.isFollowed = [[aDecoder decodeObjectForKey:@"is_followed"] boolValue];
        self.isFollowing = [[aDecoder decodeObjectForKey:@"is_following"] boolValue];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockUnblockUserNotificationHandler:) name:@"kHasBlockedUnblockedUserNotification" object:nil];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userAuthInfo forKey:@"user_auth_info"];
    [aCoder encodeObject:self.ID forKey:@"id"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_screen_name forKey:@"screen_name"];
    [aCoder encodeObject:_avatarURLString forKey:@"avatar_url_string"];
    [aCoder encodeObject:_avatarLargeURLString forKey:@"avatar_large_url_string"];
    [aCoder encodeObject:_bgImageURLString forKey:@"bg_image_url_string"];
    [aCoder encodeObject:_userDescription forKey:@"user_description"];
    [aCoder encodeObject:_gender forKey:@"gender"];
    [aCoder encodeObject:_area forKey:@"area"];
    [aCoder encodeObject:_birthday forKey:@"birthday"];
    
    [aCoder encodeObject:@(_isBlocked) forKey:@"is_blocked"];
    [aCoder encodeObject:@(_isBlocking) forKey:@"is_blocking"];
    [aCoder encodeObject:@(_isFollowed) forKey:@"is_followed"];
    [aCoder encodeObject:@(_isFollowing) forKey:@"is_following"];
}

- (void)blockUnblockUserNotificationHandler:(NSNotification *)notification
{
    NSDictionary * userInfo = [notification userInfo];
    NSString * userID = [userInfo valueForKey:@"kBlockedUnblockedUserIDKey"];
    if ([self.ID isEqualToString:userID]) {
        self.isBlocking = [[userInfo valueForKey:@"kIsBlockingKey"] boolValue];
    }
}

- (TTAccountUserType)userType
{
    TTAccountUserType curUserType = TTAccountUserTypeVisitor;
    if (!isEmptyString(self.media_id) &&
        ![self.media_id isEqualToString:@"0"]) {
        curUserType = TTAccountUserTypePGC;
    } else if ([self isVerifiedUser]) {
        curUserType = TTAccountUserTypeUGC;
    }
    return curUserType;
}

- (BOOL)isToutiaohaoUser
{
    return ([self userType] == TTAccountUserTypePGC);
}

- (BOOL)isVerifiedUser
{
    return [TTAccountManager isVerifiedOfUserVerifyInfo:self.userAuthInfo];
}

@end
