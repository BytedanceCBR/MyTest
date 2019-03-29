//
//  FHHouseListViewModel.m
//  FHHouseList
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHHouseListViewModel.h"
#import <MJRefresh.h>
#import "FHRefreshCustomFooter.h"
#import "TTHttpTask.h"
#import "FHHouseListAPI.h"
#import "FHSearchHouseModel.h"
#import "FHHouseNeighborModel.h"
#import "FHHouseRentModel.h"
#import "FHNewHouseItemModel.h"

#import "FHSingleImageInfoCellModel.h"
#import "FHPlaceHolderCell.h"
#import "TTReachability.h"
#import "FHMainManager+Toast.h"
#import <UIScrollView+Refresh.h>
#import "FHSearchFilterOpenUrlModel.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "FHMapSearchOpenUrlDelegate.h"
#import "FHUserTracker.h"
#import "FHHouseBridgeManager.h"
#import "FHHouseListRedirectTipView.h"
#import "Masonry.h"
#import "FHEnvContext.h"
#import "FHRecommendSecondhandHouseTitleCell.h"
#import "FHRecommendSecondhandHouseTitleModel.h"
#import "FHHouseBridgeManager.h"
#import "FHCityListViewModel.h"
#import <FHHouseBase/FHHouseBaseItemCell.h>
#import "HMDTTMonitor.h"
#import "TTInstallIDManager.h"
#import "FHSugSubscribeModel.h"
#import "FHSuggestionSubscribCell.h"

@interface FHHouseListViewModel () <UITableViewDelegate, UITableViewDataSource, FHMapSearchOpenUrlDelegate, FHHouseSuggestionDelegate>

@property(nonatomic , weak) FHErrorView *maskView;
@property (nonatomic , weak) FHHouseListRedirectTipView *redirectTipView;

@property(nonatomic, weak) UITableView *tableView;

@property(nonatomic , strong) NSMutableArray *houseList;
@property(nonatomic , strong) NSMutableArray *sugesstHouseList;
@property(nonatomic , strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic , weak) TTHttpTask * requestTask;
@property (nonatomic , copy, nullable) NSString *searchId;
@property (nonatomic , copy, nullable) NSString *recommendSearchId;
@property (nonatomic , copy) NSString *originSearchId;
@property (nonatomic , copy) NSString *originFrom;
@property (nonatomic , strong) NSDictionary *houseSearchDic;
@property(nonatomic , assign) BOOL canChangeHouseSearchDic;// houseSearchDic[@"query_type"] = @"filter"

@property(nonatomic , strong) FHSearchFilterOpenUrlModel *filterOpenUrlMdodel;

@property(nonatomic , assign) BOOL showPlaceHolder;
@property(nonatomic , assign) BOOL lastHasMore;

@property (nonatomic , assign) BOOL isRefresh;
@property (nonatomic , copy) NSString *query;
@property (nonatomic , copy) NSString *condition;

@property (nonatomic, copy) NSString *mapFindHouseOpenUrl;
@property(nonatomic , strong) NSMutableDictionary *houseShowCache;
@property(nonatomic , strong) FHTracerModel *tracerModel;
@property (nonatomic, strong , nullable) FHSearchHouseDataRedirectTipsModel *redirectTips;

// log
@property (nonatomic , assign) BOOL isFirstLoad;
@property (nonatomic , assign) BOOL fromRecommend;

//subscribe
@property (nonatomic , assign) NSInteger subScribeOffset;
@property (nonatomic , strong) NSString * subScribeSearchId;
@property (nonatomic , strong) NSString * subScribeQuery;
@property (nonatomic , strong) NSDictionary * subScribeShowDict;
@property (nonatomic , assign) BOOL isShowSubscribeCell;

@end


@implementation FHHouseListViewModel

-(void)setMaskView:(FHErrorView *)maskView {
    
    __weak typeof(self)wself = self;
    _maskView = maskView;
    _maskView.retryBlock = ^{
        
        [wself loadData:wself.isRefresh];
    };
}

-(void)setRedirectTipView:(FHHouseListRedirectTipView *)redirectTipView
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

