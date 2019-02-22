//
//  FHHouseDetailBaseViewModel.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import <Foundation/Foundation.h>
#import "FHHouseDetailViewController.h"
#import "ToastManager.h"
#import "FHUserTracker.h"
#import "FHHouseTypeManager.h"
#import "FHHouseDetailContactViewModel.h"
#import <TTReachability.h>
#import "FHDetailNavBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseDetailBaseViewModel : NSObject

+(instancetype)createDetailViewModelWithHouseType:(FHHouseType)houseType withController:(FHHouseDetailViewController *)viewController tableView:(UITableView *)tableView;
-(instancetype)initWithController:(FHHouseDetailViewController *)viewController tableView:(UITableView *)tableView houseType:(FHHouseType)houseType;
@property (nonatomic, assign)   FHHouseType houseType; // 房源类型
@property (nonatomic, copy)   NSString* houseId; // 房源id
@property (nonatomic, strong)   NSDictionary       *listLogPB; // 外部传入的列表页的logPB
@property (nonatomic, strong)   NSDictionary       *logPB; // 当前详情页的logPB，详情页请求后data中的log_pb
@property(nonatomic , strong) NSMutableDictionary *detailTracerDic; // 详情页基础埋点数据
@property (nonatomic, weak) FHDetailBottomBarView *bottomBar;
@property (nonatomic, weak) FHDetailNavBar *navBar;
@property (nonatomic, weak) UILabel *bottomStatusBar;
@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHHouseDetailViewController *detailController;
@property (nonatomic, strong) NSMutableArray *items;// 子类维护的数据源
@property (nonatomic, strong)   NSObject       *detailData; // 详情页数据：FHDetailOldDataModel等
@property (nonatomic, strong) FHHouseDetailContactViewModel *contactViewModel;

// 子类实现
- (void)registerCellClasses;
- (Class)cellClassForEntity:(id)model;
- (NSString *)cellIdentifierForEntity:(id)model;
- (void)startLoadData;

// 刷新数据
- (void)reloadData;


// 埋点相关
- (void)addGoDetailLog;
- (void)addStayPageLog:(NSTimeInterval)stayTime;

@end

NS_ASSUME_NONNULL_END
