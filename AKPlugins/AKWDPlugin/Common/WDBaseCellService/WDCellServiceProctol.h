//
//  WDCellServiceProctol.h
//  Wenda
//
//  Created by xuzichao on 2017/6/9.
//  Copyright © 2017年 xuzichao. All rights reserved.
//


@protocol WDCellServiceProctol <NSObject>

+ (instancetype)sharedInstance;
- (Class)cellClassFromDataClass:(Class)dataClass;

@optional
- (void)registerCell:(Class)cellClass forCellData:(Class)dataClass;
@end
