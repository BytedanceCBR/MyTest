//
//  TTWechatActivity.m
//  TTActivityViewControllerDemo
//
//  Created by 延晋 张 on 16/6/6.
//
//

#import "TTWechatActivity.h"
#import "WXApi.h"
#import "TTWeChatShare.h"
#import "TTShareManager.h"
#import "TTShareAdapterSetting.h"

NSString * const TTActivityTypePostToWechat             = @"com.toutiao.UIKit.activity.PostToWechat";

@interface TTWechatActivity () <TTWeChatShareDelegate>

@property (nonatomic,copy) TTActivityCompletionHandler completion;

@end

@implementation TTWechatActivity

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeWechat;
}

- (NSString *)activityType
{
    return TTActivityTypePostToWechat;
}

#pragma mark - Display

- (NSString *)contentTitle
{
    if ([self.contentItem respondsToSelector:@selector(contentTitle)] && [self.contentItem contentTitle]) {
        return [self.contentItem contentTitle];
    } else {
        return @"微信";
    }
}

- (NSString *)activityImageName
{
    if ([self.contentItem respondsToSelector:@selector(activityImageName)] && [self.contentItem activityImageName]) {
        return [self.contentItem activityImageName];
    } else {
        return @"weixin_allshare";
    }
}

- (NSString *)shareLabel
{
    return @"share_weixin";
}

#pragma mark - Action

- (void)shareWithContentItem:(id<TTActivityContentItemProtocol>)contentItem presentingViewController:(UIViewController *)presentingViewController onComplete:(TTActivityCompletionHandler)onComplete
{
    self.contentItem = (TTWechatContentItem *)contentItem;
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
    
    TTWechatContentItem *wechatItem = [self contentItem];
    switch (wechatItem.shareType) {
        case TTShareText: {
            [wechatShare sendTextToScene:WXSceneSession withText:wechatItem.desc customCallbackUserInfo:wechatItem.callbackUserInfo];
        }
            break;
        case TTShareImage: {
            [wechatShare sendImageToScene:WXSceneSession withImage:wechatItem.image customCallbackUserInfo:wechatItem.callbackUserInfo];
        }
            break;
        case TTShareWebPage: {
            [wechatShare sendWebpageToScene:WXSceneSession withWebpageURL:wechatItem.webPageUrl thumbnailImage:wechatItem.thumbImage title:wechatItem.title description:wechatItem.desc customCallbackUserInfo:wechatItem.callbackUserInfo];
        }
            break;
        case TTShareVideo: {
            [wechatShare sendVideoToScene:WXSceneSession withVideoURL:wechatItem.webPageUrl thumbnailImage:wechatItem.thumbImage title:wechatItem.title description:wechatItem.desc customCallbackUserInfo:wechatItem.callbackUserInfo];
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
