//
//  FHBaseMainListViewModel.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/8.
//

#import "FHBaseMainListViewModel.h"
#import <FHHouseBase/FHHouseBridgeManager.h>
#import "FHConditionFilterViewModel.h"
#import <FHHouseBase/FHConfigModel.h>
#import <FHHouseBase/FHHouseRentModel.h>
#import <TTNetworkManager/TTHttpTask.h>
#import <FHHouseBase/FHSearchFilterOpenUrlModel.h>
#import <FHHouseBase/FHPlaceHolderCell.h>
#import <TTRoute/TTRoute.h>
#import <FHCommonUI/FHRefreshCustomFooter.h>
#import <TTReachability/TTReachability.h>
#import <FHHouseBase/FHMainManager+Toast.h>
#import <FHHouseBase/FHMainApi.h>
#import <TTUIWidget/UIScrollView+Refresh.h>
#import "FHBaseMainListViewController.h"
#import <FHHouseBase/FHTracerModel.h>
#import <FHHouseBase/FHUserTracker.h>
#import <FHHouseBase/FHEnvContext.h>
#import <FHHouseBase/FHCommonDefines.h>
#import <TTUIWidget/UIViewController+Track.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <FHHouseBase/FHSearchHouseModel.h>
#import <FHHouseBase/FHRecommendSecondhandHouseTitleModel.h>
#import <FHHouseBase/FHSingleImageInfoCellModel.h>
#import <FHHouseBase/FHRecommendSecondhandHouseTitleCell.h>
#import <FHHouseBase/FHSingleImageInfoCell.h>

#import "FHMainListTopView.h"
#import "FHMainRentTopView.h"
#import "FHMainOldTopView.h"

#import <FHHouseRent/FHHouseRentFilterType.h>
#import <FHHouseRent/FHHouseRentCell.h>
#import <BDWebImage/BDWebImage.h>
#import "FHBaseMainListViewModel+Internal.h"
#import "FHBaseMainListViewModel+Old.h"
#import "FHBaseMainListViewModel+Rent.h"

#define kPlaceCellId @"placeholder_cell_id"
#define kSingleCellId @"single_cell_id"
#define kSugCellId @"sug_cell_id"
#define kFilterBarHeight 44
#define MAX_ICON_COUNT 4
#define ICON_HEADER_HEIGHT 115
#define OLD_ICON_HEADER_HEIGHT 80

@implementation FHBaseMainListViewModel

-(instancetype)initWithTableView:(UITableView *)tableView houseType:(FHHouseType)houseType  routeParam:(TTRouteParamObj *)paramObj
{
    self = [super init];
    if (self) {
        
        _houseList = [NSMutableArray new];
        _sugesstHouseList = [NSMutableArray new];
        
        self.tableView = tableView;
        self.houseType = houseType;
        
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        [_tableView registerClass:[FHSingleImageInfoCell class] forCellReuseIdentifier:kSingleCellId];
        [_tableView registerClass:[FHRecommendSecondhandHouseTitleCell class] forCellReuseIdentifier:kSugCellId];
        [_tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:kPlaceCellId];
        
        __weak typeof(self) wself = self;
        FHRefreshCustomFooter *footer = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
            if (wself.sugesstHouseList.count > 0) {
                wself.fromRecommend = YES;
                [wself requestData:NO ];
            } else {
                wself.fromRecommend = NO;
                [wself requestData:NO];
            }
            
        }];
        _tableView.mj_footer = footer;
        [footer setUpNoMoreDataText:@"没有更多信息了"];
        footer.hidden = YES;
        
        self.filterOpenUrlMdodel = [FHSearchFilterOpenUrlModel instanceFromUrl:[paramObj.sourceURL absoluteString]];
        
        [self initTopBanner];
        [self initFilter];
    }
    return self;
}

-(void)initFilter
{
    id<FHHouseFilterBridge> bridge = [[FHHouseBridgeManager sharedInstance] filterBridge];
    self.houseFilterBridge = bridge;
    
    self.houseFilterViewModel = [bridge filterViewModelWithType:FHHouseTypeRentHouse showAllCondition:YES showSort:YES];
    self.filterPanel = [bridge filterPannel:self.houseFilterViewModel];
    self.filterBgControl = [bridge filterBgView:self.houseFilterViewModel];
    self.houseFilterViewModel.delegate = self;
    
    self.filterPanel.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, kFilterBarHeight);
    
}


-(void)initTopBanner
{
    if (_houseType == FHHouseTypeRentHouse) {
        
        FHMainRentTopView *topView = [[FHMainRentTopView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH , ICON_HEADER_HEIGHT)];
        
        NSDictionary *dict = nil;
        if ([[[FHEnvContext sharedInstance] getConfigFromCache].rentOpData respondsToSelector:@selector(toDictionary)]) {
            dict =  [[FHEnvContext sharedInstance] getConfigFromCache].rentOpData.toDictionary;
        }
        
        FHConfigDataRentOpDataModel *rentModel = [[FHConfigDataRentOpDataModel alloc] initWithDictionary:dict error:nil];
        topView.items = rentModel.items;
        topView.delegate = self;
        
        self.topBannerView = topView;
    }else if (_houseType == FHHouseTypeSecondHandHouse){
        
        FHConfigDataModel *dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
        if (dataModel.houseOpData.items.count > 0) {
            FHMainOldTopView *topView = [[FHMainOldTopView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, OLD_ICON_HEADER_HEIGHT)];
            topView.delegate = self;
            topView.items = dataModel.houseOpData.items;
            self.topBannerView = topView;
            
            for (FHConfigDataOpData2ItemsModel *item in dataModel.houseOpData.items ) {
                [self addOperationShowLog:item.logPb[@"operation_name"]];
            }
        }
    }
    
}



