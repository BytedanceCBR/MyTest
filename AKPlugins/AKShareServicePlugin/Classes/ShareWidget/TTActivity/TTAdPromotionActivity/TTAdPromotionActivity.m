//
//  TTAdPromotionActivity.m
//  Article
//
//  Created by 王霖 on 2017/4/27.
//
//

#import "TTAdPromotionActivity.h"
#import "TTShareManager.h"

NSString * const TTActivityTypeAdPromotion = @"com.toutiao.UIKit.activity.AdPromotion";

@implementation TTAdPromotionActivity

+ (void)load {
    [TTShareManager addUserDefinedActivity:[TTAdPromotionActivity new]];
}

#pragma mark - Identifier

- (NSString *)contentItemType {
    return TTActivityContentItemTypeAdPromotion;
}

- (NSString *)activityType {
    return TTActivityTypeAdPromotion;
}

#pragma mark - Display

- (NSString *)activityImageName {
    return nil;
}

- (NSString *)contentTitle {
    return [self.contentItem contentTitle];
}

- (NSString *)shareLabel {
    return nil;
}

#pragma mark - Action

- (void)performActivityWithCompletion:(TTActivityCompletionHandler)completion {
    if (self.contentItem.customAction) {
        self.contentItem.customAction();
    }
    if (completion) {
        completion(self, nil, nil);
    }
}


#pragma mark - TTActivityPanelActivityProtocol

- (TTActivityPanelControllerItemLoadImageType)itemLoadImageType {
    return TTActivityPanelControllerItemLoadImageTypeURL;
}

- (TTActivityPanelControllerItemUIType)itemUIType {
    return TTActivityPanelControllerItemUITypeCornerRadius;
}

- (NSString *)itemImageURL {
    return self.contentItem.iconURL;
}

@end
