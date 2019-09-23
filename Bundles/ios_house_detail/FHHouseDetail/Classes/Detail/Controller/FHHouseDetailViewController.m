//
//  FHHouseDetailViewController.m
//  FHHouseDetail
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHHouseDetailViewController.h"
#import "FHHouseDetailBaseViewModel.h"
#import "TTReachability.h"
#import "FHDetailBottomBarView.h"
#import "FHDetailNavBar.h"
#import "TTDeviceHelper.h"
#import "UIFont+House.h"
#import "FHHouseDetailContactViewModel.h"
#import "UIViewController+Track.h"
#import "UIView+House.h"
#import <Heimdallr/HMDTTMonitor.h>
#import <FHRNHelper.h>
#import <TTArticleBase/SSCommonLogic.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "FHDetailFeedbackView.h"
#import "FHEnvContext.h"
#import "TTInstallIDManager.h"
#import <FHHouseBase/FHBaseTableView.h>

@interface FHHouseDetailViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) FHDetailNavBar *navBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *bottomStatusBar;
@property (nonatomic, strong) UIView *bottomMaskView;
@property (nonatomic, strong) FHDetailBottomBarView *bottomBar;
@property (nonatomic, strong) FHDetailFeedbackView *feedbackView;

@property (nonatomic, strong)   FHHouseDetailBaseViewModel       *viewModel;
@property (nonatomic, assign)   FHHouseType houseType; // 房源类型
@property (nonatomic, copy)     NSString       *source; // 特殊标记，从哪进入的小区详情，比如地图租房列表“rent_detail”，此时小区房源展示租房列表
@property (nonatomic, copy)   NSString *houseId; // 房源id
@property (nonatomic, copy)   NSString *ridcode; // 经纪人id，用来锁定经纪人展位
@property (nonatomic, copy)   NSString *realtorId; // 经纪人id，用来锁定经纪人展位

@property (nonatomic, strong)   NSDictionary       *listLogPB; // 外部传入的logPB
@property (nonatomic, copy)   NSString* searchId;
@property (nonatomic, copy)   NSString* imprId;
@property (nonatomic, assign)   BOOL isDisableGoDetail;
@property (nonatomic, strong) FHDetailContactModel *contactPhone;
//@property (nonatomic, strong) id instantData;
@property (nonatomic, strong) CTCallCenter *callCenter;
//是否拨打电话已接通
@property (nonatomic, assign) BOOL isPhoneCallPickUp;

@end

