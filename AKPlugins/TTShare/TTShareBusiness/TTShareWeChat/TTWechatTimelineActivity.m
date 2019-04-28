//
//  TTWechatTimelineActivity.m
//  TTActivityViewControllerDemo
//
//  Created by 延晋 张 on 16/6/6.
//
//

#import "TTWechatTimelineActivity.h"
#import "WXApi.h"
#import "TTWeChatShare.h"
#import "TTShareManager.h"
#import "TTShareAdapterSetting.h"

NSString * const TTActivityTypePostToWechatTimeline     = @"com.toutiao.UIKit.activity.PostToWechatTimeline";

@interface TTWechatTimelineActivity ()<TTWeChatShareDelegate>

@property (nonatomic,copy) TTActivityCompletionHandler completion;

@end

@implementation TTWechatTimelineActivity

#pragma mark - Identifier

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeWechatTimeLine;
}

- (NSString *)activityType
{
    return TTActivityTypePostToWechatTimeline;
}

#pragma mark - Display

- (NSString *)contentTitle
{
    if ([self.contentItem respondsToSelector:@selector(contentTitle)] && [self.contentItem contentTitle]) {
        return [self.contentItem contentTitle];
    } else {
        return @"朋友圈";
    }
}

- (NSString *)activityImageName
{
    if ([self.contentItem respondsToSelector:@selector(activityImageName)] && [self.contentItem activityImageName]) {
        return [self.contentItem activityImageName];
    } else {
        return @"pyq_allshare";
    }
}

- (NSString *)shareLabel
{
    return @"share_weixin_moments";
}

#pragma mark - Action

- (void)shareWithContentItem:(id <TTActivityContentItemProtocol>)contentItem presentingViewController:(UIViewController *)presentingViewController onComplete:(TTActivityCompletionHandler)onComplete
{
    self.contentItem = (TTWechatTimelineContentItem *)contentItem;
    [self performActivityWithCompletion:^(id<TTActivityProtocol> activity, NSError *error, NSString *desc) {
        if (onComplete) {
            onComplete(activity, error, desc);
        }
    }];
}

-(void)performActivityWithCompletion:(TTActivityCompletionHandler)completion
{
    self.completion = completion;
    
    [[TTShareAdapterSetting sharedService] activityWillSharedWith:self];

    TTWeChatShare *wechatShare = [TTWeChatShare sharedWeChatShare];
    wechatShare.delegate = self;
    
    TTWechatTimelineContentItem *wxTimeLineItem = self.contentItem;
    switch (wxTimeLineItem.shareType) {
        case TTShareText: {
            [wechatShare sendTextToScene:WXSceneTimeline withText:wxTimeLineItem.desc customCallbackUserInfo:wxTimeLineItem.callbackUserInfo];
        }
            break;
        case TTShareImage: {
            [wechatShare sendImageToScene:WXSceneTimeline withImage:wxTimeLineItem.image customCallbackUserInfo:wxTimeLineItem.callbackUserInfo];
        }
            break;
        case TTShareWebPage: {
            [wechatShare sendWebpageToScene:WXSceneTimeline withWebpageURL:wxTimeLineItem.webPageUrl thumbnailImage:wxTimeLineItem.thumbImage title:wxTimeLineItem.title description:wxTimeLineItem.desc customCallbackUserInfo:wxTimeLineItem.callbackUserInfo];
        }
            break;
        case TTShareVideo: {
            [wechatShare sendVideoToScene:WXSceneTimeline withVideoURL:wxTimeLineItem.webPageUrl thumbnailImage:wxTimeLineItem.thumbImage title:wxTimeLineItem.title description:wxTimeLineItem.desc customCallbackUserInfo:wxTimeLineItem.callbackUserInfo];
        }
            break;
        default:
            break;
    }
}

#pragma mark - TTWeChatShareDelegate

- (void)weChatShare:(TTWeChatShare *)weChatShare sharedWithError:(NSError *)error customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo
{
    NSString *desc = nil;
    if(error) {
        switch (error.code) {
            case kTTWeChatShareErrorTypeNotInstalled:
                desc = NSLocalizedString(@"您未安装微信", nil);
                break;
            case kTTWeChatShareErrorTypeNotSupportAPI:
                desc = NSLocalizedString(@"您的微信版本过低，无法支持分享", nil);
                break;
            case kTTWeChatShareErrorTypeExceedMaxImageSize:
                desc = NSLocalizedString(@"图片过大，分享图片不能超过10M", nil);
                break;
            default:
                desc = NSLocalizedString(@"分享失败", nil);
                break;
        }
    }else {
        desc = NSLocalizedString(@"分享成功", nil);
    }
    
    if (self.completion) {
        self.completion(self, error, desc);
    }
    
    [[TTShareAdapterSetting sharedService] activityHasSharedWith:self error:error desc:desc];
}

@end
