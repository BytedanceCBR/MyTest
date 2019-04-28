//
//  TTAdManager.m
//  Article
//
//  Created by yin on 16/8/1.
//
//

#import "TTAdManager.h"
#import "TTAdMonitorManager.h"
#import "TTAdVideoRelateRightImageView.h"
#import "SSADManager.h"
#import "TTURLTracker.h"
#import <TTTracker/TTTrackerProxy.h>
#import "TTAdManagerProtocol.h"
#import "TTServiceCenter.h"
#import "TTPhotoDetailAdNewCollectionViewCell.h"
#import "TTPhotoDetailAdCollectionCell.h"
#import "TTAppLinkManager.h"
#import "TTAdSplashMediator.h"

@interface TTAdManager ()<TTAdManagerProtocol, TTService>

@property (nonatomic, strong) TTAdPhotoAlbumManager*    photoAlbumManager;
@property (nonatomic, strong) TTAdVideoManager*         videoManager;
@property (nonatomic, strong) TTAdCallManager*          callManager;
@property (nonatomic, strong) TTAdShareManager*         shareManager;
@property (nonatomic, strong) TTADRefreshManager*       refreshManager;
@property (nonatomic, strong) TTAdWebResPreloadManager* preloadManager;
@property (nonatomic, strong) TTAdCanvasManager*        canvasManager;
@property (nonatomic, strong) TTAdAppDownloadManager*   appDownloadManager;
@property (nonatomic, strong) SSADManager*              splashManager;

@end

@implementation TTAdManager

#pragma mark -- Global
- (void)applicationDidFinishLaunching
{
    [[TTAdSingletonManager sharedManager] applicationDidLaunch];
}

+ (instancetype)sharedManager{
    static TTAdManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];

    });
    return _sharedManager;
}


-(id)init{
    
    self = [super init];
    if (self) {
        
        [self weakUpURLTracker];
        
    }
    return self;
}

-(void)weakUpURLTracker{
    
    [TTURLTracker shareURLTracker];
    
}

- (TTInstallNetworkConnection)connectionType
{
    return [[TTTrackerProxy sharedProxy] connectionType];
}

TTNetworkFlags TTAdNetworkGetFlags(void) {
    NSInteger flags = 0;
    if (TTNetworkWifiConnected()) {
        flags |= TTNetworkFlagWifi;
    }
    else{
        if (TTNetwork2GConnected() || TTNetwork3GConnected() || TTNetwork4GConnected()) {
            flags |= TTNetworkFlagMobile;
        }
        if (TTNetwork2GConnected()) {
            flags |= TTNetworkFlag2G;
        }
        if (TTNetwork3GConnected()) {
            flags |= TTNetworkFlag3G;
        }
        if (TTNetwork4GConnected()) {
            flags |= TTNetworkFlag4G;
        }
    }
    
    return flags;
}

#pragma mark 图集广告

-(TTAdPhotoAlbumManager*)photoAlbumManager
{ 
    if (!_photoAlbumManager) {
        _photoAlbumManager = [TTAdPhotoAlbumManager sharedManager];
        _photoAlbumManager.delegate = self;
    }
    return _photoAlbumManager;
}

-(void)registerPhotoDetailCellWithCollectionView:(UICollectionView *)collectionView WithCellType:(TTPhotDetailCellType)cellType{
    
    if (collectionView) {
        if (cellType == TTPhotDetailCellType_OldAd) {
            
            [collectionView registerClass:[TTPhotoDetailAdCollectionCell class] forCellWithReuseIdentifier:@"TTPhotoDetailAdCollectionCell"];
            
        }
        else if (cellType == TTPhotDetailCellType_NewAd){
            [collectionView registerClass:[TTPhotoDetailAdNewCollectionViewCell class] forCellWithReuseIdentifier:@"TTPhotoDetailAdNewCollectionViewCell"];
        }
    }
    
}

