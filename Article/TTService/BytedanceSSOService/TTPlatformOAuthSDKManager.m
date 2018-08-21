//
//  TTPlatformOAuthSDKManager.h
//  Article
//
//  Created by zuopengliu on 27/9/2017.
//  Copyright © 2017 Bytedance. All rights reserved.
//

#import "TTPlatformOAuthSDKManager.h"
#import <Bytedancebase/BDPlatformSDKApi.h>
#import <TTAccountLoginManager.h>



@interface TTPlatformOAuthSDKManager ()
<
BDPlatformSDKApiDelegate
>
@property (nonatomic, assign) BOOL canHandled;
@end

@implementation TTPlatformOAuthSDKManager

+ (instancetype)sharedManager
{
    static TTPlatformOAuthSDKManager *sharedInst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [self new];
    });
    return sharedInst;
}

- (instancetype)init
{
    if ((self = [super init])) {
        _canHandled = NO;
    }
    return self;
}

+ (void)startConfiguration
{
    // 配置爱看OAuth平台信息
    BDPlatformSDKConfiguration *conf = [BDPlatformSDKConfiguration new];
    conf.productType = BDPlatformSDKProductTypeToutiao;
    conf.productName = NSLocalizedString(@"article", nil);
    conf.productDisplayName = NSLocalizedString(@"爱看", nil);
    conf.URLSchemes = @[@"snssdk141", @"ttnewssso"];
#ifdef INHOUSE
    conf.URLSchemes = @[@"snssdk147", @"ttnewsinhousesso"];
#endif
    conf.navBarTitleFont = [UIFont boldSystemFontOfSize:17.f];
    conf.navBarTitleColor = [UIColor colorWithRed:0x22/256.f green:0x22/256.f blue:0x22/256.f alpha:1];
    conf.navBarButtonFont = [UIFont systemFontOfSize:16.f];
    conf.navBarButtonColor = [UIColor colorWithRed:0x22/256.f green:0x22/256.f blue:0x22/256.f alpha:1];
    
    [BDPlatformSDKApi bindConfiguration:conf];
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
    return [[self sharedManager] handleOpenURL:url];
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    return [BDPlatformSDKApi application:[UIApplication sharedApplication] openURL:url delegate:self] && _canHandled;
}

#pragma mark - delegate

- (BOOL)askForLoginDidReceiveReq:(BDPlatformSDKBaseReq *)req loginCompletion:(BDPlatformSDKLoginCompletionBlock)completedBlock
{
    if (![req isKindOfClass:[BDPlatformSDKGetAuthReq class]]) {
        self.canHandled = NO;
        return NO;
    }
    
    self.canHandled = YES;
    if ([[TTAccount sharedAccount] isLogin]) {
        // 当前已登录
        NSDictionary *userInfo = [self.class platformSDKUserInfoForAccountLoginStatus:YES];
        if (completedBlock) {
            completedBlock(YES, userInfo);
        }
    } else {
        
        // Dismiss `OLD LoginPanel`
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_MASK_AFTER_LOGIN_SUCCESS" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:TTForceToDismissLoginViewControllerNotification object:nil userInfo:@{@"animated": @(NO)}];
        
        NSInteger consumerProductType = [(BDPlatformSDKGetAuthReq *)req consumerProductType];
        NSInteger platformAuthType = [self.class platformTypeFromBDProductType:consumerProductType];
        NSString *platformName  = [TTAccount platformNameForAccountAuthType:platformAuthType];
        NSArray  *platformNames = (platformName.length > 0) ? @[platformName] : nil;
        // 未登录则执行登录操作，登录完成后必须调用completedBlock回调
        [TTAccountLoginManager presentLoginViewControllerFromVC:[TTUIResponderHelper topmostViewController] title:nil source:@"oauth" excludedPlatforms:platformNames completion:^(TTAccountLoginState state) {
            BOOL isLogin = [[TTAccount sharedAccount] isLogin];
            NSDictionary *userInfo = [self.class platformSDKUserInfoForAccountLoginStatus:isLogin];
            
            if (completedBlock) {
                completedBlock(isLogin, userInfo);
            }
        }];
    }
    
    return YES;
}

+ (NSDictionary *)platformSDKUserInfoForAccountLoginStatus:(BOOL)isLogin
{
    NSMutableDictionary *mutUserInfo = nil;
    if (isLogin) {
        mutUserInfo = [NSMutableDictionary dictionaryWithCapacity:4];
        [mutUserInfo setValue:[TTAccount sharedAccount].sessionKey
                       forKey:BDPlatformSDKSessionIdKey];
        [mutUserInfo setValue:[TTAccount sharedAccount].userIdString
                       forKey:BDPlatformSDKUserIdKey];
        [mutUserInfo setValue:[[TTAccount sharedAccount] user].name
                       forKey:BDPlatformSDKUserNameKey];
        [mutUserInfo setValue:[[TTAccount sharedAccount] user].avatarURL
                       forKey:BDPlatformSDKUserAvatarKey];
    }
    return [mutUserInfo copy];
}


#pragma mark - helper

+ (NSInteger)platformTypeFromBDProductType:(NSInteger)productType
{
    NSInteger platformType = TTAccountAuthTypeUnsupport;
    switch (productType) {
        case BDPlatformSDKProductTypeDouyin: {
            platformType = TTAccountAuthTypeDouyin;
        }
            break;
        case BDPlatformSDKProductTypeHuoshan: {
            platformType = TTAccountAuthTypeHuoshan;
        }
            break;
        case BDPlatformSDKProductTypeWatermelon: {
            
        }
            break;
        case BDPlatformSDKProductTypeWukong: {
            
        }
            break;
            
        default:
            break;
    }
    return platformType;
}

@end
