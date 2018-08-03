//
//  TTThreadStarOperateActivity.m
//  Article
//
//  Created by 王霖 on 17/2/21.
//
//

#import "TTThreadStarOperateActivity.h"
#import "TTThreadStarOperateContentItem.h"

NSString * const TTActivityTypeThreadStarOperate = @"com.toutiao.UIKit.activity.ThreadStarOperate";

@implementation TTThreadStarOperateActivity

#pragma mark - Identifier

- (NSString *)contentItemType {
    return TTActivityContentItemTypeThreadStarOperate;
}

- (NSString *)activityType {
    return TTActivityTypeThreadStarOperate;
}

#pragma mark - Action

- (void)performActivityWithCompletion:(TTActivityCompletionHandler)completion {
    if ([self.contentItem isKindOfClass:[TTThreadStarOperateContentItem class]]) {
        TTThreadStarOperateContentItem * contentItem = (TTThreadStarOperateContentItem *)self.contentItem;
        if (contentItem.customAction) {
            contentItem.customAction();
        }
    }
    if (completion) {
        completion(self, nil, nil);
    }
}

#pragma mark - Display

- (NSString *)activityImageName {
    return [self.contentItem activityImageName];
}

- (NSString *)contentTitle {
    return [self.contentItem contentTitle];
}

- (NSString *)shareLabel {
    return nil;
}

@end
