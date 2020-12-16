//
//  FHNeighborhoodDetailViewModel.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/9.
//

#import <Foundation/Foundation.h>
#import "FHHouseDetailBaseViewModel.h"
#import "ToastManager.h"
#import "FHUserTracker.h"
#import "FHHouseTypeManager.h"
#import "FHHouseDetailContactViewModel.h"
#import "TTReachability.h"
#import "FHDetailNavBar.h"
#import <Heimdallr/HMDTTMonitor.h>
#import "FHDetailHalfPopLayer.h"
#import "FHDetailBottomBar.h"
#import "FHDetailNeighborhoodModel.h"
NS_ASSUME_NONNULL_BEGIN
@class FHNeighborhoodDetailViewController;
@interface FHNeighborhoodDetailViewModel : NSObject

@property (nonatomic, copy)   NSString* houseId; // 房源id
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSArray *sectionModels;

@property (nonatomic, copy)   NSString *ridcode; // 经纪人id，用来锁定经纪人展位
@property (nonatomic, copy)   NSString *realtorId; // 经纪人id，用来锁定经纪人展位
@property (nonatomic, copy)     NSString       *source; // 特殊标记，从哪进入的小区详情，比如地图租房列表“rent_detail”，此时小区房源展示租房列表
@property (nonatomic, strong)   NSDictionary       *listLogPB; // 外部传入的列表页的logPB，详情页大部分埋点都直接用当前埋点数据
@property(nonatomic , copy) NSDictionary *detailTracerDic; // 详情页基础埋点数据
@property (nonatomic, weak) FHDetailBottomBar *bottomBar;
@property (nonatomic, weak) FHDetailNavBar *navBar;
@property (nonatomic, weak) UILabel *bottomStatusBar;
@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHNeighborhoodDetailViewController *detailController;
@property (nonatomic, strong)   FHDetailNeighborhoodModel       *detailData; // 详情页数据：FHDetailOldDataModel等
@property (nonatomic, copy) NSDictionary *originDetailDict;
@property (nonatomic, strong) FHHouseDetailContactViewModel *contactViewModel;
@property (nonatomic, strong) NSDictionary *extraInfo;
@property (nonatomic, copy)   NSString* houseInfoBizTrace; // 房源详情下发通用bizTrace
@property (nonatomic, strong)   NSString* houseInfoOriginBizTrace; // 房源详情原始bizTrace
@property (nonatomic, copy) NSString *trackingId;


- (void)startLoadData;

// 二级页所需数据
- (NSDictionary *)subPageParams;

// 埋点相关
- (NSString *)pageTypeString;
- (void)addGoDetailLog;
- (void)addStayPageLog:(NSTimeInterval)stayTime;
- (void)addClickOptionLog:(NSString *)position;

// excetionLog
- (void)addDetailCoreInfoExcetionLog;
- (BOOL)isMissTitle;
- (BOOL)isMissImage;
- (BOOL)isMissCoreInfo;
- (void)addDetailRequestFailedLog:(NSInteger)status message:(NSString *)message;

/**
 1.0.4 版本统计二手房详情页加载总时长
 写入到base类中，考虑到后期会加入其它详情页的统计时长
 */
@property (nonatomic) double initTimeInterval;
@property (nonatomic) double firstReloadInterval;
- (void)addPageLoadLog;
@end

NS_ASSUME_NONNULL_END
