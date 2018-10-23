//
//  TTVVideoDetailViewController+ExtendLink.m
//  Article
//
//  Created by pei yun on 2017/5/18.
//
//

#import "TTVVideoDetailViewController+ExtendLink.h"
#import "TTIndicatorView.h"
#import "Article.h"
#import "SSAppStore.h"
#import "ExploreMovieView.h"
#import "TTDetailModel.h"
#import "SSADActionManager.h"
#import "TTAlphaThemedButton.h"
#import "TTNavigationController.h"
#import "TTDetailNatantVideoADView.h"
#import "ArticleVideoPosterView.h"
#import "TTMovieExitFullscreenAnimatedTransitioning.h"
#import <objc/runtime.h>
#import "TTVideoShareMovie.h"
#import "SSURLTracker.h"
#import "TTDetailModel+videoArticleProtocol.h"
#import "TTVVideoDetailNatantADView.h"
#import "TTVVideoDetailViewController_Private.h"
#import "TTVideoDetailHeaderPosterView.h"
#import "TTVDetailPlayControl.h"
#import "TTVPlayVideo.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"

static void *kTTVMovieViewMaskView = &kTTVMovieViewMaskView;

extern NSString *const TTVDidExitFullscreenNotification;

@implementation TTVVideoDetailViewController (ExtendLink)

@dynamic shouldPresentAdLater;

