//
//  TTAdManagerProtocol.h
//  Article
//
//  Created by yin on 2017/6/27.
//
//

#ifndef TTAdManagerProtocol_h
#define TTAdManagerProtocol_h

#import <Foundation/Foundation.h>
#import "TTPhotoDetailCellProtocol.h"
#import "TTRefreshView.h"
#import "TTAdConstant.h"

typedef NS_ENUM(NSInteger, SSSplashADShowType) {
    SSSplashADShowTypeHide,     //不显示,但是还请求
    SSSplashADShowTypeShow,     //显示
    SSSplashADShowTypeIgnore    //不显示，不请求
};

typedef NS_ENUM(NSInteger, SSAdSplashResouceType) { //开屏广告素材类型
    SSAdSplashResouceType_None,
    SSAdSplashResouceType_Image,
    SSAdSplashResouceType_Gif,
    SSAdSplashResouceType_Video
};


@protocol  TTAdManagerDelegate<NSObject>

-(void)photoAlbum_downloadAdImageFinished;

@end

@protocol TTAdManagerProtocol <NSObject,TTPhotoDetailCellHelperProtocol>

#pragma mark -- 分享板广告
//无adid或者非广告页传0(出分享广告),图集传1(不出分享广告)
@optional
- (void)share_showInAdPage:(NSString*)adId groupId:(NSString*)groupId;


+ (void)share_realTimeRemoveAd:(NSArray*)adIds;

#pragma mark 视频详情页Banner位广告

- (UIView*)video_detailBannerPaddingView:(CGFloat)width topLineShow:(BOOL)topShow bottomLineShow:(BOOL)bottomShow;

#pragma mark -- 下拉刷新广告
-(void)refresh_requestRefreshAdData;

-(UIView *)refresh_createAnimateViewWithFrame:(CGRect)frame WithLoadingText:(NSString *)loadingText WithPullLoadingHeight:(CGFloat)pullLoadingHeight;

-(void)refresh_configureAnimateViewWithChannelId:(NSString *)channelId WithRefreshView:(TTRefreshView *)refreshView WithRefreshAnimateView:(UIView *)refreshAnimateView;

-(void)refresh_configureDefaultAnimateViewForRefreshView:(TTRefreshView *)refreshView;

#pragma mark -- 图集广告

- (TTPhotDetailCellType)photoAlbum_getCellDisplayType;

- (void)photoAlbum_setDelegate:(id<TTAdManagerDelegate>)delegate;

- (void)photoAlbum_isNativePhotoAlbum:(BOOL)isNative;

- (void)photoAlbum_fetchAdModelDict:(NSDictionary *)dict;

- (UIView *)photoAlbumAdNextViewWithFrame:(CGRect)frame WithClickBlock:(void (^)(void))clickBlock;

//获取图集广告展示样式,此接口其实是不需要放在外面的，只是为了图集详情页的开关测试，暂时放在外面
-(TTPhotoDetailAdDisplayType)photoAlbum_getAdDisplayType;

-(BOOL)photoAlbum_hasAd;

//返回图集广告页的title
- (NSString*)photoAlbum_getImagePageTitle;

- (void)photoAlbum_adImageClickWithResponder:(UIResponder*)responder;

- (NSDictionary *)photoAlbumImageDic;

- (void)photoAlbum_trackAdImageShow;

- (void)photoAlbum_trackAdImageFinishLoad;


#pragma mark 监控
+ (void)monitor_trackService:(NSString *)serviceName value:(id)value extra:(NSDictionary *)extra;

+ (void)monitor_trackService:(NSString *)serviceName status:(NSUInteger)status extra:(NSDictionary *)extra;

//监测广告事件量
+ (void)monitor_trackServiceCount:(NSString *)serviceName adId:(NSString *)adId logExtra:(NSString *)log_extra extValue:(NSDictionary*)extValue;

#pragma mark 广告落地页资源预加载

- (BOOL)preloadWebRes_isFirstEnterPageAdid:(NSString*)adid;

- (NSInteger)preloadWebRes_preloadTotalAdID:(NSString*)adid;

- (NSInteger)preloadWebRes_preloadNumInWebView;

- (NSInteger)preloadWebRes_matchNumInWebView;

- (BOOL)preloadWebRes_hasPreloadResource:(NSString *)adId;

- (void)preloadWebRes_finishCaptureThePage;

- (void)preloadWebRes_startCaptureAdWebResRequest;

- (void)preloadWebRes_stopCaptureAdWebResRequest;

#pragma mark -- App Store
- (void)app_preloadAppStoreDict:(NSDictionary*)dict;
+ (void)app_downloadAppDict:(NSDictionary *)dict;
+ (BOOL)app_downloadAppWithModel:(id<TTAd, TTAdAppAction>)model;

#pragma mark --CallPhone
- (void)call_callAdDict:(NSDictionary*)dict;
+ (void)call_callWithNumber:(NSString*)phoneNumer;

#pragma mark --Canvas
- (void)canvas_canvasCall;
- (void)canvas_trackRN:(NSDictionary*)dict;
- (void)canvas_trackCanvasTag:(NSString*)tag label:(NSString*)label dict:(NSDictionary*)dict;

#pragma mark ALL
//通过指令广告回收触发
+ (void)realTimeRemoveAd:(NSArray*)adIds;

//设置里清楚历史数据触发
+ (void)clearAllCache;

#pragma mark 开屏
- (BOOL)applicationDidBecomeActiveShowOnWindow:(UIWindow *)keyWindow splashShowType:(NSInteger)type;
- (void)didEnterBackground;
+ (void)clearSSADRecentlyEnterBackgroundTime;
+ (void)clearSSADRecentlyShowSplashTime;
@property (nonatomic, assign) BOOL adShow;
@property (nonatomic, assign) SSSplashADShowType splashADShowType;
@property (nonatomic, assign) BOOL showByForground;
@property (nonatomic, assign) SSAdSplashResouceType resouceType;

#pragma mark - 
+ (BOOL)applink_dealWithWebURL:(NSString *)webURLStr openURL:(NSString *)openURLStr sourceTag:(NSString *)sourceTag value:(NSString *)value extraDic:(NSDictionary *)extraDic;
@end

#endif /* TTAdManagerProtocol_h */
