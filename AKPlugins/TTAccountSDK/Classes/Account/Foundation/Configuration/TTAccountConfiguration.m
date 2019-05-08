//
//  TTAccountConfiguration.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/8/17.
//
//

#import "TTAccountConfiguration.h"
#import <TTNetworkManager.h>
#import "TTAccountConfiguration_Priv.h"
#import <NSDictionary+TTAdditions.h>


@interface UIResponder (TTAccountResponderHelper)

+ (UIViewController *)tta_visibleViewController;

@end

@implementation UIResponder (TTAccountResponderHelper)

+ (UIWindow *)tta_mainAppWindow
{
    UIWindow *appWindow = [[UIApplication sharedApplication].delegate window];
    if (!appWindow) appWindow = [[UIApplication sharedApplication] keyWindow];
    if (!appWindow) appWindow = [[[UIApplication sharedApplication] windows] firstObject];
    return appWindow;
}

+ (UIViewController *)tta_visibleViewController
{
    UIViewController *rootVC = [self tta_mainAppWindow].rootViewController;
    return [self tta_visibleViewControllerInVC:rootVC];
}

+ (UIViewController *)tta_visibleViewControllerInVC:(UIViewController *)rootVC
{
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootVC;
        return [self tta_visibleViewControllerInVC:tabBarController.selectedViewController];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)rootVC;
        return [self tta_visibleViewControllerInVC:navController.visibleViewController];
    } else if (rootVC.presentedViewController) {
        return [self tta_visibleViewControllerInVC:rootVC.presentedViewController];
    } else if ([rootVC isKindOfClass:[UIViewController class]]) {
        return rootVC;
    }
    return nil;
}

@end



#pragma mark - TTAccountConfiguration

NSString *TTAccountInstallIdKey      = @"install_id";
NSString *TTAccountDeviceIdKey       = @"device_id";
NSString *TTAccountFromSessionKeyKey = @"from_session_key";
NSString *TTAccountSessionKeyKey     = @"session_key";
NSString *TTAccountSSAppIdKey        = @"app_id";

@implementation TTAccountConfiguration

- (instancetype)init
{
    if ((self = [super init])) {
        _multiThreadSafeEnabled = NO;
        _unbindAlertEnabled     = YES;
        _showAlertWhenLoginFail = YES;
        _byFindPasswordLoginEnabled = YES;
        _autoSynchronizeUserInfo    = NO;
    }
    return self;
}

- (void)dealloc
{
    _visibleViewControllerHandler   = nil;
    _loggerDelegate                 = nil;
    _monitorDelegate                = nil;
    _accountMessageFirstResponder   = nil;
    _networkParamsHandler           = nil;
}

#pragma mark - Getter/Setter

- (NSDictionary * (^)(void))networkParamsHandler
{
    return ^NSDictionary *() {
        // 取TTNetworkManager中参数
        NSMutableDictionary *mutParamsDict = [[TTNetworkManager shareInstance].commonParams mutableCopy];
        if (!mutParamsDict) mutParamsDict  = [NSMutableDictionary dictionary];
        
        if ([TTNetworkManager shareInstance].commonParamsblock) {
            NSDictionary *outsideDyNetParams = [TTNetworkManager shareInstance].commonParamsblock();
            if ([outsideDyNetParams count] > 0) {
                [mutParamsDict addEntriesFromDictionary:outsideDyNetParams];
            }
        }
        
        // 取默认参数
        [mutParamsDict addEntriesFromDictionary:[self.class tta_defaultURLParameters]];
        
        // 取调用方动态配置参数
        if (_networkParamsHandler) {
            NSDictionary *dNetParams = _networkParamsHandler();
            if ([dNetParams count] > 0) {
                [mutParamsDict addEntriesFromDictionary:dNetParams];
            }
        }
        
        // ugly code : 版本号映射关系计算。同TTNetSerializer中逻辑，暂时为了解耦copy代码。后续整体干掉映射关系
        NSString *versionKey = @"version_code";
        NSString *curVersion = [mutParamsDict tt_stringValueForKey:versionKey];
        NSArray<NSString *> *strArray = [curVersion componentsSeparatedByString:@"."];
        NSInteger version = 0;
        for (NSInteger i = 0; i < strArray.count; i += 1) {
            NSString *tmp = strArray[i];
            version = version * 10 + tmp.integerValue;
        }
        version += 0;
        NSMutableArray *newStrArray = [NSMutableArray arrayWithCapacity:3];
        for (NSInteger i = 0; i < 2; i += 1) {
            NSInteger num = version % 10;
            version /= 10;
            NSString *tmp = [NSString stringWithFormat:@"%ld", num];
            [newStrArray addObject:tmp];
        }
        NSString *tmp = [NSString stringWithFormat:@"%ld",version];
        [newStrArray addObject:tmp];
        NSString *newVersion = [[newStrArray reverseObjectEnumerator].allObjects componentsJoinedByString:@"."];
        [mutParamsDict setValue:newVersion forKey:versionKey];
        
        return mutParamsDict;
    };
}

- (UIViewController * (^)(void))visibleViewControllerHandler
{
    return ^UIViewController *() {
        UIViewController *currentVC = nil;
        if (_visibleViewControllerHandler) {
            currentVC = _visibleViewControllerHandler();
        }
        if (!currentVC) {
            currentVC = [UIResponder tta_visibleViewController];
        }
        if (!currentVC) {
            NSAssert(NO, @"cann't get visible viewController, can't present TTACustomWapAuthViewController");
        }
        return currentVC;
    };
}

@end