-(void)setErrorMaskView:(FHErrorView *)errorMaskView
{
    _errorMaskView = errorMaskView;
    __weak typeof(self) wself = self;
    _errorMaskView.retryBlock = ^{
        [wself requestData:YES];
    };
    _errorMaskView.hidden = YES;
    
}

-(void)showErrorMask:(BOOL)show tip:(FHEmptyMaskViewType )type enableTap:(BOOL)enableTap showReload:(BOOL)showReload
{
    if (show) {
        [_errorMaskView showEmptyWithType:type];
        _errorMaskView.retryButton.enabled = enableTap;
        
        CGFloat top = self.tableView.contentOffset.y;
        if (top > 0) {
            top = 0;
        }
        [_errorMaskView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(-top);
        }];
        
        self.tableView.scrollEnabled = NO;
    }
    self.errorMaskView.hidden = !show;
}

-(void)requestData:(BOOL)isHead
{
    [_requestTask cancel];
    
    NSString *query = [_filterOpenUrlMdodel query];
    NSInteger offset = 0;
    if (!isHead) {
        offset = _houseList.count;
    }
    
    if (isHead) {
        self.showPlaceHolder = YES;
    }
    
    if (![TTReachability isNetworkConnected]) {
        if (isHead) {
            //@"网络不给力，点击屏幕重试"
            [self showErrorMask:YES tip:FHEmptyMaskViewTypeNoNetWorkAndRefresh enableTap:YES showReload:YES];
        }else{
            [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
            [self.tableView.mj_footer endRefreshing];
        }
        return;
    }
    
    __weak typeof(self) wself = self;
    if (self.houseType == FHHouseTypeRentHouse) {
        
        self.requestTask = [self requestRentData:isHead query:query completion:^(FHHouseRentModel * _Nullable model, NSError * _Nullable error) {
            [wself processData:model error:error isRefresh:isHead];
        }];
        
    }else{
        
        self.requestTask = [self loadData:isHead fromRecommend:self.isFromRecommend query:query completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
            [wself processData:model error:error isRefresh:isHead];
        }];
    }
    
}

-(void)processError:(NSError *)error  isRefresh:(BOOL)isRefresh
{
    if (error.code != NSURLErrorCancelled) {
        //不是主动取消
        if (isRefresh) {
            [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
        }else {
            FHEmptyMaskViewType tip = FHEmptyMaskViewTypeNoData;
            if (![TTReachability isNetworkConnected]) {
                tip = FHEmptyMaskViewTypeNoNetWorkAndRefresh;
            }
            [self showErrorMask:YES tip:tip enableTap:NO showReload:YES];
        }
    }
    [self.tableView.mj_footer endRefreshing];
    
}


- (void)processData:(id<FHBaseModelProtocol>)model error: (NSError *)error isRefresh:(BOOL)isRefresh
{
    if (error) {
        [self processError:error isRefresh:isRefresh];
        return;
    }
    
    if (isRefresh) {
        [self.houseList removeAllObjects];
        [self.sugesstHouseList removeAllObjects];
        [self.tableView.mj_footer endRefreshing];
    }
    
    if (model) {
        
        NSArray *itemArray = nil;
        NSArray *recommendItemArray = nil;
        BOOL hasMore = NO;
        NSString *refreshTip = nil;
        FHSearchHouseDataRedirectTipsModel *redirectTips = nil;
        FHRecommendSecondhandHouseDataModel *recommendHouseDataModel = nil;
        
        if ([model isKindOfClass:[FHRecommendSecondhandHouseModel class]]) {
            recommendHouseDataModel = ((FHRecommendSecondhandHouseModel *)model).data;
            self.recommendSearchId = recommendHouseDataModel.searchId;
            hasMore = recommendHouseDataModel.hasMore;
            recommendItemArray = recommendHouseDataModel.items;
        } else if ([model isKindOfClass:[FHSearchHouseModel class]]) {
            
            FHSearchHouseDataModel *houseModel = ((FHSearchHouseModel *)model).data;
            self.houseListOpenUrl = houseModel.houseListOpenUrl;
            self.mapFindHouseOpenUrl = houseModel.mapFindHouseOpenUrl;
            hasMore = houseModel.hasMore;
            refreshTip = houseModel.refreshTip;
            itemArray = houseModel.items;
            redirectTips = houseModel.redirectTips;
            recommendHouseDataModel = houseModel.recommendSearchModel;
            recommendItemArray = recommendHouseDataModel.items;
            self.searchId = houseModel.searchId;
            if (recommendItemArray.count > 0) {
                self.recommendSearchId = recommendHouseDataModel.searchId;
                if (!hasMore) {
                    hasMore = recommendHouseDataModel.hasMore;
                }
                FHRecommendSecondhandHouseTitleModel *recommendTitleModel = [[FHRecommendSecondhandHouseTitleModel alloc]init];
                recommendTitleModel.noDataTip = recommendHouseDataModel.searchHint;
                recommendTitleModel.title = recommendHouseDataModel.recommendTitle;
                [self.sugesstHouseList addObject:recommendTitleModel];
            }
        }else if ([model isKindOfClass:[FHHouseRentModel class]]){
            FHHouseRentDataModel *rentModel = [(FHHouseRentModel *)model data];
            
            self.houseListOpenUrl = rentModel.houseListOpenUrl;
            self.mapFindHouseOpenUrl = rentModel.mapFindHouseOpenUrl;
            
            hasMore = rentModel.hasMore;
            refreshTip = rentModel.refreshTip;
            itemArray = rentModel.items;
            self.searchId = rentModel.searchId;
        }
        
        if (self.isFirstLoad) {
            self.originSearchId = self.searchId;
            self.isFirstLoad = NO;
            if (self.searchId.length > 0 ) {
                SETTRACERKV(UT_ORIGIN_SEARCH_ID, self.searchId);
            }
        }
        self.showPlaceHolder = NO;
        if (self.isEnterCategory) {
            [self addEnterLog];
            self.isEnterCategory = NO;
        }
        if (isRefresh) {
            [self addHouseSearchLog];
            [self addHouseRankLog];
            
//            [self refreshHouseListUrlCallback:self.houseListOpenUrl];
            
            
        } else {
//            [self addCategoryRefreshLog];
            
            [self addLoadMoreRefreshLog];
        }
        
        if (self.houseType == FHHouseTypeSecondHandHouse) {
            if (!self.fromRecommend) {
                self.redirectTips = redirectTips;
                [self updateRedirectTipInfo];
            }
        }
        
        [itemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
                FHSingleImageInfoCellModel *cellModel = [[FHSingleImageInfoCellModel alloc]init];
                cellModel.secondModel = obj;
                cellModel.isRecommendCell = NO;
                [self.houseList addObject:cellModel];
            }else if ([obj isKindOfClass:[FHHouseRentDataItemsModel class]]){
                FHSingleImageInfoCellModel *cellModel = [[FHSingleImageInfoCellModel alloc]init];
                cellModel.rentModel = obj;
                cellModel.isRecommendCell = NO;
                [self.houseList addObject:cellModel];
            }
        }];
        
        [recommendItemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
                FHSingleImageInfoCellModel *cellModel = [[FHSingleImageInfoCellModel alloc]init];
                cellModel.secondModel = obj;
                cellModel.isRecommendCell = YES;
                [self.sugesstHouseList addObject:cellModel];
            }
        }];
        
        [self.tableView reloadData];
        
        self.tableView.mj_footer.hidden = NO;
        if (hasMore == NO) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else {
            [self.tableView.mj_footer endRefreshing];
        }
        
        if (isRefresh && (itemArray.count > 0 || recommendItemArray.count > 0)) {
            [self showNotifyMessage:refreshTip];
        }
        
        if (self.houseList.count == 0 && self.sugesstHouseList.count == 0) {
            [self showErrorMask:YES tip:FHEmptyMaskViewTypeNoDataForCondition enableTap:NO showReload:NO];
        } else {
            [self showErrorMask:NO tip:FHEmptyMaskViewTypeNoData enableTap:NO showReload:NO];
        }
        
        // 刷新请求的时候将列表滑动在最顶部
