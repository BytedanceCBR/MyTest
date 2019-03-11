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
#import <TTUIWidget/UIViewController+Track.h>
#import <TTBaseLib/UIViewAdditions.h>
#import "FHMainListTopView.h"


#import <FHHouseRent/FHHouseRentFilterType.h>
#import <FHHouseRent/FHHouseRentCell.h>
#import <BDWebImage/BDWebImage.h>

#define kPlaceCellId @"placeholder_cell_id"
#define kFilterBarHeight 44
#define MAX_ICON_COUNT 4
#define ICON_HEADER_HEIGHT 109


@interface FHBaseMainListViewModel ()<UITableViewDelegate,UITableViewDataSource,FHConditionFilterViewModelDelegate>

@property(nonatomic , strong) UITableView *tableView;
@property(nonatomic , assign) FHHouseType houseType;
@property (nonatomic , strong) FHConfigDataRentOpDataModel *rentModel;
@property(nonatomic , strong) NSMutableArray *houseList;
@property(nonatomic , strong) NSString *searchId;
@property(nonatomic , strong) FHSearchFilterOpenUrlModel *filterOpenUrlMdodel;
@property(nonatomic , strong) FHHouseRentDataModel *currentRentDataModel;
@property(nonatomic , copy)  NSString *conditionFilter;
@property(nonatomic , strong) NSString *suggestion;
@property(nonatomic , strong) NSDictionary *houseSearchDict;
@property(nonatomic , assign) BOOL showPlaceHolder;
@property(nonatomic , strong) UIImage *placeHolderImage;
@property(nonatomic , copy  ) NSString *mapFindHouseOpenUrl;
@property(nonatomic , weak) TTHttpTask *requestTask;

@property (nonatomic , strong) FHConditionFilterViewModel *houseFilterViewModel;
@property (nonatomic , strong) id<FHHouseFilterBridge> houseFilterBridge;

@property(nonatomic , strong) NSMutableDictionary *showHouseDict;
@property(nonatomic , strong) NSMutableDictionary *stayTraceDict;
@property(nonatomic , assign) CGFloat headerHeight;

@property(nonatomic , copy) NSString *originSearchId;
@property(nonatomic , copy) NSString *originFrom;
@property(nonatomic , assign) BOOL isFirstLoad;

@end

@implementation FHBaseMainListViewModel

