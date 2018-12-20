//
//  FHRentMainPageDataSource.h
//  Demo
//
//  Created by 谷春晖 on 2018/11/22.
//  Copyright © 2018年 com.haoduofangs. All rights reserved.
//

#import "FHBTableViewDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHRentMainPageDataSource : FHBTableViewDataSource

@property(nonatomic , assign) CGFloat topViewHeight; //顶部租房icons view的高度
@property(nonatomic , assign) CGFloat headerViewHeight;//筛选框的高度
@property(nonatomic , assign) CGFloat topBounceThreshhold; //顶部回弹时的高度
@property(nonatomic , copy)  UIView * (^headerViewBlock)(void);


@end

NS_ASSUME_NONNULL_END