//        if (isRefresh) {
//            if (self.houseList.count > 0) {
//                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
//            } else if (self.sugesstHouseList.count > 0) {
//                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
//            }
//        }
    } else {
        [self showErrorMask:YES tip:FHEmptyMaskViewTypeNoData enableTap:YES showReload:YES];
    }
}

-(void)showInputSearch
{
    SETTRACERKV(UT_ORIGIN_FROM,@"renting_search");
    [self addClickSearchLog];
    [self.houseFilterViewModel closeConditionFilterPanel];
    
    id<FHHouseEnvContextBridge> envBridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
    [envBridge setTraceValue:@"renting_search" forKey:@"origin_from"];
    
    NSMutableDictionary *traceParam = [self baseLogParam];
    traceParam[@"element_from"] = @"renting_search";
    traceParam[@"page_type"] = @"renting";
    traceParam[@"origin_from"] = @"renting_search";
    traceParam[@"origin_search_id"] = self.originSearchId ? : @"be_null";
    
    //house_search
    NSHashTable *sugDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [sugDelegateTable addObject:self];
    NSDictionary *dict = @{@"house_type":@(_houseType) ,
                           @"tracer": traceParam,
                           @"from_home":@(4),
                           @"sug_delegate":sugDelegateTable
                           };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL *url = [NSURL URLWithString:@"sslocal://house_search"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    
}

-(void)showMapSearch
{
    if (_houseType == FHHouseTypeRentHouse) {
        if (self.mapFindHouseOpenUrl.length > 0) {
            NSURL *url = [NSURL URLWithString:self.mapFindHouseOpenUrl];
            NSDictionary *dict = @{};
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }else{
            [self showOldMapSearch];
        }
    }
}

-(void)viewWillAppear
{
    //    self.startDate = [NSDate date];
}

-(void)viewWillDisapper
{
    [self addStayLog];
}

#pragma mark - redirect view
- (void)setRedirectTipView:(FHHouseListRedirectTipView *)redirectTipView
{
    __weak typeof(self)wself = self;
    _redirectTipView = redirectTipView;
    _redirectTipView.clickCloseBlock = ^{
        [wself closeRedirectTip];
    };
    _redirectTipView.clickRightBlock = ^{
        [wself clickRedirectTip];
    };
    
}

#pragma mark - top banner rent delegate
-(void)selecteRentItem:(FHConfigDataRentOpDataItemsModel *)model
{
    NSMutableString *openUrl = [[NSMutableString alloc] initWithString:model.openUrl];// model.openUrl;
    if (![openUrl containsString:@"house_type"]) {
        [openUrl appendFormat:@"&house_type=%ld",FHHouseTypeRentHouse];
        //        openUrl = [openUrl stringByAppendingFormat:@"&house_type=%ld",FHHouseTypeRentHouse];
    }
    if (![openUrl containsString:@"search_id"]) {
        [openUrl appendFormat:@"&search_id=%@",self.searchId?:@"be_null"];
    }
    TTRouteUserInfo *userInfo = nil;
    NSURL *url = nil;
    FHHouseRentFilterType filterType = [self rentFilterType:model.openUrl];
    
    NSString *originFrom = model.logPb[@"origin_from"];
    
    if (filterType == FHHouseRentFilterTypeMap){
        
        //王然说点击不爆切换埋点
        //        [self addMapsearchLog];
        
        //        if (self.mapFindHouseOpenUrl.length > 0) {
        //            //使用跳转
        //            openUrl = self.mapFindHouseOpenUrl;
        //        }
        if (originFrom.length == 0) {
            originFrom = @"renting_mapfind";
        }
        
        if (![openUrl containsString:@"enter_from"]) {
            [openUrl appendString:@"&enter_from=renting"];
        }
        if (![openUrl containsString:@"origin_from"]) {
            [openUrl appendFormat:@"&origin_from=%@",originFrom];
        }
        
        SETTRACERKV(UT_ORIGIN_FROM, originFrom);
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params addEntriesFromDictionary:[self.viewController.tracerModel neatLogDict] ];
        
        params[@"enter_from"] = @"renting";
        params[@"origin_from"] = originFrom;
        params[@"origin_search_id"] = nil;//remove origin_search_id
        
        NSDictionary *infoDict = @{@"tracer":params};
        userInfo = [[TTRouteUserInfo alloc]initWithInfo:infoDict];
        
    }else{
        NSDictionary *param = [self addEnterHouseListLog:model.openUrl];
        if (param) {
            NSDictionary *infoDict = @{@"tracer":param};
            userInfo = [[TTRouteUserInfo alloc]initWithInfo:infoDict];
            if (originFrom.length == 0) {
                originFrom = param[@"origin_from"];
            }
            
            if (originFrom) {
                SETTRACERKV(@"origin_from", originFrom);
            }
        }
    }
    url = [NSURL URLWithString:openUrl];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    
}

