//
//  FHHouseOldMainViewModel.m
//  Pods
//
//  Created by 张静 on 2019/3/4.
//

#import "FHHouseOldMainViewModel.h"
#import <MJRefresh.h>
#import "FHRefreshCustomFooter.h"
#import <TTNetworkManager/TTHttpTask.h>
#import "FHHouseListAPI.h"
#import <FHHouseBase/FHSearchHouseModel.h>
#import <FHHouseBase/FHSingleImageInfoCell.h>
#import <FHHouseBase/FHSingleImageInfoCellModel.h>
#import <FHHouseBase/FHPlaceHolderCell.h>
#import <TTReachability/TTReachability.h>
#import <FHHouseBase/FHMainManager+Toast.h>
#import <TTUIWidget/UIScrollView+Refresh.h>
#import <FHHouseBase/FHSearchFilterOpenUrlModel.h>
//#import "UITableView+FDTemplateLayoutCell.h"
#import <FHHouseBase/FHMapSearchOpenUrlDelegate.h>
#import <FHHouseBase/FHUserTracker.h>
#import <FHHouseBase/FHHouseBridgeManager.h>
#import "FHHouseListRedirectTipView.h"
#import <Masonry/Masonry.h>
#import <FHHouseBase/FHEnvContext.h>
#import <FHHouseBase/FHRecommendSecondhandHouseTitleCell.h>
#import <FHHouseBase/FHRecommendSecondhandHouseTitleModel.h>
#import <FHHouseBase/FHHouseBridgeManager.h>
#import "FHHouseListBannerView.h"
#import <FHCommonUI/UIView+House.h>
#import <FHHouseBase/FHHouseBaseItemCell.h>

#define kFHHouseOldMainCellId @"kFHHouseOldMainCellId"
#define kFHHouseOldMainRecommendTitleCellId @"kFHHouseOldMainRecommendTitleCellId"
#define kFHHouseOldMainPlaceholderCellId @"kFHHouseOldMainPlaceholderCellId"
#define HOUSE_ICON_HEADER_HEIGHT (60 * [UIScreen mainScreen].bounds.size.width / 375.0f)
#define HOUSE_TABLE_HEADER_HEIGHT floor(HOUSE_ICON_HEADER_HEIGHT + 19 * [UIScreen mainScreen].bounds.size.width / 375.0f) //414屏幕会出现小数 导致滑动出现问题
#define kFilterBarHeight 44

@interface FHHouseOldMainViewModel () <UITableViewDelegate, UITableViewDataSource, FHMapSearchOpenUrlDelegate>

@property(nonatomic , weak) FHErrorView *maskView;
@property (nonatomic , weak) FHHouseListRedirectTipView *redirectTipView;
@property(nonatomic , strong) UIView *iconHeaderView;
@property (nonatomic,strong) FHHouseListBannerView *iconsHeaderView;
@property (nonatomic , strong) FHConfigDataRentOpDataModel *houseOpDataModel;

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
@property(nonatomic , assign) CGFloat bottomLineMargin;

@end

@implementation FHHouseOldMainViewModel

-(void)setContainerScrollView:(UIScrollView *)containerScrollView
{
    _containerScrollView = containerScrollView;
    _containerScrollView.delegate = self;
}

-(UIView *)iconHeaderView
{
    return _iconHeaderView;
}

- (void)setMaskView:(FHErrorView *)maskView
{
    __weak typeof(self)wself = self;
    _maskView = maskView;
    _maskView.retryBlock = ^{
        
        [wself loadData:wself.isRefresh];
    };
}

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

