//
//  FHNewHouseDetailViewController.m
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailViewController.h"
#import "FHOldDetailBottomBarView.h"
#import "FHDetailNavBar.h"
#import "FHHouseDetailContactViewModel.h"
#import "UIViewController+Track.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <TTArticleBase/SSCommonLogic.h>
#import "FHEnvContext.h"
#import <FHHouseBase/FHBaseCollectionView.h>
#import <ios_house_im/FHIMConfigManager.h>
#import <TTSettingsManager/TTSettingsManager.h>
#import <FHHouseBase/FHRelevantDurationTracker.h>
#import <ByteDanceKit/ByteDanceKit.h>
#import "TTNavigationController.h"
#import <IGListKit/IGListKit.h>
#import "FHNewHouseDetailFlowLayout.h"
#import "FHNewHouseDetailSectionModel.h"
#import "FHNewHouseDetailSectionController.h"
#import <KVOController/KVOController.h>
#import "FHNewHouseDetailHeaderMediaSC.h"
#import "FHNewHouseDetailCoreInfoSC.h"
#import "FHNewHouseDetailFloorpanSC.h"
#import "FHNewHouseDetailSalesSC.h"
#import "FHNewHouseDetailAgentSC.h"
#import "FHNewHouseDetailTimelineSC.h"
#import "FHNewHouseDetailAssessSC.h"
#import "FHNewHouseDetailRGCListSC.h"
#import "FHNewHouseDetailSurroundingSC.h"
#import "FHNewHouseDetailBuildingsSC.h"
#import "FHNewHouseDetailRecommendSC.h"
#import "FHNewHouseDetailDisclaimerSC.h"
#import "FHDetailNavigationTitleView.h"
#import <FHHouseBase/FHEventShowProtocol.h>
#import <FHHouseBase/NSObject+FHOptimize.h>


@interface FHNewHouseDetailViewController () <UIGestureRecognizerDelegate, IGListAdapterDataSource, UICollectionViewDelegate, UIScrollViewDelegate>
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *source;        // 特殊标记，从哪进入的小区详情，比如地图租房列表“rent_detail”，此时小区房源展示租房列表
@property (nonatomic, copy) NSString *houseId;       // 房源id
@property (nonatomic, copy) NSString *ridcode;       // 经纪人id，用来锁定经纪人展位
@property (nonatomic, copy) NSString *realtorId;     // 经纪人id，用来锁定经纪人展位

@property (nonatomic, strong) NSDictionary *listLogPB; // 外部传入的logPB
@property (nonatomic, copy) NSString *searchId;
@property (nonatomic, copy) NSString *imprId;
@property (nonatomic, assign) BOOL isDisableGoDetail;
@property (nonatomic, strong) FHDetailContactModel *contactPhone;
@property (nonatomic, assign) CGPoint lastContentOffset;
@property (nonatomic, strong) NSDictionary *extraInfo;

@property (nonatomic, strong) FHDetailNavBar *navBar;
@property (nonatomic, strong) FHNewHouseDetailFlowLayout *detailFlowLayout;
@property (nonatomic, strong) FHBaseCollectionView *collectionView;
@property (nonatomic, strong) UIView *bottomMaskView;
@property (nonatomic, strong) FHDetailBottomBar *bottomBar;
@property (nonatomic, strong) FHDetailUGCGroupChatButton *bottomGroupChatBtn; // 新房群聊入口

@property (nonatomic) double initTimeInterval;

@property (nonatomic, strong) IGListAdapter *listAdapter;
@property (nonatomic, strong) IGListAdapterUpdater *listAdapterUpdater;

@property (nonatomic, strong) FHDetailNavigationTitleView *segmentTitleView;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;
@property (nonatomic, assign) BOOL segmentViewChangedFlag;
//是否显示
@property (nonatomic, assign) BOOL isViewDidDisapper;

@end