- (void)setMaskView:(UIView *)maskView
{
    objc_setAssociatedObject(self, kTTVMovieViewMaskView, maskView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)maskView
{
    UIView *view = objc_getAssociatedObject(self, kTTVMovieViewMaskView);
    view.backgroundColor = [UIColor blackColor];
    if (!view) {
        view = [[UIView alloc] init];
        self.maskView = view;
    }
    return view;
}

- (UIViewController *)openAppStoreWithExtendLink:(NSDictionary *)extendLink
{
    NSString *actionURL = [extendLink valueForKey:@"url"];
    NSString *appleID = [extendLink valueForKey:@"apple_id"];
    if (([appleID length] == 0 && [actionURL length] > 0))
    {
        if ([actionURL length] == 0) {
            return nil;
        }
        NSURL * url = [TTStringHelper URLWithURLString:actionURL];
        [[UIApplication sharedApplication] openURL:url];
        [self trackShow:NO];
    }
    else
    {
        if ([appleID length] > 0) {
            
            SKStoreProductViewController * skController = [[TTAdAppDownloadManager sharedManager] SKViewControllerPreloadId:appleID];
            skController.view.frame = CGRectMake(0, self.movieContainerView.bottom, self.view.width, self.view.height - self.movieContainerView.bottom);
            return skController;
        }
    }
    return nil;
}

- (void)addBackButton
{
    CGFloat topMargin = [TTDeviceHelper isIPhoneXDevice] ? 44 : 0;
    self.backButton = [[TTAlphaThemedButton alloc] init];
    self.backButton.frame = CGRectMake(0, topMargin, 44, 44);
    [self.backButton setImage:[UIImage imageNamed:@"shadow_lefterback_titlebar"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self.movieView.superview addSubview:self.backButton];
}

- (void)extendLinkViewControllerWillAppear
{
    
}

- (void)playerPlaybackState:(TTVVideoPlaybackState)state
{
    if (state == TTVVideoPlaybackStateFinished && !self.linkView.hasEnterFull) {
        [self.linkView autoFull];
    }
}

- (void)showExtendLinkViewWithArticle:(id<TTVArticleProtocol>)article isAuto:(BOOL)isAuto
{
    [self.playControl.movieView.player registerDelegate:self];
    //article 是 TTVVideoInformationResponse 没有logExtra
    self.detailStateStore.state.forbidFullScreenWhenPresentAd = YES;
    if (!isAuto) {
        [self trackClickDetail];
    }
    NSMutableDictionary *extendLink = [NSMutableDictionary dictionaryWithDictionary:article.videoExtendLink];
    [extendLink setValue:self.detailModel.adLogExtra forKey:@"log_extra"];
    if (self.ttStatusBarStyle == UIStatusBarStyleLightContent) {
        [extendLink setValue:@"white" forKey:@"status_bar_color"];
    }
    if ([[extendLink valueForKey:@"is_download_app"] boolValue])
    {
        UIViewController *controller = [self openAppStoreWithExtendLink:extendLink];
        self.presentController = controller;
        if (!controller) {
            return;
        }
        
        self.movieViewSuperView = self.movieView.superview;
        self.movieViewOriginFrame = self.movieView.frame;
        
        if ([[extendLink valueForKey:@"open_new_page"] boolValue] || [TTDeviceHelper isPadDevice])
        {
            [self pauseMovieIfNeeded];
            [[TTAdAppDownloadManager sharedManager] pushSkController:(SKStoreProductViewController *)controller controller:[TTUIResponderHelper topNavigationControllerFor:nil] completion:nil postNoti:YES];
        }
        else
        {
            controller.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            controller.providesPresentationContextTransitionStyle = YES;
            controller.definesPresentationContext = YES;
            BOOL animated = YES;
            if ([self systemlowThan9]) {
                animated = NO;
            }
            [[TTAdAppDownloadManager sharedManager] pushSkController:(SKStoreProductViewController *)controller controller:[TTUIResponderHelper topNavigationControllerFor:nil] completion:^{
                controller.view.frame = CGRectMake(0, self.movieContainerView.bottom, self.view.width, self.view.height - self.movieContainerView.bottom);
                controller.view.superview.backgroundColor = [UIColor clearColor];
                controller.view.backgroundColor = [UIColor clearColor];
                self.movieView.frame = CGRectMake(0, self.movieContainerView.top, self.view.width, self.movieView.height);
                [controller.view.superview addSubview:self.movieView];
                if (@available(iOS 11.0, *)) {
                    controller.view.hidden = NO;
                }
                [self addBackButton];
            } postNoti:NO];
            if (@available(iOS 11.0, *)) {  //规避iOS11预加载恶心的bug
                controller.view.hidden = YES;
            }
            [self trackShow:isAuto];
        }
        
    }
    else
    {
        if ([[extendLink valueForKey:@"open_new_page"] boolValue])
        {
            UIViewController *web = [TTVideoExtendLinkHelper webControllerWithParameters:extendLink];
            web.ttDisableDragBack = YES;
            TTNavigationController *nav = [[TTNavigationController alloc] initWithRootViewController:web];
            nav.ttDefaultNavBarStyle = @"White";
            [self.navigationController presentViewController:nav animated:YES completion:^{
                
            }];
        }
        else
        {
            TTVideoLinkView *linkView = [TTVideoExtendLinkHelper linkViewWithHalfFrame:CGRectMake(0, [self pageBottom], self.view.width, self.view.height - [self pageBottom]) fullFrame:CGRectMake(0, 0, self.view.width, self.view.height) parentViewController:self parameters:extendLink];
            self.linkView = linkView;
            linkView.delegate = self;
            [self.view addSubview:linkView];
        }
        [self trackShow:isAuto];
    }
}

- (BOOL)systemlowThan9
{
    return [UIDevice currentDevice].systemVersion.floatValue < 9;
}

- (CGFloat)pageBottom
{
    CGFloat bottom = self.movieContainerView.bottom;
    if (!self.embededAD.hidden) {
        CGRect rect = [self.embededAD.superview convertRect:self.embededAD.frame toView:self.view];
        bottom = CGRectGetMaxY(rect);
    }
    bottom = MAX(bottom, self.movieContainerView.bottom);
    return bottom;
}

- (void)dismissSKStoreProductViewController
{
    [self.presentController dismissViewControllerAnimated:NO completion:^{
        if ([self.presentController isKindOfClass:[SKStoreProductViewController class]]) {
            if (![[self.detailModel.protocoledArticle.videoExtendLink valueForKey:@"open_new_page"] boolValue]) {
                [self trackClose];
            }
        }
    }];
}

- (void)backButtonClicked
{
    [self.presentController dismissViewControllerAnimated:NO completion:^{
        if ([self.presentController isKindOfClass:[SKStoreProductViewController class]]) {
            if (![[self.detailModel.protocoledArticle.videoExtendLink valueForKey:@"open_new_page"] boolValue]) {
                [self removeMovieView];
                [self trackClose];
            }
        }
        [self backAction];
    }];
}

- (BOOL)shouldPauseMovieWhenShow
{
    if (![[self.detailModel.protocoledArticle.videoExtendLink valueForKey:@"open_new_page"] boolValue] && [[self.detailModel.protocoledArticle.videoExtendLink valueForKey:@"is_download_app"] boolValue] && [self systemlowThan9])
    {
        return NO;
    }
    return YES;
}

- (void)showExtendLinkViewWithArticle:(id<TTVArticleProtocol>)article
{
    if ([article showExtendLink]) {
        if (!self.playControl.movieView || [self.playControl isMovieFullScreen]) {
            //此时视频处于全屏状态，不能弹出广告
            self.shouldPresentAdLater = @(YES);
        } else {
            self.shouldPresentAdLater = @(NO);
            [self showExtendLinkViewWithArticle:article isAuto:YES];
        }
    }
}

- (void)removeMovieView
{
    self.movieView.frame = self.movieViewOriginFrame;
    [self.movieViewSuperView addSubview:self.movieView];
    [self.backButton removeFromSuperview];
}

- (void)el_addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieViewDidExitFullScreen:) name:TTVDidExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeVCDismiss:) name:@"StoreVCDismissFromVideoDetailViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStoreDismiss:) name:@"SKStoreProductViewDidDisappearKey" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissSKStoreProductViewController) name:@"TTVDismissSKStoreProductViewController" object:nil];
}

