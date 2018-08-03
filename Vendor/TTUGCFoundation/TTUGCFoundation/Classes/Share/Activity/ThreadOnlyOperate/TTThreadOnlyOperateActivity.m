//
//  TTThreadOnlyOperateActivity.m
//  Article
//
//  Created by 王霖 on 17/2/22.
//
//

#import "TTThreadOnlyOperateActivity.h"
#import "TTThreadOnlyOperateContentItem.h"

NSString * const TTActivityTypeThreadOnlyOperate = @"com.toutiao.UIKit.activity.ThreadOnlyOperate";

@implementation TTThreadOnlyOperateActivity

#pragma mark - Identifier

- (NSString *)contentItemType {
    return TTActivityContentItemTypeThreadOnlyOperate;
}

- (NSString *)activityType {
    return TTActivityTypeThreadOnlyOperate;
}

#pragma mark - Action

- (void)performActivityWithCompletion:(TTActivityCompletionHandler)completion {
    if ([self.contentItem isKindOfClass:[TTThreadOnlyOperateContentItem class]]) {
        TTThreadOnlyOperateContentItem * contentItem = (TTThreadOnlyOperateContentItem *)self.contentItem;
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