@implementation FHHouseDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
        self.houseType = [paramObj.allParams[@"house_type"] integerValue];
        self.ridcode = paramObj.allParams[@"ridcode"];
        self.realtorId = paramObj.allParams[@"realtor_id"];

        if (!self.houseType) {
            if ([paramObj.sourceURL.absoluteString containsString:@"neighborhood_detail"]) {
                self.houseType = FHHouseTypeNeighborhood;
            }
            
            if ([paramObj.sourceURL.absoluteString containsString:@"old_house_detail"]) {
                self.houseType = FHHouseTypeSecondHandHouse;
            }
            
            if ([paramObj.sourceURL.absoluteString containsString:@"new_house_detail"]) {
                self.houseType = FHHouseTypeNewHouse;
            }
            
            if ([paramObj.sourceURL.absoluteString containsString:@"rent_detail"]) {
                self.houseType = FHHouseTypeRentHouse;
            }
        }

        
        self.ttTrackStayEnable = YES;
        switch (_houseType) {
            case FHHouseTypeNewHouse:
                self.houseId = paramObj.allParams[@"court_id"];
                break;
            case FHHouseTypeSecondHandHouse:
                self.houseId = paramObj.allParams[@"house_id"];
                break;
            case FHHouseTypeRentHouse:
                self.houseId = paramObj.allParams[@"house_id"];
                break;
            case FHHouseTypeNeighborhood:
                self.houseId = paramObj.allParams[@"neighborhood_id"];
                break;
            default:
                if (!self.houseId) {
                    self.houseId = paramObj.allParams[@"house_id"];
                }
                break;
        }
        
        if ([paramObj.sourceURL.absoluteString containsString:@"neighborhood_detail"]) {
            self.houseId = paramObj.allParams[@"neighborhood_id"];
        }
        // 埋点数据处理
        [self processTracerData:paramObj.allParams];
        // 非埋点数据处理
        // disable_go_detail
        self.isDisableGoDetail = paramObj.allParams[@"disable_go_detail"] ? paramObj.allParams[@"disable_go_detail"] : NO;
        // source
        if ([paramObj.allParams[@"source"] isKindOfClass:[NSString class]]) {
            self.source = paramObj.allParams[@"source"];
        }

        if (self.houseId.length < 1) {
            [[HMDTTMonitor defaultManager]hmdTrackService:@"detail_schema_error" metric:nil category:@{@"status":@(1)} extra:@{@"openurl":paramObj.sourceURL.absoluteString}];
        }else {
            [[HMDTTMonitor defaultManager]hmdTrackService:@"detail_schema_error" metric:nil category:@{@"status":@(0)} extra:nil];
        }
        
        self.instantData = paramObj.allParams[INSTANT_DATA_KEY];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [self setupCallCenter];
    self.isViewDidDisapper = NO;
    
    if(![SSCommonLogic disableDetailInstantShow] && [TTReachability isNetworkConnected]){
        //有网且打开秒开的情况下才显示
        if (self.instantData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.viewModel handleInstantData:self.instantData];
            });
        }
    }else{
        self.instantData = nil;
    }
    
    [self startLoadData];
    
    if (!self.isDisableGoDetail) {
        [self.viewModel addGoDetailLog];
    }
    
    // Push推送过来的状态栏修改
    __weak typeof(self) wSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wSelf refreshContentOffset:wSelf.tableView.contentOffset];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel.contactViewModel refreshMessageDot];
    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isViewDidDisapper = NO;
    [self refreshContentOffset:self.tableView.contentOffset];
    [self.view endEditing:YES];
    [self.viewModel vc_viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.viewModel addStayPageLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isViewDidDisapper = YES;
    [self.viewModel vc_viewDidDisappear:animated];
}

#pragma mark - for keyboard show
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        [self.view endEditing:YES];
    }
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    
    [self.viewModel addStayPageLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        if (!self.instantData) {
            [self startLoading];
        }
        self.isLoadingData = YES;
        [self.viewModel startLoadData];
    } else {
        //无网就显示蒙层
//        if (!self.instantData) {
            [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
//        }
    }
}

// 重新加载
- (void)retryLoadData {
    if (!self.isLoadingData) {
        [self startLoadData];
    }
}

//移除导航条底部line
- (void)removeBottomLine
{
    [self.navBar removeBottomLine];
}

