//
//  FHFalseHouseListViewModel.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/5/30.
//

#import "FHFalseHouseListViewModel.h"
#import <FHHouseType.h>
#import <FHHouseBaseItemCell.h>
#import "FHErrorView.h"
#import <FHSingleImageInfoCellModel.h>
#import <FHUserTracker.h>
#import <FHHouseBridgeManager.h>
#import "TTRoute.h"
#import <FHHouseListAPI.h>
#import <TTHttpTask.h>
#import "FHFalseHouseListViewController.h"
#import "FHUtils.h"
#import <FHEnvContext.h>
#import "FHFalseListTopHeaderView.h"
#import "FHRefreshCustomFooter.h"
#import <ToastManager.h>
#import <UIScrollView+Refresh.h>
#import "UIViewController+Refresh_ErrorHandler.h"

#define kBaseCellId @"kBaseCellId"
#define kBaseErrorCellId @"kErrorCell"

static const NSUInteger kFHHomeHeaderViewSectionHeight = 35;

@interface FHFalseHouseListViewModel () <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , strong) NSMutableArray *houseList;
@property(nonatomic, weak) UITableView *tableView;
@property (nonatomic , assign) FHHouseType houseType;
@property(nonatomic , strong) NSMutableDictionary *houseShowCache;
@property(nonatomic , strong) NSString *originFrom;
@property(nonatomic , strong) NSString *originSearchId;
@property(nonatomic , copy) NSString *searchId;
@property(nonatomic , strong) FHFalseListTopHeaderView *topHeader;
@property(nonatomic , weak) TTHttpTask * requestTask;
@property(nonatomic , weak) FHRefreshCustomFooter *refreshFooter;
@property (nonatomic, weak) FHFalseHouseListViewController *currentViewController;
@property (nonatomic , strong) UIView *bottomView;
@property (nonatomic , strong) UIButton *buttonOpenMore;
@property(nonatomic , strong) FHTracerModel *tracerModel;
@property (nonatomic , strong) NSMutableDictionary *houseSearchDic;
@property(nonatomic , strong) NSString *requestSearchId;
@property(nonatomic , strong) NSString *requestSearchQuery;
@property(nonatomic , strong) NSString *bannerImageUrl;
@property(nonatomic , strong) NSString *titleTopStr;
@property(nonatomic , strong) NSString *titleBottomStr;
@property(nonatomic , assign) BOOL refreshHasMore;

@end

@implementation FHFalseHouseListViewModel

- (instancetype)initWithTableView:(UITableView *)tableView viewController:(FHFalseHouseListViewController *)viewController routeParam:(TTRouteParamObj *)paramObj
{
    
    self = [super init];
    if (self) {
        
        self.houseList = [NSMutableArray array];
        self.tableView = tableView;
        
        _topHeader = [[FHFalseListTopHeaderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 191)];
        [_topHeader setBackgroundColor:[UIColor whiteColor]];
        
        _currentViewController = viewController;
        
        NSString *houseTypeStr = paramObj.allParams[@"house_type"];
        self.houseType = FHHouseTypeSecondHandHouse;
        self.houseSearchDic = [NSMutableDictionary new];
        
        _requestSearchId = paramObj.allParams[@"searchId"];
        _requestSearchQuery = paramObj.allParams[@"searchQuery"];
        
        self.houseList = [NSMutableArray new];
        
        NSDictionary *tracerDict = paramObj.allParams[@"tracer"];
        if (tracerDict) {
            self.tracerModel = [FHTracerModel makerTracerModelWithDic:tracerDict];
            self.originFrom = self.tracerModel.originFrom;
        }
        
        WeakSelf;
        self.currentViewController.emptyView.retryBlock = ^{
            StrongSelf;
            [self requestErshouHouseListData:YES query:_requestSearchQuery offset:self.houseList.count searchId:self.requestSearchId];
        };
        
        self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
            StrongSelf;
            if ([FHEnvContext isNetworkConnected]) {
                [self requestErshouHouseListData:YES query:_requestSearchQuery offset:self.houseList.count searchId:self.requestSearchId];
            }else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView finishPullUpWithSuccess:YES];
                    });
                });
                [self.tableView.mj_footer endRefreshing];
                [[ToastManager manager] showToast:@"网络异常"];
            }
        }];
        self.refreshFooter.hidden = YES;
        self.tableView.mj_footer = self.refreshFooter;

        [self configBottomFooter];
        [self configTableView];
        
        [viewController tt_startUpdate];
        
        [self requestErshouHouseListData:YES query:_requestSearchQuery offset:self.houseList.count searchId:self.requestSearchId];
    }
    return self;
}

