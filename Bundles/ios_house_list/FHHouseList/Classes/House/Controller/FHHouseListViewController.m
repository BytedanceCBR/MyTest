//
//  FHHouseListViewController.m
//  FHHouseList
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHHouseListViewController.h"
#import <TTRoute.h>
#import <Masonry.h>
#import <FHHouseBase/FHHouseBridgeManager.h>
#import "FHFakeInputNavbar.h"
#import <UIViewAdditions.h>
#import "ArticleListNotifyBarView.h"
#import "FHTracerModel.h"
#import "FHErrorMaskView.h"
#import "FHHouseListViewModel.h"
#import "TTDeviceHelper.h"
#import "NSDictionary+TTAdditions.h"

#define kFilterBarHeight 44

@interface FHHouseListViewController ()<TTRouteInitializeProtocol,FHHouseListViewModelDelegate>

@property (nonatomic , strong) FHFakeInputNavbar *navbar;
@property (nonatomic , strong) UIView *containerView;
@property (nonatomic , strong) UITableView* tableView;

@property (nonatomic , strong) UIView *filterContainerView;
@property (nonatomic , strong) UIView *filterPanel;
@property (nonatomic , strong) UIControl *filterBgControl;
@property (nonatomic , strong) id houseFilterViewModel;
@property (nonatomic , strong) id<FHHouseFilterBridge> houseFilterBridge;

@property (nonatomic , strong) ArticleListNotifyBarView *notifyBarView;

@property (nonatomic , strong) FHErrorView *errorMaskView;

@property (nonatomic , strong) FHBaseHouseListViewModel *viewModel;

@property (nonatomic , assign) FHHouseType houseType;
@property (nonatomic , strong) TTRouteParamObj *paramObj;


@property (nonatomic , copy) NSString *associationalWord;// 联想词
@property (nonatomic , copy) NSString *suggestionParams; // sug
@property (nonatomic , copy) NSString *queryString;
@property (nonatomic , strong) NSDictionary *tracerDict; // 埋点
@property (nonatomic , assign) BOOL isNeedEncode; // 是否需要encode URL


@property (nonatomic , strong) UIButton *testBtn;


@end

@implementation FHHouseListViewController

-(instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
        //init coordinate viewmodel according to viewmodel
        self.paramObj = paramObj;
        self.hidesBottomBarWhenPushed = YES;
        NSString *houseTypeStr = paramObj.allParams[@"house_type"];
        self.houseType = houseTypeStr.length > 0 ? houseTypeStr.integerValue : FHHouseTypeSecondHandHouse;
        self.tracerModel.categoryName = [self categoryName];
        self.tracerDict = [paramObj.userInfo.allInfo tt_dictionaryValueForKey:@"tracer"];
        NSDictionary *sugDict = [paramObj.userInfo.allInfo tt_dictionaryValueForKey:@"sugParams"];
        self.associationalWord = [sugDict tt_stringValueForKey:@"associateWord"];
        self.suggestionParams = [sugDict tt_stringValueForKey:@"sug"];

        
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
    if (self.houseType == FHHouseTypeSecondHandHouse || self.houseType == FHHouseTypeRentHouse) {
        type = FHFakeInputNavbarTypeMap;
    }
    _navbar = [[FHFakeInputNavbar alloc] initWithType:type];
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
    self.houseFilterViewModel = bridge;
    
    self.viewModel = [[FHHouseListViewModel alloc]initWithTableView:self.tableView viewControler:self routeParam:self.paramObj];
    self.viewModel.viewModelDelegate = self;
    
    __weak typeof(self) wself = self;
    _viewModel.conditionNoneFilterBlock = ^NSString * _Nullable(NSDictionary * _Nonnull params) {
        return [wself.houseFilterBridge getNoneFilterQueryParams:params];
    };
    
    _viewModel.closeConditionFilter = ^{
        [wself.houseFilterBridge closeConditionFilterPanel];
    };
    
    _viewModel.clearSortCondition = ^{
        [wself.houseFilterBridge clearSortCondition];
    };
    
    _viewModel.getConditions = ^NSString * _Nonnull{
        return [wself.houseFilterBridge getConditions];
    };
    
    _viewModel.showNotify = ^(NSString * _Nonnull message) {
//        [wself showNotify:message];
    };
    
    [bridge setViewModel:self.houseFilterViewModel withDelegate:self.viewModel];
//    _filterBgControl.hidden = YES;
    
    [bridge resetFilter:self.houseFilterViewModel withQueryParams:nil updateFilterOnly:NO];
    [bridge showBottomLine:NO];
    
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor themeGray6];
    [self.filterPanel addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear:animated];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.viewModel viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

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
        make.top.mas_equalTo(self.filterPanel.mas_bottom);
    }];
    
    [self.errorMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.tableView);
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.navbar.mas_bottom);
    }];
    
    [self.filterPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.containerView);
        make.height.mas_equalTo(@44);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.filterPanel.mas_bottom);
        make.left.right.bottom.mas_equalTo(self.containerView);
    }];
    
    [self.notifyBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.tableView);
        make.height.mas_equalTo(32);
    }];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initNavbar];
    [self initFilter];

    [self setupUI];


    [self initConstraints];
    self.viewModel.maskView = self.errorMaskView;

    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];

    
    //    if (self.configModel.mapOpenUrl.length > 0) {
    //
    //        NSURL *url = [NSURL URLWithString:self.configModel.mapOpenUrl];
    //        TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:url];
    //        [bridge resetFilter:self.houseFilterViewModel withQueryParams:paramObj.allParams updateFilterOnly:NO];
    //
    //    }else if (self.configModel.conditionParams) {
    //        [bridge resetFilter:self.houseFilterViewModel withQueryParams:_configModel.conditionParams updateFilterOnly:NO];
    //    }
    
    [self.houseFilterBridge setViewModel:self.houseFilterViewModel withDelegate:_viewModel];
    
    // add by zjing for test