-(void)updateRedirectTipInfo {
    
    if (self.showRedirectTip && self.redirectTips) {
        
        self.redirectTipView.hidden = NO;
        self.redirectTipView.text = self.redirectTips.text;
        self.redirectTipView.text1 = self.redirectTips.text2;
        [self.redirectTipView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(36);
        }];
        
        NSDictionary *params = @{@"page_type":@"city_switch",
                                 @"enter_from":@"search"};
        [FHUserTracker writeEvent:@"city_switch_show" params:params];

    }else {
        self.redirectTipView.hidden = YES;
        [self.redirectTipView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
}

-(void)closeRedirectTip {
    
    self.showRedirectTip = NO;
    self.redirectTipView.hidden = YES;
    [self.redirectTipView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    NSDictionary *params = @{@"click_type":@"cancel",
                             @"enter_from":@"search"};
    [FHUserTracker writeEvent:@"city_click" params:params];
}

-(void)clickRedirectTip {
    
    if (self.redirectTips.openUrl.length > 0) {

        [FHEnvContext openSwitchCityURL:self.redirectTips.openUrl completion:^(BOOL isSuccess) {
            // 进历史
            if (isSuccess) {
                [[[FHHouseBridgeManager sharedInstance] cityListModelBridge] switchCityByOpenUrlSuccess];
            }
        }];
        NSDictionary *params = @{@"click_type":@"switch",
                                 @"enter_from":@"search"};
        [FHUserTracker writeEvent:@"city_click" params:params];
    }
}

-(instancetype)initWithTableView:(UITableView *)tableView routeParam:(TTRouteParamObj *)paramObj {

    self = [super init];
    if (self) {

        _canChangeHouseSearchDic = YES;
        self.houseList = [NSMutableArray array];
        self.sugesstHouseList = [NSMutableArray array];
        self.showPlaceHolder = YES;
        self.isRefresh = YES;
        self.isEnterCategory = YES;
        self.isFirstLoad = YES;
        self.tableView = tableView;
        self.showRedirectTip = YES;
        self.isShowSubscribeCell = NO;
        self.filterOpenUrlMdodel = [FHSearchFilterOpenUrlModel instanceFromUrl:[paramObj.sourceURL absoluteString]];
        
        NSString *houseTypeStr = paramObj.allParams[@"house_type"];
        self.houseType = houseTypeStr.length > 0 ? houseTypeStr.integerValue : FHHouseTypeSecondHandHouse;

        self.houseSearchDic = paramObj.userInfo.allInfo[@"houseSearch"];
        NSDictionary *tracerDict = paramObj.allParams[@"tracer"];
        if (tracerDict) {
            self.tracerModel = [FHTracerModel makerTracerModelWithDic:tracerDict];
            self.originFrom = self.tracerModel.originFrom;
        }
        [self configTableView];

    }
    return self;
}

-(void)configTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    __weak typeof(self)wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        wself.isRefresh = NO;
        if (wself.sugesstHouseList.count > 0) {
            wself.fromRecommend = YES;
            [wself loadData:wself.isRefresh fromRecommend:YES];
        } else {
            wself.fromRecommend = NO;
            [wself loadData:wself.isRefresh];
        }
    }];
    self.tableView.mj_footer = self.refreshFooter;
    
    [self.tableView registerClass:[FHSuggestionSubscribCell class] forCellReuseIdentifier:kFHHouseListSubscribCellId];

    [self.tableView registerClass:[FHRecommendSecondhandHouseTitleCell class] forCellReuseIdentifier:kFHHouseListRecommendTitleCellId];
    [self.tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:kFHHouseListPlaceholderCellId];
    [self.tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:kBaseCellId];
}


-(void)loadData:(BOOL)isRefresh {
    [self loadData:isRefresh fromRecommend:self.fromRecommend];
}

#pragma mark - 网络请求
-(void)loadData:(BOOL)isRefresh fromRecommend:(BOOL)isFromRecommend
{
    if (![TTReachability isNetworkConnected]) {
        if (isRefresh) {
            [self.maskView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            [self showMaskView:YES];
        }else{
            [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
            [self.tableView.mj_footer endRefreshing];
        }
        return;
    }
    
    NSString *query = self.condition;
    NSInteger offset = 0;
    NSMutableDictionary *param = [NSMutableDictionary new];

    if (isRefresh) {
        if (!_isFirstLoad && _canChangeHouseSearchDic) {
            if (self.houseSearchDic.count <= 0) {
                // pageType 默认就是 [self pageTypeString]
                self.houseSearchDic = @{
                                        @"enter_query":@"be_null",
                                        @"search_query":@"be_null",
                                        @"page_type": [self pageTypeString],
                                        @"query_type":@"filter"
                                        };
            } else {
                NSMutableDictionary *dic = [self.houseSearchDic mutableCopy];
                dic[@"query_type"] = @"filter";
                self.houseSearchDic = dic;
            }
        }
        self.tableView.mj_footer.hidden = YES;
        [self.houseShowCache removeAllObjects];
        self.searchId = nil;
    } else {
        if (isFromRecommend) {
            offset = self.sugesstHouseList.count - 1;
        } else {
            offset = self.houseList.count;
        }
    }
    
    NSString *searchId = self.searchId;

    
    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            
            [self requestNewHouseListData:isRefresh query:query offset:offset searchId:searchId];
            break;
        case FHHouseTypeSecondHandHouse:
            if (isFromRecommend) {
                [self requestRecommendErshouHouseListData:isRefresh query:query offset:offset searchId:self.recommendSearchId];
            } else {
                [self requestErshouHouseListData:isRefresh query:query offset:offset searchId:searchId];
            }
            break;
            
        case FHHouseTypeRentHouse:
            
            [self requestRentHouseListData:isRefresh query:query offset:offset searchId:searchId];
            break;
            
        case FHHouseTypeNeighborhood:
            
            [self requestNeiborhoodHouseListData:isRefresh query:query offset:offset searchId:searchId];
            break;
            
        default:
            break;
    }
    
    
}


-(void)requestNewHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [_requestTask cancel];

    __weak typeof(self) wself = self;
    
    TTHttpTask *task = [FHHouseListAPI searchNewHouseList:query params:nil offset:offset searchId:searchId sugParam:nil class:[FHNewHouseListResponseModel class] completion:^(FHNewHouseListResponseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }

        [wself processData:model error:error];
    }];
    
    self.requestTask = task;
}

