//
//  WDMoreListViewModel+ShareCategory.m
//  Article
//
//  Created by 延晋 张 on 2017/1/25.
//
//

#import "WDMoreListViewModel+ShareCategory.h"
#import "WDQuestionEntity.h"
#import "WDShareUtilsHelper.h"

#import <TTShareActivity.h>
#import "TTPanelActivity.h"
#import "SDWebImageManager.h"
#import "WDDefines.h"

@implementation WDMoreListViewModel (ShareCategory)

#pragma mark - Util

- (NSString *)shareTitle
{
    return [self.questionEntity.shareData tt_stringValueForKey:@"title"];
}

- (NSString *)shareDesc
{
    return [self.questionEntity.shareData tt_stringValueForKey:@"content"];
}

- (NSString *)shareUrl
{
    return [self.questionEntity.shareData tt_stringValueForKey:@"share_url"];
}

- (UIImage *)shareImage
{
    return [WDShareUtilsHelper weixinSharedImageForWendaShareImg:[self.questionEntity shareData]];
}

#pragma mark - 拼接模型

- (NSArray<id<TTActivityContentItemProtocol>> *)wd_customItems
{
    NSMutableArray *activityItems = @[].mutableCopy;
//    [activityItems addObject:[TTNightModelContentItem new]];
    // add by zjing 去掉字体设置
//    [activityItems addObject:[TTFontSettingContentItem new]];
    return [activityItems copy];
}

- (NSArray<id<TTActivityContentItemProtocol>> *)wd_shareItems
{
    TTWechatTimelineContentItem *wcTlItem = [[TTWechatTimelineContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareTitle] webPageUrl:[self shareUrl] thumbImage:[self shareImage] shareType:TTShareWebPage];
    TTWechatContentItem *wcItem = [[TTWechatContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] shareType:TTShareWebPage];
    TTQQFriendContentItem *qqItem = [[TTQQFriendContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] imageUrl:nil shareTye:TTShareWebPage];
    TTQQZoneContentItem *qqZoneItem = [[TTQQZoneContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] imageUrl:nil shareTye:TTShareWebPage];
//    TTDingTalkContentItem *ddItem = [[TTDingTalkContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] shareType:TTShareWebPage];
//    TTSystemContentItem *sysItem = [[TTSystemContentItem alloc] initWithDesc:[self shareDesc] webPageUrl:[self shareUrl] image:[self shareImage]];
//    TTCopyContentItem *copyItem = [[TTCopyContentItem alloc] initWithDesc:[self shareUrl]];
    
    return @[wcTlItem, wcItem, qqItem, qqZoneItem];
}

@end