//    self.testBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    [self.testBtn addTarget:self action:@selector(testBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    self.testBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview: self.testBtn];
    
    [self.viewModel loadData:YES];

}

-(FHHouseType)randomHouseType {
    
    FHHouseType houseType = arc4random() % 5;
    return houseType;
}
-(void)testBtnDidClick:(UIButton *)btn {
    
    FHHouseType houseType = [self randomHouseType];
    if (houseType == FHHouseTypeRentHouse || houseType == FHHouseTypeSecondHandHouse) {
        
        [self.navbar refreshNavbarType:FHFakeInputNavbarTypeMap];
    }else {
        [self.navbar refreshNavbarType:FHFakeInputNavbarTypeDefault];

    }
    if (self.associationalWord.length > 0) {
        
        self.navbar.placeHolder = self.associationalWord;
    }else {
        
        self.navbar.placeHolder = [self placeholderByHouseType:houseType];
    }
    [btn setTitle:[NSString stringWithFormat:@"houseType: %d",houseType] forState:UIControlStateNormal];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        [self.view endEditing:YES];
    }
}

-(void)dealloc
{
//    [self tryCallbackOpenUrl];
    
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
}


-(void)setupUI {
    
    _containerView = [[UIView alloc] init];
    [self.view addSubview:_containerView];

    self.automaticallyAdjustsScrollViewInsets = NO;

    [_containerView addSubview:self.tableView];
    
    //error view
    self.errorMaskView = [[FHErrorView alloc] init];
    [self.containerView addSubview:_errorMaskView];
    self.errorMaskView.hidden = YES;
    
    //notifyview
    self.notifyBarView = [[ArticleListNotifyBarView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.notifyBarView];

    [self.view addSubview:self.navbar];
    [self.view addSubview:self.filterBgControl];
    [self.view addSubview:self.filterPanel];

    [self.view bringSubviewToFront:self.filterBgControl];


}

#pragma mark - show notify

-(void)showNotify:(NSString *)message inViewModel:(FHBaseHouseListViewModel *)viewModel
{
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.top = self.notifyBarView.height;
    self.tableView.contentInset = inset;
    
    [self.notifyBarView showMessage:message actionButtonTitle:@"" delayHide:YES duration:1 bgButtonClickAction:nil actionButtonClickBlock:nil didHideBlock:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            
            UIEdgeInsets inset = self.tableView.contentInset;
            inset.top = 0;
            self.tableView.contentInset = inset;
        }];
    });

}

-(void)showErrorMaskView
{
    //
//    [self.viewModel reloadData];
}

#pragma mark - lazy load

-(UITableView *)tableView
{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        if (@available(iOS 11.0, *)) {
            
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if ([TTDeviceHelper isIPhoneXDevice]) {
            
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        
    }
    return _tableView;
}

@end