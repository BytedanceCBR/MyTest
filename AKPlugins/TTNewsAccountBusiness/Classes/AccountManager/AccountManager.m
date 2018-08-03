//
//  AccountManager.m
//  ShareOne
//
//  Created by Dianwei Hu on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccountManager.h"
#import "TTAccountManager+HTSAccountBridge.h"
#import "AccountKeyChainManager.h"
#import "SSCookieManager.h"
#import <TTSandBoxHelper.h>



#define kIsLoginKey                @"kIsLoginKey"

#define SNS_NEW_PLATFORM_KEY       @"share_one_account_is_new_platform"
#define SNS_NEW_USER_KEY           @"share_one_account_is_new_user"
#define SNS_USER_ID                @"SNS_USER_ID"
#define SNS_NAME_KEY               @"SNS_NAME_KEY"
#define SNS_AVATAR_KEY             @"SNS_AVATAR_KEY"
#define SNS_LARGE_AVATAR_KEY       @"SNS_LARGE_AVATAR_KEY"
#define SNS_BG_IMAGE_URL_KEY       @"SNS_BG_IMAGE_URL_KEY"
#define SNS_USER_DESCRIPTION_KEY   @"SNS_USER_DESCRIPTION_KEY"
#define SNS_USER_SHOW_INFO_KEY     @"SNS_USER_SHOW_INFO_KEY"
#define SNS_USER_AUTH_INFO_KEY     @"SNS_USER_AUTH_INFO_KEY"
#define SNS_GENDER_KEY             @"SNS_GENDER_KEY"
#define SNS_RECOMMEND_ALLOWED_KEY  @"SNS_RECOMMEND_ALLOWED_KEY"
#define SNS_RECOMMEND_HINT_KEY     @"SNS_RECOMMEND_HINT_KEY"

#define SNS_USER_MEDIA_ID_KEY         @"SNS_USER_MEDIA_ID_KEY"
#define SNS_USER_FOLLOWING_STRING_KEY @"SNS_USER_FOLLOWING_STRING_KEY"
#define SNS_USER_FOLLOWING_COUNT_KEY  @"SNS_USER_FOLLOWING_COUNT_KEY"
#define SNS_USER_FOLLOWER_STRING_KEY  @"SNS_USER_FOLLOWER_STRING_KEY"
#define SNS_USER_FOLLOWER_COUNT_KEY   @"SNS_USER_FOLLOWER_COUNT_KEY"
#define SNS_USER_VISITOR_STRING_KEY   @"SNS_USER_VISITOR_STRING_KEY"
#define SNS_USER_VISITOR_COUNT_KEY    @"SNS_USER_VISITOR_COUNT_KEY"
#define SNS_USER_MOMENT_STRING_KEY    @"SNS_USER_MOMENT_STRING_KEY"
#define SNS_USER_MOMENT_COUNT_KEY     @"SNS_USER_MOMENT_COUNT_KEY"


#define kHasAssignedInfoFromKeychain      @"kHasAssignedInfoFromKeychain"


NSString * const ArticleDraftMobileCacheKey = @"draft.mobile";

@implementation AccountManager

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

static AccountManager *sharedManager = nil;

+ (AccountManager *)sharedManager
{
    @synchronized(self) {
        if (sharedManager == nil) {
            sharedManager = [[self alloc] init];
        }
    }
    return sharedManager;
}

- (void)cleanAccounts
{
    if ([self isLogin]) {
        self.isLogin = NO;
    }
    
    [self.myUser clear];
    self.myUser = nil;
    self.userID = nil;
    self.mediaID = nil;
    self.userName = nil;
    self.userDescription = nil;
    self.isRecommendAllowed = NO;
    self.recommendHintMessage = nil;
    self.avatarURLString = nil;
    self.momentString = nil;
    self.followerString = nil;
    self.followingString = nil;
    self.visitorString = nil;
    self.showInfo = nil;
    self.userAuthInfo = nil;
    
    [self setMediaID:@""];
    [self setFollowingCount:0];
    [self setFollowerCount:0];
    [self setVisitorCount:0];
    
    //情况所有域名下的sessionid
    [SSCookieManager setSessionIDToCookie:nil];
}


#pragma mark - login status and user

- (BOOL)isLogin
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kIsLoginKey] boolValue];
}

- (void)setIsLogin:(BOOL)isLogin
{
    [self setIsLogin:isLogin getStates:YES];
}

- (void)setIsLogin:(BOOL)isLogin getStates:(BOOL)getStates
{
    [self setIsLogin:isLogin getStates:getStates displayExpirationError:YES];
}

- (void)setIsLogin:(BOOL)isLogin getStates:(BOOL)getStates displayExpirationError:(BOOL)display
{
    [[NSUserDefaults standardUserDefaults] setBool:isLogin forKey:kIsLoginKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (!isLogin) {
        [self cleanAccounts];
    } else if (getStates) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@YES, @"logout_when_fail", @YES, @"handle_exception", nil];
        
        [TTAccountManager startGetAccountStatus:display context:userInfo];
    }
}

