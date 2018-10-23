//
//  TTAdManager.h
//  Article
//
//  Created by yin on 16/8/1.
//
//

#import "Article.h"
#import "ArticleInfoManager.h"
#import "NetworkUtilities.h"
#import "SSADManager.h"
#import "TTADRefreshManager.h"
#import "TTAdAppDownloadManager.h"
#import "TTAdCallManager.h"
#import "TTAdCanvasManager.h"
#import "TTAdConstant.h"
#import "TTAdPhotoAlbumManager.h"
#import "TTAdShareManager.h"
#import "TTAdVideoManager.h"
#import "TTAdWebResPreloadManager.h"
#import "TTPhotoDetailAdCollectionCell.h"
#import "TTPhotoDetailAdModel.h"
#import <TTAdModule/TTAdCallManager.h>


#define TTAdManageInstance  [TTAdManager sharedManager]


@interface TTAdManager : NSObject<TTAdPhotoAlbumManagerDelegate>

+ (instancetype)sharedManager;

@property (nonatomic, weak) __weak id<TTAdManagerDelegate> delegate;

#pragma mark -- Global

- (void)applicationDidFinishLaunching;

/**
 网络类型判断(借用SSTrackerProxy中的网络type)

 @return 网络类型
 */
- (TTInstallNetworkConnection)connectionType;

#pragma mark 图集广告

- (void) photoAlbum_setDelegate:(id<TTAdManagerDelegate>)delegate;

- (TTPhotDetailCellType)photoAlbum_getCellDisplayType;

//此图集是否是native图集
- (void)photoAlbum_isNativePhotoAlbum:(BOOL)isNative;

- (void)photoAlbum_fetchAdModelDict:(NSDictionary *)dict;

- (TTPhotoDetailAdModel*)photoAlbum_AdModel;

- (NSDictionary *)photoAlbumImageDic;

//获取图集广告nextview
- (UIView *)photoAlbumAdNextViewWithFrame:(CGRect)frame WithClickBlock:(void (^)(void))clickBlock;

//获取图集广告展示样式
-(TTPhotoDetailAdDisplayType)photoAlbum_getAdDisplayType;

//判断有图集广告图片，需满足 1.接口有图片字段 2.图片预加载完成
- (BOOL)photoAlbum_hasAd;

- (BOOL)photoAlbum_hasFinishDownloadAdImage;

- (UIImage*)photoAlbum_getAdImage;

//返回图集广告页的title
- (NSString*)photoAlbum_getImagePageTitle;

- (TTPhotoDetailAdCollectionCell*)photoAlbum_cellForPhotoDetailAd;

- (void)photoAlbum_adImageClickWithResponder:(UIResponder*)responder;

-(void)photoAlbum_adCreativeButtonClickWithModel:(TTPhotoDetailAdModel *)adModel WithResponder:(UIResponder*)responder;

- (void)photoAlbum_trackAdImageShow;

- (void)photoAlbum_trackAdImageFinishLoad;

- (void)photoAlbum_trackAdImageClick;

- (void)photoAlbum_trackDownloadClick;

- (void)photoAlbum_trackDownloadClickToAppstore;

- (void)photoAlbum_trackDownloadClickToOpenApp;


#pragma mark 视频广告
#pragma mark 相关视频列表小图广告
/**
 *  过滤相关视频小图广告title、source、middle_image为空的item
 *
 *  @param article 广告item数据
 *
 *  @return 是否为有效数据
 */
- (BOOL)video_relateIsSmallPicAdValid:(Article*)article;

/**
 *  相关视频的cell是否是小图广告cell
 *
 *  @param aricle item数据
 *
 *  @return 是否广告cell
 */
- (BOOL)video_relateIsSmallPicAdCell:(Article*)article;

//创建相关视频的Cell
- (TTAdVideoRelateRightImageView*)video_relateRigthImageView:(Article*)article top:(CGFloat)top width:(CGFloat)width successBlock:(TTRelateVideoImageViewBlock)block;

- (TTAdVideoRelateLeftImageView*)video_relateLeftImageView:(Article*)article top:(CGFloat)top width:(CGFloat)width successBlock:(TTRelateVideoImageViewBlock)block;

- (TTAdVideoRelateTopImageView*)video_relateTopImageView:(Article*)article top:(CGFloat)top width:(CGFloat)width successBlock:(TTRelateVideoImageViewBlock)block;

- (void)video_relateTrackAdShow:(Article*)article;

