//
//  TTUGCPodBridge.h
//  Pods
//
//  Created by SongChai on 2017/12/21.
//

#import <Foundation/Foundation.h>
#import "ExploreOrderedData.h"
#import <SSImpressionManager.h>
#import <SSThemed.h>
#import <MapKit/MapKit.h>
#import "TTPlacemarkItemProtocol.h"
#import "DetailActionRequestManager.h"

#define __PodBridgeVoid(sel, func)    \
if ([self.podDelegate respondsToSelector:@selector(sel)]) { [self.podDelegate func];}

#define __PodBridge(sel, func)    \
if ([self.podDelegate respondsToSelector:@selector(sel)]) { \
return [self.podDelegate func]; \
} \
return nil; \

#define __PodBridgeBasic(sel, func)    \
if ([self.podDelegate respondsToSelector:@selector(sel)]) { \
return [self.podDelegate func]; \
} \
return 0; \

@class TTShortVideoModel,Thread,ExplorOrderedData,TSVShortVideoOriginalData;
@protocol TTUGCDetailNatantLayoutProtocol;
@protocol TTUGCExploreSearchViewController;
@protocol TTUGCArticleSearchBarProtocol;
@protocol TTActivityProtocol;

@protocol TTUGCPodBridgeDelegate <NSObject>

- (Class) threadOriginShortVideoType;
- (NSURL *) ugcImageURLWithString:(NSString *)urlString;


- (TTShortVideoModel *)originShortVideoModelForThread:(Thread *)thread;

- (TTShortVideoModel *)shortVideoModelForExploreOrderedData:(ExploreOrderedData *)orderedData;

- (NSObject *)shortVideoExitManagerWithTargetView:(UIView *)targetView imageFrame:(CGRect)imageFrame;

- (NSObject *)shortVideoFetchManagerWithShortVideoOriginalData:(TSVShortVideoOriginalData *)shortVideoOriginalData
                                                         logPb:(NSDictionary *)logPb;

- (NSDictionary *)shortVideoRouteInfoWithShortVideoOriginalData:(TSVShortVideoOriginalData *)shortVideoOriginalData
                                                          logPb:(NSDictionary *)logPb
                                                   categoryName:(NSString *)categoryName
                                                      enterFrom:(NSString *)enterFrom
                                                     targetView:(UIView *)targetView
                                                     imageFrame:(CGRect)imageFrame;

- (void)tsvPublishManagerRetryWithFakeID:(int64_t)fakeID concernID:(NSString *)concernID;
- (void)tsvPublishManagerDeleteWithFakeID:(int64_t)fakeID concernID:(NSString *)concernID;

- (Class)natantContainerViewClass;

- (id<TTUGCDetailNatantLayoutProtocol>)natantLayoutSharedInstance;

- (Class)natantHeaderPaddingViewClass;

- (Class)adDetailContainerViewClass;

- (NSString *)shareMethodUtilLabelNameForShareActivity:(id<TTActivityProtocol>)activity;

- (NSString *)shareMethodUtilLabelNameForShareActivity:(id<TTActivityProtocol>)activity shareState:(BOOL)success;

- (DetailActionRequestType)shareMethodUtilRequestTypeForShareActivityType:(id<TTActivityProtocol>)activity;

- (UIImage *)shareMethodUtilWeixinSharedImageForArticle:(Article *)article;

- (NSString *)shareMethodUtilWeixinSharedImageURLForArticle:(Article *)article;

- (void)activityShareSequenceManagerSortWithActivity:(id<TTActivityProtocol>)activity error:(NSError *)error;

- (NSArray *)activityShareSequenceManagerGetAllShareServiceSequence;

- (BOOL)shouldShowTipsOnNavBarViewController:(UIViewController *)viewController;

- (void)customAnimationManagerRegisterFromVCClass:(Class)fromVCClass
                                        toVCClass:(Class)toVCClass
                                   animationClass:(Class)animationClass;

- (BOOL)surfaceResurfaceEnable;

- (UIColor *)surfaceCategoryBarColor;

- (BOOL)isInThirdTab;

- (BOOL)isConcernTabbar;

- (void)regeocodeWithCompletionHandlerAfterAuthorization:(void (^)(NSArray *))completionHandler;

- (id<TTPlacemarkItemProtocol>)getPlacemarkItem;

- (NSArray *)placemarks;

- (UIViewController *)pushBindPhoneNumberWhenPostThreadWithCompletion:(void (^)(void))completionHandler;

- (void)regeocodeWithCompletionHandler:(void (^)(NSArray *))completionHandler;
/**
 *  混排列表impression
 */
- (void)recordGroupForExploreOrderedData:(ExploreOrderedData *)orderedData status:(SSImpressionStatus)status params:(SSImpressionParams *)params;

- (NSString *)streamAPIVersionString;

- (BOOL)RNEnabledOfPageConcern;

#pragma mark - CommonLogic相关

- (BOOL)detailPushTipsEnable;

- (BOOL)articleNavBarShowFansNumEnable;

- (NSInteger)navBarShowFansMinNum;

- (BOOL)isNewPullRefreshEnabled;

- (CGFloat)articleNotifyBarHeight;

- (BOOL)appGalleryTileSwitchOn;

- (BOOL)appGallerySlideOutSwitchOn;

- (NSString *)exploreDetailToolBarWriteCommentPlaceholderText;

- (NSString *)amapKey;

- (NSInteger)shareIconStye;

@end

@interface TTUGCPodBridge : NSObject<TTUGCPodBridgeDelegate>

@property (nonatomic, strong) id<TTUGCPodBridgeDelegate> podDelegate;

+ (instancetype)sharedInstance;
@end
