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
#import <FHHouseBase/FHHouseBaseItemCell.h>
#import <FHHouseBase/FHMapSearchOpenUrlDelegate.h>

#import "FHMainListTopView.h"
#import "FHMainRentTopView.h"
#import "FHMainOldTopView.h"

#import <FHHouseRent/FHHouseRentFilterType.h>
#import <FHHouseRent/FHHouseRentCell.h>
#import <BDWebImage/BDWebImage.h>
#import "FHBaseMainListViewModel+Internal.h"
#import "FHBaseMainListViewModel+Old.h"
#import "FHBaseMainListViewModel+Rent.h"

#import "FHSugSubscribeModel.h"
#import "FHSuggestionSubscribCell.h"
#import "FHHouseListAPI.h"

#define kPlaceCellId @"placeholder_cell_id"
#define kSingleCellId @"single_cell_id"
#define kSubscribMainPage @"kFHHouseListSubscribCellId"
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
        _showHouseDict = [NSMutableDictionary new];
        
        self.tableView = tableView;
        self.houseType = houseType;
        self.isShowSubscribeCell = NO;

        tableView.delegate = self;
        tableView.dataSource = self;
        
        [_tableView registerClass:[FHSuggestionSubscribCell class] forCellReuseIdentifier:kSubscribMainPage];
        [_tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:kSingleCellId];
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
        
        _mainListPage =  [paramObj.sourceURL.host hasSuffix:@"main"];
        if (_mainListPage && _houseType == FHHouseTypeRentHouse) {
            self.tracerModel.originFrom = @"renting";
        }
        
        _isFirstLoad = YES;
        _canChangeHouseSearchDic = YES;
        _showPlaceHolder = YES;
        _showRedirectTip = YES;
    }
    return self;
}

-(void)initFilter
{
    id<FHHouseFilterBridge> bridge = [[FHHouseBridgeManager sharedInstance] filterBridge];
    self.houseFilterBridge = bridge;
    
    self.houseFilterViewModel = [bridge filterViewModelWithType:_houseType showAllCondition:YES showSort:YES];
    self.filterPanel = [bridge filterPannel:self.houseFilterViewModel];
    self.filterBgControl = [bridge filterBgView:self.houseFilterViewModel];
    self.houseFilterViewModel.delegate = self;
    
    self.filterPanel.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, kFilterBarHeight);
    
}