-(void)requestNeiborhoodHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [_requestTask cancel];
    
    __weak typeof(self) wself = self;

    TTHttpTask *task = [FHHouseListAPI searchNeighborhoodList:query params:nil offset:offset searchId:searchId sugParam:nil class:[FHHouseNeighborModel class] completion:^(FHHouseNeighborModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }

        [wself processData:model error:error];
    }];
    
    self.requestTask = task;
}


-(void)requestRentHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [_requestTask cancel];
    
    __weak typeof(self) wself = self;
    
    TTHttpTask *task = [FHMainApi searchRent:query params:nil offset:offset searchId:searchId sugParam:nil completion:^(FHHouseRentModel * _Nonnull model, NSError * _Nonnull error) {
        
        if (!wself) {
            return ;
        }
        [wself processData:model error:error];
        
    }];
    
    self.requestTask = task;
}


-(void)requestErshouHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [_requestTask cancel];
    
    __weak typeof(self) wself = self;
    
    if (self.isRefresh) {
        if (query) {
            self.subScribeQuery = [NSString stringWithString:query];
        }
        self.subScribeOffset = offset;
        if (searchId) {
            self.subScribeSearchId = [NSString stringWithString:searchId];
        }
    }
    
    TTHttpTask *task = [FHHouseListAPI searchErshouHouseList:query params:nil offset:offset searchId:searchId sugParam:nil class:[FHSearchHouseModel class] completion:^(FHSearchHouseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }
        [wself processData:model error:error];
        
    }];
    
    self.requestTask = task;
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
                    [dictClickParams setValue:@"confirm" forKey:@"click_type"];
                    TRACK_EVENT(@"subscribe_click",dictClickParams);
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



-(void)requestRecommendErshouHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [_requestTask cancel];
    
    __weak typeof(self) wself = self;
    
    TTHttpTask *task = [FHHouseListAPI recommendErshouHouseList:query params:nil offset:offset searchId:searchId sugParam:nil class:[FHRecommendSecondhandHouseModel class] completion:^(FHRecommendSecondhandHouseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }
        [wself processData:model error:error];
        
        
    }];
    
    self.requestTask = task;
}



