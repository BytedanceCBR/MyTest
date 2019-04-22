//
//  TTBuryActivity.m
//  Article
//
//  Created by lishuangyang on 2017/8/29.
//
//

#import "TTBuryActivity.h"
#import "TTShareManager.h"

NSString * const TTActivityTypePostToBury = @"com.toutiao.UIKit.activity.Bury";

@implementation TTBuryActivity

+ (void)load
{
    [TTShareManager addUserDefinedActivity:[TTBuryActivity new]];
}

#pragma mark - Identifier
- (NSString *)contentItemType
{
    return TTActivityContentItemTypeBury;
}

- (NSString *)activityType
{
    return TTActivityTypePostToBury;
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
    return NSLocalizedString(@"踩", nil);
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
    if (!self.contentItem.banDig) {
        if (self.contentItem.selected) {
            self.contentItem.count -= 1;
            self.contentItem.selected = NO;
        }else{
            self.contentItem.count += 1;
            self.contentItem.selected = YES;
        }
        
        if (completion) {
            completion(self, nil, nil);
        }
    }
}

#pragma mark - TTActivityPanelActivityProtocol

- (TTActivityPanelControllerItemActionType)itemActionType {
    return TTActivityPanelControllerItemActionTypeNone;
}

@end
