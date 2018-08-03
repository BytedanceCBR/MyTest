//
//  TTPersonModel+FRUser.m
//  Forum
//
//  Created by zhaopengwei on 15/4/15.
//
//

#import "TTPersonModel+FRUser.h"
#import "FRApiModel.h"
#import "FRImageInfoModel.h"
#import <TTBaseLib/TTBaseMacro.h>

@implementation TTPersonModel (FRUser)

- (instancetype)initWithDefault
{
    self = [super init];
    if (self) {
        self.userID = @"";
        self.name = @"";
        self.screenName = @"";
        self.avatarURLString = @"";
        self.userDescription = @"";
        self.userAuthInfo = @"";
        self.verfiedAgency = @"";
        self.verfiedContent = @"";
        self.gender = @"0";
        self.pgcLikeCount = 0;
        self.isFollowing = NO;
        self.isFollowed = NO;
        self.followerCount = 0;
        self.followingCount = 0;
        self.isBlocked = NO;
        self.isBlocking = NO;
        self.reasonType = 0;
        self.recommendReason = @"";
        self.mobileHash = @"";
        self.phoneNumberString = @"";
        self.postCount = 0;
        self.replyCount = 0;
        self.forumCount = 0;
        self.roleDisplayType = 0;
        self.roleName = @"";
    }
    
    return self;
    
}

- (instancetype)initWithUserModel:(FRUserInfoStructModel *)userInfo
{
    self = [super init];
    if (self) {
        self.userID = userInfo.user_id.stringValue;
        self.name = userInfo.name;
        self.screenName = userInfo.screen_name;
        self.avatarURLString = userInfo.avatar_url;
        self.userDescription = userInfo.desc;
        self.userAuthInfo = userInfo.user_auth_info;
        self.verfiedAgency = userInfo.verified_agency;
        self.verfiedContent = userInfo.verified_content;
        self.gender = [NSString stringWithFormat:@"%li", userInfo.gender];
        self.pgcLikeCount = 0;
        self.isFollowing = userInfo.is_following == FRUserFollowingTypeFollowing ? YES : NO;
        self.isFollowed = userInfo.is_followed == FRUserFollowedTypeFollowed ? YES : NO;
        self.followerCount = userInfo.followers_count.intValue;
        self.followingCount = userInfo.followings_count.intValue;
        self.isBlocked = userInfo.is_blocked == FRUserBlockedTypeBlocked ? YES : NO;
        self.isBlocking = userInfo.is_blocking == FRUserBlockingTypeBlocking ? YES : NO;
        self.reasonType = userInfo.reason_type;
        self.recommendReason = userInfo.recommend_reason;
        self.mobileHash = userInfo.mobile_hash;
        self.phoneNumberString = userInfo.mobile;
        self.postCount = 20;
        self.replyCount = 20;
        self.forumCount = 20;
    }
    
    return self;
}

- (instancetype)initWithMessageListUserModel:(FRMessageListUserInfoStructModel *)userInfo
{
    self = [self initWithDefault];
    if (self) {
        self.userID = userInfo.user_id.stringValue;
        self.name = userInfo.screen_name;
        self.screenName = userInfo.screen_name;
        self.avatarURLString = userInfo.avatar_url;
        self.userAuthInfo = userInfo.user_auth_info;
    }
    
    return self;
}

