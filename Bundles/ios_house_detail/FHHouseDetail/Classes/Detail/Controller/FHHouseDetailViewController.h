//
//  FHHouseDetailViewController.h
//  FHHouseDetail
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHBaseViewController.h"

extern NSString *const INSTANT_DATA_KEY;

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseDetailViewController : FHBaseViewController

//是否显示
@property (nonatomic, assign)   BOOL     isViewDidDisapper;
//列表页带入的数据
@property (nonatomic, strong) id instantData;

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

//更新
- (void)updateLoadFinish;

@end

NS_ASSUME_NONNULL_END
