//
//  FHTopicDetailViewController.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/2.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

// 话题详情页
@interface FHTopicDetailViewController : FHBaseViewController

- (void)showEmptyWithType:(FHEmptyMaskViewType)maskViewType;
- (void)hiddenEmptyView;
- (void)refreshHeaderData;
- (void)endRefreshHeader;
- (void)mainScrollToTop;

@end

@interface FHTopicDetailScrollView : UIScrollView

@end

NS_ASSUME_NONNULL_END
