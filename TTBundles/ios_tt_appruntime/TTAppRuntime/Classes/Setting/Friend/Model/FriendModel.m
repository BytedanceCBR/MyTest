//
//  FriendModel.m
//  Article
//
//  Created by Dianwei on 12-11-2.
//
//

#import "FriendModel.h"
#import <TTAccountBusiness.h>
#import "SSABPerson.h"
#import "ArticleAddressManager.h"
#import "TTBlockManager.h"

@implementation FriendModel
@synthesize userID, name, gender, screenName, avatarURLString, platform, followingTime, authorBadgeList;
@synthesize followerCount, followingCount, userDescription, isFollowed, isFollowing, lastUpdate, userAuthInfo;

+ (FriendModel *)accountUser
{
    FriendModel *ret = [[FriendModel alloc] init];
    ret.userID = [TTAccountManager userID];
    ret.gender = [[TTAccountManager currentUser].gender stringValue];
    ret.screenName = [TTAccountManager userName];
    ret.userDescription = [TTAccountManager currentUser].userDescription;
    ret.avatarURLString = [TTAccountManager avatarURLString];
    ret.avatarLargeURLString = [TTAccountManager currentUser].avatarLargeURL;
    return ret;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithDictionary:(NSDictionary*)data
{
    self = [super init];
    if(self)
    {
        if([data objectForKey:@"user_id"])
        {
            self.userID = [NSString stringWithFormat:@"%lld", [[data objectForKey:@"user_id"] longLongValue]];
        }
        else
        {
            self.userID = [NSString stringWithFormat:@"%@", [data objectForKey:@"uid"]];
        }
        if ([data.allKeys containsObject:@"verfied_agency"]) self.name = [data objectForKey:@"verfied_agency"];
        if ([data.allKeys containsObject:@"verfied_content"]) self.name = [data objectForKey:@"verfied_content"];
        if ([data.allKeys containsObject:@"name"]) self.name = [data objectForKey:@"name"];
        if ([data.allKeys containsObject:@"gender"]) self.gender = [data objectForKey:@"gender"];
        if ([data.allKeys containsObject:@"screen_name"]) self.screenName = [data objectForKey:@"screen_name"];
        if ([data.allKeys containsObject:@"avatar_url"]) self.avatarURLString = [data objectForKey:@"avatar_url"];
        if ([data.allKeys containsObject:@"avatar_large_url"]) self.avatarLargeURLString = [data objectForKey:@"avatar_large_url"];

        if ([data.allKeys containsObject:@"platform"]) self.platform = [data objectForKey:@"platform"];
        
        if ([data.allKeys containsObject:@"type"]) {
            int type = [[data objectForKey:@"type"] intValue];
            if (1 == type) {
                self.hasSNS = @YES;
            }
            else {
                self.hasSNS = @NO;
            }
        }
        else {
            self.hasSNS = @YES;
        }
        
        if ([data.allKeys containsObject:@"description"]) self.userDescription = [data objectForKey:@"description"];
        if ([data.allKeys containsObject:@"followings_count"]) self.followingCount = [data objectForKey:@"followings_count"];
        if ([data.allKeys containsObject:@"followers_count"]) self.followerCount = [data objectForKey:@"followers_count"];
        if ([data.allKeys containsObject:@"is_following"]) self.isFollowing = [data objectForKey:@"is_following"];
        if ([data.allKeys containsObject:@"is_followed"]) self.isFollowed = [data objectForKey:@"is_followed"];
        if ([data.allKeys containsObject:@"last_update"]) self.lastUpdate = [data objectForKey:@"last_update"];
        if ([data.allKeys containsObject:@"pgc_like_count"]) {
            self.pgcLikeCount = [ data objectForKey:@"pgc_like_count"];
        }
        if ([data.allKeys containsObject:@"reason"]) {
            self.reason = [data objectForKey:@"reason"];
        }
        
        if([data objectForKey:@"verified_agency"]) self.verifySource = data[@"verified_agency"];
        if([data objectForKey:@"verified_content"]) self.verifyDesc = data[@"verified_content"];
        if([data objectForKey:@"mobile_hash"]) self.mobileHash = data[@"mobile_hash"];
        if([data objectForKey:@"recommend_reason"]) self.recommendReason = data[@"recommend_reason"];
        
        if ([data objectForKey:@"author_badge"]) {
            self.authorBadgeList = data[@"author_badge"];
        }
        
        [self updatePlatformScreenNameWithDictionary:data];
        
        self.isTipNew = [[data objectForKey:@"is_new"] boolValue];
        self.userAuthInfo = [data tt_stringValueForKey:@"user_auth_info"];
        
        self.hasInvited = @NO;
        
        if ([data.allKeys containsObject:@"is_blocking"]) self.isBlocking = [data objectForKey:@"is_blocking"];
        if ([data.allKeys containsObject:@"is_blocked"]) self.isBlocked = [data objectForKey:@"is_blocked"];
        
        if ([data.allKeys containsObject:@"entity_like_count"]) self.entityLikeCount = [data objectForKey:@"entity_like_count"];
        if ([data.allKeys containsObject:@"show_spring_festival_icon"]) self.showSpringFestivalIcon = [[data objectForKey:@"show_spring_festival_icon"] boolValue];
        if ([data.allKeys containsObject:@"spring_festival_scheme"]) self.springFestivalScheme = [data objectForKey:@"spring_festival_scheme"];
        
        if ([data objectForKey:@"new_source"]) {
            self.newSource = [data tt_integerValueForKey:@"new_source"];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockUnblockUserNotificationHandler:) name:kHasBlockedUnblockedUserNotification object:nil];
    }
    
    return self;
}


