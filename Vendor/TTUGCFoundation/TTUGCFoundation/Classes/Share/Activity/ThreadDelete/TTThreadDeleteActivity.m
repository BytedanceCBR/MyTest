//
//  TTThreadDeleteActivity.m
//  Article
//
//  Created by 王霖 on 17/2/22.
//
//

#import "TTThreadDeleteActivity.h"
#import "TTThreadDeleteContentItem.h"

NSString * const TTActivityTypeThreadDelete = @"com.toutiao.UIKit.activity.ThreadDelete";

@implementation TTThreadDeleteActivity

#pragma mark - Identifier

- (NSString *)contentItemType {
    return TTActivityContentItemTypeThreadDelete;
}

- (NSString *)activityType {
    return TTActivityTypeThreadDelete;
}

#pragma mark - Action

- (void)performActivityWithCompletion:(TTActivityCompletionHandler)completion {
    if ([self.contentItem isKindOfClass:[TTThreadDeleteContentItem class]]) {
        TTThreadDeleteContentItem * contentItem = (TTThreadDeleteContentItem *)self.contentItem;
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
