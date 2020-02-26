//
//  FHUGCMyInterestedViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/13.
//

#import "FHUGCMyInterestedViewModel.h"
#import "TTHttpTask.h"
#import "FHRefreshCustomFooter.h"
#import "FHUGCMyInterestedCell.h"
#import "FHUGCMyInterestedSimpleCell.h"
#import "FHHouseUGCAPI.h"
#import "FHUGCMyInterestModel.h"
#import "FHLocManager.h"
#import "FHUserTracker.h"
#import "UIViewController+Track.h"

#define kCellId @"cell_id"

@interface FHUGCMyInterestedViewModel()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHUGCMyInterestedController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic, strong) NSMutableDictionary *cellHeightCaches;

@property(nonatomic, strong) NSMutableDictionary *clientShowDict;
@property(nonatomic, assign) NSTimeInterval enterTabTimestamp;

@end

@implementation FHUGCMyInterestedViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHUGCMyInterestedController *)viewController {
    self = [super init];
    if (self) {
        _dataList = [[NSMutableArray alloc] init];
        _cellHeightCaches = [NSMutableDictionary dictionary];
        tableView.delegate = self;
        tableView.dataSource = self;
        _viewController = viewController;
        _tableView = tableView;
        
        if(viewController.type == FHUGCMyInterestedTypeMore){
            [tableView registerClass:[FHUGCMyInterestedSimpleCell class] forCellReuseIdentifier:kCellId];
        }else{
            [tableView registerClass:[FHUGCMyInterestedCell class] forCellReuseIdentifier:kCellId];
        }

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        if(viewController.type == FHUGCMyInterestedTypeEmpty){
            [self addEnterCategoryLog];
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear {
    if ([[NSDate date]timeIntervalSince1970] - _enterTabTimestamp > 24*60*60) {
        //超过一天
        _enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
    }
    [self addEnterCategoryLog];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillDisappear {
    if(self.viewController.type == FHUGCMyInterestedTypeEmpty){
        [self addStayCategoryLog];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)requestData:(BOOL)isHead {
    if(self.viewController.isLoadingData){
        return;
    }
    
    self.viewController.isLoadingData = YES;
    [self.viewController startLoading];
    
    __weak typeof(self) wself = self;
    
    NSString *source = @"other";
    if(self.viewController.type == FHUGCMyInterestedTypeEmpty){
        source = @"empty_page";
    }
    
    CLLocation *currentLocaton = [FHLocManager sharedInstance].currentLocaton;
    self.requestTask = [FHHouseUGCAPI requestRecommendSocialGroupsWithSource:source latitude:currentLocaton.coordinate.latitude longitude:currentLocaton.coordinate.longitude class:[FHUGCMyInterestModel class] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
        wself.viewController.isLoadingData = NO;
        [wself.viewController endLoading];
        
        FHUGCMyInterestModel *interestModel = (FHUGCMyInterestModel *)model;

        if (error) {
            //TODO: show handle error
            if(error.code != -999){
                [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
            }
            return;
        }
        
        [wself.viewController.emptyView hideEmptyView];
        
        if(model){
            if (isHead) {
                [wself.dataList removeAllObjects];
            }
            [wself.dataList addObjectsFromArray:interestModel.data.recommendSocialGroups];
            wself.viewController.hasValidateData = wself.dataList.count > 0;
            
            if(wself.dataList.count > 0){
                [wself.viewController.emptyView hideEmptyView];
                [wself.tableView reloadData];
            }else{
                if(wself.viewController.type == FHUGCMyInterestedTypeEmpty){
                    [wself.viewController.emptyView showEmptyWithTip:@"你还没有关注任何圈子\n去附近或发现逛逛吧" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
                }else{
                    [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
                }
            }
            
            //报的是我关注的feed页的埋点组件展现
            if(wself.viewController.type == FHUGCMyInterestedTypeEmpty && self.dataList.count > 0){
                [self trackElementShow];
            }
        }
    }];
}

- (void)addEnterCategoryLog {
    //报的是我关注的feed页的埋点
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    
    tracerDict[@"category_name"] = @"my_join_list";
    tracerDict[@"enter_type"] = @"click";
    tracerDict[@"enter_from"] = @"neighborhood_tab";
    tracerDict[@"show_type"] = @"feed_blank_select";
    [tracerDict setValue:@(0) forKey:@"with_tips"];
    TRACK_EVENT(@"enter_category", tracerDict);
    
    self.enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
}

- (void)addStayCategoryLog {
    NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - _enterTabTimestamp;
    if (duration <= 0 || duration >= 24*60*60) {
        return;
    }
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    
    tracerDict[@"category_name"] = @"my_join_list";
    tracerDict[@"enter_type"] = @"click";
    tracerDict[@"enter_from"] = @"neighborhood_tab";
    tracerDict[@"show_type"] = @"feed_blank_select";
    [tracerDict setValue:@(0) forKey:@"with_tips"];
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:(duration * 1000)];
    TRACK_EVENT(@"stay_category", tracerDict);
    
    self.enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
}

- (void)trackElementShow {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    
    tracerDict[@"element_type"] = @"like_neighborhood";
    tracerDict[@"page_type"] = @"my_join_list";
    tracerDict[@"enter_from"] = @"neighborhood_tab";
    tracerDict[@"card_type"] = @"left_pic";
    tracerDict[@"show_type"] = @"feed_blank_select";
    TRACK_EVENT(@"element_show", tracerDict);
}

- (void)traceGroupShowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row >= self.dataList.count) {
        return;
    }
    
    FHUGCMyInterestDataRecommendSocialGroupsModel *model = self.dataList[indexPath.row];
    
    if (!_clientShowDict) {
        _clientShowDict = [NSMutableDictionary new];
    }
    
    NSString *row = [NSString stringWithFormat:@"%i",indexPath.row];
    NSString *socialGroupId = model.socialGroup.socialGroupId;
    if(socialGroupId){
        if (_clientShowDict[socialGroupId]) {
            return;
        }
        
        _clientShowDict[socialGroupId] = @(indexPath.row);
        [self trackGroupShow:model rank:indexPath.row];
    }
}

- (void)trackGroupShow:(FHUGCMyInterestDataRecommendSocialGroupsModel *)model rank:(NSInteger)rank {
    NSMutableDictionary *dict =  [self trackDict:model rank:rank];
    [dict removeObjectsForKeys:@[@"element_type"]];
    TRACK_EVENT(@"community_group_show", dict);
}

- (NSMutableDictionary *)trackDict:(FHUGCMyInterestDataRecommendSocialGroupsModel *)model rank:(NSInteger)rank {
    NSMutableDictionary *dict =  [self.viewController.tracerDict mutableCopy];
    
    dict[@"house_type"] = @"community";
    dict[@"card_type"] = @"left_pic";
    dict[@"log_pb"] = model.socialGroup.logPb;
    dict[@"rank"] = @(rank);
    
    if(self.viewController.type == FHUGCMyInterestedTypeEmpty){
        dict[@"page_type"] = @"my_join_list";
        dict[@"show_type"] = @"feed_blank_select";
    }else{
        dict[@"page_type"] = @"like_neighborhood_list";
        dict[@"element_from"] = @"like_neighborhood";
        dict[@"element_type"] = @"like_neighborhood";
    }
    
    return dict;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
        NSNumber *cellHeight = [NSNumber numberWithFloat:cell.frame.size.height];
        self.cellHeightCaches[tempKey] = cellHeight;
        [self traceGroupShowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    FHUGCMyInterestDataRecommendSocialGroupsModel *model = self.dataList[indexPath.row];
    
    NSMutableDictionary *dict =  [self trackDict:model rank:indexPath.row];
    [dict removeObjectsForKeys:@[@"element_from"]];
    cell.tracerDic = dict;
    [cell refreshWithData:model];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.viewController.type == FHUGCMyInterestedTypeMore){
        return 70;
    }else{
        NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
        NSNumber *cellHeight = self.cellHeightCaches[tempKey];
        if (cellHeight) {
            return [cellHeight floatValue];
        }
        return UITableViewAutomaticDimension;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!self.viewController.forbidGoToDetail){
        FHUGCMyInterestDataRecommendSocialGroupsModel *model = self.dataList[indexPath.row];
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"community_id"] = model.socialGroup.socialGroupId;
        NSString* enterFrom = self.viewController.type == FHUGCMyInterestedTypeEmpty ? @"feed_blank_select" : @"like_neighborhood_list";
        dict[@"tracer"] = @{@"enter_from":enterFrom,
                            @"enter_type":@"click",
                            @"rank":@(indexPath.row),
                            @"log_pb":model.socialGroup.logPb ?: @"be_null"};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        //跳转到圈子详情页
        NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_detail"];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

- (void)applicationDidEnterBackground {
    if(self.viewController.type == FHUGCMyInterestedTypeEmpty){
        [self addStayCategoryLog];
    }
}

- (void)applicationDidBecomeActive {
    if(self.viewController.type == FHUGCMyInterestedTypeEmpty){
        _enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
    }
}

@end
