//
//  TTAccountUserEntity.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/5/16.
//  Copyright © 2016 com.bytedance.news. All rights reserved.
//

#import "TTAccountUserEntity.h"
#import "TTAccountUserEntity_Priv.h"



#pragma mark - TTAccountMediaUserEntity

@implementation TTAccountMediaUserEntity

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    TTAccountMediaUserEntity *copiedInst = [[[self class] allocWithZone:zone] init];
    copiedInst.mediaID = [self.mediaID copyWithZone:zone];
    copiedInst.name    = [self.name copyWithZone:zone];
    copiedInst.avatarURL = [self.avatarURL copyWithZone:zone];
    copiedInst.userVerified = self.userVerified;
    copiedInst.displayAppOcrEntrance = self.displayAppOcrEntrance;
    return copiedInst;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        self.mediaID = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(mediaID))];
        self.name    = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(name))];
        self.avatarURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(avatarURL))];
        self.userVerified = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userVerified))];
        self.displayAppOcrEntrance = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(displayAppOcrEntrance))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.mediaID
                  forKey:NSStringFromSelector(@selector(mediaID))];
    [aCoder encodeObject:self.name
                  forKey:NSStringFromSelector(@selector(name))];
    [aCoder encodeObject:self.avatarURL
                  forKey:NSStringFromSelector(@selector(avatarURL))];
    [aCoder encodeObject:@(self.userVerified)
                  forKey:NSStringFromSelector(@selector(userVerified))];
    [aCoder encodeObject:@(self.displayAppOcrEntrance)
                  forKey:NSStringFromSelector(@selector(displayAppOcrEntrance))];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [mutDict setValue:self.mediaID
               forKey:NSStringFromSelector(@selector(mediaID))];
    [mutDict setValue:self.name
               forKey:NSStringFromSelector(@selector(name))];
    [mutDict setValue:self.avatarURL
               forKey:NSStringFromSelector(@selector(avatarURL))];
    [mutDict setValue:@(self.userVerified)
               forKey:NSStringFromSelector(@selector(userVerified))];
    [mutDict setValue:@(self.displayAppOcrEntrance)
               forKey:NSStringFromSelector(@selector(displayAppOcrEntrance))];
    return [mutDict copy];
}

//- (NSDictionary *)toOriginalDictionary
//{
//    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
//    [mutDict setValue:self.mediaID
//               forKey:@"id"];
//    [mutDict setValue:self.mediaID
//               forKey:@"entry_id"];
//    [mutDict setValue:self.name
//               forKey:NSStringFromSelector(@selector(name))];
//    [mutDict setValue:self.avatarURL
//               forKey:@"avatar_url"];
//    [mutDict setValue:@(self.userVerified)
//               forKey:@"user_verified"];
//    [mutDict setValue:@(self.displayAppOcrEntrance)
//               forKey:@"display_app_ocr_entrance"];
//    return [mutDict copy];
//}

@end




#pragma mark - TTAccountPlatformEntity
/**
 *  绑定的第三方账号信息
 */
@implementation TTAccountPlatformEntity

