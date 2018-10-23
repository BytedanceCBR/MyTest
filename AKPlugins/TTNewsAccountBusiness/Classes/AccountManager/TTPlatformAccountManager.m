//
//  TTPlatformAccountManager.m
//  Article
//
//  Created by liuzuopeng on 03/06/2017.
//
//

#import "TTPlatformAccountManager.h"
#import "SSCookieManager.h"
#import "TTAccountManager.h"



@interface TTPlatformAccountManager ()

@property (nonatomic, strong) NSMutableDictionary *accountDict;

@end

@implementation TTPlatformAccountManager

+ (instancetype)sharedManager
{
    static TTPlatformAccountManager *sharedInst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [self new];
    });
    return sharedInst;
}

- (instancetype)init
{
    if ((self = [super init])) {
        self.accountDict = [[NSMutableDictionary alloc] init];
        
        NSMutableArray *types = [NSMutableArray arrayWithCapacity:5];
        [types addObject:[NSNumber numberWithInt:TTAccountAuthTypeTencentQQ]];
        [types addObject:[NSNumber numberWithInt:TTAccountAuthTypeSinaWeibo]];
        [types addObject:[NSNumber numberWithInt:TTAccountAuthTypeTencentWB]];
        [types addObject:[NSNumber numberWithInt:TTAccountAuthTypeRenRen]];
        [types addObject:[NSNumber numberWithInt:TTAccountAuthTypeWeChat]];
        [types addObject:[NSNumber numberWithInt:TTAccountAuthTypeTianYi]];
        [types addObject:[NSNumber numberWithInt:TTAccountAuthTypeHuoshan]];
        [types addObject:[NSNumber numberWithInt:TTAccountAuthTypeDouyin]];
        [self setPlatformAccountsByTypes:types];
    }
    return self;
}

#pragma mark - third party platforms

- (NSDictionary<NSString *, TTThirdPartyAccountInfoBase *> *)platformAccountsDict
{
    return _accountDict;
}

- (NSArray<TTThirdPartyAccountInfoBase *> *)platformAccounts
{
    return [_accountDict allValues];
}

/** 已绑定（登录）的第三方账号信息 */
- (NSArray<TTThirdPartyAccountInfoBase *> *)connectedPlatformAccountsInfo
{
    NSMutableArray *connectedUserAccounts = [NSMutableArray arrayWithCapacity:3];
    NSArray<TTAccountPlatformEntity *> *connectedAccounts = [[[TTAccount sharedAccount] user].connects copy];
    for (TTAccountPlatformEntity *connectedPlatform in connectedAccounts) {
        TTThirdPartyAccountInfoBase *platformAccountInfo = [self platformAccountInfoForKey:connectedPlatform.platform];
        if (!platformAccountInfo) {
            platformAccountInfo = [AccountInfoFactory accountInfoByType:TTAccountGetPlatformTypeByName(connectedPlatform.platform)];
            platformAccountInfo.screenName = connectedPlatform.platformScreenName;
            platformAccountInfo.profileImageURLString = connectedPlatform.profileImageURL;
            platformAccountInfo.platformUid = connectedPlatform.platformUID;
            platformAccountInfo.accountStatus = TTThirdPartyAccountStatusBounded;
        }
        if (platformAccountInfo) {
            [connectedUserAccounts addObject:platformAccountInfo];
        }
    }
    return [connectedUserAccounts count] > 0 ? connectedUserAccounts : nil;
}

- (void)setAccountPlatform:(NSString *)platformName checked:(BOOL)checked
{
    TTThirdPartyAccountInfoBase *accountInfo = [self platformAccountInfoForKey:platformName];
    if (checked) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        accountInfo.accountStatus = TTThirdPartyAccountStatusChecked;
#pragma clang diagnostic pop
    }
}

- (TTThirdPartyAccountInfoBase *)platformAccountInfoForKey:(NSString *)key
{
    return [_accountDict objectForKey:key];
}

- (NSString *)platformDisplayNameForKey:(NSString *)key
{
    return [[self platformAccountInfoForKey:key] displayName];
}