-(instancetype)initWithTableView:(UITableView *)tableView houseType:(FHHouseType)houseType  routeParam:(TTRouteParamObj *)paramObj
{
    self = [super init];
    if (self) {
        
        _houseList = [NSMutableArray new];
        
        self.tableView = tableView;
        self.houseType = houseType;
        [self initFilter];
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        [_tableView registerClass:[FHHouseRentCell class] forCellReuseIdentifier:@"item"];
        [_tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:kPlaceCellId];
        
        __weak typeof(self) wself = self;
        FHRefreshCustomFooter *footer = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
            [wself requestData:NO];
        }];
        _tableView.mj_footer = footer;
        [footer setUpNoMoreDataText:@"没有更多信息了"];
        footer.hidden = YES;
        
        self.filterOpenUrlMdodel = [FHSearchFilterOpenUrlModel instanceFromUrl:[paramObj.sourceURL absoluteString]];
        
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
        
        [_errorMaskView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.tableView.contentInset.top + self.tableView.contentOffset.y);
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
    self.requestTask =  [FHMainApi searchRent:query params:nil offset:offset searchId:self.currentRentDataModel.searchId sugParam:nil completion:^(FHHouseRentModel * _Nonnull model, NSError * _Nonnull error) {
        
        wself.tableView.scrollEnabled = YES;
        if (error) {
            //add error toast
            if (error.code != NSURLErrorCancelled) {
                //不是主动取消
                if (isHead) {
                    FHEmptyMaskViewType tip = FHEmptyMaskViewTypeNoData;
//                    NSString *tip = @"数据走丢了";
                    if (![TTReachability isNetworkConnected]) {
                        tip = FHEmptyMaskViewTypeNoNetWorkAndRefresh;//@"网络不给力，点击屏幕重试";
                    }
                    [wself showErrorMask:YES tip:tip enableTap:NO showReload:YES];
                }else{
                    [[FHMainManager sharedInstance] showToast:@"请求失败" duration:2];
                    [wself.tableView.mj_footer endRefreshing];
                }
            }
            return;
        }
        
        [wself showErrorMask:NO tip:FHEmptyMaskViewTypeNoData enableTap:NO showReload:YES];
        if (isHead) {
            if (model.data.items.count > 0) {
                NSString *tip = model.data.refreshTip;
                if (tip.length == 0) {
                    tip = @"请求成功";
                }
//                wself.showNotify(tip);
                [wself showNotifyMessage:tip];
            }
            
            [wself addHouseRankLog];
            
        }
        
        wself.tableView.mj_footer.hidden = NO;
        //reset load more state
        if (model.data && !model.data.hasMore) {
            
            [wself.tableView.mj_footer endRefreshingWithNoMoreData];
            
        }else{
            if (isHead) {
                [wself.tableView.mj_footer resetNoMoreData];
            }else{
                [wself.tableView.mj_footer endRefreshing];
            }
        }
        
        
        if (!isHead && model.data.items.count == 0) {
            [[FHMainManager sharedInstance] showToast:@"请求失败" duration:2];
        }
        
        wself.currentRentDataModel = model.data;
        wself.searchId = model.data.searchId;
        
        if (isHead) {
            [wself.houseList removeAllObjects];
        }
        
        [wself.houseList addObjectsFromArray:model.data.items];
        wself.showPlaceHolder = NO;
        [wself.tableView reloadData];
        wself.mapFindHouseOpenUrl = model.data.mapFindHouseOpenUrl;
        
        if (!isHead) {
            [wself addLoadMoreRefreshLog];
        }

        if (wself.houseList.count == 0) {
            FHEmptyMaskViewType tip;
            if (self.conditionFilter.length > 0) {
                tip = FHEmptyMaskViewTypeNoDataForCondition;
//                tip = @"暂无搜索结果";
            }else{
                tip = FHEmptyMaskViewTypeNoData;//@"数据走丢了";
            }
            [wself showErrorMask:YES tip:tip enableTap:NO showReload:NO];
        }
        wself.viewController.tracerModel.searchId = model.data.searchId;
        if (wself.isFirstLoad) {
            wself.viewController.tracerModel.originSearchId = model.data.searchId ?:@"be_null";
            wself.originSearchId = model.data.searchId;
            [wself addEnterLog];
            wself.isFirstLoad = NO;
        }
        
        wself.tableView.mj_footer.hidden = (wself.houseList.count == 0);
        
        if(wself.houseList.count < 10){
            wself.tableView.mj_footer.hidden = YES;
        }else{
            wself.tableView.mj_footer.hidden = NO;
        }
        
    }];
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
    NSDictionary *dict = @{@"house_type":@(FHHouseTypeRentHouse) ,
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
    if (self.currentRentDataModel.mapFindHouseOpenUrl.length > 0) {
        NSURL *url = [NSURL URLWithString:self.currentRentDataModel.mapFindHouseOpenUrl];
        NSDictionary *dict = @{};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
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
-(NSInteger)numberOfSections
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_showPlaceHolder) {
        return  10;
    }
    
    return _houseList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (_showPlaceHolder) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:kPlaceCellId];
        
    }else{
        
        FHHouseRentCell *rentCell = [tableView dequeueReusableCellWithIdentifier:@"item"];
        FHHouseRentDataItemsModel *model = _houseList[indexPath.row];
        
        rentCell.majorTitle.text = model.title;
        rentCell.extendTitle.text = model.subtitle;
        rentCell.priceLabel.text = model.pricing;
        if (model.tags.count > 0) {
            NSMutableArray *tags = [NSMutableArray new];
            for (FHSearchHouseDataItemsTagsModel *tag in model.tags) {
                FHTagItem *item = [FHTagItem instanceWithText:tag.content withColor:tag.textColor withBgColor:tag.backgroundColor];
                [tags addObject:item];
            }
            [rentCell setTags:tags];
        }else{
            [rentCell setTags:@[]];
        }
        
        FHSearchHouseDataItemsHouseImageModel *imgModel = [model.houseImage firstObject];
        [rentCell setHouseImages:model.houseImageTag];
        [rentCell.iconView bd_setImageWithURL:[NSURL URLWithString:imgModel.url] placeholder:self.placeHolderImage];
        
        
        cell = rentCell;
        
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
    
    if (indexPath.row == 0) {
        return 115;
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
    
    FHHouseRentDataItemsModel *model = _houseList[indexPath.row];
    
    SETTRACERKV(UT_ORIGIN_FROM, @"renting_list");
    
    id<FHHouseEnvContextBridge> envBridge = [[FHHouseBridgeManager sharedInstance] envContextBridge];
    [envBridge setTraceValue:@"renting_list" forKey:@"origin_from"];
    [envBridge setTraceValue:self.originSearchId forKey:@"origin_search_id"];
    
    NSMutableDictionary *tracer = [NSMutableDictionary dictionary];
    [tracer addEntriesFromDictionary:[self.viewController.tracerModel neatLogDict]];
    tracer[@"card_type"] = @"left_pic";
    tracer[@"element_from"] = @"be_null";
    tracer[@"enter_from"] = @"renting";
    tracer[@"log_pb"] = model.logPb;
    tracer[@"rank"] = @(indexPath.row);
    tracer[@"origin_from"] = @"renting_list";
    tracer[@"origin_search_id"] = self.originSearchId ? : @"be_null";
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fschema://rent_detail?house_id=%@", model.id]];
    TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer": tracer,@"house_type":@(3)}];
    [[TTRoute sharedRoute] openURLByViewController:url userInfo: userInfo];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    BOOL shouldInTable = (scrollView.contentOffset.y + scrollView.contentInset.top <  [self.topView filterTop]);
//    BOOL shouldInTable = (-scrollView.contentOffset.y  > [self.topView filterTop]);
    [self moveTop:shouldInTable];
    
    NSLog(@"[SCROLL] offset is: %f top %f  top cal height: %f should intable : %@",scrollView.contentOffset.y,scrollView.contentInset.top,(self.topView.height - [self.topView filterTop]),shouldInTable?@"YES":@"NO");
}


-(void)moveTop:(BOOL)toTableView
{
    if (toTableView) {
        if (self.topView.superview == self.tableView) {
            return;
        }
        
        self.topView.top = -self.topView.height;
        [self.tableView addSubview:self.topView];
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
        
//        UIEdgeInsets insets = self.tableView.contentInset;
//        insets.top = 0;
//        self.tableView.contentInset = insets;
//        self.tableView.contentOffset = ;
        
        NSLog(@"top container is: %@  set height to: %f",self.topContainerView,self.topView.height - [self.topView filterTop]);
        
        
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
//    CGFloat offsetdiff = insets.top - topViewHeight;
    insets.top = topViewHeight;
    self.tableView.contentInset = insets;
    _topView.frame = CGRectMake(0, -topViewHeight, _topView.width, topViewHeight);
    
    if (isShow) {
        self.tableView.contentOffset = CGPointMake(0, [self.topView filterTop] -topViewHeight);
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
    FHHouseRentDataItemsModel *model = _houseList[indexPath.row];
    if (_showHouseDict[model.id]) {
        //already add log
        return;
    }
    
    _showHouseDict[model.id] = @(1);
    
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
    param[@"group_id"] = model.id;
    param[@"impr_id"] = model.imprId;
    param[@"search_id"] = self.searchId;
    param[@"rank"] = @(indexPath.row);
    param[@"log_pb"] = model.logPb;
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

