//
//  FHMyFavoriteViewController.m
//  AFgzipRequestSerializer
//
//  Created by 谢思铭 on 2019/2/14.
//

#import "FHMyFavoriteViewController.h"
#import "FHMyFavoriteViewModel.h"
#import <Masonry.h>
#import "UIViewController+NavbarItem.h"
#import "UIColor+Theme.h"
#import "TTReachability.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "UIViewController+Track.h"
#import "FHTracerModel.h"
#import "FHUserTracker.h"
#import "FHHouseType.h"

@interface FHMyFavoriteViewController ()<UIViewControllerErrorHandler,TTRouteInitializeProtocol>

@property(nonatomic, strong) FHMyFavoriteViewModel *viewModel;
@property(nonatomic, assign) FHHouseType type;

@end

@implementation FHMyFavoriteViewController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.type = [paramObj.allParams[@"house_type"] integerValue];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.hidesBottomBarWhenPushed = YES;
    self.showenRetryButton = YES;
    self.ttTrackStayEnable = YES;
    
    [self initNavbar];
    [self initView];
    [self initConstraints];
    [self initViewModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.tableView setEditing:NO animated:YES];
    [self.viewModel addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
    
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = [self titleText];
}

- (NSString *)titleText {
    NSString *text = @"我关注的";
    switch (self.type) {
        case FHHouseTypeSecondHandHouse:
            text = [text stringByAppendingString:@"二手房"];
            break;
        case FHHouseTypeRentHouse:
            text = [text stringByAppendingString:@"租房"];
            break;
        case FHHouseTypeNewHouse:
            text = [text stringByAppendingString:@"新房"];
            break;
        case FHHouseTypeNeighborhood:
            text = [text stringByAppendingString:@"小区"];
            break;
            
        default:
            break;
    }
    
    return text;
}

- (void)initView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    if (@available(iOS 11.0, *)) {
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:_tableView];
    [self addDefaultEmptyViewFullScreen];
}

- (void)initConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.customNavBarView.mas_bottom);
        make.left.right.bottom.mas_equalTo(self.view);
    }];
}

- (void)initViewModel {
    _viewModel = [[FHMyFavoriteViewModel alloc] initWithTableView:_tableView controller:self type:self.type];
    [self startLoadData];
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [_viewModel requestData:YES];
    } else {
        if(!self.hasValidateData){
            [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        }
    }
}

- (void)retryLoadData {
    [self startLoadData];
}

- (NSString *)categoryName {
    NSString *categoryName = @"be_null";
    switch (self.type) {
        case FHHouseTypeNewHouse:
            categoryName = @"new_follow_list";
            break;
        case FHHouseTypeRentHouse:
            categoryName = @"rent_follow_list";
            break;
        case FHHouseTypeSecondHandHouse:
            categoryName = @"old_follow_list";
            break;
        case FHHouseTypeNeighborhood:
            categoryName = @"neighborhood_follow_list";
            break;
            
        default:
            break;
    }
    return categoryName;
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData {
    return _viewModel.dataList.count == 0 ? NO : YES; //默认会显示空
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self.viewModel addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

@end
