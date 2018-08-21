//
//  WDWendaListCell+Share.m
//  Article
//
//  Created by xuzichao on 2017/6/13.
//
//

#import "WDWendaListCell+Share.h"
#import "WDShareUtilsHelper.h"
#import "WDDefines.h"
#import <TTShare/TTActivityContentItemProtocol.h>
#import <AKShareServicePlugin/TTShareActivity.h>

@interface  WDWendaListCellShareHelper ()

@property (nonatomic, strong) WDAnswerEntity *answerEnity;

@property (nonatomic, copy) NSString *sharePlatform;

@end

@implementation WDWendaListCellShareHelper

- (instancetype)initWithAnswerEntity:(WDAnswerEntity *)entity
{
    self = [super init];
    if (self) {
        self.answerEnity = entity;
    }
    return self;
}

- (id<TTActivityContentItemProtocol>)getItemWithActivityType:(NSString *)activityTypeString {
    id<TTActivityContentItemProtocol> item = nil;
    if ([activityTypeString isEqualToString:TTActivityContentItemTypeWechatTimeLine]) {
        TTWechatTimelineContentItem *wcTlItem = [[TTWechatTimelineContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareTitle] webPageUrl:[self shareUrl] thumbImage:[self shareImage] shareType:TTShareWebPage];
        item = wcTlItem;
        self.sharePlatform = @"weixin_moments";
    } else if ([activityTypeString isEqualToString:TTActivityContentItemTypeWechat]) {
        TTWechatContentItem *wcItem = [[TTWechatContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] shareType:TTShareWebPage];
        item = wcItem;
        self.sharePlatform = @"weixin";
    } else if ([activityTypeString isEqualToString:TTActivityContentItemTypeQQFriend]) {
        TTQQFriendContentItem *qqItem = [[TTQQFriendContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] imageUrl:nil shareTye:TTShareWebPage];
        item = qqItem;
        self.sharePlatform = @"qq";
    } else if ([activityTypeString isEqualToString:TTActivityContentItemTypeQQZone]) {
        TTQQZoneContentItem *qqZoneItem = [[TTQQZoneContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] imageUrl:nil shareTye:TTShareWebPage];
        item = qqZoneItem;
        self.sharePlatform = @"qzone";
    }
    return item;
}

#pragma mark - Util

- (NSString *)shareTitle
{
    return [self.answerEnity.shareData tt_stringValueForKey:@"title"];
}

- (NSString *)shareDesc
{
    return [self.answerEnity.shareData tt_stringValueForKey:@"content"];
}

- (NSString *)shareUrl
{
    return [self.answerEnity.shareData tt_stringValueForKey:@"share_url"];
}

- (UIImage *)shareImage
{
    return [WDShareUtilsHelper weixinSharedImageForWendaShareImg:[self.answerEnity shareData]];
}

@end
