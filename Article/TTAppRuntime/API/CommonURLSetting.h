//
//  CommonLogicSetting.h
//  Gallery
//
//  Created by Hu Dianwei on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CommonURLSetting : NSObject{
}

+ (CommonURLSetting *)sharedInstance;
- (void)requestURLDomains;
- (void)refactorRequestURLDomains;
- (void)refactorHandleResult:(NSDictionary *)jsonDict error:jsonError; //add by songlu
- (void)handleResult_:(NSDictionary *)jsonDict error:jsonError; //add by songlu

#pragma mark - domains
+ (NSString*)baseURL;
+ (NSString*)baseURLWithKey:(NSString *)key;
+ (NSString*)securityURL;
+ (NSString *)channelBaseURL;
+ (NSString*)SNSBaseURL;
+ (NSString*)logBaseURL;
+ (NSString*)monitorBaseURL;

#pragma mark - 详情页默认hosts
+ (NSArray *)defaultArticleDetailURLHosts;

#pragma mark - Base URLs

+ (NSString*)tabCommentURLString;
+ (NSString*)tabCommentURLStringV2;
+ (NSString*)allCommentURLString;
+ (NSString*)appLogoutURLString;
+ (NSString*)recommendAppInfoURLString;
+ (NSString*)recommendAppAcountURLString;
+ (NSString*)videoCategoryURLString;
+ (NSString*)shortVideoCategoryURLString;
+ (NSString*)appRecommendURLString;
+ (NSString*)loadVideoURLString;
+ (NSString*)appUpdateURLString;
+ (NSString*)appNoUpdateNotifyURLString;
+ (NSString*)appNoticeStatusURLString;
+ (NSString *)appSettingsURLString;//获取设置API
+ (NSString *)articlePositionUploadURLString; //上报文章的阅读位置
///...
+ (NSString *)listEntityWordCareURLString;
+ (NSString *)listEntityWordDiscareURLString;
+ (NSString *)channelRefreshADImageURLString;

#pragma mark - LiveBase URLs
+ (NSString* )liveTalkURLString;

#pragma mark - ChannelBase URLs
+ (NSString*)appAlertURLString;
+ (NSString*)appAlertActionURLString;
+ (NSString*)checkVersionURLString;
+ (NSString*)feedbackFetch;
+ (NSString *)reportURLString;
+ (NSString *)reportUserURLString;
+ (NSString *)reportVideoURLString;
+ (NSString *)feedbackPostMsg;
+ (NSString *)feedbackFAQURLString;
+ (NSString*)continuousCDNLogURLString;

#pragma mark - SNSBase URLs
+ (NSString *)adItemActionUnDislikeURLString;
+ (NSString *)adItemActionDislikeURLString;
+ (NSString *)wapAuthSyncURLString;
+ (NSString *)wapAppURLString;
+ (NSString*)favoriteUsersURLString;
+ (NSString*)shareMessageURLString;
+ (NSString*)actionURLString;
+ (NSString*)commentActionURLString;
+ (NSString*)favoriteActionURLString;
+ (NSString*)postMessageURLString;
+ (NSString*)userInfoURLString;
+ (NSString*)loginURLString;
+ (NSString*)logoutURLString;
+ (NSString*)logoutAccountURLString;
+ (NSString*)updateUserURLString;
+ (NSString*)sinaSSOLoginURLString;
/**
 *  WAP强制解绑
 *
 *  @return <#return value description#>
 */
+ (NSString*)loginContinueURLString;
+ (NSString*)switchBindURLString; //SSO改绑
+ (NSString*)appShare;
+ (NSString*)batchItemAction;
+ (NSString*)getUpdatesURLString;       // 获取更新数
+ (NSString*)getFavouriteStatus;
+ (NSString*)getHotUpdates;
+ (NSString*)updateRecent;              // 动态更新列表
+ (NSString*)myFollowURLString;         // 我的关注头像
+ (NSString*)newFollowingURLString;     // 我的关注列表新接口
+ (NSString*)userSearchPageURLString;   // 我的Tab搜索页面
+ (NSString*)updateCountURLString;      // 新动态更新的数量
+ (NSString*)updateUserListURLString;   // 某个用户的动态更新
+ (NSString*)uploadUserPhotoURLString;  // 上传用户头像
+ (NSString *)uploadCertificationURLString; //上传认证信息
+ (NSString *)uploadModifyCertificationURLString; //上传修改认证信息
+ (NSString*)uploadUserImageURLString;  // 新的上传PGC用户头像和背景图
//+ (NSString*)setCatgegoryURLString;
+ (NSString*)requestNewSessionURLString;
+ (NSString*)exceptionURLString;