- (UICollectionViewCell *)dequeueTableCellForcollectionView:(UICollectionView *)collectionView ForCellType:(TTPhotDetailCellType)cellType atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *phototCell = nil;
    
    if (collectionView) {
        if (cellType == TTPhotDetailCellType_OldAd) {
            
            @try {
                 phototCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TTPhotoDetailAdCollectionCell" forIndexPath:indexPath];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
           
        }
        else if (cellType == TTPhotDetailCellType_NewAd){
            
            @try {
                
                phototCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TTPhotoDetailAdNewCollectionViewCell" forIndexPath:indexPath];

                
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        }
    }
    
    return phototCell;
    
}

- (void) photoAlbum_setDelegate:(id<TTAdManagerDelegate>)delegate{
    self.delegate = delegate;
}

- (TTPhotDetailCellType)photoAlbum_getCellDisplayType{
    
    if ([self.photoAlbumManager getPhotoDetailADDisplayType] == TTPhotoDetailAdDisplayType_Default) {
        
        return TTPhotDetailCellType_OldAd;
    }
    else {
        return TTPhotDetailCellType_NewAd;
    }
    
    
}

- (void)photoAlbum_isNativePhotoAlbum:(BOOL)isNative
{
    [self.photoAlbumManager isNativePhotoAlbum:isNative];
}

- (void)photoAlbum_fetchAdModelDict:(NSDictionary *)dict
{
    [self.photoAlbumManager fetchPhotoDetailAdModelDict:dict];
}

//self.photoAlbumManager在download image完成，回调此方法,通知exploreCollectionView刷新collectionView
-(void)photoAlbum_downloadAdImageFinished
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoAlbum_downloadAdImageFinished)]) {
        [self.delegate photoAlbum_downloadAdImageFinished];
    }
}

-(TTPhotoDetailAdModel*)photoAlbum_AdModel
{
    return [self.photoAlbumManager photoDetailAdModel];
}

- (NSDictionary *)photoAlbumImageDic{
    
    TTPhotoDetailAdModel* model = [self.photoAlbumManager photoDetailAdModel];
    NSDictionary* imageDict = nil;
    if (model && [model.image_recom.type isEqualToString:@"web"]) {
        imageDict = [model.image_recom.image toDictionary];
    }
    
    return imageDict;
}

- (UIView *)photoAlbumAdNextViewWithFrame:(CGRect)frame WithClickBlock:(void (^)(void))clickBlock{
    
    TTPhotoDetailAdCellNextView *nextView = [[TTPhotoDetailAdCellNextView alloc] initWithFrame:frame clickBlock:clickBlock];
    return nextView;
    
}

-(TTPhotoDetailAdDisplayType)photoAlbum_getAdDisplayType{
    return [self.photoAlbumManager getPhotoDetailADDisplayType];
}

//广告是否已加载成功
-(BOOL)photoAlbum_hasFinishDownloadAdImage
{
    return [self.photoAlbumManager hasFinishDownloadAdImage];
}

//请先提前判断hasFinishDownloadAdImage
-(UIImage*)photoAlbum_getAdImage
{
    return [self.photoAlbumManager getAdImage];
}

- (NSString*)photoAlbum_getImagePageTitle
{
    return [self.photoAlbumManager getImagePageTitle];
}


-(BOOL)photoAlbum_hasAd
{
    return [self.photoAlbumManager hasPhotoDetailAd];
}

-(TTPhotoDetailAdCollectionCell*)photoAlbum_cellForPhotoDetailAd
{
    return [self.photoAlbumManager cellForPhotoDetailAd];
}

- (void)photoAlbum_adImageClickWithResponder:(UIResponder*)responder
{
    [self.photoAlbumManager adImageClickWithResponder:responder];
}

-(void)photoAlbum_adCreativeButtonClickWithModel:(TTPhotoDetailAdModel *)adModel WithResponder:(UIResponder*)responder{
    
    if (!adModel || !adModel.image_recom) {
        return;
    }
    
    [self.photoAlbumManager adCreativeButtonClickWithModel:adModel WithResponder:responder];
}

- (void)photoAlbum_trackAdImageShow
{
    [self.photoAlbumManager trackAdImageShow];
}

- (void)photoAlbum_trackAdImageFinishLoad
{
    [self.photoAlbumManager trackAdImageFinishLoad];
}

