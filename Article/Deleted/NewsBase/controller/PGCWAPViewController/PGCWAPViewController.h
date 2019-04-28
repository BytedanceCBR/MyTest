//
//  PGCWAPViewController.h
//  Article
//
//  Created by hudianwei on 15-1-19.
//
//

#import "SSViewControllerBase.h"
#import "ExploreEntry.h"
#import "PGCAccount.h"

/**
 * 头条号主页来源统计
 */
extern NSString * const kPGCProfileEnterSourceArticleMore; // 文章详情页右上角「…」
extern NSString * const kPGCProfileEnterSourceArticleTopAuthor; // 文章详情页标题下
extern NSString * const kPGCProfileEnterSourceArticleBottomAuthor; // 文章详情页文末
extern NSString * const kPGCProfileEnterSourceChannelSubscriptionSubscribed; // 订阅频道-已订阅的头条号
extern NSString * const kPGCProfileEnterSourceChannelSubscriptionCategory; // 订阅频道-「订阅更多头条号页」-分类页
extern NSString * const kPGCProfileEnterSourceVideoArticleTopAuthor; // 视频详情页
extern NSString * const kPGCProfileEnterSourceVideoFeedMore; // 视频频道feed右下角「…」
extern NSString * const kPGCProfileEnterSourceVideoFeedAuthor; // video_feed_author
extern NSString * const kPGCProfileEnterSourceAccount; // 我的（作者看自己的头条号）
extern NSString * const kPGCProfileEnterSourceGalleryArticleMore; // 图集详情页右上角「...」
extern NSString * const kPGCProfileEnterSourceGalleryArticleTopAuthor; // 图集详情页右上角的头条号icon
extern NSString * const kPGCProfileEnterSourceVideoFloat;//视频浮层 cell左上角icon
extern NSString * const kPGCProfileEnterSourceNotification; // 从消息通知中的通知进入头条号首页
extern NSString * const kPGCProfileEnterSourceSocial; // 从我的主页订阅列表中进入


@interface PGCWAPViewController : SSViewControllerBase

+ (void)openWithMediaID:(NSString *)mediaID enterSource:(NSString *)source itemID:(NSString *)itemID;

//- (id)initWithBaseCondition:(NSDictionary *)baseCondition;

//- (id)initWithExploreEntry:(ExploreEntry *)aEntry enterSource:(NSString *)source;
//- (id)initWithPGCAccount:(PGCAccount *)account enterSource:(NSString *)source;

@end
