//
//  TTUGCPodBridge.m
//  Pods
//
//  Created by SongChai on 2017/12/21.
//

#import "TTUGCPodBridge.h"


@implementation TTUGCPodBridge

+ (instancetype)sharedInstance {
    static TTUGCPodBridge *bridge;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bridge = [[TTUGCPodBridge alloc] init];
    });
    return bridge;
}

- (Class) threadOriginShortVideoType {
    __PodBridge(threadOriginShortVideoType, threadOriginShortVideoType);
}

- (NSURL *)ugcImageURLWithString:(NSString *)urlString {
    __PodBridge(ugcImageURLWithString:, ugcImageURLWithString:urlString);
}

- (TTShortVideoModel *)originShortVideoModelForThread:(Thread *)thread {
    __PodBridge(originShortVideoModelForThread:, originShortVideoModelForThread:thread);
}

- (TTShortVideoModel *)shortVideoModelForExploreOrderedData:(ExploreOrderedData *)orderedData {
    __PodBridge(shortVideoModelForExploreOrderedData:, shortVideoModelForExploreOrderedData:orderedData);
}

- (NSObject *)shortVideoExitManagerWithTargetView:(UIView *)targetView imageFrame:(CGRect)imageFrame {
    __PodBridge(shortVideoExitManagerWithTargetView:imageFrame:, shortVideoExitManagerWithTargetView:targetView imageFrame:imageFrame);
}

- (NSObject *)shortVideoFetchManagerWithShortVideoOriginalData:(TSVShortVideoOriginalData *)shortVideoOriginalData
                                                         logPb:(NSDictionary *)logPb {
    __PodBridge(shortVideoFetchManagerWithShortVideoOriginalData:logPb:,
                shortVideoFetchManagerWithShortVideoOriginalData:shortVideoOriginalData logPb:logPb)
}

- (NSDictionary *)shortVideoRouteInfoWithShortVideoOriginalData:(TSVShortVideoOriginalData *)shortVideoOriginalData
                                                          logPb:(NSDictionary *)logPb
                                                   categoryName:(NSString *)categoryName
                                                      enterFrom:(NSString *)enterFrom
                                                     targetView:(UIView *)targetView
                                                     imageFrame:(CGRect)imageFrame {
    __PodBridge(shortVideoRouteInfoWithShortVideoOriginalData:logPb:categoryName:enterFrom:targetView:imageFrame:,
                shortVideoRouteInfoWithShortVideoOriginalData:shortVideoOriginalData
                logPb:logPb
                categoryName:categoryName
                enterFrom:enterFrom
                targetView:targetView
                imageFrame:imageFrame)
}

- (void)tsvPublishManagerRetryWithFakeID:(int64_t)fakeID concernID:(NSString *)concernID {
    __PodBridgeVoid(tsvPublishManagerRetryWithFakeID:concernID:, tsvPublishManagerRetryWithFakeID:fakeID concernID:concernID)
}

- (void)tsvPublishManagerDeleteWithFakeID:(int64_t)fakeID concernID:(NSString *)concernID {
    __PodBridgeVoid(tsvPublishManagerDeleteWithFakeID:concernID:, tsvPublishManagerDeleteWithFakeID:fakeID concernID:concernID)
}

- (Class)natantContainerViewClass {
    __PodBridge(natantContainerViewClass, natantContainerViewClass);
}

- (id<TTUGCDetailNatantLayoutProtocol>)natantLayoutSharedInstance {
    __PodBridge(natantLayoutSharedInstance, natantLayoutSharedInstance);
}

- (Class)natantHeaderPaddingViewClass {
    __PodBridge(natantHeaderPaddingViewClass, natantHeaderPaddingViewClass);
}

- (Class)adDetailContainerViewClass {
    __PodBridge(adDetailContainerViewClass, adDetailContainerViewClass);
}

- (BOOL)shouldShowTipsOnNavBarViewController:(UIViewController *)viewController {
    __PodBridgeBasic(shouldShowTipsOnNavBarViewController:, shouldShowTipsOnNavBarViewController:viewController);
}

- (void)customAnimationManagerRegisterFromVCClass:(Class)fromVCClass
                                        toVCClass:(Class)toVCClass
                                   animationClass:(Class)animationClass {
    __PodBridgeVoid(customAnimationManagerRegisterFromVCClass:toVCClass:animationClass:, customAnimationManagerRegisterFromVCClass:fromVCClass toVCClass:toVCClass animationClass:animationClass);
}

- (NSString *)shareMethodUtilLabelNameForShareActivity:(id<TTActivityProtocol>)activity {
    __PodBridge(shareMethodUtilLabelNameForShareActivity:, shareMethodUtilLabelNameForShareActivity:activity);
}

- (NSString *)shareMethodUtilLabelNameForShareActivity:(id<TTActivityProtocol>)activity shareState:(BOOL)success {
    __PodBridge(shareMethodUtilLabelNameForShareActivity:shareState:, shareMethodUtilLabelNameForShareActivity:activity shareState:success);
}