- (void)el_removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTVDidExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"StoreVCDismissFromVideoDetailViewController" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SKStoreProductViewDidDisappearKey" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TTVDismissSKStoreProductViewController" object:nil];
}

- (void)movieViewDidExitFullScreen:(NSNotification *)notification {
    if (self.playControl.movieView.playerModel == [notification object]) {
        [self.movieView.superview bringSubviewToFront:self.backButton];
        if (self.shouldPresentAdLater && [self.shouldPresentAdLater boolValue]) {
            [self showExtendLinkViewWithArticle:self.detailModel.protocoledArticle isAuto:YES];
        }
    }
}

- (void)storeVCDismiss:(NSNotification *)notification {
    [self removeMovieView];
    [self trackClose];
}

- (void)appStoreDismiss:(NSNotification *)notification{
    UIViewController *vc = notification.object;
    if ([vc isKindOfClass:[SKStoreProductViewController class]] && vc == self.presentController) {
        [self removeMovieView];
        [self trackClose];
    }
}

- (void)videoLinkViewWillDisappear
{
    self.detailStateStore.state.forbidFullScreenWhenPresentAd = NO;
    [self trackClose];
}

- (void)videoLinkViewClickBackbutton
{
    if (self.playControl.movieView.player.context.playbackState == TTVVideoPlaybackStatePaused ||
        self.playControl.movieView.player.context.playbackState == TTVVideoPlaybackStateError) {
        [self.playControl.movieView.player sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
    }
    [self backAction];
}

- (void)videoLinkViewClickMorebutton
{
    [self adTopShareActionFired];
}

- (void)videoLinkViewFullScreenTrackIsAuto:(BOOL)isAuto
{
    [self fullScreenTrack:isAuto];
}


static int switchValue = 0;

- (void)videoLinkViewScrollIsUp:(BOOL)isUp percent:(CGFloat)percent
{
    if (self.maskView.superview != self.view) {
        self.maskView.frame = self.playControl.movieView.bounds;
        [self.view addSubview:self.linkView];
    }
    self.maskView.alpha = percent;
    if (percent > 0.5) {
        if (switchValue != 1) {
            [self.playControl.movieView.player sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
            switchValue = 1;
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
        }
    }else if (percent < 0.5){
        if (switchValue != 2) {
            [self.playControl.movieView.player sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
            switchValue = 2;
            [[UIApplication sharedApplication] setStatusBarStyle:self.originalStatusBarStyle animated:NO];
        }
    }
}

- (void)videoLinkViewWillAppear
{
}

#pragma mark 统计
- (void)trackShow:(BOOL)isAuto
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@(YES) forKey:@"is_ad_event"];
    [self sendADEvent:@"detail_landingpage" label:@"detail_show" value:[self.detailModel.protocoledArticle.videoExtendLink valueForKey:@"id"] extra:dic logExtra:self.detailModel.adLogExtra click:YES];
}

- (void)fullScreenTrack:(BOOL)isAuto
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@(YES) forKey:@"is_ad_event"];
    if (isAuto) {
        [self sendADEvent:@"detail_landingpage" label:@"auto_fullscreen" value:[self.detailModel.protocoledArticle.videoExtendLink valueForKey:@"id"] extra:dic logExtra:self.detailModel.articleExtraInfo.logExtra click:YES];
    }else{
        [self sendADEvent:@"detail_landingpage" label:@"fullscreen" value:[self.detailModel.protocoledArticle.videoExtendLink valueForKey:@"id"] extra:dic logExtra:self.detailModel.articleExtraInfo.logExtra click:YES];
    }

}

