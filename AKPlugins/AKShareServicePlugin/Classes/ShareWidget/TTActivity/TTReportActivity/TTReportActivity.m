//
//  TTReportActivity.m
//  Article
//
//  Created by 延晋 张 on 2017/1/17.
//
//

#import "TTReportActivity.h"
#import <TTShareManager.h>

NSString * const TTActivityTypeReportt = @"com.toutiao.UIKit.activity.Report";

@interface TTReportActivity ()

@end

@implementation TTReportActivity

+ (void)load
{
    [TTShareManager addUserDefinedActivity:[TTReportActivity new]];
}

#pragma mark - Identifier

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeReport;
}

- (NSString *)activityType
{
    return TTActivityTypeReportt;
}

#pragma mark - Display

- (NSString *)activityImageName
{
    if ([self.contentItem respondsToSelector:@selector(activityImageName)]) {
        return [self.contentItem activityImageName];
    } else {
        return @"report_allshare";
    }
}

- (NSString *)contentTitle
{
    if ([self.contentItem respondsToSelector:@selector(contentTitle)]) {
        return [self.contentItem contentTitle];
    } else {
        return @"举报";
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
