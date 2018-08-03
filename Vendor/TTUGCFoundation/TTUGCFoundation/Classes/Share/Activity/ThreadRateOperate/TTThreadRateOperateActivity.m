//
//  TTThreadRateOperateActivity.m
//  Article
//
//  Created by 王霖 on 17/2/22.
//
//

#import "TTThreadRateOperateActivity.h"
#import "TTThreadRateOperateContentItem.h"

NSString * const TTActivityTypeThreadRateOperate = @"com.toutiao.UIKit.activity.ThreadRateOperate";

@implementation TTThreadRateOperateActivity

#pragma mark - Identifier

- (NSString *)contentItemType {
    return TTActivityContentItemTypeThreadRateOperate;
}

- (NSString *)activityType {
    return TTActivityTypeThreadRateOperate;
}

#pragma mark - Action

- (void)performActivityWithCompletion:(TTActivityCompletionHandler)completion {
    if ([self.contentItem isKindOfClass:[TTThreadRateOperateContentItem class]]) {
        TTThreadRateOperateContentItem * contentItem = (TTThreadRateOperateContentItem *)self.contentItem;
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