@implementation FHNewHouseDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
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
            NSDictionary *extraInfoDict = [(NSString *)extraInfo btd_jsonDictionary];
            self.extraInfo = extraInfoDict;
        } else if ([extraInfo isKindOfClass:[NSDictionary class]]) {
            self.extraInfo = (NSDictionary *)extraInfo;
        }

        if (!self.houseType) {
            self.houseType = FHHouseTypeNewHouse;
        }
        self.houseId = paramObj.allParams[@"court_id"];
        if (!self.houseId) {
            self.houseId = paramObj.allParams[@"house_id"];
        }

        self.ttTrackStayEnable = YES;

        // 非埋点数据处理
        // disable_go_detail
        self.isDisableGoDetail = paramObj.allParams[@"disable_go_detail"] ? paramObj.allParams[@"disable_go_detail"] : NO;
        // source
        if ([paramObj.allParams[@"source"] isKindOfClass:[NSString class]]) {
            self.source = paramObj.allParams[@"source"];
        }
        
        // 后续会构建基础埋点数据
        // 取log_pb字段数据
        id log_pb = self.tracerDict[@"log_pb"];
        if ([log_pb isKindOfClass:[NSDictionary class]]) {
            self.listLogPB = log_pb;
            self.searchId = log_pb[@"search_id"];
            self.imprId = log_pb[@"impr_id"];
        }

        if (self.houseId.length < 1) {
            [[HMDTTMonitor defaultManager] hmdTrackService:@"detail_schema_error" metric:nil category:@{ @"status" : @(1) } extra:@{ @"openurl" : paramObj.sourceURL.absoluteString }];
        } else {
            [[HMDTTMonitor defaultManager] hmdTrackService:@"detail_schema_error" metric:nil category:@{ @"status" : @(0) } extra:nil];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [self setupViewModel];
    self.isViewDidDisapper = NO;
    [self startLoadData];
    // Push推送过来的状态栏修改
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf updateStatusBar:weakSelf.collectionView.contentOffset];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.viewModel.contactViewModel refreshMessageDot];
    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isViewDidDisapper = NO;
    [self updateStatusBar:self.collectionView.contentOffset];
    [self refreshContentOffset:self.collectionView.contentOffset];
    [self.view endEditing:YES];
    [self executeOnce:^{
        [self clickTabTrackWithEnterType:@"default" sectionType:FHNewHouseDetailSectionTypeBaseInfo];
    } token:FHExecuteOnceUniqueTokenForCurrentContext];
    //    [self.viewModel vc_viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.viewModel addStayPageLog:self.ttTrackStayTime];
    [self sendCurrentPageStayTime:self.ttTrackStayTime * 1000.0];
    [self tt_resetStayTime];
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    //有些页面禁用了pan手势，但是在某些情况下比如直接push切换tab等操作 不会触发关闭当前的view，导致没有设置回来 by xsm
    if ([self.navigationController isKindOfClass:[TTNavigationController class]]) {
        TTNavigationController *naviVC = (TTNavigationController *)self.navigationController;
        naviVC.panRecognizer.enabled = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.isViewDidDisapper = YES;
    //    [self.viewModel vc_viewDidDisappear:animated];
}

#pragma mark - Setup UI
- (IGListAdapterUpdater *)listAdapterUpdater
{
    if (!_listAdapterUpdater) {
        _listAdapterUpdater = [[IGListAdapterUpdater alloc] init];
    }
    return _listAdapterUpdater;
}

