//
//  FHHouseListViewController.m
//  FHHouseList
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHHouseListViewController.h"
#import "TTRoute.h"
#import "Masonry.h"
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
#import <FHHouseBase/FHHouseBridgeManager.h>
#import "FHFakeInputNavbar.h"
#import "UIViewAdditions.h"
#import <TTUIWidget/ArticleListNotifyBarView.h>
#import "FHTracerModel.h"
#import "FHErrorMaskView.h"
#import "FHHouseListViewModel.h"
#import "NSDictionary+TTAdditions.h"
#import "FHConditionFilterViewModel.h"
#import "HMDTTMonitor.h"
#import "FHEnvContext.h"
#import <BDTrackerProtocol/BDTrackerProtocol.h>
#import "FHHouseListCommuteTipView.h"
#import "FHCommuteFilterView.h"
#import "FHCommuteManager.h"
#import <FHHouseBase/FHBaseTableView.h>
#import "FHMainOldTopTagsView.h"
#import "TTNavigationController.h"
#import <ByteDanceKit/ByteDanceKit.h>
#import "FHHouseListErrorView.h"
#import "FHHouseTableView.h"
#import "FHHouseCardUtils.h"

#define kFilterBarHeight 44
#define COMMUTE_TOP_MARGIN 6
#define COMMUTE_HEIGHT     42
#define kFilterTagsViewHeight 40

@interface FHHouseListViewController ()<TTRouteInitializeProtocol, FHHouseListViewModelDelegate>

@property (nonatomic , strong) FHFakeInputNavbar *navbar;
@property (nonatomic , strong) FHHouseListCommuteTipView *commuteTipView;
@property (nonatomic , strong) UIControl *commuteChooseBgView;
@property (nonatomic , strong) FHCommuteFilterView *commuteFilterView;

@property (nonatomic , strong) UIView *containerView;
@property (nonatomic , strong) UITableView* tableView;

@property (nonatomic , strong) UIView *filterContainerView;
@property (nonatomic , strong) UIView *filterPanel;

@property (nonatomic , strong) UIControl *filterBgControl;
@property (nonatomic , strong) FHConditionFilterViewModel *houseFilterViewModel;
@property (nonatomic , strong) id<FHHouseFilterBridge> houseFilterBridge;

@property (nonatomic , strong) ArticleListNotifyBarView *notifyBarView;

@property (nonatomic , strong) FHErrorView *errorMaskView;

@property (nonatomic , strong) FHHouseListViewModel *viewModel;

@property (nonatomic , assign) FHHouseType houseType;
@property (nonatomic , strong) TTRouteParamObj *paramObj;

@property (nonatomic , copy) NSString *associationalWord;// 联想词
@property (nonatomic , copy) NSString *suggestionParams; // sug
@property (nonatomic , copy) NSString *queryString;

@property (nonatomic , assign) FHHouseListSearchType searchType;
@property(nonatomic , strong) FHMainOldTopTagsView *topTagsView;
@property(nonatomic , strong) UIView *bottomLine;

@end

@implementation FHHouseListViewController

- (UIView *)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor themeGray6];
    }
    return _bottomLine;
}

-(instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
        //init coordinate viewmodel according to viewmodel
        self.paramObj = paramObj;
        self.hidesBottomBarWhenPushed = YES;
        self.searchType = FHHouseListSearchTypeDefault;

        NSString *houseTypeStr = paramObj.allParams[@"house_type"];
        self.houseType = houseTypeStr.length > 0 ? houseTypeStr.integerValue : FHHouseTypeSecondHandHouse;
        if (houseTypeStr.length == 0 && [paramObj.sourceURL.host isEqualToString:@"commute_list"]) {
            self.houseType = FHHouseTypeRentHouse;
        }
        if (self.houseType <= 0 || self.houseType > 4) {
            // 目前4种房源：1，2，3，4
            NSString *res = [NSString stringWithFormat:@"%ld",self.houseType];
            // device_id
            NSString *did = [BDTrackerProtocol deviceID];
            if (did.length == 0) {
                did = @"null";
            }
            [[HMDTTMonitor defaultManager] hmdTrackService:@"house_list_house_type_error"
                                                    metric:nil
                                                  category:@{@"status":@(0),@"house_type":res}
                                                     extra:@{@"device_id":did}];
            self.houseType = FHHouseTypeSecondHandHouse;
        }
        if ([paramObj.host isEqualToString:@"neighborhood_deal_list"]) {
            self.houseType = FHHouseTypeNeighborhood;
            self.searchType = FHHouseListSearchTypeNeighborhoodDeal;
        }
        self.tracerModel.categoryName = [self categoryName];
//        NSDictionary *sugDict = [paramObj.userInfo.allInfo btd_dictionaryValueForKey:@"sugParams"];
//        self.associationalWord = [sugDict tt_stringValueForKey:@"associateWord"];
//        self.suggestionParams = [sugDict tt_stringValueForKey:@"sug"];
        
        self.associationalWord = [self placeholderByHouseType:self.houseType];
        NSString *fullText = paramObj.queryParams[@"full_text"];
        NSString *displayText = paramObj.queryParams[@"display_text"];
        if (fullText.length > 0) {
            
            self.associationalWord = fullText;
        }else if (displayText.length > 0) {
            
            self.associationalWord = displayText;
        }
        self.ttTrackStayEnable = YES;
        self.ttHideNavigationBar = YES;
    }
    return self;
}

