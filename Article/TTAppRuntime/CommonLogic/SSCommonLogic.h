//
//  SSCommonLogic.h
//  Article
//
//  Created by Dianwei on 12-11-19.
//
//

#import <Foundation/Foundation.h>

#import <SSCommonDefines.h>

extern NSString * const kIntroductionViewControllerRemovedNotification;
extern NSString * const kFeedRefreshButtonSettingEnabledNotification;
extern NSString * const kFirstRefreshTipsSettingEnabledNotification;
extern NSString * const kTTArticleDislikeRefactor;
extern NSString * const kTTArticleFeedDislikeRefactor;

extern NSError *ttcommonlogic_handleError(NSError *error, NSDictionary *result, NSString **exceptionInfo);

extern NSInteger ttvs_isVideoFeedCellHeightAjust(void);
extern BOOL ttsettings_showRefreshButton(void);
extern BOOL ttsettings_shouldShowLastReadForCategoryID(NSString *categoryID);
extern BOOL ttsettings_getAutoRefreshIntervalForCategoryID(NSString *categoryID);
extern NSInteger ttsettings_favorDetailActionType(void);
extern NSArray *ttsettings_favorDetailActionTick(void);
extern BOOL ttsettings_articleNavBarShowFansNumEnable(void);
extern NSInteger ttsettings_navBarShowFansMinNum(void);
extern NSInteger ttuserdefaults_favorCount(void);
extern void ttuserdefaults_setFavorCount(NSInteger);
extern void ttuserdefaults_setSubscribeCount(NSInteger);

#define kIarNotification       @"kIarNotification"

//用于记录上次设置的时间，仅在内存中， 退出应用后清除
typedef enum SSCommonLogicTimeDictKey{
    SSCommonLogicTimeDictRequestFeedbackKey,    //请求用户反馈的时间
    SSCommonLogicTimeDictRequestCategoryKey,    //获取频道的时间
    SSCommonLogicTimeDictRequestAppAlertKey,    //App alert
    SSCommonLogicTimeDictRequestCheckVersionKey,//版本更新
    SSCommonLogicTimeDictRequestGetDomainKey,   //获取domain
    SSCommonLogicTimeDictRequestUpdateListAutoReloadKey,//动态自动刷新的时间间隔
    SSCommonLogictimeDictRequestAppActivityKey,  //活动
    SSCommonLogicTimeDictRequestChannelKey,     //4.0频道列表
}SSCommonLogicTimeDictKey;


@interface SSCommonLogic : NSObject

#ifndef SS_TODAY_EXTENSTION

@property(nonatomic, assign)BOOL ssIPhoneSupportRotate;
@property (nonatomic, copy) NSString *requestURL;


+ (SSCommonLogic *)shareCommonLogic;

+ (void)setObject:(id)value forKey:(NSString *)key;
+ (NSString *)stringForKey:(NSString *)key;
+ (BOOL)boolForKey:(NSString *)key;
+ (float)floatForKey:(NSString *)key;

//只在内存中
+ (void)updateRequestTimeForKey:(SSCommonLogicTimeDictKey)key;
+ (BOOL)couldRequestForKey:(SSCommonLogicTimeDictKey)key;

+ (NSError*)handleError:(NSError*)error responseResult:(NSDictionary*)result exceptionInfo:(NSString**)exceptionInfo treatExceptionAsError:(BOOL)treat;
+ (NSError*)handleError:(NSError*)error responseResult:(NSDictionary*)result exceptionInfo:(NSString**)exceptionInfo;
+ (NSError*)handleError:(NSError*)error responseResult:(NSDictionary*)result exceptionInfo:(NSString**)exceptionInfo treatExceptionAsError:(BOOL)treat requestURL:(NSString *)requestURL;
/**
 监控用户被踢的行为新增的方法
 
 @param url 请求的接口
 @param status 场景 2 代表session过期,1 代表其他的一场case,主要针对user/info接口
 @param error 错误
 */
+ (void)monitorLoginoutWithUrl:(NSString *)url status:(NSInteger)status error:(NSError *)error;

+ (BOOL)isZoneVersion;

+ (NSNumber *)fixNumberTypeGroupID:(NSNumber *)gID;
+ (NSString *)fixStringTypeGroupID:(NSString *)gIDStr;
+ (long long)fixLongLongTypeGroupID:(long long)gIDStr;

#pragma mark -- 跳转拦截
+ (NSArray *)getInterceptURLs;
+ (void)saveInterceptURLs:(NSArray *)ary;
#pragma mark -- 分享模版及解析类
+ (NSDictionary *)getShareTemplate;
+ (void)saveShareTemplate:(NSDictionary *)dict;
+ (NSString *)parseShareContentWithTemplate:(NSString *)templateString title:(NSString *)t shareURLString:(NSString *)urlString;

//评论/转发/回复时，如果输入框内容为空，出一条提示，此提示由服务端控制
+ (NSString *)commentInputViewPlaceHolder;
+ (void)saveCommentInputViewPlaceHolder:(NSString *)placeHolder;

#pragma mark -- 感知最近使用的App及安装的App
+ (NSString *)getRecentAppsInterval;
+ (void)saveRecentAppsInterval:(NSString *)recentAppsInterval;

+ (NSString *)getInstallAppsInterval;
+ (void)saveInstallAppsInterval:(NSString *)installAppsInterval;

#endif

@end

#ifndef SS_TODAY_EXTENSTION

@interface SSCommonLogic (TaobaoUFP)

+ (BOOL) disabledTBUFP;
+ (void) setDisabledTBUFP:(BOOL) disabled;

+ (NSString *) token;
+ (void) setToken:(NSString *) token;

+ (NSTimeInterval) minimumTimeInterval;
+ (void) setMinimumTimeInterval:(NSTimeInterval) timeInterval;

@end

@interface SSCommonLogic (TTUploadLocation)

+ (NSString *)baiduMapKey;
+ (void)setBaiduMapKey:(NSString *)baiduMapKey;

+ (NSString *)amapKey;
+ (void)setAmapKey:(NSString *)amapKey;

/// 定位超时时间
+ (void)setLocateTimeoutInterval:(NSTimeInterval)timeoutInterval;
+ (NSTimeInterval)locateTimeoutInterval;

+ (NSTimeInterval)minimumLocationUploadTimeInterval;
+ (void)setMinimumLocationUploadTimeInterval:(NSTimeInterval)timeInterval;

+ (NSTimeInterval)minimumLocationAlertTimeInterval;
+ (void)setMinimumLocationAlertTimeInterval:(NSTimeInterval)timeInterval;

@end

typedef NS_ENUM(NSInteger, SSCommentRedirectReportType)  {
    SSCommentRedirectReportTypeNone = 0,
    SSCommentRedirectReportTypeURL = 1,
    SSCommentRedirectReportTypeURLAndDOM = 2
};

@interface SSCommonLogic (WebSearch)

+ (BOOL)enabledAFNetworking;
+ (void)setEnabledAFNetworking:(BOOL)enabledAFNetworking;

+ (BOOL)enabledWhitePageMonitor;
+ (void)setEnabledWhitePageMonitor:(BOOL)enabledWhitePageMonitor;

+ (BOOL)enableWebViewHttps;
+ (void)setEnableWebViewHttps:(BOOL)enableWebViewHttps;

+ (SSCommentRedirectReportType)webviewRedirectReportType;
+ (void)setWebviewRedirectReportType:(SSCommentRedirectReportType)type;
@end

@interface SSCommonLogic (TTDNSEnabled)

+ (BOOL)enabledDNSMapping;
+ (void)setEnabledDNSMapping:(NSInteger)DNSMapping;

@end