- (void)configBottomFooter
{
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
    
    [self.bottomView setBackgroundColor:[UIColor themeGray7]];
    self.bottomView.hidden = YES;
    
    _buttonOpenMore = [UIButton new];
    if (self.titleBottomStr) {
        [_buttonOpenMore setTitle:self.titleBottomStr forState:UIControlStateNormal];

    }else
    {
        [_buttonOpenMore setTitle:@"免责声明：所有数据基于幸福里大数据进行计算，结果仅供参考" forState:UIControlStateNormal];
    }
    [_buttonOpenMore setBackgroundColor:[UIColor themeGray7]];
    [_buttonOpenMore setTitleColor:[UIColor themeGray3] forState:UIControlStateNormal];
    [_buttonOpenMore.titleLabel setFont:[UIFont themeFontRegular:10]];
    
    [self.bottomView addSubview:_buttonOpenMore];
    [_buttonOpenMore mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.centerY.equalTo(self.bottomView);
        make.height.mas_equalTo(30);
    }];
}

#pragma mark category log
-(void)addEnterCategoryLog {
    
    [FHUserTracker writeEvent:@"enter_category" params:[self categoryLogDict]];

}

-(void)addStayCategoryLog:(NSTimeInterval)stayTime {
    
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHUserTracker writeEvent:@"stay_category" params:tracerDict];
    
}

- (void)addHouseSearchLog {
    NSMutableDictionary *paramsSearch = [NSMutableDictionary new];
    
    paramsSearch[@"house_type"] = @"old";
    paramsSearch[@"origin_search_id"] = self.originSearchId.length > 0 ? self.originSearchId : @"be_null";
    paramsSearch[@"search_id"] =  self.searchId.length > 0 ? self.searchId : @"be_null";
    paramsSearch[@"origin_from"] = self.originFrom.length > 0 ? self.originFrom : @"be_null";
    [paramsSearch setValue:@"old_list" forKey:@"page_type"];
    [paramsSearch setValue:@"driving_find_house" forKey:@"query_type"];
    
    // enter_query 判空
    NSString *enter_query = self.houseSearchDic[@"enter_query"];
    if (enter_query && [enter_query isKindOfClass:[NSString class]]) {
        if (enter_query.length <= 0) {
            paramsSearch[@"enter_query"] = @"be_null";
        }
    } else {
        paramsSearch[@"enter_query"] = @"be_null";
    }
    // search_query 判空
    NSString *search_query = self.houseSearchDic[@"search_query"];
    if (search_query && [search_query isKindOfClass:[NSString class]]) {
        if (search_query.length <= 0) {
            paramsSearch[@"search_query"] = @"be_null";
        }
    } else {
        paramsSearch[@"search_query"] = @"be_null";
    }
    paramsSearch[@"growth_deepevent"] = @(1);
    [FHEnvContext recordEvent:paramsSearch andEventKey:@"house_search"];
}

-(NSDictionary *)categoryLogDict {
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    
    tracerDict[@"category_name"] = [self categoryName] ? : @"be_null";
    tracerDict[@"enter_from"] = self.tracerModel.categoryName ? : @"old_list";
    tracerDict[@"enter_type"] = @"click";
    tracerDict[@"element_from"] = @"be_null";
    tracerDict[@"search_id"] = self.requestSearchId ? : @"be_null";
    tracerDict[@"origin_from"] = self.tracerModel.originFrom ? : @"be_null";
    tracerDict[@"origin_search_id"] = self.originSearchId ? : @"be_null";
    
    return tracerDict;
}

-(NSString *)categoryName {
    return @"false_old_list";
}

- (void)openMoreClick
{
    
}

-(void)configTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:kBaseCellId];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kBaseErrorCellId];
    
}

-(void)requestErshouHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [_requestTask cancel];
    NSMutableDictionary *paramsRequest = [NSMutableDictionary new];
    [paramsRequest setValue:@(self.houseType) forKey:@"house_type"];