static NSDictionary *s_abDictionary;
+ (NSDictionary*)addressbookDictionary
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_abDictionary = [[ArticleAddressManager sharedManager] addressBookPersons];
    });
    
    return s_abDictionary;
}

- (void)updatePlatformScreenNameWithDictionary:(NSDictionary*)data
{
    if ([[data objectForKey:@"platform"] isEqual:@"mobile"])
    {
        NSString *mobileHash = [data objectForKey:@"mobile_hash"];
        if(!isEmptyString(mobileHash))
        {
            mobileHash = [mobileHash lowercaseString];
            SSABPerson * person = [[FriendModel addressbookDictionary] valueForKey:mobileHash];
            self.platformScreenName = [person personName];
        }
    }
    
    if(isEmptyString(_platformScreenName))
    {
        self.platformScreenName = [data objectForKey:@"platform_screen_name"];
    }
}


- (void)updateWithDictionary:(NSDictionary*)data
{
    if ([data.allKeys containsObject:@"verfied_agency"]) self.name = [data objectForKey:@"verfied_agency"];
    if ([data.allKeys containsObject:@"verfied_content"]) self.name = [data objectForKey:@"verfied_content"];
    if ([data.allKeys containsObject:@"name"]) self.name = [data objectForKey:@"name"];
    if ([data.allKeys containsObject:@"gender"]) self.name = [data objectForKey:@"gender"];
    if ([data.allKeys containsObject:@"screen_name"]) self.screenName = [data objectForKey:@"screen_name"];
    if ([data.allKeys containsObject:@"avatar_url"]) self.avatarURLString = [data objectForKey:@"avatar_url"];
    if ([data.allKeys containsObject:@"avatar_large_url"]) self.avatarLargeURLString = [data objectForKey:@"avatar_large_url"];
    if ([data.allKeys containsObject:@"platform"]) self.platform = [data objectForKey:@"platform"];
    
    if ([data.allKeys containsObject:@"description"]) self.userDescription = [data objectForKey:@"description"];
    if ([data.allKeys containsObject:@"followings_count"]) self.followingCount = [data objectForKey:@"followings_count"];
    if ([data.allKeys containsObject:@"followers_count"]) self.followerCount = [data objectForKey:@"followers_count"];
    if ([data.allKeys containsObject:@"is_following"]) self.isFollowing = [data objectForKey:@"is_following"];
    if ([data.allKeys containsObject:@"is_followed"]) self.isFollowed = [data objectForKey:@"is_followed"];
    if ([data.allKeys containsObject:@"last_update"]) self.lastUpdate = [data objectForKey:@"last_update"];
    if ([data.allKeys containsObject:@"reason"]) {
        self.reason = [data objectForKey:@"reason"];
    }
    if ([data.allKeys containsObject:@"pgc_like_count"]) {
        self.pgcLikeCount = [data objectForKey:@"pgc_like_count"];
    }
    if ([data.allKeys containsObject:@"is_new"]) {
        self.isTipNew = [[data objectForKey:@"is_new"] boolValue];
    }
    if ([data objectForKey:@"user_auth_info"]) {
        self.userAuthInfo = [data tt_stringValueForKey:@"user_auth_info"];
    }
    
    if([data objectForKey:@"verified_agency"]) self.verifySource = data[@"verified_agency"];
    if([data objectForKey:@"verified_content"]) self.verifyDesc = data[@"verified_content"];
    if([data objectForKey:@"mobile_hash"]) self.mobileHash = data[@"mobile_hash"];
    [self updatePlatformScreenNameWithDictionary:data];
    if([data objectForKey:@"recommend_reason"]) self.recommendReason = data[@"recommend_reason"];
    
    if ([data.allKeys containsObject:@"is_blocking"]) self.isBlocking = [data objectForKey:@"is_blocking"];
    if ([data.allKeys containsObject:@"is_blocked"]) self.isBlocked = [data objectForKey:@"is_blocked"];
    
    if ([data.allKeys containsObject:@"entity_like_count"]) self.entityLikeCount = [data objectForKey:@"entity_like_count"];
    
    if ([data.allKeys containsObject:@"show_spring_festival_icon"]) self.showSpringFestivalIcon = [[data objectForKey:@"show_spring_festival_icon"] boolValue];
    if ([data.allKeys containsObject:@"spring_festival_scheme"]) self.springFestivalScheme = [data objectForKey:@"spring_festival_scheme"];
    if ([data objectForKey:@"author_badge"]) {
        self.authorBadgeList = data[@"author_badge"];
    }
    if ([data objectForKey:@"new_source"]) {
        self.newSource = [data tt_integerValueForKey:@"new_source"];
    }
}

