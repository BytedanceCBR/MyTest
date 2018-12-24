//
//  FHBaseHouseListViewModel.h
//  FHHouseList
//
//  Created by 春晖 on 2018/12/7.
//

#import <Foundation/Foundation.h>
#import <FHHouseFilterDelegate.h>
#import "FHHouseType.h"
#import "FHErrorView.h"
#import <TTRoute.h>
#import <FHHouseSuggestionDelegate.h>

#define kFHHouseListCellId @"kFHHouseListCellId"
#define kFHHouseListPlaceholderCellId @"kFHHouseListPlaceholderCellId"

NS_ASSUME_NONNULL_BEGIN
@protocol FHHouseListViewModelDelegate;

@class FHHouseListViewController;
/*
 * 房子列表页基础 viewmodel
 * 对于二手房、租房等基础逻辑封装
 * 实现埋点接口
 */
@interface FHBaseHouseListViewModel : NSObject <FHHouseFilterDelegate,FHHouseSuggestionDelegate>

//@property(nonatomic , copy) void (^resetConditionBlock)(NSDictionary *condition);
@property(nonatomic , copy) NSString *_Nullable (^conditionNoneFilterBlock)(NSDictionary *params);//获取非过滤器显示的过滤条件
@property(nonatomic , copy) void (^closeConditionFilter)();
@property(nonatomic , copy) void (^clearSortCondition)();
@property(nonatomic , copy) NSString * (^getConditions)();
@property(nonatomic , copy) void (^showNotify)(NSString *message);
@property(nonatomic , copy) void (^setConditionsBlock)(NSDictionary *params);

@property(nonatomic , weak) id<FHHouseListViewModelDelegate> viewModelDelegate;

-(NSString *)categoryName;

-(void)reloadData;

-(void)setMaskView:(FHErrorView *)maskView;

-(instancetype)initWithTableView:(UITableView *)tableView viewControler:(FHHouseListViewController *)vc routeParam:(TTRouteParamObj *)paramObj;

-(void)loadData:(BOOL)isRefresh;

-(void)viewWillAppear:(BOOL)animated;

-(void)viewWillDisappear:(BOOL)animated;

-(void)showInputSearch;

-(void)showMapSearch;


@end


@protocol FHHouseListViewModelDelegate <NSObject>

@required
-(void)showNotify:(NSString *)message inViewModel:(FHBaseHouseListViewModel *)viewModel;

-(void)showErrorMaskView;//TODO: add type
@end

NS_ASSUME_NONNULL_END


