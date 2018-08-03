//
//  FRThreadURLSettings.m
//  Article
//
//  Created by ranny_90 on 2017/12/15.
//

#import "TTUGCPodBridgeIMP.h"
#import "TTUGCPodBridge.h"
#import "TSVShortVideoOriginalData.h"
//#import "TTUGCGifLoadManager.h"
#import "ArticleImpressionHelper.h"
#import "ArticleURLSetting.h"
#import <Thread.h>
#import "TTSurfaceManager.h"
#import "TTArticleTabBarController.h"
#import "TTTabBarProvider.h"
#import <MapKit/MapKit.h>
#import "TTLocationTransform.h"
#import "TTLocationManager.h"
#import "TTPlacemarkItemProtocol.h"
#import "ExploreItemActionManager.h"
#import "ExploreSearchViewController.h"
#import "ArticleSearchBar.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTDetailNatantContainerView.h"
#import "TTDetailNatantLayout.h"
#import "TTDetailNatantHeaderPaddingView.h"
#import "TTAdDetailContainerView.h"
#import "FriendDataManager.h"
#import "ArticleTabbarStyleNewsListViewController.h"
#import "TTExploreMainViewController.h"
#import "NewsListLogicManager.h"
#import "TTCustomAnimationDelegate.h"
#import "ArticleMobileNumberViewController.h"
#import "TTShareMethodUtil.h"
#import "TTActivityShareSequenceManager.h"
#import "TTRNCommonABTest.h"
#import "TSVShortVideoDetailExitManager.h"
#import "TSVShortVideoOriginalFetchManager.h"
#import "TSVChannelDecoupledConfig.h"
#import "TSVShortVideoDecoupledFetchManager.h"
#import "HTSVideoPageParamHeader.h"
#import "TSVPublishManager.h"

@interface TTUGCPodBridgeIMP()<TTUGCPodBridgeDelegate>

@end

@implementation TTUGCPodBridgeIMP

+ (void)load
{
    [TTUGCPodBridge sharedInstance].podDelegate = [TTUGCPodBridgeIMP new];
}

- (Class)threadOriginShortVideoType {
    return [TSVShortVideoOriginalData class];
}

- (NSURL *)ugcImageURLWithString:(NSString *)urlString {
    return [urlString ttugc_feedImageURL];
}

- (TTShortVideoModel *)originShortVideoModelForThread:(Thread *)thread {
    return thread.originShortVideoOriginalData.shortVideo;
}

- (TTShortVideoModel *)shortVideoModelForExploreOrderedData:(ExploreOrderedData *)orderedData {
    return orderedData.shortVideoOriginalData.shortVideo;
}

- (NSObject *)shortVideoExitManagerWithTargetView:(UIView *)targetView imageFrame:(CGRect)imageFrame {
    TSVShortVideoDetailExitManager *exitManager = [[TSVShortVideoDetailExitManager alloc] initWithUpdateBlock:^CGRect{
        return imageFrame;
    } updateTargetViewBlock:^UIView *{
        return targetView;
    }];
    exitManager.maskViewThemeColorKey = kColorBackground3;
    exitManager.fakeImageContentMode = TTImageViewContentModeScaleAspectFill;
    return exitManager;
}

- (NSObject *)shortVideoFetchManagerWithShortVideoOriginalData:(TSVShortVideoOriginalData *)shortVideoOriginalData
                                                         logPb:(NSDictionary *)logPb {
    TSVShortVideoOriginalFetchManager *fetchManager = [[TSVShortVideoOriginalFetchManager alloc] initWithShortVideoOriginalData:shortVideoOriginalData
                                                                                                                          logPb:logPb];
    return fetchManager;
}

- (NSDictionary *)shortVideoRouteInfoWithShortVideoOriginalData:(TSVShortVideoOriginalData *)shortVideoOriginalData
                                                          logPb:(NSDictionary *)logPb
                                                   categoryName:(NSString *)categoryName
                                                      enterFrom:(NSString *)enterFrom
                                                     targetView:(UIView *)targetView
                                                     imageFrame:(CGRect)imageFrame {
    id<TSVShortVideoDataFetchManagerProtocol> fetchManager;
    if ([categoryName isEqualToString:kTTFollowCategoryID] && shortVideoOriginalData.shortVideo) {
        TTShortVideoModel *model = shortVideoOriginalData.shortVideo;
        model.listIndex = @0;
        model.enterFrom = enterFrom;
        model.categoryName = categoryName;
        model.logPb = logPb;

        if ([TSVChannelDecoupledConfig strategy] == TSVChannelDecoupledStrategyDisabled) {
            fetchManager = [[TSVShortVideoDecoupledFetchManager alloc] initWithItems:@[model]
                                                                   requestCategoryID:kTTUGCVideoCategoryID
                                                                  trackingCategoryID:kTTUGCVideoCategoryID
                                                                        listEntrance:@"more_shortvideo_guanzhu"];
        } else {
            fetchManager = [[TSVShortVideoDecoupledFetchManager alloc] initWithItems:@[model]
                                                                   requestCategoryID:[NSString stringWithFormat:@"%@_detail_draw", kTTUGCVideoCategoryID]
                                                                  trackingCategoryID:kTTUGCVideoCategoryID
                                                                        listEntrance:@"more_shortvideo_guanzhu"];
        }
    } else {
        fetchManager = [[TSVShortVideoOriginalFetchManager alloc] initWithShortVideoOriginalData:shortVideoOriginalData logPb:logPb];
    }
    
    TSVShortVideoDetailExitManager *exitManager = [[TSVShortVideoDetailExitManager alloc] initWithUpdateBlock:^CGRect{
        if (fetchManager.currentIndex == 0) {
            return imageFrame;
        }
        return CGRectZero;
    } updateTargetViewBlock:^UIView *{
        if (fetchManager.currentIndex == 0) {
            return targetView;
        }
        return nil;
    }];
//    exitManager.maskViewThemeColorKey = kColorBackground3;//这一行由于直接推出的小视频删掉了这一行，因此这里也先主调。
    exitManager.fakeImageContentMode = TTImageViewContentModeScaleAspectFill;
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:2];
    [info setValue:fetchManager forKey:HTSVideoListFetchManager];
    [info setValue:exitManager forKey:HTSVideoDetailExitManager];
    return info;
}

