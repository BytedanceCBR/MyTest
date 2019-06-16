//
//  FHHomeItemViewController.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/6/12.
//

#import <UIKit/UIKit.h>
#import <FHHouseType.h>
#import <FHTracerModel.h>
#import "FHHomeListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger , FHHomePullTriggerType){
    FHHomePullTriggerTypePullUp = 1, //上拉刷新
    FHHomePullTriggerTypePullDown = 2  //下拉刷新
};


static const NSUInteger kFHHomeHouseTypeBannerViewSection = 0;
static const NSUInteger kFHHomeHouseTypeHouseSection = 1;

@interface FHHomeItemViewController : UIViewController

@property (nonatomic,assign)FHHouseType houseType;
@property (nonatomic, assign) BOOL showNoDataErrorView;
@property (nonatomic, assign) BOOL showRequestErrorView;
@property (nonatomic, assign) BOOL showPlaceHolder;
@property (nonatomic , strong) FHTracerModel *tracerModel;
@property (nonatomic, assign) TTReloadType reloadType; //当前enterType，用于enter_category
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *traceNeedUploadCache;


@property (nonatomic, copy) void (^requestCallBack)(FHHomePullTriggerType refreshType,FHHouseType houseType,BOOL isSuccess,JSONModel *dataModel);
@property (nonatomic, copy) void (^requestNetworkUnAvalableRetryCallBack)(void);

- (void)requestDataForRefresh:(FHHomePullTriggerType)pullType andIsFirst:(BOOL)isFirst;

- (void)showPlaceHolderCells;

- (void)currentViewIsShowing;

- (void)currentViewIsDisappeared;

@end

NS_ASSUME_NONNULL_END
