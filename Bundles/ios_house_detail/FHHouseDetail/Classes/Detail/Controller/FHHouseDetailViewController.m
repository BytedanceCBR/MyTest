//
//  FHHouseDetailViewController.m
//  FHHouseDetail
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHHouseDetailViewController.h"
#import "FHHouseDetailBaseViewModel.h"
#import "TTReachability.h"
#import "FHOldDetailBottomBarView.h"
#import "FHDetailNavBar.h"
#import "TTDeviceHelper.h"
#import "UIFont+House.h"
#import "FHHouseDetailContactViewModel.h"
#import "UIViewController+Track.h"
#import "UIView+House.h"
#import <Heimdallr/HMDTTMonitor.h>
#import <TTArticleBase/SSCommonLogic.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "FHEnvContext.h"
#import "TTInstallIDManager.h"
#import <FHHouseBase/FHBaseTableView.h>
#import "FHDetailQuestionButton.h"
#import "FHDetailBottomBarView.h"
#import "TTNavigationController.h"
#import <FHCommonUI/FHFeedbackView.h>
#import <ios_house_im/FHIMConfigManager.h>
#import <TTSettingsManager/TTSettingsManager.h>
#import <FHHouseBase/FHRelevantDurationTracker.h>
#import <CallKit/CXCallObserver.h>
#import <CallKit/CXCall.h>
#import <ByteDanceKit/NSDictionary+BTDAdditions.h>

@interface FHHouseDetailViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) FHDetailNavBar *navBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *bottomStatusBar;
@property (nonatomic, strong) UIView *bottomMaskView;
@property (nonatomic, strong) FHDetailBottomBar *bottomBar;
@property (nonatomic, strong) FHDetailUGCGroupChatButton *bottomGroupChatBtn;// 新房群聊入口
@property (nonatomic, strong) FHFeedbackView *feedbackView;
@property(nonatomic , strong) FHDetailQuestionButton *questionBtn;

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
@property (nonatomic, strong) CXCallObserver *callObserver;
//是否拨打电话已接通
@property (nonatomic, assign) BOOL isPhoneCallPickUp;
//是否拨打电话（不区分是否接通）
@property (nonatomic, assign) BOOL isPhoneCalled;// 新房UGC留资使用
@property (nonatomic, assign) CGPoint lastContentOffset;
@property (nonatomic, strong) NSDictionary *extraInfo;

@property (nonatomic) double initTimeInterval;
@end

@implementation FHHouseDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.initTimeInterval = CFAbsoluteTimeGetCurrent();
        self.isResetStatusBar = NO;
        self.houseType = [paramObj.allParams[@"house_type"] integerValue];
        self.ridcode = paramObj.allParams[@"ridcode"];
        self.realtorId = paramObj.allParams[@"realtor_id"];
        self.bizTrace = [paramObj.allParams btd_stringValueForKey:@"biz_trace"];
        
        NSObject *extraInfo = paramObj.allParams[kFHClueExtraInfo];
        if ([extraInfo isKindOfClass:[NSString class]]) {
            NSDictionary *extraInfoDict = [self getDictionaryFromJSONString:(NSString *)extraInfo];
            self.extraInfo = extraInfoDict;
        }else if ([extraInfo isKindOfClass:[NSDictionary class]]) {
            self.extraInfo = (NSDictionary *)extraInfo;
        }

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
        
        
//        self.instantData = paramObj.allParams[INSTANT_DATA_KEY];
    }
    return self;
}

- (BOOL)isTopestViewController {
    /**
     经纪人评价页面原本只应该出现在房源详情页
     目前会在房源详情页后面的所有页面只要触发手机号拨通就会弹出
     在判断弹出的方法内进行页面层级的判断，或者在其他页面不接收电话相关的observer
     */
    if (self.navigationController.viewControllers.lastObject != self || self.presentedViewController != nil) {
        return NO;
    }
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [self setupCallCenter];
    self.isViewDidDisapper = NO;
    self.isPhoneCalled = NO;
    
    
    [self startLoadData];
    
    if (!self.isDisableGoDetail) {
        [self.viewModel addGoDetailLog];
    }
    
    // Push推送过来的状态栏修改
    __weak typeof(self) wSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wSelf updateStatusBar:wSelf.tableView.contentOffset];
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
    [self updateStatusBar:self.tableView.contentOffset];
    [self refreshContentOffset:self.tableView.contentOffset];
    [self.view endEditing:YES];
    [self.viewModel vc_viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.viewModel addStayPageLog:self.ttTrackStayTime];
    [self sendCurrentPageStayTime: self.ttTrackStayTime * 1000.0];
    [self tt_resetStayTime];
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //有些页面禁用了pan手势，但是在某些情况下比如直接push切换tab等操作 不会触发关闭当前的view，导致没有设置回来 by xsm
    if([self.navigationController isKindOfClass:[TTNavigationController class]]){
        TTNavigationController *naviVC = (TTNavigationController *)self.navigationController;
        naviVC.panRecognizer.enabled = YES;
    }
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