//    [paramsRequest setValue:@(50) forKey:@"count"];
    if (_requestSearchId) {
        [paramsRequest setValue:_requestSearchId forKey:@"searchId"];
    }
    
    if (offset == 0) {
        [self.currentViewController startLoading];
    }

    __weak typeof(self) wself = self;
    TTHttpTask *task = [FHHouseListAPI searchFakeHouseList:query params:paramsRequest offset:offset searchId:searchId sugParam:nil class:[FHSearchHouseModel class] completion:^(FHSearchHouseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }
        [wself processData:model error:error];
        
    }];
    
    self.requestTask = task;
}

-(void)processData:(id<FHBaseModelProtocol>)model error: (NSError *)error {
    if (model && !error) {
        
        NSArray *itemArray = nil;
        BOOL hasMore = NO;
        NSString *refreshTip;
        
        [self.currentViewController.emptyView hideEmptyView];
        
        FHSearchHouseDataModel *houseModel = ((FHSearchHouseModel *)model).data;
        hasMore = houseModel.hasMore;
        refreshTip = houseModel.refreshTip;
        itemArray = houseModel.items;
        self.searchId = houseModel.searchId;
        self.bannerImageUrl = houseModel.banner.url;
        self.titleTopStr = houseModel.topTip;
        self.titleBottomStr = houseModel.bottomTip;
        self.refreshHasMore = hasMore;
        
        [itemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            FHSingleImageInfoCellModel *cellModel = [self houseItemByModel:obj];
            cellModel.houseType = FHHouseTypeSecondHandHouse;
            
            if (cellModel) {
                [self.houseList addObject:cellModel];
            }
            
        }];
        
        if (itemArray.count > 0) {
            if (houseModel.searchId) {
                self.originSearchId = houseModel.searchId;
                self.searchId = houseModel.searchId;
            }
            
            [self addEnterCategoryLog];
            
            if (hasMore) {
                self.refreshFooter.hidden = NO;
            }else
            {
                self.refreshFooter.hidden = YES;
            }
            
            self.bottomView.hidden = NO;
            
            self.tableView.hasMore = houseModel.hasMore;
            [self.tableView.mj_footer endRefreshing];
            self.tableView.scrollEnabled = YES;
            [self.tableView reloadData];
        }else
        {
            [self.tableView.mj_footer endRefreshing];
            self.bottomView.hidden = NO;
            self.tableView.hasMore = houseModel.hasMore;
            self.refreshFooter.hidden = YES;
            [self.tableView reloadData];
        }
        
    }else
    {
        [self.tableView reloadData];
        self.bottomView.hidden = YES;
        self.tableView.scrollEnabled = NO;
        
        self.currentViewController.emptyView.hidden = NO;
        [self.currentViewController.emptyView showEmptyWithTip:@"网络异常请重试" errorImage:[UIImage imageNamed:@"group-4"] showRetry:YES];
    }
    
    [self addHouseSearchLog];
    
    [self.currentViewController endLoading];
}

-(FHSingleImageInfoCellModel *)houseItemByModel:(id)obj {
    
    FHSingleImageInfoCellModel *cellModel = [[FHSingleImageInfoCellModel alloc]init];
    
    if ([obj isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
        
        cellModel.secondModel  = (FHSearchHouseDataItemsModel *)obj;
        
    }else if ([obj isKindOfClass:[FHNewHouseItemModel class]]) {
        
        cellModel.houseModel = (FHSearchHouseDataItemsModel *)obj;
        
    }else if ([obj isKindOfClass:[FHHouseRentDataItemsModel class]]) {
        
        cellModel.rentModel  = (FHHouseRentDataItemsModel *)obj;
        
    } else if ([obj isKindOfClass:[FHHouseNeighborDataItemsModel class]]) {
        
         cellModel.neighborModel = (FHHouseNeighborDataItemsModel *)obj;
        
    }else if ([obj isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
        
        cellModel.subscribModel = (FHSugSubscribeDataDataSubscribeInfoModel *)obj;
        
    }
    return cellModel;
}

- (NSString *)getNoneFilterQueryWithParams:(NSDictionary *)params
{
    NSMutableString* result = [[NSMutableString alloc] init];
    NSMutableSet<NSString*>* allKeys = [[NSMutableSet alloc] init];
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![allKeys containsObject:key]) {
            if ([obj isKindOfClass:[NSArray class]]) {
                NSArray* items = (NSArray*)obj;
                [items enumerateObjectsUsingBlock:^(id  _Nonnull it, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString* query = [self encodingIfNeeded:[NSString stringWithFormat:@"&%@=%@", key, it]];
                    [result appendString:query];
                }];
            } else {
                NSString* query = [self encodingIfNeeded:[NSString stringWithFormat:@"&%@=%@", key, obj]];
                [result appendString:query];
            }
        }
    }];
    return result;
}