-(void)processData:(id<FHBaseModelProtocol>)model error: (NSError *)error {
    
    if (error) {
        
        [self processError:error];
        return;
    }
    
    if (self.isRefresh) {
        [self.houseList removeAllObjects];
        [self.sugesstHouseList removeAllObjects];
        [self.tableView.mj_footer endRefreshing];
    }
    
    if (model) {

//        NSString *searchId;
//        NSString *houseListOpenUrl;
//        NSString *mapFindHouseOpenUrl;
        NSMutableArray *itemArray = [NSMutableArray new];
        NSArray *recommendItemArray = @[];
        BOOL hasMore = NO;
        NSString *refreshTip;
        FHSearchHouseDataRedirectTipsModel *redirectTips;
        FHRecommendSecondhandHouseDataModel *recommendHouseDataModel;

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
            
            if (self.isRefresh) {
                FHSugSubscribeDataDataSubscribeInfoModel *subscribeMode = houseModel.subscribeInfo;
                if ([subscribeMode isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
                    if (itemArray.count > 9) {
                        [itemArray insertObject:subscribeMode atIndex:9];
                    }else
                    {
                        [itemArray addObject:subscribeMode];
                    }
                }
            }
    
        } else if ([model isKindOfClass:[FHNewHouseListResponseModel class]]) {
            
            FHNewHouseListDataModel *houseModel = ((FHNewHouseListResponseModel *)model).data;
            self.searchId = houseModel.searchId;
            self.houseListOpenUrl = houseModel.houseListOpenUrl;
            hasMore = houseModel.hasMore;
            refreshTip = houseModel.refreshTip;
            itemArray = houseModel.items;
            redirectTips = houseModel.redirectTips;

        } else if ([model isKindOfClass:[FHHouseRentModel class]]) {

            FHHouseRentDataModel *houseModel = ((FHHouseRentModel *)model).data;
            self.searchId = houseModel.searchId;
            self.houseListOpenUrl = houseModel.houseListOpenUrl;
            self.mapFindHouseOpenUrl = houseModel.mapFindHouseOpenUrl;
            hasMore = houseModel.hasMore;
            refreshTip = houseModel.refreshTip;
            itemArray = houseModel.items;
            redirectTips = houseModel.redirectTips;

        } else if ([model isKindOfClass:[FHHouseNeighborModel class]]) {

            FHHouseNeighborDataModel *houseModel = ((FHHouseNeighborModel *)model).data;
            self.searchId = houseModel.searchId;
            self.houseListOpenUrl = houseModel.houseListOpenUrl;
            hasMore = houseModel.hasMore;
            refreshTip = houseModel.refreshTip;
            itemArray = houseModel.items;
            redirectTips = houseModel.redirectTips;

        }
        // 二手房、租房应该有 houseListOpenUrl
        if (self.houseType == FHHouseTypeSecondHandHouse || self.houseType == FHHouseTypeRentHouse) {
            if (self.houseListOpenUrl.length <= 0) {
                NSString *res = [NSString stringWithFormat:@"%ld",self.houseType];
                // device_id
                NSString *did = [[TTInstallIDManager sharedInstance] deviceID];
                if (did.length == 0) {
                    did = @"null";
                }
                [[HMDTTMonitor defaultManager] hmdTrackService:@"house_list_no_map_openurl"
                                                        metric:nil
                                                      category:@{@"status":@(0),@"house_type":res}
                                                         extra:@{@"device_id":did}];
            }
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
            [self addEnterCategoryLog];
            self.isEnterCategory = NO;
        }
        if (self.isRefresh) {
            [self addHouseSearchLog];
            [self addHouseRankLog];
            [self refreshHouseListUrlCallback:self.houseListOpenUrl];
        } else {
            [self addCategoryRefreshLog];
        }

        if (!self.fromRecommend) {
            
            self.redirectTips = redirectTips;
            [self updateRedirectTipInfo];
        }

        [itemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            FHSingleImageInfoCellModel *cellModel = [self houseItemByModel:obj];
            if (cellModel) {
                cellModel.isRecommendCell = NO;
                if ([cellModel.subscribModel isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
                    cellModel.isSubscribCell = YES;
                }else
                {
                    cellModel.isSubscribCell = NO;
                }
                [self.houseList addObject:cellModel];
            }

        }];
        
        [recommendItemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            FHSingleImageInfoCellModel *cellModel = [self houseItemByModel:obj];
            if (cellModel) {
                cellModel.isRecommendCell = YES;
                [self.sugesstHouseList addObject:cellModel];
            }
            
        }];
        
        [self.tableView reloadData];
        
        
        [self updateTableViewWithMoreData:hasMore];
        
        if (self.houseType != FHHouseTypeSecondHandHouse) {
            if (!hasMore && self.houseList.count < 10) {
                self.refreshFooter.hidden = YES;
            }
        }

        if (self.isRefresh && self.viewModelDelegate && itemArray.count > 0) {
            [self.viewModelDelegate showNotify:refreshTip inViewModel:self];
        }
        
        if (self.houseList.count == 0 && self.sugesstHouseList.count == 0) {
            [self.maskView showEmptyWithType:FHEmptyMaskViewTypeNoDataForCondition];
        } else {
            [self showMaskView:NO];
        }
        
        // 刷新请求的时候将列表滑动在最顶部
        if (self.isRefresh) {
            if (self.houseList.count > 0) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            } else if (self.sugesstHouseList.count > 0) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }
    } else {
        [self.maskView showEmptyWithType:FHEmptyMaskViewTypeNoData];
    }
}