@interface SSCommonLogic (Iar)

+ (BOOL)iar;
+ (void)setIar:(BOOL)iar;

@end

/// 后端控制 话题页的 刷新间隔

@interface SSCommonLogic (Forum)

+ (void)setForumRefreshTimeInterval:(NSTimeInterval)timeInterval;
+ (NSTimeInterval)forumListRefreshTimeInterval;

@end

/// 添加好友页面是否过滤不在本机通讯录中的好友
@interface SSCommonLogic (Contact)
+ (BOOL) shouldFilterContact;
+ (void) setShouldFilterContact:(BOOL)filterContact;
@end


@interface SSCommonLogic (CleanCoreData)

+ (BOOL)needCleanCoreData;
+ (void)setNeedCleanCoreData:(BOOL)needCleanCoreData;

@end

@interface SSCommonLogic (WeixinShareStyle)

+ (BOOL)weixinSharedExtendedObjectEnabled;
+ (void)setWeixinSharedExtendedObjectEnabled:(BOOL)sharedExtendedObjectEnabled;

@end

@interface SSCommonLogic (TTAlertControllerEnabled)

+ (BOOL)ttAlertControllerEnabled;
+ (void)setTTAlertControllerEnabled:(BOOL)ttAlertControllerEnabled;

@end

@interface SSCommonLogic (WebContentArticleProtectionTimeout)

+ (BOOL)webContentArticleProtectionTimeoutDisabled;
+ (void)setWebContentArticleProtectionTimeoutDisabled:(BOOL)disabled;
+ (NSTimeInterval)webContentArticleProtectionTimeoutInterval;
+ (void)setWebContentArticleProtectionTimeoutInterval:(NSTimeInterval)timeoutValue;

@end

@interface SSCommonLogic (ExploreDetailToolBarWriteCommentPlaceholderText)

+ (NSString *)exploreDetailToolBarWriteCommentPlaceholderText;
+ (void)setExploreDetailToolBarWriteCommentPlaceholderText:(NSString *)placeHolderText;

@end

@interface SSCommonLogic (TTJsActLogURLString)

+ (NSString *)jsActLogURLString;
+ (NSString *)shouldEvaluateActLogJsStringForAdID:(NSString *)adID;
+ (void)setJsActLogURLString:(NSString *)actLogURLString;

@end

@interface SSCommonLogic (TTJsSafeDomainList)

+ (void)setJsSafeDomainList:(NSArray *)safeDomainList;

@end

@interface SSCommonLogic (TTUMUFPSlotIDs)

+ (NSArray *)taobaoSlotIDs;
+ (void)setTaobaoSlotIDs:(NSArray *)slotIDs;

@end

@interface SSCommonLogic (LastReadRefresh)

+ (BOOL)LastReadRefreshEnabled;
+ (void)setLastReadRefreshEnabled:(BOOL)lastReadRefreshEnabled;

+ (void)setLastReadStyle:(NSInteger)style;

+ (void)setShowFloatingRefreshBtn:(BOOL)show;

+ (void)setAutoFloatingRefreshBtnInterval:(NSInteger)interval;
@end
// feed show show_over打点流程重构开关
@interface SSCommonLogic (ShowWithScenes)

+ (BOOL)showWithScensEnabled;
+ (void)setShowWithScensEnabled:(BOOL)showWithScensEnabled;

@end

// feed show show_over打点流程重构开关
@interface SSCommonLogic (FeedNewPlayer)

+ (BOOL)feedNewPlayerEnabled;
+ (void)setFeedNewPlayerEnabled:(BOOL)feedNewPlayerEnabled;

@end

// 修复feed播放gif问题相关逻辑开关
@interface SSCommonLogic (ArticleFLAnimatedImageView)

+ (BOOL)articleFLAnimatedImageViewEnabled;
+ (void)setArticleFLAnimatedImageViewEnabled:(BOOL)articleFLAnimatedImageViewEnabled;

@end

@interface SSCommonLogic (ReportInWapPage)

+ (BOOL)reportInWapPageEnabled;
+ (void)setReportInWapPageEnabled:(BOOL)reportInWapPageEnabled;

@end

@interface SSCommonLogic (EssayCommentDetail)

+ (BOOL)essayCommentDetailEnabled;
+ (void)setEssayCommentDetailEnabled:(BOOL)essayCommentDetailEnabled;

@end

@interface SSCommonLogic (CDN)

+ (NSUInteger)detailCDNVersion;
+ (void)setDetailCDNVersion:(NSUInteger)version;

@end
@interface SSCommonLogic (RefreshButtonSettingEnabled)

+ (BOOL)refreshButtonSettingEnabled;
+ (void)setRefreshButtonSettingEnabled:(BOOL)enabled;

@end

@interface SSCommonLogic (TTLiveChatTipView)

+ (BOOL)showLiveChatTipViewForliveId:(NSString *)liveId;
+ (void)setShowLiveChatTipView:(BOOL)show  liveId:(NSString *)liveId;

@end

@interface SSCommonLogic (TipGesture)

+ (BOOL)showGestureTip;
+ (void)setShowGestureTip:(BOOL)showGestureTip;

@end

@interface SSCommonLogic (ShowAlwaysOriginImageAlertRepeatly)

+ (BOOL)enabledShowAlwaysOriginImageAlertRepeatly;
+ (void)setEnabledShowAlwaysOriginImageAlertRepeatly:(BOOL)showAlwaysOriginImageAlertRepeatly;

@end

@interface SSCommonLogic (AccountABTest)

+ (BOOL)accountABVersionEnabled;
+ (void)setAccountABVersionEnabled:(BOOL)accountABVersionEnabled;

@end

//顶部搜索露出可控
@interface SSCommonLogic (searchButton)
//控制搜索动画是否使用交互式动画
+ (void)setSearchTransitionEnabled:(BOOL)enabled;
+ (BOOL)isSearchTransitionEnabled;
// 搜索框文案可控
+ (NSString *)searchBarTipForNormal;
+ (void)setSearchBarTipForNormal:(NSString *)tip;
+ (NSString *)searchBarTipForVideo;
+ (void)setSearchBarTipForVideo:(NSString *)tip;
+ (NSString *)searchBarTip;

// 详情页导航栏上显示搜索条
+ (BOOL)searchInDetailNavBarEnabled;
+ (void)enableSearchInDetailNavBar:(NSInteger)enable;

#pragma mark -- webView请求是否带通用参数
+ (void)enableWebViewQueryString:(BOOL)enable;
+ (void)setWebViewQueryEnableHostList:(NSArray<NSString *> *)hostList;
+ (BOOL)shouldAppendQueryStirngWithUrl:(NSURL *)url;

+ (BOOL)searchInitialPageWapEnabled;
+ (void)enableSearchInitialPageWap:(BOOL)enable;

@end

@interface SSCommonLogic (MineTabSearch)

// 我的Tab搜索按钮
+ (BOOL)mineTabSearchEnabled;
+ (void)setMineTabSearchEnabled:(BOOL)mineTabSearchEnabled;

@end

@interface SSCommonLogic (WKWebViewSwitch)

+ (BOOL)WKWebViewEnabled;
+ (void)setWKWebViewEnabledEnabled:(BOOL)enabled;

@end

///...
extern NSString * const SSCommonLogicLaunchedTimes4ShowIntroductionViewKey;
@interface SSCommonLogic (LaunchedTimes4ShowIntroductionView)
+ (NSInteger)launchedTimes4ShowIntroductionView;
+ (void)setLaunchedTimes4ShowIntroductionView:(NSInteger)launchedTimes;
@end

