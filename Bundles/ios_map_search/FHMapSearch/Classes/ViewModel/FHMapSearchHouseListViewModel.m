//
//  FHMapSearchHouseListViewModel.m
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "FHMapSearchHouseListViewModel.h"
#import "MJRefresh.h"
#import "UIViewAdditions.h"
#import "Masonry.h"
#import "FHRefreshCustomFooter.h"
#import "FHSearchHouseModel.h"
#import "FHHouseAreaHeaderView.h"
#import "FHMapSearchHouseListViewController.h"
#import "FHMapSearchModel.h"
#import "FHHouseSearcher.h"
#import "FHMapSearchConfigModel.h"
#import "UIViewController+HUD.h"
#import "FHUserTracker.h"
#import "FHMainManager+Toast.h"
#import "FHMapSearchBubbleModel.h"
#import "FHHouseBridgeManager.h"
#import "FHMapSearchBubbleModel.h"
#import "FHMainApi.h"
#import "TTReachability.h"
#import <FHHouseBase/FHHouseBaseItemCell.h>
#import "FHSingleImageInfoCellModel.h"
#import <Heimdallr/HMDTTMonitor.h>
#import <FHHouseBase/FHSearchChannelTypes.h>
#import "FHHouseListBaseItemCell.h"
#import "FHHouseListBaseItemModel.h"
#import "FHMapSearchSecondCell.h"
#import "FHEnvContext.h"
#import "FHPlaceHolderCell.h"

#define kCellId @"singleCellId"

@interface FHMapSearchHouseListViewModel ()<UIGestureRecognizerDelegate>

@property(nonatomic , strong) UITableView *tableView;
@property(nonatomic , strong) NSMutableArray *houseList;
@property(nonatomic , strong) FHMapSearchDataListModel *neighbor;
@property(nonatomic , strong) NSString *searchId;
@property(nonatomic , strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic , assign) NSTimeInterval startTimestamp;
@property(nonatomic , weak)   TTHttpTask * requestTask;
@property(nonatomic , assign) BOOL enteredFullListPage;
@property(nonatomic , assign) CGPoint currentOffset;
@property(nonatomic , assign) BOOL dismissing;
@property(nonatomic , strong) FHMapSearchDataListModel *currentNeighbor;
@property(nonatomic , strong) FHMapSearchBubbleModel *currentBubble;
@property(nonatomic , strong) NSMutableDictionary *houseLogs;
@property(nonatomic , strong) FHHouseListDataModel *currentHouseDataModel;
@property(nonatomic , strong) FHSearchHouseDataModel *currentRentDataModel;
@property(nonatomic , assign) BOOL showPlaceHolder;
//for rent house list


@end

@implementation FHMapSearchHouseListViewModel

-(instancetype)initWithController:(FHMapSearchHouseListViewController *)viewController tableView:(UITableView *)tableView
{
    self = [super init];
    if (self) {
        _houseList = [NSMutableArray new];
        _houseLogs = [NSMutableDictionary new];
        self.listController = viewController;
        self.tableView = tableView;
        self.showPlaceHolder = YES;
        [self configTableView];
        
    }
    return self;
}

-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    __weak typeof(self) wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself loadHouseData:NO];
    }];
    [_refreshFooter setUpNoMoreDataText:@"没有更多信息了"];
    self.tableView.mj_footer = _refreshFooter;
    
//    [_tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:kCellId];
     [_tableView registerClass:[FHHouseListBaseItemCell class] forCellReuseIdentifier:kCellId];
    [_tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:NSStringFromClass([FHPlaceHolderCell class])];
     [_tableView registerClass:[FHMapSearchSecondCell class] forCellReuseIdentifier:NSStringFromClass([FHMapSearchSecondCell class])];
    
    [self setupPannableGesture];
}