+ (NSString*)reportUserConfigurationString;

+ (NSString*)wapActivityURLString;//活动链接URL
+ (NSString*)deleteUGCMovieURLString;//删除ugc视频URL
/*
 *  短文章中使用该URL获取评论
 */
+ (NSString *)essayCommentsURLString;
/*
 * 上传图片API
 * 方法：Post
 */
+ (NSString *)uploadImageString;
/*
 *  删除评论API
 *  方法：Post
 */
+ (NSString *)deleteCommentString;

+ (NSString *)unlikePGCUserURLString;
+ (NSString *)likePGCUserURLString;
+ (NSString *)sharePGCUserURLString;

#pragma mark - LogBase URLs
+ (NSString*)appLogConfigURLString;
+ (NSString*)appLogV3ConfigURLString;
+ (NSString*)appLogURLString;
+ (NSString*)appLogV2ConfigURLString;
+ (NSString*)appLogV2URLString;
#pragma mark - Auth URLs
+ (NSString*)authLoginSuccessURLString;
+ (NSString*)CDNLogURLString;

#pragma mark - Real-name Auth URLs
+ (NSString *)imageOcrUploadURLString; //客户端OCR图片上传
+ (NSString *)imageOcrInfoSubmitURLString; //客户端OCR信息提交
+ (NSString *)imageOcrInfoStatusURLString; //客户端OCR信息填写状态
+ (NSString *)imageIDPicUploadURLString; //客户端身份证照片上传
+ (NSString *)imageIDVideoUploadURLString; //客户端身份验证视频上传
//下载AppList文件
+ (NSString*)appListFileURLString;

+ (NSString*)APIErrorReportURLString;

+ (NSString*)appMonitorConfigURLString;
+ (NSString*)appMonitorCollectURLString;

+ (NSString*)version2DislikeURLString;
#pragma mark - subscribed category
+ (NSString *)subscribeURLString;
#pragma mark - post moment
+ (NSString *)postMomentURLString;
#pragma mark - forward moment
+ (NSString *)forwardMomentURLString;

+ (NSString*)wapStoreURLString;

+ (NSString*)luaURLString;
+ (NSString*)jsAuthConfigURLString;

//5.1版需求：将频道数据分开请求 10/10/2015 by liuty
+ (NSString*)subscribedCategoryURLString;
+ (NSString*)unsubscribedCategoryURLString;

#pragma mark -- forum base URL
+ (NSString *)moiveCommentBaseURL;
+ (NSArray *)urlMapping;
+ (NSString *)yangGuangBaseURL;
@end

@interface CommonURLSetting (TTLocationUpload)

+ (NSString *)uploadLocationURLString;
+ (NSString *)uploadUserCityURLString;
+ (NSString *)locationCancelURLString;

@end

//引导图相关
@interface CommonURLSetting (TTGuide)

+ (NSString *)confWordsURLString;

@end


@interface CommonURLSetting (TTAd)
+ (NSString *)appADURLString;
+ (NSString *)shareAdURLString;
//下拉刷新广告接口
+ (NSString *)refreshADURLString;
+ (NSString *)canvasAdURLString;
+ (NSString *)canvasAdLiveURLString;
+ (NSString *)preloadAdURLString;

/**
 预加载 新数据格式
 @wiki https://wiki.bytedance.net/pages/viewpage.action?pageId=86879659
 */
+ (NSString *)adPreloadV2URLString;

@end

@interface CommonURLSetting (TTPrivateLetter)

+ (NSString *)userInfoURL;
+ (NSString *)plLoginUrl;
+ (NSString *)plLogoutUrl;

@end

@interface CommonURLSetting (TTMessageNotification)

+ (NSString*)messageNotificationListURLString; // 新消息通知列表
+ (NSString*)messageNotificationUnreadURLString; // 新消息通知未读提示

@end

@interface CommonURLSetting (TTFlowStatistics)

+ (NSString *)queryResidualFlowURLString;
+ (NSString *)updateResidualFlowURLString;

@end

@interface CommonURLSetting (TTCommonweal)

+ (NSString *)uploadUsingTimeURLString;

@end

@interface CommonURLSetting (TTGuideAmount)

+ (NSString *)guideAmountUrlString;

@end

@interface CommonURLSetting (TTRecordMusic)

+ (NSString *)getSongInfomationURLString;
+ (NSString *)getSongCollectionListURLString;
+ (NSString *)getSongListURLString;
+ (NSString *)searchSongListURLString;

@end