- (instancetype)initWithUserStructModel:(FRUserStructModel *)userInfo
{
    self = [self initWithDefault];
    if (self) {
        self.userID = userInfo.user_id.stringValue;
        self.avatarURLString = userInfo.avatar_url;
        self.name = userInfo.screen_name;
        self.screenName = userInfo.screen_name;
        self.userAuthInfo = userInfo.user_auth_info;
        self.verfiedContent = userInfo.verified_content;
        self.isBlocked = [userInfo.is_blocked integerValue];
        self.isBlocking = [userInfo.is_blocking integerValue];
        self.isFollowing = [userInfo.is_following integerValue] == FRUserFollowingTypeFollowing ? YES : NO;
        self.followerCount = [userInfo.followers_count longLongValue];
        self.followingCount = [userInfo.followings_count longLongValue];
        if (userInfo.user_role) {
            self.roleDisplayType = userInfo.user_role.role_display_type;
            self.roleName = userInfo.user_role.role_name;
        }
        
        if (userInfo.user_roles) {
            NSMutableArray *userRoles = [[NSMutableArray alloc] initWithCapacity:3];
            [userInfo.user_roles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                TTUserRoleModel *userRole = [[TTUserRoleModel alloc] init];
                userRole.roleDisplayType = [(FRUserRoleStructModel *)obj role_display_type];
                userRole.roleName = [(FRUserRoleStructModel *)obj role_name];
                [userRoles addObject:userRole];
            }];
            if (userRoles.count > 0) {
                self.userRoles = [userRoles copy];
            }
        }
        
        if (userInfo.user_role_icons) {
            NSMutableArray *userRoleIcons = [[NSMutableArray alloc] initWithCapacity:3];
            [userInfo.user_role_icons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                TTUserIconModel *userIconModel = [[TTUserIconModel alloc] init];
                userIconModel.icon_url = [FRImageInfoModel genInfoModelFromStruct:[(FRUserIconStructModel *)obj icon_url]];
                userIconModel.action_url = [(FRUserIconStructModel *)obj action_url];
                [userRoleIcons addObject:userIconModel];
            }];
            self.userRoleIcons = [userRoleIcons copy];
        }
    }
    
    return self;
}

+ (NSArray<TTPersonModel> *)genPersonModelsFromUserStruct:(NSArray<FRUserStructModel> *)userStructs
{
    if ([userStructs count] == 0) {
        return nil;
    }
    NSMutableArray<TTPersonModel> * result = (NSMutableArray<TTPersonModel> *)[NSMutableArray arrayWithCapacity:10];
    for (FRUserStructModel * stru in userStructs) {
        if ([stru isKindOfClass:[FRUserStructModel class]]) {
            TTPersonModel * model = [[TTPersonModel alloc] initWithUserStructModel:stru];
            if (model) {
                [result addObject:model];
            }
        }
    }
    return result;
}

+ (TTPersonModel *)genTTPersonModelFromMyUserModel:(SSMyUserModel *)model
{
    if (!model || ![model isKindOfClass:[SSMyUserModel class]]) {
        return nil;
    }
    TTPersonModel * ttModel = [[TTPersonModel alloc] init];
    ttModel.userID = model.ID;
    ttModel.name = model.name;
    ttModel.screenName = model.name;
    ttModel.avatarURLString = model.avatarURLString;
    ttModel.userDescription = model.userDescription;
    ttModel.userAuthInfo = model.userAuthInfo;
    ttModel.gender = model.gender;
    ttModel.pgcLikeCount = model.pgcLikeCount;
    ttModel.followerCount = model.followerCount;
    ttModel.followingCount = model.followingCount;
    ttModel.isBlocked = model.isBlocked;
    ttModel.isBlocking = model.isBlocking;
    return ttModel;
}

+ (SSMyUserModel *)genMyUserModelFromTTPersonModel:(TTPersonModel *)ttModel{
    if (!ttModel || ![ttModel isKindOfClass:[TTPersonModel class]]) {
        return nil;
    }
    SSMyUserModel * model = [[SSMyUserModel alloc] init];
    model.ID = ttModel.userID;
    model.name = ttModel.name;
    model.name = ttModel.screenName;
    model.avatarURLString = ttModel.avatarURLString;
    model.userDescription = ttModel.userDescription;
    model.userAuthInfo = ttModel.userAuthInfo;
    model.gender = ttModel.gender;
    model.pgcLikeCount = ttModel.pgcLikeCount;
    model.followerCount = ttModel.followerCount;
    model.followingCount = ttModel.followingCount;
    model.isBlocked = ttModel.isBlocked;
    model.isBlocking = ttModel.isBlocking;
    return model;
}

