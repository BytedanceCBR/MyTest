//
//  FHHouseDetailViewController.h
//  FHHouseDetail
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseDetailViewController : FHBaseViewController

//设置状态栏
- (void)refreshContentOffset:(CGPoint)contentOffset;

//获取导航bar
- (UIView *)getNaviBar;

//获取底部bar
- (UIView *)getBottomBar;

//设置navibar title
- (void)setNavBarTitle:(NSString *)navTitle;

//移除导航条底部line
- (void)removeBottomLine;

// 埋点数据处理:1、paramObj.allParams中的"tracer"字段，2、allParams中的origin_from、report_params等字段
- (void)processTracerData:(NSDictionary *)allParams;

@end

NS_ASSUME_NONNULL_END