- (Class)natantContainerViewClass {
    return [TTDetailNatantContainerView class];
}

- (TTDetailNatantLayout *)natantLayoutSharedInstance {
    return [TTDetailNatantLayout sharedInstance_tt];
}

- (Class)natantHeaderPaddingViewClass {
    return [TTDetailNatantHeaderPaddingView class];
}

- (Class)adDetailContainerViewClass {
    return [TTAdDetailContainerView class];
}

- (BOOL)shouldShowTipsOnNavBarViewController:(UIViewController *)viewController {
    if (![SSCommonLogic detailPushTipsEnable]) {
        return NO;
    }
    BOOL shouldShowTipsOnNavBar = NO;
    NSArray *vcArray = viewController.navigationController.viewControllers;
    if (vcArray.count > 1) {
        NSInteger index = vcArray.count - 2;
        UIViewController *vc = [vcArray objectAtIndex:index];
        if ([vc isKindOfClass:[ArticleTabBarStyleNewsListViewController class]]) {
            ArticleTabBarStyleNewsListViewController *articleVC = (ArticleTabBarStyleNewsListViewController *)vc;
            TTExploreMainViewController *mainVC = articleVC.mainVC;
            TTCategory *currentSelectedCategory = mainVC.categorySelectorView.currentSelectedCategory;
            NSString *parentPageCategoryID;
            parentPageCategoryID = currentSelectedCategory.categoryID;
            if (!parentPageCategoryID) {
                parentPageCategoryID = @"__all__";
            }
            shouldShowTipsOnNavBar = [[NewsListLogicManager shareManager] shouldAutoReloadFromRemoteForCategory:parentPageCategoryID];
            if (!shouldShowTipsOnNavBar) {
                shouldShowTipsOnNavBar = [NewsListLogicManager checkIfJustReloadFromRemote:parentPageCategoryID];
            }
            //!!!问题：下面这句有什么用？
            [[NewsListLogicManager shareManager] fetchReloadTipWithMinBehotTime:[NewsListLogicManager listLastReloadTimeForCategory:parentPageCategoryID] categoryID:parentPageCategoryID count:ListDataDefaultRemoteNormalLoadCount];
        }
    }
    
    return shouldShowTipsOnNavBar;
}

- (void)customAnimationManagerRegisterFromVCClass:(Class)fromVCClass
                                        toVCClass:(Class)toVCClass
                                   animationClass:(Class)animationClass {
    [[TTCustomAnimationManager sharedManager] registerFromVCClass:fromVCClass
                                                        toVCClass:toVCClass
                                                   animationClass:animationClass];
}

- (NSString *)shareMethodUtilLabelNameForShareActivity:(id<TTActivityProtocol>)activity {
    return [TTShareMethodUtil labelNameForShareActivity:activity];
}

- (NSString *)shareMethodUtilLabelNameForShareActivity:(id<TTActivityProtocol>)activity shareState:(BOOL)success {
    return [TTShareMethodUtil labelNameForShareActivity:activity shareState:success];
}

- (DetailActionRequestType)shareMethodUtilRequestTypeForShareActivityType:(id<TTActivityProtocol>)activity {
    return [TTShareMethodUtil requestTypeForShareActivityType:activity];
}

- (UIImage *)shareMethodUtilWeixinSharedImageForArticle:(Article *)article {
    return [TTShareMethodUtil weixinSharedImageForArticle:article];
}

- (NSString *)shareMethodUtilWeixinSharedImageURLForArticle:(Article *)article {
    return [TTShareMethodUtil weixinSharedImageURLForArticle:article];
}