- (void)setupUI {
    [self configTableView];
    self.viewModel = [FHHouseDetailBaseViewModel createDetailViewModelWithHouseType:self.houseType withController:self tableView:_tableView];
    self.viewModel.houseId = self.houseId;
    self.viewModel.ridcode = self.ridcode;
    self.viewModel.realtorId = self.realtorId;
    self.viewModel.listLogPB = self.listLogPB;
    // 构建详情页需要的埋点数据，放入baseViewModel中
    self.viewModel.detailTracerDic = [self makeDetailTracerData];
    self.viewModel.source = self.source;
    [self.view addSubview:_tableView];

    __weak typeof(self)wself = self;
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat navBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 44 : 20;
    _navBar = [[FHDetailNavBar alloc]initWithType:FHDetailNavBarTypeDefault];
    _navBar.backActionBlock = ^{
        [wself.navigationController popViewControllerAnimated:YES];
    };
    [self.view addSubview:_navBar];
    self.viewModel.navBar = _navBar;

    _bottomMaskView = [[UIView alloc] init];
    _bottomMaskView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_bottomMaskView];
    
    _bottomBar = [[FHDetailBottomBarView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:_bottomBar];
    self.viewModel.bottomBar = _bottomBar;
    _bottomBar.hidden = YES;
    
    _bottomStatusBar = [[UILabel alloc]init];
    _bottomStatusBar.textAlignment = NSTextAlignmentCenter;
    _bottomStatusBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    _bottomStatusBar.text = @"该房源已停售";
    _bottomStatusBar.font = [UIFont themeFontRegular:14];
    _bottomStatusBar.textColor = [UIColor whiteColor];
    _bottomStatusBar.hidden = YES;
    [self.view addSubview:_bottomStatusBar];
    self.viewModel.bottomStatusBar = _bottomStatusBar;

    self.viewModel.contactViewModel = [[FHHouseDetailContactViewModel alloc] initWithNavBar:_navBar bottomBar:_bottomBar houseType:_houseType houseId:_houseId];
    self.viewModel.contactViewModel.searchId = self.searchId;
    self.viewModel.contactViewModel.imprId = self.imprId;
    self.viewModel.contactViewModel.tracerDict = [self makeDetailTracerData];
    self.viewModel.contactViewModel.belongsVC = self;

    [self addDefaultEmptyViewFullScreen];

    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.bottomBar.mas_top);
    }];
    [_bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(64);
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom);
        }else {
            make.bottom.mas_equalTo(self.view);
        }
    }];
    [_bottomStatusBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.bottomBar.mas_top);
        make.height.mas_equalTo(0);
    }];
    
    [_bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomBar.mas_top);
        make.left.right.bottom.mas_equalTo(self.view);
    }];
    
    [self.view bringSubviewToFront:_navBar];
}

- (void)setupCallCenter {
    @weakify(self);
    self.callCenter = [[CTCallCenter alloc] init];
    _callCenter.callEventHandler = ^(CTCall* call){
        @strongify(self);
        if ([call.callState isEqualToString:CTCallStateDisconnected]){
            //未接通
        }else if ([call.callState isEqualToString:CTCallStateConnected]){
            //通话中
            self.isPhoneCallPickUp = YES;
        }else if([call.callState isEqualToString:CTCallStateIncoming]){
            //来电话
        }else if ([call.callState isEqualToString:CTCallStateDialing]){
            //正在拨号
        }else{
            //doNothing
        }
    };
}

// 埋点数据处理:1、paramObj.allParams中的"tracer"字段，2、allParams中的origin_from、report_params等字段
- (void)processTracerData:(NSDictionary *)allParams {
    // 原始数据放入：self.tracerDict
    // 取其他非"tracer"字段数据
    NSString *origin_from = allParams[@"origin_from"];
    if ([origin_from isKindOfClass:[NSString class]] && origin_from.length > 0) {
        self.tracerDict[@"origin_from"] = origin_from;
    }
    NSString *origin_search_id = allParams[@"origin_search_id"];
    if ([origin_search_id isKindOfClass:[NSString class]] && origin_search_id.length > 0) {
        self.tracerDict[@"origin_search_id"] = origin_search_id;
    }
    NSString *report_params = allParams[@"report_params"];
    if ([report_params isKindOfClass:[NSString class]]) {
        NSDictionary *report_params_dic = [self getDictionaryFromJSONString:report_params];
        if (report_params_dic) {
            [self.tracerDict addEntriesFromDictionary:report_params_dic];
        }
    }
    NSString *log_pb_str = allParams[@"log_pb"];
    if ([log_pb_str isKindOfClass:[NSDictionary class]]) {
        self.tracerDict[@"log_pb"] = log_pb_str;
    } else {
        if ([log_pb_str isKindOfClass:[NSString class]] && log_pb_str.length > 0) {
            NSDictionary *log_pb_dic = [self getDictionaryFromJSONString:log_pb_str];
            if (log_pb_dic) {
                self.tracerDict[@"log_pb"] = log_pb_str;
            }
        }else
        {
            NSDictionary *report_params_dic = [self getDictionaryFromJSONString:report_params];
            if (report_params_dic) {
                NSDictionary *report_params_dic = [self getDictionaryFromJSONString:report_params];
                if (report_params_dic) {
                    NSString *log_pb = report_params_dic[@"log_pb"];
                    if (log_pb) {
                        if ([log_pb isKindOfClass:[NSString class]]) {
                            NSDictionary *logPb = [self getDictionaryFromJSONString:log_pb];
                            if (logPb) {
                                self.tracerDict[@"log_pb"] = logPb;
                            }
                        }else if ([log_pb isKindOfClass:[NSDictionary class]])
                        {
                            self.tracerDict[@"log_pb"] = log_pb;
                        }
                    }
                }
            }
        }
    }
    
    // rank字段特殊处理：外部可能传入字段为rank和index不同类型的数据
    id index = self.tracerDict[@"index"];
    id rank = self.tracerDict[@"rank"];
    if (index != NULL && rank == NULL) {
        self.tracerDict[@"rank"] = self.tracerDict[@"index"];
    }
    // 后续会构建基础埋点数据
    // 取log_pb字段数据
    id log_pb = self.tracerDict[@"log_pb"];
    if ([log_pb isKindOfClass:[NSDictionary class]]) {
        self.listLogPB = log_pb;
        self.searchId = log_pb[@"search_id"];
        self.imprId = log_pb[@"impr_id"];
    }
}

