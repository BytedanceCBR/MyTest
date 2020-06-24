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
#import "TTSandBoxHelper.h"
#import "FHUtils.h"
#import <FHHouseBase/FHPermissionAlertViewController.h>
#import <FHHouseBase/FHIntroduceManager.h>


DEC_TASK_N(TTStartupUITask,FHTaskTypeUI,TASK_PRIORITY_HIGH);

@implementation TTStartupUITask

- (NSString *)taskIdentifier {
    return @"UI";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    
    double before = CFAbsoluteTimeGetCurrent();
    
    [[self class] makeKeyWindowVisible];
    if ([[TTThemeManager sharedInstance_tt] respondsToSelector:@selector(applyBundleName:)]) {
        [[TTThemeManager sharedInstance_tt] performSelector:@selector(applyBundleName:) withObject:@"FHHouseBase"];
    }
    [self registerHomePageViewControllers];
    [[self class] setLaunchController];
    
    //待首页view初始化后 再执行切tab
    
    NSString *lastCityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
    BOOL hasSelectedCity = [(id)[FHUtils contentForKey:kUserHasSelectedCityKey] boolValue];

    if (hasSelectedCity) {
        NSString *defaultTabName = [FHEnvContext defaultTabName];
        if ([FHEnvContext isUGCAdUser] && [FHEnvContext isUGCOpen]) {
            [[FHEnvContext sharedInstance] jumpUGCTab];
        }else if(defaultTabName.length > 0){
            [[FHEnvContext sharedInstance] jumpTab:defaultTabName];
        }else{
            if (![FHEnvContext isCurrentCityNormalOpen] && lastCityId) {
                [[FHEnvContext sharedInstance] jumpUGCTab];
            }
        }
    }

    if (lastCityId) {
        [[FHEnvContext sharedInstance] checkUGCADUserIsLaunch:NO];
    }

    // 后续inhouse功能都可以在此处添加添加
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configInHouseFunc];
    });
    
    if ([[FHEnvContext sharedInstance] hasConfirmPermssionProtocol]) {
        [NewsBaseDelegate startRegisterRemoteNotification];
    }    
}

// 是否在内测版本开启某些功能
- (void)configInHouseFunc {
    // 内测泄漏检测-企业包
    if ([TTSandBoxHelper isInHouseApp] && NSClassFromString(@"FHDebugTools")) {
        Class cls = NSClassFromString(@"FHDebugTools");
        id instance = [[cls alloc] init];
        [instance performSelector:@selector(configMemLeaks)];
    }
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
            SEL sel = NSSelectorFromString(@"requestSSOAuthExceptIntranet:completionHandler:");
            NSMethodSignature *sig = [c instanceMethodSignatureForSelector:sel];
            ssoBlock = [ssoBlock copy];
            BOOL exceptIntranet = YES;
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
            [invocation setArgument:(void *)&exceptIntranet atIndex:2];
            [invocation setArgument:(void *)&ssoBlock atIndex:3];
            [invocation retainArguments];
            invocation.selector = sel;
            [invocation invokeWithTarget:instance];
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
    if([SSCommonLogic isFHNewLaunchOptimizeEnabled]) {
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
     YYCache *epidemicSituationCache = [[FHEnvContext sharedInstance].generalBizConfig epidemicSituationCache];
    FHConfigCenterTabModel *cacheTab = [epidemicSituationCache objectForKey:@"tab_cache"];

    NSMutableArray *tabRegisterArr = [[NSMutableArray alloc]initWithObjects:kTTTabHomeTabKey,kFHouseFindTabKey,kFHouseMessageTabKey,kFHouseMineTabKey, nil];
    if (cacheTab.enable && cacheTab.openUrl.length>0 && [epidemicSituationCache objectForKey:@"esituationNormalImage"] && [epidemicSituationCache objectForKey:@"esituationHighlightImage"]) {
        [tabRegisterArr insertObject:kFHouseHouseEpidemicSituationTabKey atIndex:2];
        cacheTab.isShow = true;
    }
    [tabRegisterArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj) {
            BOOL isRegular = ![obj isEqualToString:kFHouseHouseEpidemicSituationTabKey] || cacheTab.title.length>0;
            [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:obj atIndex:idx isRegular:isRegular];
        }
    }];
    //HomeTab
    //VideoTab
//    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:kFHouseFindTabKey atIndex:1 isRegular:YES];s

//    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:kTTTabVideoTabKey atIndex:1 isRegular:YES];

    //pm@李响说所有用户默认第三和第四个tab分别是微头条和火山小视频
//    NSString *thirdTag = [self thirdTabBarIdentifier];
//    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:thirdTag atIndex:2 isRegular:YES];
//    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:kFHouseMessageTabKey atIndex:2 isRegular:YES];

//    NSString *forthTag = [self forthTabBarIdentifier];
//    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:forthTag atIndex:3 isRegular:YES];
//    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:kFHouseMineTabKey atIndex:3 isRegular:YES];
//     [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:kFHouseHouseEpidemicSituationTabKey atIndex:4 isRegular:YES];

}

//第五个tab
- (NSString *)fifthTabBarIdentifier
{
    return kTTTabMineTabKey;
}

@end
