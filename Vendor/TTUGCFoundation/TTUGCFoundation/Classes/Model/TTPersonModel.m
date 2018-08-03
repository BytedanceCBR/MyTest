//
//  TTPersonModel.m
//  Forum
//
//  Created by Zhang Leonardo on 15-3-27.
//
//

#import "TTPersonModel.h"
#import "FRImageInfoModel.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/TTBaseMacro.h>

#pragma mark -
#pragma mark TTUserRoleModel
@implementation TTUserRoleModel

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if ([dict objectForKey:@"roleDisplayType"]) {
            self.roleDisplayType = [[dict objectForKey:@"roleDisplayType"] integerValue];
        }
        
        if ([dict objectForKey:@"roleName"]) {
            self.roleName = [dict objectForKey:@"roleName"];
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.roleDisplayType = [[aDecoder decodeObjectForKey:@"roleDisplayType"] integerValue];
        self.roleName = [aDecoder decodeObjectForKey:@"roleName"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_roleDisplayType) forKey:@"roleDisplayType"];
    [aCoder encodeObject:_roleName forKey:@"roleName"];
}

@end

#pragma mark -
#pragma mark TTUserIconModel
@implementation TTUserIconModel

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.icon_url = [[FRImageInfoModel alloc] initWithDictionary:[dict objectForKey:@"icon_url"]];
        self.action_url = [dict objectForKey:@"action_url"];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.icon_url = [aDecoder decodeObjectForKey:@"icon_url"];
        self.action_url = [aDecoder decodeObjectForKey:@"action_url"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_icon_url forKey:@"icon_url"];
    [aCoder encodeObject:_action_url forKey:@"action_url"];
}

@end


#pragma mark -
#pragma mark TTPersonModel
@implementation TTPersonModel

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if(self)
    {
        [self updateWithDictionary:dict];
    }
    
    return self;
}