- (NSNumber *)isNewPlatform
{
    NSNumber *isNew = [[NSUserDefaults standardUserDefaults] objectForKey:SNS_NEW_PLATFORM_KEY];
    if ([isNew isKindOfClass:[NSString class]]) {
        isNew = @([isNew integerValue]);
    }
    return isNew;
}

- (void)setIsNewPlatform:(NSNumber *)isNewPlatform_
{
    if ([isNewPlatform_ isKindOfClass:[NSString class]]) {
        isNewPlatform_ = @([isNewPlatform_ integerValue]);
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:isNewPlatform_ forKey:SNS_NEW_PLATFORM_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSNumber *)isNewUser
{
    NSNumber *isNew = [[NSUserDefaults standardUserDefaults] objectForKey:SNS_NEW_USER_KEY];
    if ([isNew isKindOfClass:[NSString class]]) {
        isNew = @([isNew integerValue]);
    }
    return isNew;
}

- (void)setIsNewUser:(NSNumber *)isNewUser_
{
    if ([isNewUser_ isKindOfClass:[NSString class]]) {
        isNewUser_ = @([isNewUser_ integerValue]);
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:isNewUser_ forKey:SNS_NEW_USER_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)userID
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SNS_USER_ID] == nil) {
        return nil;
    } else {
        return [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:SNS_USER_ID]];
    }
}

- (void)setUserID:(NSString *)userID_
{
    if (![self.userID isEqualToString:userID_]) {
        [[NSUserDefaults standardUserDefaults] setObject:userID_ forKey:SNS_USER_ID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)userName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:SNS_NAME_KEY];
}

- (void)setUserName:(NSString *)userName
{
    if (![self.userName isEqualToString:userName]) {
        [[NSUserDefaults standardUserDefaults] setObject:userName forKey:SNS_NAME_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        _myUser.name = userName;
    }
}

- (NSString *)avatarURLString
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:SNS_AVATAR_KEY];
}

- (void)setAvatarURLString:(NSString *)avatarURLString
{
    if (![self.avatarURLString isEqualToString:avatarURLString]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:avatarURLString forKey:SNS_AVATAR_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        _myUser.avatarURLString = avatarURLString;
    }
}

- (NSString *)avatarLargeURLString
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:SNS_LARGE_AVATAR_KEY];
}

- (void)setAvatarLargeURLString:(NSString *)avatarURLString
{
    if (![self.avatarLargeURLString isEqualToString:avatarURLString]) {
        [[NSUserDefaults standardUserDefaults] setObject:avatarURLString forKey:SNS_LARGE_AVATAR_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        _myUser.avatarLargeURLString = avatarURLString;
    }
}

- (NSString *)bgImageURLString
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:SNS_BG_IMAGE_URL_KEY];
}

