//
//  TTShareMethodUtil.m
//  Article
//
//  Created by 延晋 张 on 2017/1/25.
//
//

#import "TTShareMethodUtil.h"
//#import "FRImageInfoModel.h"
#import "Article.h"
#import "Article+TTADComputedProperties.h"
#import <TTImage/TTWebImageManager.h>
#import "Common.pbobjc.h"
#import "TTWebImageManager.h"
#import "TTWebImageManager+TTVSupport.h"

@implementation TTShareMethodUtil

#pragma mark - ShareType

+ (BOOL)isQQFriendShare:(id<TTActivityContentItemProtocol>)contentItem
{
    if ([[contentItem contentItemType] isEqualToString:TTActivityContentItemTypeQQFriend]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isQQZoneShare:(id<TTActivityContentItemProtocol>)contentItem
{
    if ([[contentItem contentItemType] isEqualToString:TTActivityContentItemTypeQQZone]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isWeChatShare:(id<TTActivityContentItemProtocol>)contentItem
{
    if ([[contentItem contentItemType] isEqualToString:TTActivityContentItemTypeWechat]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isWeChatTimeLineShare:(id<TTActivityContentItemProtocol>)contentItem
{
    if ([[contentItem contentItemType] isEqualToString:TTActivityContentItemTypeWechatTimeLine]) {
        return YES;
    } else {
        return NO;
    }
}

//+ (BOOL)isWeiboShare:(id<TTActivityContentItemProtocol>)contentItem
//{
//    if ([[contentItem contentItemType] isEqualToString:TTActivityContentItemTypeWeibo]) {
//        return YES;
//    } else {
//        return NO;
//    }
//}
//
//+ (BOOL)isDingTalkShare:(id<TTActivityContentItemProtocol>)contentItem
//{
//    if ([[contentItem contentItemType] isEqualToString:TTActivityContentItemTypeDingTalk]) {
//        return YES;
//    } else {
//        return NO;
//    }
//}
//
//+ (BOOL)isAliShare:(id<TTActivityContentItemProtocol>)contentItem
//{
//    if ([[contentItem contentItemType] isEqualToString:TTActivityContentItemTypeZhiFuBao]) {
//        return YES;
//    } else {
//        return NO;
//    }
//}

#pragma mark - RequestType

+ (DetailActionRequestType)requestTypeForShareActivityType:(id<TTActivityProtocol>)activity
{
    id<TTActivityContentItemProtocol> contentItem = [activity contentItem];
    NSString *contentItemType = [contentItem contentItemType];
    if ([self isQQFriendShare:contentItem]) {
        return DetailActionTypeQQShare;
    } else if ([self isQQZoneShare:contentItem]) {
        return DetailActionTypeQQZoneShare;
    } else if ([self isWeChatShare:contentItem]) {
        return DetailActionTypeWeixinFriendShare;
    } else if ([self isWeChatTimeLineShare:contentItem]) {
        return DetailActionTypeWeixinShare;
    }
//    } else if ([self isWeiboShare:contentItem]) {
//        return DetailActionTypeSystemShare; //微博之前无类型
//    } else if ([self isAliShare:contentItem]) {
//        return DetailActionTypeZhiFuBaoShare;
//    } else if ([self isDingTalkShare:contentItem]) {
//        return DetailActionTypeDingTalkShare;
//    } else if ([contentItemType isEqualToString:TTActivityTypePostToSystem] ||
//               [contentItemType isEqualToString:TTActivityTypePostToEmail] ||
//               [contentItemType isEqualToString:TTActivityTypePostToSMS] ||
//               [contentItemType isEqualToString:TTActivityTypePostToCopy]) {
//        return DetailActionTypeSystemShare;
//    }
    return DetailActionTypeNone;
}

#pragma mark - ShareLabel

+ (NSString *)labelNameForShareActivity:(id<TTActivityProtocol>)activity shareState:(BOOL)success
{
    NSString *activityDesc = [self labelNameForShareActivity:activity];
    NSString *suffix = success ? @"_done" : @"_fail";
    return [activityDesc stringByAppendingString:suffix];
}

+ (NSString *)labelNameForShareActivity:(id<TTActivityProtocol>)activity
{
    if (activity) {
        if ([activity respondsToSelector:@selector(shareLabel)]) {
            return [activity shareLabel];
        } else {
            return nil;
        }
        return [activity shareLabel];
    } else {
        return @"share_cancel_button";
    }
    
    //    else if (activityType == TTActivityTypeQQWeibo) {
    //        return @"share_tweibo";
    //    }
    //    else if (activityType == TTActivityTypeMyMoment) {
    //        return @"share_update";
    //    }
    //    else if (activityType == TTActivityTypeNone) {
    //        return @"share_cancel_button";
    //    }
    //    else if (activityType == TTActivityTypeShareButton) {
    //        return @"share_button";
    //    }
    //    else if (activityType == TTActivityTypeZhiFuBaoMoment) {
    //        return @"share_zhifubao_shenghuoquan";
    //    }
}

#pragma mark - 根据Article分享内容

+ (NSString *)weixinSharedImageURLForArticle:(Article *)article
{
    TTImageInfosModel *imageModel = nil;
    
    //尝试获取列表中图
    if (!imageModel) {
        imageModel = article.listMiddleImageModel;
    }
    
    //尝试获取列表大图
    if (!imageModel) {
        imageModel = article.listLargeImageModel;
    }
    
    //尝试获取列表组图
    if (!imageModel && [article.listGroupImgModels count] > 0) {
        imageModel = [article.listGroupImgModels firstObject];
    }
    
    //尝试获取详情缩略图
    if (!imageModel && [article.detailThumbImageModels count] > 0) {
        imageModel = [article.detailThumbImageModels firstObject];
    }
    
    //尝试获取详情组图
    if (!imageModel && [article.detailLargeImageModels count] > 0) {
        imageModel = [article.detailLargeImageModels firstObject];
    }
    
    return [imageModel urlStringAtIndex:0];
}

+ (UIImage *)weixinSharedImageForArticle:(Article *)article
{
    UIImage * weixinImg = nil;
    
    TTImageInfosModel *imageModel = nil;
    
    //尝试获取详情缩略图
    if (!weixinImg && !imageModel && [article.detailThumbImageModels count] > 0) {
        imageModel = [article.detailThumbImageModels firstObject];
    }
    
    if(!weixinImg && imageModel)
    {
        weixinImg = [TTWebImageManager imageForModel:imageModel];
    }
    
    //尝试获取列表中图
    if (!weixinImg) {
        imageModel = article.listMiddleImageModel;
    }
    
    if(!weixinImg && imageModel)
    {
        weixinImg = [TTWebImageManager imageForModel:imageModel];
    }
    
    //尝试获取列表大图
    if (!weixinImg) {
        imageModel = article.listLargeImageModel;
    }
    
    if(!weixinImg && imageModel)
    {
        weixinImg = [TTWebImageManager imageForModel:imageModel];
    }
    
    //尝试获取列表组图
    if (!weixinImg && [article.listGroupImgModels count] > 0) {
        imageModel = [article.listGroupImgModels firstObject];
    }
    
    if(!weixinImg && imageModel)
    {
        weixinImg = [TTWebImageManager imageForModel:imageModel];
    }
    
    //尝试获取详情组图
    if (!weixinImg && [article.detailLargeImageModels count] > 0) {
        imageModel = [article.detailLargeImageModels firstObject];
    }
    
    if(!weixinImg && imageModel)
    {
        weixinImg = [TTWebImageManager imageForModel:imageModel];
    }
    
    //尝试获取详情页logo大图
    if (!weixinImg && [article.videoDetailInfo objectForKey:VideoInfoImageDictKey]){
       NSDictionary  *videoDetailLargeImageDict = [article.videoDetailInfo objectForKey:VideoInfoImageDictKey];
        TTImageInfosModel *videoDetailLargeImagemodel = [[TTImageInfosModel alloc] initWithDictionary:videoDetailLargeImageDict];
        weixinImg = [TTWebImageManager imageForModel:videoDetailLargeImagemodel];
    }
    
    //尝试获取广告图片
    if (!weixinImg && article.adIDStr && [article adModel].imageModel) {
        weixinImg = [TTWebImageManager imageForModel:[article adModel].imageModel];
    }

    if (!weixinImg) {
        weixinImg = [UIImage imageNamed:@"share_icon.png"];
    }
    
    if(!weixinImg)
    {
        weixinImg = [UIImage imageNamed:@"Icon.png"];
    }

    return weixinImg;
}

+ (UIImage *)weixinSharedImageForVideoArticle:(TTVVideoArticle *)article
{
    UIImage * weixinImg = nil;

    TTVImageUrlList *imageModel = article.middleImageList;
    if (!imageModel) {
        imageModel = article.largeImageList;
    }

    weixinImg = [TTWebImageManager imageForTTVImageUrlList:imageModel];

    if (!weixinImg) {
        weixinImg = [UIImage imageNamed:@"share_icon.png"];
    }

    if(!weixinImg)
    {
        weixinImg = [UIImage imageNamed:@"Icon.png"];
    }

    return weixinImg;
}


+ (UIImage *)weixinSharedImageForWendaShareImg:(NSDictionary *)wendaShareInfo
{
    UIImage * weixinImg = nil;
    
    //优先显示话题icon
#warning API变动 重点回归
    weixinImg = [TTWebImageManager imageForURLString:[wendaShareInfo stringValueForKey:@"image_url" defaultValue:@""]];
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

+ (void)showIndicatorViewInActivityPanelWindowWithTip:(NSString *)tipMsg andImage:(UIImage *)indicatorImage dismissHandler:(DismissHandler)handler {
    //由于分享面板在pod中，暂时使用string构造class
    __block UIWindow * activityPanelControllerWindow = nil;
    Class activityPanelControllerWindowClass = NSClassFromString(@"TTActivityPanelControllerWindow");
    [[UIApplication sharedApplication].windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:activityPanelControllerWindowClass]) {
             activityPanelControllerWindow = obj;
            if (!activityPanelControllerWindow.hidden) {
                *stop = YES;
            }
        }
    }];
    
    TTIndicatorView * indicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage
                                                                        indicatorText:tipMsg
                                                                       indicatorImage:indicatorImage
                                                                       dismissHandler:handler];
    [indicatorView showFromParentView:activityPanelControllerWindow.rootViewController.view];
}


@end
