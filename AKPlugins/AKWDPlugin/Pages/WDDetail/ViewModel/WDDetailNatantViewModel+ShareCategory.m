//
//  WDDetailNatantViewModel+ShareCategory.m
//  Article
//
//  Created by 延晋 张 on 2017/1/24.
//
//

#import "WDDetailNatantViewModel+ShareCategory.h"
#import "WDAnswerEntity.h"
#import "WDDetailModel.h"
#import "WDDetailUserPermission.h"
#import "WDCommonLogic.h"

#import "TTAdPromotionManager.h"
#import "TTAdPromotionContentItem.h"
#import "TTIndicatorView.h"
#import "TTRoute.h"
#import <NetworkUtilities.h>
#import "SDImageCache.h"
#import "TTURLUtils.h"

#import "TTActivityContentItemProtocol.h"
#import <TTWechatTimelineContentItem.h>
#import "TTWechatContentItem.h"
#import <TTQQFriendContentItem.h>
#import <TTQQZoneContentItem.h>
#import "TTFavouriteContentItem.h"
#import "TTReportContentItem.h"
#import "TTDislikeContentItem.h"
#import "TTDeleteContentItem.h"
#import "TTForwardWeitoutiaoContentItem.h"
#import "TTCommentStatContentItem.h"
#import "TTEditContentItem.h"
#import "TTFontSettingContentItem.h"

@implementation WDDetailNatantViewModel (ShareCategory)

#pragma mark - Util

- (NSString *)shareTitle
{
    NSString *questionTitle = self.detailModel.shareTitle;
    if (isEmptyString(questionTitle)) {
        questionTitle = [NSString stringWithFormat:@"%@(%@回答,%lld赞)",
                         self.detailModel.answerEntity.questionTitle,
                         self.detailModel.answerEntity.user.name,
                         self.detailModel.answerEntity.diggCount.longLongValue];
    }
    return questionTitle;
}

- (NSString *)shareDesc
{
    NSString *abstract = self.detailModel.answerEntity.abstract;
    return isEmptyString(abstract) ? NSLocalizedString(@"真房源，好中介，快流通", nil):abstract;
}

- (NSString *)qqZoneDesc
{
    NSDictionary * templatesDict = [WDCommonLogic getShareTemplate];
    NSString * qqZoneTemplate = [templatesDict objectForKey:@"qzone_sns"];
    return [WDCommonLogic parseShareContentWithTemplate:qqZoneTemplate title:[self shareTitle] shareURLString:self.detailModel.answerEntity.shareURL];
}

- (NSString *)shareUrl
{
    return self.detailModel.answerEntity.shareURL;
}


- (NSString *)shareImgUrl
{
    return self.detailModel.shareImgUrl;
}

- (UIImage *)shareImage
{
    return [[self class] weixinSharedImageForWendaShareImg:self.detailModel.shareImgUrl];
}

+ (UIImage *)weixinSharedImageForWendaShareImg:(NSString *)shareImgUrl
{
    UIImage * weixinImg = nil;
    
    if (!isEmptyString(shareImgUrl)) {
        weixinImg = [[SDImageCache sharedImageCache]
                     imageFromDiskCacheForKey:shareImgUrl];
    }
    
    //无数据时默认图：
    //优先使用share_icon.png分享
    if (!weixinImg) {
        weixinImg = [UIImage imageNamed:@"share_icon.png"];
    }
    //否则使用icon
    if(!weixinImg)
    {
        weixinImg = [UIImage imageNamed:@"Icon.png"];
    }
    
    return weixinImg;
}

#pragma mark - CustomItems

- (TTAdPromotionContentItem *)adPromotionItem
{
    
    TTActivityModel *model = [[TTActivityModel alloc] initWithDictionary:self.detailModel.adPromotion error:nil];
    TTAdPromotionContentItem * adPromotionItem = [[TTAdPromotionContentItem alloc] initWithTitle:model.label iconURL:model.icon_url];
    adPromotionItem.customAction = ^{
        [TTAdPromotionManager handleModel:model condition:nil];
        [TTAdPromotionManager trackEvent:@"sharebtn" label:@"click" extra:nil];
    };
    [TTAdPromotionManager trackEvent:@"sharebtn" label:@"show" extra:nil];
    return adPromotionItem;
}


- (TTCommentStatContentItem *)commentItem
{
    TTCommentStatContentItem *commentItem = [TTCommentStatContentItem new];
    commentItem.stat = self.detailModel.answerEntity.banComment;
    WeakSelf;
    commentItem.customAction = ^(void){
        StrongSelf;
        [self tt_opanAnswerCommentForAnswerIDFinishBlock:^(NSString *tips, NSError *error) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tips indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        }];
    };
    return commentItem;
}

- (TTDeleteContentItem *)deleteItem
{
    TTDeleteContentItem *deleteItem = [TTDeleteContentItem new];
    WeakSelf;
    deleteItem.customAction = ^(void){
        StrongSelf;
        self.isShowDeleteAnswer = YES;
    };
    return deleteItem;
}