- (NSMutableDictionary *)dictionaryInfo
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:self.userID forKey:@"user_id"];
    [dict setValue:self.name forKey:@"name"];
    [dict setValue:self.gender forKey:@"gender"];
    [dict setValue:self.screenName forKey:@"screen_name"];
    [dict setValue:self.verfiedAgency forKey:@"verfied_agency"];
    [dict setValue:self.verfiedContent forKey:@"verfied_content"];
    [dict setValue:self.avatarURLString forKey:@"avatar_url"];
    [dict setValue:self.avatarLargeURLString forKey:@"avatar_large_url"];
    [dict setValue:self.platform forKey:@"platform"];
    [dict setValue:self.userDescription forKey:@"description"];
    [dict setValue:self.followingCount forKey:@"followings_count"];
    [dict setValue:self.followerCount forKey:@"followers_count"];
    [dict setValue:self.followingTime forKey:@"following_time"];
    [dict setValue:self.isFollowing forKey:@"is_following"];
    [dict setValue:self.isFollowed forKey:@"is_followed"];
    [dict setValue:self.hasSNS forKey:@"has_sns"];
    [dict setValue:self.lastUpdate forKey:@"last_update"];
    [dict setValue:self.reason forKey:@"reason"];
    [dict setValue:self.pgcLikeCount forKey:@"pgc_like_count"];
    [dict setValue:self.userAuthInfo forKey:@"user_auth_info"];
    [dict setValue:@(self.isTipNew) forKey:@"is_new"];
    [dict setValue:self.verifySource forKey:@"verified_agency"];
    [dict setValue:self.verifyDesc forKey:@"verified_content"];
    [dict setValue:self.platformScreenName forKey:@"platform_screen_name"];
    [dict setValue:self.mobileHash forKey:@"mobile_hash"];
    [dict setValue:self.recommendReason forKey:@"recommend_reason"];
    
    [dict setValue:self.isBlocking forKey:@"is_blocking"];
    [dict setValue:self.isBlocked forKey:@"is_blocked"];
    
    [dict setValue:self.entityLikeCount forKey:@"entity_like_count"];
    
    [dict setValue:@(self.showSpringFestivalIcon) forKey:@"show_spring_festival_icon"];
    [dict setValue:self.springFestivalScheme forKey:@"spring_festival_scheme"];
    [dict setValue:self.authorBadgeList forKey:@"author_badge"];
    [dict setValue:@(self.newSource) forKey:@"new_source"];

    return dict;
}

- (void)postFriendModelChangedNotification
{
    NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:10];
    [userInfo setValue:self.userID forKey:kFriendModelUserIDKey];
    [userInfo setValue:self.isFollowing forKey:kFriendModelISFollowingKey];
    [userInfo setValue:self.isFollowed forKey:kFriendModelISFollowedKey];
    [userInfo setValue:self.isBlocking forKey:kFriendModelISBlockingKey];

    [[NSNotificationCenter defaultCenter] postNotificationName:KFriendModelChangedNotification object:nil userInfo:userInfo];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"userID:%@, name:%@, screenName:%@, avatar:%@, badgeList:%@, platform:%@", userID, name, screenName, avatarURLString, authorBadgeList, platform];
}

- (void)blockUnblockUserNotificationHandler:(NSNotification *)notification
{
    NSDictionary * userInfo = [notification userInfo];
    NSString * notificationUserID = [userInfo valueForKey:kBlockedUnblockedUserIDKey];
    if ([self.userID isEqualToString:notificationUserID]) {
        self.isBlocking = [userInfo valueForKey:kIsBlockingKey];
    }
}

@end
