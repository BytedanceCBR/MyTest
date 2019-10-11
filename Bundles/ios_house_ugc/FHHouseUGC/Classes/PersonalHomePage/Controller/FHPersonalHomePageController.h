//
//  FHPersonalHomePageController.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/10/11.
//

#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

// 个人主页
@interface FHPersonalHomePageController : FHBaseViewController

- (void)showEmptyWithType:(FHEmptyMaskViewType)maskViewType;
- (void)hiddenEmptyView;
- (void)refreshHeaderData;
//- (void)endRefreshHeader;
- (void)mainScrollToTop;

@end

@interface FHPersonalHomePageScrollView : UIScrollView

@end

NS_ASSUME_NONNULL_END