- (void)photoAlbum_trackAdImageClick
{
    [self.photoAlbumManager trackAdImageClick];
}

- (void)photoAlbum_trackDownloadClick{
    [self.photoAlbumManager trackDownloadClick];
}

- (void)photoAlbum_trackDownloadClickToAppstore{
    [self.photoAlbumManager trackDownloadClickToAppstore];
}

- (void)photoAlbum_trackDownloadClickToOpenApp{
    [self.photoAlbumManager trackDownloadClickToOpenApp];
}

#pragma mark 视频广告
#pragma mark 相关视频列表小图广告

-(TTAdVideoManager*)videoManager
{
    if (!_videoManager) {
        _videoManager = [TTAdVideoManager sharedManager];
    }
    return _videoManager;
}

- (BOOL)video_relateIsSmallPicAdValid:(Article*)article
{
    return [self.videoManager relateIsSmallPicAdValid:article];
}

- (BOOL)video_relateIsSmallPicAdCell:(Article *)article
{
    return [self.videoManager relateIsSmallPicAdCell:article];
}

- (TTAdVideoRelateRightImageView*)video_relateRigthImageView:(Article *)article top:(CGFloat)top width:(CGFloat)width successBlock:(TTRelateVideoImageViewBlock)block
{
    return [self.videoManager relateRigthImageView:article top:top width:width successBlock:block];
}

- (TTAdVideoRelateLeftImageView*)video_relateLeftImageView:(Article *)article top:(CGFloat)top width:(CGFloat)width successBlock:(TTRelateVideoImageViewBlock)block
{
    return [self.videoManager relateLeftImageView:article top:top width:width successBlock:block];
}

- (TTAdVideoRelateTopImageView*)video_relateTopImageView:(Article *)article top:(CGFloat)top width:(CGFloat)width successBlock:(TTRelateVideoImageViewBlock)block
{
    return [self.videoManager relateTopImageView:article top:top width:width successBlock:block];
}

- (void)video_relateTrackAdShow:(Article*)article
{
    [self.videoManager trackRelateAdShow:article];
}

- (void)video_relateHandleAction:(Article*)artice
{
    [self.videoManager relateHandleAction:artice];
}

#pragma mark 视频详情页Banner位广告
- (UIView*)video_detailBannerPaddingView:(CGFloat)width topLineShow:(BOOL)topShow bottomLineShow:(BOOL)bottomShow
{
    return [self.videoManager detailBannerPaddingView:width topLineShow:topShow bottomLineShow:bottomShow];
}

#pragma mark 分享板广告

- (TTAdShareManager*)shareManager
{
    if (!_shareManager) {
        _shareManager = [TTAdShareManager sharedManager];
    }
    return _shareManager;
}

+ (TTAdShareBoardView*)share_createShareViewFrame:(CGRect)frame
{
    return [TTAdShareManager createShareViewFrame:frame];
}

- (void)share_showInAdPage:(NSString*)adId groupId:(NSString*)groupId
{
    [self.shareManager showInAdPage:adId groupId:groupId];
}

- (void)share_hideInPage
{
    [self.shareManager hideInPage];
}


+ (void)share_clearShareCache
{
    [TTAdShareManager clearShareCache];
}

+ (void)share_realTimeRemoveAd:(NSArray*)adIds
{
    [TTAdShareManager realTimeRemoveAd:adIds];
}


#pragma mark -- 下拉刷新广告
- (TTADRefreshManager*)refreshManager
{
    if (!_refreshManager) {
        _refreshManager = [TTADRefreshManager sharedManager];
    }
    return _refreshManager;
}

-(void)refresh_requestRefreshAdData{
    
    [self.refreshManager fetchRefreshADModelsWithCompleteBlock:nil];
}

-(void)refresh_setRefreshManagerLauchType:(TTAppLaunchType)launchType{
    self.refreshManager.lauchType = launchType;
}

-(UIView *)refresh_createAnimateViewWithFrame:(CGRect)frame WithLoadingText:(NSString *)loadingText WithPullLoadingHeight:(CGFloat)pullLoadingHeight{
    TTADRefreshAnimationView *adRefreshAnimateView = [self.refreshManager createAnimateViewWithFrame:frame WithLoadingText:loadingText WithPullLoadingHeight:pullLoadingHeight];
    return adRefreshAnimateView;
}

