//
//  TTDiggContentItem.m
//  Article
//
//  Created by lishuangyang on 2017/8/24.
//
//

#import "TTDiggContentItem.h"

NSString * const TTActivityContentItemTypeDigg       =       @"com.toutiao.ActivityContentItem.Digg";

@implementation TTDiggContentItem

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeDigg;
}

- (NSString *)activityImageName
{
    NSString * imageName = @"digup_allshare";
    if (self.selected) {
        imageName = [NSString stringWithFormat:@"%@_selected", imageName];
    }
    return imageName;
}

- (NSString *)contentTitle
{
    return NSLocalizedString(@"顶", nil);
}

@end