- (void)setBgImageURLString:(NSString *)bgImgURLString
{
    if (![self.bgImageURLString isEqualToString:bgImgURLString]) {
        [[NSUserDefaults standardUserDefaults] setObject:bgImgURLString forKey:SNS_BG_IMAGE_URL_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        _myUser.bgImageURLString = bgImgURLString;
    }
}

- (void)setUserDescription:(NSString *)userDescription
{
    if (![self.userDescription isEqualToString:userDescription]) {
        [[NSUserDefaults standardUserDefaults] setObject:userDescription forKey:SNS_USER_DESCRIPTION_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        _myUser.userDescription = userDescription;
    }
}

- (void)setUserAuthInfo:(NSString *)userAuthInfo
{
    if (![self.userAuthInfo isEqualToString:userAuthInfo]) {
        [[NSUserDefaults standardUserDefaults] setObject:userAuthInfo forKey:SNS_USER_AUTH_INFO_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)userAuthInfo
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SNS_USER_AUTH_INFO_KEY];
}

- (void)setMediaID:(NSString *)mediaId
{
    if ([mediaId isKindOfClass:[NSNumber class]]) {
        mediaId = [NSString stringWithFormat:@"%@", mediaId];
    }
    if (mediaId != self.mediaID) {
        [[NSUserDefaults standardUserDefaults] setObject:mediaId forKey:SNS_USER_MEDIA_ID_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)mediaID
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SNS_USER_MEDIA_ID_KEY];
}

- (void)setShowInfo:(NSString *)showInfo
{
    if (showInfo != self.showInfo) {
        _myUser.showInfo = showInfo;
        [[NSUserDefaults standardUserDefaults] setObject:showInfo forKey:SNS_USER_SHOW_INFO_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)showInfo
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SNS_USER_SHOW_INFO_KEY];
}

- (void)setFollowingString:(NSString *)followingString
{
    if (followingString != self.followingString) {
        [[NSUserDefaults standardUserDefaults] setObject:followingString forKey:SNS_USER_FOLLOWING_STRING_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)followingString
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SNS_USER_FOLLOWING_STRING_KEY];
}

- (void)setFollowingCount:(long long)count
{
    if (self.followingCount != count) {
        [[NSUserDefaults standardUserDefaults] setObject:@(count) forKey:SNS_USER_FOLLOWING_COUNT_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (long long)followingCount
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:SNS_USER_FOLLOWING_COUNT_KEY] longLongValue];
}

- (void)setFollowerString:(NSString *)followerString
{
    if (followerString != self.followerString) {
        [[NSUserDefaults standardUserDefaults] setObject:followerString forKey:SNS_USER_FOLLOWER_STRING_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)followerString
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SNS_USER_FOLLOWER_STRING_KEY];
}

- (void)setFollowerCount:(long long)count
{
    if (self.followerCount != count) {
        [[NSUserDefaults standardUserDefaults] setObject:@(count) forKey:SNS_USER_FOLLOWER_COUNT_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (long long)followerCount
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:SNS_USER_FOLLOWER_COUNT_KEY] longLongValue];
}

- (void)setVisitorString:(NSString *)visitorString
{
    if (visitorString != self.visitorString) {
        [[NSUserDefaults standardUserDefaults] setObject:visitorString forKey:SNS_USER_VISITOR_STRING_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)visitorString
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SNS_USER_VISITOR_STRING_KEY];
}

- (void)setVisitorCount:(long long)count
{
    if (self.visitorCount != count) {
        [[NSUserDefaults standardUserDefaults] setObject:@(count) forKey:SNS_USER_VISITOR_COUNT_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (long long)visitorCount
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:SNS_USER_VISITOR_COUNT_KEY] longLongValue];
}

- (void)setMomentString:(NSString *)momentString
{
    if (momentString != self.momentString) {
        [[NSUserDefaults standardUserDefaults] setObject:momentString forKey:SNS_USER_MOMENT_STRING_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)momentString
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SNS_USER_MOMENT_STRING_KEY];
}

- (void)setMomentCount:(long long)count
{
    if (self.momentCount != count) {
        [[NSUserDefaults standardUserDefaults] setObject:@(count) forKey:SNS_USER_MOMENT_COUNT_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (long long)momentCount
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:SNS_USER_MOMENT_COUNT_KEY] longLongValue];
}

- (NSString *)userDescription
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:SNS_USER_DESCRIPTION_KEY];
}

- (NSString *)userGender
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:SNS_GENDER_KEY];
}

- (void)setUserGender:(NSString * )userGender
{
    //加一个类型判断保护
    NSString *finalStr = nil;
    if ([userGender isKindOfClass:[NSNumber class]]) {
        finalStr = [(NSNumber*)userGender stringValue];
    } else {
        finalStr = userGender;
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:finalStr forKey:SNS_GENDER_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isRecommendAllowed
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SNS_RECOMMEND_ALLOWED_KEY];
}

- (void)setRecommendAllowed:(BOOL)isRecommendAllowed
{
    [[NSUserDefaults standardUserDefaults] setBool:isRecommendAllowed forKey:SNS_RECOMMEND_ALLOWED_KEY];
}

- (NSString *)recommendHintMessage
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:SNS_RECOMMEND_HINT_KEY];
}

- (void)setRecommendHintMessage:(NSString *)recommendHintMessage
{
    if (!isEmptyString(recommendHintMessage)) {
        [[NSUserDefaults standardUserDefaults] setValue:recommendHintMessage forKey:SNS_RECOMMEND_HINT_KEY];
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:SNS_RECOMMEND_HINT_KEY];
    }
}

#pragma mark - platform expired related

- (BOOL)tryAssignAccountInfoFromKeychain
{
    BOOL result = NO;
    NSDictionary *account = [[AccountKeyChainManager sharedManager] accountFromKeychain];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kHasAssignedInfoFromKeychain] && ![TTAccountManager isLogin] && [account objectForKey:@"session_id"]) {
        if (![[account objectForKey:@"bundle_id"] isEqualToString:[TTSandBoxHelper bundleIdentifier]] && account.count > 0 && ![[account objectForKey:@"is_expired"] boolValue]) {
            NSString *sessionID = [account objectForKey:@"session_id"];
#warning NewAccount @zuopengliu
            // if(!isEmptyString(sessionID)) [self requestNewSession:account];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasAssignedInfoFromKeychain];
            [[NSUserDefaults standardUserDefaults] synchronize];
            result = YES;
        }
    }
    
    return result;
}

- (void)setDraftMobile:(NSString *)draftMobile
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:draftMobile forKey:ArticleDraftMobileCacheKey];
    [userDefaults synchronize];
}

- (NSString *)draftMobile
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:ArticleDraftMobileCacheKey];
}

@end
