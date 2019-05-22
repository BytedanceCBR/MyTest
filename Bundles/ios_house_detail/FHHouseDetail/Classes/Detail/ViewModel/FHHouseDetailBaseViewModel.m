//
//  FHHouseDetailBaseViewModel.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import "FHHouseDetailBaseViewModel.h"
#import "FHHouseNeighborhoodDetailViewModel.h"
#import "FHHouseOldDetailViewModel.h"
#import "FHHouseNewDetailViewModel.h"
#import "FHHouseRentDetailViewModel.h"
#import "FHDetailBaseCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <TTAccountLogin/TTAccountLoginManager.h>
#import "FHDetailOldModel.h"
#import "FHDetailRentModel.h"
#import <FHHouseBase/FHEnvContext.h>
#import <FHHouseBase/FHURLSettings.h>

@interface FHHouseDetailBaseViewModel ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)   NSMutableDictionary       *cellHeightCaches;
@property (nonatomic, strong)   NSMutableDictionary       *elementShowCaches;
@property (nonatomic, strong)   NSHashTable               *weakedCellTable;
@property (nonatomic, strong)   NSHashTable               *weakedVCLifeCycleCellTable;
@property (nonatomic, assign)   CGPoint       lastPointOffset;

@end

@implementation FHHouseDetailBaseViewModel

+(instancetype)createDetailViewModelWithHouseType:(FHHouseType)houseType withController:(FHHouseDetailViewController *)viewController tableView:(UITableView *)tableView {
    FHHouseDetailBaseViewModel *viewModel = NULL;
    switch (houseType) {
        case FHHouseTypeSecondHandHouse:
            viewModel = [[FHHouseOldDetailViewModel alloc] initWithController:viewController tableView:tableView houseType:houseType];
            break;
        case FHHouseTypeNewHouse:
            viewModel = [[FHHouseNewDetailViewModel alloc] initWithController:viewController tableView:tableView houseType:houseType];
            break;
        case FHHouseTypeRentHouse:
            viewModel = [[FHHouseRentDetailViewModel alloc] initWithController:viewController tableView:tableView houseType:houseType];
            break;
        case FHHouseTypeNeighborhood:
            viewModel = [[FHHouseNeighborhoodDetailViewModel alloc] initWithController:viewController tableView:tableView houseType:houseType];
            break;
        default:
            break;
    }
    return viewModel;
}

-(instancetype)initWithController:(FHHouseDetailViewController *)viewController tableView:(UITableView *)tableView houseType:(FHHouseType)houseType {
    self = [super init];
    if (self) {
        _detailTracerDic = [NSMutableDictionary new];
        _items = [NSMutableArray new];
        _cellHeightCaches = [NSMutableDictionary new];
        _elementShowCaches = [NSMutableDictionary new];
        _lastPointOffset = CGPointZero;
        _weakedCellTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        _weakedVCLifeCycleCellTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        self.houseType = houseType;
        self.detailController = viewController;
        self.tableView = tableView;
        [self configTableView];
    }
    return self;
}

-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self registerCellClasses];
}

- (void)reloadData {
    
    CGRect frame = self.tableView.frame;
    [self.tableView reloadData];
    self.tableView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width,10000);//设置大frame 强制计算cell高度
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.tableView.frame = frame;
    });
}

// 回调方法
- (void)vc_viewDidAppear:(BOOL)animated {
    if (self.weakedVCLifeCycleCellTable.count > 0) {
        NSArray *arr = self.weakedVCLifeCycleCellTable.allObjects;
        [arr enumerateObjectsUsingBlock:^(FHDetailBaseCell *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[FHDetailBaseCell class]] && self.detailController) {
                if ([obj conformsToProtocol:@protocol(FHDetailVCViewLifeCycleProtocol)]) {
                    [((id<FHDetailVCViewLifeCycleProtocol>)obj) vc_viewDidAppear:animated];
                }
            }
        }];
    }
    [self addPopLayerNotification];
}

