//
//  TTIntroduceViewTask.m
//  Article
//
//  Created by fengyadong on 17/1/19.
//
//

#import "TTIntroduceViewTask.h"
#import "NewsBaseDelegate.h"
#import "SSUserSettingManager.h"
#import <TTAccountBusiness.h>
#import "TTAccountLoginViewControllerGuide.h"
//#import "SSADManager.h"
#import "TTAdSplashMediator.h"
//#import "TTContactsUserDefaults.h"
#import "TTProjectLogicManager.h"
#import "SSIntroduceViewController.h"



@implementation TTIntroduceViewTask

- (NSString *)taskIdentifier {
    return @"IntroduceView";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    //没有开屏广告的时候再弹出登录引导
    BOOL shouldShowIntroductionView = [SSUserSettingManager shouldShowIntroductionView];
    
    BOOL isTrying = NO;
    if (!TTLogicBool(@"isI18NVersion", NO)) {
        isTrying = [TTAccountManager tryAssignAccountInfoFromKeychain];
    }
    
//    BOOL isSplashDisplaying = [[SSADManager shareInstance] isSplashADShowed];
    BOOL isSplashDisplaying = [TTAdSplashMediator shareInstance].isAdShowing;
    if ((shouldShowIntroductionView && !isTrying && !isSplashDisplaying) && [SharedAppDelegate appTopNavigationController]) {
//        [[self class] showIntroductionView];
    }
    else {
        [NewsBaseDelegate startRegisterRemoteNotificationAfterDelay:0.5];
    }
}

+ (void)showIntroductionView {
    if ([SSUserSettingManager shouldShowIntroductionView]) {
        wrapperTrackEvent(@"guide", @"show");
    }
    
    if ([SSCommonLogic accountABVersionEnabled]) {
        TTAccountLoginViewControllerGuide *loginVCGuide = [TTAccountLoginViewControllerGuide new];
        [[TTGuideDispatchManager sharedInstance_tt] addGuideViewItem:loginVCGuide withContext:self];
    }
    else {
        NSString * className = TTLogicString(@"IntroduceViewController", @"SSIntroduceViewController");
        Class cls = NSClassFromString(className);
        if (!cls) {
            cls = [SSIntroduceViewController class];
        }
        UIViewController<TTGuideProtocol> * introduceViewController = [[cls alloc] init];
        if ([introduceViewController isKindOfClass:[SSIntroduceViewController class]]) {
            [[TTGuideDispatchManager sharedInstance_tt] addGuideViewItem:introduceViewController withContext:self];
        }
    }
}

@end
