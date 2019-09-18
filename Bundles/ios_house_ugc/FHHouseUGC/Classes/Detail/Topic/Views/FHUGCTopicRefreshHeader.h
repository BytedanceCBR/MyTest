//
//  FHUGCTopicRefreshHeader.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/8/25.
//

#import <UIKit/UIKit.h>
#import "MJRefreshStateHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCTopicRefreshHeader : UIView

/** 刷新状态 一般交给子类内部实现 */
@property (assign, nonatomic) MJRefreshState state;
@property (nonatomic, weak)     UIScrollView       *scrollView;
@property (nonatomic, assign)   UIEdgeInsets       beginEdgeInsets;
@property (nonatomic, copy)     MJRefreshComponentRefreshingBlock       refreshingBlk;
// 滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
// 停止刷新 进入idle状态
- (void)endRefreshing;

@end

NS_ASSUME_NONNULL_END
