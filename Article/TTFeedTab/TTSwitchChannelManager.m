//
//  TTSwitchChannelManager.m
//  Article
//
//  Created by Sunhaiyuan on 2018/1/19.
//

#import "TTSwitchChannelManager.h"
#import "TTRoute.h"
#import "TTArticleTabBarController.h"
#import "TTArticleCategoryManager.h"
#import "TTNavigationController.h"
#import "ExploreChannelListViewController.h"

@implementation TTSwitchChannelManager


+ (void)load{
    [self sharedManager];
}

static TTSwitchChannelManager *sharedManager = nil;
- (instancetype)init {
    if (self = [super init]) {
        [self registerAction];
    }
    return self;
}

+ (instancetype)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[TTSwitchChannelManager alloc] init];
    });
    return sharedManager;
}

#pragma mark - private methods
- (void)registerAction {
    WeakSelf;
    [TTRoute registerAction:^(NSDictionary *params) {
        StrongSelf;
        [self switchCategoryLogicWithParameters:params];
    } withIdentifier:@"category_feed"];

    [TTRoute registerAction:^(NSDictionary *params) {
        StrongSelf;
        [self switchCategoryLogicWithParameters:params];
    } withIdentifier:@"feed"];
}


- (void)switchCategoryLogicWithParameters:(NSDictionary *)parameters
{
    BOOL isFeedPage = YES;
    NSString *categoryID = [parameters tt_stringValueForKey:@"category"];
    if (isEmptyString(categoryID)) return;
    if ([[TTUIResponderHelper correctTopmostViewController] class] == NSClassFromString(@"TTArticleTabBarController")) {
        TTArticleTabBarController *tabBar = (TTArticleTabBarController *)[TTUIResponderHelper correctTopmostViewController];
        TTNavigationController *nav = tabBar.selectedViewController;
        if ([[nav.childViewControllers firstObject] class] == NSClassFromString(@"ArticleTabBarStyleNewsListViewController")) {
            //正在feed界面
            if (nav.childViewControllers.count > 1) {
                isFeedPage = NO;
            }
        } else {
            isFeedPage = NO;
        }
    }
    
    if (isFeedPage) {
        //当前在feed页面 直接滚动到对应category
        TTCategory *categoryModel = [TTArticleCategoryManager categoryModelByCategoryID:categoryID];
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:categoryModel forKey:@"model"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCategoryManagementViewCategorySelectedNotification object:self userInfo:userInfo];
    } else {
        //当前不在feed页面 push
        ExploreChannelListViewController *controller = [[ExploreChannelListViewController alloc] initWithRouteParams:parameters];
        [[self currentNavigationController] pushViewController:controller animated:YES];
    }
}

- (UINavigationController *)currentNavigationController {
    UINavigationController *nav = nil;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:NSSelectorFromString(@"appTopNavigationController")]) {
        nav = [[[UIApplication sharedApplication] delegate] performSelector:NSSelectorFromString(@"appTopNavigationController")];
    }
#pragma clang diagnostic pop
    
    if (nav == nil) {
        nav = (UINavigationController*)[UIApplication sharedApplication].delegate.window.rootViewController;
    }
    if (![nav isKindOfClass:[UINavigationController class]]) {
        nav = nil;
    }
    
    return nav;
}

@end

