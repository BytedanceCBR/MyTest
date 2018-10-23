//
//  TTAccountManager.m
//  Article
//
//  Created by liuzuopeng on 5/19/17.
//
//

#import "TTAccountManager.h"
#import "TTAccountManager+AccountInterfaceTask.h"
#import "TTAccountManager+HTSAccountBridge.h"
#import <NSStringAdditions.h>
#import <TTIndicatorView.h>
#import <TTModuleBridge.h>
#import "SSCookieManager.h"
#import "AccountManager.h"
#import "SSMyUserModel.h"



@implementation TTAccountManager

+ (instancetype)sharedManager
{
    static TTAccountManager *sharedInst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [self new];
    });
    return sharedInst;
}

- (instancetype)init
{
    if ((self = [super init])) {
        [TTPlatformAccountManager sharedManager];
        [TTAccountManager registerHTSAccountActions];
    }
    return self;
}

- (void)dealloc
{
    [TTAccountManager unregisterHTSAccountActions];
}

+ (TTAccountUserEntity *)currentUser
{
    return [[TTAccount sharedAccount] user];
}

+ (TTAccountUserType)accountUserType
{
    NSString *mediaIdString = [[[TTAccount sharedAccount] user] mediaIDString];
    TTAccountUserType curUserType = TTAccountUserTypeVisitor;
    if (!isEmptyString(mediaIdString) && ![mediaIdString isEqualToString:@"0"]) {
        curUserType = TTAccountUserTypePGC;
    } else if ([self.class isVerifiedOfUserVerifyInfo:self.userAuthInfo]) {
        curUserType = TTAccountUserTypeUGC;
    }
    return curUserType;
}

+ (NSString *)userID
{
    return [[TTAccount sharedAccount] userIdString];
}

+ (long long)userIDLongInt
{
    return [[self class].userID longLongValue];
}

+ (NSString *)mediaID
{
    return [[[TTAccount sharedAccount] user] mediaIDString];
}

+ (NSString *)userDecoration {
    return [[[TTAccount sharedAccount] user] userDecoration];
}

+ (long long)mediaIDLongInt
{
    return [[self.class mediaID] longLongValue];
}

+ (NSString *)sessionKey
{
    return [[TTAccount sharedAccount] sessionKey];
}

+ (NSString *)userName
{
    return [[TTAccount sharedAccount] user].name;
}

+ (void)setUserName:(NSString *)userName
{
    [[TTAccount sharedAccount] user].name = userName;
}

+ (NSString *)avatarURLString
{
    return [[TTAccount sharedAccount] user].avatarURL;
}

+ (void)setAvatarURLString:(NSString *)avatarURLString
{
    [[TTAccount sharedAccount] user].avatarURL = avatarURLString;
}

+ (NSString *)userAuthInfo
{
    if ([[AccountManager sharedManager].userAuthInfo length] > 0) {
        return [AccountManager sharedManager].userAuthInfo;
    }
    return [[TTAccount sharedAccount] user].userAuthInfo;
}

+ (void)setUserAuthInfo:(NSString *)userAuthInfo
{
    [[TTAccount sharedAccount] user].userAuthInfo = userAuthInfo;
}

+ (NSString *)userGender
{
    if ([[[TTAccount sharedAccount] user].gender respondsToSelector:@selector(stringValue)]) {
        return [[[TTAccount sharedAccount] user].gender stringValue];
    }
    return nil;
}

+ (void)setUserGender:(NSString *)userGender
{
    [[TTAccount sharedAccount] user].gender = @([userGender longLongValue]);
}

+ (void)setShowInfo:(NSString *)showInfo
{
    [[AccountManager sharedManager] setShowInfo:showInfo];
}

+ (NSString *)showInfo
{
    return [AccountManager sharedManager].showInfo;
}

+ (NSString *)draftMobile
{
    return [AccountManager sharedManager].draftMobile ? : [TTAccountDraft draftPhone];
}

+ (void)setDraftMobile:(NSString *)draftMobile
{
    [AccountManager sharedManager].draftMobile = draftMobile;
    [TTAccountDraft setDraftPhone:draftMobile];
}

#pragma mark - myUser

- (SSMyUserModel *)myUser
{
    if (![TTAccountManager isLogin]) {
        _myUser = nil;
        return nil;
    }
    
    if (!_myUser) {
        _myUser = [[SSMyUserModel alloc] initWithAccountUser:[self.class currentUser]];
    }
    return _myUser;
}

- (void)synchronizeOldMyUser
{
    if ([TTAccountManager isLogin]) {
        _myUser = [[SSMyUserModel alloc] initWithAccountUser:[self.class currentUser]];
    } else {
        _myUser = nil;
    }
}

#pragma mark - login flag

+ (BOOL)isLogin
{
    return [[TTAccount sharedAccount] isLogin];
}

+ (void)setIsLogin:(BOOL)isLogin
{
    if (!isLogin) {
        [[AccountManager sharedManager] setIsLogin:isLogin];
    }
    
    [[TTAccount sharedAccount] setIsLogin:isLogin];
}

- (BOOL)isAccountUserOfUID:(NSString *)uid
{
    return [self.class isLogin] && ([uid isEqualToString:[self class].userID] || [uid isEqualToString:@"0"]);
}

+ (BOOL)isVerifiedOfUserVerifyInfo:(NSString *)verifyInfo
{
    if (isEmptyString(verifyInfo)) {
        return NO;
    }
    
    NSDictionary *verifyInfoJSON = verifyInfo.JSONValue;
    if (SSIsEmptyDictionary(verifyInfoJSON)) {
        return NO;
    }
    
    NSString *verifyContent = [verifyInfoJSON tt_stringValueForKey:@"auth_info"];
    if (isEmptyString(verifyContent)) {
        return NO;
    }
    
    return YES;
}
@end



@implementation TTAccountManager (FriendRelationshipTextHelper)

+ (NSString *)followingString
{
    return [AccountManager sharedManager].followingString;
}

+ (void)setFollowingString:(NSString *)followingString
{
    [AccountManager sharedManager].followingString = followingString;
}

+ (NSString *)followerString
{
    return [AccountManager sharedManager].followerString;
}

+ (void)setFollowerString:(NSString *)followerString
{
    [AccountManager sharedManager].followerString = followerString;
}

+ (NSString *)visitorString
{
    return [AccountManager sharedManager].visitorString;
}

+ (void)setVisitorString:(NSString *)visitorString
{
    [AccountManager sharedManager].visitorString = visitorString;
}

+ (NSString *)momentString
{
    return [AccountManager sharedManager].momentString;
}

+ (void)setMomentString:(NSString *)momentString
{
    [AccountManager sharedManager].momentString = momentString;
}

@end