- (BOOL)isBoundedPlatformForKey:(NSString *)platformKey
{
    NSArray<NSString *> *boundedNames = [self boundedPlatformNames];
    for (NSString *platformName in boundedNames) {
        if ([platformName isEqualToString:platformKey]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray<NSString *> *)boundedPlatformNames
{
    NSMutableArray *checkedAccountNames = [[NSMutableArray alloc] init];
    
    NSArray *accounts = [_accountDict allValues];
    for (TTThirdPartyAccountInfoBase *account in accounts) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (account.accountStatus == TTThirdPartyAccountStatusBounded ||
            account.accountStatus == TTThirdPartyAccountStatusChecked) {
            [checkedAccountNames addObject:[account keyName]];
        }
#pragma clang diagnostic pop
    }
    
    return checkedAccountNames;
}

/**
 清空平台账号信息
 */
- (void)clearPlatformAccounts
{
    [_accountDict removeAllObjects];
}

// 当授权的第三方平台过期时，clean specific accounts
- (void)cleanExpiredPlatformAccountsByNames:(NSArray *)accountNames
{
    for (NSString *accountName in accountNames) {
        TTThirdPartyAccountInfoBase *account = [self platformAccountInfoForKey:accountName];
        [account clear];
    }
}

- (void)cleanPlatformAccounts
{
    NSArray *accounts = [self platformAccounts];
    for (TTThirdPartyAccountInfoBase *info in accounts) {
        [info clear];
    }
    
    // 清空所有域名下的sessionid
    if (![TTAccountManager isLogin]) {
        [SSCookieManager setSessionIDToCookie:nil];
    }
}

// 判断是否有绑定的平台账号
- (BOOL)hasBoundedPlatformAccount
{
    return [[[TTAccount sharedAccount] user].connects count] > 0;
}

- (void)setPlatformAccountsByTypes:(NSArray<NSNumber *> *)types
{
    if ([types count] > 0) {
        NSDictionary *oldAccountInfos = [_accountDict copy];
        NSMutableDictionary *newAccountInfos = [NSMutableDictionary dictionaryWithCapacity:3];
        
        for (NSNumber *typeNumber in types) {
            TTAccountAuthType type = [typeNumber integerValue];
            NSString *platformName = TTAccountGetPlatformNameByType(type);
            
            if (platformName) {
                TTThirdPartyAccountInfoBase *accountInfo = [oldAccountInfos objectForKey:platformName];
                if (!accountInfo) {
                    accountInfo = [AccountInfoFactory accountInfoByType:type];
                }
                
                [newAccountInfos setValue:accountInfo forKey:platformName];
            }
        }
        
        if ([newAccountInfos count] > 0) {
            @synchronized (self.accountDict) {
                self.accountDict = newAccountInfos;
            }
        }
    }
}

- (void)synchronizePlatformAccountsStatus
{
    [self cleanPlatformAccounts];
    
    NSArray<TTAccountPlatformEntity *> *connectedAccounts = [[TTAccount sharedAccount] user].connects;
    for (TTAccountPlatformEntity *connectedAccount in connectedAccounts) {
        
        TTThirdPartyAccountInfoBase *accountInfo = [self platformAccountInfoForKey:connectedAccount.platform];
        accountInfo.screenName  = connectedAccount.platformScreenName;
        accountInfo.platformUid = connectedAccount.platformUID;
        accountInfo.expiredIn   = [connectedAccount.expiredIn doubleValue];
        accountInfo.profileImageURLString = connectedAccount.profileImageURL;
        // 只是把状态改成绑定 不做强行的 转发选中
        accountInfo.accountStatus = TTThirdPartyAccountStatusBounded;
    }
}

#pragma mark - share helper

- (NSInteger)numberOfCheckedAccounts
{
    NSInteger count = 0;
    NSArray<TTThirdPartyAccountInfoBase *> *accounts = [self platformAccounts];
    for (TTThirdPartyAccountInfoBase *account in accounts) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (account.accountStatus == TTThirdPartyAccountStatusChecked) {
            count++;
        }
#pragma clang diagnostic pop
    }
    return count;
}

- (NSInteger)numberOfLoginedAccounts
{
    NSInteger count = 0;
    NSArray<TTThirdPartyAccountInfoBase *> *accounts = [self platformAccounts];
    for (TTThirdPartyAccountInfoBase *account in accounts) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (account.accountStatus == TTThirdPartyAccountStatusChecked ||
            account.accountStatus == TTThirdPartyAccountStatusBounded) {
            count++;
        }
#pragma clang diagnostic pop
    }
    return count;
}

- (NSString *)sharePlatformsJoinedString
{
    NSMutableString *str = [NSMutableString stringWithCapacity:10];
    NSArray *accounts = [_accountDict allValues];
    NSString *sep = @"";
    
    for (TTThirdPartyAccountInfoBase *account in accounts) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (account.accountStatus == TTThirdPartyAccountStatusChecked) {
            //3.3 分享不分享QQ空间， 此处做过滤。
            if ([[account keyName] isEqualToString:PLATFORM_QZONE] ||
                [account.keyName isEqualToString:PLATFORM_WEIXIN]) {
                continue;
            }
            
            [str appendFormat:@"%@%@", sep, [account keyName]];
            sep = @",";
        }
#pragma clang diagnostic pop
    }
    
    return str;
}

@end