///...
@interface SSCommonLogic (FeedRefreshADDisable)
+ (BOOL)feedRefreshADDisable;
+ (void)setFeedRefreshADDisable:(BOOL)disabled;
@end


//下拉刷新请求控制
@interface SSCommonLogic (RefreshAdControl)

//下拉刷新请求时间间隔
+ (NSTimeInterval)refreshDefaultAdFetchInterval;

//下拉刷新开启关闭控制
+ (BOOL)RefreshADDisable;

//下拉刷新开启关闭控制
+ (void)setRefreshADDisable:(BOOL)disabled;

//下拉刷新广告默认展示次数限制
+ (NSNumber *)refreshADDefaultShowLimit;
@end

@interface SSCommonLogic (FeedRefreshADExpireInterval)
+ (NSTimeInterval)feedRefreshADExpireInterval;
+ (void)setFeedRefreshADExpireInterval:(NSTimeInterval)expireInterval;
@end


//图集广告、图片cell重构开关
@interface SSCommonLogic (RefactorPhotoAlbumControl)

+(void)setRefacorPhotoAlbumControlAble:(BOOL)abled;

+(BOOL)refectorPhotoAlbumControlEnable;

@end

@interface SSCommonLogic (ShowRefreshButton)

+ (BOOL)showRefreshButton;
+ (void)setShowRefreshButton:(BOOL)show;

@end


@interface SSCommonLogic (TTAppseeSample)
//0 表示关闭，1 表示开启
+ (NSNumber *)appseeSampleSetting;
+ (void)setAppseeSampleSetting:(NSNumber *)value;

@end

@interface SSCommonLogic (TTGalleryTileSwitch)
//0 表示关闭，1 表示开启
+ (BOOL)appGalleryTileSwitchOn;
+ (void)setGalleryTileSwitch:(NSNumber *)value;

@end

@interface SSCommonLogic (TTGallerySlideOutSwitch)
//0 表示关闭，1 表示开启
+ (BOOL)appGallerySlideOutSwitchOn;
+ (void)setGallerySlideOutSwitch:(NSNumber *)value;

@end

@interface SSCommonLogic (TTGallerySlideDownOutTip)
//0 表示未展示，1 表示需要展示
+ (BOOL)needToShowSlideDownOutTip;
+ (void)setGallerySlideDownOutTip:(NSNumber *)value;

@end
//视频tab气泡引导
@interface SSCommonLogic (VideoTip)

+ (BOOL)videoTipServerSettingEnabled;
+ (void)setVideoTipServerEnabled:(BOOL)enabled;

+ (NSTimeInterval)videoTipServerInterval;
+ (void)setVideoTipServerInterval:(NSTimeInterval)interval;

@end

//视频自动播放
typedef NS_ENUM(NSUInteger, TTAutoPlaySettingMode) {
    TTAutoPlaySettingModeAll  = 0,
    TTAutoPlaySettingModeWifi = 1,
    TTAutoPlaySettingModeNone = 2
};


@interface SSCommonLogic (Detail)
//详情页快速退出
+ (BOOL)detailQuickExitEnabled;
+ (void)setDetailQuickExitEnabled:(BOOL)enabled;

+ (BOOL)newNatantStyleEnabled;
+ (void)setNewNatantStyleEnabled:(BOOL)enabled;

+ (BOOL)newNatantStyleInADEnabled;
+ (void)setNewNatantStyleInADEnabled:(BOOL)enabled;

+ (void)setDetailWKEnabled:(BOOL)enabled;
+ (BOOL)detailWKEnabled;

+ (void)setDetailSharedWebViewEnabled:(BOOL)enabled;
+ (BOOL)detailSharedWebViewEnabled;

+ (void)setDetailNewLayoutEnabled:(BOOL)enabled;
+ (BOOL)detailNewLayoutEnabled;

+ (void)setCDNBlockEnabled:(BOOL)enabled;
+ (BOOL)CDNBlockEnabled;

+ (void)setToolbarLabelEnabled:(BOOL)enabled;
+ (BOOL)toolbarLabelEnabled;

+ (void)setShareIconStyle:(NSInteger)style;
+ (NSInteger)shareIconStye;
@end

@interface SSCommonLogic (VideoTabBadge)

+ (BOOL)shouldShowVideoTabSpotForVersion:(NSInteger)version;
+ (void)setVideoTabSpotServerEnabled:(BOOL)enabled;
+ (void)showedVideoTabSpot;

@end

typedef NS_ENUM(NSInteger, SSCommentType)  {
    SSCommentTypeArticle,   // 文章类型评论
    SSCommentTypeArticleComment, // 文章评论的评论
    SSCommentTypeMoment,    // 动态类型评论
    SSCommentTypeMomentComment, // 动态评论的评论
};
/// 存储结构
/*
 key {
 type1: {id:draft},
 type2: {id:draft},
 }
 */
@interface SSCommonLogic (CommentDraft)
+ (void)setDraft:(NSDictionary *)draft forType:(SSCommentType)type;
+ (NSDictionary *)draftForType:(SSCommentType)type;
+ (void)cleanDrafts;

+ (void)setSaveForwordStatusEnabled:(BOOL)enabled;
+ (BOOL)saveForwordStatusEnabled;
@end


@interface SSCommonLogic(SSCrashReportSetting)
/**
 *  是否允许umeng收集log
 *
 *  @return YES:允许
 */
+ (BOOL)umengCrashReportEnable;
/**
 *  是否允许toutiao自己的crash report收集log
 *
 *  @return YES:允许
 */
+ (BOOL)toutiaoCrashReportEnable;
/**
 *  是否允许crashlytics收集log
 *
 *  @return YES:允许
 */
+ (BOOL)crashlyticsCrashReportEnable;
/**
 *  设置crash报告者
 *
 *  @param reporter umeng:友盟;toutiao:头条;crashlytics:crashlytics， 不认识及默认都是crashlytics, no_reporter:全都关闭
 */
+ (void)setCrashReporter:(NSString *)reporter;

@end

//@interface SSCommonLogic (WebSearch)
//
//+ (BOOL)enabledWapSearch;
//+ (void)setEnabledWapSearch:(BOOL)enabledWapSearch;
//
//+ (BOOL)enabledAFNetworking;
//+ (void)setEnabledAFNetworking:(BOOL)enabledAFNetworking;
//
//@end

@interface SSCommonLogic (QuickRegister)

+ (NSString *)quickRegisterPageTitle;
+ (void)setQuickRegisterPageTitle:(NSString *)quickRegisterPageTitle;

+ (void)setQuickRegisterButtonText:(NSString *)quickRegisterButtonText;
+ (NSString *)quickRegisterButtonText;
+ (void)setDialogTitles:(NSDictionary *)dict;
+ (NSString *)dialogTitleOfIndex:(NSUInteger)index;/*大登陆引导弹窗的文案*/
+ (void)setLoginAlertTitles:(NSDictionary *)dict;
+ (NSString *)loginAlertTitleOfIndex:(NSUInteger)index;/*小登陆引导弹窗的文案*/

//quick_login    是否启用验证码快捷登录（否的话走密码登录）
//+ (void)setQuickLoginSwitch:(BOOL)quickLogin;
+ (BOOL)quickLoginSwitch;
@end

@interface SSCommonLogic (UGCCellLineNumber)

+ (NSInteger)getUgcCellLineNumber:(NSUInteger)type;
+ (void)setUgcCellLineNumber:(NSDictionary *)dic;

@end

@interface SSCommonLogic (PGCAuthorRecommend)

+ (BOOL)isPGCAuthorSelfRecommendAllowed;
+ (void)setPGCAuthorSelfRecommendAllowed:(BOOL)allowed;

@end