- (void)video_relateHandleAction:(Article*)artice;

#pragma mark 视频详情页Banner位广告

- (UIView*)video_detailBannerPaddingView:(CGFloat)width topLineShow:(BOOL)topShow bottomLineShow:(BOOL)bottomShow;



#pragma mark -- 分享板广告

+ (TTAdShareBoardView*)share_createShareViewFrame:(CGRect)frame;

//无adid或者非广告页传0(出分享广告),图集传1(不出分享广告)
- (void)share_showInAdPage:(NSString*)adId groupId:(NSString*)groupId;

//默认图集页不出分享广告、广告详情页不出
- (void)share_hideInPage;

+ (void)share_clearShareCache;

+ (void)share_realTimeRemoveAd:(NSArray*)adIds;


#pragma mark -- 下拉刷新广告
-(void)refresh_requestRefreshAdData;

-(void)refresh_setRefreshManagerLauchType:(TTAppLaunchType)launchType;

-(UIView *)refresh_createAnimateViewWithFrame:(CGRect)frame WithLoadingText:(NSString *)loadingText WithPullLoadingHeight:(CGFloat)pullLoadingHeight;

-(void)refresh_configureAnimateViewWithChannelId:(NSString *)channelId WithRefreshView:(TTRefreshView *)refreshView WithRefreshAnimateView:(UIView *)refreshAnimateView;

-(void)refresh_configureDefaultAnimateViewForRefreshView:(TTRefreshView *)refreshView;

#pragma mark 监控
+ (void)monitor_trackService:(NSString *)serviceName value:(id)value extra:(NSDictionary *)extra;

+ (void)monitor_trackService:(NSString *)serviceName status:(NSUInteger)status extra:(NSDictionary *)extra;

//监测广告事件量
+ (void)monitor_trackServiceCount:(NSString *)serviceName adId:(NSString *)adId logExtra:(NSString *)log_extra extValue:(NSDictionary*)extValue;


#pragma mark -- ALL

//设置里清楚历史数据触发
+ (void)clearAllCache;

//通过指令广告回收触发
+ (void)realTimeRemoveAd:(NSArray*)adIds;

#pragma mark -- 沉浸式广告
- (void)canvas_requestCanvasData;
- (void)canvas_trackRN:(NSDictionary*)dict;
- (BOOL)canvas_showCanvasView:(ExploreOrderedData*)orderData cell:(UITableViewCell*)cell;
- (void)canvas_canvasCall;
- (void)canvas_trackCanvasTag:(NSString*)tag label:(NSString*)label dict:(NSDictionary*)dict;

#pragma mark 监听电话拨打
- (void)call_callAdModel:(TTAdCallListenModel*)model;

- (void)call_callAdDict:(NSDictionary*)dict;

+ (void)call_callWithNumber:(NSString*)phoneNumer;

#pragma mark 下载app
+ (void)app_downloadAppDict:(NSDictionary *)dict;

- (void)app_preloadAppStoreDict:(NSDictionary*)dict;

- (void)app_preloadAppStoreAppleId:(NSString *)appleId;

#pragma mark 广告落地页资源预加载

- (void)preloadWebRes_preloadResource:(ExploreOrderedData*)orderData;

- (BOOL)preloadWebRes_isWebTargetPreload;

- (BOOL)preloadWebRes_isFirstEnterPageAdid:(NSString*)adid;

- (NSInteger)preloadWebRes_preloadTotalAdID:(NSString*)adid;

- (NSInteger)preloadWebRes_preloadNumInWebView;

- (NSInteger)preloadWebRes_matchNumInWebView;

- (BOOL)preloadWebRes_hasPreloadResource:(NSString *)adId;

- (void)preloadWebRes_finishCaptureThePage;

- (void)preloadWebRes_startCaptureAdWebResRequest;

- (void)preloadWebRes_stopCaptureAdWebResRequest;

#pragma mark 开屏

@property (nonatomic, assign) SSSplashADShowType splashADShowType;
@property (nonatomic, assign) SSAdSplashResouceType resouceType;
@property (nonatomic, assign) BOOL showByForground;
@property (nonatomic, assign) BOOL adShow;


- (BOOL)applicationDidBecomeActiveShowOnWindow:(UIWindow *)keyWindow splashShowType:(SSSplashADShowType)type;
- (void)didEnterBackground;

+ (void)clearSSADRecentlyEnterBackgroundTime;

+ (void)clearSSADRecentlyShowSplashTime;
@end
