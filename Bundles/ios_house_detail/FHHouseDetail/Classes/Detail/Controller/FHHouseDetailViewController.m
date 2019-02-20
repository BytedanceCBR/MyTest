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

@interface FHHouseDetailViewController ()

@property (nonatomic, strong) FHDetailNavBar *navBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *bottomStatusBar;
@property (nonatomic, strong) FHDetailBottomBarView *bottomBar;

@property (nonatomic, strong)   FHHouseDetailBaseViewModel       *viewModel;
@property (nonatomic, assign)   FHHouseType houseType; // 房源类型
@property (nonatomic, copy)   NSString* houseId; // 房源id
@property (nonatomic, strong)   NSDictionary       *listLogPB; // 外部传入的logPB
@property (nonatomic, copy)   NSString* searchId;
@property (nonatomic, copy)   NSString* imprId;

@end

@implementation FHHouseDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.houseType = [paramObj.allParams[@"house_type"] integerValue];
        self.houseId = paramObj.allParams[@"house_id"];
        self.searchId = paramObj.allParams[@"search_id"];
        self.imprId = paramObj.allParams[@"impr_id"];
        // 埋点数据处理
        [self processTracerData:paramObj.allParams];
        // 非埋点数据处理
        // disable_go_detail
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [self startLoadData];
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [self.viewModel startLoadData];
    } else {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
}

// 重新加载
- (void)retryLoadData {
    [self startLoadData];
}

- (void)setupUI {
    [self configTableView];
    self.viewModel = [FHHouseDetailBaseViewModel createDetailViewModelWithHouseType:self.houseType withController:self tableView:_tableView];
    self.viewModel.houseId = self.houseId;
    self.viewModel.listLogPB = self.listLogPB;
    // 构建详情页需要的埋点数据，放入baseViewModel中
    self.viewModel.detailTracerDic = [self makeDetailTracerData];
    [self.view addSubview:_tableView];

    __weak typeof(self)wself = self;
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat navBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 44 : 20;
    _navBar = [[FHDetailNavBar alloc]initWithFrame:CGRectMake(0, 0, screenBounds.size.width, navBarHeight + 44)];
    _navBar.backActionBlock = ^{
        [wself.navigationController popViewControllerAnimated:YES];
    };
    [self.view addSubview:_navBar];
    
    _bottomBar = [[FHDetailBottomBarView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:_bottomBar];
    
    _bottomStatusBar = [[UILabel alloc]init];
    _bottomStatusBar.textAlignment = NSTextAlignmentCenter;
    _bottomStatusBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    _bottomStatusBar.text = @"该房源已停售";
    _bottomStatusBar.font = [UIFont themeFontRegular:14];
    _bottomStatusBar.textColor = [UIColor whiteColor];
    _bottomStatusBar.hidden = YES;
    [self.view addSubview:_bottomStatusBar];

    self.viewModel.contactViewModel = [[FHHouseDetailContactViewModel alloc] initWithNavBar:_navBar bottomBar:_bottomBar];
    self.viewModel.contactViewModel.houseType = self.houseType;
    self.viewModel.contactViewModel.houseId = self.houseId;
    self.viewModel.contactViewModel.searchId = self.searchId;
    self.viewModel.contactViewModel.imprId = self.imprId;

    [self addDefaultEmptyViewFullScreen];

    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.bottomBar.mas_top);
    }];
    [_bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(64);
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-[UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom);
        }else {
            make.bottom.mas_equalTo(self.view);
        }
    }];
    [_bottomStatusBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.bottomBar.mas_top);
        make.height.mas_equalTo(0);
    }];
}

// 埋点数据处理:1、paramObj.allParams中的"tracer"字段，2、allParams中的origin_from、report_params等字段
- (void)processTracerData:(NSDictionary *)allParams {
    // 原始数据放入：self.tracerDict
    // 取其他非"tracer"字段数据
    NSString *origin_from = allParams[@"origin_from"];
    if (origin_from.length > 0) {
        self.tracerDict[@"origin_from"] = origin_from;
    }
    NSString *origin_search_id = allParams[@"origin_search_id"];
    if (origin_search_id.length > 0) {
        self.tracerDict[@"origin_search_id"] = origin_search_id;
    }
    NSString *report_params = allParams[@"report_params"];
    NSDictionary *report_params_dic = [self getDictionaryFromJSONString:report_params];
    if (report_params_dic) {
        [self.tracerDict addEntriesFromDictionary:report_params_dic];
    }
    NSString *log_pb_str = allParams[@"log_pb"];
    if (log_pb_str.length > 0) {
        NSDictionary *log_pb_dic = [self getDictionaryFromJSONString:log_pb_str];
        if (log_pb_dic) {
            self.tracerDict[@"log_pb"] = log_pb_dic;
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
    if (self.tracerDict[@"card_type"]) {
        detailTracerDic[@"card_type"] = self.tracerDict[@"card_type"];
    }
    if (self.tracerDict[@"element_from"]) {
        detailTracerDic[@"element_from"] = self.tracerDict[@"element_from"];
    }
    if (self.tracerDict[@"enter_from"]) {
        detailTracerDic[@"enter_from"] = self.tracerDict[@"enter_from"];
    }
    if (self.tracerDict[@"log_pb"]) {
        detailTracerDic[@"log_pb"] = self.tracerDict[@"log_pb"];
    }
    if (self.tracerDict[@"origin_from"]) {
        detailTracerDic[@"origin_from"] = self.tracerDict[@"origin_from"];
    }
    if (self.tracerDict[@"origin_search_id"]) {
        detailTracerDic[@"origin_search_id"] = self.tracerDict[@"origin_search_id"];
    }
    detailTracerDic[@"page_type"] = [self pageTypeString];
    if (self.tracerDict[@"rank"]) {
        detailTracerDic[@"rank"] = self.tracerDict[@"rank"];
    }
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
    titleLabel.textColor = [UIColor themeBlue1];
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

    if (contentOffset.y > 0) {
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
    }else {
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (void)configTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.estimatedRowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
    }
}

- (UIView *)getNaviBar
{
    return self.navBar;
}

- (UIView *)getBottomBar
{
    return self.bottomBar;
}

@end
