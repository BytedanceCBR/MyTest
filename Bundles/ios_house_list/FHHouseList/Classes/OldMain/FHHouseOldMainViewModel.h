//
//  FHHouseOldMainViewModel.h
//  Pods
//
//  Created by 张静 on 2019/3/4.
//

#import <Foundation/Foundation.h>
#import <FHHouseBase/FHHouseFilterDelegate.h>
#import <FHHouseBase/FHHouseType.h>
#import <FHCommonUI/FHErrorView.h>
#import <TTRoute.h>
#import <FHHouseBase/FHTracerModel.h>
#import <FHHouseBase/FHBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN
@class FHHouseListRedirectTipView;
@interface FHHouseOldMainViewModel : NSObject <FHHouseFilterDelegate>

@property(nonatomic , strong) UIView *headerView;
@property(nonatomic , strong) UIScrollView *containerScrollView;
@property(nonatomic , weak) FHBaseViewController *viewController;
@property(nonatomic , weak) UIView *bottomLine;

@property(nonatomic , copy) NSString *_Nullable (^conditionNoneFilterBlock)(NSDictionary *params);//获取非过滤器显示的过滤条件
@property(nonatomic , copy) void (^closeConditionFilter)();
@property(nonatomic , copy) void (^clearSortCondition)();
@property(nonatomic , copy) NSString * (^getConditions)();
@property(nonatomic , copy) void (^showNotify)(NSString *message);
@property(nonatomic , copy) void (^setConditionsBlock)(NSDictionary *params);

@property(nonatomic , copy) NSString * (^getAllQueryString)();
@property(nonatomic , copy) NSString *_Nullable (^getSortTypeString)();

@property (nonatomic, copy) NSString *houseListOpenUrl;
@property (nonatomic , assign) FHHouseType houseType;

@property(nonatomic , copy) void (^sugSelectBlock)(TTRouteParamObj *paramObj);
@property(nonatomic , copy) void (^houseListOpenUrlUpdateBlock)(TTRouteParamObj *paramObj, BOOL isFromMap);

@property(nonatomic , assign) BOOL isEnterCategory; // 是否算enter_category
@property (nonatomic , assign) BOOL showRedirectTip;

//@property(nonatomic , weak) id<FHHouseListViewModelDelegate> viewModelDelegate;
- (UIView *)iconHeaderView;

- (NSString *)categoryName;

- (void)reloadData;

- (void)setMaskView:(FHErrorView *)maskView;

- (instancetype)initWithTableView:(UITableView *)tableView routeParam:(TTRouteParamObj *)paramObj;

- (void)loadData:(BOOL)isRefresh;

- (void)showInputSearch;

- (void)showMapSearch;

- (void)setRedirectTipView:(FHHouseListRedirectTipView *)redirectTipView;

#pragma mark - log相关
- (void)addStayCategoryLog:(NSTimeInterval)stayTime;
// findTab过来的houseSearch需要单独处理下埋点数据
- (void)updateHouseSearchDict:(NSDictionary *)houseSearchDic;
- (NSDictionary *)categoryLogDict;
- (void)addClickHouseSearchLog;

@end

NS_ASSUME_NONNULL_END
