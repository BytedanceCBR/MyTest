//
//  TTQQZoneActivity.m
//  Pods
//
//  Created by 张 延晋 on 16/06/03.
//
//

#import "TTQQZoneActivity.h"
#import "TTQQShare.h"
#import "TTShareManager.h"
#import "TTShareAdapterSetting.h"
#import <TencentOpenAPI/QQApiInterface.h>

NSString * const TTActivityTypePostToQQZone             = @"com.toutiao.UIKit.activity.PostToQQZone";

@interface TTQQZoneActivity () <TTQQShareDelegate>

@property (nonatomic,copy) TTActivityCompletionHandler completion;

@end

@implementation TTQQZoneActivity

#pragma mark - Identifier

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeQQZone;
}

- (NSString *)activityType
{
    return TTActivityTypePostToQQZone;
}

#pragma mark - Display

- (NSString *)contentTitle
{
    if ([self.contentItem respondsToSelector:@selector(contentTitle)] && [self.contentItem contentTitle]) {
        return [self.contentItem contentTitle];
    } else {
        return @"QQ空间";
    }
}

- (NSString *)activityImageName
{
    if ([self.contentItem respondsToSelector:@selector(activityImageName)] && [self.contentItem activityImageName]) {
        return [self.contentItem activityImageName];
    } else {
        return @"qqkj_allshare";
    }
}

- (NSString *)shareLabel
{
    return @"share_qzone";
}

#pragma mark - Action

- (void)shareWithContentItem:(id <TTActivityContentItemProtocol>)contentItem presentingViewController:(UIViewController *)presentingViewController onComplete:(TTActivityCompletionHandler)onComplete
{
    self.contentItem = (TTQQZoneContentItem *)contentItem;
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

    TTQQShare *qqshare = [TTQQShare sharedQQShare];
    qqshare.delegate = self;
    
    TTQQZoneContentItem *qqZoneItem = self.contentItem;
    switch (qqZoneItem.shareType) {
        case TTShareImage: {
            [qqshare sendImageToQZoneWithImage:qqZoneItem.image title:qqZoneItem.title customCallbackUserInfo:qqZoneItem.callbackUserInfo];
        }
            break;
        case TTShareWebPage:{
            [qqshare sendNewsToQZoneWithURL:qqZoneItem.webPageUrl thumbnailImage:qqZoneItem.thumbImage thumbnailImageURL:qqZoneItem.imageUrl title:qqZoneItem.title description:qqZoneItem.desc customCallbackUserInfo:qqZoneItem.callbackUserInfo];
        }
            break;
        case TTShareVideo:{
            [qqshare sendNewsToQZoneWithURL:qqZoneItem.webPageUrl thumbnailImage:qqZoneItem.thumbImage thumbnailImageURL:qqZoneItem.imageUrl title:qqZoneItem.title description:qqZoneItem.desc customCallbackUserInfo:qqZoneItem.callbackUserInfo];
        }
            break;
        default: {
            NSAssert(0, @"未添加该分享方式");
        }
            break;
    }
}

#pragma mark - TTQQShareDelegate

- (void)qqShare:(TTQQShare *)qqShare sharedWithError:(NSError *)error customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo
{
    NSString *desc = nil;
    if (!error) {
        desc = NSLocalizedString(@"QQ分享成功", nil);
    }else{
        switch (error.code) {
            case kTTQQShareErrorTypeNotInstalled:
                desc = NSLocalizedString(@"您未安装QQ", nil);
                break;
            case kTTQQShareErrorTypeNotSupportAPI:
                desc = NSLocalizedString(@"您的QQ版本过低，无法支持分享", nil);
                break;
            default:
                desc = NSLocalizedString(@"QQ分享失败", nil);
                break;
        }
    }

    if (self.completion) {
        self.completion(self, error, desc);
    }
    
    [[TTShareAdapterSetting sharedService] activityHasSharedWith:self error:error desc:desc];
}

@end