-(NSString *)categoryName
{
    return [self.viewModel categoryName];
}

-(NSString *)placeholderByHouseType:(FHHouseType)houseType {
    
    switch (houseType) {
        case FHHouseTypeNewHouse:
            return @"请输入楼盘名/地址";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"请输入小区/商圈/地铁";
            break;
        case FHHouseTypeNeighborhood:
            return @"请输入小区/商圈/地铁";
            break;
        case FHHouseTypeRentHouse:
            return @"请输入小区/商圈/地铁";
            break;
        default:
            return @"";
            break;
    }
}

-(void)initNavbar
{
    FHFakeInputNavbarType type = FHFakeInputNavbarTypeDefault;
    if (self.houseType == FHHouseTypeSecondHandHouse) {
        type = FHFakeInputNavbarTypeMap;
    }
    // FHFakeInputNavbarTypeMessageAndMap 二手房列表页显示消息和小红点
    if (self.houseType == FHHouseTypeSecondHandHouse || self.houseType == FHHouseTypeRentHouse) {
        type = FHFakeInputNavbarTypeMessageAndMap;
    }
    
    if ( self.houseType == FHHouseTypeNewHouse || self.houseType == FHHouseTypeNeighborhood) {
        type = FHFakeInputNavbarTypeMessageSingle;
    }
    
    if ([self.paramObj.sourceURL.host rangeOfString:@"commute_list"].location != NSNotFound) {
        //通勤找房不显示地图
        type = FHFakeInputNavbarTypeDefault;
    }
    
    _navbar = [[FHFakeInputNavbar alloc] initWithType:type];
    _navbar.style = FHFakeInputNavbarStyleBorder;
    [_navbar refreshAlpha:1];
    if (self.associationalWord.length > 0) {
        
        _navbar.placeHolder = self.associationalWord;
    }else {
        
        _navbar.placeHolder = [self placeholderByHouseType:self.houseType];
    }

    __weak typeof(self) wself = self;
    _navbar.defaultBackAction = ^{
        [wself.navigationController popViewControllerAnimated:YES];
    };
    _navbar.showMapAction = ^{
        [wself.viewModel showMapSearch];
    };
    _navbar.messageActionBlock = ^{
        [wself.viewModel showMessageList];
    };

    _navbar.tapInputBar = ^{
        [wself.viewModel showInputSearch];
    };
    
}

-(void)initFilter
{
    id<FHHouseFilterBridge> bridge = [[FHHouseBridgeManager sharedInstance] filterBridge];
    self.houseFilterBridge = bridge;
    
    self.houseFilterViewModel = [bridge filterViewModelWithType:self.houseType showAllCondition:YES showSort:YES];
    self.filterPanel = [bridge filterPannel:self.houseFilterViewModel];
    self.filterBgControl = [bridge filterBgView:self.houseFilterViewModel];
    
    [self.houseFilterViewModel setFilterConditions:self.paramObj.queryParams];
    
    self.viewModel.viewModelDelegate = self;
    [bridge setViewModel:self.houseFilterViewModel withDelegate:self.viewModel];
    
    [bridge showBottomLine:YES];
    [self.filterBgControl addSubview:self.bottomLine];
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo([UIDevice btd_onePixel]);
    }];
