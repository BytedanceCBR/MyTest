//
//  FHHouseDetailViewController.h
//  FHHouseDetail
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
extern NSString *const INSTANT_DATA_KEY;
@class FHHouseDetailBaseViewModel;

@interface FHHouseDetailViewController : FHBaseViewController

//是否显示
@property (nonatomic, assign)   BOOL     isViewDidDisapper;
//列表页带入的数据
@property (nonatomic, strong) id instantData;
//是否显示拨打电话
@property (nonatomic, assign) BOOL isPhoneCallShow;
//正在拨打电话的经纪人id
@property (nonatomic, copy, nullable) NSString *phoneCallRealtorId;
//正在拨打电话对应请求虚拟电话的请求ID
@property (nonatomic, copy, nullable) NSString *phoneCallRequestId;
//ViewModel
@property (nonatomic, strong)   FHHouseDetailBaseViewModel       *viewModel;
//bizTrace
@property (nonatomic, copy) NSString *bizTrace;

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

-(void)updateLayout:(BOOL)isInstant;

- (void)hiddenPlaceHolder;

@end

NS_ASSUME_NONNULL_END
