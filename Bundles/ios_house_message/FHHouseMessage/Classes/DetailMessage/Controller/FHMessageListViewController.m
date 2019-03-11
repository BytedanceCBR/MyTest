//
//  FHMessageListViewController.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/1.
//

#import "FHMessageListViewController.h"
#import "FHMessageListBaseViewModel.h"
#import "FHMessageListSysViewModel.h"
#import "FHMessageListHouseViewModel.h"
#import <Masonry.h>
#import "FHMessageAPI.h"
#import <TTRoute.h>
#import "UIColor+Theme.h"
#import "TTReachability.h"
#import "UIViewController+HUD.h"
#import "FHUserTracker.h"
#import "UIFont+House.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "UIViewController+Track.h"

@interface FHMessageListViewController ()<TTRouteInitializeProtocol,UIViewControllerErrorHandler>

@property(nonatomic, strong) FHMessageListBaseViewModel *viewModel;
@property(nonatomic ,strong) UITableView *tableView;
@property(nonatomic, strong) NSString *typeId;
@property(nonatomic, assign) NSTimeInterval enterTabTimestamp;

@end

@implementation FHMessageListViewController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.typeId = [paramObj.allParams[@"list_id"] description];
        
        if(!self.typeId){
            self.typeId = paramObj.userInfo.allInfo[@"typeId"];
        }
        self.title = paramObj.allParams[@"title"];
    }
    return self;
}

- (NSString *)categoryName
{
    FHMessageType type = [self.typeId integerValue];
    NSString *categoryName = @"be_null";
    if(self.typeId){
        switch (type) {
            case FHMessageTypeNew:
                categoryName = @"new_message_list";
                break;
            case FHMessageTypeOld:
                categoryName = @"old_message_list";
                break;
            case FHMessageTypeRent:
                categoryName = @"rent_message_list";
                break;
            case FHMessageTypeNeighborhood:
                categoryName = @"neighborhood_message_list";
                break;
            case FHMessageTypeHouseOld:
                categoryName = @"recommend_message_list";
                break;
            case FHMessageTypeHouseRent:
                categoryName = @"recommend_message_list";
                break;
            case FHMessageTypeSystem:
                categoryName = @"official_message_list";
                break;

            default:
                break;
        }
    }
    return categoryName;
}

- (NSString *)originFrom
{
    FHMessageType type = [self.typeId integerValue];
    NSString *originFrom = @"be_null";
    if(self.typeId){
        switch (type) {
            case FHMessageTypeNew:
                originFrom = @"messagetab_new";
                break;
            case FHMessageTypeOld:
                originFrom = @"messagetab_old";
                break;
            case FHMessageTypeRent:
                originFrom = @"messagetab_rent";
                break;
            case FHMessageTypeNeighborhood:
                originFrom = @"messagetab_neighborhood";
                break;
            case FHMessageTypeHouseOld:
                originFrom = @"messagetab_recommend_old";
                break;
            case FHMessageTypeHouseRent:
                originFrom = @"messagetab_recommend_rent";
                break;
                
            default:
                break;
        }
    }
    return originFrom;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
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
    [self addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = self.title;
}

- (void)initView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor themeGray7];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.tableFooterView = footerView;
    
    _tableView.sectionFooterHeight = 0.0;
    
    _tableView.estimatedRowHeight = 85;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    
    if (@available(iOS 11.0 , *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.view addSubview:_tableView];
    
    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (void)initConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.mas_topLayoutGuide).offset(44);
        } else {
            make.top.mas_equalTo(64);
        }
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)initViewModel {
    FHMessageType type = [self.typeId integerValue];
    FHMessageListBaseViewModel *viewModel = nil;
        
    if(type == FHMessageTypeSystem){
        viewModel = [[FHMessageListSysViewModel alloc] initWithTableView:_tableView controller:self];
    }else {
        viewModel = [[FHMessageListHouseViewModel alloc] initWithTableView:_tableView controller:self listId:type];
    }

    self.viewModel = viewModel;
    [self startLoadData];
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [_viewModel requestData:YES first:YES];
    } else {
        if(!self.hasValidateData){
            [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        }
    }
}

- (void)retryLoadData {
    [self startLoadData];
}

- (void)addStayCategoryLog:(NSTimeInterval)stayTime {
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    NSMutableDictionary *tracerDict = [self.viewModel categoryLogDict].mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    TRACK_EVENT(@"stay_category", tracerDict);
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData {
    return _viewModel.dataList.count == 0 ? NO : YES; //默认会显示空
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

@end
