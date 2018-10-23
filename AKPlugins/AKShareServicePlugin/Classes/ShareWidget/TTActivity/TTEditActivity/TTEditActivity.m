//
//  TTEditActivity.m
//  Article
//
//  Created by 延晋 张 on 2017/1/17.
//
//

#import "TTEditActivity.h"
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTShareManager.h>

NSString * const TTActivityTypeEditting = @"com.toutiao.UIKit.activity.Editting";
@implementation TTEditActivity

+ (void)load
{
    [TTShareManager addUserDefinedActivity:[TTEditActivity new]];
}

#pragma mark - Identifier

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeEdit;
}

- (NSString *)activityType
{
    return TTActivityTypeEditting;
}

#pragma mark - Display

- (NSString *)activityImageName
{
    if ([self.contentItem respondsToSelector:@selector(activityImageName)]) {
        return [self.contentItem activityImageName];
    } else {
        return @"editor_allshare";
    }
}

- (NSString *)contentTitle
{
    return NSLocalizedString(@"编辑", nil);
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
