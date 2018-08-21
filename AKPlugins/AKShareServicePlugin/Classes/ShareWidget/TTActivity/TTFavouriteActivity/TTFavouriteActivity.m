//
//  TTFavouriteActivity.m
//  Article
//
//  Created by 延晋 张 on 2017/1/18.
//
//

#import "TTFavouriteActivity.h"
#import "TTShareManager.h"

NSString * const TTActivityTypeFavourite = @"com.toutiao.UIKit.activity.Favourite";
@implementation TTFavouriteActivity

+ (void)load
{
    [TTShareManager addUserDefinedActivity:[TTFavouriteActivity new]];
}

#pragma mark - Identifier

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeFavourite;
}

- (NSString *)activityType
{
    return TTActivityTypeFavourite;
}

#pragma mark - Display

- (NSString *)activityImageName
{
    if ([self.contentItem respondsToSelector:@selector(activityImageName)]) {
        return [self.contentItem activityImageName];
    } else {
        return @"love_allshare";
    }
}

- (NSString *)contentTitle
{
    return NSLocalizedString(@"收藏", nil);
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

#pragma mark - TTActivityPanelActivityProtocol

- (TTActivityPanelControllerItemActionType)itemActionType {
    return TTActivityPanelControllerItemActionTypeNone;
}

@end
