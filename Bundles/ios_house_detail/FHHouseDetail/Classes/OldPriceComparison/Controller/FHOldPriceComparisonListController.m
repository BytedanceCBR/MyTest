//
//  FHOldPriceComparisonListController.m
//  FHHouseList
//
//  Created by 谢思铭 on 2019/4/9.
//

#import "FHOldPriceComparisonListController.h"
#import "FHOldPriceComparisonListViewModel.h"
#import <TTUIWidget/UIViewController+Track.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTReachability/TTReachability.h>
#import <TTUIWidget/ArticleListNotifyBarView.h>
#import <UIViewAdditions.h>
#import <FHHouseBase/FHBaseTableView.h>

@interface FHOldPriceComparisonListController ()

@property (nonatomic, strong) FHOldPriceComparisonListViewModel *viewModel;
@property (nonatomic, copy) NSString *neighborhoodId;
@property (nonatomic, copy) NSString *neighborhoodName;
@property (nonatomic, copy) NSString *houseType;
@property (nonatomic, copy) NSString *orderBy;
@property (nonatomic, copy) NSString *roomNum;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic , strong) ArticleListNotifyBarView *notifyBarView;

@end

@implementation FHOldPriceComparisonListController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.neighborhoodId = paramObj.allParams[@"neighborhood_id"];
        self.houseType = paramObj.allParams[@"house_type"];
        self.orderBy = [paramObj.allParams[@"order_by%5B%5D"] firstObject];
        self.roomNum = [paramObj.allParams[@"room_num%5B%5D"] firstObject];
        self.title = paramObj.allParams[@"title"];
        self.ttTrackStayEnable = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [self startLoadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.viewModel viewWillDisappear:animated];
}

- (void)setupUI {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = self.title;
    [self configTableView];
    
    self.viewModel = [[FHOldPriceComparisonListViewModel alloc] initWithController:self tableView:_tableView];
    self.viewModel.query = [self getQueryStr];
    [self.view addSubview:_tableView];
    
    //notifyview
    self.notifyBarView = [[ArticleListNotifyBarView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.notifyBarView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.customNavBarView.mas_bottom);
        make.bottom.mas_equalTo(self.view);
    }];
    [self.notifyBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.tableView);
        make.height.mas_equalTo(32);
    }];
    
    [self addDefaultEmptyViewFullScreen];
    [self.viewModel setMaskView:self.emptyView];
}

- (void)configTableView {
    _tableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
}

- (NSString *)getQueryStr {
    NSString* conditionQueryString = [NSString stringWithFormat:@"&house_type=%@&order_by[]=%@&neighborhood_id=%@&room_num[]=%@",self.houseType,self.orderBy,self.neighborhoodId,self.roomNum];
    conditionQueryString = [conditionQueryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return conditionQueryString;
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [self.viewModel requestErshouHouseListData:NO query:self.viewModel.query offset:0 searchId:nil];
    } else {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
}

#pragma mark - show notify

- (void)showNotify:(NSString *)message {
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.top = self.notifyBarView.height;
    self.tableView.contentInset = inset;
    [self.notifyBarView showMessage:message actionButtonTitle:@"" delayHide:YES duration:1 bgButtonClickAction:nil actionButtonClickBlock:nil didHideBlock:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.contentInset = UIEdgeInsetsZero;
        }];
    });
    
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self.viewModel addStayCategoryLog];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

@end
