//
//  TTDirectForwardWeitoutiaoActivity.m
//  TTShareService
//
//  Created by jinqiushi on 2018/1/17.
//

#import "TTDirectForwardWeitoutiaoActivity.h"
#import "TTShareManager.h"

NSString * const TTActivityTypeDirectForwardWeitoutiao = @"com.toutiao.UIKit.activity.DirectForwardWeitoutiao";

@implementation TTDirectForwardWeitoutiaoActivity

+ (void)load {
    [TTShareManager addUserDefinedActivity:[TTDirectForwardWeitoutiaoActivity new]];
}

- (TTDirectForwardWeitoutiaoContentItem *)contentItem
{
    if (!_contentItem) {
        _contentItem = [[TTDirectForwardWeitoutiaoContentItem alloc] init];
    }
    return _contentItem;
}

- (NSString *)contentItemType {
    return TTActivityContentItemTypeDirectForwardWeitoutiao;
}
- (NSString *)activityType {
    return TTActivityTypeDirectForwardWeitoutiao;
}


- (NSString *)activityImageName {
    return nil;
}


- (NSString *)contentTitle {
    return nil;
}


- (void)performActivityWithCompletion:(TTActivityCompletionHandler)completion {
    if (self.contentItem.customAction) {
        self.contentItem.customAction();
    }
    if (completion) {
        completion(self, nil, nil);
    }
}


- (NSString *)shareLabel {
    return nil;
}

@end