@interface SSCommonLogic (FollowButtonColor)
+ (void)setFollowButtonColorTemplate:(NSDictionary *)dict;
+ (NSDictionary *)followButtonDefaultColorDict;
+ (NSString *)followButtonColorStringForWap;//透传用的
+ (NSString *)followButtonDefaultColorStyle;
+ (NSString *)followButtonDefaultColor;
+ (NSString *)followSelectedImageName;//批量关注的带钩按钮选中图名
+ (NSString *)followUnSelectedImageName;//批量关注的带钩按钮未选中图名
+ (BOOL)followButtonDefaultColorStyleRed;
@end

@interface SSCommonLogic (TAOBAOSDK)
+ (BOOL)newTaobaoSDkEnable;
+ (void)setNewTaobaoSDkEnable:(BOOL)allowed;
@end

@interface SSCommonLogic (TeMaiControls)
+ (BOOL)isTeMaiURL:(NSString*)url;
+ (NSArray *)getTeMaiURLs;
+ (void)saveTeMaiURLs:(NSArray *)ary;
@end

@interface SSCommonLogic (TBJDSDK)
+ (BOOL)isTBSDKEnable;
+ (BOOL)isKeplerEnable;
+ (void)setTBSDKEnable:(BOOL)enable;
+ (void)setKeplerEnable:(BOOL)enable;
@end

@interface SSCommonLogic (CategoryGuide)
+ (NSInteger)cagetoryGuideCount;
+ (void)setCagetoryGuideCount:(NSInteger)count;
@end


@interface SSCommonLogic (LoginDialogStrategyDetail)
+ (NSInteger)detailActionType;
+ (void)setDetailActionType:(NSInteger)type;
@end

@interface SSCommonLogic (LoginDialogStrategyDetailActionTick)
+ (NSArray *)detailActionTick;
+ (void)setDetailActionTick:(NSArray *)actionTick;
@end

@interface SSCommonLogic (LoginDialogStrategyFavorDetail)
+ (NSInteger)favorDetailActionType;
+ (void)setFavorDetailActionType:(NSInteger)type;
@end

@interface SSCommonLogic (LoginDialogStrategyFavorDetailActionTick)
+ (NSArray *)favorDetailActionTick;
+ (void)setFavorDetailActionTick:(NSArray *)actionTick;
@end

@interface SSCommonLogic (LoginDialogStrategyFavorDetailActionHasFavor)
+ (BOOL)needShowLoginTipsForFavor;
@end

@interface SSCommonLogic (LoginDialogStrategyFavorDetailDialogOrder)
+ (NSInteger)favorDetailDialogOrder ;
+ (void)setFavorDetailDialogOrder:(NSInteger)type;
@end

@interface SSCommonLogic (UnForceLoginFavorCount)
+ (NSInteger)favorCount;
+ (void)setFavorCount:(NSInteger)favorCount;
@end

@interface SSCommonLogic (UnForceLoginSubscribeCount)
+ (NSInteger)subscribeCount;
+ (void)setSubscribeCount:(NSInteger)subscribeCount;
@end


@interface SSCommonLogic (APPlog)
+ (void)setEnableSdWebImageMonitor:(BOOL)enable;
+ (BOOL)enableSdWebImageMonitor;

+ (BOOL)useEncrypt;
+ (void)setUseEncrypt:(BOOL)encrypted;

+ (BOOL)monitorLog;
+ (void)setMonitorLog:(BOOL)shouldMonitor;

+ (BOOL)checkLog;
+ (void)setCheckLog:(BOOL)shouldCheck;

+ (BOOL)enableCrashMonitor;
+ (void)setEnableCrashMonitor:(BOOL)enableCrashMonitor;

+ (BOOL)enableDebugRealMonitor;
+ (void)setEnableDebugRealMonitor:(BOOL)enableDebuguReal;

+ (BOOL)enableJSONModelMonitor;
+ (void)setEnableJSONModelMonitor:(BOOL)enableJSONModelMonitor;

+ (BOOL)enableCacheSizeReport;
+ (void)setEnableCacheSizeReport:(BOOL)enable;

@end


@interface SSCommonLogic (VideoFloating)
+ (void)setVideoFloatingEnable:(NSNumber *)floating;
+ (BOOL)isVideoFloatingEnabled;
@end

@interface SSCommonLogic (FollowTabTips)
+ (void)setFollowTabTipsEnable:(BOOL)allowed;
+ (BOOL)isFollowTabTipsEnable;
+ (void)setFollowTabTipsString:(NSString *)string;
+ (NSString *)followTabTipsString;
@end

@interface SSCommonLogic (PreloadFollow)
+ (void)setPreloadFollowEnable:(BOOL)allowed;
+ (BOOL)isPreloadFollowEnable;
@end

@interface SSCommonLogic (ChannelControl)
+ (void)setChannelControlDict:(NSDictionary *)channelControlDict;
+ (NSDictionary *)getChannelControlDict;
+ (NSUInteger)getAutoRefreshIntervalForCategoryID:(NSString *)categoryID;
+ (BOOL)shouldShowLastReadForCategoryID:(NSString *)categoryID;
@end

//文章相关的开关.都放在这把.
@interface SSCommonLogic (Article)
+ (BOOL)isEnableArticleReadPosition;
+ (void)setArticleReadPositionEnable:(BOOL)enable;
@end

@interface SSCommonLogic (HomepageUIConfig)
+ (BOOL)homepageUIConfigSimultaneouslyValid;//顶部底部是否同时生效
+ (void)setHomepageUIConfigSimultaneouslyValid:(BOOL)enable;
+ (void)removeHomepageUIConfigSimultaneousKey;
@end

@interface SSCommonLogic (AccurateTrack)
+ (BOOL)hasUploadAccurateTrack;
+ (void)setUploadAccurateTrackFinished:(BOOL)finished;
@end

@interface SSCommonLogic (LoginEntryList)
+ (void)setLoginEntryList:(NSArray *)loginEntries;
+ (NSArray *)loginEntryList;
@end

@interface SSCommonLogic (PosterAD)
+ (void)setPosterADClickEnabled:(BOOL)enabled;
+ (BOOL)isPosterADClickEnabled;
@end

@interface SSCommonLogic (VideoOwnPlayer)
+ (void)setVideoOwnPlayerEnabled:(BOOL)enabled;
+ (BOOL)isVideoOwnPlayerEnabled;
@end

@interface SSCommonLogic (Optimise)
+ (BOOL)shouldUseOptimisedLaunch;
+ (void)setShouldUseOptimisedLaunch:(BOOL)useOptimised;

+ (BOOL)shouldUseALBBService;
+ (void)setShouldUseALBBService:(BOOL)useOptimised;

+ (CGFloat)maxNSUrlCache;
+ (void)setMaxNSUrlCache:(CGFloat)maxValue;
+ (BOOL)isNetWorkDebugEnable;

+ (void)setIsNetWorkDebugEnable:(BOOL)enable;


@end

@interface SSCommonLogic (NaviRefactor)
+ (void)setRefactorNaviEnabled:(BOOL)enabled;
@end

@interface SSCommonLogic (NewFeedImpression)

+ (void)setNewFeedImpressionEnabled:(BOOL)enabled;
+ (BOOL)isNewFeedImpressionEnabled;

@end

@interface SSCommonLogic (Author)

+ (void)setH5SettingsForAuthor:(NSDictionary *)settings;
+ (NSDictionary *)fetchH5SettingsForAuthor;

@end



/**
 *  文章/图集/视频详情页强校验
 */
@interface SSCommonLogic (StrictDetailJudgement)

+ (void)setStrictDetailJudgementEnabled:(BOOL)enabled;
+ (BOOL)strictDetailJudgementEnabled;

