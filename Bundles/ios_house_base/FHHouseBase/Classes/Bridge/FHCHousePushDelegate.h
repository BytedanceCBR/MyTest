//
//  FHCHousePushDelegate.h
//  FHHouseBase
//
//  Created by 张静 on 2019/4/10.
//

#ifndef FHCHousePushDelegate_h
#define FHCHousePushDelegate_h


@protocol FHCHousePushDelegate <NSObject>

@optional

- (BOOL)isFullScreen;
- (BOOL)isTTVPlayVideoFullScreenOrRotating;
- (BOOL)isFullScreenViewClass:(UIView *)aView;
- (BOOL)hasNewFeedback;
- (UIViewController *)feedbackViewController;
- (void)setSplashADShowTypeHide;
- (UINavigationController*)appTopNavigationController;
- (NSString*)appNoticeStatusURLString;
- (void)setTTTrackerLaunchFromRemotePush;
- (NSString*)appAlertURLString;
- (NSString*)appAlertActionURLString;
- (UIResponder *)houseAppDelegate;
- (id)apnsManagerDelegate; // <ArticleAPNsManagerDelegate>
- (void)push2ArticleDetailPage:(id)article;
- (void)reportDeviceTokenByAppLogout;
- (void)showIntroductionView;
- (void)setIsColdLaunch:(BOOL)isCold;
- (void)startRegisterRemoteNotificationAfterDelay:(int)secs;
- (BOOL)isAdShowing;
- (BOOL)shouldShowIntroductionView;
- (BOOL)logicBoolForKey:(NSString *)key;
- (NSString *)logicStringForKey:(NSString *)key;

@end

#endif /* FHCHousePushDelegate_h */
