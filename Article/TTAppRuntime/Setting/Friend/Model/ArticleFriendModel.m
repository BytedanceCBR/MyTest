//
//  ArticleFriendModel.m
//  Article
//
//  Created by Dianwei on 14-7-20.
//
//

#import "ArticleFriendModel.h"
#import "PGCAccount.h"
#import <TTAccountBusiness.h>
#import <objc/runtime.h>


@interface NSString (TrimmingWhitespaceAndNewline)
@end
@implementation NSString (TrimmingWhitespaceAndNewline)
- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
@end

@implementation ArticleFriendModel
- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super initWithDictionary:dict];
    if(self)
    {
        if([dict objectForKey:@"media"])
        {
            self.pgcAccount = [[PGCAccount alloc] initWithDictionary:[dict objectForKey:@"media"]];
        }
        
        self.suggestType = [[dict objectForKey:@"type"] intValue];
        
        self.reasonType = [[dict objectForKey:@"reason_type"] intValue];
        
        self.platformString = [dict objectForKey:@"platform"];
        
        self.mobileHash = [dict objectForKey:@"mobile_hash"];
        
        self.platformScreenName = [dict objectForKey:@"platform_screen_name"];
        
        self.recommendReason = [dict objectForKey:@"recommend_reason"];
        
        self.newSource = [dict tt_integerValueForKey:@"new_source"];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.pgcAccount = [aDecoder decodeObjectForKey:@"pgcAccount"];
        self.suggestType = [[aDecoder decodeObjectForKey:@"type"] intValue];
        self.reasonType = [[aDecoder decodeObjectForKey:@"reason_type"] intValue];
        self.platformString = [aDecoder decodeObjectForKey:@"platform"];
        self.mobileHash = [aDecoder decodeObjectForKey:@"mobile_hash"];
        self.platformScreenName = [aDecoder decodeObjectForKey:@"platform_screen_name"];
        self.recommendReason = [aDecoder decodeObjectForKey:@"recommend_reason"];
        self.newSource = [[aDecoder decodeObjectForKey:@"new_source"] integerValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_pgcAccount forKey:@"pgcAccount"];
    [aCoder encodeObject:@(_suggestType) forKey:@"type"];
    [aCoder encodeObject:@(_reasonType) forKey:@"reason_type"];
    [aCoder encodeObject:_platformString forKey:@"platform"];
    [aCoder encodeObject:_mobileHash forKey:@"mobile_hash"];
    [aCoder encodeObject:_platformScreenName forKey:@"platform_screen_name"];
    [aCoder encodeObject:_recommendReason forKey:@"recommend_reason"];
    [aCoder encodeObject:@(_newSource) forKey:@"new_source"];
}

- (BOOL)isAccountUser
{
    return [self.ID isEqualToString:[TTAccountManager userID]] || [self.ID isEqualToString:@"0"];
}

- (ArticleFriend*)articleFriend
{
    
    ArticleFriend *friend = [[ArticleFriend alloc] init];
    friend.verfiedAgency = self.verifiedAgency;
    friend.verfiedContent = self.verifiedContent;
    friend.userID = self.ID;
    friend.userDescription = self.userDescription;
    friend.name = self.name;
    friend.gender = self.gender;
    friend.screenName = self.platformScreenName;
    friend.avatarURLString = self.avatarURLString;
    friend.platform = self.platformString;
    friend.followerCount = @(self.followerCount);
    friend.followingCount = @(self.followingCount);
    friend.isFollowed = @(self.isFollowed);
    friend.isFollowing = @(self.isFollowing);
    friend.userAuthInfo = self.userAuthInfo;
    friend.pgcLikeCount = @(self.pgcLikeCount);
    friend.isTipNew = self.isNew;
    friend.reason = self.recommendReason;
    friend.verifySource = self.verifiedAgency;
    friend.verifyDesc = self.verifiedContent;
    friend.isBlocking = @(self.isBlocking);
    friend.isBlocked = @(self.isBlocked);
    friend.newSource = self.newSource;
    friend.newReason = self.newReason;
    return friend;
}

- (NSDictionary *)parseToDictionary
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:20];
    
    [dict setValue:self.userAuthInfo forKey:@"user_auth_info"];
    [dict setValue:self.ID forKey:@"id"];
    [dict setValue:self.name forKey:@"name"];
    [dict setValue:self.avatarURLString forKey:@"avatar_url_string"];
    [dict setValue:self.userDescription forKey:@"user_description"];
    [dict setValue:self.gender forKey:@"gender"];
    
    [dict setValue:@(self.isBlocked) forKey:@"is_blocked"];
    [dict setValue:@(self.isBlocking) forKey:@"is_blocking"];
    
    [dict setValue:@(self.isFollowed) forKey:@"is_followed"];
    [dict setValue:@(self.isFollowing) forKey:@"is_following"];
    [dict setValue:@(self.isNew) forKey:@"is_newer"];
    [dict setValue:self.displayInfo forKey:@"display_info"];
    [dict setValue:self.verifiedAgency forKey:@"verified_agency"];
    [dict setValue:self.verifiedContent forKey:@"verified_content"];
    
    [dict setValue:_pgcAccount forKey:@"pgcAccount"];
    [dict setValue:@(_suggestType) forKey:@"type"];
    [dict setValue:@(_reasonType) forKey:@"reason_type"];
    [dict setValue:_platformString forKey:@"platform"];
    [dict setValue:_mobileHash forKey:@"mobile_hash"];
    [dict setValue:_platformScreenName forKey:@"platform_screen_name"];
    [dict setValue:_recommendReason forKey:@"recommend_reason"];
    [dict setValue:@(self.newSource) forKey:@"new_source"];
    
    return dict;
}

- (SSUserModel *)userModel
{
    SSUserModel * user = [[SSUserModel alloc] initWithDictionary:[self parseToDictionary]];
    user.isFriend = self.isFollowing;
    
    return user;
}

- (NSString *)titleString {
    return !isEmptyString([self.name trim]) ? [self.name trim] : [self.screen_name trim];
}

- (NSString *)subtitle1String {
    NSString *text = !isEmptyString([self.platformScreenName trim]) ? self.platformScreenName : self.recommendReason;
    return [text trim];
}

- (NSString *)subtitle2String {
    NSString *text = !isEmptyString([self.verifiedContent trim]) ? self.verifiedContent : self.userDescription;
    if (isEmptyString([text trim])) text = @"这个人很懒，什么也没留下";
    return [text trim];
}
@end