-(FHSingleImageInfoCellModel *)houseItemByModel:(id)obj {

    FHSingleImageInfoCellModel *cellModel = [[FHSingleImageInfoCellModel alloc]init];
    
    if ([obj isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
        
        FHSearchHouseDataItemsModel *item = (FHSearchHouseDataItemsModel *)obj;
        cellModel.secondModel = obj;
        
    }else if ([obj isKindOfClass:[FHNewHouseItemModel class]]) {
        
        FHSearchHouseDataItemsModel *item = (FHSearchHouseDataItemsModel *)obj;
        cellModel.houseModel = obj;
        
    }else if ([obj isKindOfClass:[FHHouseRentDataItemsModel class]]) {
        
        FHHouseRentDataItemsModel *item = (FHHouseRentDataItemsModel *)obj;
        cellModel.rentModel = obj;
        
    } else if ([obj isKindOfClass:[FHHouseNeighborDataItemsModel class]]) {
        
        FHHouseNeighborDataItemsModel *item = (FHHouseNeighborDataItemsModel *)obj;
        cellModel.neighborModel = obj;
        
    }else if ([obj isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
        
        FHSugSubscribeDataDataSubscribeInfoModel *item = (FHSugSubscribeDataDataSubscribeInfoModel *)obj;
        cellModel.subscribModel = obj;
        
    }
    return cellModel;
    
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    
    self.tableView.mj_footer.hidden = NO;
    self.lastHasMore = hasMore;
    if (hasMore == NO) {
        [self.refreshFooter setUpNoMoreDataText:@"没有更多信息了" offsetY:-3];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
}

-(void)processError:(NSError *)error {

    //add error toast
    if (error.code != NSURLErrorCancelled) {
        //不是主动取消
        if (!self.isRefresh) {
            
            [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
            [self showMaskView:NO];
            
        }else {
            if (![TTReachability isNetworkConnected]) {
                
                [self.maskView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkNotRefresh];
            }else {
                
                [self.maskView showEmptyWithType:FHEmptyMaskViewTypeNoData];
            }
        }
    }
    [self.tableView.mj_footer endRefreshing];
    
}


-(void)showMaskView:(BOOL)show
{
    self.maskView.hidden = !show;
    
}


#pragma mark - filter delegate

#pragma mark filter条件改变
-(void)onConditionChanged:(NSString *)condition
{
    NSString *allQuery = @"";
    if (self.getAllQueryString) {
        
        allQuery = self.getAllQueryString();
    }

//    if ([self.condition isEqualToString:allQuery]) {
//        return;
//    }
    self.condition = allQuery;
    [self.filterOpenUrlMdodel overwriteFliter:self.condition];

    self.isRefresh = YES;
    [self.tableView triggerPullDown];
    self.fromRecommend = NO;
    [self loadData:self.isRefresh];
    
}

#pragma mark filter将要显示
-(void)onConditionWillPanelDisplay
{
//    NSLog(@"onConditionWillPanelDisplay");

}

#pragma mark filter将要消失
-(void)onConditionPanelWillDisappear
{

}

#pragma mark - nav 点击事件
-(void)showInputSearch {
    if (self.closeConditionFilter) {
        self.closeConditionFilter();
    }
    [self addClickHouseSearchLog];
    
    NSDictionary *traceParam = [self.tracerModel toDictionary] ? : @{};
    //house_search
    NSHashTable *sugDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [sugDelegateTable addObject:self];
    NSDictionary *dict = @{@"house_type":@(self.houseType) ,
                           @"tracer": traceParam,
                           @"from_home":@(3), // list
                           @"sug_delegate":sugDelegateTable
                           };
    NSMutableDictionary *dictInfo = [NSMutableDictionary dictionaryWithDictionary:dict];
    if (self.listVC) {
        NSHashTable *tempTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        [tempTable addObject:self.listVC];
        dictInfo[@"need_back_vc"] = tempTable;
    }
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dictInfo];
    
    NSURL *url = [NSURL URLWithString:@"sslocal://house_search"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    
}

#pragma mark 地图找房
-(void)showMapSearch {
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
        NSMutableDictionary *param = [self categoryLogDict].mutableCopy;
        param[@"click_type"] = @"map";
        param[@"enter_type"] = @"click";
        TRACK_EVENT(@"click_switch_mapfind", param);
        
        NSMutableString *query = @"".mutableCopy;
        if (![self.mapFindHouseOpenUrl containsString:@"enter_category"]) {
            [query appendString:[NSString stringWithFormat:@"enter_category=%@",[self categoryName]]];

        }
        if (![self.mapFindHouseOpenUrl containsString:@"origin_from"]) {
            [query appendString:[NSString stringWithFormat:@"&origin_from=%@",self.tracerModel.originFrom ? : @"be_null"]];

        }
        if (![self.mapFindHouseOpenUrl containsString:@"origin_search_id"]) {
            [query appendString:[NSString stringWithFormat:@"&origin_search_id=%@",self.originSearchId ? : @"be_null"]];

        }
        if (![self.mapFindHouseOpenUrl containsString:@"enter_from"]) {
            [query appendString:[NSString stringWithFormat:@"&enter_from=%@",[self pageTypeString]]];
            
        }
        if (![self.mapFindHouseOpenUrl containsString:@"element_from"]) {
            [query appendString:[NSString stringWithFormat:@"&element_from=%@",self.tracerModel.elementFrom ? : @"be_null"]];
            
        }
        if (![self.mapFindHouseOpenUrl containsString:@"search_id"]) {
            [query appendString:[NSString stringWithFormat:@"&search_id=%@",self.searchId ? : @"be_null"]];
            
        }
        if (query.length > 0) {
            
            openUrl = [NSString stringWithFormat:@"%@&%@",openUrl,query];
        }
        
        //需要重置非过滤器条件，以及热词placeholder
        self.closeConditionFilter();

        NSURL *url = [NSURL URLWithString:openUrl];
        NSMutableDictionary *dict = @{}.mutableCopy;
        
        NSHashTable *hashMap = [[NSHashTable alloc]initWithOptions:NSPointerFunctionsWeakMemory capacity:1];
        [hashMap addObject:self];
        dict[OPENURL_CALLBAK] = hashMap;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }

}

-(void)refreshHouseListUrlCallback:(NSString *)openUrl {

    if (openUrl.length < 1) {
        return;
    }
    if (self.houseListOpenUrlUpdateBlock) {
        
        TTRouteParamObj *routeParamObj = [[TTRoute sharedRoute]routeParamObjWithURL:[NSURL URLWithString:openUrl]];
        self.houseListOpenUrlUpdateBlock(routeParamObj, NO);
    }
}

// findTab过来的houseSearch需要单独处理下埋点数据
-(void)updateHouseSearchDict:(NSDictionary *)houseSearchDic {

    self.houseSearchDic = houseSearchDic;
    self.canChangeHouseSearchDic = NO; // 禁止修改house_search埋点数据
}

#pragma mark - map url delegate
-(void)handleHouseListCallback:(NSString *)openUrl {
    
    if ([self.houseListOpenUrl isEqualToString:openUrl]) {
        return;
    }
    
    if (self.houseListOpenUrlUpdateBlock) {
        
        TTRouteParamObj *routeParamObj = [[TTRoute sharedRoute]routeParamObjWithURL:[NSURL URLWithString:openUrl]];
        self.houseListOpenUrlUpdateBlock(routeParamObj, YES);
    }
    
}

#pragma mark - sug delegate
-(void)suggestionSelected:(TTRouteObject *)routeObject {
    
    self.showRedirectTip = YES;
    NSMutableDictionary *allInfo = [routeObject.paramObj.userInfo.allInfo mutableCopy];
    if (allInfo[@"houseSearch"]) {
        self.houseSearchDic = allInfo[@"houseSearch"];
        self.canChangeHouseSearchDic = NO; // 禁止修改house_search埋点数据
    }
    
    NSString *houseTypeStr = routeObject.paramObj.allParams[@"house_type"];
    self.houseType = houseTypeStr.integerValue;
    
    if (self.sugSelectBlock) {
        self.sugSelectBlock(routeObject.paramObj);
    }
}

-(void)resetCondition {
    //    self.resetConditionBlock(nil);
}

-(void)backAction:(UIViewController *)controller {
    [controller.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sugesstHouseList.count > 0 ? 2 : 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.showPlaceHolder) {
        return 10;
    }
    return section == 0 ? self.houseList.count : self.sugesstHouseList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.showPlaceHolder) {
        if (indexPath.section == 1 && indexPath.row == 0 && [self.sugesstHouseList[0] isKindOfClass:[FHRecommendSecondhandHouseTitleModel class]]) {
            FHRecommendSecondhandHouseTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHHouseListRecommendTitleCellId];
            FHRecommendSecondhandHouseTitleModel *model = self.sugesstHouseList[0];

            [cell bindData:model];
            
            if (self.isShowSubscribeCell) {
                [cell hideSeprateLine:self.houseList.count > 1 ? NO : YES];
            }
            
            return cell;
        } else {
            if (indexPath.section == 0) {
                FHHouseBaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kBaseCellId];
                if (indexPath.row < self.houseList.count) {
                    
                    FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
                    if (cellModel.isSubscribCell) {
                        if ([cellModel.subscribModel isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
                            FHSugSubscribeDataDataSubscribeInfoModel *subscribModel = (FHSugSubscribeDataDataSubscribeInfoModel *)cellModel.subscribModel;
                            FHSuggestionSubscribCell *subScribCell = [tableView dequeueReusableCellWithIdentifier:kFHHouseListSubscribCellId];
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
                    
                    [cell refreshTopMargin: 20];
                    [cell updateWithHouseCellModel:cellModel];
                }
                return cell;
            } else {
                FHHouseBaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kBaseCellId];
                BOOL isFirstCell = (indexPath.row == 0);
                BOOL isLastCell = (indexPath.row == self.sugesstHouseList.count - 1);
                
                if (indexPath.row < self.sugesstHouseList.count) {
                    FHSingleImageInfoCellModel *cellModel = self.sugesstHouseList[indexPath.row];
                    [cell refreshTopMargin: 20];
                    [cell updateWithHouseCellModel:cellModel];
                }
                return cell;
            }
        }
    } else {
        FHPlaceHolderCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHHouseListPlaceholderCellId];
        return cell;
    }

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        if (indexPath.row < self.houseList.count) {
            
            FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
            if (cellModel.groupId.length > 0 && ![self.houseShowCache.allKeys containsObject:cellModel.groupId]) {
                
                [self addHouseShowLog:cellModel withRank:indexPath.row];
                self.houseShowCache[cellModel.groupId] = @"1";
            }
        }
    } else {
        if (indexPath.row > 0 && indexPath.row < self.sugesstHouseList.count) {
            FHSingleImageInfoCellModel *cellModel = self.sugesstHouseList[indexPath.row];
            if (cellModel.groupId.length > 0 && ![self.houseShowCache.allKeys containsObject:cellModel.groupId]) {
        
                [self addHouseShowLog:cellModel withRank:(indexPath.row - 1)];
                self.houseShowCache[cellModel.groupId] = @"1";
            }
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.showPlaceHolder) {
        if (indexPath.section == 1 && indexPath.row == 0 && [self.sugesstHouseList[0] isKindOfClass:[FHRecommendSecondhandHouseTitleModel class]]) {
            CGFloat height = 44.5;
            FHRecommendSecondhandHouseTitleModel *titleModel = self.sugesstHouseList[0];
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
            FHSingleImageInfoCellModel *cellModel  = nil;
            BOOL isLastCell = NO;
            
            if (indexPath.section == 0) {
            
                cellModel = self.houseList[indexPath.row];
                
                if (cellModel.isSubscribCell) {
                    if ([cellModel.subscribModel isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
                        return 121;
                    }
                }
                
                isLastCell = (indexPath.row == self.houseList.count - 1);
                
//                if (indexPath.row < self.houseList.count) {
//
//                    FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
//                    CGFloat height = [[tableView fd_indexPathHeightCache] heightForIndexPath:indexPath];
//                    if (height < 1) {
//                        height = [tableView fd_heightForCellWithIdentifier:kFHHouseListCellId cacheByIndexPath:indexPath configuration:^(FHSingleImageInfoCell *cell) {
//
//                            [cell updateWithHouseCellModel:cellModel];
//                            [cell refreshTopMargin: 20];
//                            [cell refreshBottomMargin:isLastCell ? 20 : 0];
//
//                        }];
//                    }
//                    return height;
//                }
            } else {
                isLastCell = (indexPath.row == self.sugesstHouseList.count - 1);
                cellModel = self.sugesstHouseList[indexPath.row];
            }
            
            CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHHouseBaseItemCell recommendReasonHeight] : 0;
            return (isLastCell ? 125 : 105)+reasonHeight;
        }
    }

    return 105;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row < self.houseList.count) {
            FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
            if (cellModel) {
                [self jump2HouseDetailPage:cellModel withRank:indexPath.row];
            }
        }
    } else {
        if (indexPath.row > 0 && indexPath.row < self.sugesstHouseList.count) {
            FHSingleImageInfoCellModel *cellModel = self.sugesstHouseList[indexPath.row];
            if (cellModel) {
                [self jump2HouseDetailPage:cellModel withRank:(indexPath.row - 1)];
            }
        }
    }
}

