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
#import "FHUserTracker.h"
#import "TTAccountManager.h"
#import "FHHouseUGCAPI.h"

@interface FHUGCFollowListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableDictionary *houseShowTracerDic;
@property (nonatomic, strong) NSMutableArray *preDeleteArray;
@property (nonatomic, strong) NSString *userId;//用户id

@end

@implementation FHUGCFollowListController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        // 埋点
        NSDictionary *params = paramObj.allParams;
        self.userId = [params objectForKey:@"uid"];
        
        NSString *enterFrom = params[@"enter_from"];
        if (enterFrom.length > 0) {
            self.tracerDict[@"enter_from"] = enterFrom;
        }
        self.tracerDict[@"enter_type"] = @"click";
        
        self.tracerDict[@"page_type"] = [self pageType];
        
        self.ttTrackStayEnable = YES;
    }
    return self;
}

- (NSString *)pageType {
    return @"personal_join_list";
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.items = [NSMutableArray new];
    self.preDeleteArray = [NSMutableArray array];
    [self setupUI];
    [self startLoadData];
    // 埋点
     self.houseShowTracerDic = [NSMutableDictionary new];
    [self addGoDetailLog];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStateChanged:) name:kFHUGCFollowNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    for (NSString *socialGroupId in self.preDeleteArray) {
        [self deleteCell:socialGroupId];
    }
    [self.preDeleteArray removeAllObjects];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setupUI {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = [[TTAccountManager userID] isEqualToString:self.userId] ? @"我关注的圈子" : @"TA关注的圈子";
    
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
    __weak typeof(self) wself = self;
    [self startLoading];
    [self.items removeAllObjects];
    [FHHouseUGCAPI requestFocusListWithUserId:self.userId completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        [wself endLoading];
        
        FHUGCModel *focusModel = (FHUGCModel *)model;
        
        if (!wself) {
            return;
        }
        
        if (error) {
            //TODO: show handle error
            if(error.code != -999){
                [wself.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
                wself.showenRetryButton = YES;
            }
            return;
        }
        
        if(focusModel){
            [wself.items addObjectsFromArray:focusModel.data.userFollowSocialGroups];
            wself.hasValidateData = wself.items.count > 0;
            
            if(wself.items.count > 0){
                [wself.emptyView hideEmptyView];
            }else{
                [wself.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
                wself.showenRetryButton = YES;
            }
            [wself.tableView reloadData];
        }
    }];
}

- (void)retryLoadData {
    [self startLoadData];
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
//                [self addHouseShowLog:indexPath];
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
        dict[@"tracer"] = @{@"enter_from":[self pageType],
                            @"enter_type":@"click",
                            @"rank":@(indexPath.row),
                            @"log_pb":data.logPb ?: @"be_null"};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        // 跳转到圈子详情页
        NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_detail"];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

- (void)followStateChanged:(NSNotification *)notification {
    //仅仅是进入我的关注列表需要处理
    if([[TTAccountManager userID] isEqualToString:self.userId]){
        BOOL followed = [notification.userInfo[@"followStatus"] boolValue];
        NSString *socialGroupId = notification.userInfo[@"social_group_id"];
        NSInteger row = [self getCellIndex:socialGroupId];
        if(row < self.items.count && row >= 0 && socialGroupId){
            if(followed){
                //关注
                if([self.preDeleteArray containsObject:socialGroupId]){
                    [self.preDeleteArray removeObject:socialGroupId];
                }
            }else{
                //取消关注
                if(![self.preDeleteArray containsObject:socialGroupId]){
                    [self.preDeleteArray addObject:socialGroupId];
                }
            }
        }
    }
}

- (void)deleteCell:(NSString *)socialGroupId {
    NSInteger row = [self getCellIndex:socialGroupId];
    if(row < self.items.count && row >= 0){
        [self.items removeObjectAtIndex:row];
        if(self.items.count <= 0){
            [self.emptyView showEmptyWithTip:@"没有更多了" errorImageName:@"fh_ugc_home_page_no_auth" showRetry:NO];
        }
    }
}

- (NSInteger)getCellIndex:(NSString *)socialGroupId {
    for (NSInteger i = 0; i < self.items.count; i++) {
        FHUGCScialGroupDataModel *model = self.items[i];
        if([socialGroupId isEqualToString:model.socialGroupId]){
            return i;
        }
    }
    return -1;
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self addStayPageLog];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

#pragma mark - Tracer

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self addStayPageLog];
}

-(void)addGoDetailLog {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    [FHUserTracker writeEvent:@"go_detail" params:tracerDict];
}

-(void)addStayPageLog {
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHUserTracker writeEvent:@"stay_page" params:tracerDict];
    [self tt_resetStayTime];
}

//- (void)addHouseShowLog:(NSIndexPath *)indexPath {
//    
//    if (indexPath.row >= self.items.count) {
//        return;
//    }
//    FHUGCScialGroupDataModel* cellModel = self.items[indexPath.row];
//    
//    if (!cellModel) {
//        return;
//    }
//    
//    NSString *house_type = @"community";
//    NSString *page_type = self.tracerDict[@"category_name"];
//    
//    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
//    tracerDict[@"house_type"] = house_type ? : @"be_null";
//    tracerDict[@"page_type"] = page_type ? : @"be_null";
//    tracerDict[@"rank"] = @(indexPath.row);
//    tracerDict[@"log_pb"] = cellModel.logPb ? : @"be_null";
//    tracerDict[@"card_type"] = @"left_pic";
//    
//    [tracerDict removeObjectForKey:@"category_name"];
//
//    [FHUserTracker writeEvent:@"community_group_show" params:tracerDict];
//}

@end