- (instancetype)copyWithZone:(NSZone *)zone
{
    TTAccountPlatformEntity *copiedInst = [[[self class] allocWithZone:zone] init];
    copiedInst.userID             = [self.userID copyWithZone:zone];
    copiedInst.platformScreenName = [self.platformScreenName copyWithZone:zone];
    copiedInst.profileImageURL    = [self.profileImageURL copyWithZone:zone];
    copiedInst.platform           = [self.platform copyWithZone:zone];
    copiedInst.platformUID        = [self.platformUID copyWithZone:zone];
    copiedInst.expiredIn          = [self.expiredIn copyWithZone:zone];
    copiedInst.expiredTime        = [self.expiredTime copyWithZone:zone];
    return copiedInst;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        self.userID             = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userID))];
        self.platformScreenName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(platformScreenName))];
        self.profileImageURL    = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(profileImageURL))];
        self.platform           = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(platform))];
        self.platformUID        = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(platformUID))];
        self.expiredIn          = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(expiredIn))];
        self.expiredTime        = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(expiredTime))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userID
                  forKey:NSStringFromSelector(@selector(userID))];
    [aCoder encodeObject:self.platformScreenName
                  forKey:NSStringFromSelector(@selector(platformScreenName))];
    [aCoder encodeObject:self.profileImageURL
                  forKey:NSStringFromSelector(@selector(profileImageURL))];
    [aCoder encodeObject:self.platform
                  forKey:NSStringFromSelector(@selector(platform))];
    [aCoder encodeObject:self.platformUID
                  forKey:NSStringFromSelector(@selector(platformUID))];
    [aCoder encodeObject:self.expiredIn
                  forKey:NSStringFromSelector(@selector(expiredIn))];
    [aCoder encodeObject:self.expiredTime
                  forKey:NSStringFromSelector(@selector(expiredTime))];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [mutDict setValue:self.userID
               forKey:NSStringFromSelector(@selector(userID))];
    [mutDict setValue:self.platformScreenName
               forKey:NSStringFromSelector(@selector(platformScreenName))];
    [mutDict setValue:self.profileImageURL
               forKey:NSStringFromSelector(@selector(profileImageURL))];
    [mutDict setValue:self.platform
               forKey:NSStringFromSelector(@selector(platform))];
    [mutDict setValue:self.platformUID
               forKey:NSStringFromSelector(@selector(platformUID))];
    [mutDict setValue:self.expiredIn
               forKey:NSStringFromSelector(@selector(expiredIn))];
    [mutDict setValue:self.expiredTime
               forKey:NSStringFromSelector(@selector(expiredTime))];
    return [mutDict copy];
}

@end



@implementation TTAccountUserEntity

- (instancetype)init
{
    if ((self = [super init])) {
        _isToutiao = NO;
        _canBeFoundByPhone = YES;
        _userPrivacyExtend = 0;
        _shareToRepost = -1;
    }
    return self;
}

- (NSString *)mediaIDString
{
    @try {
        if (self.media && self.media.mediaID) {
            return [self.media.mediaID stringValue];
        }
        return self.mediaID ? [self.mediaID stringValue] : nil;
    } @catch (NSException *exception) {
    } @finally {
    }
    return nil;
}

