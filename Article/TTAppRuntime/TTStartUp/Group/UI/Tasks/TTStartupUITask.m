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
#import "TSVTabViewController.h"
#import "TTHTSTabViewController.h"
#import "TTTabBarProvider.h"
#import "TTTabBar.h"
//#import "TTFantasyTimeCountDownManager.h"
#import "AKActivityTabManager.h"
#import "AKTaskSettingHelper.h"
#import "Bubble-Swift.h"
@implementation TTStartupUITask

- (NSString *)taskIdentifier {
    return @"UI";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    [[[EnvContext shared] client] onStart];
    [[self class] makeKeyWindowVisible];
    [self registerHomePageViewControllers];
    [[self class] setLaunchController];
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
    [self setRootViewControllerWithStoryboardName:@"RootTab"];
}

+ (void)setRootViewControllerWithStoryboardName:(NSString *)name {

    [[[EnvContext shared] client] onStart];

    //TTTabBarController还是先用storyBoard加载，否则tabBar上出飘新提示的时第三个Tab上面容易出现小灰条的问题
    if([SSCommonLogic isNewLaunchOptimizeEnabled]) {
        UIViewController* rootVC = [[TTArticleTabBarController alloc] init];
        UINavigationController* nav = [[EnvContext shared] rootNavController];
        nav.viewControllers = @[rootVC];
        SharedAppDelegate.window.rootViewController = nav;
    } else {
        UIViewController* rootVC = [[UIStoryboard storyboardWithName:name bundle:nil] instantiateInitialViewController];
        UINavigationController* nav = [[EnvContext shared] rootNavController];
        nav.viewControllers = @[rootVC];
        SharedAppDelegate.window.rootViewController = nav;
    }
    [SharedAppDelegate.window makeKeyAndVisible];
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
    if (isEmptyString(schema) && [TTTabBarProvider hasPriorMiddleTab] && [[TTTabBarProvider allSupportedTags] containsObject:identifier]) {
        [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:identifier atIndex:2 isRegular:NO];
    }
    
    //aikan tab
    [[AKActivityTabManager sharedManager] updateActivityTabHiddenState:![[AKTaskSettingHelper shareInstance] isEnableShowTaskEntrance]];
}

- (void)constructDefaultTabs {

    //TODO f100 加载房产页面
    //VideoTab
    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:kFHouseHomeTabKey atIndex:0 isRegular:YES];

    // f100 去掉发现页签
    //HomeTab
    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:kFHouseMessageTabKey atIndex:1 isRegular:YES];
    //pm@李响说所有用户默认第三和第四个tab分别是微头条和火山小视频
//    NSString *thirdTag = [self thirdTabBarIdentifier];
    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:kFHouseMineTabKey atIndex:2 isRegular:YES];
    
//    NSString *forthTag = [self forthTabBarIdentifier];
//    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:forthTag atIndex:3 isRegular:YES];

//    NSString *fifthTag = [self fifthTabBarIdentifier];
//    [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:fifthTag atIndex:3 isRegular:YES];
}

- (NSString *)thirdTabBarIdentifier {
    return kFHouseMessageTabKey;
//    if ([SSCommonLogic isThirdTabHTSEnabled]) {
//        return kTTTabHTSTabKey;
//    } else if ([SSCommonLogic isThirdTabWeitoutiaoEnabled]) {
//        return kTTTabWeitoutiaoTabKey;
//    }
//
//    return kTTTabWeitoutiaoTabKey;
}

//第四个tab
- (NSString *)forthTabBarIdentifier
{
//    if ([SSCommonLogic isForthTabHTSEnabled]) {
//        return kTTTabHTSTabKey;
//    }
//    else {
//        return kTTTabMineTabKey;
//    }

    return kTTTabHTSTabKey;
}

//第五个tab
- (NSString *)fifthTabBarIdentifier
{
    return kFHouseMineTabKey;
}

@end
