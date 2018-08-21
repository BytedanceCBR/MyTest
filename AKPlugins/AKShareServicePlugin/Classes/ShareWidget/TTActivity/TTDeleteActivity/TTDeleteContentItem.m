//
//  TTDeleteContentItem.m
//  Article
//
//  Created by 延晋 张 on 2017/1/17.
//
//

#import "TTDeleteContentItem.h"

NSString * const TTActivityContentItemTypeDelete         =
@"com.toutiao.ActivityContentItem.Delete";

@implementation TTDeleteContentItem

- (instancetype)init
{
    if (self = [super init]) {
        _canDelete = YES;
    }
    return self;
}

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeDelete;
}

- (NSString *)activityImageName
{
    if (self.canDelete) {
        return @"delete_allshare";
    } else {
        return @"delete_allshare_disable";
    }
}

@end
