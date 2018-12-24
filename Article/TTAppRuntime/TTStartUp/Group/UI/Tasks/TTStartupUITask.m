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
#import "FHEnvContext.h"

@implementation TTStartupUITask

- (NSString *)taskIdentifier {
    return @"UI";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
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


    //TTTabBarController还是先用storyBoard加载，否则tabBar上出飘新提示的时第三个Tab上面容易出现小灰条的问题
    if([SSCommonLogic isNewLaunchOptimizeEnabled]) {
        
        SharedAppDelegate.window.rootViewController = [[TTArticleTabBarController alloc] init];
    } else {
        SharedAppDelegate.window.rootViewController = [[UIStoryboard storyboardWithName:name bundle:nil] instantiateInitialViewController];
    }
//    [[TTFantasyTimeCountDownManager sharedManager] fetchFantasyActivityTimes];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[EnvContext shared] client] onStart];
        [[FHEnvContext sharedInstance] onStartApp];
    });

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
    if (isEmptyString(schema) && [TTTabBarProvider hasPriorMiddleTab] &&[[TTTabBarProvider allSupportedTags] containsObject:identifier]) {
        [[TTTabBarManager sharedTTTabBarManager] registerTabBarforIndentifier:identifier atIndex:2 isRegular:NO];
    }
    
    //aikan tab
    [[AKActivityTabManager sharedManager] updateActivityTabHiddenState:![[AKTaskSettingHelper shareInstance] isEnableShowTaskEntrance]];
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

- (NSString *)thirdTabBarIdentifier {
    return kTTTabHTSTabKey;
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

    return kAKTabActivityTabKey;
}

//第五个tab
- (NSString *)fifthTabBarIdentifier
{
    return kTTTabMineTabKey;
}

@end