// page_type
-(NSString *)pageTypeString {
    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            return @"new_detail";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"old_detail";
            break;
        case FHHouseTypeRentHouse:
            return @"rent_detail";
            break;
        case FHHouseTypeNeighborhood:
            return @"neighborhood_detail";
            break;
        default:
            return @"be_null";
            break;
    }
}

// 构建详情页基础埋点数据
- (NSMutableDictionary *)makeDetailTracerData {
    NSMutableDictionary *detailTracerDic = [NSMutableDictionary new];
    detailTracerDic[@"page_type"] = [self pageTypeString];
    detailTracerDic[@"card_type"] = self.tracerDict[@"card_type"] ? : @"be_null";
    detailTracerDic[@"enter_from"] = self.tracerDict[@"enter_from"] ? : @"be_null";
    detailTracerDic[@"element_from"] = self.tracerDict[@"element_from"] ? : @"be_null";
    detailTracerDic[@"rank"] = self.tracerDict[@"rank"] ? : @"be_null";
    detailTracerDic[@"origin_from"] = self.tracerDict[@"origin_from"] ? : @"be_null";
    detailTracerDic[@"origin_search_id"] = self.tracerDict[@"origin_search_id"] ? : @"be_null";
    detailTracerDic[@"log_pb"] = self.tracerDict[@"log_pb"] ? : @"be_null";
    // 以下3个参数都在:log_pb中
    // group_id
    // impr_id
    // search_id
    // 比如：element_show中添加："element_type": "trade_tips"
    // house_show 修改 rank、log_pb 等字段
    return detailTracerDic;
}

- (NSDictionary *)getDictionaryFromJSONString:(NSString *)jsonString {
    NSMutableDictionary *retDic = nil;
    if (jsonString.length > 0) {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        retDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if ([retDic isKindOfClass:[NSDictionary class]] && error == nil) {
            return retDic;
        } else {
            return nil;
        }
    }
    return retDic;
}

- (void)setNavBarTitle:(NSString *)navTitle
{
    UILabel *titleLabel = [UILabel new];
    FHDetailNavBar *navbar = (FHDetailNavBar *)[self getNaviBar];
    titleLabel.text = navTitle;
    titleLabel.textColor = [UIColor themeGray1];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [navbar addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.bottom.equalTo(navbar);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(44);
    }];
}

