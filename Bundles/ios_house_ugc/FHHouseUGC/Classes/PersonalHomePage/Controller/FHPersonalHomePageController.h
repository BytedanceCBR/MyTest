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

@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) UIScrollView *subScrollView;
@property (nonatomic, strong) FHErrorView *tableErrorView; // 覆盖在下方的error页

- (void)showEmptyWithType:(FHEmptyMaskViewType)maskViewType;
- (void)hiddenEmptyView;
- (void)refreshHeaderData;
- (void)mainScrollToTop;

- (void)addGoDetailLog;
- (void)addStayPageLog;

@end

@interface FHPersonalHomePageScrollView : UIScrollView

@end

NS_ASSUME_NONNULL_END