-(void)setHeaderView:(FHHouseAreaHeaderView *)headerView
{
    _headerView = headerView;
    _tableView.tableHeaderView = _headerView;
    [headerView addTarget:self action:@selector(showNeighborDetail) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setMaskView:(FHErrorMaskView *)maskView
{
    _maskView = maskView;
    maskView.hidden = YES;
    __weak typeof(self) wself = self;
    _maskView.retryBlock = ^{
        [wself reloadingHouseData:nil];
    };
    
    
}

-(void)showMaskView:(BOOL)show
{
    self.maskView.hidden = !show;
    
//    [self.maskView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(self.listController.view.superview.height - [self.listController minTop]);
//    }];
//    self.maskView.height = self.listController.view.superview.height - [self.listController minTop];
    
}

-(FHMapSearchShowMode)enterShowMode
{
    return self.currentBubble.lastShowMode;
}

-(void)updateWithHouseData:(FHSearchHouseDataModel *_Nullable)data neighbor:(FHMapSearchDataListModel *)neighbor bubble:(FHMapSearchBubbleModel *)bubble
{
    if (self.requestTask.state == TTHttpTaskStateRunning) {
        [self.requestTask cancel];
    }
    self.currentNeighbor = neighbor;
    [_headerView updateWithMode:neighbor houseType:bubble.houseType];
    
    [_houseList removeAllObjects];
    [_houseLogs removeAllObjects];
    self.neighbor = neighbor;
    self.currentBubble = bubble;
    
    [self showMaskView:NO];
    if (data) {
        self.showPlaceHolder = NO;
        [_houseList addObjectsFromArray:data.items];
        self.searchId = data.searchId;
        if (data.hasMore) {
            [self.tableView.mj_footer resetNoMoreData];
        }else{
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    } else {
        self.showPlaceHolder = YES;
        self.searchId = nil;
        [self reloadingHouseData:nil];
    }
    [self.tableView reloadData];
    self.tableView.contentOffset = CGPointZero;
    
    self.startTimestamp = [[NSDate date] timeIntervalSince1970];
    if (neighbor) {
        [self addNeighborShowLog:self.neighbor];
    }
}

-(void)showNeighborDetail
{
    if (self.listController.showNeighborhoodDetailBlock) {
//        [self addShowNeighborDetailLog:self.neighbor];
        self.listController.showNeighborhoodDetailBlock(self.neighbor,self.currentBubble);
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.showPlaceHolder) {
        return 10;
    }
    return _houseList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.showPlaceHolder) {
        FHPlaceHolderCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHPlaceHolderCell class])];
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    FHHouseListBaseItemModel *cellModel = self.houseList[indexPath.row];
    if([cellModel isKindOfClass:[FHHouseListBaseItemModel class]]){
        if ([FHEnvContext isDisplayNewCardType]) {
            FHMapSearchSecondCell *secondCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHMapSearchSecondCell class])];
            [secondCell refreshWithData:cellModel];
            return secondCell;
        }
                      FHHouseListBaseItemCell *imageInfoCell = (FHHouseListBaseItemCell *)cell;
                        [imageInfoCell refreshWithData:cellModel];
                        
    }else{
        if([cellModel isKindOfClass:[FHSearchHouseDataItemsModel class]]){
            if ([cell isKindOfClass:[FHHouseListBaseItemCell class]]) {
                FHHouseListBaseItemCell *imageInfoCell = (FHHouseListBaseItemCell *)cell;
                [imageInfoCell refreshWithData:cellModel];
                
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.showPlaceHolder) {
        return;
    }
    [self addHouseShowLog:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    id model = _houseList[indexPath.row];
//    if([model isKindOfClass:[FHHouseRentDataItemsModel class]]){
//        FHHouseRentDataItemsModel *rentModel = (FHHouseRentDataItemsModel *)model;
//        if (self.listController.showRentHouseDetailBlock) {
//            self.listController.showRentHouseDetailBlock(rentModel, indexPath.row,self.currentBubble);
//        }
//    }else if([model isKindOfClass:[FHSearchHouseDataItemsModel class]]){
//        FHSearchHouseDataItemsModel *houseModel = (FHSearchHouseDataItemsModel *)model;
//        if (self.listController.showHouseDetailBlock) {
//            self.listController.showHouseDetailBlock(model,indexPath.row,self.currentBubble);
//        }
//    }
    if (self.showPlaceHolder) {
        return;
    }
    FHHouseListBaseItemModel *model = _houseList[indexPath.row];
       if(model.houseType == FHHouseTypeRentHouse){
           if (self.listController.showRentHouseDetailBlock) {
               self.listController.showRentHouseDetailBlock(model, indexPath.row,self.currentBubble);
           }
       }else if(model.houseType == FHHouseTypeSecondHandHouse){
           if (self.listController.showHouseDetailBlock) {
               self.listController.showHouseDetailBlock(model,indexPath.row,self.currentBubble);
           }
       }
}

-(void)dismiss
{
    [self handleDismiss:0.3];
}

-(void)handleDismiss:(CGFloat)duration
{
    if (_dismissing) {
        return;
    }
    self.dismissing = YES;
    if (self.listController.willSwipeDownDismiss) {
        self.listController.willSwipeDownDismiss(duration,self.currentBubble);
    }
    [UIView animateWithDuration:duration animations:^{
        self.listController.view.top = self.listController.parentViewController.view.height;
    } completion:^(BOOL finished) {
        if (self.listController.didSwipeDownDismiss) {
            self.listController.didSwipeDownDismiss(self.currentBubble);
        }
        self.dismissing = NO;
    }];
    [self.tableView.mj_footer resetNoMoreData];
    
    [self addHouseListDurationLog];
}


-(void)overwirteCondition:(NSString *)condition
{
    if (condition) {
        [self.currentBubble overwriteFliter:condition];
    }
    self.condition = condition;
}

-(void)reloadingHouseData:(NSString *)condition
{
    if (condition) {
        [self.currentBubble overwriteFliter:condition];
    }
    self.condition = condition;
    
    CGPoint offset = CGPointMake(0, -(self.listController.view.bottom - self.listController.view.superview.height));
//    [self.listController showLoadingAlert:nil offset:offset];
    [self.houseList removeAllObjects];
    [self.tableView reloadData];
    [self loadHouseData:YES];
    self.tableView.mj_footer.hidden = YES;
}

-(void)loadHouseData:(BOOL)showLoading
{
    if (showLoading) {
        self.currentHouseDataModel = nil;
        self.currentRentDataModel = nil;
    }
    if (self.requestTask.state == TTHttpTaskStateRunning) {
        [self.requestTask cancel];
    }
    NSMutableDictionary *param = [NSMutableDictionary new];
    NSString *query = nil;
    if (self.currentBubble) {
        
        if (self.currentBubble.houseType == FHHouseTypeRentHouse) {
            [self loadRentHouseData:showLoading];
            return;
        }
        
        //使用openurl
        param[HOUSE_TYPE_KEY] = @(self.currentBubble.houseType);
        query = [self.currentBubble query];
        
    }else{
        if (self.neighbor.nid) {
            param[NEIGHBORHOOD_ID_KEY] = self.neighbor.nid;
        }
        param[HOUSE_TYPE_KEY] = @(self.configModel.houseType);
    }
    if (self.searchId) {
        param[@"search_id"] = self.searchId;
    }
    
    if (query.length == 0) {
        query = self.configModel.conditionQuery;
    }
    
    if (![TTReachability isNetworkConnected]) {
        if (showLoading) {
            [self.listController dismissLoadingAlert];
            [self.maskView showErrorWithTip:@"网络异常，请检查网络连接"];
            [self.maskView showRetry:YES];
            [self showMaskView:YES];
        }else{
            [[FHMainManager sharedInstance]showToast:@"网络异常" duration:1];
            [self.tableView.mj_footer endRefreshing];
        }
        return ;
    }
    
    if (self.currentBubble.lastShowMode == FHMapSearchShowModeSubway) {
        param[CHANNEL_ID] = CHANNEL_ID_SUBWAY_HOUSE_HOUSE_LIST;
        if (query.length > 0) {
            query = [NSString stringWithFormat:@"%@&%@=%@",query,CHANNEL_ID,CHANNEL_ID_SUBWAY_HOUSE_HOUSE_LIST];
        }else {
            query = [NSString stringWithFormat:@"%@=%@",CHANNEL_ID,CHANNEL_ID_SUBWAY_HOUSE_HOUSE_LIST];
        }
    }else if (self.currentBubble.lastShowMode == FHMapSearchShowModeDrawLine) {

        if (query.length > 0) {
            query = [NSString stringWithFormat:@"%@&%@=%@",query,CHANNEL_ID,CHANNEL_ID_CIRCEL_SEARCH];
        }else {
            query = [NSString stringWithFormat:@"%@=%@",CHANNEL_ID,CHANNEL_ID_CIRCEL_SEARCH];
        }
    } else {
        if (query.length > 0) {
            query = [NSString stringWithFormat:@"%@&%@=%@",query,CHANNEL_ID,CHANNEL_ID_MAP_FIND_HOUSE];
        }else {
            query = [NSString stringWithFormat:@"%@=%@",CHANNEL_ID,CHANNEL_ID_MAP_FIND_HOUSE];
        }
    }
    
    if (![query containsString:@"house_type"]) {
        query = [NSString stringWithFormat:@"%@&house_type=%ld",query,self.configModel.houseType];
    }
    
    __weak typeof(self) wself = self;
    TTHttpTask *task = [FHHouseSearcher houseSearchWithQuery:query param:param offset:self.currentHouseDataModel.offset class:[FHListResultHouseModel class] needCommonParams:YES callback:^(NSError * _Nullable error, id<FHBaseModelProtocol> _Nullable modelData) {
        
        if (!wself) {
            return ;
        }
        if (showLoading) {
            [wself.listController dismissLoadingAlert];
        }
                
        if (!error && modelData) {
            FHHouseListDataModel *houseModel = (FHHouseListDataModel*)((FHListResultHouseModel *)modelData).data;
            wself.searchId = houseModel.searchId;
            wself.currentHouseDataModel = houseModel;
            [wself addEnterListPageLog];
            if (showLoading) {
                [wself addHouseListShowLog:wself.neighbor houseListModel:houseModel];
            }
            
            if (wself.houseList.count == 0) {
                //first page
                wself.currentNeighbor.onSaleCount = houseModel.total;
                [wself.headerView updateWithMode:wself.currentNeighbor houseType:FHHouseTypeSecondHandHouse];
                
//                NSString *toast = [NSString stringWithFormat:@"共找到%@套房源",houseModel.total];
//                [[FHMainManager sharedInstance] showToast:toast duration:1];
            }
            self.showPlaceHolder = NO;
            [wself.houseList addObjectsFromArray:houseModel.items];
            [wself.tableView reloadData];
            if (houseModel.hasMore) {
                [wself.tableView.mj_footer endRefreshing];
            }else{
                [wself.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            wself.tableView.mj_footer.hidden = NO;
        
            if (wself.houseList.count < 10 && !houseModel.hasMore) {
                wself.tableView.mj_footer.hidden = YES;
            }
            
            if (wself.houseList.count == 0) {
                //没有数据 提示数据走丢了
                NSString *tip = nil;
                BOOL showRetry = YES;
                if ([wself.condition containsString:@"&"]) {
                    tip = @"暂无搜索结果";
                    showRetry = NO;
                }else{
                    tip = @"数据走丢了";
                }
                
                [wself.maskView showErrorWithTip:tip];
                [wself.maskView showRetry:showRetry];
                [wself showMaskView:YES];
            }else{
                [wself showMaskView:NO];
            }
        }else{
            if (error) {
                if (error.code == NSURLErrorCancelled) {
                    //用户主动取消
                    return;
                }
                
                if (showLoading) {
                    [wself.maskView showErrorWithTip:@"网络异常，请检查网络连接"];
                    [wself.maskView showRetry:YES];
                    [wself showMaskView:YES];
                }else{
                    [[FHMainManager sharedInstance] showToast:@"房源请求失败" duration:2];
                }
                [[HMDTTMonitor defaultManager] hmdTrackService:@"map_house_request_failed" attributes:@{@"message":error.domain?:@""}];
            }else{
                [wself showMaskView:NO];
            }
        }
    }];
    
    self.requestTask = task;
    if (!showLoading) {
        [self addHouseListLoadMoreLog];
    }
}

-(void)loadRentHouseData:(BOOL)showLoading
{
    NSMutableDictionary *param = [NSMutableDictionary new];
    NSString *query = nil;

    param[HOUSE_TYPE_KEY] = @(self.currentBubble.houseType);
    query = [self.currentBubble query];
    if (self.searchId) {
        param[@"search_id"] = self.searchId;
    }


    if (query.length == 0) {
        query = self.configModel.conditionQuery;
    }

    if (![TTReachability isNetworkConnected]) {
        if (showLoading) {
            [self.listController dismissLoadingAlert];
            [self.maskView showErrorWithTip:@"网络异常，请检查网络连接"];
            [self.maskView showRetry:YES];
            [self showMaskView:YES];
        }else{
            [[FHMainManager sharedInstance]showToast:@"网络异常" duration:1];
            [self.tableView.mj_footer endRefreshing];
        }
        return ;
    }
    if (query.length > 0) {
        query = [NSString stringWithFormat:@"%@&%@=%@",query,CHANNEL_ID,CHANNEL_ID_MAP_FIND_RENT];
    }else {
        query = [NSString stringWithFormat:@"%@=%@",CHANNEL_ID,CHANNEL_ID_MAP_FIND_RENT];
    }
    __weak typeof(self) wself = self;
    /*
     +(TTHttpTask *)searchRent:(NSString *_Nullable)query params:(NSDictionary *_Nullable)param offset:(NSInteger)offset searchId:(NSString *_Nullable)searchId sugParam:(NSString *_Nullable)sugParam completion:(void(^_Nullable)(FHHouseRentModel *model , NSError *error))completion
     */
    TTHttpTask *task = [FHMainApi searchRent:query params:param offset:self.houseList.count searchId:self.searchId sugParam:nil class:[FHListResultHouseModel class] completion:(FHMainApiCompletion)^(FHListResultHouseModel * _Nonnull model, NSError * _Nonnull error) {
        
        if (!wself) {
            return ;
        }
        if (showLoading) {
            [wself.listController dismissLoadingAlert];
        }
        
        FHHouseListDataModel *houseModel = model.data;
        
        if (!error && houseModel) {
            wself.searchId = houseModel.searchId;
            wself.currentRentDataModel = houseModel;
            [wself addEnterListPageLog];
            if (showLoading) {
                [wself addHouseListShowLog:wself.neighbor houseListModel:houseModel];
            }
            
            if (wself.houseList.count == 0) {
                //first page
                wself.currentNeighbor.onSaleCount = houseModel.total;
                [wself.headerView updateWithMode:wself.currentNeighbor houseType:FHHouseTypeRentHouse];
                
//                NSString *toast = [NSString stringWithFormat:@"共找到%@套房源",houseModel.total];
//                [[FHMainManager sharedInstance] showToast:toast duration:1];
            }
            self.showPlaceHolder = NO;
            [wself.houseList addObjectsFromArray:houseModel.items];
            [wself.tableView reloadData];
            if (houseModel.hasMore) {
                [wself.tableView.mj_footer endRefreshing];
            }else{
                [wself.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            wself.tableView.mj_footer.hidden = NO;
            
            
            if (wself.houseList.count < 10 && !houseModel.hasMore) {
                wself.tableView.mj_footer.hidden = YES;
            }
            
            if (wself.houseList.count == 0) {
                //没有数据 提示数据走丢了
                NSString *tip = nil;
                BOOL showRetry = YES;
                if ([wself.condition containsString:@"&"]) {
                    tip = @"暂无搜索结果";
                    showRetry = NO;
                }else{
                    tip = @"数据走丢了";
                }
                
                [wself.maskView showErrorWithTip:tip];
                [wself.maskView showRetry:showRetry];
                [wself showMaskView:YES];
            }else{
                [wself showMaskView:NO];
            }
        }else{
            if (error) {
                if (error.code == NSURLErrorCancelled) {
                    //用户主动取消
                    return;
                }
                if (showLoading) {
                    [wself.maskView showErrorWithTip:@"网络异常，请检查网络连接"];
                    [wself.maskView showRetry:YES];
                    [wself showMaskView:YES];
                }else{
                    [[FHMainManager sharedInstance] showToast:@"房源请求失败" duration:2];
                }
                [[HMDTTMonitor defaultManager] hmdTrackService:@"map_house_request_failed" attributes:@{@"message":error.domain?:@""}];
            }else{
                [wself showMaskView:NO];
            }
        }
    }];
    
    self.requestTask = task;
    if (!showLoading) {
        [self addHouseListLoadMoreLog];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.startTimestamp = [[NSDate date] timeIntervalSince1970];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self addHouseListDurationLog];
}


#pragma mark - log

-(NSString *)enterFrom
{
    if (self.currentBubble.lastShowMode == FHMapSearchShowModeDrawLine) {
        return @"circlefind";
    }else if (self.currentBubble.lastShowMode == FHMapSearchShowModeSubway){
        return @"subwayfind";
    }
    return @"mapfind";
}

-(NSMutableDictionary *)logBaseParams
{
    NSMutableDictionary *param = [NSMutableDictionary new];
    NSString *enterFrom = nil;
//    if (self.configModel.houseType == FHHouseTypeRentHouse) {
        enterFrom = self.configModel.enterFrom;
//    }else{
//        enterFrom = @"mapfind";
//    }
    
    param[@"enter_from"] = enterFrom;
    param[@"category_name"] = @"same_neighborhood_list";
    param[@"element_from"] = @"half_category";
    param[@"search_id"] = self.searchId?:@"be_null";
    param[@"origin_from"] = self.configModel.originFrom?:@"be_null";
    param[@"origin_search_id"] = self.configModel.originSearchId ?: @"be_null";
 
    return param;
}

-(void)addEnterListPageLog
{
    if (_enteredFullListPage) {
        return;
    }
    _enteredFullListPage = YES;
    NSMutableDictionary *param = [self logBaseParams];
    param[@"category_name"] = @"same_neighborhood_list";
    param[@"enter_type"] = @"slide_up";
    param[@"enter_from"] = [self enterFrom]; // 地图找房页
    
    [FHUserTracker writeEvent:@"enter_category" params:param];
}

-(void)addHouseListDurationLog
{
    if (!_enteredFullListPage) {
        return;
    }
    _enteredFullListPage = NO;
    
    NSTimeInterval duration = [[NSDate date]timeIntervalSince1970] - _startTimestamp;
    if (duration < 0.5 || duration > 60*60) {
        //invalid log
        return;
    }
    
    
    NSMutableDictionary *param = [self logBaseParams];
    param[@"stay_time"] = [NSNumber numberWithInteger:duration*1000];

    param[@"enter_type"] = @"slide_up";
    param[@"enter_from"] = [self enterFrom];

    [FHUserTracker writeEvent:@"stay_category" params:param];
    _startTimestamp = 0;
}

-(void)addHouseListLoadMoreLog
{
   NSMutableDictionary *param = [self logBaseParams];
    param[@"refresh_type"] = @"pre_load_more";
    param[@"enter_type"] = @"slide_up";
    param[@"enter_from"] = [self enterFrom];
    param[UT_LOG_PB] = UT_BE_NULL;
    [FHUserTracker writeEvent:@"category_refresh" params:param];
}

-(void)addNeighborShowLog:(FHMapSearchDataListModel *)neighbor
{
    NSMutableDictionary *param = [self logBaseParams];
    
    param[@"house_type"] = @"neighborhood";
    param[@"page_type"] =  [self enterFrom];
    param[@"card_type"] = @"no_pic";
    param[@"element_type"] = @"half_category";
    param[@"group_id"] = neighbor.logPb.groupId ?: @"be_null";
    param[@"impr_id"] = neighbor.logPb.imprId ?: @"be_null";
    param[@"search_id"] = neighbor.logPb.searchId ?: @"be_null";
    param[@"rank"] = @"0";
    if (neighbor.logPb) {
        param[@"log_pb"] = [neighbor.logPb toDictionary];
    }
    param[@"category_name"] = nil;
    param[@"element_from"] = nil;
    [FHUserTracker writeEvent:@"house_show" params:param];
}

-(void)addHouseShowLog:(NSIndexPath *)indexPath
{
//    id model = _houseList[indexPath.row];
//    NSDictionary *logPb;
//    NSString *imprId;
//    if([model isKindOfClass:[FHHouseRentDataItemsModel class]]){
//        FHHouseRentDataItemsModel *rentModel = (FHHouseRentDataItemsModel *)model;
//        logPb = rentModel.logPb;
//        imprId = rentModel.imprId;
//    }else{
//        FHSearchHouseDataItemsModel *item = _houseList[indexPath.row];
//        logPb = item.logPb;
//        imprId = item.imprId;
//    }
//
    if (_houseList.count == 0) {
        return;
    }
    
    FHHouseListBaseItemModel *model = _houseList[indexPath.row];
    NSDictionary *logPb = model.logPb;
    NSString *imprId = model.imprId;;
    if (_houseLogs[@(indexPath.row)]) {
        return;
    }
    NSMutableDictionary *param = [self logBaseParams];
    
    param[@"house_type"] = [_configModel houseTypeName]?:@"old";
    param[@"page_type"] =  [self enterFrom];
    param[@"card_type"] = @"left_pic";
    param[@"group_id"] = logPb[@"group_id"] ?: @"be_null";
    param[@"search_id"] = logPb[@"search_id"] ?: @"be_null";
    param[@"impr_id"] = imprId ?: @"be_null";
    param[@"rank"] = [NSString stringWithFormat:@"%@", @(indexPath.row+1)]; //小区是0 
    if ([self.listController canMoveup]) {
        param[@"element_type"] = @"half_category";
    }else{
        param[@"element_type"] = @"be_null";
    }
    
    if (logPb) {
        param[@"log_pb"] = logPb;
    }
    param[@"category_name"] = nil;
    param[@"element_from"] = nil;
    [FHUserTracker writeEvent:@"house_show" params:param];
    _houseLogs[@(indexPath.row)] = @(1);
}

-(void)addHouseListShowLog:(FHMapSearchDataListModel*)model houseListModel:(FHSearchHouseDataModel *)houseDataModel
{
    NSMutableDictionary *param = [self logBaseParams];
    param[@"search_id"] = houseDataModel.searchId;
    param[@"category_name"] = nil;
    param[@"element_from"] = nil;
    
    if (self.currentBubble.lastShowMode == FHMapSearchShowModeDrawLine) {
        param[UT_ENTER_FROM] = @"mapfind";
        TRACK_EVENT(@"circlefind_half_category", param);
    }else if (self.currentBubble.lastShowMode == FHMapSearchShowModeSubway){
        param[UT_ENTER_FROM] = @"mapfind";
        TRACK_EVENT(@"subwayfind_half_category", param);
    }else{
        TRACK_EVENT(@"mapfind_half_category", param);
    }
}

#pragma mark - 列表滑动交互
- (void)setupPannableGesture {
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGR.delegate = self;
    [self.tableView addGestureRecognizer:panGR];
    
    self.listController.view.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panGR2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.listController.view addGestureRecognizer:panGR2];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && otherGestureRecognizer.view == self.tableView);
}

static BOOL canPan = NO;
- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint velocity = [gesture velocityInView:self.listController.view];
            canPan = [self canPanWithVelocity:velocity];
            self.tableView.scrollEnabled = !canPan;
            if (canPan) {
                self.tableView.contentOffset = CGPointZero;
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint velocity = [gesture velocityInView:self.listController.view];
            canPan = [self canPanWithVelocity:velocity];
            self.tableView.scrollEnabled = !canPan;
            if (canPan) {
                self.tableView.contentOffset = CGPointZero;
            }
            
            if (!canPan) {
                [gesture setTranslation:CGPointMake(0, 0) inView:gesture.view];
                return;
            }
            
            CGFloat minTop = [self.listController minTop];
            CGFloat offsetY = [gesture translationInView: self.listController.view].y;
            CGFloat listTop = self.listController.view.top + offsetY;
            if (listTop < minTop) {
                listTop = minTop;
            }
            self.listController.view.top = listTop;
            if (self.listController.movingBlock) {
                self.listController.movingBlock(self.listController.view.top);
            }
 
            [gesture setTranslation:CGPointMake(0, 0) inView:gesture.view];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled: {
            if (!canPan) return;
            CGPoint velocity = [gesture velocityInView:self.listController.view];
            [self moveIfNeedWithVelocity:velocity];
            break;
        }
        default:
            break;
    }
}

- (BOOL)canPanWithVelocity:(CGPoint)velocity {
    //列表页内容不满一屏
    if (self.tableView.height >= self.tableView.contentSize.height) {
        return YES;
    }
    
    //列表不在最顶部
    if (self.listController.view.top > [self.listController minTop]) {
        return YES;
    }
    
    //列表内容滚到顶部，向下拉
    if (self.tableView.contentOffset.y <= 0 && velocity.y > 0) {
        return YES;
    }
    
    return NO;
}

- (void)moveIfNeedWithVelocity:(CGPoint)velocity {
    CGFloat currentH = self.listController.view.superview.height - self.listController.view.top;
    CGFloat initH = self.listController.view.superview.height - [self.listController initialTop];
    CGFloat maxH = self.listController.view.superview.height;
    CGFloat minH = 0;
    if (fabs(velocity.y) < 500) {
        //慢速松手
        if (currentH >= initH + (maxH - initH) / 2) {
            [self moveToTop];
        } else if (currentH < initH + (maxH - initH) / 2 && currentH >= minH + (initH - minH) / 2) {
            [self moveToMiddle];
        } else {
            [self moveToBottom];
        }
    } else {
        //快速松手
        if (velocity.y > 0) {
            if (currentH > initH) {
                [self moveToMiddle];
            } else {
                [self moveToBottom];
            }
        } else {
            if (currentH > initH) {
                [self moveToTop];
            } else {
                [self moveToMiddle];
            }
        }
    }
}

- (void)moveToMiddle {
    __weak typeof(self) wself = self;
    [self.listController moveTop:[self.listController initialTop] completion:^(BOOL finished) {
        __strong typeof(wself) self = wself;
        self.tableView.scrollEnabled = NO;
    }];
    self.listController.moveDock();
}

- (void)moveToTop {
    __weak typeof(self) wself = self;
    [self.listController moveTop:0 completion:^(BOOL finished) {
        __strong typeof(wself) self = wself;
        self.tableView.scrollEnabled = YES;//(self.tableView.height < self.tableView.contentSize.height);
    }];
}

- (void)moveToBottom {
    [self handleDismiss:0.3];
}

@end
