//
//  TTReportUserActivity.m
//  Article
//
//  Created by 王霖 on 17/2/22.
//
//

#import "TTReportUserActivity.h"
#import "TTReportUserContentItem.h"

NSString * const TTActivityTypeReportUser = @"com.toutiao.UIKit.activity.ReportUser";

@implementation TTReportUserActivity

#pragma mark - Identifier

- (NSString *)contentItemType {
    return TTActivityContentItemTypeReportUser;
}

- (NSString *)activityType {
    return TTActivityTypeReportUser;
}

#pragma mark - Action

- (void)performActivityWithCompletion:(TTActivityCompletionHandler)completion {
    if ([self.contentItem isKindOfClass:[TTReportUserContentItem class]]) {
        TTReportUserContentItem * contentItem = (TTReportUserContentItem *)self.contentItem;
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