//    if (!self.viewModel.isCommute) {
//        //非通勤找房下才显示分隔线
//        UIView *bottomLine = [[UIView alloc] init];
//        bottomLine.backgroundColor = [UIColor themeGray6];
//        [self.filterPanel addSubview:bottomLine];
//        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.and.right.and.bottom.mas_equalTo(self.filterPanel);
//            make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
//        }];
//    }


}

-(void)initCommuteTip
{
    _commuteTipView = [[FHHouseListCommuteTipView alloc] init];
    __weak typeof(self) wself = self;
    _commuteTipView.changeOrHideBlock = ^(BOOL showHide) {
        if (showHide) {
            [wself.viewModel addModifyCommuteLog:NO];
            wself.commuteChooseBgView.hidden = YES;
        }else{
            FHCommuteManager *manager = [FHCommuteManager sharedInstance];
            [wself.commuteFilterView updateType:manager.commuteType time:manager.duration];
            [wself.view bringSubviewToFront:wself.commuteChooseBgView];
            [wself.commuteChooseBgView addSubview:wself.commuteFilterView];
            wself.commuteChooseBgView.hidden = NO;
            [wself.viewModel addModifyCommuteLog:YES];
            [wself.houseFilterBridge closeConditionFilterPanel];
        }
        wself.commuteTipView.showHide = !showHide;
    };
    
    [self updateCommuteTip];
    
    FHCommuteManager *manager = [FHCommuteManager sharedInstance];
    [self.commuteFilterView updateType:manager.commuteType time:manager.duration];
    
    _commuteChooseBgView = [[UIControl alloc] init];
    _commuteChooseBgView.backgroundColor =  RGBA(0, 0, 0, 0.4);
    _commuteChooseBgView.hidden = YES;
    [_commuteChooseBgView addTarget:self action:@selector(onCommuteBgTap) forControlEvents:UIControlEventTouchUpInside];
}

-(FHCommuteFilterView *)commuteFilterView
{
    if (!_commuteFilterView) {
        FHCommuteType type = [[FHCommuteManager sharedInstance] commuteType];
        if (type < 0) {
            type = FHCommuteTypeDrive;
        }
        _commuteFilterView = [[FHCommuteFilterView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 298) insets:UIEdgeInsetsMake(20, 0,  20, 0) type:type];
        __weak typeof(self) wself = self;
        _commuteFilterView.chooseBlock = ^(NSString * _Nonnull time, FHCommuteType type) {
            FHCommuteManager *manager = [FHCommuteManager sharedInstance];
            if (!([time isEqualToString:manager.duration] && type == manager.commuteType)) {
                //选择发送改变
                manager.duration = time;
                manager.commuteType = type;
                [manager sync];
                [wself updateCommuteTip];
                [wself.viewModel commuteFilterUpdated];
            }
            
            [wself onCommuteBgTap];
        };
    }
    return _commuteFilterView;
    
}

-(void)updateCommuteTip
{
    FHCommuteManager *manager = [FHCommuteManager sharedInstance];
    NSString *tip = [NSString stringWithFormat:@"通过%@%@分钟内到达",[manager commuteTypeName],manager.duration];
    BOOL highlight = manager.commuteType != FHCommuteTypeWalk && manager.commuteType != FHCommuteTypeRide;
    NSString *time = nil;
    if (highlight) {
        time = @"早高峰";
        tip = [@" " stringByAppendingString:tip];
    }
    [_commuteTipView updateTime:time tip:tip highlightTime:highlight];
    
}

-(void)onCommuteBgTap
{
    self.commuteTipView.showHide = NO;
    self.commuteChooseBgView.hidden = YES;
    
    [self.viewModel addModifyCommuteLog:NO];
}