- (NSString *)userIDString
{
    if ([self.userID respondsToSelector:@selector(stringValue)]) {
        return [self.userID stringValue];
    } else if ([self.userID isKindOfClass:[NSString class]]) {
        return (NSString *)self.userID;
    }
    return nil;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    TTAccountUserEntity *copiedInst  = [[[self class] allocWithZone:zone] init];
    copiedInst.isToutiao        = self.isToutiao;
    copiedInst.token            = [self.token copyWithZone:zone];
    copiedInst.sessionKey       = [self.sessionKey copyWithZone:zone];
    copiedInst.newUser          = self.newUser;
    copiedInst.name             = [self.name copyWithZone:zone];
    copiedInst.birthday         = [self.birthday copyWithZone:zone];
    copiedInst.area             = [self.area copyWithZone:zone];
    copiedInst.industry         = [self.industry copyWithZone:zone];
    copiedInst.userID           = [self.userID copyWithZone:zone];
    copiedInst.mediaID          = [self.mediaID copyWithZone:zone];
    copiedInst.media            = [self.media copyWithZone:zone];
    copiedInst.canBeFoundByPhone= self.canBeFoundByPhone;
    copiedInst.userPrivacyExtend= self.userPrivacyExtend;
    copiedInst.shareToRepost    = self.shareToRepost;
    copiedInst.gender           = [self.gender copyWithZone:zone];
    copiedInst.screenName       = [self.screenName copyWithZone:zone];
    copiedInst.mobile           = [self.mobile copyWithZone:zone];
    copiedInst.email            = [self.email copyWithZone:zone];
    copiedInst.avatarURL        = [self.avatarURL copyWithZone:zone];
    copiedInst.avatarLargeURL   = [self.avatarLargeURL copyWithZone:zone];
    copiedInst.bgImgURL         = [self.bgImgURL copyWithZone:zone];
    copiedInst.userDescription  = [self.userDescription copyWithZone:zone];
    copiedInst.userDecoration  = [self.userDecoration copyWithZone:zone];
    copiedInst.verifiedReason   = [self.verifiedReason copyWithZone:zone];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    copiedInst.userVerified     = self.userVerified;
    copiedInst.verifiedContent  = [self.verifiedContent copyWithZone:zone];
#pragma clang diagnostic pop
    copiedInst.userAuthInfo     = [self.userAuthInfo copyWithZone:zone];
    copiedInst.verifiedAgency   = [self.verifiedAgency copyWithZone:zone];
    copiedInst.recommendReason  = [self.recommendReason copyWithZone:zone];
    copiedInst.reasonType       = [self.reasonType copyWithZone:zone];
    copiedInst.point            = [self.point copyWithZone:zone];
    copiedInst.shareURL         = self.shareURL;
    copiedInst.safe             = self.safe;
    copiedInst.isBlocking       = self.isBlocking;
    copiedInst.isBlocked        = self.isBlocked;
    copiedInst.isFollowing      = self.isFollowing;
    copiedInst.isFollowed       = self.isFollowed;
    copiedInst.isRecommendAllowed   = self.isRecommendAllowed;
    copiedInst.recommendHintMessage = [self.recommendHintMessage copyWithZone:zone];
    copiedInst.followersCount   = self.followersCount;
    copiedInst.followingsCount  = self.followingsCount;
    copiedInst.visitCountRecent = self.visitCountRecent;
    copiedInst.connects         = [self.connects copyWithZone:zone];
    copiedInst.auditInfoSet     = [self.auditInfoSet copyWithZone:zone];
    
    return copiedInst;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        self.isToutiao       = [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(isToutiao))] boolValue];
        self.token           = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(token))];
        self.sessionKey      = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(sessionKey))];
        self.newUser         = [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(newUser))] boolValue];
        self.name            = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(name))];
        self.birthday        = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(birthday))];
        self.area            = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(area))];
        self.industry        = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(industry))];
        self.userID          = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userID))];
        self.mediaID         = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(mediaID))];
        self.media           = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(media))];
        self.canBeFoundByPhone= [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(canBeFoundByPhone))] boolValue];
        self.userPrivacyExtend= [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userPrivacyExtend))] boolValue];
        self.shareToRepost   = [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(shareToRepost))] integerValue];
        self.gender          = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(gender))];
        self.screenName      = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(screenName))];
        self.mobile          = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(mobile))];
        self.email           = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(email))];
        self.avatarURL       = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(avatarURL))];
        self.avatarLargeURL  = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(avatarLargeURL))];
        self.bgImgURL        = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(bgImgURL))];
        self.userDescription = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userDescription))];
        self.userDecoration  = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userDecoration))];
        self.verifiedReason  = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(verifiedReason))];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.userVerified    = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userVerified))];
        self.verifiedContent = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(verifiedContent))];
