//
//  TTCommodityActivity.m
//  Article
//
//  Created by lishuangyang on 2017/9/14.
//
//

#import "TTCommodityActivity.h"
#import "TTShareManager.h"

NSString * const TTActivityTypeShowCommodity = @"com.toutiao.UIKit.activity.Commodity";

@implementation TTCommodityActivity

+ (void)load
{
    [TTShareManager addUserDefinedActivity:[TTCommodityActivity new]];
}

#pragma mark - Identifier

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeCommodity;
}

- (NSString *)activityType
{
    return TTActivityTypeShowCommodity;
}

#pragma mark - Display

- (NSString *)contentTitle
{
    if ([self.contentItem respondsToSelector:@selector(contentTitle)] && [self.contentItem contentTitle]) {
        return [self.contentItem contentTitle];
    } else {
        return @"推荐商品";
    }
}

- (NSString *)activityImageName
{
    if ([self.contentItem respondsToSelector:@selector(activityImageName)] && [self.contentItem activityImageName]) {
        return [self.contentItem activityImageName];
    } else {
        return @"video_commodity_goods";
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
