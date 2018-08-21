//
//  TTRSharePannel.m
//  TTWebViewBundle
//
//  Created by muhuai on 2017/11/20.
//  Copyright © 2017年 muhuai. All rights reserved.
//

#import "TTRSharePanel.h"
#import <TTRexxar/TTRJSBForwarding.h>
#import <TTShare/TTShareManager.h>
#import <TTShare/TTWechatTimelineContentItem.h>
#import <TTShare/TTWechatContentItem.h>
#import <TTShare/TTQQZoneContentItem.h>
#import <TTShare/TTQQFriendContentItem.h>
//#import <TTShare/TTDingTalkContentItem.h>
//#import <TTShare/TTSMSContentItem.h>
//#import <TTShare/TTCopyContentItem.h>
//#import <TTShare/TTEmailContentItem.h>
//#import <TTShare/TTSystemContentItem.h>
#import <TTThemed/UIImage+TTThemeExtension.h>
#import <TTUIWidget/TTIndicatorView.h>
#import <TTImage/TTWebImageManager.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>

@interface TTRSharePanel()<TTShareManagerDelegate>
@property (nonatomic, strong) TTShareManager *shareManager;
@property (nonatomic, strong) NSSet *shareActivityContentItemTypes;

@end
@implementation TTRSharePanel

+ (void)load {
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRSharePanel.showSharePanel" for:@"showSharePanel"];
}

+ (TTRJSBInstanceType)instanceType {
    return TTRJSBInstanceTypeWebView;
}

- (void)showSharePanelWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString *title = [param tt_stringValueForKey:@"title"];
    NSString *content = [param tt_stringValueForKey:@"content"];
    NSString *imageURL = [param tt_stringValueForKey:@"image_url"];
    NSString *webPageURL = [param tt_stringValueForKey:@"url"];
    
    if (webPageURL.length <= 0) {
        TTR_CALLBACK_WITH_MSG(TTRJSBMsgParamError, @"url不能为空")
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    void (^showSharePanel)(UIImage *thumbImage) = ^(UIImage *thumbImage) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSArray *contentItems = [strongSelf shareContentItemsWithTitle:title content:content thumbImage:thumbImage webPageURL:webPageURL];
        [strongSelf.shareManager displayActivitySheetWithContent:contentItems];
        TTR_CALLBACK_SUCCESS
    };
    
    UIImage *thumbImage = [TTWebImageManager imageForURLString:imageURL];
    
    if (thumbImage) {
        showSharePanel(thumbImage);
    } else {
        TTIndicatorView *indicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleWaitingView indicatorText:nil indicatorImage:nil dismissHandler:nil];
        indicatorView.autoDismiss = NO;
        [indicatorView showFromParentView:controller.view];
        
        [[TTWebImageManager shareManger] downloadImageWithURL:imageURL options:TTWebImageHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
            [indicatorView dismissFromParentView];
            showSharePanel(image);
        }];
    }
}

- (nullable NSArray<NSArray *> *)shareContentItemsWithTitle:(NSString *)title content:(NSString *)content thumbImage:(UIImage *)thumbImage webPageURL:(NSString *)webPageURL {
    NSString * shareTitle = title;
    NSString * shareDescribe = content;
    NSMutableSet * shareActivityContentItemTypes = [NSMutableSet set];
    
    //微信朋友圈分享
    TTWechatTimelineContentItem * wctlContentItem = [[TTWechatTimelineContentItem alloc] initWithTitle:shareDescribe
                                                                                                  desc:nil
                                                                                            webPageUrl:webPageURL
                                                                                            thumbImage:thumbImage
                                                                                             shareType:TTShareWebPage];
    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeWechatTimeLine];
    
    //微信好友分享
    TTWechatContentItem *wcContentItem = [[TTWechatContentItem alloc] initWithTitle:shareTitle
                                                                               desc:shareDescribe
                                                                         webPageUrl:webPageURL
                                                                         thumbImage:thumbImage
                                                                          shareType:TTShareWebPage];
    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeWechat];
    
    //QQ好友分享
    TTQQFriendContentItem * qqContentItem = [[TTQQFriendContentItem alloc] initWithTitle:shareTitle
                                                                                    desc:shareDescribe
                                                                              webPageUrl:webPageURL
                                                                              thumbImage:thumbImage
                                                                                imageUrl:nil
                                                                                shareTye:TTShareWebPage];
    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeQQFriend];
    
    //QQ空间分享
    TTQQZoneContentItem * qqZoneContentItem = [[TTQQZoneContentItem alloc] initWithTitle:shareTitle
                                                                                    desc:shareDescribe
                                                                              webPageUrl:webPageURL
                                                                              thumbImage:thumbImage
                                                                                imageUrl:nil
                                                                                shareTye:TTShareWebPage];
    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeQQZone];
    