@end

// 搜索优化
@interface SSCommonLogic (SearchOptimize)
+ (void)disableSearchOptimize:(BOOL)disable;
+ (BOOL)isSearchOptimizeDisabled;
@end

@interface SSCommonLogic (ImageDisplayMode)
+ (void)setImageDisplayModeFor3GIsSameAs2GEnable:(BOOL)enabled;
+ (BOOL)imageDisplayModeFor3GIsSameAs2G;
+ (void)setIsUpgradeUserAfterImageDisplayModeControlled:(BOOL)upgrade;
+ (BOOL)isUpgradeUserAfterImageDisplayModelControlled;
@end

@interface SSCommonLogic (ThirdTabSwitch)
+ (void)setThirdTabWeitoutiaoEnabled:(BOOL)enabled;
+ (BOOL)isThirdTabWeitoutiaoEnabled;
//第三个tab是关注tab
+ (BOOL)isThirdTabFollowEnabled;
//我的tab里收藏下面出关注
+ (BOOL)isMyFollowSwitchEnabled;
@end

@interface SSCommonLogic (UserVerifyConfig)

+ (void)setUserVerifyConfigs:(NSDictionary *)configs;
+ (NSDictionary *)userVerifyConfigs;
/** 根据认证类型，返回对应的头像图标模型 */
+ (NSDictionary *)userVerifyAvatarIconModelOfType:(NSString *)type;
/** 根据认证类型，返回对应的标签认证模型 */
+ (NSDictionary *)userVerifyLabelIconModelOfType:(NSString *)type;
/** 返回Feed控制应该显示的认证类型数组 */
+ (NSArray<NSString *> *)userVerifyFeedShowArray;
@end

@interface SSCommonLogic (WeitoutiaoTabListUpdateTipType)

+ (void)setWeitoutiaoTabListUpdateTipType:(NSUInteger)type;
+ (NSUInteger)WeitoutiaoTabListUpdateTipType;

@end

// 是否收集用户手机空间和相册图片数目，为时光相册收集数据
@interface SSCommonLogic (CollectDiskSpace)
+ (void)setCollectDiskSpaceEnable:(BOOL)enable;
+ (BOOL)isCollectDiskSpaceEnable;
@end

@interface SSCommonLogic (TTLiveUseOwnPlayer)
+ (void)setLiveUseOwnPlayerEnabled:(BOOL)enabled;
+ (BOOL)isLiveUseOwnPlayerEnabled;
@end

/** 图集关注按钮显示 */
@interface SSCommonLogic (TTPicsFollowEnable)
+ (void)setPicsFollowEnabled:(BOOL)enabled;
+ (BOOL)isPicsFollowEnabled;
@end

@interface SSCommonLogic (TTTrackSwitch)
+ (void)setV3LogFormatEnabled:(BOOL)enabled;
+ (BOOL)isV3LogFormatEnabled;
@end

@interface SSCommonLogic (RefactorGetDomainsEnabled)
+ (void)setRefactorGetDomainsEnabled:(BOOL)enabled;
+ (BOOL)isRefactorGetDomainsEnabled;
@end

@interface SSCommonLogic (VideoNewRotate)
+ (void)setVideoNewRotateTipEnabled:(BOOL)enabled;
+ (BOOL)isRotateTipEnabled;
@end

@interface SSCommonLogic (SDWebImage)
+ (void)setCustomSDDownloaderOperationEnable:(BOOL)enable;
+ (BOOL)enableCustomSDDownloaderOperation;

+ (void)setUseImageOptimizeStrategyEnable:(BOOL)enable;
+ (BOOL)enableImageOptimizeStrategy;

+ (void)setMonitorFirstHostSuccessRateEnable:(BOOL)enable;
+ (BOOL)enableMonitorFirstHostSuccessRate;
+ (void)setBugfixSDWebImageDownloaderEnable:(BOOL)enable;
+ (BOOL)enableBugfixSDWebImageDownloader;
@end

@interface SSCommonLogic (TTAdSplash)
+ (void)setFirstSplashEnable:(BOOL)enable;
+ (BOOL)isFirstSplashEnable;
@end

@interface SSCommonLogic (TTAd_ForbidJump)

+ (BOOL)shouldInterceptAdJump;
+ (void)setShouldInterceptAdJump:(BOOL)enabled;

+ (BOOL)shouldAutoJumpControlEnabled;
+ (void)setShouldAutoJumpControlEnabled:(BOOL)enabled;

+ (NSSet<NSString *> *)whiteListForAutoJump;
+ (void)setWhiteListForAutoJump:(NSArray<NSString *> *)whiteList;

+ (BOOL)shouldClickJumpControlEnabled;
+ (void)setShouldClickJumpControlEnabled:(BOOL)enabled;

+ (NSTimeInterval)clickJumpTimeInterval;
+ (void)setClickJumpTimeInterval:(NSTimeInterval)interval;

+ (NSString *)frobidClickJumpTips;
+ (void)setFrobidClickJumpTips:(NSString *)tips;

+ (NSSet<NSString *> *)blackListForClickJump;
+ (void)setBlackListForClickJump:(NSArray<NSString *> *)blackList;
@end

@interface SSCommonLogic (TTAdGifImageView)
+ (void)setAdGifImageViewEnable:(BOOL)enable;
+ (BOOL)isAdGifImageViewEnable;
@end

// 默认打开 收集Feed广告曝光时间， 下发0关闭
@interface SSCommonLogic (TTAdImpressionTrack)
+ (void)setAdImpressionTrack:(BOOL)enable;
+ (BOOL)isAdImpressionTrack;
@end

@interface SSCommonLogic (TTAdResPreload)
+ (void)setAdResPreloadEnable:(BOOL)enable;
+ (BOOL)isAdResPreloadEnable;
@end


/**
 广告 预加载资源是否采用 v2版本接口
 */
@interface SSCommonLogic (TTAdUseV2Preload)
+ (void)setAdUseV2PreloadEnable:(BOOL)enable;
+ (BOOL)isAdUseV2PreloadEnable;
@end

@interface SSCommonLogic (TTAdCanvas)
+ (void)setCanvasEnable:(BOOL)enable;
+ (BOOL)isCanvasEnable;
@end

@interface SSCommonLogic (TTAdCanvas_NativeEnable)
+ (void)setCanvasNativeEnable:(BOOL)enable;
+ (BOOL)isCanvasNativeEnable;
@end

@interface SSCommonLogic (TTAdCanvas_PreloadStrategy)
+ (NSDictionary *)canvasPreloadStrategy;
+ (void)setCanvasPreloadStrategy:(NSDictionary *)dict;
@end

@interface SSCommonLogic (TTAdUrlTracker)
+ (void)setUrlTrackerEnable:(BOOL)enable;
+ (BOOL)isUrlTrackerEnable;
@end

@interface SSCommonLogic (TTTemailTracker)
+ (void)setTemailTrackerEnable:(BOOL)enable;
+ (BOOL)isTemailTrackerEnable;

@end

@interface SSCommonLogic (TTAdAppPreload)
+ (void)setAppPreloadEnable:(BOOL)enable;
+ (BOOL)isAppPreloadEnable;
@end

@interface SSCommonLogic (TTAdWebDomComplete)
+ (void)setWebDomCompleteEnable:(BOOL)enable;
+ (BOOL)isWebDomCompleteEnable;
@end

@interface SSCommonLogic (TTAdMZSDKEnable)

+ (void)setMZSDKEnable:(BOOL)enable;

+ (BOOL)isMZSDKEnable;

@end

@interface SSCommonLogic (TTAdUAEnable)

