//
//  TTAccountUserEntity+Private.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/5/16.
//  Copyright © 2016 com.bytedance.news. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAccountUserEntity_Priv.h"
#import "TTAccountRespModel.h"
#import <objc/runtime.h>



#pragma mark - TTAccountMediaUserEntity

@implementation TTAccountMediaUserEntity (tta_internal)

- (instancetype)initWithMediaUserModel:(TTAMediaUserModel *)aMdl
{
    if (!aMdl) return nil;
    if (![aMdl isKindOfClass:[TTAMediaUserModel class]]) return nil;
    if ((self = [super init])) {
        self.mediaID = aMdl.media_id;
        self.name    = aMdl.name;
        self.avatarURL = aMdl.avatar_url;
        self.userVerified = [aMdl.user_verified boolValue];
        self.displayAppOcrEntrance = [aMdl.display_app_ocr_entrance boolValue];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if ((self = [super init])) {
        self.mediaID = [dict valueForKey:NSStringFromSelector(@selector(mediaID))];
        if (!self.mediaID) self.mediaID = [dict valueForKey:NSStringFromSelector(@selector(media_id))];
        if ([self.mediaID isKindOfClass:[NSString class]]) self.mediaID = @([(NSString *)self.mediaID longLongValue]);
        
        self.name = [dict valueForKey:NSStringFromSelector(@selector(name))];
        
        self.avatarURL = [dict valueForKey:NSStringFromSelector(@selector(avatarURL))];
        if (!self.avatarURL && [dict valueForKey:NSStringFromSelector(@selector(avatar_url))]) {
            self.avatarURL = [dict valueForKey:NSStringFromSelector(@selector(avatar_url))];
        }
        
        if ([dict valueForKey:NSStringFromSelector(@selector(userVerified))]) {
            self.userVerified = [[dict valueForKey:NSStringFromSelector(@selector(userVerified))] boolValue];
        } else if ([dict valueForKey:NSStringFromSelector(@selector(user_verified))]) {
            self.userVerified = [[dict valueForKey:NSStringFromSelector(@selector(user_verified))] boolValue];
        }
        
        if ([dict valueForKey:NSStringFromSelector(@selector(displayAppOcrEntrance))]) {
            self.displayAppOcrEntrance = [[dict valueForKey:NSStringFromSelector(@selector(displayAppOcrEntrance))] boolValue];
        } else if ([dict valueForKey:NSStringFromSelector(@selector(display_app_ocr_entrance))]) {
            self.displayAppOcrEntrance = [[dict valueForKey:NSStringFromSelector(@selector(display_app_ocr_entrance))] boolValue];
        }
    }
    return self;
}

@end



#pragma mark - TTAccountUserAuditSet

@implementation TTAccountUserAuditEntity (tta_internal)

- (instancetype)initWithAuditModel:(TTAUserAuditInfoItem *)auditMdl
{
    if (!auditMdl || ![auditMdl isKindOfClass:[TTAUserAuditInfoItem class]])
        return nil;
    if ((self = [super init])) {
        self.name = auditMdl.name;
        self.userDescription = auditMdl.user_description;
        self.avatarURL  = auditMdl.avatar_url;
        
        self.gender     = auditMdl.gender;
        self.birthday   = auditMdl.birthday;
        self.area       = auditMdl.area;
        self.industry   = auditMdl.industry;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if ([dict count] <= 0) return nil;
    if ((self = [super init])) {
        self.name = [dict valueForKey:NSStringFromSelector(@selector(name))];
        
        self.userDescription = [dict valueForKey:NSStringFromSelector(@selector(userDescription))];
        if (!self.userDescription) {
            self.userDescription = [dict valueForKey:NSStringFromSelector(@selector(user_description))];
        }
        
        self.avatarURL = [dict valueForKey:NSStringFromSelector(@selector(avatarURL))];
        if (!self.avatarURL) {
            self.avatarURL = [dict valueForKey:NSStringFromSelector(@selector(avatar_url))];
        }
        
        self.gender = [dict valueForKey:NSStringFromSelector(@selector(gender))];
        if ([self.gender isKindOfClass:[NSString class]]) {
            self.gender = @([(NSString *)self.gender longLongValue]);
        }
        
        self.birthday = [dict valueForKey:NSStringFromSelector(@selector(birthday))];
        
        self.area = [dict valueForKey:NSStringFromSelector(@selector(area))];
        
        self.industry = [dict valueForKey:NSStringFromSelector(@selector(industry))];
    }
    return self;
}

@end

@implementation TTAccountVerifiedUserAuditEntity (tta_internal)

- (instancetype)initWithVerifiedAuditModel:(TTAUserVerifiedAuditInfoItem *)verifiedAuditMdl
{
    if (!verifiedAuditMdl || ![verifiedAuditMdl isKindOfClass:[TTAUserVerifiedAuditInfoItem class]])
        return nil;
    if ((self = [super init])) {
        self.name = verifiedAuditMdl.audit_info.name;
        self.userDescription = verifiedAuditMdl.audit_info.user_description;
        self.avatarURL = verifiedAuditMdl.audit_info.avatar_url;
        self.gender = verifiedAuditMdl.audit_info.gender;
        self.birthday = verifiedAuditMdl.audit_info.birthday;
        self.area = verifiedAuditMdl.audit_info.area;
        self.industry = verifiedAuditMdl.audit_info.industry;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if ((self = [super initWithDictionary:dict])) {
        
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    return [super toDictionary];
}

@end

@implementation TTAccountMediaUserAuditEntity (tta_internal)

- (instancetype)initWithMediaAuditModel:(TTAPGCUserAuditInfoItem *)mediaAuditMdl
{
    if (!mediaAuditMdl || ![mediaAuditMdl isKindOfClass:[TTAPGCUserAuditInfoItem class]])
        return nil;
    if ((self = [super init])) {
        self.auditing = [mediaAuditMdl.is_auditing boolValue];
        self.expiredTime = mediaAuditMdl.audit_expire_time;
        
        self.name = mediaAuditMdl.audit_info.name;
        self.userDescription = mediaAuditMdl.audit_info.user_description;
        self.avatarURL = mediaAuditMdl.audit_info.avatar_url;
        self.gender = mediaAuditMdl.audit_info.gender;
        self.birthday = mediaAuditMdl.audit_info.birthday;
        self.area = mediaAuditMdl.audit_info.area;
        self.industry = mediaAuditMdl.audit_info.industry;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if ([dict count] <= 0) return nil;
    if ((self = [super initWithDictionary:dict])) {
        self.auditing = [[dict valueForKey:NSStringFromSelector(@selector(auditing))] boolValue];
        if (![dict valueForKey:NSStringFromSelector(@selector(auditing))]) {
            self.auditing = [[dict valueForKey:NSStringFromSelector(@selector(is_auditing))] boolValue];
        }
        
        self.expiredTime = [dict valueForKey:NSStringFromSelector(@selector(expiredTime))];
        if (!self.expiredTime) {
            self.expiredTime = [dict valueForKey:NSStringFromSelector(@selector(audit_expire_time))];
        }
    }
    return self;
}

@end

@implementation TTAccountUserAuditSet (tta_internal)

- (instancetype)initWithUserModel:(TTAUpdateUserProfileModel *)userAuditMdl
{
    if (!userAuditMdl || ![userAuditMdl isKindOfClass:[TTAUpdateUserProfileModel class]])
        return nil;
    if ((self = [super init])) {
        self.currentUserEntity
        = [[TTAccountUserAuditEntity alloc] initWithAuditModel:userAuditMdl.current_info];
        self.verifiedUserAuditEntity
        = [[TTAccountVerifiedUserAuditEntity alloc] initWithVerifiedAuditModel:userAuditMdl.verified_audit_info];
        self.pgcUserAuditEntity
        = [[TTAccountMediaUserAuditEntity alloc] initWithMediaAuditModel:userAuditMdl.pgc_audit_info];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if ((self = [super init])) {
        NSDictionary *currentUserDict = [dict valueForKey:NSStringFromSelector(@selector(currentUserEntity))];
        self.currentUserEntity = [[TTAccountUserAuditEntity alloc] initWithDictionary:currentUserDict];
        
        NSDictionary *verifiedUserDict = [dict valueForKey:NSStringFromSelector(@selector(verifiedUserAuditEntity))];
        self.verifiedUserAuditEntity = [[TTAccountVerifiedUserAuditEntity alloc] initWithDictionary:verifiedUserDict];
        
        NSDictionary *pgcUserDict = [dict valueForKey:NSStringFromSelector(@selector(pgcUserAuditEntity))];
        self.pgcUserAuditEntity = [[TTAccountMediaUserAuditEntity alloc] initWithDictionary:pgcUserDict];
    }
    return self;
}

@end



#pragma mark - TTAccountPlatformEntity

@implementation TTAccountPlatformEntity (tta_internal)

- (instancetype)initWithThirdAccountModel:(TTAThirdAccountModel *)aMdl
{
    if (!aMdl) return nil;
    if (![aMdl isKindOfClass:[TTAThirdAccountModel class]]) return nil;
    if ((self = [super init])) {
        self.userID             = aMdl.user_id;
        self.platformScreenName = aMdl.platform_screen_name;
        self.profileImageURL    = aMdl.profile_image_url;
        self.platform           = aMdl.platform;
        self.platformUID        = aMdl.platform_uid;
        self.expiredIn          = aMdl.expires_in;
        self.expiredTime        = aMdl.expired_time;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if ((self = [super init])) {
        self.userID = [dict valueForKey:NSStringFromSelector(@selector(userID))];
        if (!self.userID) {
            self.userID = [dict valueForKey:NSStringFromSelector(@selector(user_id))];
        }
        if ([self.userID isKindOfClass:[NSString class]]) {
            self.userID = @([(NSString *)self.userID longLongValue]);
        }
        
        self.platformScreenName     = [dict valueForKey:NSStringFromSelector(@selector(platformScreenName))];
        if (!self.platformScreenName) {
            self.platformScreenName = [dict valueForKey:NSStringFromSelector(@selector(platform_screen_name))];
        }
        
        self.profileImageURL = [dict valueForKey:NSStringFromSelector(@selector(profileImageURL))];
        if (!self.profileImageURL) {
            self.profileImageURL= [dict valueForKey:NSStringFromSelector(@selector(profile_image_url))];
        }
        
        self.platform           = [dict valueForKey:NSStringFromSelector(@selector(platform))];
        
        self.platformUID        = [dict valueForKey:NSStringFromSelector(@selector(platformUID))];
        if (!self.platformUID) {
            self.platformUID    = [dict valueForKey:NSStringFromSelector(@selector(platform_uid))];
        }
        
        self.expiredIn          = [dict valueForKey:NSStringFromSelector(@selector(expiredIn))];
        if ([self.expiredIn isKindOfClass:[NSString class]]) {
            self.expiredIn      = @([(NSString *)self.expiredIn longLongValue]);
        }
        
        self.expiredTime        = [dict valueForKey:NSStringFromSelector(@selector(expiredTime))];
        if ([self.expiredTime isKindOfClass:[NSString class]]) {
            self.expiredTime    = @([(NSString *)self.expiredTime longLongValue]);
        }
    }
    return self;
}

@end



#pragma mark - TTAccountUserEntity

@implementation TTAccountUserEntity (tta_internal)

- (void)dealloc
{
    [self tta_removeObservers];
    [self tta_setObserveValueChangedHandler:nil];
}

- (instancetype)initWithUserModel:(TTAUserModel *)userMdl
{
    if (!userMdl) return nil;
    if (userMdl.error_code != 0) return nil;
    
    if ((self = [super init])) {
        self.isToutiao       = [userMdl.is_toutiao boolValue];
        self.token           = nil;
        self.sessionKey      = userMdl.session_key;
        self.newUser         = userMdl.new_user;
        self.name            = userMdl.name;
        self.birthday        = userMdl.birthday;
        self.area            = userMdl.area;
        self.industry        = userMdl.industry;
        self.userID          = userMdl.user_id;
        self.mediaID         = userMdl.media_id;
        self.media           = [[TTAccountMediaUserEntity alloc] initWithMediaUserModel:userMdl.media];
        self.canBeFoundByPhone = userMdl.can_be_found_by_phone;
        self.userPrivacyExtend = userMdl.user_privacy_extend;
        self.shareToRepost   = userMdl.share_to_repost;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.userVerified    = userMdl.user_verified;
#pragma clang diagnostic pop
        self.userAuthInfo    = userMdl.user_auth_info;
        
        self.gender          = userMdl.gender;
        self.screenName      = userMdl.screen_name;
        self.mobile          = userMdl.mobile;
        self.email           = userMdl.email;
        self.avatarURL       = userMdl.avatar_url;
        self.avatarLargeURL  = userMdl.avatar_large_url;
        self.bgImgURL        = userMdl.bg_img_url;
        self.userDescription = userMdl.user_description;
        self.verifiedReason  = userMdl.verified_reason;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.verifiedContent = userMdl.verified_content;
#pragma clang diagnostic pop
        self.verifiedAgency  = userMdl.verified_agency;
        self.userDecoration  = userMdl.user_decoration;
        self.recommendReason = userMdl.recommend_reason;
        self.reasonType      = userMdl.reason_type;
        self.point           = userMdl.point;
        self.shareURL        = userMdl.share_url;
        self.safe            = userMdl.safe;
        self.isBlocking      = userMdl.is_blocking;
        self.isBlocked       = userMdl.is_blocked;
        self.isFollowing     = userMdl.is_following;
        self.isFollowed      = userMdl.is_followed;
        self.followersCount  = [userMdl.followers_count longLongValue];
        self.followingsCount = [userMdl.followings_count longLongValue];
        self.visitCountRecent= [userMdl.visit_count_recent longLongValue];
        self.momentsCount    = [userMdl.moments_count longLongValue];
        self.isRecommendAllowed = userMdl.is_recommend_allowed;
        self.recommendHintMessage = userMdl.recommend_hint_message;
        
        if ([userMdl.connects count] > 0) {
            NSMutableArray<TTAccountPlatformEntity *> *accountEntities = [NSMutableArray array];
            [userMdl.connects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[TTAThirdAccountModel class]]) {
                    TTAccountPlatformEntity *aEntity = [[TTAccountPlatformEntity alloc] initWithThirdAccountModel:obj];
                    if (aEntity) [accountEntities addObject:aEntity];
                }
            }];
            self.connects = ([accountEntities count] > 0) ? accountEntities : nil;
        }
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if ((self = [super init])) {
        self.isToutiao      = [[dict valueForKey:NSStringFromSelector(@selector(isToutiao))] boolValue];
        if ([dict valueForKey:NSStringFromSelector(@selector(is_toutiao))]) {
            self.isToutiao  = [[dict valueForKey:NSStringFromSelector(@selector(is_toutiao))] boolValue];
        }
        
        self.token           = [dict valueForKey:NSStringFromSelector(@selector(token))];
        
        self.sessionKey      = [dict valueForKey:NSStringFromSelector(@selector(sessionKey))];
        if (!self.sessionKey) {
            self.sessionKey  = [dict valueForKey:NSStringFromSelector(@selector(session_key))];
        }
        
        self.newUser         = [[dict valueForKey:NSStringFromSelector(@selector(newUser))] boolValue];
        if ([dict valueForKey:NSStringFromSelector(@selector(new_user))]) {
            self.newUser     = [[dict valueForKey:NSStringFromSelector(@selector(new_user))] boolValue];
        }
        
        self.name            = [dict valueForKey:NSStringFromSelector(@selector(name))];
        
        self.birthday        = [dict valueForKey:NSStringFromSelector(@selector(birthday))];
        
        self.area            = [dict valueForKey:NSStringFromSelector(@selector(area))];
        
        self.industry        = [dict valueForKey:NSStringFromSelector(@selector(industry))];
        
        self.userID          = [dict valueForKey:NSStringFromSelector(@selector(userID))];
        if ([self.userID isKindOfClass:[NSString class]]) {
            self.userID      = @([(NSString *)self.userID longLongValue]);
        }
        if (!self.userID) {
            self.userID      = [dict valueForKey:NSStringFromSelector(@selector(user_id))];
        }
        
        self.mediaID         = [dict valueForKey:NSStringFromSelector(@selector(mediaID))];
        if ([self.mediaID isKindOfClass:[NSString class]]) {
            self.mediaID     = @([(NSString *)self.mediaID longLongValue]);
        }
        if (!self.mediaID) {
            self.mediaID     = [dict valueForKey:NSStringFromSelector(@selector(media_id))];
        }
        
        self.media           = [dict valueForKey:NSStringFromSelector(@selector(media))];
        if ([self.media isKindOfClass:[NSDictionary class]]) {
            self.media       = [[TTAccountMediaUserEntity alloc] initWithDictionary:(NSDictionary *)self.media];
        } else {
            self.media       = nil;
        }
        
        if ([[dict allKeys] containsObject:NSStringFromSelector(@selector(canBeFoundByPhone))]) {
            self.canBeFoundByPhone = [[dict valueForKey:NSStringFromSelector(@selector(canBeFoundByPhone))] boolValue];
        } else if ([[dict allKeys] containsObject:NSStringFromSelector(@selector(can_be_found_by_phone))]) {
            self.canBeFoundByPhone = [[dict valueForKey:NSStringFromSelector(@selector(can_be_found_by_phone))] boolValue];
        } else {
            self.canBeFoundByPhone = YES;
        }
        
        if ([[dict allKeys] containsObject:NSStringFromSelector(@selector(userPrivacyExtend))]) {
            self.userPrivacyExtend = [[dict valueForKey:NSStringFromSelector(@selector(userPrivacyExtend))] integerValue];
        } else if ([[dict allKeys] containsObject:NSStringFromSelector(@selector(user_privacy_extend))]) {
            self.userPrivacyExtend = [[dict valueForKey:NSStringFromSelector(@selector(user_privacy_extend))] integerValue];
        } else {
            self.userPrivacyExtend = 0;
        }
        
        if ([[dict allKeys] containsObject:NSStringFromSelector(@selector(shareToRepost))]) {
            self.shareToRepost = [[dict valueForKey:NSStringFromSelector(@selector(shareToRepost))] integerValue];
        } else if ([[dict allKeys] containsObject:NSStringFromSelector(@selector(share_to_repost))]) {
            self.shareToRepost = [[dict valueForKey:NSStringFromSelector(@selector(share_to_repost))] integerValue];
        } else {
            self.shareToRepost = -1;
        }
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.userVerified    = [[dict valueForKey:NSStringFromSelector(@selector(userVerified))] boolValue];
        if ([[dict allKeys] containsObject:NSStringFromSelector(@selector(user_verified))]) {
            self.userVerified= [[dict valueForKey:NSStringFromSelector(@selector(user_verified))] boolValue];
        }
#pragma clang diagnostic pop
        
        if ([[dict allKeys] containsObject:NSStringFromSelector(@selector(userAuthInfo))]) {
            self.userAuthInfo = [dict valueForKey:NSStringFromSelector(@selector(userAuthInfo))];
        } else if ([[dict allKeys] containsObject:NSStringFromSelector(@selector(user_auth_info))]) {
            self.userAuthInfo = [dict valueForKey:NSStringFromSelector(@selector(user_auth_info))];
        } else {
            self.userAuthInfo = nil;
        }
        
        self.gender     = [dict valueForKey:NSStringFromSelector(@selector(gender))];
        if ([self.gender isKindOfClass:[NSString class]]) {
            self.gender = @([(NSString *)self.gender longLongValue]);
        }
        
        self.screenName      = [dict valueForKey:NSStringFromSelector(@selector(screenName))];
        if (!self.screenName) {
            self.screenName  = [dict valueForKey:NSStringFromSelector(@selector(screen_name))];
        }
        
        self.mobile          = [dict valueForKey:NSStringFromSelector(@selector(mobile))];
        self.email           = [dict valueForKey:NSStringFromSelector(@selector(email))];
        
        self.avatarURL       = [dict valueForKey:NSStringFromSelector(@selector(avatarURL))];
        if (!self.avatarURL) {
            self.avatarURL   = [dict valueForKey:NSStringFromSelector(@selector(avatar_url))];
        }
        
        self.avatarLargeURL  = [dict valueForKey:NSStringFromSelector(@selector(avatarLargeURL))];
        if (!self.avatarLargeURL) {
            self.avatarLargeURL = [dict valueForKey:NSStringFromSelector(@selector(avatar_large_url))];
        }
        
        self.bgImgURL        = [dict valueForKey:NSStringFromSelector(@selector(bgImgURL))];
        if (!self.bgImgURL) {
            self.bgImgURL    = [dict valueForKey:NSStringFromSelector(@selector(bg_img_url))];
        }
        
        self.userDescription = [dict valueForKey:NSStringFromSelector(@selector(userDescription))];
        if (!self.userDescription) {
            self.userDescription = [dict valueForKey:NSStringFromSelector(@selector(user_description))];
        }
        
        self.userDecoration = [dict valueForKey:NSStringFromSelector(@selector(userDecoration))];
        if (!self.userDecoration) {
            self.userDecoration = [dict valueForKey:NSStringFromSelector(@selector(user_decoration))];
        }
        self.verifiedReason     = [dict valueForKey:NSStringFromSelector(@selector(verifiedReason))];
        if (!self.verifiedReason) {
            self.verifiedReason = [dict valueForKey:NSStringFromSelector(@selector(verified_reason))];
        }
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.verifiedContent     = [dict valueForKey:NSStringFromSelector(@selector(verifiedContent))];
        if (!self.verifiedContent) {
            self.verifiedContent = [dict valueForKey:NSStringFromSelector(@selector(verified_content))];
        }
#pragma clang diagnostic pop
        
        self.verifiedAgency     = [dict valueForKey:NSStringFromSelector(@selector(verifiedAgency))];
        if (!self.verifiedAgency) {
            self.verifiedAgency = [dict valueForKey:NSStringFromSelector(@selector(verified_agency))];
        }
        
        self.recommendReason = [dict valueForKey:NSStringFromSelector(@selector(recommendReason))];
        if (!self.recommendReason) {
            self.recommendReason = [dict valueForKey:NSStringFromSelector(@selector(recommend_reason))];
        }
        
        self.reasonType      = [dict valueForKey:NSStringFromSelector(@selector(reasonType))];
        if (!self.reasonType) {
            self.reasonType  = [dict valueForKey:NSStringFromSelector(@selector(reason_type))];
        }
        
        self.point           = [dict valueForKey:NSStringFromSelector(@selector(point))];
        if ([self.point isKindOfClass:[NSString class]]) {
            self.point = @([(NSString *)self.point longLongValue]);
        }
        
        self.shareURL        = [dict valueForKey:NSStringFromSelector(@selector(shareURL))];
        if (!self.shareURL) {
            self.shareURL    = [dict valueForKey:NSStringFromSelector(@selector(share_url))];
        }
        
        self.safe            = [dict valueForKey:NSStringFromSelector(@selector(safe))];
        if ([self.safe isKindOfClass:[NSString class]]) {
            self.safe        = @([(NSString *)self.safe longLongValue]);
        }
        
        self.isBlocking      = [[dict valueForKey:NSStringFromSelector(@selector(isBlocking))] boolValue];
        if ([dict valueForKey:NSStringFromSelector(@selector(is_blocking))]) {
            self.isBlocking  = [[dict valueForKey:NSStringFromSelector(@selector(is_blocking))] boolValue];
        }
        
        self.isBlocked       = [[dict valueForKey:NSStringFromSelector(@selector(isBlocked))] boolValue];
        if ([dict valueForKey:NSStringFromSelector(@selector(is_blocked))]) {
            self.isBlocked   = [[dict valueForKey:NSStringFromSelector(@selector(is_blocked))] boolValue];
        }
        
        self.isFollowing     = [[dict valueForKey:NSStringFromSelector(@selector(isFollowing))] boolValue];
        if ([dict valueForKey:NSStringFromSelector(@selector(is_following))]) {
            self.isFollowing = [[dict valueForKey:NSStringFromSelector(@selector(is_following))] boolValue];
        }
        
        self.isFollowed      = [[dict valueForKey:NSStringFromSelector(@selector(isFollowed))] boolValue];
        if ([dict valueForKey:NSStringFromSelector(@selector(is_followed))]) {
            self.isFollowed  = [[dict valueForKey:NSStringFromSelector(@selector(is_followed))] boolValue];
        }
        
        self.isRecommendAllowed = [[dict valueForKey:NSStringFromSelector(@selector(isRecommendAllowed))] boolValue];
        if ([dict valueForKey:NSStringFromSelector(@selector(is_recommend_allowed))]) {
            self.isRecommendAllowed = [[dict valueForKey:NSStringFromSelector(@selector(is_recommend_allowed))] boolValue];
        }
        
        self.recommendHintMessage = [dict valueForKey:NSStringFromSelector(@selector(recommendHintMessage))];
        if ([dict valueForKey:NSStringFromSelector(@selector(recommend_hint_message))]) {
            self.recommendHintMessage = [dict valueForKey:NSStringFromSelector(@selector(recommend_hint_message))];
        }
        
        self.followersCount = [[dict valueForKey:NSStringFromSelector(@selector(followersCount))] longLongValue];
        if ([dict valueForKey:NSStringFromSelector(@selector(followers_count))]) {
            self.followersCount = [[dict valueForKey:NSStringFromSelector(@selector(followers_count))] longLongValue];
        }
        
        self.followingsCount = [[dict valueForKey:NSStringFromSelector(@selector(followingsCount))] longLongValue];
        if ([dict valueForKey:NSStringFromSelector(@selector(followings_count))]) {
            self.followingsCount = [[dict valueForKey:NSStringFromSelector(@selector(followings_count))] longLongValue];
        }
        
        self.visitCountRecent = [[dict valueForKey:NSStringFromSelector(@selector(visitCountRecent))] longLongValue];
        if ([dict valueForKey:NSStringFromSelector(@selector(visit_count_recent))]) {
            self.visitCountRecent = [[dict valueForKey:NSStringFromSelector(@selector(visit_count_recent))] longLongValue];
        }
        
        self.momentsCount = [[dict valueForKey:NSStringFromSelector(@selector(momentsCount))] longLongValue];
        if ([dict valueForKey:NSStringFromSelector(@selector(moments_count))]) {
            self.momentsCount = [[dict valueForKey:NSStringFromSelector(@selector(moments_count))] longLongValue];
        }
        
        NSArray *thirdAccounts = [dict valueForKey:NSStringFromSelector(@selector(connects))];
        if ([thirdAccounts isKindOfClass:[NSArray class]] && [thirdAccounts count] > 0) {
            NSMutableArray<TTAccountPlatformEntity *> *thirdEntities = [NSMutableArray array];
            [thirdAccounts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    TTAccountPlatformEntity *aEntity = [[TTAccountPlatformEntity alloc] initWithDictionary:(NSDictionary *)obj];
                    if (aEntity) [thirdEntities addObject:aEntity];
                }
            }];
            if ([thirdEntities count] > 0) {
                self.connects = thirdEntities;
            }
        }
        
        NSDictionary *auditEntities = [dict valueForKey:NSStringFromSelector(@selector(auditInfoSet))];
        self.auditInfoSet = [[TTAccountUserAuditSet alloc] initWithDictionary:auditEntities];
    }
    return self;
}

- (NSDictionary *)toSharingKeyChainDictionary
{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [mutDict setValue:@(self.isToutiao)
               forKey:NSStringFromSelector(@selector(isToutiao))];
    [mutDict setValue:self.sessionKey
               forKey:NSStringFromSelector(@selector(sessionKey))];
    [mutDict setValue:self.name
               forKey:NSStringFromSelector(@selector(name))];
    [mutDict setValue:self.birthday
               forKey:NSStringFromSelector(@selector(birthday))];
    [mutDict setValue:self.area
               forKey:NSStringFromSelector(@selector(area))];
    [mutDict setValue:self.industry
               forKey:NSStringFromSelector(@selector(industry))];
    [mutDict setValue:self.userID
               forKey:NSStringFromSelector(@selector(userID))];
    [mutDict setValue:self.gender
               forKey:NSStringFromSelector(@selector(gender))];
    [mutDict setValue:self.mobile
               forKey:NSStringFromSelector(@selector(mobile))];
    [mutDict setValue:self.email
               forKey:NSStringFromSelector(@selector(email))];
    [mutDict setValue:self.avatarURL
               forKey:NSStringFromSelector(@selector(avatarURL))];
    [mutDict setValue:self.userDescription
               forKey:NSStringFromSelector(@selector(userDescription))];
    [mutDict setValue:self.userDecoration
               forKey:NSStringFromSelector(@selector(userDecoration))];
    return mutDict;
}

- (NSDictionary *)toKeyChainDictionary
{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [mutDict setValue:@(self.isToutiao)
               forKey:NSStringFromSelector(@selector(isToutiao))];
    [mutDict setValue:self.token
               forKey:NSStringFromSelector(@selector(token))];
    [mutDict setValue:self.sessionKey
               forKey:NSStringFromSelector(@selector(sessionKey))];
    
    [mutDict setValue:@(self.newUser)
               forKey:NSStringFromSelector(@selector(newUser))];
    [mutDict setValue:self.name
               forKey:NSStringFromSelector(@selector(name))];
    [mutDict setValue:self.birthday
               forKey:NSStringFromSelector(@selector(birthday))];
    [mutDict setValue:self.area
               forKey:NSStringFromSelector(@selector(area))];
    [mutDict setValue:self.industry
               forKey:NSStringFromSelector(@selector(industry))];
    [mutDict setValue:self.userID
               forKey:NSStringFromSelector(@selector(userID))];
    [mutDict setValue:self.mediaID
               forKey:NSStringFromSelector(@selector(mediaID))];
    [mutDict setValue:[self.media toDictionary]
               forKey:NSStringFromSelector(@selector(media))];
    [mutDict setValue:@(self.canBeFoundByPhone)
               forKey:NSStringFromSelector(@selector(canBeFoundByPhone))];
    [mutDict setValue:@(self.userPrivacyExtend)
               forKey:NSStringFromSelector(@selector(userPrivacyExtend))];
    [mutDict setValue:@(self.shareToRepost)
               forKey:NSStringFromSelector(@selector(shareToRepost))];
    [mutDict setValue:self.gender
               forKey:NSStringFromSelector(@selector(gender))];
    [mutDict setValue:self.screenName
               forKey:NSStringFromSelector(@selector(screenName))];
    [mutDict setValue:self.mobile
               forKey:NSStringFromSelector(@selector(mobile))];
    [mutDict setValue:self.email
               forKey:NSStringFromSelector(@selector(email))];
    [mutDict setValue:self.avatarURL
               forKey:NSStringFromSelector(@selector(avatarURL))];
    [mutDict setValue:self.avatarLargeURL
               forKey:NSStringFromSelector(@selector(avatarLargeURL))];
    [mutDict setValue:self.bgImgURL
               forKey:NSStringFromSelector(@selector(bgImgURL))];
    [mutDict setValue:self.userDescription
               forKey:NSStringFromSelector(@selector(userDescription))];
    [mutDict setValue:self.userDecoration
               forKey:NSStringFromSelector(@selector(userDecoration))];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [mutDict setValue:@(self.userVerified)
               forKey:NSStringFromSelector(@selector(userVerified))];
#pragma clang diagnostic pop
    [mutDict setValue:self.userAuthInfo
               forKey:NSStringFromSelector(@selector(userAuthInfo))];
    
    [mutDict setValue:self.safe
               forKey:NSStringFromSelector(@selector(safe))];
    
    [mutDict setValue:@(self.followersCount)
               forKey:NSStringFromSelector(@selector(followersCount))];
    [mutDict setValue:@(self.followingsCount)
               forKey:NSStringFromSelector(@selector(followingsCount))];
    [mutDict setValue:@(self.visitCountRecent)
               forKey:NSStringFromSelector(@selector(visitCountRecent))];
    [mutDict setValue:@(self.momentsCount)
               forKey:NSStringFromSelector(@selector(momentsCount))];
    
    return mutDict;
}

#pragma mark - observer helper

- (void)checkAndAvoidHittingTheObservedValues
{
    if ([self.observedKeyPaths count] > 0) {
        [self tta_removeObservers];
    }
}

/**
 *  需要手动添加
 */
- (void)observeValueDidChangeHandler:(void (^)(NSString *keyPath, NSDictionary *change))observedBlock
{
    [self tta_addObservers];
    [self tta_setObserveValueChangedHandler:observedBlock];
}

//- (NSMutableArray<NSString *> *)observedKeyPaths
//{
//    id object = objc_getAssociatedObject(self, _cmd);
//    if ([object isKindOfClass:[NSArray class]]) {
//        return object;
//    }
//
//    object = [NSMutableArray array];
//    [self setObservedKeyPaths:object];
//
//    return object;
//}
//
//- (void)setObservedKeyPaths:(NSMutableArray<NSString *> *)observedKeyPaths
//{
//    objc_setAssociatedObject(self, @selector(observedKeyPaths), observedKeyPaths, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

- (void)tta_addObservers
{
    NSSet<NSString *> *observedKeyPathSet = [self.class tta_observedKeyPaths];
    [observedKeyPathSet enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        @synchronized (self.observedKeyPaths) {
            @try {
                if (![self.observedKeyPaths containsObject:obj]) {
                    [self addObserver:self forKeyPath:obj options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
                    
                    [self.observedKeyPaths addObject:obj];
                }
            } @catch (NSException *exception) {
                [self.observedKeyPaths removeObject:obj];
            } @finally {
                
            }
        }
    }];
}

- (void)tta_removeObservers
{
    @synchronized (self.observedKeyPaths) {
        [self.observedKeyPaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @try {
                [self removeObserver:self forKeyPath:obj context:nil];
            } @catch (NSException *exception) {
            } @finally {
            }
        }];
        [self.observedKeyPaths removeAllObjects];
    }
}

static void *kTTAccountObserveUserValueChangedHandlerKey = &kTTAccountObserveUserValueChangedHandlerKey;

- (void)tta_setObserveValueChangedHandler:(void (^)(NSString *keyPath, NSDictionary *change))observedBlock
{
    objc_setAssociatedObject(self, kTTAccountObserveUserValueChangedHandlerKey, observedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(NSString *keyPath, NSDictionary *change))tta_observeValueChangedHandler
{
    return objc_getAssociatedObject(self, kTTAccountObserveUserValueChangedHandlerKey);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([self.observedKeyPaths containsObject:keyPath] && object == self) {
        void (^tta_valueChangedBlock)(NSString *keyPath, NSDictionary *change) = [self tta_observeValueChangedHandler];
        if (tta_valueChangedBlock) tta_valueChangedBlock(keyPath, change);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - keypaths

+ (NSSet<NSString *> *)tta_observedKeyPaths
{
    return [NSSet setWithArray:@[
                                 NSStringFromSelector(@selector(isToutiao)),
                                 NSStringFromSelector(@selector(token)),
                                 NSStringFromSelector(@selector(newUser)),
                                 NSStringFromSelector(@selector(name)),
                                 NSStringFromSelector(@selector(birthday)),
                                 NSStringFromSelector(@selector(area)),
                                 NSStringFromSelector(@selector(industry)),
                                 NSStringFromSelector(@selector(sessionKey)),
                                 NSStringFromSelector(@selector(userID)),
                                 NSStringFromSelector(@selector(mediaID)),
                                 NSStringFromSelector(@selector(media)),
                                 NSStringFromSelector(@selector(canBeFoundByPhone)),
                                 NSStringFromSelector(@selector(userPrivacyExtend)),
                                 NSStringFromSelector(@selector(shareToRepost)),
                                 NSStringFromSelector(@selector(gender)),
                                 NSStringFromSelector(@selector(screenName)),
                                 NSStringFromSelector(@selector(mobile)),
                                 NSStringFromSelector(@selector(email)),
                                 NSStringFromSelector(@selector(avatarURL)),
                                 NSStringFromSelector(@selector(avatarLargeURL)),
                                 NSStringFromSelector(@selector(bgImgURL)),
                                 NSStringFromSelector(@selector(userDescription)),
                                 NSStringFromSelector(@selector(userDecoration)),
                                 NSStringFromSelector(@selector(userVerified)),
                                 NSStringFromSelector(@selector(verifiedReason)),
                                 NSStringFromSelector(@selector(verifiedContent)),
                                 NSStringFromSelector(@selector(userAuthInfo)),
                                 NSStringFromSelector(@selector(verifiedAgency)),
                                 NSStringFromSelector(@selector(recommendReason)),
                                 NSStringFromSelector(@selector(reasonType)),
                                 NSStringFromSelector(@selector(point)),
                                 NSStringFromSelector(@selector(shareURL)),
                                 NSStringFromSelector(@selector(safe)),
                                 NSStringFromSelector(@selector(isBlocking)),
                                 NSStringFromSelector(@selector(isBlocked)),
                                 NSStringFromSelector(@selector(isFollowing)),
                                 NSStringFromSelector(@selector(isFollowed)),
                                 NSStringFromSelector(@selector(isRecommendAllowed)),
                                 NSStringFromSelector(@selector(recommendHintMessage)),
                                 NSStringFromSelector(@selector(followersCount)),
                                 NSStringFromSelector(@selector(followingsCount)),
                                 NSStringFromSelector(@selector(visitCountRecent)),
                                 NSStringFromSelector(@selector(momentsCount)),
                                 NSStringFromSelector(@selector(connects)),
                                 NSStringFromSelector(@selector(auditInfoSet))
                                 ]];
}

@end



#pragma mark - TTAccountImageEntity

@implementation TTAccountImageEntity (tta_internal)

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    if ((self = [super init])) {
        if ([dict valueForKey:NSStringFromSelector(@selector(web_uri))]) {
            self.web_uri = [dict valueForKey:NSStringFromSelector(@selector(web_uri))];
        }
        
        if ([dict valueForKey:NSStringFromSelector(@selector(url_list))]) {
            NSDictionary *urlListDict = [dict valueForKey:NSStringFromSelector(@selector(url_list))];
            if (urlListDict && [urlListDict isKindOfClass:[NSDictionary class]]) {
                NSString *originUrl, *thumbUrl, *mediumUrl;
                if ([dict valueForKey:NSStringFromSelector(@selector(origin_url))]) {
                    originUrl = [dict valueForKey:NSStringFromSelector(@selector(origin_url))];
                }
                if ([dict valueForKey:NSStringFromSelector(@selector(thumb_url))]) {
                    thumbUrl = [dict valueForKey:NSStringFromSelector(@selector(thumb_url))];
                }
                if ([dict valueForKey:NSStringFromSelector(@selector(medium_url))]) {
                    mediumUrl = [dict valueForKey:NSStringFromSelector(@selector(medium_url))];
                }
                
                if (originUrl || thumbUrl || mediumUrl) {
                    TTAccountImageListEntity *imageUrlList = [TTAccountImageListEntity new];
                    imageUrlList.origin_url = originUrl;
                    imageUrlList.thumb_url  = thumbUrl;
                    imageUrlList.medium_url = mediumUrl;
                    
                    self.url_list = imageUrlList;
                }
            }
        }
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [mutDict setValue:self.web_uri
               forKey:NSStringFromSelector(@selector(web_uri))];
    if (self.url_list) {
        NSMutableDictionary *mutUrlListDict = [NSMutableDictionary dictionary];
        [mutUrlListDict setValue:self.url_list.origin_url
                          forKey:NSStringFromSelector(@selector(origin_url))];
        [mutUrlListDict setValue:self.url_list.thumb_url
                          forKey:NSStringFromSelector(@selector(thumb_url))];
        [mutUrlListDict setValue:self.url_list.medium_url
                          forKey:NSStringFromSelector(@selector(medium_url))];
        
        [mutDict setValue:[mutUrlListDict copy]
                   forKey:NSStringFromSelector(@selector(url_list))];
    }
    return [mutDict copy];
}

@end