- (void)setupUI
{
    self.detailFlowLayout = [[FHNewHouseDetailFlowLayout alloc] init];
    self.collectionView = [[FHBaseCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.detailFlowLayout];
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    UITapGestureRecognizer *tapGesturRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapGesturRecognizer.cancelsTouchesInView = NO;
    tapGesturRecognizer.delegate = self;
    [self.collectionView addGestureRecognizer:tapGesturRecognizer];
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.collectionView.backgroundColor = [UIColor themeGray7];
    self.view.backgroundColor = self.collectionView.backgroundColor;
    [self.view addSubview:self.collectionView];

    self.listAdapter = [[IGListAdapter alloc] initWithUpdater:self.listAdapterUpdater viewController:self workingRangeSize:5];
    self.listAdapter.collectionView = self.collectionView;
    self.listAdapter.dataSource = self;
    self.listAdapter.scrollViewDelegate = self;
    self.listAdapter.collectionViewDelegate = self;

    __weak typeof(self) weakSelf = self;
    _navBar = [[FHDetailNavBar alloc] initWithType:FHDetailNavBarTypeDefault];
    [_navBar removeBottomLine];
    _navBar.backActionBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    [self.view addSubview:_navBar];

    self.bottomMaskView = [[UIView alloc] init];
    self.bottomMaskView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bottomMaskView];
    self.bottomMaskView.hidden = YES;

    self.bottomBar = [[FHOldDetailBottomBarView alloc] initWithFrame:CGRectZero];

    [self.view addSubview:_bottomBar];
    
    _bottomBar.hidden = YES;

    self.bottomGroupChatBtn = [[FHDetailUGCGroupChatButton alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_bottomGroupChatBtn];
    self.bottomBar.bottomGroupChatBtn = _bottomGroupChatBtn; // 这样子改动最小
    _bottomGroupChatBtn.hidden = YES;

    [self addDefaultEmptyViewFullScreen];

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.bottomBar.mas_top);
    }];
    [_bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(self.houseType == FHHouseTypeRentHouse ? 64 : 80);
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom);
        } else {
            make.bottom.mas_equalTo(self.view);
        }
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
    
    self.segmentTitleView = [[FHDetailNavigationTitleView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navBar.frame), CGRectGetWidth(self.view.bounds), 42)];
    self.segmentTitleView.backgroundColor = [UIColor whiteColor];
    self.segmentTitleView.alpha = 0;
    self.segmentTitleView.seperatorLine.hidden = NO;
    [self.segmentTitleView setCurrentIndexBlock:^(NSInteger currentIndex) {
        [weakSelf scrollToCurrentIndex:currentIndex];
    }];
    [self.view addSubview:self.segmentTitleView];
    [self.segmentTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(42);
        make.top.mas_equalTo(self.navBar.mas_bottom);
    }];
    [self.segmentTitleView reloadData];
    self.segmentTitleView.selectIndex = 0;
}

- (void)setupViewModel {
    self.viewModel = [[FHNewHouseDetailViewModel alloc] init];
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
    self.viewModel.houseType = self.houseType;
        
    self.viewModel.contactViewModel = [[FHHouseDetailContactViewModel alloc] initWithNavBar:_navBar bottomBar:_bottomBar houseType:_houseType houseId:_houseId];
    self.viewModel.contactViewModel.searchId = self.searchId;
    self.viewModel.contactViewModel.imprId = self.imprId;
    self.viewModel.contactViewModel.tracerDict = [self makeDetailTracerData];
    self.viewModel.contactViewModel.belongsVC = self;
    self.viewModel.contactViewModel.houseInfoOriginBizTrace = self.bizTrace;
    
    if (self.tracerDict[@"event_tracking_id"] && [self.tracerDict[@"event_tracking_id"] isKindOfClass:[NSString class]]) {
        self.viewModel.trackingId = self.tracerDict[@"event_tracking_id"];
    }
    if (!self.isDisableGoDetail) {
        [self.viewModel addGoDetailLog];
    }
    __weak typeof(self) weakSelf = self;
    [self.viewModel setUpdateLayout:^{
        if (!weakSelf) {
            return;
        }
        [weakSelf updateLayout];
    }];
    [self.KVOController observe:self.viewModel
                        keyPath:@"sectionModels"
                        options:NSKeyValueObservingOptionNew
                          block:^(id _Nullable observer, id _Nonnull object, NSDictionary<NSString *, id> *_Nonnull change) {
        if (!weakSelf) {
            return;
        }
        if (change[NSKeyValueChangeNewKey] && [change[NSKeyValueChangeNewKey] isKindOfClass:[NSArray class]]) {
            [weakSelf sectionModelsDidUpdate];
        }
    }];

    [self.KVOController observe:self.viewModel keyPath:@"isShowEmpty" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        if (!weakSelf) {
            return;
        }
        if (change[NSKeyValueChangeNewKey] && [change[NSKeyValueChangeNewKey] isKindOfClass:[NSNumber class]]) {
            BOOL isShowEmpty = [(NSNumber *)change[NSKeyValueChangeNewKey] boolValue];
            [weakSelf reloadSubViewStatus:isShowEmpty];
        }
    }];
}