-(void)refresh_configureAnimateViewWithChannelId:(NSString *)channelId WithRefreshView:(TTRefreshView *)refreshView WithRefreshAnimateView:(UIView *)refreshAnimateView{
    
    [self.refreshManager configureAnimateViewWithChannelId:channelId WithRefreshView:refreshView WithRefreshAnimateView:refreshAnimateView];
}

-(void)refresh_configureDefaultAnimateViewForRefreshView:(TTRefreshView *)refreshView{
    [self.refreshManager configureDefaultAnimateViewForRefreshView:refreshView];
}


#pragma mark 监控
+ (void)monitor_trackService:(NSString *)serviceName value:(id)value extra:(NSDictionary *)extra
{
    [TTAdMonitorManager trackService:serviceName value:value extra:extra];
}

+ (void)monitor_trackService:(NSString *)serviceName status:(NSUInteger)status extra:(NSDictionary *)extra
{
    [TTAdMonitorManager trackService:serviceName status:status extra:extra];
}

+ (void)monitor_trackServiceCount:(NSString *)serviceName adId:(NSString *)adId logExtra:(NSString *)log_extra extValue:(NSDictionary*)extValue
{
    [TTAdMonitorManager trackServiceCount:serviceName adId:adId logExtra:log_extra extValue:extValue];
}

#pragma mark -- ALL

+ (void)clearAllCache
{
    [TTAdManager share_clearShareCache];
    [[TTAdCanvasManager sharedManager] clearModelCache];
    [[TTAdWebResPreloadManager sharedManager] clearCache];
    [[TTADRefreshManager sharedManager] clearADRefreshCache];
    [TTAdSplashMediator clearResouceCache];
}

+ (void)realTimeRemoveAd:(NSArray*)adIds
{
    [TTAdShareManager realTimeRemoveAd:adIds];
//    [[SSADManager shareInstance] discardAd:adIds];
    [[TTAdSplashMediator shareInstance] discardAd:adIds];
    [[TTADRefreshManager sharedManager] realTimeRemoveAd:adIds];
    
}


#pragma mark -- 沉浸式广告

- (TTAdCanvasManager*)canvasManager
{
    if (!_canvasManager) {
        _canvasManager = [TTAdCanvasManager sharedManager];
    }
    return _canvasManager;
}

- (void)canvas_requestCanvasData
{
    [self.canvasManager requestCanvasData];
}

- (void)canvas_trackRN:(NSDictionary*)dict
{
    [self.canvasManager trackCanvasRN:dict];
}

- (BOOL)canvas_showCanvasView:(ExploreOrderedData*)orderData cell:(UITableViewCell*)cell;
{
    return [self.canvasManager showCanvasView:orderData cell:cell];
}

- (void)canvas_canvasCall
{
    [self.canvasManager canvasCall];
}

- (void)canvas_trackCanvasTag:(NSString*)tag label:(NSString*)label dict:(NSDictionary*)dict
{
    [self.canvasManager trackCanvasTag:tag label:label dict:dict];
}

#pragma mark 监听电话拨打

-(TTAdCallManager*)callManager
{
    if (!_callManager) {
        _callManager = [TTAdCallManager sharedManager];
    }
    return _callManager;
}

- (void)call_callAdModel:(TTAdCallListenModel*)model
{
    [self.callManager callAdModel:model];
}

- (void)call_callAdDict:(NSDictionary*)dict
{
    [self.callManager callAdDict:dict];
}

+ (void)call_callWithNumber:(NSString*)phoneNumer
{
    [TTAdCallManager callWithNumber:phoneNumer];
}

#pragma mark 下载app

-(TTAdAppDownloadManager*)appDownloadManager
{
    if (!_appDownloadManager) {
        _appDownloadManager = [TTAdAppDownloadManager sharedManager];
    }
    return _appDownloadManager;
}

+ (void)app_downloadAppDict:(NSDictionary *)dict
{
    [TTAdAppDownloadManager downloadAppDict:dict];
}

