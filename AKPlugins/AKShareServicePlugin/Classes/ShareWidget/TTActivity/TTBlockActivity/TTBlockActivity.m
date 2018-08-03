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