- (void)trackClose
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@(YES) forKey:@"is_ad_event"];
    [self sendADEvent:@"detail_landingpage" label:@"close" value:[self.detailModel.protocoledArticle.videoExtendLink valueForKey:@"id"] extra:dic logExtra:self.detailModel.adLogExtra click:NO];
}

- (void)trackClickDetail
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@(YES) forKey:@"is_ad_event"];
    [self sendADEvent:@"detail_landingpage" label:@"click_landingpage" value:[self.detailModel.protocoledArticle.videoExtendLink valueForKey:@"id"] extra:dic logExtra:self.detailModel.adLogExtra click:YES];
}


- (void)sendADEvent:(NSString *)event label:(NSString *)label value:(NSString *)value extra:(NSDictionary *)extra logExtra:(NSString *)logExtra click:(BOOL)click
{
    TTAdBaseModel *adBaseModel = [[TTAdBaseModel alloc] init];
    adBaseModel.ad_id = self.detailModel.articleExtraInfo.adIDStr;
    adBaseModel.log_extra = self.detailModel.articleExtraInfo.logExtra;
    if (!SSIsEmptyArray(self.detailModel.articleExtraInfo.adClickTrackURLs)) {
        [[SSURLTracker shareURLTracker] trackURLs:self.detailModel.articleExtraInfo.adClickTrackURLs model:adBaseModel];
    }
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:event forKey:@"tag"];
    [dict setValue:label forKey:@"label"];
    [dict setValue:value forKey:@"value"];
    if (self.videoInfo.groupModel.groupID) {
        [dict setValue:self.videoInfo.groupModel.groupID forKey:@"ext_value"];
    }
    else
    {
        [dict setValue:@"0" forKey:@"ext_value"];
    }
    
    TTInstallNetworkConnection connection = TTInstallNetworkNoConnection;
    if (TTNetworkWifiConnected()) {
        connection = TTInstallNetworkWifiConnection;
    } else if (TTNetwork2GConnected()) {
        connection = TTInstallNetwork2GConnection;
    } else if (TTNetwork3GConnected()) {
        connection = TTInstallNetwork3GConnection;
    } else if (TTNetwork4GConnected()) {
        connection = TTInstallNetwork4GConnection;
    } else if (TTNetworkConnected()) {
        connection = TTInstallNetworkMobileConnnection;
    }
    
    [dict setValue:@(connection) forKey:@"nt"];
    
    
    if (logExtra) {
        [dict setValue:logExtra forKey:@"log_extra"];
    } else {
        [dict setValue:@"" forKey:@"log_extra"];
    }
    
    if ([[extra allKeys] count] > 0) {
        [dict addEntriesFromDictionary:extra];
    }
    
    [TTTrackerWrapper eventData:dict];
}

#pragma mark getter&setter

- (NSNumber *)shouldPresentAdLater {
    return objc_getAssociatedObject(self, @selector(shouldPresentAdLater));
}

- (void)setShouldPresentAdLater:(NSNumber *)shouldPresentAdLater {
    objc_setAssociatedObject(self, @selector(shouldPresentAdLater), shouldPresentAdLater, OBJC_ASSOCIATION_RETAIN);
}

@end
