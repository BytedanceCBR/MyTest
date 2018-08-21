//
//  TTAppDelegate.m
//  TTAccountLogin
//
//  Created by Nice2Me on 05/26/2017.
//  Copyright (c) 2017 Nice2Me. All rights reserved.
//

#import "TTAppDelegate.h"
#import <TTAccountSDK.h>
#import "TTAccountLoginManager.h"
#import "TTAccountNavigationBar.h"
#import <Aspects.h>



@implementation TTAppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UINavigationBar appearance] setTintColor:[UIColor redColor]];
    [[UINavigationBar appearance] setBarTintColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.3]];
    
    // Override point for customization after application launch.
    
    //    Class debuggingCls = NSClassFromString(@"UIDebuggingInformationOverlay");
    //    SEL debuggingSelString = NSSelectorFromString(@"prepareDebuggingOverlay");
    //    [(id)debuggingCls performSelector:debuggingSelString];
    
    [self.class confAccountSDK];
    [self.class confAccountLoginManager];
    
    [self observeKeyWindowChange];
    
    return YES;
}

- (void)observeKeyWindowChange
{
    // not working
    [[UIApplication sharedApplication].keyWindow addObserver:self forKeyPath:@"keyWindow" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tt_resignKeyWindow:) name:UIWindowDidResignKeyNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tt_becomeKeyWindow:) name:UIWindowDidBecomeKeyNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tt_windowDidBecomeVisible:) name:UIWindowDidBecomeVisibleNotification object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"keyWindow"] && object == self) {
        
    }
}

- (void)tt_resignKeyWindow:(NSNotification *)not
{
    
}

- (void)tt_becomeKeyWindow:(NSNotification *)not
{
    
}

- (void)tt_windowDidBecomeVisible:(NSNotification *)not
{
    
}

+ (void)confAccountSDK
{
     [TTAccount accountConf].multiThreadSafeEnabled = arc4random()%2;
    [TTAccount accountConf].sharingKeyChainGroup = @"XXHND5J98K.com.bytedance.keychainshare";
    
    [TTAccount accountConf].networkParamsHandler = ^NSDictionary *() {
        return nil;
    };
    
    [TTAccount accountConf].appRequiredParamsHandler = ^NSDictionary *() {
        NSMutableDictionary *requiredDict = [NSMutableDictionary dictionaryWithCapacity:4];
        return [requiredDict copy];
    };
    
    [self.class registerAccountPlatforms];
}

+ (void)registerAccountPlatforms
{
    NSString *WXAppID = nil;
    NSString *QQAppID = nil;
    NSString *WBAppID = nil;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [TTAccount registerAppId:WXAppID
                 forPlatform:TTAccountAuthTypeWeChat];
    [TTAccount registerAppId:QQAppID
                 forPlatform:TTAccountAuthTypeTencentQQ];
    [TTAccount registerAppId:WBAppID
                 forPlatform:TTAccountAuthTypeSinaWeibo];
#pragma clang diagnostic pop
}


+ (void)confAccountLoginManager
{
    [TTAccountLoginConfLogic setQuickRegisterPageTitleBlock:^NSString *{
        return nil;
    }];
    [TTAccountLoginConfLogic setQuickRegisterButtonTextBlock:^NSString *{
        return nil;
    }];
    [TTAccountLoginConfLogic setLoginDialogTitleHandler:^NSString *(NSInteger type) {
        return nil;
    }];
    [TTAccountLoginConfLogic setLoginAlertTitleHandler:^NSString *(NSInteger type) {
        return nil;
    }];
    [TTAccountLoginConfLogic setLoginPlatformEntryListHandler:^NSArray *{
        return nil;
    }];
    
    [TTAccountLoginConfLogic setLoginPlatforms:TTAccountLoginPlatformTypeInHouseOnly];
    
    NSMutableDictionary *platformNameMapper = [NSMutableDictionary dictionary];
    [platformNameMapper setObject:@"email"
                           forKey:@(TTAccountLoginPlatformTypeEmail)];
    [platformNameMapper setObject:@"phone"
                           forKey:@(TTAccountLoginPlatformTypePhone)];
    [platformNameMapper setObject:@"weixin"
                           forKey:@(TTAccountLoginPlatformTypeWeChat)];
    [platformNameMapper setObject:@"weixin_sns"
                           forKey:@(TTAccountLoginPlatformTypeWeChatSNS)];
    [platformNameMapper setObject:@"qzone_sns"
                           forKey:@(TTAccountLoginPlatformTypeQZone)];
    [platformNameMapper setObject:@"qq_weibo"
                           forKey:@(TTAccountLoginPlatformTypeQQWeibo)];
    [platformNameMapper setObject:@"sina_weibo"
                           forKey:@(TTAccountLoginPlatformTypeSinaWeibo)];
    [platformNameMapper setObject:@"renren_sns"
                           forKey:@(TTAccountLoginPlatformTypeRenRen)];
    [platformNameMapper setObject:@"telecom"
                           forKey:@(TTAccountLoginPlatformTypeTianYi)];
    [platformNameMapper setObject:@"huoshan"
                           forKey:@(TTAccountLoginPlatformTypeHuoshan)];
    [platformNameMapper setObject:@"douyin"
                           forKey:@(TTAccountLoginPlatformTypeDouyin)];
    [TTAccountLoginConfLogic setLoginPlatformNames:platformNameMapper];
}

@end