- (void)updateRedirectTipInfo
{
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

- (void)closeRedirectTip
{
    self.showRedirectTip = NO;
    self.redirectTipView.hidden = YES;
    [self.redirectTipView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    NSDictionary *params = @{@"click_type":@"cancel",
                             @"enter_from":@"search"};
    [FHUserTracker writeEvent:@"city_click" params:params];
}

- (void)clickRedirectTip
{
    if (self.redirectTips.openUrl.length > 0) {
        
        [FHEnvContext sharedInstance].refreshConfigRequestType = @"switch_house";

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

- (instancetype)initWithTableView:(UITableView *)tableView routeParam:(TTRouteParamObj *)paramObj
{
    self = [super init];
    if (self) {
        
        _houseType = FHHouseTypeSecondHandHouse;
        _canChangeHouseSearchDic = YES;
        _bottomLineMargin = 20;
        self.houseList = [NSMutableArray array];
        self.sugesstHouseList = [NSMutableArray array];
        self.showPlaceHolder = YES;
        self.isRefresh = YES;
        self.isEnterCategory = YES;
        self.isFirstLoad = YES;
        self.tableView = tableView;
        self.showRedirectTip = YES;
        self.filterOpenUrlMdodel = [FHSearchFilterOpenUrlModel instanceFromUrl:[paramObj.sourceURL absoluteString]];
        
        [self setupBannerView];

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

- (void)setupBannerView
{
    FHConfigDataModel *dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    if (dataModel.houseOpData.items.count > 0) {
        NSMutableArray *items = @[].mutableCopy;
        _iconsHeaderView =  [[FHHouseListBannerView alloc] init];
        _iconsHeaderView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, HOUSE_TABLE_HEADER_HEIGHT);
        for (NSInteger index = 0; index < dataModel.houseOpData.items.count; index++) {
            FHConfigDataOpData2ItemsModel *obj = dataModel.houseOpData.items[index];
            FHHouseListBannerItem *item = [[FHHouseListBannerItem alloc]init];
            item.title = obj.title;
            item.subtitle = obj.descriptionStr;
            item.openUrl = obj.openUrl;
            FHConfigDataOpData2ItemsImageModel *imageModel = obj.image.firstObject;
            if (imageModel) {
                item.iconName = imageModel.url;
            }
            [items addObject:item];
            NSDictionary *logpbDict = obj.logPb;
            [self addOperationShowLog:logpbDict[@"operation_name"]];
        }
        [_iconsHeaderView addBannerItems:items];
        __weak typeof(self)wself = self;
        _iconsHeaderView.clickedItemCallBack = ^(NSInteger index) {
            if (index < wself.houseOpDataModel.items.count ) {

                FHConfigDataRentOpDataItemsModel *model = wself.houseOpDataModel.items[index];
                [wself quickJump:model];
                NSDictionary *logpbDict = model.logPb;
                [wself addOperationClickLog:logpbDict[@"operation_name"]];
            }
        };
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, HOUSE_TABLE_HEADER_HEIGHT)];
        header.backgroundColor  = [UIColor whiteColor];
        [header addSubview:_iconsHeaderView];
        
        self.iconHeaderView = header;
        self.houseOpDataModel = dataModel.houseOpData;
    }
}

#pragma mark - quick jump
- (void)quickJump:(FHConfigDataRentOpDataItemsModel *)model
{
    TTRouteParamObj *paramObj = [[TTRoute sharedRoute]routeParamObjWithURL:[NSURL URLWithString:model.openUrl]];
    NSMutableDictionary *queryP = [NSMutableDictionary new];
    [queryP addEntriesFromDictionary:paramObj.allParams];
    NSDictionary *baseParams = [self categoryLogDict];
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"enter_from"] = @"old_kind_list";
    NSDictionary *logpbDict = model.logPb;
    dict[@"element_from"] = logpbDict[@"element_from"] ? : @"be_null";
    dict[@"origin_from"] = logpbDict[@"origin_from"] ? : @"be_null";
    dict[@"log_pb"] = model.logPb ? : @"be_null";
    dict[@"search_id"] = baseParams[@"search_id"] ? : @"be_null";
    dict[@"origin_search_id"] = baseParams[@"origin_search_id"] ? : @"be_null";

    NSString *reportParams = [self getEvaluateWebParams:dict];
    NSString *jumpUrl = @"sslocal://webview";
    NSMutableString *urlS = [[NSMutableString alloc] init];
    [urlS appendString:queryP[@"url"]];
    [urlS appendFormat:@"&report_params=%@",reportParams];
    queryP[@"url"] = urlS;
    queryP[@"hide_nav_bottom_line"] = @(YES);
    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:queryP];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:jumpUrl] userInfo:info];
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
    [self.refreshFooter setUpNoMoreDataText:@"没有更多信息了"];
    self.tableView.mj_footer = self.refreshFooter;
    self.tableView.mj_footer.hidden = YES;
    
    [self.tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:kFHHouseOldMainCellId];
    [self.tableView registerClass:[FHRecommendSecondhandHouseTitleCell class] forCellReuseIdentifier:kFHHouseOldMainRecommendTitleCellId];
    [self.tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:kFHHouseOldMainPlaceholderCellId];
    
}