#pragma clang diagnostic pop
        self.userAuthInfo    = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userAuthInfo))];
        self.verifiedAgency  = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(verifiedAgency))];
        self.recommendReason = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(recommendReason))];
        self.reasonType      = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(reasonType))];
        self.point           = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(point))];
        self.shareURL        = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(shareURL))];
        self.safe            = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(safe))];
        self.isBlocking      = [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(isBlocking))] boolValue];
        self.isBlocked       = [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(isBlocked))] boolValue];
        self.isFollowing     = [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(isFollowing))] boolValue];
        self.isFollowed      = [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(isFollowed))] boolValue];
        self.isRecommendAllowed= [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(isRecommendAllowed))] boolValue];
        self.recommendHintMessage= [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(recommendHintMessage))];
        self.followersCount  = [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(followersCount))] integerValue];
        self.followingsCount = [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(followingsCount))] integerValue];
        self.visitCountRecent= [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(visitCountRecent))] integerValue];
        @try {
            self.connects    = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(connects))];
        } @catch (NSException *) {
        } @finally {
        }
        self.auditInfoSet    = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(auditInfoSet))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(self.isToutiao)
                  forKey:NSStringFromSelector(@selector(isToutiao))];
    [aCoder encodeObject:self.token
                  forKey:NSStringFromSelector(@selector(token))];
    [aCoder encodeObject:self.sessionKey
                  forKey:NSStringFromSelector(@selector(sessionKey))];
    [aCoder encodeObject:@(self.newUser)
                  forKey:NSStringFromSelector(@selector(newUser))];
    [aCoder encodeObject:self.name
                  forKey:NSStringFromSelector(@selector(name))];
    [aCoder encodeObject:self.birthday
                  forKey:NSStringFromSelector(@selector(birthday))];
    [aCoder encodeObject:self.area
                  forKey:NSStringFromSelector(@selector(area))];
    [aCoder encodeObject:self.industry
                  forKey:NSStringFromSelector(@selector(industry))];
    [aCoder encodeObject:self.userID
                  forKey:NSStringFromSelector(@selector(userID))];
    [aCoder encodeObject:self.mediaID
                  forKey:NSStringFromSelector(@selector(mediaID))];
    [aCoder encodeObject:self.media
                  forKey:NSStringFromSelector(@selector(media))];
    [aCoder encodeObject:@(self.canBeFoundByPhone)
                  forKey:NSStringFromSelector(@selector(canBeFoundByPhone))];
    [aCoder encodeObject:@(self.userPrivacyExtend)
                  forKey:NSStringFromSelector(@selector(userPrivacyExtend))];
    [aCoder encodeObject:@(self.shareToRepost)
                  forKey:NSStringFromSelector(@selector(shareToRepost))];
    [aCoder encodeObject:self.gender
                  forKey:NSStringFromSelector(@selector(gender))];
    [aCoder encodeObject:self.screenName
                  forKey:NSStringFromSelector(@selector(screenName))];
    [aCoder encodeObject:self.mobile
                  forKey:NSStringFromSelector(@selector(mobile))];
    [aCoder encodeObject:self.email
                  forKey:NSStringFromSelector(@selector(email))];
    [aCoder encodeObject:self.avatarURL
                  forKey:NSStringFromSelector(@selector(avatarURL))];
    [aCoder encodeObject:self.avatarLargeURL
                  forKey:NSStringFromSelector(@selector(avatarLargeURL))];
    [aCoder encodeObject:self.bgImgURL
                  forKey:NSStringFromSelector(@selector(bgImgURL))];
    [aCoder encodeObject:self.userDescription
                  forKey:NSStringFromSelector(@selector(userDescription))];
    [aCoder encodeObject:self.userDecoration
                  forKey:NSStringFromSelector(@selector(userDecoration))];
    [aCoder encodeObject:self.verifiedReason
                  forKey:NSStringFromSelector(@selector(verifiedReason))];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [aCoder encodeObject:@(self.userVerified)
                  forKey:NSStringFromSelector(@selector(userVerified))];
    [aCoder encodeObject:self.verifiedContent
                  forKey:NSStringFromSelector(@selector(verifiedContent))];