- (void)updateWithDictionary:(NSDictionary *)dict
{
    if([dict objectForKey:@"user_id"])
    {
        self.userID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"user_id"]];
    }
    else if ([dict objectForKey:@"id"])
    {
        self.userID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
    }
    
    if(!isEmptyString([dict tt_stringValueForKey:@"name"]))
    {
        self.name = [dict objectForKey:@"name"];
    } else if (!isEmptyString([dict tt_stringValueForKey:@"user_name"])) {
        self.name = [dict objectForKey:@"user_name"];
    }

    if(!isEmptyString([dict tt_stringValueForKey:@"screen_name"]))
    {
        self.screenName = [dict objectForKey:@"screen_name"];
    }
    
    if(!isEmptyString([dict tt_stringValueForKey:@"avatar_url"]))
    {
        self.avatarURLString = [dict objectForKey:@"avatar_url"];
    } else if (!isEmptyString([dict tt_stringValueForKey:@"user_profile_image_url"])) {
        self.avatarURLString = dict[@"user_profile_image_url"];
    }

    if(!isEmptyString([dict tt_stringValueForKey:@"description"]))
    {
        self.userDescription = [dict objectForKey:@"description"];
    }
    
    if (!isEmptyString([dict tt_stringValueForKey:@"user_intro"])) {
        self.userIntro = dict[@"user_intro"];
    }
    
    if([dict objectForKey:@"user_auth_info"]) {
        self.userAuthInfo = [dict tt_stringValueForKey:@"user_auth_info"];
    }

    if([dict objectForKey:@"verified_agency"]) {
        self.verfiedAgency = dict[@"verified_agency"];
    }
    
    if([dict objectForKey:@"verified_content"]) {
        self.verfiedContent = dict[@"verified_content"];
    }
    
    if([dict objectForKey:@"gender"])
    {
        self.gender = [dict objectForKey:@"gender"];
    }
    
    if ([dict.allKeys containsObject:@"pgc_like_count"]) {
        self.pgcLikeCount = [dict tt_longlongValueForKey:@"pgc_like_count"];
    }

    if ([dict.allKeys containsObject:@"is_following"]) {
        self.isFollowing = [[dict objectForKey:@"is_following"] intValue];
    }

    if ([dict.allKeys containsObject:@"followings_count"]) {
        self.followingCount = [dict tt_longlongValueForKey:@"followings_count"];
    }

    if ([dict.allKeys containsObject:@"is_followed"]) {
        self.isFollowed = [[dict objectForKey:@"is_followed"] intValue];
    }
    
    if ([dict.allKeys containsObject:@"followers_count"]) {
        self.followerCount = [dict tt_longlongValueForKey:@"followers_count"];
    }
    
    if ([dict.allKeys containsObject:@"is_blocking"]) {
        self.isBlocking = [[dict objectForKey:@"is_blocking"] boolValue];
    }
    
    if ([dict.allKeys containsObject:@"is_blocked"]) {
        self.isBlocked = [[dict objectForKey:@"is_blocked"] boolValue];
    }
    
    if ([dict.allKeys containsObject:@"reason_type"]) {
        self.reasonType = [[dict objectForKey:@"reason_type"] intValue];
    }
    
    if ([dict.allKeys containsObject:@"recommend_reason"]) {
        self.recommendReason = [dict objectForKey:@"recommend_reason"];
    }
    
    if ([dict.allKeys containsObject:@"mobile_hash"]) {
        self.mobileHash = [dict objectForKey:@"mobile_hash"];
    }
    
    if([dict objectForKey:@"mobile"])
    {
        self.phoneNumberString = [dict objectForKey:@"mobile"];
    }
    
    if ([dict objectForKey:@"post_count"]) {
        self.postCount = [[dict objectForKey:@"post_count"] integerValue];
    }
    
    if ([dict objectForKey:@"reply_count"]) {
        self.replyCount = [[dict objectForKey:@"reply_count"] integerValue];
    }
    
    if ([dict objectForKey:@"forum_count"]) {
        self.forumCount = [[dict objectForKey:@"forum_count"] integerValue];
    }
    
    if ([dict objectForKey:@"roleDisplayType"]) {
        self.roleDisplayType = [[dict objectForKey:@"roleDisplayType"] integerValue];
    }
    
    if ([dict objectForKey:@"roleName"]) {
        self.roleName = [dict objectForKey:@"roleName"];
    }
    
    NSArray<NSDictionary *> *userRolesDics = [dict objectForKey:@"userRoles"];
    if ([userRolesDics isKindOfClass:[NSArray class]] && userRolesDics.count > 0) {
        NSMutableArray * userRoles= [[NSMutableArray alloc] initWithCapacity:3];
        [userRolesDics enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TTUserRoleModel *userRole = [[TTUserRoleModel alloc] initWithDictionary:obj];
            if (userRole) {
                [userRoles addObject:userRole];
            }
        }];
        if (userRoles.count > 0) {
            self.userRoles = [userRoles copy];
        }
    }
    
    NSArray<NSDictionary *> *userRoleIconsDics = [dict objectForKey:@"userRoleIcons"];
    if ([userRoleIconsDics isKindOfClass:[NSArray class]] && userRoleIconsDics.count > 0) {
        NSMutableArray<TTUserIconModel *> *userRoleIcons = [NSMutableArray arrayWithCapacity:10];
        [userRoleIconsDics enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TTUserIconModel *userIconModel = [[TTUserIconModel alloc] initWithDictionary:obj];
            [userRoleIcons addObject:userIconModel];
        }];
        self.userRoleIcons = [userRoleIcons copy];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.userID = [aDecoder decodeObjectForKey:@"userID"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.screenName = [aDecoder decodeObjectForKey:@"screenName"];
        self.avatarURLString = [aDecoder decodeObjectForKey:@"avatarURLString"];
        self.userDescription = [aDecoder decodeObjectForKey:@"userDescription"];
        self.userAuthInfo = [aDecoder decodeObjectForKey:@"user_auth_info"];
        self.verfiedAgency = [aDecoder decodeObjectForKey:@"verfiedAgency"];
        self.verfiedContent = [aDecoder decodeObjectForKey:@"verfiedContent"];
        self.gender = [aDecoder decodeObjectForKey:@"gender"];
        self.pgcLikeCount = [[aDecoder decodeObjectForKey:@"pgcLikeCount"] longLongValue];
        self.isFollowing = [[aDecoder decodeObjectForKey:@"isFollowing"] boolValue];
        self.followingCount = [[aDecoder decodeObjectForKey:@"followingCount"] longLongValue];
        self.isFollowed = [[aDecoder decodeObjectForKey:@"isFollowed"] boolValue];
        self.followerCount = [[aDecoder decodeObjectForKey:@"followerCount"] longLongValue];
        self.isBlocking = [[aDecoder decodeObjectForKey:@"isBlocking"] boolValue];
        self.isBlocked = [[aDecoder decodeObjectForKey:@"isBlocked"] boolValue];
        self.reasonType = [[aDecoder decodeObjectForKey:@"reasonType"] intValue];
        self.recommendReason = [aDecoder decodeObjectForKey:@"recommendReason"];
        self.mobileHash = [aDecoder decodeObjectForKey:@"mobileHash"];
        self.phoneNumberString = [aDecoder decodeObjectForKey:@"phoneNumberString"];
        self.postCount = [[aDecoder decodeObjectForKey:@"postCount"] integerValue];
        self.replyCount = [[aDecoder decodeObjectForKey:@"replyCount"] integerValue];
        self.forumCount = [[aDecoder decodeObjectForKey:@"forumCount"] integerValue];
        self.roleDisplayType = [[aDecoder decodeObjectForKey:@"roleDisplayType"] integerValue];
        self.roleName = [aDecoder decodeObjectForKey:@"roleName"];
        self.userRoles = [aDecoder decodeObjectForKey:@"userRoles"];
        self.userRoleIcons = [aDecoder decodeObjectForKey:@"userRoleIcons"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_userID forKey:@"userID"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_screenName forKey:@"screenName"];
    [aCoder encodeObject:_avatarURLString forKey:@"avatarURLString"];
    [aCoder encodeObject:_userDescription forKey:@"userDescription"];
    [aCoder encodeObject:_userAuthInfo forKey:@"user_auth_info"];
    [aCoder encodeObject:_verfiedAgency forKey:@"verfiedAgency"];
    [aCoder encodeObject:_verfiedContent forKey:@"verfiedContent"];
    [aCoder encodeObject:_gender forKey:@"gender"];
    [aCoder encodeObject:@(_pgcLikeCount) forKey:@"pgcLikeCount"];
    [aCoder encodeObject:@(_isFollowing) forKey:@"isFollowing"];
    [aCoder encodeObject:@(_followingCount) forKey:@"followingCount"];
    [aCoder encodeObject:@(_isBlocking) forKey:@"isBlocking"];
    [aCoder encodeObject:@(_isBlocked) forKey:@"isBlocked"];
    [aCoder encodeObject:@(_reasonType) forKey:@"reasonType"];
    [aCoder encodeObject:_recommendReason forKey:@"recommendReason"];
    [aCoder encodeObject:_mobileHash forKey:@"mobileHash"];
    [aCoder encodeObject:_phoneNumberString forKey:@"phoneNumberString"];
    [aCoder encodeObject:@(_postCount) forKey:@"postCount"];
    [aCoder encodeObject:@(_replyCount) forKey:@"replyCount"];
    [aCoder encodeObject:@(_forumCount) forKey:@"forumCountl"];
    [aCoder encodeObject:@(_roleDisplayType) forKey:@"roleDisplayType"];
    [aCoder encodeObject:_roleName forKey:@"roleName"];
    [aCoder encodeObject:_userRoles forKey:@"userRoles"];
    [aCoder encodeObject:_userRoleIcons forKey:@"userRoleIcons"];
}


@end

