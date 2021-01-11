//
//  TTStartupUITask+LarkSSO.m
//  Pods
//
//  Created by 谢雷 on 2021/1/7.
//

#import "TTStartupUITask+LarkSSO.h"
#import <BDFeedBack/BDFBFloatingWindowManager.h> // 浮窗管理
#import <BDFeedBack/BDFBInjectedInfo.h>          // 配置信息
#import <BDFeedBack/BDFBLarkSSOManager.h>        // Lark授权
#import <ByteDanceKit/ByteDanceKit.h>
#import "FHEnvContext.h"

@implementation TTStartupUITask (LarkSSO)

+ (void)checkLarkSSOIfNeeded {
    __block void(^ssoBlock)() = ^{
        [self setRootViewControllerWithStoryboard];
        [[FHEnvContext sharedInstance] onStartApp];
    };
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveStatusUpdate)
                                                 name: BDFBLarkSSOStatusDidUpdateNotification
                                               object: nil];
    

// 采用条件宏，只在内测版，非 DEBUG，非模拟器条件下，要求通过 SSO 认证
//#if INHOUSE && !TARGET_IPHONE_SIMULATOR
#if INHOUSE && !DEBUG && !TARGET_IPHONE_SIMULATOR
    // 内测版要求通过 SSO 认证 @shengxuanwei
    BOOL ssoEnabled = [[[NSBundle mainBundle] infoDictionary] btd_boolValueForKey:@"SSO_ENABLED"];
    if (ssoEnabled) { // Info.plist 开关，用于自动化测试绕过 SSO 认证
        
        BDFBFloatingWindowManager *floatingWindowManager = [BDFBFloatingWindowManager sharedManager];
        BDFBInjectedInfo *injectInfo = [BDFBInjectedInfo sharedInfo];
        BDFBLarkSSOManager *ssoManager = [BDFBLarkSSOManager sharedManager];

        injectInfo.appID = 1370; // 必填，配置AppID，例如头条是13
        injectInfo.isLark = NO; // 必填，飞书还是Lark
        injectInfo.feishuOrLarkAppId = @"lk9c5i482wynhkzx8l"; // 必填，上述Lark的Scheme字符串
        injectInfo.language = @"zh"; // 可选，语言设置，默认为系统语言。影响鉴权的H5界面语言设定
        injectInfo.channel = @"local_test"; // 必填，渠道
        
        //测试调试使用 打包应注释
//        [[BDFBLarkSSOManager sharedManager] enableSSO];
//        ssoManager.overrideBundleId = @"com.bytedance.fp1";
        
        [[BDFBLarkSSOManager sharedManager] startVerification];
        
        [self setRootViewControllerWithStoryboard];
    } else {
        ssoBlock();
    }
#else
    ssoBlock();
#endif
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[BDFBLarkSSOManager sharedManager] handleURL:url];
}

//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
//
//}

// 处理SSO状态更新的回调
+ (void)didReceiveStatusUpdate {
    if ([BDFBLarkSSOManager sharedManager].checkStatus == BDFBLarkSSOSuccess) {
        // 成功了之后移除通知，同时隐藏本弹窗
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        btd_dispatch_async_on_main_queue(^{
            [[FHEnvContext sharedInstance] onStartApp];
        });
    }
}

@end