-(void)selecteOldItem:(FHConfigDataOpData2ItemsModel *)model
{
    TTRouteParamObj *paramObj = [[TTRoute sharedRoute]routeParamObjWithURL:[NSURL URLWithString:model.openUrl]];
    NSMutableDictionary *queryP = [NSMutableDictionary new];
    [queryP addEntriesFromDictionary:paramObj.allParams];
    NSDictionary *baseParams = [self baseLogParam];
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"enter_from"] = baseParams[@"enter_from"] ? : @"be_null";
    dict[@"element_from"] = baseParams[@"element_from"] ? : @"be_null";
    dict[@"origin_from"] = baseParams[@"origin_from"] ? : @"be_null";
    dict[@"log_pb"] = model.logPb ? : @"be_null";
    dict[@"search_id"] = baseParams[@"search_id"] ? : @"be_null";
    dict[@"origin_search_id"] = baseParams[@"origin_search_id"] ? : @"be_null";
    
    NSString *reportParams = [self getEvaluateWebParams:dict];
    NSString *jumpUrl = @"sslocal://webview";
    NSMutableString *urlS = [[NSMutableString alloc] init];
    [urlS appendString:queryP[@"url"]];
    [urlS appendFormat:@"&report_params=%@",reportParams];
    queryP[@"url"] = urlS;
    
    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:queryP];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:jumpUrl] userInfo:info];
    
    NSDictionary *logpbDict = model.logPb;
    [self addOperationClickLog:logpbDict[@"operation_name"]];
}

- (NSString *)getEvaluateWebParams:(NSDictionary *)dic
{
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONReadingAllowFragments error:&error];
    if (data && !error) {
        NSString *temp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        temp = [temp stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        return temp;
    }
    return nil;
}


#pragma mark - filter delegate

-(void)onConditionChanged:(NSString *)condition
{
    if ([self.conditionFilter isEqualToString:condition]) {
        return;
    }
    
    self.tableView.scrollEnabled = YES;
    
    self.conditionFilter = condition;
    
    [self.filterOpenUrlMdodel overwriteFliter:condition];
    [self.tableView triggerPullDown];
    [self requestData:YES];
}

-(void)onConditionPanelWillDisplay
{
    self.tableView.contentOffset = CGPointMake(0, [self.topView filterTop] - self.topView.height);
}

-(void)onConditionPanelWillDisappear
{
}

-(UIImage *)placeHolderImage
{
    if (!_placeHolderImage) {
        _placeHolderImage = [UIImage imageNamed:@"default_image"];
    }
    return _placeHolderImage;
}