+ (BOOL)app_downloadAppWithModel:(id<TTAd, TTAdAppAction>)model {
    return [TTAdAppDownloadManager downloadApp:model];
}

- (void)app_preloadAppStoreDict:(NSDictionary*)dict
{
    [self.appDownloadManager preloadAppStoreDict:dict];
}

- (void)app_preloadAppStoreAppleId:(NSString *)appleId
{
    [self.appDownloadManager preloadAppStoreAppleId:appleId];
}

#pragma mark 广告落地页资源预加载

- (TTAdWebResPreloadManager*)preloadManager
{
    if (!_preloadManager) {
        _preloadManager = [TTAdWebResPreloadManager sharedManager];
    }
    return _preloadManager;
}

- (void)preloadWebRes_preloadResource:(ExploreOrderedData*)orderData
{
    [self.preloadManager preloadResource:orderData];
    [self.canvasManager preCreateCanvasView:orderData];
}



- (BOOL)preloadWebRes_isWebTargetPreload
{
    return self.preloadManager.isWebTargetPreload;
}

- (BOOL)preloadWebRes_isFirstEnterPageAdid:(NSString*)adid
{
    return [self.preloadManager isFirstEnterPageAdid:adid];
}

- (NSInteger)preloadWebRes_preloadTotalAdID:(NSString*)adid
{
    return [self.preloadManager preloadTotalAdID:adid];
}

- (NSInteger)preloadWebRes_preloadNumInWebView
{
    return [self.preloadManager preloadNumInWebView];
}

- (NSInteger)preloadWebRes_matchNumInWebView
{
    return [self.preloadManager matchNumInWebView];
}

- (BOOL)preloadWebRes_hasPreloadResource:(NSString *)adId
{
    return [self.preloadManager hasPreloadResource:adId];
}

- (void)preloadWebRes_finishCaptureThePage
{
    [self.preloadManager finishCaptureThePage];
    
}

- (void)preloadWebRes_startCaptureAdWebResRequest
{
    [self.preloadManager startCaptureAdWebResRequest];
}

- (void)preloadWebRes_stopCaptureAdWebResRequest
{
    [self.preloadManager stopCaptureAdWebResRequest];
}

#pragma mark 开屏
- (SSSplashADShowType)splashADShowType
{
    return [SSADManager shareInstance].splashADShowType;
}

- (void)setSplashADShowType:(SSSplashADShowType)splashADShowType
{
    [SSADManager shareInstance].splashADShowType = splashADShowType;
}

- (BOOL)showByForground
{
    return [SSADManager shareInstance].showByForground;
}

- (void)setShowByForground:(BOOL)showByForground
{
    [SSADManager shareInstance].showByForground = showByForground;
}

- (BOOL)adShow
{
    return [SSADManager shareInstance].adShow;
}

- (void)setAdShow:(BOOL)adShow
{
    [SSADManager shareInstance].adShow = adShow;
}

- (SSAdSplashResouceType)resouceType
{
    return [SSADManager shareInstance].resouceType;
}

- (BOOL)applicationDidBecomeActiveShowOnWindow:(UIWindow *)keyWindow splashShowType:(SSSplashADShowType)type
{
    return [[SSADManager shareInstance] applicationDidBecomeActiveShowOnWindow:keyWindow splashShowType:type];
}

- (void)didEnterBackground
{
    [[SSADManager shareInstance] didEnterBackground];
}

+ (void)clearSSADRecentlyEnterBackgroundTime
{
    [[SSADManager class] performSelector:@selector(clearSSADRecentlyEnterBackgroundTime)];
    
}

+ (void)clearSSADRecentlyShowSplashTime
{
    [[SSADManager class] performSelector:@selector(clearSSADRecentlyShowSplashTime)];
}

+ (BOOL)applink_dealWithWebURL:(NSString *)webURLStr openURL:(NSString *)openURLStr sourceTag:(NSString *)sourceTag value:(NSString *)value extraDic:(NSDictionary *)extraDic {
    return [TTAppLinkManager dealWithWebURL:webURLStr openURL:openURLStr sourceTag:sourceTag value:value extraDic:extraDic];
}

@end
