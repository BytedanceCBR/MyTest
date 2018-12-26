//
//  FHHouseListViewModel.m
//  FHHouseList
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHHouseListViewModel.h"
#import <MJRefresh.h>
#import "NIHRefreshCustomFooter.h"
#import "TTHttpTask.h"
#import "FHHouseListAPI.h"
#import "FHSearchHouseModel.h"
#import "FHHouseNeighborModel.h"
#import "FHHouseRentModel.h"
#import "FHNewHouseItemModel.h"

#import "FHSingleImageInfoCell.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHPlaceHolderCell.h"
#import "FHHouseListViewController.h"
#import "TTReachability.h"
#import "FHMainManager+Toast.h"
#import <UIScrollView+Refresh.h>
#import "FHSearchFilterOpenUrlModel.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "FHMapSearchOpenUrlDelegate.h"

@interface FHHouseListViewModel () <UITableViewDelegate, UITableViewDataSource, FHMapSearchOpenUrlDelegate, FHHouseSuggestionDelegate>

@property(nonatomic , strong) FHErrorView *maskView;
@property(nonatomic , strong) UILabel *majorTitle;

@property(nonatomic, weak) FHHouseListViewController *listVC;
@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic , strong) NSMutableArray *houseList;
@property(nonatomic , strong) NIHRefreshCustomFooter *refreshFooter;
@property(nonatomic , weak) TTHttpTask * requestTask;
@property (nonatomic , copy) NSString *searchId;
@property(nonatomic , strong) FHSearchFilterOpenUrlModel *filterOpenUrlMdodel;

@property(nonatomic , assign) BOOL showPlaceHolder;
@property(nonatomic , assign) BOOL lastHasMore;

@property (nonatomic , assign) BOOL isRefresh;
@property (nonatomic , copy) NSString *query;
@property (nonatomic , copy) NSString *condition;

@property (nonatomic, copy) NSString *mapFindHouseOpenUrl;
@end


@implementation FHHouseListViewModel

-(void)setMaskView:(FHErrorView *)maskView {
    
    __weak typeof(self)wself = self;
    _maskView = maskView;
    _maskView.retryBlock = ^{
        
        [wself loadData:wself.isRefresh];
    };
}

-(instancetype)initWithTableView:(UITableView *)tableView viewControler:(FHHouseListViewController *)vc routeParam:(TTRouteParamObj *)paramObj {

    self = [super init];
    if (self) {

        _listVC = vc;
        self.houseList = [NSMutableArray array];
        self.showPlaceHolder = YES;
        self.isRefresh = YES;
        self.tableView = tableView;
        self.filterOpenUrlMdodel = [FHSearchFilterOpenUrlModel instanceFromUrl:[paramObj.sourceURL absoluteString]];
        
        NSString *houseTypeStr = paramObj.allParams[@"house_type"];
        self.houseType = houseTypeStr.length > 0 ? houseTypeStr.integerValue : FHHouseTypeSecondHandHouse;
        
        [self configTableView];
        
        // add by zjing for test
        
        self.condition = [self.filterOpenUrlMdodel query];

    }
    return self;
}

-(void)configTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    __weak typeof(self)wself = self;
    self.refreshFooter = [NIHRefreshCustomFooter footerWithRefreshingBlock:^{
        wself.isRefresh = NO;
        [wself loadData:wself.isRefresh];
    }];
    self.tableView.mj_footer = self.refreshFooter;
    
    [self.tableView registerClass:[FHSingleImageInfoCell class] forCellReuseIdentifier:kFHHouseListCellId];
    [self.tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:kFHHouseListPlaceholderCellId];

}