- (void)trySendCurrentPageStayTime {
    if (self.ttTrackStartTime == 0) {//当前页面没有在展示过
        return;
    }
    double duration = self.ttTrackStayTime * 1000.0;
    if (duration <= 200) {//低于200毫秒，忽略
        self.ttTrackStartTime = 0;
        [self tt_resetStayTime];
        return;
    }
    [self sendCurrentPageStayTime:duration];
    
    self.ttTrackStartTime = 0;
    [self tt_resetStayTime];
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    
    [self.viewModel addStayPageLog:self.ttTrackStayTime * 1000.0];
    [self trySendCurrentPageStayTime];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)sendCurrentPageStayTime:(double)duration
{
    if (self.houseType != FHHouseTypeSecondHandHouse) {
        return;
    }
    NSString *_categoryName = self.tracerDict[@"enter_from"];
    NSString *elementFrom = self.tracerDict[@"element_from"];
    NSString *enterFrom = @"";

    if ([elementFrom isEqualToString:@"be_null"]) {
        enterFrom = [NSString stringWithFormat:@"click_%@", _categoryName];
    }else {
        enterFrom = [NSString stringWithFormat:@"click_%@", elementFrom];
    }
    //新加的详情页关联时长
    [[FHRelevantDurationTracker sharedTracker] appendRelevantDurationWithGroupID:_houseId
                                                                          itemID:_houseId
                                                                       enterFrom:enterFrom
                                                                    categoryName:_categoryName
                                                                        stayTime:(NSInteger)(duration)
                                                                           logPb:self.listLogPB];
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
//        if (!self.instantData) {
            [self startLoading];
//        }
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
    self.viewModel.houseInfoOriginBizTrace = self.bizTrace;
    self.viewModel.houseId = self.houseId;
    self.viewModel.ridcode = self.ridcode;
    self.viewModel.realtorId = self.realtorId;
    self.viewModel.listLogPB = self.listLogPB;
    // 构建详情页需要的埋点数据，放入baseViewModel中
    self.viewModel.detailTracerDic = [self makeDetailTracerData];
    self.viewModel.source = self.source;
    self.viewModel.extraInfo = self.extraInfo;
    self.viewModel.initTimeInterval = self.initTimeInterval;
    [self.view addSubview:_tableView];

    __weak typeof(self)wself = self;
//    CGRect screenBounds = [UIScreen mainScreen].bounds;
//    CGFloat navBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 44 : 20;
    _navBar = [[FHDetailNavBar alloc]initWithType:FHDetailNavBarTypeDefault];
    _navBar.backActionBlock = ^{
        [wself.navigationController popViewControllerAnimated:YES];
    };
    [self.view addSubview:_navBar];
    self.viewModel.navBar = _navBar;

    _bottomMaskView = [[UIView alloc] init];
    _bottomMaskView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_bottomMaskView];
    
    if  (_houseType == FHHouseTypeRentHouse ) {
        _bottomBar = [[FHDetailBottomBarView alloc]initWithFrame:CGRectZero];
    }else {
         _bottomBar = [[FHOldDetailBottomBarView alloc]initWithFrame:CGRectZero];
    }
    
    [self.view addSubview:_bottomBar];
    self.viewModel.bottomBar = _bottomBar;
    _bottomBar.hidden = YES;
    
    self.bottomGroupChatBtn = [[FHDetailUGCGroupChatButton alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_bottomGroupChatBtn];
    self.bottomBar.bottomGroupChatBtn = _bottomGroupChatBtn;// 这样子改动最小
    _bottomGroupChatBtn.hidden = YES;
    
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
    self.viewModel.contactViewModel.houseInfoOriginBizTrace = self.bizTrace;

    [self.view addSubview:self.questionBtn];
    self.viewModel.questionBtn = self.questionBtn;
    self.questionBtn.hidden = YES;
    CGFloat bottomMargin = 0;
    if (@available(iOS 11.0, *)) {
        bottomMargin = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
    }
    [self.questionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(40);
        make.bottom.mas_equalTo(self.view).mas_offset(-100 - bottomMargin);
    }];
    
    [self addDefaultEmptyViewFullScreen];

    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.bottomBar.mas_top);
    }];
    [_bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(self.houseType == FHHouseTypeRentHouse ? 64 : 80);
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
    
    [_bottomGroupChatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(32);
        make.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.bottomBar.mas_top).offset(-30);
    }];
    
    [self.view bringSubviewToFront:_navBar];
}