-(void)setupViewModelBlock {
    
    __weak typeof(self) wself = self;
    _viewModel.conditionNoneFilterBlock = ^NSString * _Nullable(NSDictionary * _Nonnull params) {
        return [wself.houseFilterBridge getNoneFilterQueryParams:params];
    };
    
    _viewModel.closeConditionFilter = ^{
        [wself.houseFilterBridge closeConditionFilterPanel];
        [wself onCommuteBgTap];
    };
    
    _viewModel.clearSortCondition = ^{
        [wself.houseFilterBridge clearSortCondition];
    };
    
    _viewModel.getConditions = ^NSString * _Nonnull{
        return [wself.houseFilterBridge getConditions];
    };
    _viewModel.setConditionsBlock = ^(NSDictionary * _Nonnull params) {
        
        [wself.houseFilterBridge setFilterConditions:params];
        [wself.houseFilterBridge trigerConditionChanged];
    };
    _viewModel.getAllQueryString = ^NSString * _Nonnull{
        
        return [wself.houseFilterBridge getAllQueryString];
    };
    _viewModel.getSortTypeString = ^NSString * _Nullable {
        if ([wself.houseFilterViewModel isLastSearchBySort]) {
            return [wself.houseFilterViewModel sortType] ? : @"default";
        }
        return nil;
    };
    _viewModel.sugSelectBlock = ^(TTRouteParamObj * _Nonnull paramObj) {
        
        [wself handleSugSelection:paramObj];
    };
    _viewModel.houseListOpenUrlUpdateBlock = ^(TTRouteParamObj * _Nonnull paramObj, BOOL isFromMap) {
        
        [wself handleListOpenUrlUpdate:paramObj];
        if (isFromMap) {
            [wself.houseFilterViewModel trigerConditionChanged];
        }
    };
    
    _viewModel.showNotify = ^(NSString * _Nonnull message) {
        //        [wself showNotify:message];
    };
    
    _viewModel.commuteSugSelectBlock = ^(NSString * _Nonnull poi) {
      
        [wself refreshNavBar:wself.houseType placeholder:nil inputText:poi];
    };
    
}

-(void)resetFilter:(TTRouteParamObj *)paramObj {

    [_filterBgControl removeFromSuperview];
    [self.filterContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self initFilter];
    
    [self.view addSubview:self.filterBgControl];
    [self.filterContainerView addSubview:self.filterPanel];
    
    [self.filterBgControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.containerView);
        make.top.mas_equalTo(self.filterContainerView.mas_bottom);
    }];
    
    [self.filterPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.filterContainerView);
    }];
    

    self.viewModel.houseType = self.houseType;
    [self.houseFilterViewModel setFilterConditions:paramObj.queryParams];
    [self.houseFilterBridge setViewModel:self.houseFilterViewModel withDelegate:self.viewModel];

    
}
#pragma mark 处理sug带回的houseType，导航栏placeholder，筛选器
-(void)handleListOpenUrlUpdate:(TTRouteParamObj *)paramObj {

    NSString *placeholder = [self placeholderByHouseType:self.houseType];
    NSString *fullText = paramObj.queryParams[@"full_text"];
    NSString *displayText = paramObj.queryParams[@"display_text"];
    
    if (fullText.length > 0) {
        
        placeholder = fullText;
    }else if (displayText.length > 0) {
        
        placeholder = displayText;
    }
    [self refreshNavBar:self.houseType placeholder:placeholder inputText:nil];
    
    [self.houseFilterBridge setFilterConditions:paramObj.queryParams];
    if (self.topTagsView && paramObj.queryParams) {
        self.topTagsView.lastConditionDic = [NSMutableDictionary dictionaryWithDictionary:paramObj.queryParams];
    }
}
-(void)handleSugSelection:(TTRouteParamObj *)paramObj {
    
    NSString *houseTypeStr = paramObj.allParams[@"house_type"];
    if (houseTypeStr.length > 0 && houseTypeStr.integerValue != self.houseType) {
        
        self.viewModel.isEnterCategory = YES;
        self.houseType = houseTypeStr.integerValue;
        [self resetFilter:paramObj];
        
    }
    BOOL hasTagData = [self.topTagsView hasTagData];
    CGFloat tagHeight = (hasTagData && self.houseType == FHHouseTypeSecondHandHouse) ? kFilterTagsViewHeight : 0;
    [self.topTagsView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(tagHeight);
    }];
    self.topTagsView.hidden = (hasTagData && self.houseType == FHHouseTypeSecondHandHouse) ? NO : YES;
    [self handleListOpenUrlUpdate:paramObj];
    [self.houseFilterBridge trigerConditionChanged];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.viewModel viewWillDisappear:animated];
    [self.viewModel addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.viewModel refreshMessageDot];
    [self.viewModel viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.houseFilterViewModel closeConditionFilterPanel];
}


