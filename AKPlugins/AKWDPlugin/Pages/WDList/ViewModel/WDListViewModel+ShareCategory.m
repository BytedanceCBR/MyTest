//
//  WDListViewModel+ShareCategory.m
//  Article
//
//  Created by 延晋 张 on 2017/1/24.
//
//

#import "WDListViewModel+ShareCategory.h"
#import "WDQuestionEntity.h"
#import "WDShareUtilsHelper.h"

#import "TTAdPromotionManager.h"

#import "SDWebImageManager.h"
#import <TTShareActivity.h>
#import "TTPanelActivity.h"
#import "TTAdPromotionContentItem.h"
#import <TTRoute/TTRoute.h>

@implementation WDListViewModel (ShareCategory)

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

#pragma mark - CustomItems

- (TTAdPromotionContentItem *)adPromotionItem
{
    TTActivityModel *model = [[TTActivityModel alloc] initWithDictionary:self.questionEntity.adPromotion error:nil];
    TTAdPromotionContentItem * adPromotionItem = [[TTAdPromotionContentItem alloc] initWithTitle:model.label iconURL:model.icon_url];
    adPromotionItem.customAction = ^{
        [TTAdPromotionManager handleModel:model condition:nil];
        [TTAdPromotionManager trackEvent:@"sharebtn" label:@"click" extra:nil];
    };
    [TTAdPromotionManager trackEvent:@"sharebtn" label:@"show" extra:nil];
    return adPromotionItem;
}

- (TTDeleteContentItem *)deleteItem
{
    TTDeleteContentItem *deleteItem = [TTDeleteContentItem new];
    WeakSelf;
    deleteItem.customAction = ^(void){
        StrongSelf;
        if (self.deleteBlock) {
            self.deleteBlock();
        }
    };
    deleteItem.canDelete = [self.questionEntity canDelete];
    return deleteItem;
}

- (TTEditContentItem *)editItem
{
    TTEditContentItem *editItem = [TTEditContentItem new];
    WeakSelf;
    editItem.customAction = ^(void) {
        StrongSelf;
        if (self.editBlock) {
            self.editBlock();
        }
    };
    editItem.canEdit = [self.questionEntity canEdit];
    return editItem;
}

- (TTReportContentItem *)reportItem
{
    TTReportContentItem *reportItem = [TTReportContentItem new];
    WeakSelf;
    reportItem.customAction = ^(void) {
        StrongSelf;
        [self reportQuestion];
    };
    return reportItem;
}

#pragma mark - Weitoutiao Forward
- (TTForwardWeitoutiaoContentItem *)weiTouTiaoItem {
    TTForwardWeitoutiaoContentItem *wttItem = [[TTForwardWeitoutiaoContentItem alloc] init];
    WeakSelf;
    wttItem.customAction = ^{
        StrongSelf;
        [self forwardToWeitoutiao];
    };
    return wttItem;
}

- (void)forwardToWeitoutiao {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    parameters[@"fw_id"] = self.repostParams.fw_id;
    parameters[@"fw_id_type"] = self.repostParams.fw_id_type;
    parameters[@"opt_id"] = self.repostParams.opt_id;
    parameters[@"opt_id_type"] = self.repostParams.opt_id_type;
    parameters[@"fw_user_id"] = self.repostParams.fw_user_id;
    parameters[@"repost_type"] = self.repostParams.repost_type;
    parameters[@"cover_url"] = self.repostParams.cover_url;
    parameters[@"title"] = self.repostParams.title;
    parameters[@"schema"] = self.repostParams.schema;
    
    [[TTRoute sharedRoute] openURLByPresentViewController:[NSURL URLWithString:@"sslocal://repost_page"] userInfo:TTRouteUserInfoWithDict([parameters copy])];
}

#pragma mark - 拼接模型

- (NSArray<id<TTActivityContentItemProtocol>> *)wd_customItems
{
    NSMutableArray *activityItems = @[].mutableCopy;
    if (self.questionEntity.adPromotion) {
        //问答 增加号外入口
//        [activityItems addObject:[self adPromotionItem]];
    }
//    if ([self.questionEntity shouldShowEdit]) {
//        [activityItems addObject:[self editItem]];
//    }
//    if ([self.questionEntity shouldShowDelete]) {
//        [activityItems addObject:[self deleteItem]];
//    }
    
//    [activityItems addObject:[TTNightModelContentItem new]];
    [activityItems addObject:[TTFontSettingContentItem new]];
    [activityItems addObject:[self reportItem]];
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
    
    NSMutableArray<id<TTActivityContentItemProtocol>> *shareItems = [NSMutableArray array];
//    if (![TTDeviceHelper isPadDevice] && self.repostParams) {
//        // 转发微头条
//        TTForwardWeitoutiaoContentItem *wttItem = [self weiTouTiaoItem];
//        [shareItems addObject:wttItem];
//    }
    [shareItems addObjectsFromArray:@[wcTlItem, wcItem, qqItem,qqZoneItem]];
    
    return [shareItems copy];
}

@end
