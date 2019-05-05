//
//  TTCopyActivity.m
//  NeteaseLottery
//
//  Created by 延晋 张 on 16/6/7.
//
//

#import "TTCopyActivity.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "TTShareAdapterSetting.h"

NSString * const TTActivityTypePostToCopy              = @"com.toutiao.UIKit.activity.PostToCopy";

@interface TTCopyActivity () <MFMailComposeViewControllerDelegate>

@property (nonatomic,copy) TTActivityCompletionHandler completion;

@end

@implementation TTCopyActivity

#pragma mark - Identifier

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeCopy;
}

- (NSString *)activityType
{
    return TTActivityTypePostToCopy;
}

#pragma mark - Display

- (NSString *)contentTitle
{
    if ([self.contentItem respondsToSelector:@selector(contentTitle)] && [self.contentItem contentTitle]) {
        return [self.contentItem contentTitle];
    } else {
        return @"复制链接";
    }
}

- (NSString *)activityImageName
{
    if ([self.contentItem respondsToSelector:@selector(activityImageName)] && [self.contentItem activityImageName]) {
        return [self.contentItem activityImageName];
    } else {
        return @"copy_allshare";
    }
}

- (NSString *)shareLabel
{
    return @"share_copy_link";
}

#pragma mark - Action

- (void)shareWithContentItem:(id <TTActivityContentItemProtocol>)contentItem presentingViewController:(UIViewController *)presentingViewController onComplete:(TTActivityCompletionHandler)onComplete
{
    self.contentItem = contentItem;
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
    
    NSString *text = [self contentItem].desc;
    NSString *desc = nil;
    NSError *error = nil;
    if ([text isKindOfClass:[NSString class]]) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:text];
        desc = @"复制成功";
    } else {
        error = [NSError errorWithDomain:TTActivityTypePostToCopy code:-100 userInfo:@{NSLocalizedDescriptionKey : @"复制失败"}];
        desc = @"复制失败";
    }
    
    if (self.completion) {
        completion(self, error, desc);
    }
    
    [[TTShareAdapterSetting sharedService] activityHasSharedWith:self error:error desc:desc];
}


@end
