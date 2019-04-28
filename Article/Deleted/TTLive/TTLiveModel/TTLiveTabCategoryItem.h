//
//  TTLiveTabCategoryItem.h
//  TTLive
//
//  Created by xuzichao on 16/4/27.
//  Copyright © 2016年 Nick Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTHorizontalCategoryBar.h"

@class TTLiveChatTableViewController;

@interface TTLiveTabCategoryItem : TTCategoryItem

@property (nonatomic, strong) NSNumber *categoryId;
@property (nonatomic, copy)   NSString *categoryUrl;
@property (nonatomic, strong) NSNumber *history;
@property (nonatomic, strong) NSNumber *maxCursor;
@property (nonatomic, strong) NSNumber *minCursor;
//@property (nonatomic, strong)  TTLiveChatTableViewController *chatVC;

@end