- (NSString *)encodingIfNeeded:(NSString *)queryCondition
{
    if (![queryCondition containsString:@"%"]) {
        return [[queryCondition stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    }
    return queryCondition;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _houseList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHHouseBaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kBaseCellId];
    if (indexPath.row < self.houseList.count) {
        FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
        [cell refreshTopMargin: 20];
        [cell updateWithHouseCellModel:cellModel];
        
        if (cellModel.secondModel.fakeReason) {
            [cell updateFakeHouseImageWithUrl:cellModel.secondModel.fakeReason.fakeReasonImage.url andSourceStr:cellModel.secondModel.externalInfo.externalName];
        }
        return cell;
    }else
    {
        return [UITableViewCell new];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        if (indexPath.row < self.houseList.count) {
            
            FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
            if (![self.houseShowCache.allKeys containsObject:cellModel.houseId] && cellModel.houseId) {
                [self addHouseShowLog:cellModel withRank:indexPath.row];
                self.houseShowCache[cellModel.houseId] = @"1";
            }
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.houseList.count) {
        FHSingleImageInfoCellModel *cellModel  = nil;
        BOOL isLastCell = NO;
        
        cellModel = self.houseList[indexPath.row];
        
        isLastCell = (indexPath.row == self.houseList.count - 1);
        CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHHouseBaseItemCell recommendReasonHeight] : 0;
        return (isLastCell ? 125 : 105) + reasonHeight;
    }
    return 105;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.bannerImageUrl) {
        [_topHeader refreshUI:self.titleTopStr andImageUrl:[NSURL URLWithString:self.bannerImageUrl]];
    }
    return _topHeader;
}// custom view for header. will be adjusted to default or specified header height


- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.refreshHasMore) {
        _bottomView.hidden = YES;
        return nil;
    }
    return _bottomView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 168;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.refreshHasMore) {
        return 0;
    }
    return 30;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.houseList.count) {
        FHSingleImageInfoCellModel *cellModel  = nil;
        BOOL isLastCell = NO;
        
        cellModel = self.houseList[indexPath.row];
        
        NSMutableDictionary *tracerDict = @{}.mutableCopy;
        tracerDict[@"card_type"] = @"left_pic";
        tracerDict[@"page_type"] = @"old_detail";
        tracerDict[@"enter_from"] = @"false_old_list";
        tracerDict[@"element_from"] = @"be_null";
        tracerDict[@"rank"] = @(indexPath.row);
        tracerDict[@"origin_from"] = self.originFrom;
        tracerDict[@"origin_search_id"] = self.originSearchId ? : @"be_null";
        tracerDict[@"log_pb"] = [cellModel logPb] ? : @"be_null";
        [FHUserTracker writeEvent:@"click_house" params:tracerDict];
        
    }
}

#pragma mark house_show log
-(void)addHouseShowLog:(FHSingleImageInfoCellModel *)cellModel withRank: (NSInteger) rank {
    if (!cellModel) {
        return;
    }
    
    NSString *originFrom = self.originFrom ? : @"be_null";
    
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"house_type"] = @"old";
    tracerDict[@"card_type"] = @"left_pic";
    tracerDict[@"page_type"] = @"false_old_list";
    tracerDict[@"search_id"] = self.searchId ? : @"be_null";
    tracerDict[@"group_id"] = [cellModel groupId] ? : @"be_null";
    tracerDict[@"impr_id"] = [cellModel imprId] ? : @"be_null";
    tracerDict[@"rank"] = @(rank);
    tracerDict[@"element_from"] = @"be_null";
    tracerDict[@"origin_from"] = originFrom;
    tracerDict[@"origin_search_id"] = self.originSearchId ? : @"be_null";
    tracerDict[@"log_pb"] = [cellModel logPb] ? : @"be_null";
    
    [FHUserTracker writeEvent:@"house_show" params:tracerDict];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

#pragma mark - 埋点相关
-(NSMutableDictionary *)houseShowCache {
    
    if (!_houseShowCache) {
        _houseShowCache = [NSMutableDictionary dictionary];
    }
    return _houseShowCache;
}

@end