- (void)vc_viewDidDisappear:(BOOL)animated {
    if (self.weakedVCLifeCycleCellTable.count > 0) {
        NSArray *arr = self.weakedVCLifeCycleCellTable.allObjects;
        [arr enumerateObjectsUsingBlock:^(FHDetailBaseCell *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[FHDetailBaseCell class]] && self.detailController) {
                if ([obj conformsToProtocol:@protocol(FHDetailVCViewLifeCycleProtocol)]) {
                    [((id<FHDetailVCViewLifeCycleProtocol>)obj) vc_viewDidDisappear:animated];
                }
            }
        }];
    }
    [self removePopLayerNotification];
}

#pragma mark - 需要子类实现的方法

// 注册cell类型
- (void)registerCellClasses {
    // sub implements.........
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}
// cell class
- (Class)cellClassForEntity:(id)model {
    // sub implements.........
    // Donothing
    return [FHDetailBaseCell class];
}
// cell identifier
- (NSString *)cellIdentifierForEntity:(id)model {
    // sub implements.........
    // Donothing
    return @"";
}
// 网络数据请求
- (void)startLoadData {
    // sub implements.........
    // Donothing
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.items.count) {
        id data = self.items[row];
        NSString *identifier = [self cellIdentifierForEntity:data];
        if (identifier.length > 0) {
            FHDetailBaseCell *cell = (FHDetailBaseCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            cell.baseViewModel = self;
            [cell refreshWithData:data];
            return cell;
        }
    }
    return [[UITableViewCell alloc] init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FHDetailBaseCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.didClickCellBlk) {
        cell.didClickCellBlk();
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
    NSNumber *cellHeight = self.cellHeightCaches[tempKey];
    if (cellHeight) {
        return [cellHeight floatValue];
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
    NSNumber *cellHeight = [NSNumber numberWithFloat:cell.frame.size.height];
    self.cellHeightCaches[tempKey] = cellHeight;
    if ([cell conformsToProtocol:@protocol(FHDetailScrollViewDidScrollProtocol)] && ![self.weakedCellTable containsObject:cell]) {
        [self.weakedCellTable addObject:cell];
    }
    if ([cell conformsToProtocol:@protocol(FHDetailVCViewLifeCycleProtocol)] && ![self.weakedVCLifeCycleCellTable containsObject:cell]) {
        [self.weakedVCLifeCycleCellTable addObject:cell];
    }
    // 添加element_show埋点
    if (!self.elementShowCaches[tempKey]) {
        self.elementShowCaches[tempKey] = @(YES);
        FHDetailBaseCell *tempCell = (FHDetailBaseCell *)cell;
        NSString *element_type = [tempCell elementTypeString:self.houseType];
        if (element_type.length > 0) {
            // 上报埋点
            NSMutableDictionary *tracerDic = self.detailTracerDic.mutableCopy;
            tracerDic[@"element_type"] = element_type;
            [tracerDic removeObjectForKey:@"element_from"];
            [FHUserTracker writeEvent:@"element_show" params:tracerDic];
        }
        
        NSArray *element_array = [tempCell elementTypeStringArray:self.houseType];
        if (element_array.count > 0) {
            for (NSString * element_name in element_array) {
                if ([element_name isKindOfClass:[NSString class]]) {
                    // 上报埋点
                    NSMutableDictionary *tracerDic = self.detailTracerDic.mutableCopy;
                    tracerDic[@"element_type"] = element_name;
                    [tracerDic removeObjectForKey:@"element_from"];
                    [FHUserTracker writeEvent:@"element_show" params:tracerDic];
                }
            }
        }
        
        NSDictionary * houseShowDict = [tempCell elementHouseShowUpload];
        if (houseShowDict.allKeys.count > 0) {
            // 上报埋点
            NSMutableDictionary *tracerDic = self.detailTracerDic.mutableCopy;
            [tracerDic addEntriesFromDictionary:houseShowDict];
            [tracerDic removeObjectForKey:@"element_from"];
            [FHUserTracker writeEvent:@"house_show" params:tracerDic];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != self.tableView) {
        return;
    }
    // 解决类似周边房源列表页的house_show问题，视频播放逻辑
    CGPoint offset = scrollView.contentOffset;
    if (self.weakedCellTable.count > 0) {
        NSArray *arr = self.weakedCellTable.allObjects;
        [arr enumerateObjectsUsingBlock:^(FHDetailBaseCell *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[FHDetailBaseCell class]] && self.detailController) {
                if ([obj conformsToProtocol:@protocol(FHDetailScrollViewDidScrollProtocol)]) {
                    [((id<FHDetailScrollViewDidScrollProtocol>)obj) fhDetail_scrollViewDidScroll:self.detailController.view];
                }
            }
        }];
    }
    self.lastPointOffset = offset;
    
    [self.detailController refreshContentOffset:scrollView.contentOffset];
}

#pragma mark - 埋点
- (void)addGoDetailLog
{
//    1. event_type ：house_app2c_v2
//    2. page_type（详情页类型）：rent_detail（租房详情页），old_detail（二手房详情页）
//    3. card_type（房源展现时的卡片样式）：left_pic（左图）
//    4. enter_from（详情页入口）：search_related_list（搜索结果推荐）
//    5. element_from ：search_related
//    6. rank
//    7. origin_from
//    8. origin_search_id
//    9.log_pb
    [FHUserTracker writeEvent:@"go_detail" params:self.detailTracerDic];

}

- (NSDictionary *)subPageParams
{
    NSMutableDictionary *info = @{}.mutableCopy;
    if (self.contactViewModel) {
        info[@"follow_status"] = @(self.contactViewModel.followStatus);
    }
    if (self.contactViewModel.contactPhone) {
        info[@"contact_phone"] = self.contactViewModel.contactPhone;
    }
    if (self.contactViewModel.chooseAgencyList) {
        info[@"choose_agency_list"] = self.contactViewModel.chooseAgencyList;
    }
    info[@"house_type"] = @(self.houseType);
    switch (_houseType) {
        case FHHouseTypeNewHouse:
            info[@"court_id"] = self.houseId;
            break;
        case FHHouseTypeSecondHandHouse:
            info[@"house_id"] = self.houseId;
            break;
        case FHHouseTypeRentHouse:
            info[@"house_id"] = self.houseId;
            break;
        case FHHouseTypeNeighborhood:
            info[@"neighborhood_id"] = self.houseId;
            break;
        default:
            info[@"house_id"] = self.houseId;
            break;
    }
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    [tracerDict addEntriesFromDictionary:self.detailTracerDic];
    info[@"tracer"] = tracerDict;
    return info;
}

- (void)addStayPageLog:(NSTimeInterval)stayTime
{
    //    1. event_type ：house_app2c_v2
    //    2. page_type（详情页类型）：rent_detail（租房详情页），old_detail（二手房详情页）
    //    3. card_type（房源展现时的卡片样式）：left_pic（左图）
    //    4. enter_from（详情页入口）：search_related_list（搜索结果推荐）
    //    5. element_from ：search_related
    //    6. rank
    //    7. origin_from
    //    8. origin_search_id
    //    9.log_pb
    //    10.stay_time
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    NSMutableDictionary *params = @{}.mutableCopy;
    [params addEntriesFromDictionary:self.detailTracerDic];
    params[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHUserTracker writeEvent:@"stay_page" params:params];
    
}

- (BOOL)isMissTitle
{
    return NO;
}
- (BOOL)isMissImage
{
    return NO;
}
- (BOOL)isMissCoreInfo
{
    return NO;
}

// excetionLog
- (void)addDetailCoreInfoExcetionLog
{
    //    detail_core_info_error
    NSMutableDictionary *attr = @{}.mutableCopy;
    NSInteger status = 0;
    if ([self isMissTitle]) {
        attr[@"title"] = @(1);
        attr[@"house_id"] = self.houseId;
        status |= FHDetailCoreInfoErrorTypeTitle;
    }
    if ([self isMissImage]) {
        attr[@"image"] = @(1);
        attr[@"house_id"] = self.houseId;
        status |= FHDetailCoreInfoErrorTypeImage;
    }
    if ([self isMissCoreInfo]) {
        attr[@"core_info"] = @(1);
        attr[@"house_id"] = self.houseId;
        status |= FHDetailCoreInfoErrorTypeCoreInfo;
    }
    attr[@"house_type"] = @(self.houseType);
    if (status != 0) {
        [[HMDTTMonitor defaultManager]hmdTrackService:@"detail_core_info_error" status:status extra:attr];
    }
    
}

- (void)addDetailRequestFailedLog:(NSInteger)status message:(NSString *)message
{
    NSMutableDictionary *attr = @{}.mutableCopy;
    attr[@"message"] = message;
    attr[@"house_type"] = @(self.houseType);
    attr[@"house_id"] = self.houseId;
    [[HMDTTMonitor defaultManager]hmdTrackService:@"detail_request_failed" status:status extra:attr];
}

#pragma mark - poplayer

- (void)addPopLayerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowPoplayerNotification:) name:DETAIL_SHOW_POP_LAYER_NOTIFICATION object:nil];
}
- (void)removePopLayerNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DETAIL_SHOW_POP_LAYER_NOTIFICATION object:nil];
}
- (void)onShowPoplayerNotification:(NSNotification *)notification
{
    
}