+ (void)setUAEnable:(BOOL)enable;

+ (BOOL)isUAEnable;

@end

@interface SSCommonLogic (TTAdRNMonitorEnable)

+ (void)setRNMonitorEnable:(BOOL)enable;

+ (BOOL)isRNMonitorEnable;

@end

@interface SSCommonLogic (TTAdSDKDelayEnable)

+ (void)setSDKDelayEnable:(BOOL)enable;

+ (BOOL)isSDKDelayEnable;

@end


@interface SSCommonLogic (TTAd_RawAdData)
+ (void)setRawAdDataEnable:(BOOL)enable;
+ (BOOL)isRawAdDataEnable;
@end

@interface SSCommonLogic (TTAdSKVCBugFixEnable)

+ (void)setSKVCBugFixEnable:(BOOL)enable;

+ (BOOL)isSKVCBugFixEnable;

@end

@interface SSCommonLogic (TTAdSKVCLoadEnable)

+ (void)setSKVCLoadEnable:(BOOL)enable;

+ (BOOL)isSKVCLoadEnable;


@end

@interface SSCommonLogic (VideoBusinessSplit)
+ (void)setVideoBusinessSplitEnabled:(BOOL)enabled;
+ (BOOL)isVideoBusinessSplitEnabled;
@end

@interface SSCommonLogic (FetchSettings)
+ (void)setFetchSettingWhenEnterForegroundEnable:(BOOL)enable;
+ (BOOL)isFetchSettingWhenEnterForegroundEnabled;
+ (void)setFetchSettingTimeInterval:(NSTimeInterval)interval;
+ (NSTimeInterval)fetchSettingTimeInterval;
@end

@interface SSCommonLogic (mixedBaseList)
+ (void)setGetRemoteCheckNetworkEnable:(BOOL)enable;
+ (BOOL)isGetRemoteCheckNetworkEnabled;
@end

@interface SSCommonLogic (screenshotShare)
+ (NSString *)shareText;
+ (void)setShareTextWithText:(NSString *)text;
+ (BOOL)screenshotEnable;
+ (void)setScreenshotEnable:(BOOL)enabled;
+ (NSString *)screenshotShareQR;
+ (void)setScreenshotShareQR:(NSString *)url;
+ (BOOL)makeScreenshotForMethodB;//使用第二种方案截图
+ (void)setMakeScreenshotForMethodBEnable:(BOOL)enable;
@end

@interface SSCommonLogic (PullRefresh)
+ (void)setNewPullRefreshEnabled:(BOOL)enabled;
+ (BOOL)isNewPullRefreshEnabled;
+ (CGFloat)articleNotifyBarHeight;
@end

@interface SSCommonLogic (VideoCompressRefactor)
+ (void)setVideoCompressRefactorEnabled:(BOOL)enabled;
+ (BOOL)isVideoCompressRefactorEnabled;
@end

@interface SSCommonLogic (VideoFeedCellHeightAjust)
+ (void)setVideoFeedCellHeightAjust:(NSInteger)enabled;
+ (NSInteger)isVideoFeedCellHeightAjust;
@end

@interface SSCommonLogic (VideoAdAutoPlayedHalfShow)
+ (void)setVideoAdAutoPlayedWhenHalfShow:(BOOL)enabled;
+ (BOOL)isVideoAdAutoPlayedWhenHalfShow;
@end

@interface SSCommonLogic (WeitoutiaoRepostOriginalStatusHint)
+ (NSString *)repostOriginalReviewHint;
+ (void)setRepostOriginalReviewHint:(NSString *)reviewHint;

@end
@interface SSCommonLogic (TTDislikeRefactor)
+ (void)setDislikeRefactorEnabled:(BOOL)enabled;
+ (BOOL)isDislikeRefactorEnabled;

+ (void)setFeedDislikeRefactorEnabled:(BOOL)enabled;
+ (BOOL)isFeedDislikeRefactorEnabled;
@end

@interface SSCommonLogic (RealnameAuth)
+ (void)setRealnameAuthEncryptDisabled:(BOOL)disabled; //实名认证参数加密
+ (BOOL)isRealnameAuthEncryptDisabled;
@end

@interface SSCommonLogic (ReportTyposAlert)
+ (void)setReportTyposEnabled:(BOOL)enabled;
+ (BOOL)isReportTyposEnabled;
@end

@interface SSCommonLogic (TransitonAnimationEnable)
+ (void)setTransitionAnimationEnable:(BOOL)enable;
+ (BOOL)transitionAnimationEnable;
@end

@interface SSCommonLogic (IMServer)

+ (void)setIMServerEnabled:(BOOL)enable;
+ (BOOL)isIMServerEnable;

@end

@interface SSCommonLogic (ImageTransitionAnimationControl)
+ (void)setImageTransitionAnimationEnable:(BOOL)enabled;
+ (BOOL)imageTransitionAnimationEnable;
@end


@interface SSCommonLogic (NewMessageNotification)
+ (void)setNewMessageNotificationEnabled:(BOOL)enabled;
+ (BOOL)isNewMessageNotificationEnabled;
@end

@interface SSCommonLogic (AppLogSendOptimize)
+ (void)setAppLogSendOptimizeEnabled:(BOOL)enabled;
+ (BOOL)isAppLogSendOptimizeEnabled;

@end

@interface SSCommonLogic (VideoPasterADReplay)
+ (void)setVideoADReplayBtnEnabled:(BOOL)enabled;
+ (BOOL)isVideoADReplayBtnEnabled;
@end

@interface SSCommonLogic (IsIcloudEabled)
+ (BOOL)isIcloudEabled;
+ (void)setIcloudBtnEnabled:(BOOL)enabled;

@end

@interface SSCommonLogic (NewLaunchOptimize)
+ (void)setNewLaunchOptimizeEnabled:(BOOL)enabled;
+ (BOOL)isNewLaunchOptimizeEnabled;
@end

@interface SSCommonLogic (PersonalHome)
+ (void)setPersonalHomeMediaTypeThreeEnable:(BOOL)enable;
+ (BOOL)isPersonalHomeMediaTypeThreeEnable;

@end

@interface SSCommonLogic (PlayWithIP)
+ (void)setPlayerImageEnhancementEnabel:(BOOL)enabled;
+ (BOOL)playerImageEnhancementEnabel;
@end

@interface SSCommonLogic (HTSTabSettings)
//火山tab总开关
+ (void)setHTSTabSwitch:(NSInteger)tabSwitch;
+ (BOOL)isForthTabHTSEnabled;
+ (BOOL)isThirdTabHTSEnabled;
//火山tab 首次进入显示火山／抖音频道
+ (void)setForthTabInitialVisibleCategoryIndex:(NSInteger)index;
+ (NSInteger)forthTabInitialVisibleCategoryIndex;
//火山app是否已安装
+ (BOOL)isHTSAppInstalled;
//火山tab列表点击cell是否跳转到火山app开关
+ (void)setLaunchHuoShanAppEnabled:(BOOL)enabled;
+ (BOOL)isLaunchHuoShanAppEnabled;
//火山tab顶部banner
+ (void)setHTSTabBannerInfoDict:(NSDictionary *)dict;
+ (NSDictionary *)htsTabBannerInfoDict;
+ (BOOL)htsTabBannerEnabled;
//火山tab出现时，我的在左上角展示，我的icon的默认图的url
+ (void)setHTSTabMineIconURL:(NSString *)url;
+ (NSString *)htsTabMineIconURL;
//火山app下载所需apple_id
+ (void)setHTSAppDownloadInfoDict:(NSDictionary *)dict;
+ (NSDictionary *)htsAppDownloadInfoDict;

