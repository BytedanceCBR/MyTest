//
//  FHUGCFollowListController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/16.
//

#import "FHUGCFollowListController.h"
#import "TTReachability.h"
#import "UIViewAdditions.h"
#import "FHRefreshCustomFooter.h"
#import "FHUserTracker.h"
#import "FHFakeInputNavbar.h"
#import "FHConditionFilterFactory.h"
#import "SSNavigationBar.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "UIViewController+NavbarItem.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTDeviceHelper.h"
#import "FHUGCConfig.h"
#import "FHUGCFollowListCell.h"
#import "UIViewController+Track.h"

@interface FHUGCFollowListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableDictionary *houseShowTracerDic;

@end

@implementation FHUGCFollowListController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        // 埋点
        self.tracerDict[@"category_name"] = [self categoryName];
        self.ttTrackStayEnable = YES;
    }
    return self;
}

- (NSString *)categoryName {
    return @"my_joined_neighborhood_list";
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.items = [NSMutableArray new];
    [self setupUI];
    [self setupData];
    [self startLoadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFollowDataFinished:) name:kFHUGCLoadFollowDataFinishedNotification object:nil];
    // 埋点
     self.houseShowTracerDic = [NSMutableDictionary new];
    [self addEnterCategoryLog];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.items.count > 0) {
        [self.tableView reloadData];
    }
}

- (void)loadFollowDataFinished:(NSNotification *)noti {
    [self setupData];
}

- (void)setupData {
    [self.items removeAllObjects];
    // 是否有数据
    if ([FHUGCConfig sharedInstance].followData && [FHUGCConfig sharedInstance].followData.data.userFollowSocialGroups.count > 0) {
        // 有数据
        [self.items addObjectsFromArray:[FHUGCConfig sharedInstance].followData.data.userFollowSocialGroups];
        [self.emptyView hideEmptyView];
        [self.tableView reloadData];
    } else {
        // 暂时没有数据
        [self.emptyView showEmptyWithTip:@"你还没有关注任何小区" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:YES];
        [self.emptyView.retryButton setTitle:@"关注小区" forState:UIControlStateNormal];
    }
}

- (void)setupUI {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"TA关注的小区圈";
    
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    
    [self configTableView];
    [self.view addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[FHUGCFollowListCell class] forCellReuseIdentifier:@"FHUGCFollowListCell"];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(height);
    }];
    [self addDefaultEmptyViewFullScreen];
}

- (void)configTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.estimatedRowHeight = 70;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    if ([TTDeviceHelper isIPhoneXSeries]) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
}

- (void)startLoadData {
    
}

- (void)retryLoadData {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"click_position"] = @"join_like_neighborhood";
    NSString *category_name = self.tracerDict[@"category_name"];
    tracerDict[@"page_type"] = category_name ?: @"be_null";
    [tracerDict removeObjectForKey:@"category_name"];
    [FHUserTracker writeEvent:@"click_join_like_neighborhood" params:tracerDict];
    
    NSMutableDictionary *dict = @{}.mutableCopy;
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    NSString *enter_from = @"join_like_neighborhood";
    traceParam[@"enter_from"] = enter_from;
    dict[TRACER_KEY] = traceParam;
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    // 关注小区 按钮点击
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_my_interest"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHUGCFollowListCell *cell = (FHUGCFollowListCell *)[tableView dequeueReusableCellWithIdentifier:@"FHUGCFollowListCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.items.count) {
        id data = self.items[row];
        [cell refreshWithData:data];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.items.count) {
        FHUGCScialGroupDataModel* data = self.items[indexPath.row];
        NSString *recordKey = data.socialGroupId;
        if (recordKey.length > 0) {
            if (!self.houseShowTracerDic[recordKey]) {
                // 埋点
                self.houseShowTracerDic[recordKey] = @(YES);
                [self addHouseShowLog:indexPath];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.items.count) {
        FHUGCScialGroupDataModel* data = self.items[row];
        // 我关注的小区
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"community_id"] = data.socialGroupId;
        dict[@"tracer"] = @{@"enter_from":@"my_joined_neighborhood_list",
                            @"enter_type":@"click",
                            @"rank":@(indexPath.row),
                            @"log_pb":data.logPb ?: @"be_null"};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        // 跳转到圈子详情页
        NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_detail"];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self addStayCategoryLog];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

#pragma mark - Tracer

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self addStayCategoryLog];
}

-(void)addEnterCategoryLog {
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    [FHUserTracker writeEvent:@"enter_category" params:tracerDict];
}

-(void)addStayCategoryLog {
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHUserTracker writeEvent:@"stay_category" params:tracerDict];
    [self tt_resetStayTime];
}

-(NSDictionary *)categoryLogDict {
    
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    NSString *enter_type = self.tracerDict[@"enter_type"];
    tracerDict[@"enter_type"] = enter_type.length > 0 ? enter_type : @"be_null";
    NSString *category_name = self.tracerDict[@"category_name"];
    tracerDict[@"category_name"] = category_name.length > 0 ? category_name : @"be_null";
    NSString *enter_from = self.tracerDict[@"enter_from"];
    tracerDict[@"enter_from"] = enter_from.length > 0 ? enter_from : @"be_null";
    NSString *element_from = self.tracerDict[@"element_from"];
    tracerDict[@"element_from"] = element_from.length > 0 ? element_from : @"be_null";
    return tracerDict;
}


-(void)addHouseShowLog:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= self.items.count) {
        return;
    }
    FHUGCScialGroupDataModel* cellModel = self.items[indexPath.row];
    
    if (!cellModel) {
        return;
    }
    
    NSString *house_type = @"community";
    NSString *page_type = self.tracerDict[@"category_name"];
    
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"house_type"] = house_type ? : @"be_null";
    tracerDict[@"page_type"] = page_type ? : @"be_null";
    tracerDict[@"rank"] = @(indexPath.row);
    tracerDict[@"log_pb"] = cellModel.logPb ? : @"be_null";
    tracerDict[@"card_type"] = @"left_pic";
    
    
    [tracerDict removeObjectForKey:@"category_name"];
    
    
    [FHUserTracker writeEvent:@"community_group_show" params:tracerDict];
}

@end
