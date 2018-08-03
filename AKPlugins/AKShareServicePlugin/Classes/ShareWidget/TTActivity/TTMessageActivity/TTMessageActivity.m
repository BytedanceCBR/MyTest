//
//  TTEditActivity.m
//  Article
//
//  Created by 延晋 张 on 2017/1/17.
//
//

#import "TTMessageActivity.h"
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTShareManager.h>

NSString * const TTActivityTypeMessage = @"com.toutiao.UIKit.activity.Message";

@implementation TTMessageActivity

+ (void)load
{
    [TTShareManager addUserDefinedActivity:[TTMessageActivity new]];
}

#pragma mark - Identifier

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeMessage;
}

- (NSString *)activityType
{
    return TTActivityTypeMessage;
}

#pragma mark - Display

- (NSString *)activityImageName
{
    if ([self.contentItem respondsToSelector:@selector(activityImageName)]) {
        return [self.contentItem activityImageName];
    } else {
        return @"message_allshare";
    }
}

- (NSString *)contentTitle
{
    return NSLocalizedString(@"短信", nil);
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