#pragma clang diagnostic pop
    [aCoder encodeObject:self.userAuthInfo
                  forKey:NSStringFromSelector(@selector(userAuthInfo))];
    [aCoder encodeObject:self.verifiedAgency
                  forKey:NSStringFromSelector(@selector(verifiedAgency))];
    [aCoder encodeObject:self.recommendReason
                  forKey:NSStringFromSelector(@selector(recommendReason))];
    [aCoder encodeObject:self.reasonType
                  forKey:NSStringFromSelector(@selector(reasonType))];
    [aCoder encodeObject:self.point
                  forKey:NSStringFromSelector(@selector(point))];
    [aCoder encodeObject:self.shareURL
                  forKey:NSStringFromSelector(@selector(shareURL))];
    [aCoder encodeObject:self.safe
                  forKey:NSStringFromSelector(@selector(safe))];
    [aCoder encodeObject:@(self.isBlocking)
                  forKey:NSStringFromSelector(@selector(isBlocking))];
    [aCoder encodeObject:@(self.isBlocked)
                  forKey:NSStringFromSelector(@selector(isBlocked))];
    [aCoder encodeObject:@(self.isFollowing)
                  forKey:NSStringFromSelector(@selector(isFollowing))];
    [aCoder encodeObject:@(self.isFollowed)
                  forKey:NSStringFromSelector(@selector(isFollowed))];
    [aCoder encodeObject:@(self.isRecommendAllowed)
                  forKey:NSStringFromSelector(@selector(isRecommendAllowed))];
    [aCoder encodeObject:self.recommendHintMessage
                  forKey:NSStringFromSelector(@selector(recommendHintMessage))];
    [aCoder encodeObject:@(self.followersCount)
                  forKey:NSStringFromSelector(@selector(followersCount))];
    [aCoder encodeObject:@(self.followingsCount)
                  forKey:NSStringFromSelector(@selector(followingsCount))];
    [aCoder encodeObject:@(self.visitCountRecent)
                  forKey:NSStringFromSelector(@selector(visitCountRecent))];
    [aCoder encodeObject:self.connects
                  forKey:NSStringFromSelector(@selector(connects))];
    [aCoder encodeObject:self.auditInfoSet
                  forKey:NSStringFromSelector(@selector(auditInfoSet))];
}

- (NSDictionary *)toDictionary
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
    [mutDict setValue:self.verifiedReason
               forKey:NSStringFromSelector(@selector(verifiedReason))];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [mutDict setValue:@(self.userVerified)
               forKey:NSStringFromSelector(@selector(userVerified))];
    [mutDict setValue:self.verifiedContent
               forKey:NSStringFromSelector(@selector(verifiedContent))];
#pragma clang diagnostic pop
    [mutDict setValue:self.userAuthInfo
               forKey:NSStringFromSelector(@selector(userAuthInfo))];
    [mutDict setValue:self.verifiedAgency
               forKey:NSStringFromSelector(@selector(verifiedAgency))];
    [mutDict setValue:self.recommendReason
               forKey:NSStringFromSelector(@selector(recommendReason))];
    [mutDict setValue:self.reasonType
               forKey:NSStringFromSelector(@selector(reasonType))];
    
    [mutDict setValue:self.point
               forKey:NSStringFromSelector(@selector(point))];
    [mutDict setValue:self.shareURL
               forKey:NSStringFromSelector(@selector(shareURL))];
    [mutDict setValue:self.safe
               forKey:NSStringFromSelector(@selector(safe))];
    [mutDict setValue:@(self.isBlocking)
               forKey:NSStringFromSelector(@selector(isBlocking))];
    [mutDict setValue:@(self.isBlocked)
               forKey:NSStringFromSelector(@selector(isBlocked))];
    [mutDict setValue:@(self.isFollowing)
               forKey:NSStringFromSelector(@selector(isFollowing))];
    [mutDict setValue:@(self.isFollowed)
               forKey:NSStringFromSelector(@selector(isFollowed))];
    [mutDict setValue:@(self.isRecommendAllowed)
               forKey:NSStringFromSelector(@selector(isRecommendAllowed))];
    [mutDict setValue:self.recommendHintMessage
               forKey:NSStringFromSelector(@selector(recommendHintMessage))];
    [mutDict setValue:@(self.followersCount)
               forKey:NSStringFromSelector(@selector(followersCount))];
    [mutDict setValue:@(self.followingsCount)
               forKey:NSStringFromSelector(@selector(followingsCount))];
    [mutDict setValue:@(self.visitCountRecent)
               forKey:NSStringFromSelector(@selector(visitCountRecent))];
    [mutDict setValue:@(self.momentsCount)
               forKey:NSStringFromSelector(@selector(momentsCount))];
    
    if ([self.connects count] > 0) {
        NSMutableArray<NSDictionary *> *thirdAccounts = [NSMutableArray array];
        [self.connects enumerateObjectsUsingBlock:^(TTAccountPlatformEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *dict = [obj toDictionary];
            if (dict) [thirdAccounts addObject:dict];
        }];
        [mutDict setValue:thirdAccounts
                   forKey:NSStringFromSelector(@selector(connects))];
    }
    
    [mutDict setValue:[self.auditInfoSet toDictionary]
               forKey:NSStringFromSelector(@selector(auditInfoSet))];
    
    return [mutDict copy];
}