-(void)initConstraints
{
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    
    [self.navbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.mas_equalTo(self.view);
        make.height.mas_equalTo(height);
    }];
    
    [self.filterBgControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.containerView);
        make.top.mas_equalTo(self.filterContainerView.mas_bottom);
    }];
    
    [self.errorMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.tableView);
    }];
    
    if (_commuteTipView) {
        [self.commuteTipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.view);
            make.top.mas_equalTo(self.navbar.mas_bottom);
            make.height.mas_equalTo(COMMUTE_HEIGHT);
        }];
        
        [self.commuteChooseBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(self.view);
            make.top.mas_equalTo(self.commuteTipView.mas_bottom);
        }];
    }
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.bottom.mas_equalTo(self.view);
        if (self.commuteTipView) {
            make.top.mas_equalTo(self.commuteTipView.mas_bottom);
        }else{
            make.top.mas_equalTo(self.navbar.mas_bottom);
        }
    }];
    
    [self.filterContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.containerView);
        make.height.mas_equalTo(@44);
    }];
    
    [self.filterPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.filterContainerView);
    }];
    
    BOOL hasTagData = [self.topTagsView hasTagData];
    CGFloat tagHeight = (hasTagData && self.houseType == FHHouseTypeSecondHandHouse) ? kFilterTagsViewHeight : 0;
    self.topTagsView.hidden = (hasTagData && self.houseType == FHHouseTypeSecondHandHouse) ? NO : YES;
    [self.topTagsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.filterContainerView.mas_bottom);
        make.left.right.mas_equalTo(self.containerView);
        make.height.mas_equalTo(tagHeight);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.topTagsView) {
            make.top.mas_equalTo(self.topTagsView.mas_bottom);
        }else {
            make.top.mas_equalTo(self.filterContainerView.mas_bottom);
        }
        make.left.right.bottom.mas_equalTo(self.containerView);
    }];
    
    [self.notifyBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.tableView);
        make.height.mas_equalTo(32);
    }];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.ttNeedIgnoreZoomAnimation = YES;
    
    [FHHouseCardUtils trackUseListComponentIfNeed];
    
    [self initNavbar];
    
    self.viewModel = [[FHHouseListViewModel alloc] initWithTableView:self.tableView routeParam:self.paramObj];
    [self.viewModel updateTracerDict:self.tracerDict.copy];
    self.viewModel.searchType = self.searchType;
    self.viewModel.listVC = self;
    [self.viewModel addNotiWithNaviBar:self.navbar];
    [self initFilter];
    [self setupViewModelBlock];

    [self setupUI];

    [self initConstraints];
    self.viewModel.maskView = self.errorMaskView;
    [self.viewModel setTopTagsView:self.topTagsView];
    if (self.topTagsView && self.paramObj.queryParams) {
        self.topTagsView.lastConditionDic = [NSMutableDictionary dictionaryWithDictionary:self.paramObj.queryParams];
    }
    [self.houseFilterViewModel trigerConditionChanged];

    
    WeakSelf;
    self.panBeginAction = ^{
        StrongSelf;
        [self.view endEditing:YES];
    };
}

-(void)refreshNavBar:(FHHouseType)houseType placeholder:(NSString *)placeholder inputText:(NSString *)inputText{
    
    if ((houseType == FHHouseTypeRentHouse && !self.viewModel.isCommute ) || houseType == FHHouseTypeSecondHandHouse ||houseType == FHHouseTypeNewHouse || houseType == FHHouseTypeNeighborhood) {
        if (houseType == FHHouseTypeSecondHandHouse || houseType == FHHouseTypeRentHouse) {
            // FHFakeInputNavbarTypeMessageAndMap 二手房列表页显示消息和小红点
            [self.navbar refreshNavbarType:FHFakeInputNavbarTypeMessageAndMap];
        } else if(houseType == FHHouseTypeNewHouse||houseType == FHHouseTypeNeighborhood){
            [self.navbar refreshNavbarType:FHFakeInputNavbarTypeMessageSingle];
        } else{
            [self.navbar refreshNavbarType:FHFakeInputNavbarTypeMap];
        }
    }else {

        [self.navbar refreshNavbarType:FHFakeInputNavbarTypeDefault];
    }
    self.navbar.placeHolder = placeholder;
    self.navbar.inputText = inputText;
    self.associationalWord = placeholder;
}