+ (TTPersonModel *)genTTPersonModelFromUserModel:(SSUserModel *)model
{
    if (!model || ![model isKindOfClass:[SSUserModel class]]) {
        return nil;
    }
    TTPersonModel * ttModel = [[TTPersonModel alloc] init];
    ttModel.userID = model.ID;
    ttModel.name = model.name;
    ttModel.screenName = model.name;
    ttModel.avatarURLString = model.avatarURLString;
    ttModel.userDescription = model.userDescription;
    ttModel.userAuthInfo = model.userAuthInfo;
    ttModel.gender = model.gender;
    ttModel.pgcLikeCount = model.pgcLikeCount;
    ttModel.followerCount = model.followerCount;
    ttModel.followingCount = model.followingCount;
    ttModel.isBlocked = model.isBlocked;
    ttModel.isBlocking = model.isBlocking;
    return ttModel;
}

+ (SSUserModel *)genUserModelFromTTPersonModel:(TTPersonModel *)ttModel{
    if (!ttModel || ![ttModel isKindOfClass:[TTPersonModel class]]) {
        return nil;
    }
    SSUserModel * model = [[SSUserModel alloc] init];
    model.ID = ttModel.userID;
    model.name = ttModel.name;
    model.name = ttModel.screenName;
    model.avatarURLString = ttModel.avatarURLString;
    model.userDescription = ttModel.userDescription;
    model.userAuthInfo = ttModel.userAuthInfo;
    model.gender = ttModel.gender;
    model.pgcLikeCount = ttModel.pgcLikeCount;
    model.followerCount = ttModel.followerCount;
    model.followingCount = ttModel.followingCount;
    model.isBlocked = ttModel.isBlocked;
    model.isBlocking = ttModel.isBlocking;
    return model;
}

+ (FRUserStructModel *)genUserStructModelFrom:(TTPersonModel *)ttModel {
    if (ttModel == nil) {
        return nil;
    }
    FRUserStructModel * userStructModel = [[FRUserStructModel alloc] init];
    userStructModel.user_id = @(ttModel.userID.longLongValue);
    userStructModel.avatar_url = ttModel.avatarURLString;
    userStructModel.screen_name = ttModel.name;
    userStructModel.screen_name = ttModel.screenName;
    userStructModel.user_auth_info = ttModel.userAuthInfo;
    userStructModel.verified_content = ttModel.verfiedContent;
    userStructModel.is_blocked = @(ttModel.isBlocked);
    userStructModel.is_blocking = @(ttModel.isBlocking);
    userStructModel.is_following = @(ttModel.isFollowing) ? @(FRUserFollowingTypeFollowing):@(FRUserFollowingTypeUnfollowing);
    if (!isEmptyString(ttModel.roleName)) {
        userStructModel.user_role = [[FRUserRoleStructModel alloc] init];
        userStructModel.user_role.role_display_type = ttModel.roleDisplayType;
        userStructModel.user_role.role_name = ttModel.roleName;
    }
    
    if (ttModel.userRoles.count > 0) {
        NSMutableArray <FRUserRoleStructModel *> * userRoleStructModels = [[NSMutableArray alloc] initWithCapacity:3];
        [ttModel.userRoles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TTUserRoleModel * userRole = obj;
            FRUserRoleStructModel * userRoleStructModel = [[FRUserRoleStructModel alloc] init];
            userRoleStructModel.role_display_type = userRole.roleDisplayType;
            userRoleStructModel.role_name = userRole.roleName;
            [userRoleStructModels addObject:userRoleStructModel];
        }];
        if (userRoleStructModels.count > 0) {
            userStructModel.user_roles = userRoleStructModels.copy;
        }
    }
    
    if (ttModel.userRoleIcons.count > 0) {
        NSMutableArray <FRUserIconStructModel *> * userIconStructModels = [[NSMutableArray alloc] initWithCapacity:3];
        [ttModel.userRoleIcons enumerateObjectsUsingBlock:^(TTUserIconModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FRUserIconStructModel * userIconStructModel = [[FRUserIconStructModel alloc] init];
            userIconStructModel.icon_url = [FRImageInfoModel genUserIconStructModelFromInfoModel:obj.icon_url];
            userIconStructModel.action_url = obj.action_url;
            [userIconStructModels addObject:userIconStructModel];
        }];
        if (userIconStructModels.count > 0) {
            userStructModel.user_role_icons = userIconStructModels.copy;
        }
    }
    
    return userStructModel;
}

@end
