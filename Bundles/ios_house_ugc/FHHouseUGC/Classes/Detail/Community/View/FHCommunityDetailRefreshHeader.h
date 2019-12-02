//
//  FHCommunityDetailRefreshHeader.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/11/12.
//

#import <UIKit/UIKit.h>
#import "MJRefreshStateHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCommunityDetailRefreshHeader : UIView

@property(nonatomic,assign) CGFloat lable2LoadingMargin;
@property(nonatomic,assign) CGFloat loadingSize;
@property(nonatomic, assign) MJRefreshState state;

@property(nonatomic, copy) void(^refreshingBlock)(void);
@property(nonatomic, copy) void(^endRefreshingCompletionBlock)(void);

- (void)beginRefreshing;
- (void)endRefreshing;

@end

NS_ASSUME_NONNULL_END
