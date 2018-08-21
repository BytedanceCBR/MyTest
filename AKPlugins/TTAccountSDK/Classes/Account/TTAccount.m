//
//  TTAccount.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/5/16.
//  Copyright © 2016 Toutiao. All rights reserved.
//

#import "TTAccount.h"
#import "TTAccount+Notifications.h"
#import "TTAccountStore.h"
#import "TTAccountUserEntity_Priv.h"
#import "TTAccountConfiguration_Priv.h"



/**
 *  Keys In SecKeyChain and NSUserDefault
 */
static NSString * const TTASecKeyChainAccountUserKey              = @"com.toutiao.account.keychain.user";
static NSString * const TTANSUserDefaultAccountUserKey            = @"com.toutiao.account.userdefault.user";
static NSString * const TTANSUserDefaultAccountUserLoginStatusKey = @"com.toutiao.account.userdefault.user.login_status";


@interface TTAccount () {
    dispatch_semaphore_t _readOnlySemaphore_;
}
/** Flag: 用户是否已登录状态 */
@property (nonatomic, assign, readwrite) BOOL isLogin;

/** 用户信息 */
@property (nonatomic, strong, readwrite) TTAccountUserEntity *user;
@end
@implementation TTAccount
@synthesize user    = _user;
@synthesize isLogin = _isLogin;
+ (void)load
{
    /** 这个必须同步处理，否则AppDelegate的application:didFinishLaunchingWithOptions:执行完成才会调用 */
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self sharedAccount];
    });
}

+ (instancetype)sharedAccount
{
    static TTAccount *sharedInst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [self new];
    });
    return sharedInst;
}

- (instancetype)init
{
    if ((self = [super init])) {
        _readOnlySemaphore_ = dispatch_semaphore_create(1);
        
        _isLogin = NO;
        [self __registerNotifications__];
        [self __loadAccountUserFromDisk__];
    }
    return self;
}

- (void)dealloc
{
    [self __unregisterNotifications__];
}

- (void)__loadAccountUserFromDisk__
{
    BOOL isLoginInUserDefault = [self.class isLoginInNSUserDefault];
    TTAccountUserEntity *userInNSUserDefault = [self.class accountUserInNSUserDefault];
    if (isLoginInUserDefault && [userInNSUserDefault.sessionKey length] > 0) {
        // LoginFlag and SessionKey 都存在
        _isLogin = isLoginInUserDefault;
        self.user = userInNSUserDefault;
        return;
    }
    
    TTAccountUserEntity *userInKeyChain = [self.class currentAccountUserInDisk];
    if (isLoginInUserDefault && [userInKeyChain.sessionKey length] > 0) {
        _isLogin = isLoginInUserDefault;
        self.user = userInKeyChain;
    } else if (!isLoginInUserDefault && [userInKeyChain.sessionKey length] > 0) {
        // NSUserDefault不存在，but SecKeyChain中存在SessionKey，则使用/2/user/info/接口与服务端同步，尝试登录
        // 1. 同一个App Group下共享Keychain实现自动登录
        // 2. NSUserDefault丢失自动登录
        self.user = userInKeyChain;
        
        // [self.class synchronizeAccountUserStatusWithloggedOn:_isLogin
        //                                        waitUntilDone:NO];
    }
}

- (void)__synchronizeAccountUserFromNetwork__
{
    BOOL isLoginInUserDefault = [self.class isLoginInNSUserDefault];
    TTAccountUserEntity *userInDisk = [self.class currentAccountUserInDisk];
    
    if (isLoginInUserDefault) {
        _isLogin = isLoginInUserDefault;
        self.user = userInDisk;
        return;
    }
    
    if (!isLoginInUserDefault && [userInDisk.sessionKey length] > 0) {
        // NSUserDefault不存在，but SecKeyChain中存在SessionKey，则使用/2/user/info/接口与服务端同步，尝试登录
        // 1. 同一个App Group下共享Keychain实现自动登录
        // 2. NSUserDefault丢失自动登录
        
        self.user = userInDisk;
        
        [self.class synchronizeAccountUserStatusByNetwork:nil
                                            waitUntilDone:NO];
    }
}

#pragma mark - synchronize account

- (void)persistence
{
    if ([self.class __multiThreadSafeSupported__]) {
        dispatch_semaphore_wait(_readOnlySemaphore_, DISPATCH_TIME_FOREVER);
        BOOL savedLoginFlag = _isLogin;
        TTAccountUserEntity *savedUser = _user;
        dispatch_semaphore_signal(_readOnlySemaphore_);
        
        // save login status
        [self.class setIsLoginInNSUserDefault:savedLoginFlag];
        
        // persistence user
        [self.class saveAccountUserToDisk:savedUser];
    } else {
        // save login status
        [self.class setIsLoginInNSUserDefault:_isLogin];
        
        // persistence user
        [self.class saveAccountUserToDisk:_user];
    }
}

