//
//  ExploreMomentDefine.h
//  Article
//
//  Created by Zhang Leonardo on 15-1-21.
//
//

#import <Foundation/Foundation.h>

#import "SSTTTAttributedLabel.h"
#import <ExploreMomentDefine_Enums.h>
static NSString *const ArticleMomentDetailViewAddMomentNoti = @"ArticleMomentDetailViewAddMomentNoti";
// 文章详情页右上角「…」
static NSString * const kPGCProfileEnterSourceArticleMore = @"article_more";
// 文章详情页标题下
static NSString * const kPGCProfileEnterSourceArticleTopAuthor = @"article_top_author";
// 文章详情页文末
static NSString * const kPGCProfileEnterSourceArticleBottomAuthor = @"article_bottom_author";
// 订阅频道-已订阅的头条号
static NSString * const kPGCProfileEnterSourceChannelSubscriptionSubscribed = @"channel_subscription_subscribed";
// 订阅频道-「订阅更多头条号页」-分类页
static NSString * const kPGCProfileEnterSourceChannelSubscriptionCategory = @"channel_subscription_category";
// 视频详情页
static NSString * const kPGCProfileEnterSourceVideoArticleTopAuthor = @"video_article_top_author";
// 视频频道feed右下角「…」
static NSString * const kPGCProfileEnterSourceVideoFeedMore = @"video_feed_more";
// 视频频道feed中的头条号icon
static NSString * const kPGCProfileEnterSourceVideoFeedAuthor = @"video_feed_author";
// 我的（作者看自己的头条号）
static NSString * const kPGCProfileEnterSourceAccount = @"account";
// 我的（作者看自己的头条号的作品管理）
static NSString * const kPGCProfileEnterWorkLibrarySourceAccount = @"work_library";

// 图集详情页右上角「...」
static NSString * const kPGCProfileEnterSourceGalleryArticleMore = @"gallery_article_more";
// 图集详情页右上角的头条号icon
static NSString * const kPGCProfileEnterSourceGalleryArticleTopAuthor = @"gallery_article_top_author";
// 从消息通知中的通知进入头条号首页
static NSString * const kPGCProfileEnterSourceNotification = @"notification";
// 从我的主页订阅列表中进入
static NSString * const kPGCProfileEnterSourceSocial = @"social";

// 视频facebook浮层
static NSString * const kPGCProfileEnterSourceFacebookFloat = @"video_float_author";

#ifndef Article_ExploreMomentDefine_h
#define Article_ExploreMomentDefine_h

static inline CGSize sizeOfString (NSString *str, CGFloat fontSize, CGFloat fixedWidth)
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSParagraphStyleAttributeName:paragraphStyle};
    CGSize size = [SSTTTAttributedLabel sizeThatFitsString:str withConstraints:CGSizeMake(fixedWidth, CGFLOAT_MAX) attributes:attributes limitedToNumberOfLines:10];
    
    return size;
}

static inline CGFloat heightOfString (NSString *str, CGFloat fontSize, CGFloat fixedWidth)
{
    return sizeOfString(str, fontSize, fixedWidth).height;
}

#endif