#pragma mark - tableview delegate & datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.sugesstHouseList.count > 0) {
        return 2;
    }
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_showPlaceHolder) {
        return  10;
    }
    
    return section == 0 ? self.houseList.count : self.sugesstHouseList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (_showPlaceHolder) {        
        cell = [tableView dequeueReusableCellWithIdentifier:kPlaceCellId];
    }else{
        if (indexPath.section == 1 && indexPath.row == 0 && [self.sugesstHouseList[0] isKindOfClass:[FHRecommendSecondhandHouseTitleModel class]]) {
            FHRecommendSecondhandHouseTitleCell *scell = [tableView dequeueReusableCellWithIdentifier:kSugCellId];
            FHRecommendSecondhandHouseTitleModel *model = self.sugesstHouseList[0];
            [scell bindData:model];
            cell = scell;
            
        } else {
            
            FHSingleImageInfoCell *scell = [tableView dequeueReusableCellWithIdentifier:kSingleCellId];
            
            if (indexPath.section == 0) {
                
                BOOL isFirstCell = (indexPath.row == 0);
                BOOL isLastCell = (indexPath.row == self.houseList.count - 1);
                
                if (indexPath.row < self.houseList.count) {
                    FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
                    CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHSingleImageInfoCell recommendReasonHeight] : 0;
                    [scell updateWithHouseCellModel:cellModel];
                    [scell refreshTopMargin: 20];
                    [scell refreshBottomMargin:(isLastCell ? 20 : 0)+reasonHeight];
                }
                
            } else {
                
                BOOL isFirstCell = (indexPath.row == 0);
                BOOL isLastCell = (indexPath.row == self.sugesstHouseList.count - 1);
                
                if (indexPath.row < self.sugesstHouseList.count) {
                    FHSingleImageInfoCellModel *cellModel = self.sugesstHouseList[indexPath.row];
                    CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHSingleImageInfoCell recommendReasonHeight] : 0;
                    [scell updateWithHouseCellModel:cellModel];
                    [scell refreshTopMargin: 20];
                    [scell refreshBottomMargin:(isLastCell ? 20 : 0)+reasonHeight];
                }
            }
            
            cell = scell;
        }
        
    }
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_showPlaceHolder) {
        return 105;
    }
    
    if (indexPath.section == 1 && indexPath.row == 0 && [self.sugesstHouseList[0] isKindOfClass:[FHRecommendSecondhandHouseTitleModel class]]) {
        CGFloat height = 44.5;
        FHRecommendSecondhandHouseTitleModel *titleModel = self.sugesstHouseList[0];
        if (titleModel.noDataTip.length > 0) {
            height += 58;
        }
        return height;
    } else {
        if (indexPath.section == 0) {
            BOOL isLastCell = (indexPath.row == self.houseList.count - 1);
            FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
            CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHSingleImageInfoCell recommendReasonHeight] : 0;
            return (isLastCell ? 125 : 105)+reasonHeight;
        } else {
            BOOL isLastCell = (indexPath.row == self.sugesstHouseList.count - 1);
            FHSingleImageInfoCellModel *cellModel = self.sugesstHouseList[indexPath.row];
            CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHSingleImageInfoCell recommendReasonHeight] : 0;
            return (isLastCell ? 125 : 105)+reasonHeight;
        }
    }
    
    return 105;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_showPlaceHolder) {
        [self addHouseShowLog:indexPath];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_showPlaceHolder || [_houseList count] <= indexPath.row) {
        return;
    }
    
    FHSingleImageInfoCellModel *cellModel = nil;
    if (indexPath.section == 0) {
        if (indexPath.row < self.houseList.count) {
            cellModel = self.houseList[indexPath.row];
        }
    } else {
        if (indexPath.row > 0 && indexPath.row < self.sugesstHouseList.count) {
            cellModel = self.sugesstHouseList[indexPath.row];           
        }
    }
    
    if (!cellModel || ![cellModel isKindOfClass:[FHSingleImageInfoCellModel class]]) {
        return;
    }
    
    id<FHHouseEnvContextBridge> contextBridge = [[FHHouseBridgeManager sharedInstance]envContextBridge];
    NSMutableDictionary *tracer = [NSMutableDictionary dictionary];
    NSString *urlStr = nil;
    if (self.houseType == FHHouseTypeRentHouse) {
        
        SETTRACERKV(UT_ORIGIN_FROM, @"renting_list");
        
        id<FHHouseEnvContextBridge> envBridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
        [envBridge setTraceValue:self.originSearchId forKey:@"origin_search_id"];
        
        [tracer addEntriesFromDictionary:[self.viewController.tracerModel neatLogDict]];
        tracer[@"card_type"] = @"left_pic";
        tracer[@"element_from"] = @"be_null";
        tracer[@"enter_from"] = @"renting";
        tracer[@"log_pb"] = cellModel.logPb;
        tracer[@"rank"] = @(indexPath.row);
        tracer[@"origin_from"] = @"renting_list";
        tracer[@"origin_search_id"] = self.originSearchId ? : @"be_null";
        
        urlStr = [NSString stringWithFormat:@"fschema://rent_detail?house_id=%@", cellModel.rentModel.id];
        
    }else if (self.houseType == FHHouseTypeSecondHandHouse){
        
        [contextBridge setTraceValue:self.originFrom forKey:@"origin_from"];
        [contextBridge setTraceValue:self.originSearchId forKey:@"origin_search_id"];
        if (cellModel.secondModel) {
            
            FHSearchHouseDataItemsModel *theModel = cellModel.secondModel;
            urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",theModel.hid];
        }
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    if (url) {
        TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer": tracer,@"house_type":@(self.houseType)}];
        [[TTRoute sharedRoute] openURLByViewController:url userInfo: userInfo];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    BOOL shouldInTable = (scrollView.contentOffset.y + scrollView.contentInset.top <  [self.topView filterTop]);
    [self moveTop:shouldInTable];
    
//    NSLog(@"[SCROLL] offset is: %f top %f  top cal height: %f should intable : %@",scrollView.contentOffset.y,scrollView.contentInset.top,(self.topView.height - [self.topView filterTop]),shouldInTable?@"YES":@"NO");
}


-(void)moveTop:(BOOL)toTableView
{
    if (toTableView) {
        if (self.topView.superview == self.tableView) {
            return;
        }
        
        self.topView.top = -self.topView.height;
        [self.tableView addSubview:self.topView];
        [self.tableView sendSubviewToBack:self.topView];
        [self.topContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
    }else{
        
        if (self.topView.superview == self.topContainerView){
            return;
        }
        
        [self.topContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.topView.height - [self.topView filterTop]);
        }];
        
        [self.topContainerView addSubview:self.topView];
        self.topView.top = -[self.topView filterTop];
    }
}

-(void)showNotifyMessage:(NSString *)message
{
    __weak typeof(self) wself = self;
    CGFloat height =  [_topView showNotify:message willCompletion:^{
        
        wself.tableView.scrollEnabled = NO;
        [UIView animateWithDuration:0.3 animations:^{
            
            [wself configNotifyInfo:[wself.topView filterBottom] isShow:NO];
            
        } completion:^(BOOL finished) {
            wself.tableView.scrollEnabled = YES;
            
        }];
        
    }];
    
    [self configNotifyInfo:height isShow:YES];
    
    
}

-(void)configNotifyInfo:(CGFloat)topViewHeight isShow:(BOOL)isShow
{
    UIEdgeInsets insets = self.tableView.contentInset;
    BOOL isTop = (fabs(self.tableView.contentOffset.y) < 0.1) || fabs(self.tableView.contentOffset.y + self.tableView.contentInset.top) < 0.1; //首次进入情况
    insets.top = topViewHeight;
    self.tableView.contentInset = insets;
    _topView.frame = CGRectMake(0, -topViewHeight, _topView.width, topViewHeight);
    
    if (isShow) {
        if (isTop) {
            [self.tableView setContentOffset:CGPointMake(0, -topViewHeight) animated:NO];
        }else{
            self.tableView.contentOffset = CGPointMake(0, [self.topView filterTop] -topViewHeight);
        }
    }else{
        //
        if (self.tableView.contentOffset.y >= -[self.topView filterTop]) {
            if (self.tableView.contentOffset.y <= ([self.topView filterTop] - topViewHeight)) {
                self.tableView.contentOffset = CGPointMake(0, [self.topView filterTop] -topViewHeight);
            }
        }                       
    }
    
    if (_topView.superview == self.topContainerView) {
        self.topView.top = -[self.topView filterTop];
        [self.topContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.topView.height - [self.topView filterTop]);
        }];
    }
}


