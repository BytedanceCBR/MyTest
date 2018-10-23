//
//  TTThreadTopOperateActivity.m
//  Article
//
//  Created by 王霖 on 17/2/21.
//
//

#import "TTThreadTopOperateActivity.h"
#import "TTThreadTopOperateContentItem.h"

NSString * const TTActivityTypeThreadTopOperate = @"com.toutiao.UIKit.activity.ThreadTopOperate";

@implementation TTThreadTopOperateActivity

#pragma mark - Identifier

- (NSString *)contentItemType {
    return TTActivityContentItemTypeThreadTopOperate;
}

- (NSString *)activityType {
    return TTActivityTypeThreadTopOperate;
}

#pragma mark - Action

- (void)performActivityWithCompletion:(TTActivityCompletionHandler)completion {
    if ([self.contentItem isKindOfClass:[TTThreadTopOperateContentItem class]]) {
        TTThreadTopOperateContentItem * contentItem = (TTThreadTopOperateContentItem *)self.contentItem;
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