#pragma mark - 网络请求
-(void)loadData:(BOOL)isRefresh
{

//    NSString *query = [_filterOpenUrlMdodel query];
    
    NSString *query = self.condition;

    NSInteger offset = 0;

    NSMutableDictionary *param = [NSMutableDictionary new];

    NSString *searchId = self.searchId;

    // add by zjing for test
    NSLog(@"zjing query: %@, search id: %@",query, searchId);
    
    if (isRefresh) {
        
        self.tableView.mj_footer.hidden = YES;
        [self.houseList removeAllObjects];
    }else {
        offset = self.houseList.count;
    }
    
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
    
    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            
            [self requestNewHouseListData:isRefresh query:query offset:offset searchId:searchId];
            break;
        case FHHouseTypeSecondHandHouse:
            
            [self requestErshouHouseListData:isRefresh query:query offset:offset searchId:searchId];
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
        FHNewHouseListDataModel *houseModel = model.data;
        if (error) {
            //add error toast
            if (error.code != NSURLErrorCancelled) {
                //不是主动取消
                if (!isRefresh) {
                    
                    [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
                    [wself showMaskView:NO];
                    
                }else {
                    if (![TTReachability isNetworkConnected]) {
                        
                        [wself.maskView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkNotRefresh];
                    }else {
                        
                        [wself.maskView showEmptyWithType:FHEmptyMaskViewTypeNoData];
                    }
                }
            }
            [wself.tableView.mj_footer endRefreshing];
            return;
        }
        
        if (isRefresh) {
            [wself.houseList removeAllObjects];
            [wself.tableView.mj_footer endRefreshing];
        }
        if (houseModel) {
            
            wself.searchId = houseModel.searchId;
            wself.showPlaceHolder = NO;
            if (isRefresh) {
                [wself handleHouseListCallback:houseModel.houseListOpenUrl];
            }
            wself.houseListOpenUrl = houseModel.houseListOpenUrl;
            [houseModel.items enumerateObjectsUsingBlock:^(FHNewHouseItemModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                FHSingleImageInfoCellModel *cellModel = [[FHSingleImageInfoCellModel alloc]init];
                cellModel.houseModel = obj;
                [wself.houseList addObject:cellModel];
            }];

            [wself.tableView reloadData];
            [wself updateTableViewWithMoreData:houseModel.hasMore];
            
            if (isRefresh && wself.viewModelDelegate) {
                [wself.viewModelDelegate showNotify:houseModel.refreshTip inViewModel:wself];
            }
            
            if (wself.houseList.count == 0) {
                [wself.maskView showEmptyWithType:FHEmptyMaskViewTypeNoDataForCondition];
                
            }else{
                [wself showMaskView:NO];
            }
        }else {
            
            [wself.maskView showEmptyWithType:FHEmptyMaskViewTypeNoData];
        }
        
        if (isRefresh && wself.houseList.count > 0) {
            [wself.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        
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
        wself.showPlaceHolder = NO;
        FHHouseNeighborDataModel *houseModel = model.data;
        if (error) {
            //add error toast
            if (error.code != NSURLErrorCancelled) {
                //不是主动取消
                if (!isRefresh) {
                    
                    [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
                    [wself showMaskView:NO];
                    
                }else {
                    if (![TTReachability isNetworkConnected]) {
                        
                        [wself.maskView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkNotRefresh];
                    }else {
                        
                        [wself.maskView showEmptyWithType:FHEmptyMaskViewTypeNoData];
                    }
                }
            }
            [wself.tableView.mj_footer endRefreshing];
            return;
        }
        
        if (isRefresh) {
            [wself.houseList removeAllObjects];
            [wself.tableView.mj_footer endRefreshing];
        }
        if (houseModel) {
            
            wself.searchId = houseModel.searchId;
            wself.showPlaceHolder = NO;
            if (isRefresh) {
                [wself handleHouseListCallback:houseModel.houseListOpenUrl];
            }
            wself.houseListOpenUrl = houseModel.houseListOpenUrl;
            [houseModel.items enumerateObjectsUsingBlock:^(FHHouseNeighborDataItemsModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                FHSingleImageInfoCellModel *cellModel = [[FHSingleImageInfoCellModel alloc]init];
                cellModel.neighborModel = obj;
                [wself.houseList addObject:cellModel];
            }];
            [wself.tableView reloadData];
            [wself updateTableViewWithMoreData:houseModel.hasMore];
            
            if (isRefresh && wself.viewModelDelegate) {
                [wself.viewModelDelegate showNotify:houseModel.refreshTip inViewModel:wself];
            }
            
            if (wself.houseList.count == 0) {
                [wself.maskView showEmptyWithType:FHEmptyMaskViewTypeNoDataForCondition];
                
            }else{
                [wself showMaskView:NO];
            }
        }else {
            
            [wself.maskView showEmptyWithType:FHEmptyMaskViewTypeNoData];
        }
        
        if (isRefresh && wself.houseList.count > 0) {
            [wself.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        
    }];
    
    self.requestTask = task;
}


-(void)requestRentHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [_requestTask cancel];
    
    __weak typeof(self) wself = self;
    
    TTHttpTask *task = [FHHouseListAPI searchErshouHouseList:query params:nil offset:offset searchId:searchId sugParam:nil class:[FHHouseRentModel class] completion:^(FHHouseRentModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }
        FHHouseRentDataModel *houseModel = model.data;
        if (error) {
            //add error toast
            if (error.code != NSURLErrorCancelled) {
                //不是主动取消
                if (!isRefresh) {
                    
                    [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
                    [wself showMaskView:NO];
                    
                }else {
                    if (![TTReachability isNetworkConnected]) {
                        
                        [wself.maskView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkNotRefresh];
                    }else {
                        
                        [wself.maskView showEmptyWithType:FHEmptyMaskViewTypeNoData];
                    }
                }
            }
            [wself.tableView.mj_footer endRefreshing];
            return;
        }
        
        if (isRefresh) {
            [wself.houseList removeAllObjects];
            [wself.tableView.mj_footer endRefreshing];
        }
        if (houseModel) {
            
            wself.searchId = houseModel.searchId;
            self.showPlaceHolder = NO;
            wself.mapFindHouseOpenUrl = houseModel.mapFindHouseOpenUrl;
            if (isRefresh) {
                [wself handleHouseListCallback:houseModel.houseListOpenUrl];
            }
            wself.houseListOpenUrl = houseModel.houseListOpenUrl;
            [houseModel.items enumerateObjectsUsingBlock:^(FHHouseRentDataItemsModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                FHSingleImageInfoCellModel *cellModel = [[FHSingleImageInfoCellModel alloc]init];
                cellModel.rentModel = obj;
                [wself.houseList addObject:cellModel];
            }];
            [wself.tableView reloadData];
            [wself updateTableViewWithMoreData:houseModel.hasMore];
            
            if (isRefresh && wself.viewModelDelegate) {
                [wself.viewModelDelegate showNotify:houseModel.refreshTip inViewModel:wself];
            }
            
            if (wself.houseList.count == 0) {
                [wself.maskView showEmptyWithType:FHEmptyMaskViewTypeNoDataForCondition];
                
            }else{
                [wself showMaskView:NO];
            }
        }else {
            
            [wself.maskView showEmptyWithType:FHEmptyMaskViewTypeNoData];
        }
        
        
        if (isRefresh && wself.houseList.count > 0) {
            [wself.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        
    }];
    
    self.requestTask = task;
}


-(void)requestErshouHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [_requestTask cancel];
    
    __weak typeof(self) wself = self;
    
    TTHttpTask *task = [FHHouseListAPI searchErshouHouseList:query params:nil offset:offset searchId:searchId sugParam:nil class:[FHSearchHouseModel class] completion:^(FHSearchHouseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (!wself) {
            return ;
        }
        FHSearchHouseDataModel *houseModel = model.data;
        if (error) {
            //add error toast
            if (error.code != NSURLErrorCancelled) {
                //不是主动取消
                if (!isRefresh) {
                    
                    [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
                    [wself showMaskView:NO];
                    
                }else {
                    if (![TTReachability isNetworkConnected]) {
                        
                        [wself.maskView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkNotRefresh];
                    }else {
                        
                        [wself.maskView showEmptyWithType:FHEmptyMaskViewTypeNoData];
                    }
                }
            }
            [wself.tableView.mj_footer endRefreshing];
            return;
        }
        
        if (isRefresh) {
            [wself.houseList removeAllObjects];
            [wself.tableView.mj_footer endRefreshing];
        }
        if (houseModel) {
            
            wself.searchId = houseModel.searchId;
            wself.showPlaceHolder = NO;
            wself.mapFindHouseOpenUrl = houseModel.mapFindHouseOpenUrl;
            if (isRefresh) {
                [wself handleHouseListCallback:houseModel.houseListOpenUrl];
            }
            wself.houseListOpenUrl = houseModel.houseListOpenUrl;

            [houseModel.items enumerateObjectsUsingBlock:^(FHSearchHouseDataItemsModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                FHSingleImageInfoCellModel *cellModel = [[FHSingleImageInfoCellModel alloc]init];
                cellModel.secondModel = obj;
                [wself.houseList addObject:cellModel];
            }];
            [wself.tableView reloadData];
            [wself updateTableViewWithMoreData:houseModel.hasMore];
            
            if (isRefresh && wself.viewModelDelegate) {
                [wself.viewModelDelegate showNotify:houseModel.refreshTip inViewModel:wself];
            }
            
            if (wself.houseList.count == 0) {
                [wself.maskView showEmptyWithType:FHEmptyMaskViewTypeNoDataForCondition];

            }else{
                [wself showMaskView:NO];
            }
        }else {
            
            [wself.maskView showEmptyWithType:FHEmptyMaskViewTypeNoData];
        }

        self.showPlaceHolder = NO;

        if (isRefresh && wself.houseList.count > 0) {
            [wself.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        
    }];
    
    self.requestTask = task;
}

-(CGSize)titleSizeByTitle:(NSString *)title isShowTags:(BOOL)isShowTags {
    
    self.majorTitle.text = title;
    self.majorTitle.numberOfLines = isShowTags ? 1 : 2;
    CGSize fitSize = [self.majorTitle sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width * ([UIScreen mainScreen].bounds.size.width > 376 ? 0.61 : [UIScreen mainScreen].bounds.size.width > 321 ? 0.56 : 0.48), 0)];
    
    return fitSize;
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

-(void)showMaskView:(BOOL)show
{
    self.maskView.hidden = !show;
    
}


#pragma mark - filter delegate

#pragma mark filter条件改变
-(void)onConditionChanged:(NSString *)condition
{
    NSLog(@"zjing - onConditionChanged condition-%@",condition);
    
    NSString *allQuery = @"";
    if (self.getAllQueryString) {
        
        allQuery = self.getAllQueryString();
    }

    if ([self.condition isEqualToString:allQuery]) {
        return;
    }
    self.condition = allQuery;
    [self.filterOpenUrlMdodel overwriteFliter:self.condition];

    self.showPlaceHolder = NO;
    self.isRefresh = YES;
    [self.tableView triggerPullDown];
    [self loadData:YES];
    
}

#pragma mark filter将要显示
-(void)onConditionWillPanelDisplay
{
    NSLog(@"onConditionWillPanelDisplay");

}

#pragma mark filter将要消失
-(void)onConditionPanelWillDisappear
{

}

#pragma mark - nav 点击事件
-(void)showInputSearch {
    
    // FIXME: by zjing log
    //    [self addClickSearchLog];
    if (self.closeConditionFilter) {
        self.closeConditionFilter();
    }
    
//    SETTRACERKV(UT_ORIGIN_FROM,@"renting_search");
    
//    id<FHHouseEnvContextBridge> envBridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
    //    [envBridge setTraceValue:@"renting_search" forKey:@"origin_from"];
    
    NSMutableDictionary *traceParam = [self baseLogParam];
    //    traceParam[@"element_from"] = @"renting_search";
    //    traceParam[@"page_type"] = @"renting";
    
    //sug_list
    NSHashTable *sugDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [sugDelegateTable addObject:self];
    NSDictionary *dict = @{@"house_type":@(self.houseType) ,
                           @"tracer": traceParam,
                           @"from_home":@(3), // list
                           @"sug_delegate":sugDelegateTable
                           };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL *url = [NSURL URLWithString:@"sslocal://sug_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    
}

#pragma mark 地图找房
-(void)showMapSearch {
    
    if (self.mapFindHouseOpenUrl.length > 0) {
        // FIXME: zjing log
//        recordEvent(key: TraceEventName.click_switch_mapfind, params: params)
//        var query = ""
//        if  !openUrl.contains("enter_category") {
//            query = "enter_category=\(catName)"
//        }
//        if !openUrl.contains("origin_from") {
//            query = "\(query)&origin_from=\(originFrom)"
//        }
//
//        if !openUrl.contains("origin_search_id") {
//            query = "\(query)&origin_search_id=\(originSearchId)"
//        }
//        if !openUrl.contains("enter_from"){
//            query = "\(query)&enter_from=\(catName)"
//        }
//        if !openUrl.contains("element_from"){
//            query = "\(query)&element_from=\(elementName)"
//        }
//        if !openUrl.contains("search_id"){
//            query = "\(query)&search_id=\(categoryListViewModel?.originSearchId ?? "be_null")"
//        }
//
//
//        if query.count > 0 {
//            openUrl = "\(openUrl)&\(query)"
//        }
        
        //需要重置非过滤器条件，以及热词placeholder
        self.closeConditionFilter();

        NSURL *url = [NSURL URLWithString:self.mapFindHouseOpenUrl];
        NSMutableDictionary *dict = @{}.mutableCopy;
        
        NSHashTable *hashMap = [[NSHashTable alloc]initWithOptions:NSPointerFunctionsWeakMemory capacity:1];
        [hashMap addObject:self];
        dict[OPENURL_CALLBAK] = hashMap;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }

}

#pragma mark - map url delegate
-(void)handleHouseListCallback:(NSString *)openUrl {
    
    if ([self.houseListOpenUrl isEqualToString:openUrl]) {
        return;
    }
    
    if (self.houseListOpenUrlUpdateBlock) {
        
        TTRouteParamObj *routeParamObj = [[TTRoute sharedRoute]routeParamObjWithURL:[NSURL URLWithString:openUrl]];
        self.houseListOpenUrlUpdateBlock(routeParamObj);
    }
    
}

#pragma mark - sug delegate
-(void)suggestionSelected:(TTRouteObject *)routeObject {
    // FIXME: by zjing log
    //JUMP to cat list page
    [self.listVC.navigationController popViewControllerAnimated:YES];
    
    NSMutableDictionary *allInfo = [routeObject.paramObj.userInfo.allInfo mutableCopy];
    NSMutableDictionary *tracerDict = [self baseLogParam];
    [tracerDict addEntriesFromDictionary:allInfo[@"houseSearch"]];
    //    tracerDict[@"category_name"] = @"rent_list";
    //    tracerDict[UT_ELEMENT_FROM] = @"renting_search";
    //    tracerDict[@"page_type"] = @"renting";
    
    NSMutableDictionary *houseSearchDict = [[NSMutableDictionary alloc] initWithDictionary:allInfo[@"houseSearch"]];
    //    houseSearchDict[@"page_type"] = @"renting";
    allInfo[@"houseSearch"] = houseSearchDict;
    allInfo[@"tracer"] = tracerDict;
    
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
    //    [param addEntriesFromDictionary:[self.viewController.tracerModel logDict]];
//    [param addEntriesFromDictionary:houseParams];
    
    //    param[@"search_id"] = self.searchId ?: @"be_null";
    param[@"enter_from"] = @"old";
    
    return param;
}


#pragma mark - UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return !self.showPlaceHolder ? self.houseList.count : 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.showPlaceHolder) {

        FHSingleImageInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHHouseListCellId];
        BOOL isFirstCell = (indexPath.row == 0);
        BOOL isLastCell = (indexPath.row == self.houseList.count - 1);
//        NSLog(@"zjing - islast %ld,indexPath %@",isLastCell,indexPath);
        if (indexPath.row < self.houseList.count) {
            
            FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
            [cell updateWithHouseCellModel:cellModel];
            [cell refreshTopMargin: 20];
            [cell refreshBottomMargin:isLastCell ? 20 : 0];
        }
        return cell;
        
    }else {
        
        FHPlaceHolderCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHHouseListPlaceholderCellId];
        return cell;

    }

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self addHouseShowLog:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.showPlaceHolder) {

        BOOL isLastCell = (indexPath.row == self.houseList.count - 1);
        if (indexPath.row < self.houseList.count) {

            FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
            CGFloat height = [[tableView fd_indexPathHeightCache] heightForIndexPath:indexPath];
            if (height < 1) {
                
                height = [tableView fd_heightForCellWithIdentifier:kFHHouseListCellId cacheByIndexPath:indexPath configuration:^(FHSingleImageInfoCell *cell) {
                    
                    [cell updateWithHouseCellModel:cellModel];
                    [cell refreshTopMargin: 20];
                    [cell refreshBottomMargin:isLastCell ? 20 : 0];
                    
                }];
            }
            
            return height;
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

    if (indexPath.row < self.houseList.count) {
        
        id model = self.houseList[indexPath.row];
        
        if (indexPath.row < self.houseList.count) {
            
            switch (self.houseType) {
                case FHHouseTypeNewHouse:
                    [self jump2NewDetailPage:indexPath];
                    break;
                case FHHouseTypeSecondHandHouse:
                    [self jump2OldDetailPage:indexPath];
                    break;
                case FHHouseTypeRentHouse:
                    [self jump2RentDetailPage:indexPath];
                    break;
                case FHHouseTypeNeighborhood:
                    [self jump2NeighborDetailPage:indexPath];
                    break;
                default:
                    break;
            }
        }
        
    }
}

#pragma mark - 详情页跳转
-(void)jump2NewDetailPage:(NSIndexPath *)indexPath {
    
    FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
    if (cellModel.houseModel) {
        
    }
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    FHNewHouseItemModel *theModel = cellModel.houseModel;
    NSDictionary *dict = @{@"house_type":@(self.houseType) ,
                           @"tracer": traceParam
                           };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",theModel.houseId]];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    
}

-(void)jump2OldDetailPage:(NSIndexPath *)indexPath {
    
    FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
    if (cellModel.secondModel) {
        
        FHSearchHouseDataItemsModel *theModel = cellModel.secondModel;
        NSMutableDictionary *traceParam = @{}.mutableCopy;
        NSDictionary *dict = @{@"house_type":@(self.houseType) ,
                               @"tracer": traceParam
                               };
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",theModel.hid]];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }

}

-(void)jump2RentDetailPage:(NSIndexPath *)indexPath {
    
    FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
    if (cellModel.rentModel) {
        
        FHHouseRentDataItemsModel *theModel = cellModel.rentModel;
        NSMutableDictionary *traceParam = @{}.mutableCopy;
        NSDictionary *dict = @{@"house_type":@(self.houseType) ,
                               @"tracer": traceParam
                               };
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://rent_detail?house_id=%@",theModel.id]];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }

}

-(void)jump2NeighborDetailPage:(NSIndexPath *)indexPath {
    
    FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
    if (cellModel.neighborModel) {
        
        FHHouseNeighborDataItemsModel *theModel = cellModel.neighborModel;
        NSMutableDictionary *traceParam = @{}.mutableCopy;
        NSDictionary *dict = @{@"house_type":@(self.houseType) ,
                               @"tracer": traceParam
                               };
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://neighborhood_detail?neighborhood_id=%@",theModel.id]];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }

}

-(UILabel *)majorTitle {
    
    if (!_majorTitle) {
        
        _majorTitle = [[UILabel alloc]init];
        _majorTitle.font = [UIFont themeFontRegular:16];
        _majorTitle.textColor = [UIColor themeBlack];
    }
    return _majorTitle;
}


@end