#pragma mark - Setter/Getter

- (NSMutableArray<NSString *> *)observedKeyPaths
{
    if (!_observedKeyPaths) {
        _observedKeyPaths = [NSMutableArray array];
    }
    return _observedKeyPaths;
}

@end



#pragma mark - TTAccountUserAuditSet

@implementation TTAccountUserAuditEntity

- (instancetype)copyWithZone:(NSZone *)zone
{
    TTAccountUserAuditEntity *copiedInst = [[[self class] allocWithZone:zone] init];
    copiedInst.name            = [self.name copyWithZone:zone];
    copiedInst.userDescription = [self.userDescription copyWithZone:zone];
    copiedInst.avatarURL       = [self.avatarURL copyWithZone:zone];
    
    copiedInst.gender          = [self.gender copyWithZone:zone];
    copiedInst.birthday        = [self.birthday copyWithZone:zone];
    copiedInst.area            = [self.area copyWithZone:zone];
    copiedInst.industry        = [self.industry copyWithZone:zone];
    
    return copiedInst;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        self.name            = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(name))];
        self.userDescription = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userDescription))];
        self.avatarURL       = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(avatarURL))];
        
        self.gender          = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(gender))];
        self.birthday        = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(birthday))];
        self.area            = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(area))];
        self.industry        = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(industry))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name
                  forKey:NSStringFromSelector(@selector(name))];
    [aCoder encodeObject:self.userDescription
                  forKey:NSStringFromSelector(@selector(userDescription))];
    [aCoder encodeObject:self.avatarURL
                  forKey:NSStringFromSelector(@selector(avatarURL))];
    
    [aCoder encodeObject:self.gender
                  forKey:NSStringFromSelector(@selector(gender))];
    [aCoder encodeObject:self.birthday
                  forKey:NSStringFromSelector(@selector(birthday))];
    [aCoder encodeObject:self.area
                  forKey:NSStringFromSelector(@selector(area))];
    [aCoder encodeObject:self.industry
                  forKey:NSStringFromSelector(@selector(industry))];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [mutDict setValue:self.name
               forKey:NSStringFromSelector(@selector(name))];
    [mutDict setValue:self.userDescription
               forKey:NSStringFromSelector(@selector(userDescription))];
    [mutDict setValue:self.avatarURL
               forKey:NSStringFromSelector(@selector(avatarURL))];
    
    [mutDict setValue:self.gender
               forKey:NSStringFromSelector(@selector(gender))];
    [mutDict setValue:self.birthday
               forKey:NSStringFromSelector(@selector(birthday))];
    [mutDict setValue:self.area
               forKey:NSStringFromSelector(@selector(area))];
    [mutDict setValue:self.industry
               forKey:NSStringFromSelector(@selector(industry))];
    return [mutDict copy];
}

- (NSDictionary *)toOriginalDictionary
{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [mutDict setValue:self.name
               forKey:NSStringFromSelector(@selector(name))];
    [mutDict setValue:self.userDescription
               forKey:@"description"];
    [mutDict setValue:self.avatarURL
               forKey:@"avatar_url"];

    [mutDict setValue:self.gender
               forKey:NSStringFromSelector(@selector(gender))];
    [mutDict setValue:self.birthday
               forKey:NSStringFromSelector(@selector(birthday))];
    [mutDict setValue:self.area
               forKey:NSStringFromSelector(@selector(area))];
    [mutDict setValue:self.industry
               forKey:NSStringFromSelector(@selector(industry))];

    return [mutDict copy];
}

@end

@implementation TTAccountVerifiedUserAuditEntity

- (NSDictionary *)toOriginalDictionary
{
    NSDictionary *auditInfoDict = [super toOriginalDictionary];
    NSMutableDictionary *mutDict = nil;
    if ([auditInfoDict count] > 0) {
        mutDict = [NSMutableDictionary dictionary];
        [mutDict setValue:auditInfoDict forKey:@"audit_info"];
    }
    return [mutDict copy];
}