#pragma mark - log

-(NSMutableDictionary *)baseLogParam
{
    /*
     1. event_type：house_app2c_v2
     2. category_name（列表名）：renting（租房大类页）
     3. enter_from（列表入口）：maintab（首页）
     4. enter_type（进入列表方式）：click（点击）
     5. element_from（组件入口）：maintab_icon（首页icon）
     6. search_id
     7. origin_from：renting_list（租房大类页推荐列表）
     8. origin_search_id
     9. stay_time（停留时长，单位毫秒）
     */
    
    NSMutableDictionary *param = [NSMutableDictionary new];
    //    id<FHHouseEnvContextBridge> envBridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
    //    NSDictionary *houseParams = [envBridge homePageParamsMap];
    [param addEntriesFromDictionary:[self.viewController.tracerModel logDict]];
    //    [param addEntriesFromDictionary:houseParams];
    param[@"origin_search_id"] = self.originSearchId ?: @"be_null";
    param[@"search_id"] = self.searchId ?: @"be_null";
    param[@"enter_from"] = @"renting";
    
    return param;
}

-(NSString *)pageTypeString
{
    return @"old_kind_list";
}

-(NSString *)categoryName
{
    return @"old_kind_list";
}

-(NSString *)houseTypeString
{
    return @"old";
}

//-(NSString *)pageTypeString
//{
//    return @"old_kind_list";
//}

-(NSString *)elementTypeString {
    
    return @"be_null";
    
}


-(void)addEnterLog
{
    /*
     enter_category
     1. event_type：house_app2c_v2
     2. category_name（列表名）：renting（租房大类页）
     3. enter_from（列表入口）：maintab（首页）
     4. enter_type（进入列表方式）：click（点击）
     5. element_from（组件入口）：maintab_icon（首页icon）
     6. search_id
     7. origin_from：renting_list（租房大类页推荐列表）
     8. origin_search_id
     */
    
    if (self.viewController.tracerModel) {
        
        FHTracerModel *model = self.viewController.tracerModel;
        TRACK_MODEL(UT_ENTER_CATEOGRY,model);
        
        self.stayTraceDict = [model logDict];
        
        //        NSMutableDictionary *param = [NSMutableDictionary new];
        //        [param addEntriesFromDictionary:self.tracerDict];
        //        param[@"category_name"] = @"renting";
        //
        //        TRACK_EVENT(@"enter_category", param);
    }
    
}

-(void)addClickSearchLog
{
    
    /*
     1. event_type：house_app2c_v2
     2. page_type（页面类型）：renting（租房大类页），rent_list（租房列表页），findtab_rent（租房）
     3. origin_from
     4. origin_search_id
     5. hot_word（搜索框轮播词，无轮播词记为be_null）
     */
    //
    //    id<FHHouseEnvContextBridge> envBridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
    //    NSDictionary *houseParams = [envBridge homePageParamsMap];
    [[FHEnvContext sharedInstance] getCommonParams];
    NSMutableDictionary *homeParams = [NSMutableDictionary new];
    
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params addEntriesFromDictionary:[self.viewController.tracerModel logDict]];
    params[@"page_type"] = @"renting";
    params[@"origin_search_id"] = self.viewController.tracerModel.originSearchId?:@"be_null";
    params[@"hot_word"] = @"be_null";
    params[@"origin_from"] = @"renting_search";
    
    TRACK_EVENT(@"click_house_search",params);
}

- (void)addHouseSearchLog
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (self.houseSearchDic) {
        [params addEntriesFromDictionary:self.houseSearchDic];
    } else {
        // house_search 上报时机是通过搜索（搜索页面）进入的搜索列表页，而通过搜索点击tab进入的不上报当前埋点，过滤器重新选择后也上报
        return;
    }
    params[@"house_type"] = [self houseTypeString];
    params[@"origin_search_id"] = self.originSearchId.length > 0 ? self.originSearchId : @"be_null";
    params[@"search_id"] =  self.searchId.length > 0 ? self.searchId : @"be_null";
    params[@"origin_from"] = self.originFrom.length > 0 ? self.originFrom : @"be_null";
    TRACK_EVENT(@"house_search",params);
    self.canChangeHouseSearchDic = YES;
}

- (void)addOperationShowLog:(NSString *)operationName
{
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"operation_name"] = operationName ? : @"be_null";
    tracerDict[@"page_type"] = @"old_kind_list";
    [FHUserTracker writeEvent:@"operation_show" params:tracerDict];
}

- (void)addOperationClickLog:(NSString *)operationName
{
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"operation_name"] = operationName ? : @"be_null";
    tracerDict[@"page_type"] = @"old_kind_list";
    [FHUserTracker writeEvent:@"operation_click" params:tracerDict];
}