+ (NSString *)htsAPPAppleID;

+ (void)setHTSTabMineIconTipsHasShow:(BOOL)show;
+ (BOOL)htsTabMineIconTipsHasShow;

//播放器类型 0：系统播放器 1：自研播放器
+ (NSInteger)htsVideoPlayerType;
+ (void)setHTSVideoPlayerType:(NSInteger)playType;

//小视频详情页是否开启显示首帧
+ (void)setAWEVideoDetailFirstFrame:(NSNumber *)type;
@end

@interface SSCommonLogic (AWEMEVideoSettings)
//抖音是否已安装
+ (BOOL)isAWEMEAppInstalled;
+ (NSString *)awemeAPPAppleID;
@end

@interface SSCommonLogic (VideoDetailPlayLastShowText)
+ (void)setVideoDetailPlayLastShowText:(BOOL)enabled;
+ (BOOL)isVideoDetailPlayLastShowText;
@end

@interface SSCommonLogic (UGCThreadPost)
+ (void)setUGCThreadPostImageWebP:(BOOL)enabled;
+ (BOOL)isUGCThreadPostImageWebP;

+ (void)setUGCNewCellEnable:(BOOL)enabled;
+ (BOOL)isUGCNewCellEnable;
@end

@interface SSCommonLogic (ChatroomInterrupt)
+ (void)setHandleInterruptTrickMethodEnable:(BOOL)enabled;
+ (BOOL)handleInterruptTrickMethodEnable;
@end

@interface SSCommonLogic (FollowChannel)
+ (void)setFollowChannelColdStartEnable:(BOOL)enable;
+ (BOOL)followChannelColdStartEnable;

+ (void)setFollowChannelMessageEnable:(BOOL)enable;
+ (BOOL)followChannelMessageEnable;

+ (void)setFollowChannelUploadContactsEnable:(BOOL)enable;
+ (BOOL)followChannelUploadContactsEnable;

+ (void)setFollowChannelUploadContactsText:(NSString *)text;
+ (NSString *)followChannelUploadContactsText;
@end

@interface SSCommonLogic (WeiboExpiration)
+ (void)setWeiboExpirationDetectEnable:(BOOL)enable;
+ (BOOL)weiboExpirationDetectEnable;
@end

@interface SSCommonLogic (FeedDetailShareImageStyle)
+ (void)setFeedDetailShareImageStyle:(NSInteger)feedDetailShareImageStyle;
+ (NSInteger)feedDetailShareImageStyle;
@end

@interface SSCommonLogic (FeedHomeClickRefreshSetting)
+ (void)setFeedHomeClickRefreshSetting:(NSDictionary *)dict;
+ (BOOL)homeClickNoAction;
+ (BOOL)homeClickRefreshEnable;
+ (BOOL)homeClickLoadmoreEnable;
+ (BOOL)homeClickLoadmoreEnableForCategoryID:(NSString *)categoryID;
+ (NSInteger)homeClickActionTypeForCategoryID:(NSString *)categoryID;
@end

@interface SSCommonLogic (FeedStartCategoryConfig)
+ (void)setFeedStartCategoryConfig:(NSDictionary *)dict;
+ (NSString *)feedStartCategory;
@end

@interface SSCommonLogic (FeedStartTabConfig)
+ (void)setFeedStartTabConfig:(NSDictionary *)dict;
+ (NSString *)feedStartTab;
@end

@interface SSCommonLogic (FeedCategoryTabAllConfig)
+ (void)setCategoryTabAllConfig:(NSDictionary *)dict;
+ (NSInteger)firstCategoryStyle;
+ (NSInteger)firstTabStyle;
@end

@interface SSCommonLogic (FeedLoadLocalStrategy)
+ (void)setFeedLoadLocalStrategy:(NSDictionary *)dict;
+ (BOOL)showMyAppFansView;
+ (BOOL)useImageVideoNewApi;
+ (NSInteger)configSwitchTimeDaysCount;
+ (BOOL)configSwitchFWebOffline;
+ (NSInteger)configEditProfileEntry;
+ (BOOL)useNewSearchTransitionAnimation;
+ (BOOL)useNewSearchTransitionAnimationForVideo;
+ (BOOL)useRealUnixTimeEnable;
+ (NSInteger)feedLoadLocalStrategy;
+ (BOOL)newItemIndexStrategyEnable;
+ (BOOL)loadLocalUseMemoryCache;
@end

@interface SSCommonLogic (SearchHintSuggestEnable)
+ (void)setSearchHintSuggestEnable:(BOOL)enable;
+ (BOOL)searchHintSuggestEnable;
@end

@interface SSCommonLogic (VideoVisible)
+ (BOOL)videoVisibleEnabled;
+ (void)setVideoVisibleEnabled:(BOOL)videoVisibleEnabled;
@end

@interface SSCommonLogic (FeedVideoEnterBack)
+ (BOOL)feedVideoEnterBackEnabled;
+ (void)setFeedVideoEnterBackEnabled:(BOOL)enterBackEnabled;
@end

@interface SSCommonLogic (FeedCaregoryAddHidden)
+ (void)setFeedCaregoryAddHiddenEnable:(BOOL)enable;
+ (BOOL)feedCaregoryAddHiddenEnable;
@end

@interface SSCommonLogic (PreloadmoreOutScreenNumber)
+ (void)setPreloadmoreOutScreenNumber:(NSInteger)number;
+ (NSInteger)preloadmoreOutScreenNumber;
@end

@interface SSCommonLogic (FeedSearchEntry)
+ (void)setFeedSearchEntryEnable:(BOOL)enable;
+ (BOOL)feedSearchEntrySettingsSaved;
+ (BOOL)feedSearchEntryEnable;
@end

@interface SSCommonLogic (Fantasy)
+ (void)setFeedFantasyLocalSettings:(NSDictionary *)dict;
+ (BOOL)fantasyCountDownEnable;
+ (BOOL)fantasyWindowResizeable;
+ (BOOL)fantasyWindowAlwaysResizeable;
@end

@interface SSCommonLogic (FeedTipsShowStrategy)
+ (void)setFeedTipsShowStrategyDict:(NSDictionary *)dict;
+ (BOOL)feedTipsShowStrategyEnable;
+ (NSInteger)feedTipsShowStrategyType;
+ (NSInteger)feedTipsShowStrategyColor;
@end

@interface SSCommonLogic (FeedRefreshStrategy)
+ (void)setFeedRefreshStrategyDict:(NSDictionary *)dict;
+ (BOOL)showRefreshHistoryTip;
+ (void)updateRefreshHistoryTip;
+ (BOOL)feedLoadMoreWithNewData;
+ (BOOL)feedLastReadCellShowEnable;
+ (BOOL)feedRefreshClearAllEnable;
+ (BOOL)feedLoadingInitImageEnable;
@end

@interface SSCommonLogic (PushTipsEnable)
+ (void)setDetailPushTipsEnable:(BOOL)enable;
+ (BOOL)detailPushTipsEnable;
@end

@interface SSCommonLogic (FeedAutoInsertEnable)
+ (void)setFeedAutoInsertDict:(NSDictionary *)dict;
+ (BOOL)feedAutoInsertEnable;
+ (NSInteger)feedAutoInsertTimes;
+ (NSTimeInterval)feedAutoInsertTimeInterval;
@end

@interface SSCommonLogic (RepeatedAd)
+ (void)setRepeatedAdDisable:(BOOL)disable;
+ (BOOL)isRepeatedAdDisable;
@end

@interface SSCommonLogic (IMCommunicateStrategy)
+ (void)setimCommunicateStrategy:(NSInteger)imCommunicateStrategy;
+ (NSInteger)imCommunicateStrategy;
@end