- (void)reloadSubViewStatus:(BOOL )isShowEmpty {
    if (isShowEmpty) {
        self.isLoadingData = NO;
        self.hasValidateData = NO;
        self.bottomBar.hidden = YES;
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
    } else {
        self.hasValidateData = YES;
        self.bottomBar.hidden = NO;
        [self.emptyView hideEmptyView];
        [self.navBar showMessageNumber];
    }
}

- (void)sectionModelsDidUpdate {
    
    NSMutableArray *titles = [NSMutableArray array];
    NSArray *sectionModels = self.viewModel.sectionModels.copy;
    for (FHNewHouseDetailSectionModel *model in sectionModels) {
        switch (model.sectionType) {
            case FHNewHouseDetailSectionTypeHeader:
                
                break;
            case FHNewHouseDetailSectionTypeBaseInfo:
                [titles addObject:@"基础信息"];
                break;
            case FHNewHouseDetailSectionTypeFloorpan:
                [titles addObject:@"户型"];
                break;
            case FHNewHouseDetailSectionTypeSales:
            case FHNewHouseDetailSectionTypeAgent:
                if ([titles containsObject:@"优惠"]) {
                    continue;
                }
                [titles addObject:@"优惠"];
                break;
            case FHNewHouseDetailSectionTypeTimeline:
            case FHNewHouseDetailSectionTypeAssess:
            case FHNewHouseDetailSectionTypeRGC:
                if ([titles containsObject:@"动态"]) {
                    continue;
                }
                [titles addObject:@"动态"];
                break;
            case FHNewHouseDetailSectionTypeSurrounding:
                [titles addObject:@"周边"];
                break;
            case FHNewHouseDetailSectionTypeBuildings:
                [titles addObject:@"楼栋"];
                break;
            case FHNewHouseDetailSectionTypeRecommend:
                [titles addObject:@"推荐"];
                break;
            case FHNewHouseDetailSectionTypeDisclaimer:
                break;
            default:
                break;
        }
    }
    
    self.segmentTitleView.titleNames = titles.copy;
    [self.segmentTitleView reloadData];
    if (self.segmentTitleView.selectIndex == 0) {
        self.segmentTitleView.selectIndex = 0;
    }
    
    self.detailFlowLayout.sectionModels = sectionModels;
    [self.listAdapter performUpdatesAnimated:NO
                                      completion:^(BOOL finished) {
    }];
}


