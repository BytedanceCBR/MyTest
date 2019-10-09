//
//  TTStartupUITask.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTStartupUITask.h"
#import "NewsBaseDelegate.h"
#import "TTNavigationController.h"
#import "TTArticleTabBarController.h"
#import "ArticleTabbarStyleNewsListViewController.h"
#import "TTVVideoTabViewController.h"
#import "TTVideoTabViewController.h"
//#import "TTWeitoutiaoViewController.h"
#import "TTTabBarManager.h"
//#import "TTSFActivityMainViewController.h"
//#import "TTFollowWebViewController.h"
#import "TTProfileViewController.h"
#import "TTSettingsManager.h"
#import "TTTabBarProvider.h"
#import "TTTabBar.h"
//#import "TTFantasyTimeCountDownManager.h"
#import "AKTaskSettingHelper.h"
#import "FHEnvContext.h"
#import "SSCommonLogic.h"

#import "TTLaunchDefine.h"
#import "BDSSOAuthManager.h"
#import "NSDictionary+TTAdditions.h"
#import "TTInstallIDManager.h"

#if INHOUSE
#import "MLeaksConfig.h"
#import "MLeaksFinder.h"
#endif

DEC_TASK_N(TTStartupUITask,FHTaskTypeUI,TASK_PRIORITY_HIGH);

@implementation TTStartupUITask

- (NSString *)taskIdentifier {
    return @"UI";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    [[self class] makeKeyWindowVisible];
    if ([[TTThemeManager sharedInstance_tt] respondsToSelector:@selector(applyBundleName:)]) {
        [[TTThemeManager sharedInstance_tt] performSelector:@selector(applyBundleName:) withObject:@"FHHouseBase"];
    }
    [self registerHomePageViewControllers];
    [[self class] setLaunchController];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configMemLeaks];
    });
}

// 是否开启内存泄漏检测
- (void)configMemLeaks {
// 采用条件宏，只在内测版
#if INHOUSE
    NSString * appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * buildVersionRaw = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UPDATE_VERSION_CODE"];
    NSString *deviceId = [[TTInstallIDManager sharedInstance] deviceID];
    NSString *didStr = [NSString stringWithFormat:@"Device ID:\n%@",deviceId];
    MLeaksConfig *config = [[MLeaksConfig alloc] initWithAid:@"1370"
                                  enableAssociatedObjectHook:YES
                                                     filters:nil
                                               viewStackType:MLeaksViewStackTypeViewController
                                                  appVersion:appVersion
                                                   buildInfo:buildVersionRaw
                                               userInfoBlock:^NSString *{
                                                   return didStr;
                                               }];
    [TTMLeaksFinder startDetectMemoryLeakWithConfig:config];
#endif
}

+ (void)makeKeyWindowVisible {
    SharedAppDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

+ (void)setLaunchController
{
    [self setPhoneLaunchViewController];
}

+ (void)setPhoneLaunchViewController
{
    __block void(^ssoBlock)() = ^{
        [self setRootViewControllerWithStoryboardName:@"RootTab"];
    };    
// 采用条件宏，只在内测版，非 DEBUG，非模拟器条件下，要求通过 SSO 认证
#if INHOUSE && !DEBUG && !TARGET_IPHONE_SIMULATOR
    // 内测版要求通过 SSO 认证 @shengxuanwei
    BOOL ssoEnabled = [[[NSBundle mainBundle] infoDictionary] tt_boolValueForKey:@"SSO_ENABLED"];
    if (ssoEnabled) { // Info.plist 开关，用于自动化测试绕过 SSO 认证
        Class c = NSClassFromString(@"BDSSOAuthManager");
        if (c) {
            id instance = [c sharedInstance];
            [instance performSelector:NSSelectorFromString(@"requestSSOAuthWithCompletionHandler:") withObject:ssoBlock];
        }
    } else {
        ssoBlock();
    }
#else
    ssoBlock();
#endif
}

+ (void)setRootViewControllerWithStoryboardName:(NSString *)name {
    // TTTabBarController还是先用storyBoard加载，否则tabBar上出飘新提示的时第三个Tab上面容易出现小灰条的问题
    if([SSCommonLogic isNewLaunchOptimizeEnabled]) {
        SharedAppDelegate.window.rootViewController = [[TTArticleTabBarController alloc] init];
    } else {
        SharedAppDelegate.window.rootViewController = [[UIStoryboard storyboardWithName:name bundle:nil] instantiateInitialViewController];
    }

    [SharedAppDelegate.window makeKeyAndVisible];
    [[FHEnvContext sharedInstance] onStartApp];
}

- (void)registerHomePageViewControllers {
//    //HomeTab
//    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:kTTTabHomeTabKey atIndex:0 isRegular:YES];
//
//    //VideoTab
//    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:kTTTabVideoTabKey atIndex:1 isRegular:YES];
    
    NSArray *tags = [TTTabBarProvider confTabList];
    
    if (!SSIsEmptyArray(tags)) {
        //最多取前五个
        NSUInteger maxLength = MIN(5, tags.count);
        NSArray *properTags = [tags subarrayWithRange:NSMakeRange(0, maxLength)];
        
        BOOL isAbnormal = NO;
        
        for (NSString *tag in properTags) {
            if(![[TTTabBarProvider allSupportedTags] containsObject:tag]) {
                isAbnormal = YES;
                break;
            }
        }
        
        if (properTags.count == 1) {
            isAbnormal = YES;
        }
        
        if (!isAbnormal) {
            [properTags enumerateObjectsUsingBlock:^(NSString *_Nonnull tag, NSUInteger idx, BOOL * _Nonnull stop) {
                [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:tag atIndex:idx isRegular:YES];
            }];
        } else {
            [self constructDefaultTabs];
        }
    } else {
        [self constructDefaultTabs];
    }
    
    //middle tab
    NSString *schema = [TTTabBarProvider priorMiddleTabSchema];
    NSString *identifier = [TTTabBarProvider priorMiddleTabIdentifier];
    if (isEmptyString(schema) && [TTTabBarProvider hasPriorMiddleTab] &&[[TTTabBarProvider allSupportedTags] containsObject:identifier]) {
        [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:identifier atIndex:2 isRegular:NO];
    }
}

- (void)constructDefaultTabs {
    //HomeTab
    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:kTTTabHomeTabKey atIndex:0 isRegular:YES];
    
    //VideoTab
    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:kFHouseFindTabKey atIndex:1 isRegular:YES];

//    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:kTTTabVideoTabKey atIndex:1 isRegular:YES];

    //pm@李响说所有用户默认第三和第四个tab分别是微头条和火山小视频
//    NSString *thirdTag = [self thirdTabBarIdentifier];
//    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:thirdTag atIndex:2 isRegular:YES];
    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:kFHouseMessageTabKey atIndex:2 isRegular:YES];

//    NSString *forthTag = [self forthTabBarIdentifier];
//    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:forthTag atIndex:3 isRegular:YES];
    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:kFHouseMineTabKey atIndex:3 isRegular:YES];

}

//第五个tab
- (NSString *)fifthTabBarIdentifier
{
    return kTTTabMineTabKey;
}

@end