-(void)loadData:(BOOL)isRefresh
{
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
    if (isFromRecommend) {
        [self requestRecommendErshouHouseListData:isRefresh query:query offset:offset searchId:self.recommendSearchId];
    } else {
        [self requestErshouHouseListData:isRefresh query:query offset:offset searchId:searchId];
    }

}

- (void)requestErshouHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId
{
    [_requestTask cancel];
    
    __weak typeof(self) wself = self;
    
    TTHttpTask *task = [FHHouseListAPI searchErshouHouseList:query params:nil offset:offset searchId:searchId sugParam:nil class:[FHSearchHouseModel class] completion:^(FHSearchHouseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }
        wself.tableView.scrollEnabled = YES;
        [wself processData:model error:error];
    }];
    
    self.requestTask = task;
}

- (void)requestRecommendErshouHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId
{
    [_requestTask cancel];
    
    __weak typeof(self) wself = self;
    
    TTHttpTask *task = [FHHouseListAPI recommendErshouHouseList:query params:nil offset:offset searchId:searchId sugParam:nil class:[FHRecommendSecondhandHouseModel class] completion:^(FHRecommendSecondhandHouseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }
        wself.tableView.scrollEnabled = YES;
        [wself processData:model error:error];
    }];
    
    self.requestTask = task;
}