- (FHDetailHalfPopLayer *)popLayer
{
    FHDetailHalfPopLayer *poplayer = [[FHDetailHalfPopLayer alloc] initWithFrame:self.detailController.view.bounds];
    __weak typeof(self) wself = self;
    poplayer.reportBlock = ^(id  _Nonnull data) {
        [wself popLayerReport:data];
    };
    [self.detailController.view addSubview:poplayer];
    return poplayer;
}

-(void)popLayerReport:(id)model
{
    
    NSMutableDictionary *tracerDic = self.detailTracerDic.mutableCopy;
    tracerDic[@"log_pb"] = self.listLogPB ?: @"be_null";
    [FHUserTracker writeEvent:@"click_feedback" params:tracerDic];
    if ([TTAccountManager isLogin]) {
        [self gotoReportVC:model];
    } else {
        [self gotoLogin:model];
    }
}

- (void)gotoLogin:(id)model
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"old_feedback" forKey:@"enter_from"];
    [params setObject:@"feedback" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(NO) forKey:@"need_pop_vc"];
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                [wSelf gotoReportVC:model];
            }
            // 移除登录页面
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [wSelf delayRemoveLoginVC];
            });
        }
    }];
}

// 二手房-房源问题反馈
- (void)gotoReportVC:(id)model
{    
    NSString *reportUrl = nil;
    if ([model isKindOfClass:[FHDetailDataBaseExtraOfficialModel class]]) {
        reportUrl = [(FHDetailDataBaseExtraOfficialModel *)model dialogs].reportUrl;
    }else if ([model isKindOfClass:[FHDetailDataBaseExtraDetectiveModel class]]){
        reportUrl = [(FHDetailDataBaseExtraDetectiveModel *)model dialogs].reportUrl;
    }else if ([model isKindOfClass:[FHRentDetailDataBaseExtraModel class]]){
        reportUrl = [(FHRentDetailDataBaseExtraModel *)model dialogs].reportUrl;
    }
    
    if(reportUrl.length == 0){
        return;
    }
    
    JSONModel *dataModel = self.detailData;
    NSDictionary *jsonDic = [dataModel toDictionary];
    if (jsonDic) {

        NSString *openUrl = @"sslocal://webview";
        NSDictionary *pageData = @{@"data":jsonDic};
        NSDictionary *commonParams = [[FHEnvContext sharedInstance] getRequestCommonParams];
        if (commonParams == nil) {
            commonParams = @{};
        }
        NSDictionary *commonParamsData = @{@"data":commonParams};
        NSDictionary *jsParams = @{@"requestPageData":pageData,
                                   @"getNetCommonParams":commonParamsData
                                   };
        NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",host,reportUrl];
        NSDictionary *info = @{@"url":urlStr,@"fhJSParams":jsParams,@"title":@"房源问题反馈"};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:openUrl] userInfo:userInfo];
    }
}

- (void)delayRemoveLoginVC {
    UINavigationController *navVC = self.detailController.navigationController;
    NSInteger count = navVC.viewControllers.count;
    if (navVC && count >= 2) {
        NSMutableArray *vcs = [[NSMutableArray alloc] initWithArray:navVC.viewControllers];
        if (vcs.count == count) {
            [vcs removeObjectAtIndex:count - 2];
            [self.detailController.navigationController setViewControllers:vcs];
        }
    }
}

@end

NSString *const DETAIL_SHOW_POP_LAYER_NOTIFICATION = @"_DETAIL_SHOW_POP_LAYER_NOTIFICATION_"; //详情页点击显示半屏弹窗
