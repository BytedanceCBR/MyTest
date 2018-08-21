//
//  TTEditContentItem.m
//  Article
//
//  Created by 延晋 张 on 2017/1/17.
//
//

#import "TTMessageContentItem.h"

NSString * const TTActivityContentItemTypeMessage         =
@"com.toutiao.ActivityContentItem.Message";

@implementation TTMessageContentItem

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeMessage;
}

@end