//    //钉钉分享
//    TTDingTalkContentItem * ddContentItem = [[TTDingTalkContentItem alloc] initWithTitle:shareTitle
//                                                                                    desc:shareDescribe
//                                                                              webPageUrl:webPageURL
//                                                                              thumbImage:thumbImage
//                                                                               shareType:TTShareWebPage];
//    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeDingTalk];
//
//
//    TTSystemContentItem *sysContentItem = [[TTSystemContentItem alloc] initWithDesc:shareDescribe
//                                                                         webPageUrl:webPageURL
//                                                                              image:thumbImage];
//    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeSystem];
//
//    TTSMSContentItem *smsContentItem = [[TTSMSContentItem alloc] initWithDesc:webPageURL];
//    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeSMS];
//
//    TTEmailContentItem *mailContentItem = [[TTEmailContentItem alloc] initWithTitle:title desc:[NSString stringWithFormat:@"%@\n%@", shareDescribe.length? shareDescribe: @"", webPageURL]];
//    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeEmail];
//
//    TTCopyContentItem *copyContentItem = [[TTCopyContentItem alloc] initWithDesc:[NSString stringWithFormat:@"%@\n%@\n%@", title.length? title: @"", shareDescribe.length? shareDescribe: @"", webPageURL]];
//    [shareActivityContentItemTypes addObject:TTActivityContentItemTypeCopy];
    
    self.shareActivityContentItemTypes = shareActivityContentItemTypes.copy;
    
    NSMutableArray *SeqArray = @[].mutableCopy;
        [SeqArray addObject: wctlContentItem];
        [SeqArray addObject: wcContentItem];
        [SeqArray addObject: qqContentItem];
        [SeqArray addObject: qqZoneContentItem];
//        [SeqArray addObject:ddContentItem];
    
//    return @[@[wctlContentItem, wcContentItem, qqContentItem, qqZoneContentItem, ddContentItem], @[sysContentItem, smsContentItem, mailContentItem, copyContentItem]];
    return @[@[wctlContentItem, wcContentItem, qqContentItem, qqZoneContentItem]];
}

- (NSString *)platformWithContentItemType:(NSString *)itemType {
    if ([itemType isEqualToString:TTActivityContentItemTypeWechatTimeLine]) {
        return @"weixin_timeline";
    }
    if ([itemType isEqualToString:TTActivityContentItemTypeWechat]) {
        return @"weixin";
    }
    if ([itemType isEqualToString:TTActivityContentItemTypeQQFriend]) {
        return @"qq";
    }
    if ([itemType isEqualToString:TTActivityContentItemTypeQQZone]) {
        return @"qzone";
    }
//    if ([itemType isEqualToString:TTActivityContentItemTypeDingTalk]) {
//        return @"dingding";
//    }
//    if ([itemType isEqualToString:TTActivityContentItemTypeSystem]) {
//        return @"system";
//    }
//    if ([itemType isEqualToString:TTActivityContentItemTypeSMS]) {
//        return @"sms";
//    }
//    if ([itemType isEqualToString:TTActivityContentItemTypeEmail]) {
//        return @"email";
//    }
//    if ([itemType isEqualToString:TTActivityContentItemTypeCopy]) {
//        return @"copy";
//    }
    return itemType;
}

#pragma mark - TTShareManagerDelegate
- (void)shareManager:(TTShareManager *)shareManager
         clickedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController {
    
}

- (void)shareManager:(TTShareManager *)shareManager
       completedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
               error:(NSError *)error
                desc:(NSString *)desc {
    NSString *contentItemType = activity.contentItem.contentItemType;
    if (![self.shareActivityContentItemTypes containsObject:contentItemType]) {
        return;
    }
    if(!isEmptyString(desc)) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:desc
                                 indicatorImage:[UIImage themedImageNamed:error ? @"close_popup_textpage.png" : @"doneicon_popup_textpage.png"]
                                    autoDismiss:YES
                                 dismissHandler:nil];
    }
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithCapacity:3];
    [data setValue:[self platformWithContentItemType:contentItemType] forKey:@"platform"];
    [data setValue:error.description forKey:@"msg"];
    [data setValue:@(error? 1: 2) forKey:@"code"];
    [self.engine ttr_fireEvent:@"share_result" data:[data copy]];
    
}


- (TTShareManager *)shareManager {
    if (nil == _shareManager) {
        _shareManager = [[TTShareManager alloc] init];
        _shareManager.delegate = self;
    }
    return _shareManager;
}
@end
