//
//  TTDislikeActivity.m
//  Pods
//
//  Created by 王双华 on 2017/8/24.
//
//

#import "TTDislikeActivity.h"
#import <TTShareManager.h>

NSString * const TTActivityTypeDislike = @"com.toutiao.UIKit.activity.Dislike";

@interface TTDislikeActivity ()

@end

@implementation TTDislikeActivity

+ (void)load
{
    [TTShareManager addUserDefinedActivity:[TTDislikeActivity new]];
}

#pragma mark - Identifier

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeDislike;
}

- (NSString *)activityType
{
    return TTActivityTypeDislike;
}

#pragma mark - Display

- (NSString *)activityImageName
{
    if ([self.contentItem respondsToSelector:@selector(activityImageName)]) {
        return [self.contentItem activityImageName];
    } else {
        return @"unlike_allshare";
    }
}

- (NSString *)contentTitle
{
    if ([self.contentItem respondsToSelector:@selector(contentTitle)]) {
        return [self.contentItem contentTitle];
    } else {
        return @"不感兴趣";
    }
}

- (NSString *)shareLabel
{
    return nil;
}

#pragma mark - Action

- (void)performActivityWithCompletion:(TTActivityCompletionHandler)completion
{
    if (self.contentItem.customAction) {
        self.contentItem.customAction();
    }
    if (completion) {
        completion(self, nil, nil);
    }
}

@end