@end

@implementation TTAccountMediaUserAuditEntity

- (instancetype)copyWithZone:(NSZone *)zone
{
    TTAccountMediaUserAuditEntity *copiedInst = [super copyWithZone:zone];
    copiedInst.auditing    = self.auditing;
    copiedInst.expiredTime = [self.expiredTime copyWithZone:zone];
    return copiedInst;
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        self.auditing    = [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(auditing))] boolValue];
        self.expiredTime = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(expiredTime))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:@(self.auditing)
                  forKey:NSStringFromSelector(@selector(auditing))];
    [aCoder encodeObject:self.expiredTime
                  forKey:NSStringFromSelector(@selector(expiredTime))];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *mutDict = [[NSMutableDictionary alloc] initWithDictionary:[super toDictionary]];
    if (mutDict) {
        [mutDict setValue:@(self.auditing)
                   forKey:NSStringFromSelector(@selector(auditing))];
        [mutDict setValue:self.expiredTime
                   forKey:NSStringFromSelector(@selector(expiredTime))];
    }
    return [mutDict copy];
}

- (NSDictionary *)toOriginalDictionary
{
    NSDictionary *auditInfoDict = [super toOriginalDictionary];
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    if ([auditInfoDict count] > 0) {
        [mutDict setValue:auditInfoDict forKey:@"audit_info"];
    }
    
    [mutDict setValue:@(self.auditing)
               forKey:@"is_auditing"];
    [mutDict setValue:self.expiredTime
               forKey:@"audit_expire_time"];
    
    return [mutDict copy];
}

@end

@implementation TTAccountUserAuditSet

- (instancetype)copyWithZone:(NSZone *)zone
{
    TTAccountUserAuditSet *copiedInst  = [[[self class] allocWithZone:zone] init];
    copiedInst.currentUserEntity       = [self.currentUserEntity copyWithZone:zone];
    copiedInst.verifiedUserAuditEntity = [self.verifiedUserAuditEntity copyWithZone:zone];
    copiedInst.pgcUserAuditEntity      = [self.pgcUserAuditEntity copyWithZone:zone];
    return copiedInst;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        self.currentUserEntity       = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(currentUserEntity))];
        self.verifiedUserAuditEntity = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(verifiedUserAuditEntity))];
        self.pgcUserAuditEntity      = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(pgcUserAuditEntity))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.currentUserEntity
                  forKey:NSStringFromSelector(@selector(currentUserEntity))];
    [aCoder encodeObject:self.verifiedUserAuditEntity
                  forKey:NSStringFromSelector(@selector(verifiedUserAuditEntity))];
    [aCoder encodeObject:self.pgcUserAuditEntity
                  forKey:NSStringFromSelector(@selector(pgcUserAuditEntity))];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *mutDict = [NSMutableDictionary new];
    [mutDict setValue:[self.currentUserEntity toDictionary]
               forKey:NSStringFromSelector(@selector(currentUserEntity))];
    [mutDict setValue:[self.verifiedUserAuditEntity toDictionary]
               forKey:NSStringFromSelector(@selector(verifiedUserAuditEntity))];
    [mutDict setValue:[self.pgcUserAuditEntity toDictionary]
               forKey:NSStringFromSelector(@selector(pgcUserAuditEntity))];
    return [mutDict copy];
}

- (NSDictionary *)toOriginalDictionary
{
    NSMutableDictionary *mutDict = [NSMutableDictionary new];
    [mutDict setValue:[self.currentUserEntity toOriginalDictionary]
               forKey:@"current_info"];
    [mutDict setValue:[self.verifiedUserAuditEntity toOriginalDictionary]
               forKey:@"verified_audit_info"];
    [mutDict setValue:[self.pgcUserAuditEntity toOriginalDictionary]
               forKey:@"pgc_audit_info"];
    return [mutDict copy];
}

@end



#pragma mark - TTAccountImageEntity

@implementation TTAccountImageListEntity

@end

@implementation TTAccountImageEntity

@end