- (void)processData:(id<FHBaseModelProtocol>)model error: (NSError *)error
{
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
        NSArray *itemArray = @[];
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
            
            FHSingleImageInfoCellModel *cellModel = [[FHSingleImageInfoCellModel alloc]init];
            if ([obj isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
                
                FHSearchHouseDataItemsModel *item = (FHSearchHouseDataItemsModel *)obj;
                cellModel.secondModel = obj;
            }
            if (cellModel) {
                cellModel.isRecommendCell = NO;
                [self.houseList addObject:cellModel];
            }
            
        }];
        
        [recommendItemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            FHSingleImageInfoCellModel *cellModel = [[FHSingleImageInfoCellModel alloc]init];
            if ([obj isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
                
                FHSearchHouseDataItemsModel *item = (FHSearchHouseDataItemsModel *)obj;
                cellModel.secondModel = obj;
            }
            if (cellModel) {
                cellModel.isRecommendCell = YES;
                [self.sugesstHouseList addObject:cellModel];
            }
            
        }];
        
        [self.tableView reloadData];
        [self updateTableViewWithMoreData:hasMore];
        
        if (self.isRefresh && itemArray.count > 0 && self.showNotify) {
            self.showNotify(refreshTip);
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

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    
    self.tableView.mj_footer.hidden = NO;
    self.lastHasMore = hasMore;
    if (hasMore == NO) {
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
            self.tableView.scrollEnabled = NO;
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
- (void)onConditionChanged:(NSString *)condition
{
    NSString *allQuery = @"";
    if (self.getAllQueryString) {
        
        allQuery = self.getAllQueryString();
    }
    
    self.tableView.scrollEnabled = YES;

    self.condition = allQuery;
    [self.filterOpenUrlMdodel overwriteFliter:self.condition];
    
    self.isRefresh = YES;
    [self.tableView triggerPullDown];
    self.fromRecommend = NO;
    [self loadData:self.isRefresh];
    
}

- (void)updateBottomLineMargin:(CGFloat)margin
{
    if (margin == _bottomLineMargin) {
        return;
    }
    _bottomLineMargin = margin;
    [self.bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(margin);
        make.right.mas_equalTo(-margin);
    }];
}

#pragma mark filter将要显示
- (void)onConditionPanelWillDisplay
{
    if (self.houseOpDataModel.items.count > 0) {
        self.containerScrollView.contentOffset = CGPointMake(0, HOUSE_TABLE_HEADER_HEIGHT);
    }
    self.containerScrollView.scrollEnabled = NO;
    [self updateBottomLineMargin:0];
}

#pragma mark filter将要消失
- (void)onConditionPanelWillDisappear
{
    if (self.houseOpDataModel.items.count > 0) {
        self.containerScrollView.scrollEnabled = YES;
    }else {
        self.containerScrollView.scrollEnabled = NO;
    }
}

#pragma mark - nav 点击事件
- (void)showInputSearch {
    if (self.closeConditionFilter) {
        self.closeConditionFilter();
    }
    [self addClickHouseSearchLog];
    NSMutableDictionary *traceParam = [self categoryLogDict].mutableCopy;
    traceParam[@"element_from"] = [self elementTypeString];
    traceParam[@"page_type"] = [self pageTypeString];
    
    NSDictionary *dict = @{@"house_type":@(self.houseType) ,
                           @"tracer": traceParam,
                           @"from_home":@(5)// list
                           };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
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
            FHRecommendSecondhandHouseTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHHouseOldMainRecommendTitleCellId];
            FHRecommendSecondhandHouseTitleModel *model = self.sugesstHouseList[0];
            [cell bindData:model];
            return cell;
        } else {
            if (indexPath.section == 0) {
                FHHouseBaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHHouseOldMainCellId];
                BOOL isFirstCell = (indexPath.row == 0);
                BOOL isLastCell = (indexPath.row == self.houseList.count - 1);
                
                if (indexPath.row < self.houseList.count) {                    
                    FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
                    CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHHouseBaseItemCell recommendReasonHeight] : 0;
                    [cell refreshTopMargin: 20];
                    [cell updateWithHouseCellModel:cellModel];
                }
                return cell;
            } else {
                FHHouseBaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHHouseOldMainCellId];
                BOOL isFirstCell = (indexPath.row == 0);
                BOOL isLastCell = (indexPath.row == self.sugesstHouseList.count - 1);
                
                if (indexPath.row < self.sugesstHouseList.count) {
                    FHSingleImageInfoCellModel *cellModel = self.sugesstHouseList[indexPath.row];
                    CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHHouseBaseItemCell recommendReasonHeight] : 0;
                    [cell refreshTopMargin: 20];
                    [cell updateWithHouseCellModel:cellModel];
                }
                return cell;
            }
        }
    } else {
        FHPlaceHolderCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHHouseOldMainPlaceholderCellId];
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
            return height;
        } else {
            if (indexPath.section == 0) {
                BOOL isLastCell = (indexPath.row == self.houseList.count - 1);
                FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
                CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHHouseBaseItemCell recommendReasonHeight] : 0;
                return (isLastCell ? 125 : 105)+reasonHeight;
                //                if (indexPath.row < self.houseList.count) {
                //
                //                    FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
                //                    CGFloat height = [[tableView fd_indexPathHeightCache] heightForIndexPath:indexPath];
                //                    if (height < 1) {
                //                        height = [tableView fd_heightForCellWithIdentifier:kFHHouseListCellId cacheByIndexPath:indexPath configuration:^(FHHouseBaseItemCell *cell) {
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
                BOOL isLastCell = (indexPath.row == self.sugesstHouseList.count - 1);
                FHSingleImageInfoCellModel *cellModel = self.sugesstHouseList[indexPath.row];
                CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHHouseBaseItemCell recommendReasonHeight] : 0;
                return (isLastCell ? 125 : 105)+reasonHeight;
                
                //                if (indexPath.row < self.sugesstHouseList.count) {
                //
                //                    FHSingleImageInfoCellModel *cellModel = self.sugesstHouseList[indexPath.row];
                //                    CGFloat height = [[tableView fd_indexPathHeightCache] heightForIndexPath:indexPath];
                //                    if (height < 1) {
                //                        height = [tableView fd_heightForCellWithIdentifier:kFHHouseListCellId cacheByIndexPath:indexPath configuration:^(FHHouseBaseItemCell *cell) {
                //                            [cell updateWithHouseCellModel:cellModel];
                //                            [cell refreshTopMargin: 20];
                //                            [cell refreshBottomMargin:isLastCell ? 20 : 0];
                //                        }];
                //                    }
                //                    return height;
                //                }
            }
        }
    }
    
    return 105;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = self.tableView.contentOffset;
    CGPoint coffset = self.containerScrollView.contentOffset;
    [self.viewController.view endEditing:YES];
    