- (void)refreshContentOffset:(CGPoint)contentOffset
{
    CGFloat alpha = contentOffset.y / 139 * 2;
    [self.navBar refreshAlpha:alpha];

    if (!self.isViewDidDisapper) {
        if (contentOffset.y > 0) {
            [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
        }else {
            [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
        }
    }
}

- (void)configTableView {
    _tableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    tapGesturRecognizer.cancelsTouchesInView = NO;
    tapGesturRecognizer.delegate = self;
    [_tableView addGestureRecognizer:tapGesturRecognizer];
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
}

-(void)tapAction:(id)tap {
    [_tableView endEditing:YES];
}

- (UIView *)getNaviBar
{
    return self.navBar;
}

- (UIView *)getBottomBar
{
    return self.bottomBar;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if([otherGestureRecognizer.view isKindOfClass:[UITextField class]] || [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]){
        return NO;
    }
    return YES;
}

#pragma mark 监听返回

- (void)goBack
{
    UIViewController *popVC = [self.navigationController popViewControllerAnimated:YES];
    if (nil == popVC) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (void)willMoveToParentViewController:(UIViewController*)parent{
    [super willMoveToParentViewController:parent];
}

- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    if (!parent) {
        [self.viewModel.contactViewModel destroyRNPreLoadCache];
    }
}

- (void)updateLoadFinish
{
    [self.viewModel.contactViewModel updateLoadFinish];
}

- (void)applicationDidBecomeActive {
    if([self isShowFeedbackView]){
        self.isPhoneCallPickUp = NO;
        self.isPhoneCallShow = NO;
        [self addFeedBackView];
        self.phoneCallRealtorId = nil;
        self.phoneCallRequestId = nil;
    }
}

- (BOOL)isShowFeedbackView {
    //满足这两个条件，在回来时候显示反馈弹窗
    if(self.isPhoneCallPickUp &&
       self.isPhoneCallShow &&
       self.phoneCallRealtorId &&
       self.phoneCallRequestId &&
       (self.viewModel.houseType == FHHouseTypeSecondHandHouse)){
        NSString *houseId = self.viewModel.houseId;
        NSString *deviceId = [[TTInstallIDManager sharedInstance] deviceID];
        NSString *cacheKey = @"";

        if(!isEmptyString(houseId)){
            cacheKey = [cacheKey stringByAppendingString:houseId];
        }

        if(!isEmptyString(deviceId)){
            cacheKey = [cacheKey stringByAppendingString:@"_"];
            cacheKey = [cacheKey stringByAppendingString:deviceId];
        }

        if(!isEmptyString(cacheKey)){
            NSTimeInterval dayStartTime = [[self dayStart:[NSDate date]] timeIntervalSince1970];
            YYCache *detailFeedbackCache = [[FHEnvContext sharedInstance].generalBizConfig detailFeedbackCache];
            if([detailFeedbackCache containsObjectForKey:cacheKey]){
                //已经显示过该房源
                id value = [detailFeedbackCache objectForKey:cacheKey];
                NSTimeInterval lastDayStartTime = [value doubleValue];
                //超过一天清空所有记录，再次显示
                if(dayStartTime - lastDayStartTime >= 24 * 60 * 60){
                    [detailFeedbackCache removeAllObjects];
                    [detailFeedbackCache setObject:@(dayStartTime) forKey:cacheKey];
                    return YES;
                }
            }else{
                //未显示过
                [detailFeedbackCache setObject:@(dayStartTime) forKey:cacheKey];
                return YES;
            }
        }
    }

    return NO;
}

- (NSDate *)dayStart:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    NSDate *startDate = [calendar dateFromComponents:components];
    return startDate;
}

- (void)addFeedBackView {
    self.feedbackView.realtorId = self.phoneCallRealtorId;
    self.feedbackView.requestId = self.phoneCallRequestId;
    [self.feedbackView show:self.view];
}

- (FHDetailFeedbackView *)feedbackView {
    if (!_feedbackView) {
        __weak typeof(self) wself = self;
        _feedbackView = [[FHDetailFeedbackView alloc] initWithFrame:self.view.bounds];
        _feedbackView.navVC = self.navigationController;
        _feedbackView.viewModel = self.viewModel;
    }
    return _feedbackView;
}

@end

NSString *const INSTANT_DATA_KEY = @"_INSTANT_DATA_KEY_";