-(void)initTopBanner
{
    FHConfigDataModel *dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    
    if (_houseType == FHHouseTypeRentHouse) {
        FHConfigDataRentOpDataModel *rentModel = dataModel.rentOpData;
        if (rentModel.items.count > 0) {
            FHMainRentTopView *topView = [[FHMainRentTopView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH , ICON_HEADER_HEIGHT)];
            topView.items = rentModel.items;
            topView.delegate = self;
            self.topBannerView = topView;
        }
        
    }else if (_houseType == FHHouseTypeSecondHandHouse){
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

-(NSString *)originFrom
{
    return self.viewController.tracerModel.originFrom;
}

-(NSString *)originSearchId
{
    return self.viewController.tracerModel.originSearchId;
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

-(void)showErrorMask:(BOOL)show tip:(FHEmptyMaskViewType )type enableTap:(BOOL)enableTap
{
    if (show) {
        [self.tableView reloadData];
        [_errorMaskView showEmptyWithType:type];
        _errorMaskView.retryButton.enabled = enableTap;
        
        //        CGRect frame = self.tableView.frame;
        //        frame.origin = CGPointZero;
        //        self.errorMaskView.frame = frame;
        //        self.errorMaskView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
                
        CGFloat top = _topView.height; //self.tableView.contentOffset.y;
//        if (!_tableView.window) {
//            //还未显示
//            top = - _topView.height;
//        }
//        if (top > 0) {
//            top = 0;
//        }
        [_errorMaskView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(top);
        }];
        self.tableView.contentOffset = CGPointMake(0, -top);
        
        
        self.tableView.scrollEnabled = NO;
    }
    self.errorMaskView.hidden = !show;
}

- (void)requestAddSubScribe:(NSString *)text
{
    [_requestTask cancel];
    __weak typeof(self) wself = self;
    NSDictionary *paramsDict = nil;
    if (_houseType) {
        paramsDict = @{@"house_type":@(_houseType)};
    }
    
    TTHttpTask *task = [FHHouseListAPI requestAddSugSubscribe:_subScribeQuery params:paramsDict offset:_subScribeOffset searchId:_subScribeSearchId sugParam:nil class:[FHSugSubscribeModel class] completion:^(id<FHBaseModelProtocol>  _Nullable model, NSError * _Nullable error) {
        if ([model isKindOfClass:[FHSugSubscribeModel class]]) {
            FHSugSubscribeModel *infoModel = (FHSugSubscribeModel *)model;
            if (infoModel.data.items.firstObject) {
                FHSugSubscribeDataDataSubscribeInfoModel *subModel = (FHSugSubscribeDataDataSubscribeInfoModel *)infoModel.data.items.firstObject;
                
                NSMutableDictionary *dict = [NSMutableDictionary new];
                [dict setValue:text forKey:@"text"];
                [dict setValue:@"1" forKey:@"status"];
                [dict setValue:subModel.subscribeId forKey:@"subId"];

                [[NSNotificationCenter defaultCenter] postNotificationName:kFHSuggestionSubscribeNotificationKey object:nil userInfo:dict];
                
                NSMutableDictionary *uiDict = [NSMutableDictionary new];
                [uiDict setValue:@(YES) forKey:@"subscribe_state"];
                [uiDict setValue:subModel.subscribeId forKey:@"subscribe_id"];
                [uiDict setValue:subModel forKey:@"subscribe_item"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHSugSubscribeNotificationName" object:uiDict];
                
                NSMutableDictionary *dictClickParams = [NSMutableDictionary new];
                
                if (self.subScribeShowDict) {
                    [dictClickParams addEntriesFromDictionary:self.subScribeShowDict];
                }
                
                if (subModel.subscribeId) {
                    [dictClickParams setValue:subModel.subscribeId forKey:@"subscribe_id"];
                }
                
                if (subModel.title) {
                    [dictClickParams setValue:subModel.title forKey:@"title"];
                }else
                {
                    [dictClickParams setValue:@"be_null" forKey:@"title"];
                }
                
                if (subModel.text) {
                    [dictClickParams setValue:subModel.text forKey:@"text"];
                }else
                {
                    [dictClickParams setValue:@"be_null" forKey:@"text"];
                }
                
                if (dictClickParams) {
                    self.subScribeShowDict = [NSDictionary dictionaryWithDictionary:dictClickParams];
                }
                
                if (wself.subScribeShowDict) {
                    if (wself.subScribeShowDict) {
                        [dictClickParams setValue:@"confirm" forKey:@"click_type"];
                        TRACK_EVENT(@"subscribe_click",dictClickParams);
                    }
                }
            }
        }
        
    }];
    
    self.requestTask = task;
}

- (void)requestDeleteSubScribe:(NSString *)subscribeId andText:(NSString *)text
{
    [_requestTask cancel];
    __weak typeof(self) wself = self;
    TTHttpTask *task = [FHHouseListAPI requestDeleteSugSubscribe:subscribeId class:nil completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        if (!error) {
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setValue:text forKey:@"text"];
            [dict setValue:@"0" forKey:@"status"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFHSuggestionSubscribeNotificationKey object:nil userInfo:dict];
            
            NSMutableDictionary *uiDict = [NSMutableDictionary new];
            [uiDict setValue:@(NO) forKey:@"subscribe_state"];
            [uiDict setValue:subscribeId forKey:@"subscribe_id"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHSugSubscribeNotificationName" object:uiDict];
            
            if (wself.subScribeShowDict) {
                NSMutableDictionary *traceParams = [NSMutableDictionary dictionaryWithDictionary:self.subScribeShowDict];
                [traceParams setValue:@"cancel" forKey:@"click_type"];
                TRACK_EVENT(@"subscribe_click",traceParams);
            }
        }
    }];
    
    self.requestTask = task;
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
            self.showPlaceHolder = NO;
            [self showErrorMask:YES tip:FHEmptyMaskViewTypeNoNetWorkAndRefresh enableTap:YES ];
        }else{
            [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
            [self.tableView.mj_footer endRefreshing];
        }
        return;
    }
    
    __weak typeof(self) wself = self;
    if (_mainListPage && self.houseType == FHHouseTypeRentHouse) {
        
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
            [self showErrorMask:YES tip:tip enableTap:NO ];
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
        [self.showHouseDict removeAllObjects];
    }
    
    if (model) {
        
        
        NSMutableArray *items = nil;
        NSArray *recommendItems = nil;
        BOOL hasMore = NO;
        NSString *refreshTip = nil;
        FHSearchHouseDataRedirectTipsModel *redirectTips = nil;
        FHRecommendSecondhandHouseDataModel *recommendHouseDataModel = nil;
        
        if ([model isKindOfClass:[FHRecommendSecondhandHouseModel class]]) { //推荐
            recommendHouseDataModel = ((FHRecommendSecondhandHouseModel *)model).data;
            self.recommendSearchId = recommendHouseDataModel.searchId;
            hasMore = recommendHouseDataModel.hasMore;
            recommendItems = recommendHouseDataModel.items;
        } else if ([model isKindOfClass:[FHSearchHouseModel class]]) { // 列表页
            
            FHSearchHouseDataModel *houseModel = ((FHSearchHouseModel *)model).data;
            self.houseListOpenUrl = houseModel.houseListOpenUrl;
            self.mapFindHouseOpenUrl = houseModel.mapFindHouseOpenUrl;
            hasMore = houseModel.hasMore;
            refreshTip = houseModel.refreshTip;
            items = [NSMutableArray arrayWithArray:houseModel.items];
            redirectTips = houseModel.redirectTips;
            recommendHouseDataModel = houseModel.recommendSearchModel;
            recommendItems = recommendHouseDataModel.items;
            self.searchId = houseModel.searchId;
            if (recommendItems.count > 0) {
                self.recommendSearchId = recommendHouseDataModel.searchId;
                if (!hasMore) {
                    hasMore = recommendHouseDataModel.hasMore;
                }
                FHRecommendSecondhandHouseTitleModel *recommendTitleModel = [[FHRecommendSecondhandHouseTitleModel alloc]init];
                recommendTitleModel.noDataTip = recommendHouseDataModel.searchHint;
                recommendTitleModel.title = recommendHouseDataModel.recommendTitle;
                [self.sugesstHouseList addObject:recommendTitleModel];
            }
            
            if (isRefresh) {
                FHSugSubscribeDataDataSubscribeInfoModel *subscribeMode = houseModel.subscribeInfo;
                if ([subscribeMode isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
                    if (items.count > 9) {
                        [items insertObject:subscribeMode atIndex:9];
                    }else
                    {
                        [items addObject:subscribeMode];
                    }
                }
            }
            
        }else if ([model isKindOfClass:[FHHouseRentModel class]]){ //租房大类页
            FHHouseRentDataModel *rentModel = [(FHHouseRentModel *)model data];
            
            self.houseListOpenUrl = rentModel.houseListOpenUrl;
            self.mapFindHouseOpenUrl = rentModel.mapFindHouseOpenUrl;
            
            hasMore = rentModel.hasMore;
            refreshTip = rentModel.refreshTip;
            items = [NSMutableArray arrayWithArray:rentModel.items];
            self.searchId = rentModel.searchId;
        }
        
        self.viewController.tracerModel.searchId = self.searchId;
        if (self.isFirstLoad) {
            self.viewController.tracerModel.originSearchId = self.searchId;
            self.isFirstLoad = NO;
            if (self.searchId.length > 0 ) {
                SETTRACERKV(UT_ORIGIN_SEARCH_ID, self.searchId);
            }
        }
        
        self.showPlaceHolder = NO;
        if (!self.addEnterCategory) {
            [self addEnterLog];
            self.addEnterCategory = YES;
        }
        if (isRefresh) {
            [self addHouseSearchLog];
            [self addHouseRankLog];
            [self handleRefreshHouseOpenUrl:self.houseListOpenUrl];            
        } else {
            [self addLoadMoreRefreshLog];
        }
        
        if (!self.fromRecommend) {
            self.redirectTips = redirectTips;
            [self updateRedirectTipInfo];
        }
        
        [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
            }else if ([obj isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]){
                FHSingleImageInfoCellModel *cellModel = [[FHSingleImageInfoCellModel alloc]init];
                cellModel.subscribModel = obj;
                cellModel.isSubscribCell = YES;
                [self.houseList addObject:cellModel];
            }
        }];
        
        [recommendItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
        
        if (isRefresh && (items.count > 0 || recommendItems.count > 0) && !_showFilter) {
            [self showNotifyMessage:refreshTip];
        }
        
        if (self.houseList.count == 0 && self.sugesstHouseList.count == 0) {
            [self showErrorMask:YES tip:FHEmptyMaskViewTypeNoDataForCondition enableTap:NO ];
        } else {
            [self showErrorMask:NO tip:FHEmptyMaskViewTypeNoData enableTap:NO ];
            self.tableView.scrollEnabled = YES;
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
        [self showErrorMask:YES tip:FHEmptyMaskViewTypeNoData enableTap:YES ];
    }
}

-(void)showInputSearch
{
    [self addClickSearchLog];
    [self.houseFilterViewModel closeConditionFilterPanel];
    
    //house_search
    NSObject *sugDelegateTable = WRAP_WEAK(self);
    
    NSInteger fromHome = 3;//list
    NSMutableDictionary *traceParam = [self baseLogParam];
    if (_mainListPage) {
        
        if ( _houseType == FHHouseTypeRentHouse) {
            //租房大类页要重新设置originfrom
            NSString *originFrom = @"renting_search";
            SETTRACERKV(UT_ORIGIN_FROM,originFrom);
            id<FHHouseEnvContextBridge> envBridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
            [envBridge setTraceValue:originFrom forKey:UT_ORIGIN_FROM];
            fromHome = 4;//rent
            traceParam[UT_ELEMENT_FROM] = originFrom;
            traceParam[UT_PAGE_TYPE] = @"renting";
            traceParam[UT_ORIGIN_FROM] = originFrom;
        }else if (_houseType == FHHouseTypeSecondHandHouse){
            fromHome = 5; // list main
            sugDelegateTable = nil;
        }
        
    }
    traceParam[UT_ORIGIN_SEARCH_ID] = self.originSearchId ? : @"be_null";
    
    NSMutableDictionary *dict = @{@"house_type":@(_houseType) ,
                           @"tracer": traceParam,
                           @"from_home":@(fromHome)
                           }.mutableCopy;
    if (sugDelegateTable) {
        dict[@"sug_delegate"] = sugDelegateTable;
    }
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL *url = [NSURL URLWithString:@"sslocal://house_search"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    
}

-(void)showMapSearch
{
    if (_houseType == FHHouseTypeRentHouse && _mainListPage && self.mapFindHouseOpenUrl.length > 0) {
        NSURL *url = [NSURL URLWithString:self.mapFindHouseOpenUrl];
        NSDictionary *dict = @{};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }else{
        [self showOldMapSearch];
    }
}

#pragma mark 地图找房
-(void)showOldMapSearch
{
    /*
     1. event_type：house_app2c_v2
     2. click_type: 点击类型,{'地图找房': 'map', '房源列表': 'list'}
     3. category_name：category名,{'二手房列表页': 'old_list'}
     4. enter_from：category入口,{'首页': 'maintab', '找房tab': 'findtab'}
     5. enter_type：进入category方式,{'点击': 'click'}
     6. element_from：组件入口,{'首页搜索': 'maintab_search', '首页icon': 'maintab_icon', '找房tab开始找房': 'findtab_find', '找房tab搜索': 'findtab_search'}
     7. search_id
     8. origin_from
     9. origin_search_id
     */
    
    if (self.mapFindHouseOpenUrl.length > 0) {
        
        NSMutableString *openUrl = self.mapFindHouseOpenUrl;
        
        NSMutableDictionary *param = @{}.mutableCopy;
        param[UT_CATEGORY_NAME] = [self categoryName] ? : @"be_null";
        param[UT_ENTER_FROM] = self.tracerModel.enterFrom ? : @"be_null";
        param[UT_ENTER_TYPE] = self.tracerModel.enterType ? : @"be_null";
        param[UT_ELEMENT_FROM] = self.tracerModel.elementFrom ? : @"be_null";
        param[UT_SEARCH_ID] = self.searchId ? : @"be_null";
        param[UT_ORIGIN_FROM] = self.tracerModel.originFrom ? : @"be_null";
        param[UT_ORIGIN_SEARCH_ID] = self.originSearchId ? : @"be_null";
        
        param[@"click_type"] = @"map";
        param[UT_ENTER_TYPE] = @"click";
        TRACK_EVENT(@"click_switch_mapfind", param);
        
        NSMutableString *query = @"".mutableCopy;
        if (![self.mapFindHouseOpenUrl containsString:@"enter_category"]) {
            [query appendString:[NSString stringWithFormat:@"enter_category=%@",[self categoryName]]];
            
        }
        if (![self.mapFindHouseOpenUrl containsString:UT_ORIGIN_FROM]) {
            [query appendString:[NSString stringWithFormat:@"&origin_from=%@",self.tracerModel.originFrom ? : @"be_null"]];
            
        }
        if (![self.mapFindHouseOpenUrl containsString:UT_ORIGIN_SEARCH_ID]) {
            [query appendString:[NSString stringWithFormat:@"&origin_search_id=%@",self.originSearchId ? : @"be_null"]];
            
        }
        if (![self.mapFindHouseOpenUrl containsString:UT_ENTER_FROM]) {
            [query appendString:[NSString stringWithFormat:@"&enter_from=%@",[self pageTypeString]]];
            
        }
        if (![self.mapFindHouseOpenUrl containsString:UT_ELEMENT_FROM]) {
            [query appendString:[NSString stringWithFormat:@"&element_from=%@",self.tracerModel.elementFrom ? : @"be_null"]];
            
        }
        if (![self.mapFindHouseOpenUrl containsString:UT_SEARCH_ID]) {
            [query appendString:[NSString stringWithFormat:@"&search_id=%@",self.searchId ? : @"be_null"]];
            
        }
        if (query.length > 0) {
            
            openUrl = [NSString stringWithFormat:@"%@&%@",openUrl,query];
        }
        
        //需要重置非过滤器条件，以及热词placeholder
        [self.houseFilterBridge closeConditionFilterPanel];
        
        NSURL *url = [NSURL URLWithString:openUrl];
        NSMutableDictionary *dict = @{}.mutableCopy;
        
        NSHashTable *hashMap = [[NSHashTable alloc]initWithOptions:NSPointerFunctionsWeakMemory capacity:1];
        [hashMap addObject:self];
        dict[OPENURL_CALLBAK] = hashMap;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
    
}


-(void)handleRefreshHouseOpenUrl:(NSString *)openUrl
{
    if (openUrl.length < 1) {
        return;
    }
    TTRouteParamObj *paramObj = [[TTRoute sharedRoute]routeParamObjWithURL:[NSURL URLWithString:openUrl]];
    
    NSString *placeholder = nil;
    NSString *fullText = paramObj.queryParams[@"full_text"];
    NSString *displayText = paramObj.queryParams[@"display_text"];
    
    if (fullText.length > 0) {
        placeholder = fullText;
    }else if (displayText.length > 0) {
        placeholder = displayText;
    }
    
    if (placeholder.length == 0) {
        placeholder =  [self navbarPlaceholder];
    }
    
    self.navbar.placeHolder = placeholder;
    
    [self.houseFilterBridge setFilterConditions:paramObj.queryParams];
}

-(NSString *)navbarPlaceholder
{
//    if (self.topView && _houseType == FHHouseTypeRentHouse) {
//        //大类页
//        return @"你想住哪里？";
//    }
    switch (_houseType) {
            case FHHouseTypeNewHouse:
                return @"请输入楼盘名/地址";
            case FHHouseTypeSecondHandHouse:
                return @"请输入小区/商圈/地铁";
            case FHHouseTypeNeighborhood:
                return @"请输入小区/商圈/地铁";
            case FHHouseTypeRentHouse:
                return @"请输入小区/商圈/地铁";
        default:
            return @"";
            break;
    }
        
}

-(void)handleHouseListCallback:(NSString *)openUrl {
    
    if ([self.houseListOpenUrl isEqualToString:openUrl]) {
        return;
    }
    
    [self handleRefreshHouseOpenUrl:openUrl];
    [self.houseFilterViewModel trigerConditionChanged];
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
    }
    if (![openUrl containsString:UT_SEARCH_ID]) {
        [openUrl appendFormat:@"&search_id=%@",self.searchId?:@"be_null"];
    }
    TTRouteUserInfo *userInfo = nil;
    NSURL *url = nil;
    FHHouseRentFilterType filterType = [self rentFilterType:model.openUrl];
    
    NSString *originFrom = model.logPb[UT_ORIGIN_FROM];
    
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
        
        if (![openUrl containsString:UT_ENTER_FROM]) {
            [openUrl appendString:@"&enter_from=renting"];
        }
        if (![openUrl containsString:UT_ORIGIN_FROM]) {
            [openUrl appendFormat:@"&origin_from=%@",originFrom];
        }
        
        SETTRACERKV(UT_ORIGIN_FROM, originFrom);
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params addEntriesFromDictionary:[self.viewController.tracerModel neatLogDict] ];
        
        params[UT_ENTER_FROM] = @"renting";
        params[UT_ORIGIN_FROM] = originFrom;
        params[UT_ORIGIN_SEARCH_ID] = nil;//remove origin_search_id
        
        NSDictionary *infoDict = @{@"tracer":params};
        userInfo = [[TTRouteUserInfo alloc]initWithInfo:infoDict];
        
    }else{
        NSDictionary *param = [self addEnterHouseListLog:model.openUrl];
        if (param) {
            NSDictionary *infoDict = @{@"tracer":param};
            userInfo = [[TTRouteUserInfo alloc]initWithInfo:infoDict];
            if (originFrom.length == 0) {
                originFrom = param[UT_ORIGIN_FROM];
            }
            
            if (originFrom) {
                SETTRACERKV(UT_ORIGIN_FROM, originFrom);
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
    dict[UT_ENTER_FROM] = baseParams[UT_ENTER_FROM] ? : @"be_null";
    dict[UT_ELEMENT_FROM] = baseParams[UT_ELEMENT_FROM] ? : @"be_null";
    dict[UT_ORIGIN_FROM] = baseParams[UT_ORIGIN_FROM] ? : @"be_null";
    dict[UT_LOG_PB] = model.logPb ? : @"be_null";
    dict[UT_SEARCH_ID] = baseParams[UT_SEARCH_ID] ? : @"be_null";
    dict[UT_ORIGIN_SEARCH_ID] = baseParams[UT_ORIGIN_SEARCH_ID] ? : @"be_null";
    
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
    //只显示筛选器
    [self.topContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([self.topView filterBottom] - [self.topView filterTop]);
    }];
    [self scrollViewDidScroll:self.tableView];
    self.showFilter = YES;
}

-(void)onConditionPanelWillDisappear
{
    self.showFilter = NO;
    if (!self.errorMaskView.isHidden) {
        //显示无网或者无结果view
        self.tableView.contentOffset = CGPointMake(0, -self.topView.height);
    }
    [self scrollViewDidScroll:self.tableView];
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
        if (indexPath.section == 1 &&  [self.sugesstHouseList[indexPath.row] isKindOfClass:[FHRecommendSecondhandHouseTitleModel class]]) {
            FHRecommendSecondhandHouseTitleCell *scell = [tableView dequeueReusableCellWithIdentifier:kSugCellId];
            FHRecommendSecondhandHouseTitleModel *model = self.sugesstHouseList[indexPath.row];
            [scell bindData:model];
            
            if (self.isShowSubscribeCell) {
                [scell hideSeprateLine:self.houseList.count > 1 ? NO : YES];
            }
            
            cell = scell;
        } else {
            
            FHHouseBaseItemCell *scell = [tableView dequeueReusableCellWithIdentifier:kSingleCellId];
            BOOL isLastCell = NO;
            FHSingleImageInfoCellModel *cellModel = nil;
            if (indexPath.section == 0) {
                isLastCell = (indexPath.row == self.houseList.count - 1);
                if (indexPath.row < self.houseList.count) {
                    cellModel = self.houseList[indexPath.row];
                }
                
                if (cellModel.isSubscribCell) {
                    if ([cellModel.subscribModel isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
                        FHSugSubscribeDataDataSubscribeInfoModel *subscribModel = (FHSugSubscribeDataDataSubscribeInfoModel *)cellModel.subscribModel;
                        FHSuggestionSubscribCell *subScribCell = [tableView dequeueReusableCellWithIdentifier:kSubscribMainPage];
                        if ([subScribCell respondsToSelector:@selector(refreshUI:)]) {
                            [subScribCell refreshUI:subscribModel];
                        }
                        __weak typeof(self) weakSelf = self;
                        subScribCell.addSubscribeAction = ^(NSString * _Nonnull subscribeText) {
                            [weakSelf requestAddSubScribe:subscribeText];
                        };
                        
                        if (cellModel == self.houseList.lastObject) {
                            self.isShowSubscribeCell = YES;
                        }
                        
                        subScribCell.deleteSubscribeAction = ^(NSString * _Nonnull subscribeId) {
                            [weakSelf requestDeleteSubScribe:subscribeId andText:subscribModel.text];
                        };
                        return subScribCell;
                    }
                }
                
            } else {
                isLastCell = (indexPath.row == self.sugesstHouseList.count - 1);
                if (indexPath.row < self.sugesstHouseList.count) {
                    cellModel = self.sugesstHouseList[indexPath.row];
                }
            }
            if (cellModel) {
                CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHHouseBaseItemCell recommendReasonHeight] : 0; //显示榜单推荐
                [scell refreshTopMargin: 20];
                [scell updateWithHouseCellModel:cellModel];
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
    
    if (indexPath.section == 1 && [self.sugesstHouseList[indexPath.row] isKindOfClass:[FHRecommendSecondhandHouseTitleModel class]]) {
        CGFloat height = 44.5;
        FHRecommendSecondhandHouseTitleModel *titleModel = self.sugesstHouseList[indexPath.row];
        if (titleModel.noDataTip.length > 0) {
            height += 58;
        }
        if (self.isShowSubscribeCell) {
            if (titleModel.noDataTip.length > 0) {
                height -= 30;
            }else
            {
                height -= 3;
            }
        }
        return height;
    } else {
        BOOL isLastCell = NO;
        FHSingleImageInfoCellModel *cellModel = nil;
        if (indexPath.section == 0) {
            isLastCell = (indexPath.row == self.houseList.count - 1);
            cellModel = self.houseList[indexPath.row];
        } else {
            isLastCell = (indexPath.row == self.sugesstHouseList.count - 1);
            cellModel = self.sugesstHouseList[indexPath.row];
        }
        
        if (cellModel.isSubscribCell) {
            if ([cellModel.subscribModel isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
                return 121;
            }
        }
        
        CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHHouseBaseItemCell recommendReasonHeight] : 0;
        return (isLastCell ? 125 : 105)+reasonHeight;
        
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
    if (_showPlaceHolder) {
        return;
    }
    
    FHSingleImageInfoCellModel *cellModel = nil;
    if (indexPath.section == 0) {
        if (indexPath.row < self.houseList.count) {
            cellModel = self.houseList[indexPath.row];
        }
    } else {
        if (indexPath.row < self.sugesstHouseList.count) { //非FHSingleImageInfoCellModel 在后面会直接返回
            cellModel = self.sugesstHouseList[indexPath.row];           
        }
    }
    
    if (!cellModel || ![cellModel isKindOfClass:[FHSingleImageInfoCellModel class]]) {
        return;
    }
    
    [self showHouseDetail:cellModel atIndexPath:indexPath];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.showFilter) {
        //正在展示筛选器
        return;
    }
    BOOL shouldInTable = (scrollView.contentOffset.y + scrollView.contentInset.top <  [self.topView filterTop]);
    [self moveToTableView:shouldInTable];
    
}


-(void)moveToTableView:(BOOL)toTableView
{
    if (toTableView) {
        if (!self.topBannerView) {
            return;
        }
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


#pragma mark - goto detail
-(void)showHouseDetail:(FHSingleImageInfoCellModel *)cellModel atIndexPath:(NSIndexPath *)indexPath
{
    id<FHHouseEnvContextBridge> contextBridge = [[FHHouseBridgeManager sharedInstance]envContextBridge];
    NSMutableDictionary *tracerParam = [NSMutableDictionary dictionary];
    NSString *urlStr = nil;
    tracerParam[@"card_type"] = @"left_pic";
    
    if (_mainListPage && self.houseType == FHHouseTypeRentHouse) {
        
        SETTRACERKV(UT_ORIGIN_FROM, @"renting_list");
        
        id<FHHouseEnvContextBridge> envBridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
        [envBridge setTraceValue:self.originSearchId forKey:UT_ORIGIN_SEARCH_ID];
        
        [tracerParam addEntriesFromDictionary:[self.viewController.tracerModel neatLogDict]];        
        tracerParam[UT_ELEMENT_FROM] = @"be_null";
        tracerParam[UT_ENTER_FROM] = @"renting";
        tracerParam[UT_LOG_PB] = cellModel.logPb;
        tracerParam[@"rank"] = @(indexPath.row);
        tracerParam[UT_ORIGIN_FROM] = @"renting_list";
        tracerParam[UT_ORIGIN_SEARCH_ID] = self.originSearchId ? : @"be_null";
        
        urlStr = [NSString stringWithFormat:@"fschema://rent_detail?house_id=%@", cellModel.rentModel.id];
        
    }else if (self.houseType == FHHouseTypeSecondHandHouse){
        
        NSInteger rank = ((indexPath.section == 0) ? indexPath.row : indexPath.row - 1);
        
        if (cellModel.isRecommendCell) {
            tracerParam[UT_ENTER_FROM] = [self pageTypeString];
            tracerParam[UT_ELEMENT_FROM] = @"search_related";
            tracerParam[UT_SEARCH_ID] = self.recommendSearchId;
        } else {
            tracerParam[UT_ENTER_FROM] = [self pageTypeString];
            tracerParam[UT_ELEMENT_FROM] = [self elementTypeString];
            tracerParam[UT_SEARCH_ID] = self.searchId;
        }
        tracerParam[UT_LOG_PB] = [cellModel logPb];
        tracerParam[UT_ORIGIN_FROM] = self.originFrom;
        tracerParam[UT_ORIGIN_SEARCH_ID] = self.originSearchId ?:@"be_null";
        tracerParam[@"rank"] = @(rank);
        
        [contextBridge setTraceValue:self.originFrom forKey:UT_ORIGIN_FROM];
        [contextBridge setTraceValue:self.originSearchId forKey:UT_ORIGIN_SEARCH_ID];
        
        switch (self.houseType) {
                case FHHouseTypeNewHouse: {
                    if (cellModel.houseModel) {
                        FHNewHouseItemModel *theModel = cellModel.houseModel;
                        urlStr = [NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",theModel.houseId];
                    }
                }
                break;
                case FHHouseTypeSecondHandHouse: {
                    if (cellModel.secondModel) {
                        FHSearchHouseDataItemsModel *theModel = cellModel.secondModel;
                        urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",theModel.hid];
                    }
                }
                break;
                case FHHouseTypeRentHouse: {
                    if (cellModel.rentModel) {
                        FHHouseRentDataItemsModel *theModel = cellModel.rentModel;
                        urlStr = [NSString stringWithFormat:@"sslocal://rent_detail?house_id=%@",theModel.id];
                    }
                }
                break;
                case FHHouseTypeNeighborhood: {
                    if (cellModel.neighborModel) {
                        FHHouseNeighborDataItemsModel *theModel = cellModel.neighborModel;
                        urlStr = [NSString stringWithFormat:@"sslocal://neighborhood_detail?neighborhood_id=%@",theModel.id];
                    }
                }
                break;
            default:
                break;
        }
    }
    
    if (urlStr) {
        NSURL *url = [NSURL URLWithString:urlStr];
        if (url) {
            TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer": tracerParam,@"house_type":@(self.houseType)}];
            [[TTRoute sharedRoute] openURLByViewController:url userInfo: userInfo];
        }
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
    param[UT_ORIGIN_SEARCH_ID] = self.originSearchId ?: @"be_null";
    param[UT_SEARCH_ID] = self.searchId ?: @"be_null";
    if (_mainListPage && self.houseType == FHHouseTypeRentHouse) {
        param[UT_ENTER_FROM] = @"renting";
    }
    
    return param;
}

-(NSString *)pageTypeString
{
    if (_mainListPage && _houseType == FHHouseTypeRentHouse) {
        return @"renting";
    }
    return @"old_kind_list";
}

-(NSString *)categoryName
{
    if (_mainListPage) {
        if (_houseType == FHHouseTypeRentHouse) {
            return @"renting";
        }
        return @"old_kind_list";
    }
    
    switch (self.houseType) {
            case FHHouseTypeNewHouse:
            return @"new_list";
            break;
            case FHHouseTypeSecondHandHouse:
            return @"old_list";
            break;
            case FHHouseTypeRentHouse:
            return @"rent_list";
            break;
            case FHHouseTypeNeighborhood:
            return @"neighborhood_list";
            break;
        default:
            return @"be_null";
            break;
    }
}

-(NSString *)houseTypeString
{
    switch (self.houseType) {
            case FHHouseTypeNewHouse:
            return @"new";
            break;
            case FHHouseTypeSecondHandHouse:
            return @"old";
            break;
            case FHHouseTypeRentHouse:
            return @"rent";
            break;
            case FHHouseTypeNeighborhood:
            return @"neighborhood";
            break;
        default:
            return @"be_null";
            break;
    }
}

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

    NSMutableDictionary *homeParams = [NSMutableDictionary new];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[UT_PAGE_TYPE] = [self pageTypeString];
    params[UT_ORIGIN_SEARCH_ID] = self.originSearchId?:@"be_null";
    params[@"hot_word"] = @"be_null";
    if (_mainListPage && _houseType == FHHouseTypeRentHouse) {
        params[UT_ORIGIN_FROM] = @"renting_search";
    }else{
        params[@"origin_from"] = self.originFrom.length > 0 ? self.originFrom : @"be_null";
    }
    params[UT_ORIGIN_SEARCH_ID] = self.viewController.tracerModel.originSearchId;
    
    TRACK_EVENT(@"click_house_search",params);
}

- (void)addHouseSearchLog
{
    if (_mainListPage && _houseType == FHHouseTypeRentHouse) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (self.houseSearchDic) {
        [params addEntriesFromDictionary:self.houseSearchDic];
    } else {
        // house_search 上报时机是通过搜索（搜索页面）进入的搜索列表页，而通过搜索点击tab进入的不上报当前埋点，过滤器重新选择后也上报
        return;
    }
    params[@"house_type"] = [self houseTypeString];
    params[UT_ORIGIN_SEARCH_ID] = self.originSearchId.length > 0 ? self.originSearchId : @"be_null";
    params[UT_SEARCH_ID] =  self.searchId.length > 0 ? self.searchId : @"be_null";
    params[UT_ORIGIN_FROM] = self.viewController.tracerModel.originFrom.length > 0 ? self.viewController.tracerModel.originFrom : @"be_null";
    TRACK_EVENT(@"house_search",params);
    self.canChangeHouseSearchDic = YES;
}

- (void)addOperationShowLog:(NSString *)operationName
{
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"operation_name"] = operationName ? : @"be_null";
    tracerDict[UT_PAGE_TYPE] = [self pageTypeString];
    [FHUserTracker writeEvent:@"operation_show" params:tracerDict];
}

- (void)addOperationClickLog:(NSString *)operationName
{
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"operation_name"] = operationName ? : @"be_null";
    tracerDict[UT_PAGE_TYPE] = [self pageTypeString];
    [FHUserTracker writeEvent:@"operation_click" params:tracerDict];
}


-(void)addStayLog:(NSTimeInterval)duration
{
    duration = duration * 1000.0;
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
    
    self.stayTraceDict[@"stay_time"] = [NSString stringWithFormat:@"%.0f",duration];
    
    TRACK_EVENT(@"stay_category", self.stayTraceDict);
    [self.viewController tt_resetStayTime];
    
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
    
    //    param[UT_SEARCH_ID] = self.searchId;
    param[@"refresh_type"] = @"pre_load_more";
    param[UT_ENTER_FROM] = self.viewController.tracerModel.enterFrom?:@"maintab";
    
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
        if (indexPath.row < self.sugesstHouseList.count) {
            cellModel = self.sugesstHouseList[indexPath.row];
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
    NSInteger rank = indexPath.section == 0 ? indexPath.row : indexPath.row - 1;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"house_type"] =  [self houseTypeString] ? : @"be_null";
    param[@"card_type"] = @"left_pic";
    
    if (cellModel.isRecommendCell) {
        param[UT_PAGE_TYPE] = [self pageTypeString];
        param[@"element_type"] = @"search_related";
        param[UT_SEARCH_ID] = self.recommendSearchId ? : @"be_null";
    } else {
        param[UT_PAGE_TYPE] = [self pageTypeString];
        param[@"element_type"] = @"be_null";
        param[UT_SEARCH_ID] = self.searchId ? : @"be_null";
    }
    
    param[@"group_id"] = cellModel.groupId;
    param[@"impr_id"] = cellModel.imprId;
    param[UT_SEARCH_ID] = self.searchId;
    param[@"rank"] = @(indexPath.row);
    param[UT_LOG_PB] = cellModel.logPb;
    param[UT_ORIGIN_FROM] = baseParam[UT_ORIGIN_FROM] ? : @"be_null";;
    param[UT_ORIGIN_SEARCH_ID] = self.viewController.tracerModel.originSearchId ? : @"be_null";;
    
    if (cellModel.isSubscribCell) {
        if ([cellModel.subscribModel isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
            FHSugSubscribeDataDataSubscribeInfoModel *cellSubModel = (FHSugSubscribeDataDataSubscribeInfoModel *)cellModel.subscribModel;
            if ([cellSubModel.subscribeId isKindOfClass:[NSString class]] && [cellSubModel.subscribeId integerValue] != 0) {
                [param setValue:cellSubModel.subscribeId forKey:@"subscribe_id"];
            }else
            {
                [param setValue:@"be_null" forKey:@"subscribe_id"];
            }
            
            if (cellSubModel.title) {
                [param setValue:cellSubModel.title forKey:@"title"];
            }else
            {
                [param setValue:@"be_null" forKey:@"title"];
            }
            
            if (cellSubModel.text) {
                [param setValue:cellSubModel.text forKey:@"text"];
            }else
            {
                [param setValue:@"be_null" forKey:@"text"];
            }
        }
        
        [param removeObjectForKey:@"impr_id"];
        [param removeObjectForKey:@"group_id"];
        self.subScribeShowDict = param;
        TRACK_EVENT(@"subscribe_show", param);

    }else
    {
        TRACK_EVENT(@"house_show", param);
    }
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
    param[UT_CATEGORY_NAME] = @"rent_list";
    param[UT_ENTER_TYPE] = @"click";
    param[UT_ELEMENT_FROM] = @"renting_icon";
    param[UT_SEARCH_ID] = self.searchId;
    
    param[UT_ORIGIN_FROM] = originFrom;
    if (!param[UT_ORIGIN_SEARCH_ID]) {
        param[UT_ORIGIN_SEARCH_ID] = @"be_null";
    }
    
    return param;
}

- (void)addHouseRankLog
{
    NSString *sortType = nil;
    if ([self.houseFilterViewModel isLastSearchBySort]) {
        sortType =  [self.houseFilterViewModel sortType] ? : @"default";
    }
    
    if (sortType.length < 1) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[UT_PAGE_TYPE] = [self pageTypeString];//@"renting";
    params[@"rank_type"] = sortType;
    params[UT_ORIGIN_SEARCH_ID] = self.originSearchId.length > 0 ? self.originSearchId : @"be_null";
    params[UT_SEARCH_ID] =  self.searchId.length > 0 ? self.searchId : @"be_null";
    params[UT_ORIGIN_FROM] = self.originFrom ? : @"be_null";//
    TRACK_EVENT(@"house_rank",params);
}


#pragma mark - sug delegate
-(void)suggestionSelected:(TTRouteObject *)routeObject
{
    NSMutableDictionary *allInfo = [routeObject.paramObj.userInfo.allInfo mutableCopy];
    if (_mainListPage && _houseType == FHHouseTypeRentHouse) {
        //JUMP to cat list page
        
        NSMutableDictionary *tracerDict = [self baseLogParam];
        [tracerDict addEntriesFromDictionary:allInfo[@"houseSearch"]];
        tracerDict[UT_CATEGORY_NAME] = @"rent_list";
        tracerDict[UT_ELEMENT_FROM] = @"renting_search";
        tracerDict[UT_PAGE_TYPE] = @"renting";
        tracerDict[UT_ORIGIN_FROM] = allInfo[@"tracer"][UT_ORIGIN_FROM] ? allInfo[@"tracer"][UT_ORIGIN_FROM] : @"be_null";
        
        NSMutableDictionary *houseSearchDict = [[NSMutableDictionary alloc] initWithDictionary:allInfo[@"houseSearch"]];
        houseSearchDict[UT_PAGE_TYPE] = @"renting";
        allInfo[@"houseSearch"] = houseSearchDict;
        allInfo[@"tracer"] = tracerDict;
        
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:allInfo];
        
        routeObject.paramObj.userInfo = userInfo;
        [[TTRoute sharedRoute] openURLByPushViewController:routeObject.paramObj.sourceURL userInfo:routeObject.paramObj.userInfo];
    }
    
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