-(void)setupUI {
    
    _containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_containerView];

    self.automaticallyAdjustsScrollViewInsets = NO;

    [_containerView addSubview:self.tableView];
    
    //error view
    self.errorMaskView = [[FHHouseListErrorView alloc] init];
    [self.containerView addSubview:_errorMaskView];
    self.errorMaskView.hidden = YES;

    //notifyview
    self.notifyBarView = [[ArticleListNotifyBarView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.notifyBarView];
    [self setupTopTagsView];

    [self.view addSubview:self.navbar];
    [self.view addSubview:self.filterBgControl];
    
    _filterContainerView = [[UIView alloc]init];
    [self.view addSubview:_filterContainerView];

    [_filterContainerView addSubview:self.filterPanel];
    [self.view bringSubviewToFront:self.filterBgControl];
    
    
    if (_viewModel.isCommute) {
        //
        [self initCommuteTip];
        [self.view addSubview:_commuteTipView];
        [self.view addSubview:_commuteChooseBgView];
        
        if ([[self placeholderByHouseType:self.houseType] isEqualToString: self.associationalWord] && [FHCommuteManager sharedInstance].destLocation) {
            self.navbar.inputText = [FHCommuteManager sharedInstance].destLocation;
        }
    }

}

- (void)setupTopTagsView
{
    self.topTagsView = [[FHMainOldTopTagsView alloc] init];
    [self.view addSubview:self.topTagsView];
    BOOL hasTagData = [self.topTagsView hasTagData];
    CGFloat tagHeight = (hasTagData && self.houseType == FHHouseTypeSecondHandHouse) ? kFilterTagsViewHeight : 0;
    self.topTagsView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, tagHeight);
    self.topTagsView.hidden = (hasTagData && self.houseType == FHHouseTypeSecondHandHouse) ? NO : YES;
    __weak typeof(self) weakSelf = self;
    self.topTagsView.itemClickBlk = ^{
        __block NSString *value_id = nil;
        NSArray *temp = weakSelf.topTagsView.lastConditionDic[@"tags%5B%5D"];
        if ([temp isKindOfClass:[NSArray class]] && temp.count > 0) {
            [temp enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (value_id.length > 0) {
                    value_id = [NSString stringWithFormat:@"%@,%@",value_id,obj];
                } else {
                    value_id = obj;
                }
            }];
        } else {
            value_id = nil;//
        }
        [weakSelf.houseFilterBridge setFilterConditions:weakSelf.topTagsView.lastConditionDic];
        [weakSelf.houseFilterViewModel trigerConditionChanged];
        [weakSelf.viewModel addTagsViewClick:value_id];
    };
}

#pragma mark - show notify

- (void)showNotify:(NSString *)message inViewModel:(FHBaseHouseListViewModel *)viewModel
{
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.top = self.notifyBarView.height;
    self.tableView.contentInset = inset;
    
    [self.notifyBarView showMessage:message actionButtonTitle:@"" delayHide:YES duration:1 bgButtonClickAction:nil actionButtonClickBlock:nil didHideBlock:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 34 , 0);
        }];
    });

}

-(void)showErrorMaskView
{

}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    
    [self.viewModel addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
    
    if ([FHEnvContext isHouseListComponentEnable]) {
        [(FHHouseTableView *)self.tableView handleAppDidEnterBackground];
    }
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
    
    if ([FHEnvContext isHouseListComponentEnable]) {
        [(FHHouseTableView *)self.tableView handleAppWillEnterForground];
    }
    
    if (self.houseType == FHHouseTypeSecondHandHouse || self.houseType == FHHouseTypeNewHouse) {
        NSArray *tableCells = [self.tableView visibleCells];
        if (tableCells) {
            [tableCells enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored   "-Wundeclared-selector"
                if ([obj respondsToSelector:@selector(resumeVRIcon)]) {
                    [obj performSelector:@selector(resumeVRIcon)];
                }
#pragma clang diagnostic pop
            }];
        }
    }

}

#pragma mark - lazy load

-(UITableView *)tableView {
    if (!_tableView) {
        if ([FHEnvContext isHouseListComponentEnable]) {
            _tableView = [[FHHouseTableView alloc] initWithFrame:self.view.bounds];
        } else {
            _tableView = [[FHBaseTableView alloc] initWithFrame:self.view.bounds];
        }
        if (@available(iOS 11.0, *)) {
            
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if ([UIDevice btd_isIPhoneXSeries]) {
            
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
        }
        if (self.houseType == FHHouseTypeNewHouse || self.houseType == FHHouseTypeSecondHandHouse) {
            _tableView.backgroundColor = [UIColor themeGray7];
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _tableView;
}

@end
