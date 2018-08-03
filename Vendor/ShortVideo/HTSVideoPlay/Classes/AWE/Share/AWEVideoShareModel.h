//
//  AWEVideoShareModel.h
//  Pods
//
//  Created by 王双华 on 2017/8/24.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityContentItemProtocol.h"
#import <TTWechatTimelineContentItem.h>
#import "TTWechatContentItem.h"
#import <TTQQFriendContentItem.h>
#import <TTQQZoneContentItem.h>
#import "TTFavouriteContentItem.h"
#import "TTReportContentItem.h"
#import "TTDislikeContentItem.h"
//#import "TTSystemContentItem.h"
//#import "TTCopyContentItem.h"
//#import "TTSaveVideoContentItem.h"
#import "TTDeleteContentItem.h"
#import "TTForwardWeitoutiaoContentItem.h"

/*
 *  AWEVideoShareTypeDefault:
 *  第一排：微信朋友圈、微信好友、转发微头条、qq、qq空间 第二排：系统分享、复制链接、保存视频
 *  ps.如果是自己发的小视频，第二排只留下系统分享、复制链接
 *
 *  AWEVideoShareTypeMore:
 *  第一排：微信朋友圈、微信好友、转发微头条、qq、qq空间 第二排：收藏、不感兴趣、举报、保存视频、复制链接
 *  ps.如果是自己发的小视频，第二排只留下收藏、删除、
 *
 *  AWEVideoShareTypeMoreForStory:
 *  第一排：微信朋友圈、微信好友、转发微头条、qq、qq空间 第二排：收藏、举报、保存视频、复制链接
 *
 *  AWEVideoShareTypeAd:
 *  第一排：微信朋友圈、微信好友、转发微头条、qq、qq空间 第二排：收藏、举报、保存视频、复制链接
 */
typedef NS_ENUM (NSUInteger, AWEVideoShareType) {
    AWEVideoShareTypeDefault = 0,
    AWEVideoShareTypeMore = 1,
    AWEVideoShareTypeMoreForStory,
    AWEVideoShareTypeAd
};

@class TTShortVideoModel;

NS_ASSUME_NONNULL_BEGIN

@interface AWEVideoShareModel : NSObject

+ (NSString *)labelForContentItemType:(NSString *)contentItemType;

- (instancetype)initWithModel:(TTShortVideoModel *)model image:(UIImage *)shareImage shareType:(AWEVideoShareType)shareType;

- (NSArray<id<TTActivityContentItemProtocol>> *)shareContentItems;
- (NSArray<id<TTActivityContentItemProtocol>> *)forwardSharePanelContentItems;

- (TTWechatTimelineContentItem *)wechatMomentsContentItem;
- (TTWechatContentItem *)wechatContentItem;

@end

NS_ASSUME_NONNULL_END