- (void)activityShareSequenceManagerSortWithActivity:(id<TTActivityProtocol>)activity error:(NSError *)error {
    //分享成功或失败，触发分享item排序
    if(error) {
        TTVActivityShareErrorCode errorCode = [TTActivityShareSequenceManager shareErrorCodeFromItemErrorCode:error WithActivity:activity];
        switch (errorCode) {
            case TTVActivityShareErrorFailed:
                [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareServiceSequenceFirstActivity:activity.contentItemType];
                break;
            case TTVActivityShareErrorUnavaliable:
            case TTVActivityShareErrorNotInstalled:
            default:
                break;
        }
    }else{
        [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareServiceSequenceFirstActivity:activity.contentItemType];
    }
}

- (NSArray *)activityShareSequenceManagerGetAllShareServiceSequence {
    return [[TTActivityShareSequenceManager sharedInstance_tt] getAllShareServiceSequence];
}

- (void)recordGroupForExploreOrderedData:(ExploreOrderedData *)orderedData status:(SSImpressionStatus)status params:(SSImpressionParams *)params {
    [ArticleImpressionHelper recordGroupForExploreOrderedData:orderedData status:status params:params];
}

- (NSString *)streamAPIVersionString {
    return [ArticleURLSetting streamAPIVersionString];
}

- (BOOL)surfaceResurfaceEnable {
    return [TTSurfaceManager resurfaceEnable];
}

- (UIColor *)surfaceCategoryBarColor {
    return [TTSurfaceManager categoryBarColor];
}

- (BOOL)isInThirdTab {
    UIViewController * controller = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    if ([controller isKindOfClass:[TTArticleTabBarController class]]) {
        TTArticleTabBarController * tabBarController = (TTArticleTabBarController *)controller;
        return [tabBarController isShowingConcernOrForumTab];
    }
    return NO;
}

- (BOOL)isConcernTabbar {
    if ([TTTabBarProvider isFollowTabOnTabBar]) {
        
        UIViewController * controller = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        if ([controller isKindOfClass:[TTArticleTabBarController class]]) {
            TTArticleTabBarController * tabBarController = (TTArticleTabBarController *)controller;
            return [tabBarController isShowingConcernOrForumTab];
        }
    }
    return NO;
}

- (void)regeocodeWithCompletionHandlerAfterAuthorization:(void (^)(NSArray *))completionHandler {
    [[TTLocationManager sharedManager] regeocodeWithCompletionHandlerAfterAuthorization:completionHandler];
}

- (id<TTPlacemarkItemProtocol>)getPlacemarkItem {

    return [[TTLocationManager sharedManager] getPlacemarkItem];
}

- (NSArray *)placemarks {
    return [[TTLocationManager sharedManager] placemarks];
}

- (void)regeocodeWithCompletionHandler:(void (^)(NSArray *))completionHandler {

    [[TTLocationManager sharedManager] regeocodeWithCompletionHandler:completionHandler];
}

- (UIViewController *)pushBindPhoneNumberWhenPostThreadWithCompletion:(void (^)(void))completionHandler {

    void (^completion)() = [completionHandler copy];

    ArticleMobileNumberViewController *viewController = [[ArticleMobileNumberViewController alloc] initWithMobileNumberUsingType:ArticleMobileNumberUsingTypeBind];

    viewController.completion = ^(ArticleLoginState state){
        if (state != ArticleLoginStateUserCancelled) {
            if (completion) {
                completion();
            }
        }
    };

    return viewController;
}

- (BOOL)RNEnabledOfPageConcern {
    return [TTRNCommonABTest RNEnabledOfPage:kTTRNPageEnabledTypeConcern];
}

#pragma mark - CommonLogic相关

- (BOOL)detailPushTipsEnable {
    return [SSCommonLogic detailPushTipsEnable];
}

- (BOOL)articleNavBarShowFansNumEnable {
    return [SSCommonLogic articleNavBarShowFansNumEnable];
}

- (NSInteger)navBarShowFansMinNum {
    return [SSCommonLogic navBarShowFansMinNum];
}

- (BOOL)isNewPullRefreshEnabled {
    return [SSCommonLogic isNewPullRefreshEnabled];
}

- (CGFloat)articleNotifyBarHeight {
    return [SSCommonLogic articleNotifyBarHeight];
}

- (BOOL)appGalleryTileSwitchOn {
    return [SSCommonLogic appGalleryTileSwitchOn];
}

- (BOOL)appGallerySlideOutSwitchOn {
    return [SSCommonLogic appGallerySlideOutSwitchOn];
}

- (NSString *)exploreDetailToolBarWriteCommentPlaceholderText {
    return [SSCommonLogic exploreDetailToolBarWriteCommentPlaceholderText];
}

- (NSString *)amapKey {
    return [SSCommonLogic amapKey];
}

- (NSInteger)shareIconStye {
    return [SSCommonLogic shareIconStye];
}

#pragma mark - 小视频相关

- (void)tsvPublishManagerRetryWithFakeID:(int64_t)fakeID concernID:(NSString *)concernID {
    [[TSVPublishManager class] retryWithFakeID:fakeID concernID:concernID];
}

- (void)tsvPublishManagerDeleteWithFakeID:(int64_t)fakeID concernID:(NSString *)concernID {
    [[TSVPublishManager class] deleteWithFakeID:fakeID concernID:concernID];
}
@end