-(void)updateLayout:(BOOL)isInstant
{
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        if (isInstant) {
            make.bottom.mas_equalTo(self.view);
        }else{
            make.bottom.mas_equalTo(self.bottomBar.mas_top);
        }
    }];
    self.bottomBar.hidden = isInstant;
    self.bottomMaskView.hidden = isInstant;
    self.bottomStatusBar.hidden = isInstant;
    
    if (isInstant) {
        [self.view bringSubviewToFront:self.tableView];
    }else{
        [self.view sendSubviewToBack:self.tableView];
    }
    
    [self.view setNeedsUpdateConstraints];
    
    
}

- (void)setupCallCenter {
    if (@available(iOS 10.0 , *)) {
        _callObserver = [[CXCallObserver alloc]init];
        [_callObserver setDelegate:(id)self queue:dispatch_get_main_queue()];
    }else {
        @weakify(self);
        _callCenter = [[CTCallCenter alloc] init];
        _callCenter.callEventHandler = ^(CTCall* call){
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self callHandlerWith:call];
            });
        };
    }
}

- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call API_AVAILABLE(ios(10.0)){
    
    if (![self isTopestViewController]) {
        return ;
    }
//    NSLog(@"outgoing :%d  onHold :%d   hasConnected :%d   hasEnded :%d",call.outgoing,call.onHold,call.hasConnected,call.hasEnded);
    /** 以下为我手动测试 如有错误欢迎指出
      拨通:  outgoing :1  onHold :0   hasConnected :0   hasEnded :0
      拒绝:  outgoing :1  onHold :0   hasConnected :0   hasEnded :1
      链接:  outgoing :1  onHold :0   hasConnected :1   hasEnded :0
      挂断:  outgoing :1  onHold :0   hasConnected :1   hasEnded :1
     
      新来电话:    outgoing :0  onHold :0   hasConnected :0   hasEnded :0
      保留并接听:  outgoing :1  onHold :1   hasConnected :1   hasEnded :0
      另一个挂掉:  outgoing :0  onHold :0   hasConnected :1   hasEnded :0
      保持链接:    outgoing :1  onHold :0   hasConnected :1   hasEnded :1
      对方挂掉:    outgoing :0  onHold :0   hasConnected :1   hasEnded :1
     */
    //接通
    if (call.outgoing) {
        self.isPhoneCalled = YES;
    }
    if (call.outgoing && call.hasConnected) {
        //通话中
        self.isPhoneCallPickUp = YES;
    }
    //挂断
    if (call.hasEnded) {
        if (self.isPhoneCalled && self.isPhoneCallPickUp) {
            [self checkShowFeedbackView];
        }
        [self checkShowSocialAlert];
        self.isPhoneCalled = NO;
    }
}