//    NSLog(@"scrollview scroll: %@  offset is: %f  coffset is: %f  draging: %@",scrollView == self.tableView?@"TableView":@"ContainerView",offset.y,coffset.y,scrollView.isDragging?@"YES":@"NO");
    
    CGFloat threshold = self.houseOpDataModel.items.count > 0 ? HOUSE_TABLE_HEADER_HEIGHT : 0;
    CGFloat realOffset = offset.y + self.tableView.contentInset.top;
//    NSLog(@"scrollview scroll: real offset is: %f\n\n",realOffset);
    
    if (scrollView == _containerScrollView) {
        
        if (coffset.y > threshold) {
            //向上滑动， 此时应滑动tableview
            if (self.tableView.scrollEnabled) {
                if (self.tableView.height + self.tableView.contentInset.bottom + self.tableView.contentInset.top > self.tableView.contentSize.height) {
                    //内容不满一屏幕
                    offset = CGPointMake(0, -self.tableView.contentInset.top);
                }else{
                    CGFloat delta = (offset.y + self.tableView.height + self.tableView.contentInset.bottom + self.tableView.contentInset.top - self.tableView.contentSize.height);
                    if (delta > 0) {
                        if (delta < 10) {
                            offset.y += (coffset.y - threshold);
                        }else{
                            offset.y += (coffset.y - threshold)*(10/delta);
                        }
                    }else{
                        offset.y += coffset.y - threshold;
                    }
//                    offset.y -= self.tableView.contentInset.top; // 注释掉避免refreshTip出现时上滑页面引起的死循环然后crash
                }
            }
            coffset.y = threshold;
            
            self.tableView.contentOffset = offset;
            self.containerScrollView.contentOffset = CGPointMake(0, threshold);
        }else if(coffset.y > 0 && realOffset > 0){
            //注释后，则在筛选器在顶部时不能向下滑动，只能等tableview滑动下来后才可以
            CGPoint location = [scrollView.panGestureRecognizer locationInView:scrollView];
            if (location.y > threshold + kFilterBarHeight+10) {
                //不在筛选栏滑动
                offset.y += (coffset.y-threshold - self.tableView.contentInset.top);
                self.tableView.contentOffset = offset;
            }
            if (self.tableView.scrollEnabled) {
                self.containerScrollView.contentOffset = CGPointMake(0, threshold);
            }
        }
        
        
    }else if (scrollView == self.tableView){
        
        UIEdgeInsets insets = self.tableView.contentInset;
        CGFloat realOffset = offset.y + insets.top;
        if (realOffset < 0) {
            
            if (coffset.y > -10) {
                coffset.y += realOffset;
            }else if (coffset.y > -20){
                coffset.y += realOffset * 0.3;
            }else {//if (coffset.y > -50)
                coffset.y += realOffset * 0.1;
            }
            
            if (coffset.y < -30) {
                coffset.y = -30;
            }
            
            if (self.houseOpDataModel.items.count > 0) {
                self.containerScrollView.contentOffset = coffset;
                self.tableView.contentOffset = CGPointMake(0, -insets.top);
            }else {
                self.tableView.contentOffset = CGPointMake(0, offset.y);
            }
        }else if (coffset.y < threshold){
            
            coffset.y += realOffset;
            if (coffset.y > threshold) {
                coffset.y = threshold;
            }
            self.tableView.contentOffset = CGPointMake(0, -insets.top);;
            if (self.houseOpDataModel.items.count > 0) {
                self.containerScrollView.contentOffset = coffset;
            }
        }
    }
    if (self.containerScrollView.contentOffset.y > HOUSE_TABLE_HEADER_HEIGHT) {
        [self updateBottomLineMargin:0];
    }else {
        [self updateBottomLineMargin:20];
    }
}