#pragma mark - 详情页跳转
-(void)jump2HouseDetailPage:(FHSingleImageInfoCellModel *)cellModel withRank: (NSInteger) rank  {
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[@"card_type"] = @"left_pic";
    if (cellModel.isRecommendCell) {
        traceParam[@"enter_from"] = [self pageTypeString];
        traceParam[@"element_from"] = @"search_related";
        traceParam[@"search_id"] = self.recommendSearchId;
    } else {
        traceParam[@"enter_from"] = [self pageTypeString];
        traceParam[@"element_from"] = [self elementTypeString];
        traceParam[@"search_id"] = self.searchId;
    }
    traceParam[@"log_pb"] = [cellModel logPb];
    traceParam[@"origin_from"] = self.originFrom;
    traceParam[@"origin_search_id"] = self.originSearchId;
    traceParam[@"rank"] = @(rank);
    NSDictionary *dict = @{@"house_type":@(self.houseType) ,
                           @"tracer": traceParam
                           };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSString *urlStr;

    id<FHHouseEnvContextBridge> contextBridge = [[FHHouseBridgeManager sharedInstance]envContextBridge];
    [contextBridge setTraceValue:self.originFrom forKey:@"origin_from"];
    [contextBridge setTraceValue:self.originSearchId forKey:@"origin_search_id"];

    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            if (cellModel.houseModel) {
                
                FHNewHouseItemModel *theModel = cellModel.houseModel;
                urlStr = [NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",theModel.houseId];
            }
            break;
        case FHHouseTypeSecondHandHouse:
            if (cellModel.secondModel) {
                
                FHSearchHouseDataItemsModel *theModel = cellModel.secondModel;
                urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",theModel.hid];
            }
            break;
        case FHHouseTypeRentHouse:
            if (cellModel.rentModel) {
                
                FHHouseRentDataItemsModel *theModel = cellModel.rentModel;
                urlStr = [NSString stringWithFormat:@"sslocal://rent_detail?house_id=%@",theModel.id];
            }
            break;
        case FHHouseTypeNeighborhood:
            if (cellModel.neighborModel) {
                
                FHHouseNeighborDataItemsModel *theModel = cellModel.neighborModel;
                urlStr = [NSString stringWithFormat:@"sslocal://neighborhood_detail?neighborhood_id=%@",theModel.id];
            }
            break;
        default:
            break;
    }
    
    if (urlStr.length > 0) {
        NSURL *url = [NSURL URLWithString:urlStr];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
    
}

#pragma mark - commute
-(void)showCommuteInView:(UIView *)view
{
    
}

#pragma mark - 埋点相关
-(NSMutableDictionary *)houseShowCache {
    
    if (!_houseShowCache) {
        _houseShowCache = [NSMutableDictionary dictionary];
    }
    return _houseShowCache;
}

-(NSString *)categoryName {
    
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

-(NSString *)houseTypeString {
    
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

-(NSString *)pageTypeString {
    
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

-(NSString *)pageTypeStringByFindTab {
    
    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            return @"findtab_new";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"findtab_old";
            break;
        case FHHouseTypeRentHouse:
            return @"findtab_rent";
            break;
        case FHHouseTypeNeighborhood:
            return @"findtab_neighborhood";
            break;
        default:
            return @"be_null";
            break;
    }
}

-(NSString *)elementTypeString {
    
    return @"be_null";

}

#pragma mark house_show log
-(void)addHouseShowLog:(FHSingleImageInfoCellModel *)cellModel withRank: (NSInteger) rank {
    if (!cellModel) {
        return;
    }
    
    NSString *originFrom = self.originFrom ? : @"be_null";
    
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"house_type"] = [self houseTypeString] ? : @"be_null";
    tracerDict[@"card_type"] = @"left_pic";
    if (cellModel.isRecommendCell) {
        tracerDict[@"page_type"] = [self pageTypeString];
        tracerDict[@"element_type"] = @"search_related";
        tracerDict[@"search_id"] = self.recommendSearchId ? : @"be_null";
    } else {
        tracerDict[@"page_type"] = [self pageTypeString];
        tracerDict[@"element_type"] = @"be_null";
        tracerDict[@"search_id"] = self.searchId ? : @"be_null";
    }
    tracerDict[@"group_id"] = [cellModel groupId] ? : @"be_null";
    tracerDict[@"impr_id"] = [cellModel imprId] ? : @"be_null";
    tracerDict[@"rank"] = @(rank);
    tracerDict[@"origin_from"] = originFrom;
    tracerDict[@"origin_search_id"] = self.originSearchId ? : @"be_null";
    tracerDict[@"log_pb"] = [cellModel logPb] ? : @"be_null";


    if (cellModel.isSubscribCell) {
        if ([cellModel.subscribModel isKindOfClass:[FHSugSubscribeDataDataSubscribeInfoModel class]]) {
            FHSugSubscribeDataDataSubscribeInfoModel *cellSubModel = (FHSugSubscribeDataDataSubscribeInfoModel *)cellModel.subscribModel;
            if ([cellSubModel.subscribeId isKindOfClass:[NSString class]] && [cellSubModel.subscribeId integerValue] != 0) {
                [tracerDict setValue:cellSubModel.subscribeId forKey:@"subscribe_id"];
            }else
            {
                [tracerDict setValue:@"be_null" forKey:@"subscribe_id"];
            }
            if (cellSubModel.title) {
                [tracerDict setValue:cellSubModel.title forKey:@"title"];
            }else
            {
                [tracerDict setValue:@"be_null" forKey:@"title"];
            }
            
            if (cellSubModel.text) {
                [tracerDict setValue:cellSubModel.text forKey:@"text"];
            }else
            {
                [tracerDict setValue:@"be_null" forKey:@"text"];
            }
        }
        [tracerDict removeObjectForKey:@"impr_id"];
        [tracerDict removeObjectForKey:@"group_id"];
        self.subScribeShowDict = tracerDict;
        [FHUserTracker writeEvent:@"subscribe_show" params:tracerDict];
    }else
    {
        [FHUserTracker writeEvent:@"house_show" params:tracerDict];
    }
}


#pragma mark category log
-(void)addEnterCategoryLog {

    [FHUserTracker writeEvent:@"enter_category" params:[self categoryLogDict]];
}

-(void)addCategoryRefreshLog {

    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"refresh_type"] = @"pre_load_more";
    [FHUserTracker writeEvent:@"category_refresh" params:tracerDict];
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

- (void)addClickHouseSearchLog {
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (self.fromFindTab) {
        
        params[@"page_type"] = [self pageTypeStringByFindTab];
    }else {
        
        params[@"page_type"] = [self pageTypeString];
    }
    params[@"origin_search_id"] = self.originSearchId.length > 0 ? self.originSearchId : @"be_null";
    params[@"hot_word"] = @"be_null";
    params[@"origin_from"] = self.originFrom.length > 0 ? self.originFrom : @"be_null";
    
    TRACK_EVENT(@"click_house_search",params);
}

- (void)addHouseSearchLog {
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
    // enter_query 判空
    NSString *enter_query = params[@"enter_query"];
    if (enter_query && [enter_query isKindOfClass:[NSString class]]) {
        if (enter_query.length <= 0) {
            params[@"enter_query"] = @"be_null";
        }
    } else {
         params[@"enter_query"] = @"be_null";
    }
    // search_query 判空
    NSString *search_query = params[@"search_query"];
    if (search_query && [search_query isKindOfClass:[NSString class]]) {
        if (search_query.length <= 0) {
            params[@"search_query"] = @"be_null";
        }
    } else {
         params[@"search_query"] = @"be_null";
    }
    TRACK_EVENT(@"house_search",params);
    self.canChangeHouseSearchDic = YES;
}

- (void)addHouseRankLog {
    
    NSString *sortType;
    if (self.getSortTypeString) {
        sortType = self.getSortTypeString();
    }
    if (sortType.length < 1) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"page_type"] = [self pageTypeString];
    params[@"rank_type"] = sortType;
    params[@"origin_search_id"] = self.originSearchId.length > 0 ? self.originSearchId : @"be_null";
    params[@"search_id"] =  self.searchId.length > 0 ? self.searchId : @"be_null";
    params[@"origin_from"] = self.originFrom.length > 0 ? self.originFrom : @"be_null";
    TRACK_EVENT(@"house_rank",params);
}

-(NSDictionary *)categoryLogDict {
    
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"category_name"] = [self categoryName] ? : @"be_null";
    tracerDict[@"enter_from"] = self.tracerModel.enterFrom ? : @"be_null";
    tracerDict[@"enter_type"] = self.tracerModel.enterType ? : @"be_null";
    tracerDict[@"element_from"] = self.tracerModel.elementFrom ? : @"be_null";
    tracerDict[@"search_id"] = self.searchId ? : @"be_null";
    tracerDict[@"origin_from"] = self.tracerModel.originFrom ? : @"be_null";
    tracerDict[@"origin_search_id"] = self.originSearchId ? : @"be_null";
    
    return tracerDict;
}

-(NSString *)stayPageEvent {
    
    return @"enter_category";
}

-(NSDictionary *)stayPageParams {
    
    return [self categoryLogDict];
}


@end