- (void)callHandlerWith:(CTCall*)call
{
    if (![self isTopestViewController]) {
        return ;
    }

    if ([call.callState isEqualToString:CTCallStateDisconnected]){
        //未接通和挂断
        if (self.isPhoneCalled && self.isPhoneCallPickUp) {
            [self checkShowFeedbackView];
        }
        [self checkShowSocialAlert];
        self.isPhoneCalled = NO;
    }else if ([call.callState isEqualToString:CTCallStateConnected]){
        //通话中
        self.isPhoneCallPickUp = YES;
    }else if([call.callState isEqualToString:CTCallStateIncoming]){
        //来电话
    }else if ([call.callState isEqualToString:CTCallStateDialing]){
        //正在拨号
        self.isPhoneCalled = YES;
    }else{
        //doNothing
    }
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
                self.tracerDict[@"log_pb"] = log_pb_dic;
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
    
    id tracerLogPb = self.tracerDict[@"log_pb"];
    //IM 新房等进入时log_pb 是字符串
    if ([tracerLogPb isKindOfClass:[NSString class]]) {
        self.tracerDict[@"log_pb"] = self.tracerModel.logPb;
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
    detailTracerDic[@"from_gid"] = self.tracerDict[@"from_gid"];
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

- (void)refreshContentOffset:(CGPoint)contentOffset {
    //如果房源是企业担保的，不需要更新statusbar样式，header背景黄色，也不需要更换图标
    if (self.navBar.isForVouch) {
        if (contentOffset.y > CGRectGetWidth(self.view.bounds)*281.0/375.0 - 41 + 20 - (CGRectGetHeight(self.navBar.frame) - 40)) {
            [self.navBar refreshAlpha:1.0];
        } else {
            [self.navBar refreshAlpha:0];
        }
        if ([UIApplication sharedApplication].statusBarStyle != UIStatusBarStyleLightContent) {
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        }
        return;
    }
    CGFloat alpha = contentOffset.y / 139 * 2;
    [self.navBar refreshAlpha:alpha];
    
    if ((contentOffset.y <= 0 && _lastContentOffset.y <= 0) || (contentOffset.y > 0 && _lastContentOffset.y > 0)) {
        return;
    }
    _lastContentOffset = contentOffset;
    [self updateStatusBar:contentOffset];
}

- (void)updateStatusBar:(CGPoint)contentOffset
{
    UIStatusBarStyle style = UIStatusBarStyleLightContent;
    if (contentOffset.y > 0) {
        style = UIStatusBarStyleDefault;
    }
    if (!self.isViewDidDisapper) {
        [[UIApplication sharedApplication]setStatusBarStyle:style];
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

- (void)tapAction:(id)tap {
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

    
}

- (void)updateLoadFinish
{
    [self.viewModel.contactViewModel updateLoadFinish];
}

- (void)applicationDidBecomeActive {
}

- (void)checkShowSocialAlert {
    // 新房留资后弹窗
    if (self.isPhoneCalled) {
        self.isPhoneCalled = NO;
        [self.viewModel.contactViewModel checkSocialPhoneCall];
    } else {
        self.viewModel.contactViewModel.socialContactConfig = nil;
    }
}

// 二手房反馈弹窗
- (void)checkShowFeedbackView {
    // 反馈弹窗
    if([self isShowFeedbackView]){
        self.isPhoneCallPickUp = NO;
        self.isPhoneCallShow = NO;
        [self addFeedBackView];
        self.phoneCallRealtorId = nil;
        self.phoneCallRequestId = nil;
    }
    // 数据清除
    self.isPhoneCallShow = NO;
}

- (BOOL)isShowFeedbackView {
    //满足这两个条件，在回来时候显示反馈弹窗
    if(self.isPhoneCallPickUp &&
       self.isPhoneCallShow &&
       self.phoneCallRealtorId &&
       self.phoneCallRequestId &&
       (self.viewModel.houseType == FHHouseTypeSecondHandHouse)){
        
        if (![self isTopestViewController]) {
            return NO;
        }
        
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
//    self.feedbackView.realtorId = self.phoneCallRealtorId;
//    self.feedbackView.requestId = self.phoneCallRequestId;
//    [self.feedbackView show:self.view];
    NSString *realtorId = self.phoneCallRealtorId;
    NSString *requestId = self.phoneCallRequestId;

    WeakSelf;
    __block NSMutableDictionary *tracerDic = @{}.mutableCopy;
    if (self.viewModel.detailTracerDic) {
        [tracerDic addEntriesFromDictionary:self.viewModel.detailTracerDic];
    }
    tracerDic[@"realtor_id"] = realtorId ? realtorId : @"be_null";
    //    tracerDic[@"click_position"] = position ? position : @"be_null";
    tracerDic[@"request_id"] = requestId ?: UT_BE_NULL;
    //    tracerDic[@"star_num"] = num ? num : @"be_null";
    if (self.viewModel.contactViewModel && self.viewModel.contactViewModel.contactPhone) {
        tracerDic[@"realtor_logpb"] = self.viewModel.contactViewModel.contactPhone.realtorLogpb;
    } else {
        tracerDic[@"realtor_logpb"] = UT_BE_NULL;
    }
    [self addClickFeedbackLog:tracerDic];

    FHRealtorEvaluationModel *evaluationModel = [[FHIMConfigManager shareInstance]getRealtorEvaluationModel];
    if (![evaluationModel isKindOfClass:[FHRealtorEvaluationModel class]]) {
        evaluationModel = nil;
    }
    FHFeedbackView *feedbackView = [[FHFeedbackView alloc]initWithFrame:[UIScreen mainScreen].bounds evalationModel:evaluationModel submitBlock:^(NSString * _Nonnull content, NSInteger scoreCount, NSArray * _Nonnull scoreTags) {
        StrongSelf;
        NSMutableDictionary *traceParams = @{}.mutableCopy;
        traceParams[@"realtor_id"] = realtorId;
        traceParams[@"target_id"] = self.houseId;
        tracerDic[@"star_num"] = @(scoreCount);
        traceParams[@"evaluation_type"] = @(0);
        [[FHIMConfigManager shareInstance]submitRealtorEvaluation:content scoreCount:scoreCount scoreTags:scoreTags traceParams:traceParams];
        
        tracerDic[@"click_position"] = @"confirm";
        tracerDic[@"star_num"] = @(scoreCount);
        [self addRealtorEvaluatePopupClickLog:tracerDic];
    } closeBlock:^(FHFeedbackViewCompleteType type) {
        StrongSelf;
        tracerDic[@"star_num"] = @(0);
        tracerDic[@"click_position"] = @"cancel";
        [self addRealtorEvaluatePopupClickLog:tracerDic];
    }];
    BOOL isForceEnableConfirm = NO;
    NSDictionary *fhSettings= [[TTSettingsManager sharedManager] settingForKey:@"f_settings" defaultValue:@{} freeze:YES];
    if (fhSettings != nil && [fhSettings objectForKey:@"f_phone_feedback_low_score_submit_enabled"] != nil) {
        NSInteger info = [[fhSettings objectForKey:@"f_phone_feedback_low_score_submit_enabled"] integerValue];
        if (info == 1) {
            isForceEnableConfirm = YES;
        }
    }
    feedbackView.isForceEnableConfirm = isForceEnableConfirm;
    [feedbackView showFrom:nil];
    [self addRealtorEvaluatePopupShowLog:tracerDic];
}

- (void)addClickFeedbackLog:(NSDictionary *)extraDict
{
    NSMutableDictionary *tracerDic = @{}.mutableCopy;
    if (self.viewModel.detailTracerDic) {
        [tracerDic addEntriesFromDictionary:self.viewModel.detailTracerDic];
    }
    tracerDic[@"realtor_id"] = extraDict[@"realtor_id"];
    tracerDic[@"request_id"] = extraDict[@"request_id"];
    tracerDic[@"enter_from"] = @"realtor_evaluate_popup";
    TRACK_EVENT(@"click_feedback", tracerDic);
}

- (void)addRealtorEvaluatePopupShowLog:(NSDictionary *)params
{
    [FHUserTracker writeEvent:@"realtor_evaluate_popup_show" params:params];
}

- (void)addRealtorEvaluatePopupClickLog:(NSDictionary *)params
{
    [FHUserTracker writeEvent:@"realtor_evaluate_popup_click" params:params];
}

- (FHDetailQuestionButton *)questionBtn
{
    if (!_questionBtn) {
        _questionBtn = [[FHDetailQuestionButton alloc]init];
//        _questionBtn.backgroundColor = [UIColor whiteColor];
        _questionBtn.isFold = YES;
    }
    return _questionBtn;
}


- (void)dealloc
{
    if (@available(iOS 10.0 , *)) {
        _callObserver = nil;
    }else {
        _callCenter = nil;
    }
}

@end

NSString *const INSTANT_DATA_KEY = @"_INSTANT_DATA_KEY_";
