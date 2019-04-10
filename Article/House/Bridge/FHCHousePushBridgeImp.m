//
//  FHCHousePushBridgeImp.m
//  Article
//
//  Created by 张静 on 2019/4/10.
//

#import "FHCHousePushBridgeImp.h"
#import "ExploreMovieView.h"
#import "TTVPlayVideo.h"
#import "SSFeedbackManager.h"
#import "SSFeedbackViewController.h"
#import "CommonURLSetting.h"
#import "TTAdSplashMediator.h"
#import "NewsBaseDelegate.h"
#import "TTLaunchTracer.h"
#import "TTDetailContainerViewController.h"
#import "TTBackgroundModeTask.h"
#import "SSUserSettingManager.h"
#import "TTIntroduceViewTask.h"
#import "TTProjectLogicManager.h"

@implementation FHCHousePushBridgeImp

- (BOOL)isFullScreen
{
    return [ExploreMovieView isFullScreen];
}

- (BOOL)isTTVPlayVideoFullScreenOrRotating
{
    return [[TTVPlayVideo currentPlayingPlayVideo].player.context isFullScreen] || [[TTVPlayVideo currentPlayingPlayVideo].player.context isRotating];
}

- (BOOL)isFullScreenViewClass:(UIView *)aView
{
    return [aView isKindOfClass:[ExploreMovieView class]] || [aView isKindOfClass:[TTVPlayVideo class]];
}

- (BOOL)hasNewFeedback
{
    return [SSFeedbackManager hasNewFeedback];
}

- (UIViewController *)feedbackViewController
{
    return [[SSFeedbackViewController alloc] init];
}

- (void)setSplashADShowTypeHide
{
    [TTAdSplashMediator shareInstance].splashADShowType = TTAdSplashShowTypeHide;

}

- (UINavigationController*)appTopNavigationController
{
    return [SharedAppDelegate appTopNavigationController];
}

+ (NSString*)appNoticeStatusURLString
{
    return [CommonURLSetting appNoticeStatusURLString];
}

- (void)setTTTrackerLaunchFromRemotePush
{
    [[TTLaunchTracer shareInstance] setLaunchFrom:TTAPPLaunchFromRemotePush];

}

- (NSString*)appAlertURLString
{
    return [CommonURLSetting appAlertURLString];
}

- (NSString*)appAlertActionURLString
{
    return [CommonURLSetting appAlertActionURLString];
}

- (UIResponder *)houseAppDelegate
{
    return SharedAppDelegate;
}

- (id)apnsManagerDelegate
{
    return SharedAppDelegate;
}

- (void)push2ArticleDetailPage:(id)article
{
    if ([article conformsToProtocol:@protocol(TTVArticleProtocol)]) {
        
        NewsGoDetailFromSource source = NewsGoDetailFromSourceAPNS;
        TTDetailContainerViewController *detailController = [[TTDetailContainerViewController alloc] initWithArticle:article
                                                                                                              source:source
                                                                                                           condition:nil];
        [[SharedAppDelegate appTopNavigationController] pushViewController:detailController animated:YES];
    }
}

- (void)reportDeviceTokenByAppLogout
{
    [TTBackgroundModeTask reportDeviceTokenByAppLogout];
}

- (void)showIntroductionView
{
    [TTIntroduceViewTask showIntroductionView];
}

- (void)setIsColdLaunch:(BOOL)isCold
{
    [SharedAppDelegate setIsColdLaunch:YES];
}

- (void)startRegisterRemoteNotificationAfterDelay:(int)secs
{
    [NewsBaseDelegate startRegisterRemoteNotificationAfterDelay:secs];
}

- (BOOL)isAdShowing
{
    return [[TTAdSplashMediator shareInstance] isAdShowing];
}

- (BOOL)shouldShowIntroductionView
{
    return [SSUserSettingManager shouldShowIntroductionView];
}

- (BOOL)logicBoolForKey:(NSString *)key
{
    return [[TTProjectLogicManager sharedInstance_tt] logicBoolForKey:key defaultValue:NO];
}





@end