- (TTEditContentItem *)editItem
{
    TTEditContentItem *editItem = [TTEditContentItem new];
    WeakSelf;
    editItem.customAction = ^(void) {
        StrongSelf;
        if ([NSURL URLWithString:self.detailModel.answerEntity.editAnswerSchema]) {
            [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:self.detailModel.answerEntity.editAnswerSchema] userInfo:nil];
        }
        [self.detailModel sendDetailTrackEventWithTag:kWDDetailViewControllerUMEventName label:@"edit"];
    };
    return editItem;
}

- (TTFavouriteContentItem *)favItem
{
    TTFavouriteContentItem *favItem = [TTFavouriteContentItem new];
    favItem.selected = self.detailModel.answerEntity.userRepined;
    WeakSelf;
    __weak TTFavouriteContentItem * weakFavItem = favItem;
    favItem.customAction = ^(void) {
        StrongSelf;
        if (!TTNetworkConnected()){
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                      indicatorText:NSLocalizedString(@"没有网络连接", nil)
                                     indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"]
                                        autoDismiss:YES
                                     dismissHandler:nil];
            return;
        }
        [self tt_willChangeArticleFavoriteState];
        weakFavItem.selected = self.detailModel.answerEntity.userRepined;
    };
    return favItem;
}

- (TTReportContentItem *)reportItem
{
    TTReportContentItem *reportItem = [TTReportContentItem new];
    WeakSelf;
    reportItem.customAction = ^(void) {
        StrongSelf;
        [self tt_willShowReport];
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
    
    parameters[@"fw_id"] = self.detailModel.repostParams.fw_id;
    parameters[@"fw_id_type"] = self.detailModel.repostParams.fw_id_type;
    parameters[@"opt_id"] = self.detailModel.repostParams.opt_id;
    parameters[@"opt_id_type"] = self.detailModel.repostParams.opt_id_type;
    parameters[@"fw_user_id"] = self.detailModel.repostParams.fw_user_id;
    parameters[@"repost_type"] = self.detailModel.repostParams.repost_type;
    parameters[@"cover_url"] = self.detailModel.repostParams.cover_url;
    parameters[@"title"] = self.detailModel.repostParams.title;
    parameters[@"schema"] = self.detailModel.repostParams.schema;
    
    [[TTRoute sharedRoute] openURLByPresentViewController:[NSURL URLWithString:@"sslocal://repost_page"] userInfo:TTRouteUserInfoWithDict([parameters copy])];
}

#pragma mark - 拼接模型

- (NSArray<id<TTActivityContentItemProtocol>> *)wd_customItems
{
    NSMutableArray *activityItems = @[].mutableCopy;
//    if (self.detailModel.adPromotion) {
//        //问答 增加号外入口
//        [activityItems addObject:[self adPromotionItem]];
//    }
    if ([self.detailModel.userPermission canForbidComment]) {
        [activityItems addObject:[self commentItem]];
    }
//    if ([self.detailModel.userPermission canDeleteAnswer]) {
//        [activityItems addObject:[self deleteItem]];
//    }
//    if ([self.detailModel.userPermission canEditAnswer]) {
//        [activityItems addObject:[self editItem]];
//    }
    
    [activityItems addObject:[self favItem]];
    //    [activityItems addObject:[TTNightModelContentItem new]];
    
    // add by zjing 去掉字体设置
//    [activityItems addObject:[TTFontSettingContentItem new]];
//        [activityItems addObject:[self reportItem]];
    return [activityItems copy];
}

- (NSArray<id<TTActivityContentItemProtocol>> *)wd_shareItems
{
    TTWechatTimelineContentItem *wcTlItem = [[TTWechatTimelineContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareTitle] webPageUrl:[self shareUrl] thumbImage:[self shareImage] shareType:TTShareWebPage];
    TTWechatContentItem *wcItem = [[TTWechatContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] shareType:TTShareWebPage];
    TTQQFriendContentItem *qqItem = [[TTQQFriendContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] imageUrl:[self shareImgUrl] shareTye:TTShareWebPage];
    TTQQZoneContentItem *qqZoneItem = [[TTQQZoneContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] imageUrl:[self shareImgUrl] shareTye:TTShareWebPage];
//    TTDingTalkContentItem *ddItem = [[TTDingTalkContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] shareType:TTShareWebPage];
//    TTSystemContentItem *sysItem = [[TTSystemContentItem alloc] initWithDesc:[self shareDesc] webPageUrl:[self shareUrl] image:[self shareImage]];
//    TTCopyContentItem *copyItem = [[TTCopyContentItem alloc] initWithDesc:[self shareUrl]];
    
    NSMutableArray<id<TTActivityContentItemProtocol>> *shareItems = [NSMutableArray array];
    //    if (![TTDeviceHelper isPadDevice] && self.detailModel.repostParams) {
    //        // 转发微头条
    //        TTForwardWeitoutiaoContentItem *wttItem = [self weiTouTiaoItem];
    //        [shareItems addObject:wttItem];
    //    }
    [shareItems addObjectsFromArray:@[wcTlItem, wcItem, qqItem, qqZoneItem]];
    
    return [shareItems copy];
}

@end