-(void)addStayLog
{
    NSTimeInterval duration = self.viewController.ttTrackStayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    
    /*
     1. event_type：house_app2c_v2
     2. category_name（列表名）：renting（租房大类页）
     3. enter_from（列表入口）：maintab（首页）
     4. enter_type（进入列表方式）：click（点击）
     5. element_from（组件入口）：maintab_icon（首页icon）
     6. search_id
     7. origin_from：renting_list（租房大类页推荐列表）
     8. origin_search_id
     9. stay_time（停留时长，单位毫秒）
     */
    
    //    NSMutableDictionary *param = [self.viewController.tracerModel logDict];//[NSMutableDictionary new];
    //    [param addEntriesFromDictionary:self.tracerDict];
    //    param[@"search_id"] = self.searchId;
    self.stayTraceDict[@"stay_time"] = [NSString stringWithFormat:@"%.0f",duration];
    //    param[@"category_name"] = @"renting";
    
    TRACK_EVENT(@"stay_category", self.stayTraceDict);
    [self.viewController tt_resetStayTime];
    /*
     1. event_type：house_app2c_v2
     2. category_name（列表名）：renting（租房大类页）
     3. enter_from（列表入口）：maintab（首页）
     4. enter_type（进入列表方式）：click（点击）
     5. element_from（组件入口）：maintab_icon（首页icon）
     6. search_id
     7. origin_from：renting_list（租房大类页推荐列表）
     8. origin_search_id
     9. stay_time（停留时长，单位毫秒）
     */
    
    
}


-(void)addLoadMoreRefreshLog
{
    NSMutableDictionary *param = [self baseLogParam];
    
    /*
     "1. event_type：house_app2c_v2
     2. category_name（列表名）：renting（租房大类页）
     3. enter_from（列表入口）：maintab（首页）
     4. enter_type（进入列表方式）：click（点击）
     5. element_from（组件入口）：maintab_icon（首页icon）
     6. search_id
     7. origin_from：renting_list（租房大类页推荐列表）
     8. origin_search_id
     9. refresh_type（刷新类型）：pre_load_more（滑动频道）"
     */
    
    //    param[@"search_id"] = self.searchId;
    param[@"refresh_type"] = @"pre_load_more";
    param[@"enter_from"] = self.viewController.tracerModel.enterFrom?:@"maintab";
    
    TRACK_EVENT(@"category_refresh", param);
}

-(void)addHouseShowLog:(NSIndexPath *)indexPath
{
    FHSingleImageInfoCellModel *cellModel = nil;
    
    if (indexPath.section == 0) {
        if (indexPath.row < self.houseList.count) {
            cellModel = self.houseList[indexPath.row];
        }
    } else {
        if (indexPath.row > 0 && indexPath.row < self.sugesstHouseList.count) {
            FHSingleImageInfoCellModel *cellModel = self.sugesstHouseList[indexPath.row];
        }
    }
    
    if (!cellModel || ![cellModel isKindOfClass:[FHSingleImageInfoCellModel class]]) {
        return;
    }
    
    if (_showHouseDict[cellModel.groupId]) {
        //already add log
        return;
    }
    
    _showHouseDict[cellModel.groupId] = @(1);
    
    NSDictionary *baseParam = [self baseLogParam];
    
    /*
     "1. event_type：house_app2c_v2
     2. house_type（房源类型）：rent（租房）
     3. card_type（卡片样式）：left_pic（左图）
     4. page_type（页面类型）：renting（租房大类页）
     5. element_type：be_null
     6. group_id
     7. impr_id
     8. search_id
     9. rank
     10. origin_from：renting_list（租房大类页推荐列表）
     11. origin_search_id"
     */
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"house_type"] = @"rent";
    param[@"card_type"] = @"left_pic";
    param[@"page_type"] = @"renting";
    param[@"element_type"] = @"be_null";
    param[@"group_id"] = cellModel.groupId;
    param[@"impr_id"] = cellModel.imprId;
    param[@"search_id"] = self.searchId;
    param[@"rank"] = @(indexPath.row);
    param[@"log_pb"] = cellModel.logPb;
    param[@"origin_from"] = baseParam[@"origin_from"] ? : @"be_null";;
    param[@"origin_search_id"] = self.viewController.tracerModel.originSearchId ? : @"be_null";;
    
    TRACK_EVENT(@"house_show", param);
}

-(void)addGodetailLog:(NSIndexPath *)indexPath
{
    FHHouseRentDataItemsModel *model = _houseList[indexPath.row];
    NSMutableDictionary *param = [self baseLogParam];
    
    /*
     "1. event_type：house_app2c_v2
     2. house_type（房源类型）：rent（租房）
     3. card_type（卡片样式）：left_pic（左图）
     4. page_type（页面类型）：renting（租房大类页）
     5. element_type：be_null
     6. group_id
     7. impr_id
     8. search_id
     9. rank
     10. origin_from：renting_list（租房大类页推荐列表）
     11. origin_search_id"
     */
    
    param[@"house_type"] = @"rent";
    param[@"card_type"] = @"left_pic";
    param[@"page_type"] = @"renting";
    param[@"element_type"] = @"be_null";
    param[@"impr_id"] = model.imprId;
    param[@"log_pb"] = model.logPb;
    param[@"rank"] = @(indexPath.row);
    param[@"search_id"] = self.searchId;
    
    TRACK_EVENT(@"go_detail", param);
}

-(NSDictionary *)addEnterHouseListLog:(NSString *)openUrl
{
    /*
     "1. event_type：house_app2c_v2
     2. category_name（列表名）：rent_list（租房列表页）
     3. enter_from（列表入口）：renting（租房大类页），maintab（首页），findtab（找房tab）
     4. enter_type（进入列表方式）：click（点击）
     5. element_from（组件入口）：renting_icon（租房大类页icon），renting_search（租房大类页搜索），maintab_search（首页搜索）, findtab_find（找房tab开始找房）findtab_search（找房tab搜索）
     6. search_id
     7. origin_from：renting_all（租房大类页全部房源icon），renting_joint（租房大类页合租icon），renting_fully（租房大类页整租icon），renting_apartment（租房大类页公寓icon），maintab_search（首页搜索），findtab_find（找房tab开始找房），findtab_search（找房tab搜索）
     8. origin_search_id"
     
     enter_category
     */
    
    FHHouseRentFilterType filterType = [self rentFilterType:openUrl];
    if (filterType == FHHouseRentFilterTypeMap) {
        //        [self addMapsearchLog];
        return nil;
    }
    
    NSString *originFrom = [self originFromWithFilterType:filterType];
    if (!originFrom) {
        return nil ;
    }
    
    self.originFrom = originFrom;
    NSMutableDictionary *param = [[self baseLogParam]mutableCopy];
    param[@"category_name"] = @"rent_list";
    param[@"enter_type"] = @"click";
    param[@"element_from"] = @"renting_icon";
    param[@"search_id"] = self.searchId;
    
    param[@"origin_from"] = originFrom;
    if (!param[@"origin_search_id"]) {
        param[@"origin_search_id"] = @"be_null";
    }
    
    return param;
}

