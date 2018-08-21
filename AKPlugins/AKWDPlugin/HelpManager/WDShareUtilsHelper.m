//
//  WDShareUtilsHelper.m
//  Article
//
//  Created by xuzichao on 2017/6/13.
//
//

#import "WDShareUtilsHelper.h"
#import "TTWebImageManager.h"
#import "WDDefines.h"
#import "TTQQFriendContentItem.h"
#import "TTQQZoneContentItem.h"
#import "TTWechatContentItem.h"
#import "TTWechatTimelineContentItem.h"

@implementation WDShareUtilsHelper

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
}


+ (DetailActionRequestType)requestTypeForShareActivityType:(id<TTActivityProtocol>)activity
{
    id<TTActivityContentItemProtocol> contentItem = [activity contentItem];
    NSString *contentItemType = [contentItem contentItemType];
    if (contentItemType == TTActivityContentItemTypeQQFriend) {
        return DetailActionTypeQQShare;
    }
    else if (contentItemType == TTActivityContentItemTypeQQZone) {
        return DetailActionTypeQQZoneShare;
    }
    else if (contentItemType == TTActivityContentItemTypeWechat) {
        return DetailActionTypeWeixinFriendShare;
    }
    else if (contentItemType == TTActivityContentItemTypeWechatTimeLine) {
        return DetailActionTypeWeixinShare;
    }
//    else if (contentItemType == TTActivityContentItemTypeWeibo) {
//        return DetailActionTypeSystemShare; //微博之前无类型
//    }
//    else if (contentItemType == TTActivityContentItemTypeZhiFuBao) {
//        return DetailActionTypeZhiFuBaoShare;
//    }
//    else if (contentItemType == TTActivityContentItemTypeDingTalk) {
//        return DetailActionTypeDingTalkShare;
//    }
//    else if ([contentItemType isEqualToString:TTActivityTypePostToSystem] ||
//             [contentItemType isEqualToString:TTActivityTypePostToEmail] ||
//             [contentItemType isEqualToString:TTActivityTypePostToSMS] ||
//             [contentItemType isEqualToString:TTActivityTypePostToCopy]) {
//        return DetailActionTypeSystemShare;
//    }
    
    return DetailActionTypeNone;
}

+ (UIImage *)weixinSharedImageForWendaShareImg:(NSDictionary *)wendaShareInfo
{
    UIImage * weixinImg = nil;
    
    //优先显示话题icon
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



@end
