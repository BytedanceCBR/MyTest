//
//  ArticleURLSetting.h
//  Article
//
//  Created by Dianwei on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonURLSetting.h"

@interface ArticleURLSetting : CommonURLSetting

/**
 *  获取添加订阅的api
 *
 *  @return 获取添加订阅的api的URL string
 */
+ (NSString *)articleEntryListURLString;
+ (NSString*)articleItemActionURLString;
+ (NSString*)recentURLString;
+ (NSString *)encrpytionStreamUrlString;
+ (NSString *)movieCommentVideoTabURLString;
+ (NSString *)movieCommentEntireTabURLString;
+ (NSString *)verticalVideoURLString;
+ (NSString*)getFavoritesURLString;
+ (NSString*)getHistoryURLString;
+ (NSString*)deleteHistoryURLString;
+ (NSString*)searchURLString;
+ (NSString*)findWebURLString;
+ (NSString *)streamAPIVersionString;
/// 使用网页搜索的URL
+ (NSString*)searchWebURLString;
+ (NSString *)searchInitialPageURLString;
+ (NSString *)searchSuggestionURLString;

+ (NSString*)hotCommentURLString;
+ (NSString*)recommendForumURLString;

+ (NSString *)refreshTipURLString;
+ (NSString*)essayDetailURLString;
/*
 *  新闻信息API
 *  方法:Get
 */
+ (NSString *)newArticleInfoString;
+ (NSString*)cityURLString;

//详情页CDN
+ (NSString *)detailFullPathString;
+ (NSString *)detailContentPathString;
+ (NSString *)detailCDNAPIVersionString;
+ (NSString *)detailPaidNovelFullURLString;
+ (NSString *)detailPaidNovelContentURLString;

#pragma mark -- PGC
+ (NSString *)fetchEntryURLString;
+ (NSString *)PGCProfileURLString;
+ (NSString *)PGCArticleURLString;
+ (NSString *)PGCStatisticsURLString;
+ (NSString *)PGCLikeUserURLString;

#pragma mark - 新版动态URL

+ (NSString*)momentListURLString;
+ (NSString*)momentUpdateNumberURLString;
+ (NSString*)momentDetailURLString;
+ (NSString*)momentDetailURLStringV8;
+ (NSString*)momentDetailListURLString;
+ (NSString*)momentDiggedUsersURLString;
+ (NSString*)momentCommentURLString;
+ (NSString*)momentCommentURLStringV4;


/**
 评论动态URL
 */
+ (NSString*)commentDetailURLString;
+ (NSString*)commentDiggedUsersURLString;
+ (NSString*)replyedCommentListURLString;
+ (NSString*)replyedCommentDigURLString;
+ (NSString*)postReplyedCommentURLString;
+ (NSString*)deleteReplyedCommentURLString;

+ (NSString*)momentPostCommentURLString;
+ (NSString*)momentDiggURLString;
+ (NSString*)momentCancelDiggURLString;
+ (NSString*)momentCommentDiggURLString;

// 新消息/通知
+ (NSString*)followGetUpdateNumberURLString;

#pragma mark - 手机号注册相关
// 发送验证码
+ (NSString*)PRSendCodeURLString;
+ (NSString*)PRRegisterURLString;
+ (NSString*)PRRefreshCaptchaURLString;
+ (NSString*)PRLoginURLString;
+ (NSString*)PRMailLoginURLString;
+ (NSString*)PRQuickLoginURLString;
+ (NSString*)PRResetPasswordURLString;
+ (NSString*)PRChangePasswordURLString;
+ (NSString*)PRBindPhoneURLString;
+ (NSString*)PRUnbindPhoneURLString;
+ (NSString*)uploadAddressBookURLString;
+ (NSString*)uploadAddressBookV2URLString;

+ (NSString*)PRChangePhoneNumberURLString;

+ (NSString*)userProtocolURLString;
+ (NSString*)functionExtensionURLString;
+ (NSString*)userPrivateProtocolURLString;
+ (NSString*)protectedProtocolURLString;

#pragma mark -- 删除
/**
 *  删除动态
 */
+ (NSString *)deleteMomentURLString;
/**
 *  删除文章评论
 */
+ (NSString *)deleteArticleCommentURLString;
+ (NSString *)deleteArticleNewCommentURLString;
/**
 *  删除动态评论
 */
+ (NSString *)deleteMomentCommentURLString;

// 话题
+ (NSString *)forumInfoURLString;
+ (NSString *)followForumURLString;
+ (NSString *)unfollowForumURLString;
+ (NSString *)myForumWebURLString;
+ (NSString *)topicListURLString; //4.6 added 
+ (NSString*)topicDiscoverString; //4.6 added

// 动态
+ (NSString*)discoverNumberURLString;
//动态管理入口url
+ (NSString*)momentAdminURL;

//头条tv api version
+ (NSString *)toutiaoVideoAPIVersion;
//头条tv
+ (NSString *)toutiaoVideoAPIURL;
//乐视tv
+ (NSString *)leTVAPIURL;
//相关视频
+ (NSString *)relatedVideoURL;
//视频设置
+ (NSString *)videoSettingURLString;

+ (NSString *)pushSettingURL;

+ (NSString *)moreForumURL;
+ (NSString *)concernGuideURL;

// 个人主页
+ (NSString *)wapProfileURL;

//5.4 监控
+ (NSString *)monitorURL;

+ (NSString *)monitorURLForBaseURL:(NSString *)baseUrl;

//5.5 我的关注
+ (NSString *)myFollowURL;

+ (NSString *)contInfoV2URLString;

//首页搜索框提示
+ (NSString *)searchPlaceholderTextURLString;

//小视频 点赞api
+ (NSString *)shortVideoDiggUpURL;

//小视频 取消点赞api
+ (NSString *)shortVideoCancelDiggURL;

//小视频 请求单个视频
+ (NSString *)shortVideoInfoURL;

//小视频 个人主页loadmore
+ (NSString *)shortVideoLoadMoreURL;

//小视频 活动页loadmore
+ (NSString *)shortVideoActivityListLoadMoreURL;

//检测App更新
+ (NSString *)checkVersionURL;

//获取推荐好友关注列表接口
+ (NSString *)relationFriendsActivityURLString;

//获取春节活动分享短链
+ (NSString *)SFShareShotLinkURLString;

//爱看获取收益信息的接口
+ (NSString *)AKProfileBenefitInfo;

//爱看获取我的页面图片通知的接口
+ (NSString *)AKFetchAlertInfo;

//爱看获取阅读、观看视频金币
+ (NSString *)AKGetReadBonus;
@end