-(void)addMapsearchLog
{
    /*
     let params = TracerParams.momoid() <|>
     toTracerParams(enterFrom, key: "enter_from") <|>
     toTracerParams("click", key: "enter_type") <|>
     toTracerParams("map", key: "click_type") <|>
     toTracerParams(catName, key: "category_name") <|>
     toTracerParams(categoryListViewModel?.originSearchId ?? "be_null", key: "search_id") <|>
     toTracerParams(elementName, key: "element_from") <|>
     toTracerParams(originFrom, key: "origin_from") <|>
     toTracerParams(originSearchId, key: "origin_search_id")
     
     recordEvent(key: TraceEventName.click_switch_mapfind, params: params)
     */
    
    NSMutableDictionary *param = [[self baseLogParam]mutableCopy];
    param[@"element_from"] = @"renting_icon";
    param[@"origin_from"] = @"renting_mapfind";
    param[UT_CATEGORY_NAME] = @"rent_list";
    
    TRACK_EVENT(@"click_switch_mapfind", param);
}

-(void)addSearchLog
{
    
}

- (void)addHouseRankLog
{
    NSString *sortType = @"default";
    if ([self.houseFilterViewModel isLastSearchBySort]) {
        sortType =  [self.houseFilterViewModel sortType] ? : @"default";
    }
    
    if (sortType.length < 1) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"page_type"] = @"renting";
    params[@"rank_type"] = sortType;
    params[@"origin_search_id"] = self.originSearchId.length > 0 ? self.originSearchId : @"be_null";
    params[@"search_id"] =  self.searchId.length > 0 ? self.searchId : @"be_null";
    params[@"origin_from"] = @"renting";
    TRACK_EVENT(@"house_rank",params);
}

-(NSString *)originFromWithFilterType:(FHHouseRentFilterType)filterType
{
    switch (filterType) {
        case FHHouseRentFilterTypeWhole:
            return  @"renting_fully";
        case FHHouseRentFilterTypeApart:
            return  @"renting_apartment";
        case FHHouseRentFilterTypeShare:
            return  @"renting_joint";
        case FHHouseRentFilterTypeMap:
            return @"renting_mapfind";
        default:
            return nil;
    }
    return nil;
}

-(FHHouseRentFilterType)rentFilterType:(NSString *)openUrl
{
    NSURL *url = [NSURL URLWithString:openUrl];
    if (!url) {
        return FHHouseRentFilterTypeNone;
    }
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    if ([components.host isEqualToString:@"mapfind_rent"]) {
        return FHHouseRentFilterTypeMap;
    }
    
    if ([components.host isEqualToString:@"house_list"]) {
        for (NSURLQueryItem *queryItem in components.queryItems) {
            if ([queryItem.name isEqualToString:@"rental_type[]"]) {
                if ([queryItem.value isEqualToString:@"1"]) {
                    //整租
                    return FHHouseRentFilterTypeWhole;
                }else if ([queryItem.value isEqualToString:@"2"]){
                    //合租
                    return FHHouseRentFilterTypeShare;
                }
            }else if ([queryItem.name isEqualToString:@"rental_contract_type[]"]){
                if ([queryItem.value isEqualToString:@"2"]) {
                    //公寓
                    return FHHouseRentFilterTypeApart;
                }
                
            }
        }
    }
    return FHHouseRentFilterTypeNone;
}

#pragma mark - sug delegate
-(void)suggestionSelected:(TTRouteObject *)routeObject
{
    
    //JUMP to cat list page
    [self.viewController.navigationController popViewControllerAnimated:NO];
    
    NSMutableDictionary *allInfo = [routeObject.paramObj.userInfo.allInfo mutableCopy];
    NSMutableDictionary *tracerDict = [self baseLogParam];
    [tracerDict addEntriesFromDictionary:allInfo[@"houseSearch"]];
    tracerDict[@"category_name"] = @"rent_list";
    tracerDict[UT_ELEMENT_FROM] = @"renting_search";
    tracerDict[@"page_type"] = @"renting";
    tracerDict[@"origin_from"] = allInfo[@"tracer"][@"origin_from"] ? allInfo[@"tracer"][@"origin_from"] : @"be_null";
    
    NSMutableDictionary *houseSearchDict = [[NSMutableDictionary alloc] initWithDictionary:allInfo[@"houseSearch"]];
    houseSearchDict[@"page_type"] = @"renting";
    allInfo[@"houseSearch"] = houseSearchDict;
    allInfo[@"tracer"] = tracerDict;
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:allInfo];
    
    routeObject.paramObj.userInfo = userInfo;
    [[TTRoute sharedRoute] openURLByPushViewController:routeObject.paramObj.sourceURL userInfo:routeObject.paramObj.userInfo];
    
}

-(void)resetCondition
{
    //    self.resetConditionBlock(nil);
}

-(void)backAction:(UIViewController *)controller
{
    [controller.navigationController popViewControllerAnimated:YES];
}


#pragma mark - network changed
-(void)connectionChanged:(NSNotification *)notification
{
    TTReachability *reachability = (TTReachability *)notification.object;
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status != NotReachable) {
        //有网络了，重新请求
        if (!self.errorMaskView.isHidden) {
            //只有在显示错误的时候才自动刷新
            [self requestData:YES];
        }
    }
}

@end