- (void)clear
{
    if ([self.class __multiThreadSafeSupported__]) {
        dispatch_semaphore_wait(_readOnlySemaphore_, DISPATCH_TIME_FOREVER);
        _isLogin = NO;
        _user    = nil;
        dispatch_semaphore_signal(_readOnlySemaphore_);
    } else {
        _isLogin = NO;
        _user    = nil;
    }
    
    [self.class setIsLoginInNSUserDefault:NO];
    [self.class saveAccountUserToDisk:nil];
}

- (void)clearMemory
{
    [self persistence];
}

/** 绑定（登录）第三方平台 */
- (void)loginAuthorizedPlatform:(NSString *)platformName
{
    if ([platformName length] <= 0) {
        return;
    }
    
    NSMutableArray *thirdAccounts = [self.user.connects mutableCopy];
    if (!thirdAccounts) thirdAccounts = [NSMutableArray array];
    
    TTAccountPlatformEntity *aEntity = [TTAccountPlatformEntity new];
    aEntity.userID = self.user.userID;
    aEntity.platform = platformName;
    
    [thirdAccounts addObject:aEntity];
    
    @synchronized (self.user.connects) {
        self.user.connects = thirdAccounts;
    }
}

/** 解绑（登出）第三方平台信息 */
- (void)logoutAuthorizedPlatform:(NSString *)platformName
{
    if ([platformName length] <= 0) {
        return;
    }
    
    NSMutableArray *thirdAccounts = [self.user.connects mutableCopy];
    __block NSInteger removedIdx = NSNotFound;
    [thirdAccounts enumerateObjectsUsingBlock:^(TTAccountPlatformEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.platform isEqualToString:platformName]) {
            removedIdx = idx;
        }
    }];
    
    if (removedIdx != NSNotFound && removedIdx < [thirdAccounts count]) {
        [thirdAccounts removeObjectAtIndex:removedIdx];
    }
    
    @synchronized (self.user.connects) {
        self.user.connects = thirdAccounts;
    }
}

- (TTAccountPlatformEntity *)connectedAccountForPlatform:(NSString *)platformName
{
    if (!platformName) return nil;
    NSArray *connectedAccounts = [self.user.connects copy];
    __block NSInteger foundIdx = NSNotFound;
    [connectedAccounts enumerateObjectsUsingBlock:^(TTAccountPlatformEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.platform isEqualToString:platformName]) {
            foundIdx = idx;
        }
    }];
    
    if (foundIdx != NSNotFound && foundIdx < [connectedAccounts count]) {
        return connectedAccounts[foundIdx];
    }
    return nil;
}


#pragma mark - Getter/Setter

- (void)setSessionKey:(NSString *)sessionKey
{
    self.user.sessionKey = sessionKey;
}

- (NSString *)sessionKey
{
    if (self.user) {
        return self.user.sessionKey;
    }
    return [self.class currentAccountUserInDisk].sessionKey;
}

- (NSString *)userIdString
{
    if (![self isLogin]) {
        return @"0"; // 默认用户id
    }
    return [self.user userIDString];
}

- (BOOL)isLogin
{
    if (_isLogin) {
        return _isLogin;
    }
    
    [self __synchronizeAccountUserFromNetwork__];
    
    return _isLogin;
}

- (void)setIsLogin:(BOOL)isLogin
{
    if ([self.class __multiThreadSafeSupported__]) {
        dispatch_semaphore_wait(_readOnlySemaphore_, DISPATCH_TIME_FOREVER);
        _isLogin = isLogin;
        dispatch_semaphore_signal(_readOnlySemaphore_);
    } else {
        _isLogin = isLogin;
    }
    
    if (isLogin) {
        [self persistence];
    } else {
        [self clear];
    }
}

- (TTAccountUserEntity *)user
{
    if (!_isLogin) return nil;
    if (_user) return _user;
    
    // 从磁盘获取数据
    TTAccountUserEntity *userInDisk = [self.class currentAccountUserInDisk];
    self.user = userInDisk;
    
    return _user;
}

- (void)setUser:(TTAccountUserEntity *)user
{
    if (![user isKindOfClass:[TTAccountUserEntity class]]) {
        return;
    }
    if (user == _user) {
        return;
    }
    
    if ([self.class __multiThreadSafeSupported__]) {
        dispatch_semaphore_wait(_readOnlySemaphore_, DISPATCH_TIME_FOREVER);
        [user checkAndAvoidHittingTheObservedValues];
        user.sessionKey ? nil : (user.sessionKey = _user.sessionKey);
        user.token ? nil : (user.token = _user.token);
        _user = user;
        dispatch_semaphore_signal(_readOnlySemaphore_);
    } else {
        user.sessionKey ? nil : (user.sessionKey = _user.sessionKey);
        user.token ? nil : (user.token = _user.token);
        _user = user;
    }
    
    __weak typeof(self) weakSelf = self;
    [_user observeValueDidChangeHandler:^(NSString *keyPath, NSDictionary *change) {
        if ([weakSelf.class __multiThreadSafeSupported__]) {
            dispatch_semaphore_wait(_readOnlySemaphore_, DISPATCH_TIME_FOREVER);
            TTAccountUserEntity *savedUser = weakSelf.user;
            dispatch_semaphore_signal(_readOnlySemaphore_);
            
            [TTAccount saveAccountUserToDisk:savedUser];
        } else {
            [TTAccount saveAccountUserToDisk:user];
        }
    }];
}


