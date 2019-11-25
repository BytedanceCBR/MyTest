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
#import <Heimdallr/HMDTTMonitor.h>
#import "FHDetailHalfPopLayer.h"
#import "FHDetailQuestionButton.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FHDetailCoreInfoErrorTypeTitle = 1 << 0,
    FHDetailCoreInfoErrorTypeImage = 1 << 1,
    FHDetailCoreInfoErrorTypeCoreInfo = 1 << 2,
} FHDetailCoreInfoErrorType;

extern NSString *const DETAIL_SHOW_POP_LAYER_NOTIFICATION ; //详情页点击显示半屏弹窗


@class FHDetailQuestionButton;

@interface FHHouseDetailBaseViewModel : NSObject

+(instancetype)createDetailViewModelWithHouseType:(FHHouseType)houseType withController:(FHHouseDetailViewController *)viewController tableView:(UITableView *)tableView;
-(instancetype)initWithController:(FHHouseDetailViewController *)viewController tableView:(UITableView *)tableView houseType:(FHHouseType)houseType;
@property (nonatomic, assign)   FHHouseType houseType; // 房源类型
@property (nonatomic, copy)   NSString* houseId; // 房源id
@property (nonatomic, copy)   NSString *ridcode; // 经纪人id，用来锁定经纪人展位
@property (nonatomic, copy)   NSString *realtorId; // 经纪人id，用来锁定经纪人展位
@property (nonatomic, copy)     NSString       *source; // 特殊标记，从哪进入的小区详情，比如地图租房列表“rent_detail”，此时小区房源展示租房列表
@property (nonatomic, strong)   NSDictionary       *listLogPB; // 外部传入的列表页的logPB，详情页大部分埋点都直接用当前埋点数据
@property(nonatomic , strong) NSMutableDictionary *detailTracerDic; // 详情页基础埋点数据
@property (nonatomic, weak) FHDetailBottomBarView *bottomBar;
@property (nonatomic, weak) FHDetailNavBar *navBar;
@property (nonatomic, weak) UILabel *bottomStatusBar;
@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHHouseDetailViewController *detailController;
@property (nonatomic, strong) NSMutableArray *items;// 子类维护的数据源
@property (nonatomic, strong)   NSObject       *detailData; // 详情页数据：FHDetailOldDataModel等
@property (nonatomic, strong) FHHouseDetailContactViewModel *contactViewModel;
@property(nonatomic , weak) FHDetailQuestionButton *questionBtn;

// 子类实现
- (void)registerCellClasses;
- (Class)cellClassForEntity:(id)model;
- (NSString *)cellIdentifierForEntity:(id)model;
- (void)startLoadData;

// 回调方法
- (void)vc_viewDidAppear:(BOOL)animated;
- (void)vc_viewDidDisappear:(BOOL)animated;

// 刷新数据
- (void)reloadData;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView;

// 二级页所需数据
- (NSDictionary *)subPageParams;

//秒开相关
-(void)handleInstantData:(id)data;
-(BOOL)currentIsInstantData;

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

//半屏列表页
- (void)addPopLayerNotification;
- (void)removePopLayerNotification;
- (void)onShowPoplayerNotification:(NSNotification *)notification;
- (FHDetailHalfPopLayer *)popLayer;

- (void)enableController:(BOOL)enabled;
- (void)popLayerReport:(id)model;
- (void)poplayerFeedBack:(id)model type:(NSInteger)type completion:(void (^)(BOOL success))completion;
@end

NS_ASSUME_NONNULL_END