- (void)scrollToCurrentIndex:(NSInteger )toIndex {
    NSString *title = self.segmentTitleView.titleNames[toIndex];
    NSArray *sectionModels = self.viewModel.sectionModels.copy;
    __block NSUInteger index = NSNotFound;
    [sectionModels enumerateObjectsUsingBlock:^(FHNewHouseDetailSectionModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([title isEqualToString:@"基础信息"]) {
            if (model.sectionType == FHNewHouseDetailSectionTypeBaseInfo) {
                index = idx;
                *stop = YES;
            }
        }
        if ([title isEqualToString:@"户型"]) {
            if (model.sectionType == FHNewHouseDetailSectionTypeFloorpan) {
                index = idx;
                *stop = YES;
            }
        }
        if ([title isEqualToString:@"优惠"]) {
            if (model.sectionType == FHNewHouseDetailSectionTypeSales || model.sectionType == FHNewHouseDetailSectionTypeAgent) {
                index = idx;
                *stop = YES;
            }
        }
        if ([title isEqualToString:@"动态"]) {
            if (model.sectionType == FHNewHouseDetailSectionTypeTimeline|| model.sectionType == FHNewHouseDetailSectionTypeAssess || model.sectionType == FHNewHouseDetailSectionTypeRGC) {
                index = idx;
                *stop = YES;
            }
        }
        if ([title isEqualToString:@"周边"]) {
            if (model.sectionType == FHNewHouseDetailSectionTypeSurrounding) {
                index = idx;
                *stop = YES;
            }
        }
        if ([title isEqualToString:@"楼栋"]) {
            if (model.sectionType == FHNewHouseDetailSectionTypeBuildings) {
                index = idx;
                *stop = YES;
            }
        }
        if ([title isEqualToString:@"推荐"]) {
            if (model.sectionType == FHNewHouseDetailSectionTypeRecommend) {
                index = idx;
                *stop = YES;
            }
        }
    }];
    if (index == NSNotFound) {
        return;
    }
    self.lastIndexPath = [NSIndexPath indexPathForItem:0 inSection:index];
    FHNewHouseDetailSectionModel *model = sectionModels[index];
    [self clickTabTrackWithEnterType:@"click" sectionType:model.sectionType];
    UICollectionViewLayoutAttributes *attributes = [self.detailFlowLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:self.lastIndexPath];
    if (attributes.frame.size.height < 0.1) {
        attributes = [self.detailFlowLayout layoutAttributesForItemAtIndexPath:self.lastIndexPath];
//        attributes = [self.collectionView layoutAttributesForItemAtIndexPath:self.lastIndexPath];
    }
    
    CGRect frame = attributes.frame;
    //section header frame
    //需要滚到到顶部，如果滚动的距离超过contengsize，则滚动到底部
    CGPoint contentOffset = self.collectionView.contentOffset;
    contentOffset.y = frame.origin.y - (self.navBar.btd_height + self.segmentTitleView.btd_height);
    if (contentOffset.y + CGRectGetHeight(self.collectionView.frame) > (self.collectionView.contentSize.height + self.collectionView.contentInset.bottom)) {
        contentOffset.y = self.collectionView.contentSize.height - CGRectGetHeight(self.collectionView.frame) + self.collectionView.contentInset.bottom;
    }
    //防止向上滑动
    if (contentOffset.y < 0) {
        contentOffset.y = 0;
    }
    if (index == 1) {
        contentOffset.y = 0;
    }
//    [self.collectionView scrollToItemAtIndexPath:_lastIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
//    [self.collectionView setContentOffset:contentOffset];
    self.segmentViewChangedFlag = YES;
    [UIView animateWithDuration:0.2 animations:^{
        [self.collectionView setContentOffset:contentOffset animated:NO];
    } completion:^(BOOL finished) {
        self.segmentViewChangedFlag = NO;
    }];

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
    self.segmentTitleView.alpha = alpha;

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
        [[UIApplication sharedApplication] setStatusBarStyle:style];
    }
}

- (void)updateLayout
{
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.bottomBar.mas_top);
    }];
    self.bottomBar.hidden = NO;
    self.bottomMaskView.hidden = NO;
    [self.view sendSubviewToBack:self.collectionView];
    [self.view setNeedsUpdateConstraints];
}

- (UIView *)getNaviBar
{
    return self.navBar;
}

- (UIView *)getBottomBar
{
    return self.bottomBar;
}