@interface SSCommonLogic (LoginDialogStrategy)
+ (void)setAppBootEnable:(BOOL)enable;
+ (BOOL)appBootEnable;
+ (void)setDislikeEnable:(BOOL)enable;
+ (BOOL)dislikeEnable;
@end

@interface SSCommonLogic (MiniProgramShare)
+ (NSString *)miniProgramID;
+ (void)setMiniProgramID:(NSString *)ID;
+ (NSString *)miniProgramPathTemplate;
+ (void)setMiniProgramPathTemplate:(NSString *)pathTemplate;
@end

@interface SSCommonLogic (OpenInSafariWindow)
+ (void)setOpenInSafariWindowEnable:(BOOL)Enable;
+ (BOOL)openInSafariWindowEnable;
@end

@interface SSCommonLogic (CommonParameter)
+ (void)setCommonParameterNameWithName:(NSString *)name index:(NSInteger)index;
+ (NSString *)commonParameterNameWithIndex:(NSInteger)index;
+ (void)setCommonParameterWithValue:(NSString *)value index:(NSInteger)index;
+ (NSString *)commonParameterValueWithIndex:(NSInteger)index;
@end

@interface SSCommonLogic (ThreeTopBar)
+ (void)setThreeTopBarEnable:(BOOL)enable;
+ (BOOL)threeTopBarEnable;
@end

@interface SSCommonLogic (UGCEmojiQuickInput)
+ (void)setUGCEmojiQuickInputEnabled:(BOOL)enabled;
+ (BOOL)isUGCEmojiQuickInputEnabled;
@end

@interface SSCommonLogic (VideoDetailRelatedStyle)
+ (void)setVideoDetailRelatedStyle:(NSInteger)style;
+ (NSInteger)videoDetailRelatedStyle;
@end

@interface SSCommonLogic (AutoUploadContacts)
+ (void)setAutoUploadContactsInterval:(NSNumber *)interval;
+ (NSNumber *)autoUploadContactsInterval;
@end

@interface SSCommonLogic (ShortVideoScrollDirection)

+(void)setShortVideoScrollDirection:(NSNumber *)direction;
+(NSNumber *)shortVideoScrollDirection;

@end

@interface SSCommonLogic (ShortVideoFirstUsePromptType)
+(void)setShortVideoFirstUsePromptType:(NSNumber *)direction;
+(NSNumber *)shortVideoFirstUsePromptType;
@end

@interface SSCommonLogic (ShortVideoDetailInfiniteScrollEnable)

+(void)setShortVideoDetailInfiniteScrollEnable:(BOOL)enable;
+(BOOL)shortVideoDetailInfiniteScrollEnable;

@end

@interface SSCommonLogic (MemoryWarningHierarchy)
+ (void)setShouldMonitorMemoryWarningHierarchy:(BOOL)enable;
+ (BOOL)shouldMonitorMemoryWarningHierarchy;
@end

@interface SSCommonLogic (pushSDK)

+ (void)setPushSDKEnable:(BOOL)enable;
+ (BOOL)pushSDKEnable;
@end

@interface SSCommonLogic (commonweal)

+ (void)setCommonwealEntranceEnable:(BOOL)enable;
+ (BOOL)commonwealEntranceEnable;
+ (void)setCommonwealInfo:(NSDictionary *)dict;
+ (NSDictionary *)commonwealInfo;
+ (void)setCommonwealDefaultShowTipTime:(int64_t)time;
+ (int64_t)commonwealDefaultShowTipTime;
+ (void)setCommonwealTips:(NSString *)tips;
+ (NSString *)commonwealTips;
@end

@interface SSCommonLogic (InhouseSetting)

+ (void)setInHouseSetting:(NSDictionary *)settings;

+ (BOOL)isLoginPlatformPhoneOnly;
+ (BOOL)isQuickFeedbackGateShow;

@end

@interface SSCommonLogic (MultiDigg)
+ (void)setMultiDiggEnable:(BOOL)enable;
+ (BOOL)multiDiggEnable;
@end

@interface SSCommonLogic (LocalImageTracker)

+ (BOOL)shouldTrackLocalImage;
+ (void)setShouldTrackLocalImage:(BOOL)shouldTrack;

@end

@interface SSCommonLogic (NavBarShowFansNum)

+ (BOOL)articleNavBarShowFansNumEnable;
+ (void)setArticleNavBarShowFansNumEnable:(BOOL)enable;
+ (NSInteger)navBarShowFansMinNum;
+ (void)setNavBarShowFansMinNum:(NSInteger)minNum;

@end

@interface SSCommonLogic (TTRecordVideoLength)

+ (NSTimeInterval)recorderMaxLength;
+ (void)setRecorderMaxLength:(NSTimeInterval)maxLength;

@end

@interface SSCommonLogic (TTSensetimeLicenceURL)

+ (NSString *)sensetimeLicenceURL;
+ (void)setSensetimeLicenceURL:(NSString *)url;
+ (NSString *)sensetimeLicenceMd5;
+ (void)setSensetimeLicenceMd5:(NSString *)md5;

@end

@interface SSCommonLogic (ChatroomVideoLiveSDK)
+ (void)setChatroomVideoLiveSDKEnable:(BOOL)enable;
+ (BOOL)chatroomVideoLiveSDKEnable;
@end

@interface SSCommonLogic (ArticleShareWithPGCName)
+ (void)setArticleShareWithPGCName:(BOOL)enable;
+ (BOOL)shouldArticleShareWithPGCName;
@end

@interface SSCommonLogic (ArticleTitleLogoSettings)
+ (void)setArticleTitleLogoEnbale:(BOOL)enable;
+ (BOOL)articleTitleLogoEnable;
@end
/**
 搜索取消点击改进开关
 */
@interface SSCommonLogic (SearchCancelClickActionChange)
+ (void)setSearchCancelClickActionChangeEnable:(BOOL)enable;
+ (BOOL)searchCancelClickActionChangeEnable;
@end

@interface SSCommonLogic (TTHomeAuthControl)
+ (void)setHomePageAddAuthSettings:(NSDictionary *)settings;
+ (NSDictionary *)HomePageAddAuthSettings;

+ (void)setHomePageAddVSettings:(NSDictionary *)settings;
+ (NSDictionary *)HomePageAddVSettings;
@end

//频道下发配置
@interface SSCommonLogic (CategoryConfig)
+ (void)setCategoryNameConfigDict:(NSDictionary *)dict;
+ (NSString *)homeTabMainCategoryName;
+ (void)setVideoTabMainCategoryName:(NSString *)name;
+ (NSString *)videoTabMainCategoryName;
@end

@interface SSCommonLogic (FeedGetLocalDataSettings)
+ (void)setGetLocalDataDisable:(BOOL)disable;
+ (BOOL)disableGetLocalData;

+ (NSArray *)clearLocalFeedDataList;
+ (void)setClearLocalFeedDataList:(NSArray *)list;
@end

@interface SSCommonLogic (WXShareConfig)
+ (void)setEnableWXShareCallback:(BOOL)enable;
+ (BOOL)enableWXShareCallback;
@end


//f_settings配置 add by zjing
@interface SSCommonLogic (FHSettings)
+ (void)setFHSettings:(NSDictionary *)fhSettings;
+ (NSDictionary *)fhSettings;

+ (BOOL)wendaShareEnable;
// 找房tab是否显示房源展现 0 默认筛选器样式，1 房源列表
+ (NSInteger)findTabShowHouse;
//首页推荐红点请求时间间隔
+ (NSInteger)categoryBadgeTimeInterval;
+ (BOOL)imCanStart;

@end



#endif

