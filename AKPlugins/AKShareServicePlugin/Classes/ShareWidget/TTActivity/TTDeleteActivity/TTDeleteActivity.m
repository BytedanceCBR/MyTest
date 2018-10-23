//
//  TTDeleteActivity.m
//  Article
//
//  Created by 延晋 张 on 2017/1/17.
//
//

#import "TTDeleteActivity.h"
#import <TTShareManager.h>

NSString * const TTActivityTypeDelete = @"com.toutiao.UIKit.activity.Delete";
@interface TTDeleteActivity ()

@end

@implementation TTDeleteActivity

+ (void)load
{
    [TTShareManager addUserDefinedActivity:[TTDeleteActivity new]];
}

#pragma mark - Identifier

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeDelete;
}

- (NSString *)activityType
{
    return TTActivityTypeDelete;
}

#pragma mark - Display

- (NSString *)activityImageName
{
    if ([self.contentItem respondsToSelector:@selector(activityImageName)]) {
        return [self.contentItem activityImageName];
    } else {
        return @"delete_allshare";
    }
}

- (NSString *)contentTitle
{
    if ([self.contentItem respondsToSelector:@selector(contentTitle)]) {
        return [self.contentItem contentTitle];
    } else {
        return @"删除";
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
