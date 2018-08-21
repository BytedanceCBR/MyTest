//
//  TTEditContentItem.m
//  Article
//
//  Created by 延晋 张 on 2017/1/17.
//
//

#import "TTEditContentItem.h"

NSString * const TTActivityContentItemTypeEdit         =
@"com.toutiao.ActivityContentItem.Edit";

@implementation TTEditContentItem

- (instancetype)init
{
    if (self = [super init]) {
        _canEdit = YES;
    }
    return self;
}

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeEdit;
}

- (NSString *)activityImageName
{
    if (self.canEdit) {
        return @"editor_allshare";
    } else {
        return @"editor_allshare_disable";
    }
}

@end