#pragma mark - operate data in disk

+ (NSString *)__sharingKeyChainGroup__
{
    return [[TTAccount accountConf] tta_sharingKeyChainGroup];
}

+ (void)saveAccountUserToDisk:(TTAccountUserEntity *)user
{
    [self.class setAccountUserInNSUserDefault:user];
    [TTAccountStore tt_setDictionary:[user toKeyChainDictionary]
                              forKey:TTASecKeyChainAccountUserKey
                             service:nil
                         accessGroup:[self.class __sharingKeyChainGroup__]];
}

+ (TTAccountUserEntity *)currentAccountUserInDisk
{
    TTAccountUserEntity *currentUser = [self.class accountUserInNSUserDefault];
    if (!currentUser) {
        NSDictionary *accountUserDict =
        [TTAccountStore tt_dictionaryForKey:TTASecKeyChainAccountUserKey
                                    service:nil
                                accessGroup:[self __sharingKeyChainGroup__]];
        if ([accountUserDict count] > 0) {
            currentUser = [[TTAccountUserEntity alloc] initWithDictionary:accountUserDict];
        }
    }
    if ([currentUser isKindOfClass:[TTAccountUserEntity class]]) {
        return currentUser;
    }
    return nil;
}

+ (BOOL)isLoginInNSUserDefault
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:TTANSUserDefaultAccountUserLoginStatusKey];
}

+ (void)setIsLoginInNSUserDefault:(BOOL)isLogin
{
    [[NSUserDefaults standardUserDefaults] setBool:isLogin forKey:TTANSUserDefaultAccountUserLoginStatusKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (TTAccountUserEntity *)accountUserInNSUserDefault
{
    NSData *userData = [[NSUserDefaults standardUserDefaults] objectForKey:TTANSUserDefaultAccountUserKey];
    TTAccountUserEntity *currentUser = nil;
    if ([userData isKindOfClass:[NSData class]]) {
        currentUser = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    } else if ([userData isKindOfClass:[NSDictionary class]]) {
        currentUser = [[TTAccountUserEntity alloc] initWithDictionary:(NSDictionary *)userData];
    }
    return [currentUser isKindOfClass:[TTAccountUserEntity class]] ? currentUser : nil;
}

+ (void)setAccountUserInNSUserDefault:(TTAccountUserEntity *)currentUser
{
    NSData *currentUserData = currentUser ? [NSKeyedArchiver archivedDataWithRootObject:currentUser] : nil;
    [[NSUserDefaults standardUserDefaults] setObject:currentUserData forKey:TTANSUserDefaultAccountUserKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)__multiThreadSafeSupported__
{
    return [TTAccount accountConf].multiThreadSafeEnabled;
}

@end



@implementation TTAccount (Configuration)

static TTAccountConfiguration *s_sharedAccountConf = nil;

+ (void)setAccountConf:(TTAccountConfiguration *)accountConfiguration
{
    s_sharedAccountConf = accountConfiguration;
}

+ (TTAccountConfiguration *)accountConf
{
    if (!s_sharedAccountConf) {
        s_sharedAccountConf = [TTAccountConfiguration new];
    }
    
    return s_sharedAccountConf;
}

@end



@implementation NSDictionary (AccountHelper)

- (BOOL)tta_boolForKey:(NSObject<NSCopying> *)key
{
    if (!key) return NO;
    if (![key conformsToProtocol:@protocol(NSCopying)]) return NO;
    
    id value = [self objectForKey:key];
    if ([value respondsToSelector:@selector(boolValue)]) {
        return [value boolValue];
    }
    return NO;
}

- (BOOL)tta_boolForEnumKey:(NSInteger)enumInt
{
    NSString *valueForEnumKey = [self tta_stringForEnumKey:enumInt];
    if (valueForEnumKey) return [valueForEnumKey boolValue];
    return NO;
}

- (NSString *)tta_stringForKey:(NSObject<NSCopying> *)key
{
    if (!key) return nil;
    if (![key conformsToProtocol:@protocol(NSCopying)]) return nil;
    
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    } else if ([value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    }
    return nil;
}

- (NSString *)tta_stringForEnumKey:(NSInteger)enumInt
{
    NSString *valueForEnumKey = [self tta_stringForKey:@(enumInt)];
    if (valueForEnumKey) return valueForEnumKey;
    return [self tta_stringForKey:[@(enumInt) stringValue]];
}

@end