#pragma mark - Request
- (void)startLoadData
{
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
- (void)retryLoadData
{
    if (!self.isLoadingData) {
        [self startLoadData];
    }
}

#pragma mark - Method
// page_type
- (NSString *)pageTypeString
{
    return @"new_detail";
}

// 构建详情页基础埋点数据
- (NSMutableDictionary *)makeDetailTracerData
{
    NSMutableDictionary *detailTracerDic = [NSMutableDictionary new];
    detailTracerDic[@"page_type"] = [self pageTypeString];
    detailTracerDic[@"card_type"] = self.tracerDict[@"card_type"] ?: @"be_null";
    detailTracerDic[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    detailTracerDic[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    detailTracerDic[@"rank"] = self.tracerDict[@"rank"] ?: @"be_null";
    detailTracerDic[@"origin_from"] = self.tracerDict[@"origin_from"] ?: @"be_null";
    detailTracerDic[@"origin_search_id"] = self.tracerDict[@"origin_search_id"] ?: @"be_null";
    detailTracerDic[@"log_pb"] = self.tracerDict[@"log_pb"] ?: @{};
    detailTracerDic[@"from_gid"] = self.tracerDict[@"from_gid"];
    // 以下3个参数都在:log_pb中
    // group_id
    // impr_id
    // search_id
    // 比如：element_show中添加："element_type": "trade_tips"
    // house_show 修改 rank、log_pb 等字段
    return detailTracerDic;
}

- (void)tapAction:(id)tap
{
    [self.collectionView endEditing:YES];
}

#pragma mark - TTUIViewControllerTrackProtocol
- (void)trackEndedByAppWillEnterBackground
{
    [self.viewModel addStayPageLog:self.ttTrackStayTime * 1000.0];
    [self trySendCurrentPageStayTime];
}

- (void)trackStartedByAppWillEnterForground
{
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
    } else {
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

- (void)trySendCurrentPageStayTime
{
    if (self.ttTrackStartTime == 0) { //当前页面没有在展示过
        return;
    }
    double duration = self.ttTrackStayTime * 1000.0;
    if (duration <= 200) { //低于200毫秒，忽略
        self.ttTrackStartTime = 0;
        [self tt_resetStayTime];
        return;
    }
    [self sendCurrentPageStayTime:duration];

    self.ttTrackStartTime = 0;
    [self tt_resetStayTime];
}

#pragma mark - for keyboard show
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        [self.view endEditing:YES];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer.view isKindOfClass:[UITextField class]] || [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]) {
        return NO;
    }
    return YES;
}

#pragma mark 监听返回

- (void)goBack
{
    UIViewController *popVC = [self.navigationController popViewControllerAnimated:YES];
    if (nil == popVC) {
        [self dismissViewControllerAnimated:YES
                                 completion:^ {

                                 }];
    }
}

- (void)updateLoadFinish
{
    [self.viewModel.contactViewModel updateLoadFinish];
}

#pragma mark - IGListAdapterDataSource

/**
 Asks the data source for the objects to display in the list.

 @param listAdapter The list adapter requesting this information.

 @return An array of objects for the list.
 */
- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter
{
    return self.viewModel.sectionModels.copy;
}

/**
 Asks the data source for a section controller for the specified object in the list.

 @param listAdapter The list adapter requesting this information.
 @param object An object in the list.

 @return A new section controller instance that can be displayed in the list.

 @note New section controllers should be initialized here for objects when asked. You may pass any other data to
 the section controller at this time.

 Section controllers are initialized for all objects whenever the `IGListAdapter` is created, updated, or reloaded.
 Section controllers are reused when objects are moved or updated. Maintaining the `-[IGListDiffable diffIdentifier]`
 guarantees this.
 */
- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object
{
    if (object && [object isKindOfClass:[FHNewHouseDetailSectionModel class]]) {
        FHNewHouseDetailSectionModel *sectionModel = (FHNewHouseDetailSectionModel *)object;
        switch (sectionModel.sectionType) {
            case FHNewHouseDetailSectionTypeHeader:
                return [[FHNewHouseDetailHeaderMediaSC alloc] init];
                break;
            case FHNewHouseDetailSectionTypeBaseInfo:
                return [[FHNewHouseDetailCoreInfoSC alloc] init];
                break;
            case FHNewHouseDetailSectionTypeFloorpan:
                return [[FHNewHouseDetailFloorpanSC alloc] init];
                break;
            case FHNewHouseDetailSectionTypeSales:
                return [[FHNewHouseDetailSalesSC alloc] init];
                break;
            case FHNewHouseDetailSectionTypeAgent:
                return [[FHNewHouseDetailAgentSC alloc] init];
                break;
            case FHNewHouseDetailSectionTypeTimeline:
                return [[FHNewHouseDetailTimelineSC alloc] init];
                break;
            case FHNewHouseDetailSectionTypeAssess:
                return [[FHNewHouseDetailAssessSC alloc] init];
                break;
            case FHNewHouseDetailSectionTypeRGC:
                return [[FHNewHouseDetailRGCListSC alloc] init];
                break;
            case FHNewHouseDetailSectionTypeSurrounding:
                return [[FHNewHouseDetailSurroundingSC alloc] init];
                break;
            case FHNewHouseDetailSectionTypeBuildings:
                return [[FHNewHouseDetailBuildingsSC alloc] init];
                break;
            case FHNewHouseDetailSectionTypeRecommend:
                return [[FHNewHouseDetailRecommendSC alloc] init];
                break;
            case FHNewHouseDetailSectionTypeDisclaimer:
                return [[FHNewHouseDetailDisclaimerSC alloc] init];
            default:
                break;
        }
    }
    return [[FHNewHouseDetailSectionController alloc] init];
}

/**
 Asks the data source for a view to use as the collection view background when the list is empty.

 @param listAdapter The list adapter requesting this information.

 @return A view to use as the collection view background, or `nil` if you don't want a background view.

 @note This method is called every time the list adapter is updated. You are free to return new views every time,
 but for performance reasons you may want to retain the view and return it here. The infra is only responsible for
 adding the background view and maintaining its visibility.
 */
- (nullable UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter
{
    return nil;
}

#pragma mark - UICollectionViewDelegate
- (NSMutableDictionary *)elementShowCaches {
    if (!_elementShowCaches) {
        _elementShowCaches = [NSMutableDictionary dictionary];
    }
    return _elementShowCaches;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tempKey = [NSString stringWithFormat:@"%@_%ld",NSStringFromClass([cell class]), (long)indexPath.section];
    if (self.elementShowCaches[tempKey]) {
        return;
    }
    self.elementShowCaches[tempKey] = @(YES);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([cell conformsToProtocol:@protocol(FHEventShowProtocol)]) {
            UICollectionViewCell<FHEventShowProtocol> *showCell = (UICollectionViewCell<FHEventShowProtocol> *)cell;
            if ([showCell respondsToSelector:@selector(elementType)]) {
                [self trackElementType:[showCell elementType]];
            } else if ([showCell respondsToSelector:@selector(elementTypes)]) {
                NSArray *elementArray = [showCell elementTypes];
                for (NSString *elementType in elementArray) {
                    [self trackElementType:elementType];
                }
            }
        }
    });
}

