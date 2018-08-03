//
//  TTVideoDetailViewController+ExtendLink.m
//  Article
//
//  Created by panxiang on 16/9/19.
//
//

#import "TTVideoDetailViewController+ExtendLink.h"
#import "TTVideoDetailViewController+Log.h"
#import "TTIndicatorView.h"
#import "Article.h"
#import "SSAppStore.h"
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
#import "TTVideoDetailPlayControl.h"
#import "ExploreOrderedData+TTAd.h"

@interface TTVideoDetailViewController()
@end

@implementation TTVideoDetailViewController (ExtendLink)

@dynamic shouldPresentAdLater;

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
            SKStoreProductViewController *skController = [[TTAdAppDownloadManager sharedManager] SKViewControllerPreloadId:appleID];
            skController.view.frame = CGRectMake(0, self.moviewViewContainer.bottom, self.view.width, self.view.height - self.moviewViewContainer.bottom);
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

- (void)showExtendLinkViewWithArticle:(Article *)article isAuto:(BOOL)isAuto
{
    self.playControl.forbidFullScreenWhenPresentAd = YES;
    if (!isAuto) {
        [self trackClickDetail];
    }
    NSMutableDictionary *extendLink = [NSMutableDictionary dictionaryWithDictionary:article.videoExtendLink];
    [extendLink setValue:article.adIDStr forKey:@"ad_id"];
    [extendLink setValue:article.logExtra forKey:@"log_extra"];
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

        if ([[extendLink valueForKey:@"open_new_page"] boolValue])
        {
            [self pauseMovieIfNeeded];
            [self.navigationController presentViewController:controller animated:YES completion:^{
            }];
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
                self.isDownloadAppInIOS78 = YES;
            }
            [[TTAdAppDownloadManager sharedManager] pushSkController:(SKStoreProductViewController *)controller controller:[TTUIResponderHelper topNavigationControllerFor:nil] completion:^{
                controller.view.frame = CGRectMake(0, self.moviewViewContainer.bottom, self.view.width, self.view.height - self.moviewViewContainer.bottom);
                controller.view.superview.backgroundColor = [UIColor clearColor];
                controller.view.backgroundColor = [UIColor clearColor];
                self.movieView.frame = CGRectMake(0, self.moviewViewContainer.top, self.view.width, self.movieView.height);
                [controller.view.superview addSubview:self.movieView];
                if (@available(iOS 11.0, *)) {  //规避iOS11预加载恶心的bug
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
            [self pauseMovieIfNeeded];
            UIViewController *web = [TTVideoExtendLinkHelper webControllerWithParameters:extendLink];
            web.ttDisableDragBack = YES;
            TTNavigationController *nav = [[TTNavigationController alloc] initWithRootViewController:web];
            nav.ttDefaultNavBarStyle = @"White";
            [self.navigationController presentViewController:nav animated:YES completion:^{
                
            }];
        }
        else
        {
            TTVideoLinkView *linkView = [TTVideoExtendLinkHelper linkViewWithHalfFrame:CGRectMake(0, [self pageBottom], self.view.width, self.view.height - [self pageBottom]) fullFrame:self.view.bounds parentViewController:self parameters:extendLink];

            linkView.delegate = self;
            CGRect originFrame = linkView.frame;
            linkView.frame = CGRectOffset(linkView.frame, 0, linkView.height);
            [self.view addSubview:linkView];
            [UIView animateWithDuration:0.25 animations:^{
                linkView.frame = originFrame;
            }];
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
    CGFloat bottom = self.moviewViewContainer.bottom;
    if (!self.embededAD.hidden) {
        CGRect rect = [self.embededAD.superview convertRect:self.embededAD.frame toView:self.view];
        bottom = CGRectGetMaxY(rect);
    }
    bottom = MAX(bottom, self.moviewViewContainer.bottom);
    return bottom;
}

- (void)backButtonClicked
{
    [self.presentController dismissViewControllerAnimated:NO completion:^{
        if ([self.presentController isKindOfClass:[SKStoreProductViewController class]]) {
            if (![[self.detailModel.article.videoExtendLink valueForKey:@"open_new_page"] boolValue]) {
                [self removeMovieView];
                [self trackClose];
            }
        }
        [self backAction];
    }];
}

- (BOOL)shouldPauseMovieWhenShow
{
    if (![[self.detailModel.article.videoExtendLink valueForKey:@"open_new_page"] boolValue] && [[self.detailModel.article.videoExtendLink valueForKey:@"is_download_app"] boolValue] && [self systemlowThan9])
    {
        return NO;
    }
    return YES;
}

- (void)showExtendLinkViewWithArticle:(Article *)article
{
    if ([article showExtendLink]) {
        if (!self.movieView || [self.playControl isMovieFullScreen]) {
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieViewDidExitFullScreen:) name:TTMovieDidExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeVCDismiss:) name:@"StoreVCDismissFromVideoDetailViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStoreDismiss:) name:@"SKStoreProductViewDidDisappearKey" object:nil];
}

- (void)el_removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTMovieDidExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"StoreVCDismissFromVideoDetailViewController" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SKStoreProductViewDidDisappearKey" object:nil];
}

- (void)movieViewDidExitFullScreen:(NSNotification *)notification {
    [self.backButton.superview bringSubviewToFront:self.backButton];
    if (self.shouldPresentAdLater && [self.shouldPresentAdLater boolValue]) {
        [self showExtendLinkViewWithArticle:self.detailModel.article isAuto:YES];
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
    self.playControl.forbidFullScreenWhenPresentAd = NO;
    [self trackClose];
}

- (void)videoLinkViewWillAppear
{
}

#pragma mark 统计
- (void)trackShow:(BOOL)isAuto
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@(YES) forKey:@"is_ad_event"];
    [self sendADEvent:@"detail_landingpage" label:@"detail_show" value:[self.detailModel.article.videoExtendLink valueForKey:@"id"] extra:dic logExtra:self.orderedData.log_extra click:YES];
}

- (void)trackClose
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@(YES) forKey:@"is_ad_event"];
    [self sendADEvent:@"detail_landingpage" label:@"close" value:[self.detailModel.article.videoExtendLink valueForKey:@"id"] extra:dic logExtra:self.orderedData.log_extra click:NO];
}

- (void)trackClickDetail
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@(YES) forKey:@"is_ad_event"];
    [self sendADEvent:@"detail_landingpage" label:@"click_landingpage" value:[self.detailModel.article.videoExtendLink valueForKey:@"id"] extra:dic logExtra:self.orderedData.log_extra click:YES];
}

#pragma mark getter&setter

- (NSNumber *)shouldPresentAdLater {
    return objc_getAssociatedObject(self, @selector(shouldPresentAdLater));
}

- (void)setShouldPresentAdLater:(NSNumber *)shouldPresentAdLater {
    objc_setAssociatedObject(self, @selector(shouldPresentAdLater), shouldPresentAdLater, OBJC_ASSOCIATION_RETAIN);
}

@end
