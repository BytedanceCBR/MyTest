//
//  TTAccountVersionAdapter.m
//  Article
//
//  Created by liuzuopeng on 27/05/2017.
//
//

#import "TTAccountVersionAdapter.h"
#import "AccountKeyChainManager.h"
#import "AccountManager.h"



@implementation TTAccountVersionAdapter

+ (void)oldAccountUserCompatibility
{
    if ([self __isNeedAccountCompatibility__]) {
        TTAccountUserEntity *oldUserEntity = [self currentAccountUserFromOldVersion];
        if (oldUserEntity) {
            [[TTAccount sharedAccount] setUser:oldUserEntity];
            [[TTAccount sharedAccount] setIsLogin:YES];
        }
    }
}

// 当使用新的账号时，是否使用老的账号信息兼容
+ (BOOL)__isNeedAccountCompatibility__
{
    if ([[AccountManager sharedManager] isLogin] &&
        ![[TTAccount sharedAccount] isLogin]) {
        return YES;
    }
    return NO;
}

+ (TTAccountUserEntity *)currentAccountUserFromOldVersion
{
    if (![[AccountManager sharedManager] isLogin])  {
        return nil;
    }
    
    TTAccountUserEntity *oldAccountUser = [TTAccountUserEntity new];
    
    //oldAccountUser.token = [AccountManager sharedManager].token;
    
    NSDictionary *account = [[AccountKeyChainManager sharedManager] accountFromKeychain];
    NSString *sessionIDString = [account objectForKey:@"session_id"];
    oldAccountUser.sessionKey = sessionIDString;
    
    oldAccountUser.newUser = [[AccountManager sharedManager].isNewUser boolValue];
    oldAccountUser.canBeFoundByPhone = YES;
    oldAccountUser.userID = @([[AccountManager sharedManager].userID longLongValue]);
    oldAccountUser.name = [AccountManager sharedManager].userName;
    oldAccountUser.screenName = [AccountManager sharedManager].userName;
    oldAccountUser.mobile = [AccountManager sharedManager].myUser.phoneNumberString;
    oldAccountUser.birthday = [AccountManager sharedManager].myUser.birthday;
    oldAccountUser.area = [AccountManager sharedManager].myUser.area;
    oldAccountUser.userDescription = [AccountManager sharedManager].userDescription;
    oldAccountUser.avatarURL = [AccountManager sharedManager].avatarURLString;
    oldAccountUser.avatarLargeURL = [AccountManager sharedManager].avatarLargeURLString;
    oldAccountUser.bgImgURL = [AccountManager sharedManager].bgImageURLString;
    oldAccountUser.gender = @([[AccountManager sharedManager].userGender longLongValue]);
    oldAccountUser.shareURL = [AccountManager sharedManager].myUser.shareURL;
    
    
    oldAccountUser.isBlocking = [AccountManager sharedManager].myUser.isBlocking;
    oldAccountUser.isBlocked = [AccountManager sharedManager].myUser.isBlocked;
    oldAccountUser.isFollowing = [AccountManager sharedManager].myUser.isFollowing;
    oldAccountUser.isFollowed = [AccountManager sharedManager].myUser.isFollowed;
    
    
    NSString *mediaIDString = [AccountManager sharedManager].myUser.media_id;
    if ([mediaIDString isKindOfClass:[NSNumber class]]) {
        oldAccountUser.mediaID = (NSNumber *)mediaIDString;
    } else if ([mediaIDString isKindOfClass:[NSString class]]) {
        oldAccountUser.mediaID = @([mediaIDString longLongValue]);
    }
    
    
    oldAccountUser.userVerified = [AccountManager sharedManager].userVerified;
    oldAccountUser.userAuthInfo = [AccountManager sharedManager].userAuthInfo;
    oldAccountUser.verifiedReason = [AccountManager sharedManager].myUser.verifiedReason;
    
    
    oldAccountUser.isRecommendAllowed = [AccountManager sharedManager].isRecommendAllowed;
    oldAccountUser.recommendHintMessage = [AccountManager sharedManager].recommendHintMessage;
    
    
    oldAccountUser.followingsCount = [AccountManager sharedManager].followingCount;
    oldAccountUser.followersCount = [AccountManager sharedManager].followerCount;
    oldAccountUser.visitCountRecent = [AccountManager sharedManager].visitorCount;
    oldAccountUser.momentsCount = [AccountManager sharedManager].momentCount;
    
    
    // 老的账号Connects等其它都没有持久化
    
    return oldAccountUser;
}

@end