- (void)clickTabTrackWithEnterType:(NSString *)enterType sectionType:(FHNewHouseDetailSectionType)sectionType {
    switch (sectionType) {
        case FHNewHouseDetailSectionTypeHeader:
        case FHNewHouseDetailSectionTypeDisclaimer:
            return;
        default:
            break;
    }
    NSMutableDictionary *tracerDic = [[NSMutableDictionary alloc] init];
    tracerDic[@"event_tracking_id"] = @"107645";
    tracerDic[@"event_type"] = @"house_app2c_v2";
    tracerDic[@"enter_type"] = enterType;
    tracerDic[@"tab_name"] = [self getTabNameBySectionType:sectionType];
    tracerDic[@"page_type"] = [self pageTypeString];
    [FHUserTracker writeEvent:@"click_tab" params:tracerDic];
}

- (void)trackElementType:(NSString *)elementType
{
    if (elementType.length) {
        NSMutableDictionary *tracerDic = self.tracerDict.mutableCopy;
        tracerDic[@"element_type"] = elementType;
        [tracerDic removeObjectForKey:@"element_from"];
        tracerDic[@"page_type"] = [self pageTypeString];
        [FHUserTracker writeEvent:@"element_show" params:tracerDic];
    }
}

- (NSString *)getTabNameBySectionType:(FHNewHouseDetailSectionType)sectionType {
    switch (sectionType) {
        case FHNewHouseDetailSectionTypeBaseInfo:
            return @"基础信息";
        case FHNewHouseDetailSectionTypeFloorpan:
            return @"户型";
        case FHNewHouseDetailSectionTypeSales:
        case FHNewHouseDetailSectionTypeAgent:
            return @"优惠";
        case FHNewHouseDetailSectionTypeTimeline:
        case FHNewHouseDetailSectionTypeAssess:
        case FHNewHouseDetailSectionTypeRGC:
            return @"动态";
        case FHNewHouseDetailSectionTypeSurrounding:
            return @"周边";
        case FHNewHouseDetailSectionTypeBuildings:
            return @"楼栋";
        case FHNewHouseDetailSectionTypeRecommend:
            return @"推荐";
        default:
            return @"";
    }
    return @"";
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self refreshContentOffset:scrollView.contentOffset];
    if (self.segmentViewChangedFlag) {
        return;
    }
    //locate the scrollview which is in the centre
    CGPoint centerPoint = CGPointMake(20, scrollView.contentOffset.y + self.navBar.btd_height + self.segmentTitleView.btd_height);
    NSArray *attributesArray = [self.detailFlowLayout layoutAttributesForElementsInRect:CGRectMake(centerPoint.x, centerPoint.y, 1, 1)];
    UICollectionViewLayoutAttributes *attributes = attributesArray.firstObject;
    NSIndexPath *indexPath = attributes.indexPath;
    NSArray *sectionModels = self.viewModel.sectionModels.copy;
    if (indexPath && self.lastIndexPath.section != indexPath.section) {
        self.lastIndexPath = indexPath;
        if (indexPath.section >= sectionModels.count) {
            return;
        }
        FHNewHouseDetailSectionModel *model = sectionModels[indexPath.section];
        NSString *title = @"";
        switch (model.sectionType) {
            case FHNewHouseDetailSectionTypeHeader:
                break;
            case FHNewHouseDetailSectionTypeBaseInfo:
                title = @"基础信息";
                break;
            case FHNewHouseDetailSectionTypeFloorpan:
                title = @"户型";
                break;
            case FHNewHouseDetailSectionTypeSales:
            case FHNewHouseDetailSectionTypeAgent:
                title = @"优惠";
                break;
            case FHNewHouseDetailSectionTypeTimeline:
            case FHNewHouseDetailSectionTypeAssess:
            case FHNewHouseDetailSectionTypeRGC:
                title = @"动态";
                break;
            case FHNewHouseDetailSectionTypeSurrounding:
                title = @"周边";
                break;
            case FHNewHouseDetailSectionTypeBuildings:
                title = @"楼栋";
                break;
            case FHNewHouseDetailSectionTypeRecommend:
                title = @"推荐";
                break;
            case FHNewHouseDetailSectionTypeDisclaimer:
                break;
            default:
                break;
        }
        NSUInteger selectIndex = [self.segmentTitleView.titleNames indexOfObject:title];
        if (selectIndex < self.segmentTitleView.titleNames.count) {
            if (self.segmentTitleView) {
                self.segmentTitleView.selectIndex = selectIndex;
            }
        }
    }
}

@end
