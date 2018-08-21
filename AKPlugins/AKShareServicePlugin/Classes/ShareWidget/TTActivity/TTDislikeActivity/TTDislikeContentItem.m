//
//  TTDislikeContentItem.m
//  Pods
//
//  Created by 王双华 on 2017/8/24.
//
//

#import "TTDislikeContentItem.h"

NSString * const TTActivityContentItemTypeDislike         =
@"com.toutiao.ActivityContentItem.Dislike";

@implementation TTDislikeContentItem

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeDislike;
}

@end
