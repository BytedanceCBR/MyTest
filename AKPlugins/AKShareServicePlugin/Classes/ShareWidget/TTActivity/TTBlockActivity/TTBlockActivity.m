//
//  TTBlockActivity.m
//  Article
//
//  Created by 王霖 on 17/2/22.
//
//

#import "TTBlockActivity.h"
#import "TTBlockContentItem.h"

NSString * const TTActivityTypeBlock = @"com.toutiao.UIKit.activity.Block";

@implementation TTBlockActivity

#pragma mark - Identifier

- (NSString *)contentItemType {
    return TTActivityContentItemTypeBlock;
}

- (NSString *)activityType {
    return TTActivityTypeBlock;
}

#pragma mark - Action

- (void)performActivityWithCompletion:(TTActivityCompletionHandler)completion {
    if ([self.contentItem isKindOfClass:[TTBlockContentItem class]]) {
        TTBlockContentItem * contentItem = (TTBlockContentItem *)self.contentItem;
        if (contentItem.customAction) {
            contentItem.customAction();
        }
    }
    if (completion) {
        completion(self, nil, nil);
    }
}

#pragma mark - Display

#pragma mark - Display

- (NSString *)activityImageName
{
    if ([self.contentItem respondsToSelector:@selector(activityImageName)]) {
        if ([self.contentItem activityImageName].length > 0) {
            return [self.contentItem activityImageName];
        }else {
            return @"shield_allshare";
        }
    } else {
        return @"shield_allshare";
    }
}

- (NSString *)contentTitle
{
    if ([self.contentItem respondsToSelector:@selector(contentTitle)]) {
        if ([self.contentItem contentTitle].length > 0) {
            return [self.contentItem contentTitle];
        }else {
            return @"拉黑";
        }
    } else {
        return @"拉黑";
    }
}

- (NSString *)shareLabel {
    return nil;
}

@end