//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    if (scrollView == self.tableView && self.tableView.contentOffset.y + self.tableView.height - self.tableView.contentInset.bottom + 0.5 - self.tableView.contentSize.height > 0) {
//        [self checkScrollMoveEffect:scrollView animated:YES];
//    }
//}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self checkScrollMoveEffect:scrollView animated:YES];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self checkScrollMoveEffect:scrollView animated:NO];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        [self checkScrollMoveEffect:scrollView animated:YES];
    }
}

-(void)checkScrollMoveEffect:(UIScrollView *)scrollView animated:(BOOL)animated
{
//        NSLog(@"scrollview move %@ info is: %@",scrollView == self.tableView?@"tableview":@"containerview",scrollView);
    if (scrollView == self.tableView) {
        if (self.containerScrollView.contentOffset.y < 0) {
            if (animated) {
                [UIView animateWithDuration:0.1 animations:^{
                    self.containerScrollView.contentOffset = CGPointZero;
                }];
            }else{
                [self.containerScrollView setContentOffset:CGPointZero animated:NO];
            }
        }else if(self.containerScrollView.contentOffset.y + self.containerScrollView.height > self.containerScrollView.contentSize.height){
            self.containerScrollView.contentOffset = CGPointMake(0, self.containerScrollView.contentSize.height - self.containerScrollView.height);
        }
        if ([self tableViewDragUpToLimit]) {
            //滑动到底部
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height + self.tableView.contentInset.bottom - self.tableView.height - 0.5) animated:YES];
        }
        
    }else if (scrollView == self.containerScrollView && self.tableView.scrollEnabled){
        if (self.tableView.height + self.tableView.contentInset.bottom + self.tableView.contentInset.top > self.tableView.contentSize.height) {
            //内容不满一屏幕
            self.tableView.contentOffset = CGPointMake(0, -self.tableView.contentInset.top);;
        }else{
            if (self.tableView.contentOffset.y + self.tableView.contentInset.top < 0) {
                self.tableView.contentOffset = CGPointMake(0, -self.tableView.contentInset.top);
            }else if (self.tableView.contentOffset.y + self.tableView.height  > self.tableView.contentSize.height + self.tableView.contentInset.bottom){
                self.tableView.contentOffset = CGPointMake(0, self.tableView.contentSize.height + self.tableView.contentInset.bottom - self.tableView.height - self.tableView.contentInset.top -0.5 );
            }
        }
    }
    
}

-(BOOL)tableViewDragUpToLimit
{
    return self.tableView.contentOffset.y + self.tableView.height - self.tableView.contentInset.bottom + 0.5 - self.tableView.contentSize.height > 0;
}


-(CGFloat)headerBottomOffset
{
    return MAX(CGRectGetHeight(self.tableView.tableHeaderView.frame) - self.tableView.contentOffset.y,0) + kFilterBarHeight;
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
    if (cellModel.secondModel) {
        
        FHSearchHouseDataItemsModel *theModel = cellModel.secondModel;
        urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",theModel.hid];
    }
    
    if (urlStr.length > 0) {
        NSURL *url = [NSURL URLWithString:urlStr];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
    
}

#pragma mark - 埋点相关
-(NSMutableDictionary *)houseShowCache
{
    if (!_houseShowCache) {
        _houseShowCache = [NSMutableDictionary dictionary];
    }
    return _houseShowCache;
}

-(NSString *)categoryName
{
    return @"old_kind_list";
}

-(NSString *)houseTypeString
{
    return @"old";
}

-(NSString *)pageTypeString
{
    return @"old_kind_list";
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
    
    [FHUserTracker writeEvent:@"house_show" params:tracerDict];
    
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
    params[@"page_type"] = [self pageTypeString];
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



@end
