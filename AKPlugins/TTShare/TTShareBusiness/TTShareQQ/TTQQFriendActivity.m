//
//  TTQQFriendActivity.m
//  Pods
//
//  Created by 张 延晋 on 16/06/03.
//
//

#import "TTQQFriendActivity.h"
#import "TTShareManager.h"
#import "TTQQShare.h"
#import "TTShareAdapterSetting.h"

NSString * const TTActivityTypePostToQQFriend           = @"com.toutiao.UIKit.activity.PostToQQFriend";

@interface TTQQFriendActivity () <TTQQShareDelegate>

@property (nonatomic,copy) TTActivityCompletionHandler completion;

@end

@implementation TTQQFriendActivity

#pragma mark - Identifier

-(NSString *)contentItemType
{
    return TTActivityContentItemTypeQQFriend;
}

-(NSString *)activityType
{
    return TTActivityTypePostToQQFriend;
}

#pragma mark - Display

- (NSString *)contentTitle
{
    if ([self.contentItem respondsToSelector:@selector(contentTitle)] && [self.contentItem contentTitle]) {
        return [self.contentItem contentTitle];
    } else {
        return @"QQ";
    }
}

- (NSString *)activityImageName
{
    if ([self.contentItem respondsToSelector:@selector(activityImageName)] && [self.contentItem activityImageName]) {
        return [self.contentItem activityImageName];
    } else {
        return @"qq_allshare";
    }
}

- (NSString *)shareLabel
{
    return @"share_qq";
}

#pragma mark - Action

- (void)shareWithContentItem:(id <TTActivityContentItemProtocol>)contentItem presentingViewController:(UIViewController *)presentingViewController onComplete:(TTActivityCompletionHandler)onComplete
{
    self.contentItem = (TTQQFriendContentItem *)contentItem;
    [self performActivityWithCompletion:^(id<TTActivityProtocol> activity, NSError *error, NSString *desc) {
        if (onComplete) {
            onComplete(activity, error, desc);
        }
    }];
}

- (void)performActivityWithCompletion:(TTActivityCompletionHandler)completion
{
    self.completion = completion;
    
    [[TTShareAdapterSetting sharedService] activityWillSharedWith:self];

    TTQQShare *qqShare = [TTQQShare sharedQQShare];
    qqShare.delegate = self;
    
    TTQQFriendContentItem *qqItem = self.contentItem;
    switch (self.contentItem.shareType) {
        case TTShareText:{
            [qqShare sendText:qqItem.desc withCustomCallbackUserInfo:qqItem.callbackUserInfo];
        }
            break;
        case TTShareImage: {
            [qqShare sendImage:qqItem.image withTitle:qqItem.title description:qqItem.desc customCallbackUserInfo:qqItem.callbackUserInfo];
        }
            break;
        case TTShareWebPage: {
            [qqShare sendNewsWithURL:qqItem.webPageUrl thumbnailImage:qqItem.thumbImage thumbnailImageURL:qqItem.imageUrl title:qqItem.title description:qqItem.desc customCallbackUserInfo:qqItem.callbackUserInfo];
        }
            break;
        case TTShareVideo: {
            [qqShare sendNewsWithURL:qqItem.webPageUrl thumbnailImage:qqItem.thumbImage thumbnailImageURL:qqItem.imageUrl title:qqItem.title description:qqItem.desc customCallbackUserInfo:qqItem.callbackUserInfo];
        }
            break;
        default:{
            NSAssert(0, @"暂时未支持此分享类型啊亲");
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
