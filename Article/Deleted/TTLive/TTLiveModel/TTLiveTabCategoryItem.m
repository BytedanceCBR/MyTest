//
//  TTLiveTabCategoryItem.m
//  TTLive
//
//  Created by xuzichao on 16/4/27.
//  Copyright © 2016年 Nick Yu. All rights reserved.
//

#import "TTLiveTabCategoryItem.h"

@implementation TTLiveTabCategoryItem

- (instancetype)init
{
    self = [super init];
    self.minCursor = @0;
    self.maxCursor = @0;
    self.history = @0;
    self.badgeNum = 0;
    self.badgeStyle = TTCategoryItemBadgeStyleNumber;
    self.categoryId = @0;
    self.categoryUrl = @"";
    
    return self;
}

@end