- (DetailActionRequestType)shareMethodUtilRequestTypeForShareActivityType:(id<TTActivityProtocol>)activity {
    __PodBridgeBasic(shareMethodUtilRequestTypeForShareActivityType:, shareMethodUtilRequestTypeForShareActivityType:activity);
}

- (UIImage *)shareMethodUtilWeixinSharedImageForArticle:(Article *)article {
    __PodBridge(shareMethodUtilWeixinSharedImageForArticle:, shareMethodUtilWeixinSharedImageForArticle:article);
}

- (NSString *)shareMethodUtilWeixinSharedImageURLForArticle:(Article *)article {
    __PodBridge(shareMethodUtilWeixinSharedImageURLForArticle:, shareMethodUtilWeixinSharedImageURLForArticle:article);
}

- (void)activityShareSequenceManagerSortWithActivity:(id<TTActivityProtocol>)activity error:(NSError *)error {
    __PodBridgeVoid(activityShareSequenceManagerSortWithActivity:error:, activityShareSequenceManagerSortWithActivity:activity error:error);
}

- (NSArray *)activityShareSequenceManagerGetAllShareServiceSequence {
    __PodBridge(activityShareSequenceManagerGetAllShareServiceSequence, activityShareSequenceManagerGetAllShareServiceSequence);
}

- (void)recordGroupForExploreOrderedData:(ExploreOrderedData *)orderedData status:(SSImpressionStatus)status params:(SSImpressionParams *)params {
    __PodBridgeVoid(recordGroupForExploreOrderedData:status:params:, recordGroupForExploreOrderedData:orderedData status:status params:params);
}

- (NSString *)streamAPIVersionString {
    __PodBridge(streamAPIVersionString, streamAPIVersionString);
}

- (BOOL)surfaceResurfaceEnable {
    __PodBridge(surfaceResurfaceEnable, surfaceResurfaceEnable);
}

- (UIColor *)surfaceCategoryBarColor {
    __PodBridge(surfaceCategoryBarColor, surfaceCategoryBarColor);
}

- (BOOL)isInThirdTab {
    __PodBridge(isInThirdTab, isInThirdTab);
}

- (BOOL)isConcernTabbar {
    __PodBridge(isConcernTabbar, isConcernTabbar);
}

- (void)regeocodeWithCompletionHandlerAfterAuthorization:(void (^)(NSArray *))completionHandler {
    __PodBridgeVoid(regeocodeWithCompletionHandlerAfterAuthorization:, regeocodeWithCompletionHandlerAfterAuthorization:completionHandler);
}

- (id<TTPlacemarkItemProtocol>)getPlacemarkItem {
    __PodBridge(getPlacemarkItem, getPlacemarkItem);
}

- (UIViewController *)pushBindPhoneNumberWhenPostThreadWithCompletion:(void (^)(void))completionHandler {
    __PodBridge(pushBindPhoneNumberWhenPostThreadWithCompletion:, pushBindPhoneNumberWhenPostThreadWithCompletion:completionHandler);
}

- (NSArray *)placemarks {
    __PodBridge(placemarks, placemarks);
}

- (void)regeocodeWithCompletionHandler:(void (^)(NSArray *))completionHandler {
    __PodBridgeVoid(regeocodeWithCompletionHandler:, regeocodeWithCompletionHandler:completionHandler);
}

- (BOOL)RNEnabledOfPageConcern {
    __PodBridgeBasic(RNEnabledOfPageConcern, RNEnabledOfPageConcern);
}

#pragma mark - CommonLogic相关

- (BOOL)detailPushTipsEnable {
    __PodBridgeBasic(detailPushTipsEnable, detailPushTipsEnable)
}

- (BOOL)articleNavBarShowFansNumEnable {
    __PodBridgeBasic(articleNavBarShowFansNumEnable, articleNavBarShowFansNumEnable)
}

- (NSInteger)navBarShowFansMinNum {
    __PodBridgeBasic(navBarShowFansMinNum, navBarShowFansMinNum)
}

- (BOOL)isNewPullRefreshEnabled {
    __PodBridgeBasic(isNewPullRefreshEnabled, isNewPullRefreshEnabled);
}

- (CGFloat)articleNotifyBarHeight {
    __PodBridgeBasic(articleNotifyBarHeight, articleNotifyBarHeight);
}

- (BOOL)appGalleryTileSwitchOn {
    __PodBridgeBasic(appGalleryTileSwitchOn, appGalleryTileSwitchOn);
}

- (BOOL)appGallerySlideOutSwitchOn {
    __PodBridgeBasic(appGallerySlideOutSwitchOn, appGallerySlideOutSwitchOn);
}

- (NSString *)exploreDetailToolBarWriteCommentPlaceholderText {
    __PodBridge(exploreDetailToolBarWriteCommentPlaceholderText, exploreDetailToolBarWriteCommentPlaceholderText);
}

- (NSString *)amapKey {
    __PodBridge(amapKey, amapKey)
}

- (NSInteger)shareIconStye {
    __PodBridgeBasic(shareIconStye, shareIconStye)
}

@end
