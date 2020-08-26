//
//  FHHouseFindResultViewModel.m
//  FHHouseFind
//
//  Created by 张静 on 2019/3/25.
//

#import "FHHouseFindResultViewModel.h"
#import "FHHouseType.h"
#import "FHHouseBaseItemCell.h"
#import "FHErrorView.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHUserTracker.h"
#import "FHHouseBridgeManager.h"
#import "FHHouseListBaseItemCell.h"
#import "FHHouseListBaseItemModel.h"
#import "TTRoute.h"
#import "FHHouseListAPI.h"
#import "TTHttpTask.h"
#import "FHHouseFindResultViewController.h"
#import "FHHouseFindResultTopHeader.h"
#import "FHHouseFindResultViewController.h"
#import "FHUtils.h"
#import "FHEnvContext.h"
#import <FHHouseBase/FHSearchChannelTypes.h>

#define kBaseCellId @"kBaseCellId"
#define kBaseErrorCellId @"kErrorCell"

static const NSUInteger kFHHomeHeaderViewSectionHeight = 35;

@interface FHHouseFindResultViewModel () <UITableViewDelegate,UITableViewDataSource>


@property(nonatomic , strong) NSMutableArray *houseList;
@property(nonatomic, weak) UITableView *tableView;
@property (nonatomic , assign) FHHouseType houseType;
@property(nonatomic , strong) NSMutableDictionary *houseShowCache;
@property(nonatomic , strong) NSString *originFrom;
@property(nonatomic , strong) NSString *originSearchId;
@property(nonatomic , strong) NSString *searchId;
@property(nonatomic , strong) FHHouseFindResultTopHeader *topHeader;
@property(nonatomic , weak) TTHttpTask * requestTask;
@property(nonatomic , assign) BOOL isShowErrorPage;
@property (nonatomic, weak) FHHouseFindResultViewController *currentViewController;
@property (nonatomic , strong) UIView *bottomView;
@property (nonatomic , strong) UIButton *buttonOpenMore;
@property(nonatomic , strong) FHTracerModel *tracerModel;
@property (nonatomic , strong) NSMutableDictionary *houseSearchDic;

@end

@implementation FHHouseFindResultViewModel

- (instancetype)initWithTableView:(UITableView *)tableView viewController:(FHHouseFindResultViewController *)viewController routeParam:(TTRouteParamObj *)paramObj
{

    self = [super init];
    if (self) {
        
        self.houseList = [NSMutableArray array];
        self.tableView = tableView;
        
        _topHeader = [[FHHouseFindResultTopHeader alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 191)];
        [_topHeader setBackgroundColor:[UIColor whiteColor]];
        
        self.isShowErrorPage = NO;
        
        _currentViewController = viewController;
        
        NSString *houseTypeStr = paramObj.allParams[@"house_type"];
        self.houseType = houseTypeStr ? [houseTypeStr integerValue] : FHHouseTypeSecondHandHouse;
        self.houseSearchDic = [NSMutableDictionary new];
        
        NSDictionary *tracerDict = paramObj.allParams[@"tracer"];
        if (tracerDict) {
            self.tracerModel = [FHTracerModel makerTracerModelWithDic:tracerDict];
            self.originFrom = self.tracerModel.originFrom;
        }
        
        NSDictionary *recommendHouseParam = paramObj.allParams[@"recommend_house"];
        
        if (recommendHouseParam && [recommendHouseParam isKindOfClass:[NSDictionary class]]) {
            self.recommendModel = [[FHHouseFindRecommendDataModel alloc] initWithDictionary:recommendHouseParam error:nil];
        }

        [self configBottomFooter];
        [self configTableView];
        
    }
    return self;
}

- (void)setRecommendModel:(FHHouseFindRecommendDataModel *)recommendModel
{
    self.tableView.scrollsToTop = NO;
    _recommendModel = recommendModel;
    __weak typeof(self) wself = self;
    _topHeader.clickCallBack = ^{
        [wself.currentViewController rightBtnClick];
    };
    [_topHeader refreshUI:self.recommendModel];
    
    if ([recommendModel isKindOfClass:[FHHouseFindRecommendDataModel class]]&& recommendModel.openUrl) {
        TTRouteParamObj *routeParamObj = [[TTRoute sharedRoute]routeParamObjWithURL:[NSURL URLWithString:recommendModel.openUrl]];
        NSString *queryString = [self getNoneFilterQueryWithParams:routeParamObj.queryParams];
        [self.houseSearchDic setValue:queryString forKey:@"search_query"];
        [self requestErshouHouseListData:YES query:queryString offset:0 searchId:nil];
    }
}

- (void)configBottomFooter
{
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
    
    [self.bottomView setBackgroundColor:[UIColor whiteColor]];
    self.bottomView.hidden = YES;
    
    _buttonOpenMore = [UIButton new];
    [_buttonOpenMore setTitle:@"查看更多符合条件房源" forState:UIControlStateNormal];
    [_buttonOpenMore setBackgroundColor:[UIColor themeGray7]];
    [_buttonOpenMore setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    [_buttonOpenMore.titleLabel setFont:[UIFont themeFontRegular:14]];
    [_buttonOpenMore addTarget:self action:@selector(openMoreClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomView addSubview:_buttonOpenMore];
    [_buttonOpenMore mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.centerY.equalTo(self.buttonOpenMore);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark category log
-(void)addEnterCategoryLog {
    NSMutableDictionary *params = [self categoryLogDict].mutableCopy;
    [params setValue:@"93413" forKey:@"event_tracking_id"];
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
    tracerDict[@"enter_from"] = self.tracerModel.enterFrom ? : @"be_null";
    tracerDict[@"enter_type"] = @"click";
    tracerDict[@"element_from"] = self.tracerModel.elementFrom ? : @"be_null";
    tracerDict[@"search_id"] = self.searchId ? : @"be_null";
    tracerDict[@"origin_from"] = self.tracerModel.originFrom ? : @"be_null";
    tracerDict[@"origin_search_id"] = self.originSearchId ? : @"be_null";
    
    return tracerDict;
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

- (void)openMoreClick
{
    NSMutableDictionary *categoryDict = [NSMutableDictionary new];
    [categoryDict setValue:@"old_list" forKey:@"page_type"];
    [categoryDict setValue:@"driving_find_house" forKey:@"element_from"];
    [FHUserTracker writeEvent:@"click_loadmore" params:categoryDict];

    
    if (self.recommendModel && self.recommendModel.bottomOpenUrl) {
        NSURL *url1 = [NSURL URLWithString:self.recommendModel.bottomOpenUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:url1 userInfo:nil];
    }else
    {
        NSURL *url1 = [NSURL URLWithString:@"sslocal://house_list?house_type=2"];
        [[TTRoute sharedRoute] openURLByPushViewController:url1 userInfo:nil];
    }
}

-(void)configTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
//    [self.tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:kBaseCellId];
     [self.tableView registerClass:[FHHouseListBaseItemCell class] forCellReuseIdentifier:kBaseCellId];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kBaseErrorCellId];
    
}

-(void)requestErshouHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId{
    
    [_requestTask cancel];
    NSMutableDictionary *paramsRequest = [NSMutableDictionary new];
    [paramsRequest setValue:@(self.houseType) forKey:@"house_type"];
    [paramsRequest setValue:@(50) forKey:@"count"];
    paramsRequest[CHANNEL_ID] = CHANNEL_ID_HELP_ME_FIND_HOUSE;
    
    [self.currentViewController startLoading];
    
    self.houseList = [NSMutableArray array];
    self.bottomView.hidden = YES;
    self.topHeader.titleLabel.text = @"";
    if (self.isShowErrorPage) {
        self.isShowErrorPage = NO;
    }
    [self.tableView reloadData];
    
    [self.tableView setContentOffset:CGPointMake(0, 0)];
//    if ([self.tableView numberOfSections] && [self.tableView numberOfRowsInSection:0]) {
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    }
    
    __weak typeof(self) wself = self;
    TTHttpTask *task = [FHHouseListAPI searchErshouHouseList:query params:paramsRequest offset:offset searchId:searchId sugParam:nil class:[FHListResultHouseModel class] completion:^(FHListResultHouseModel *  _Nullable model, NSError * _Nullable error) {
    
            if (!wself) {
                return ;
            }
            [wself processData:model error:error];
    
        }];
    
    self.requestTask = task;
}

-(void)processData:(id<FHBaseModelProtocol>)model error: (NSError *)error {
    if (model && !error) {
        
        NSMutableArray *itemArray = [NSMutableArray new];
        BOOL hasMore = NO;
        NSString *refreshTip;
        
        FHHouseListDataModel *houseModel = ((FHListResultHouseModel *)model).data;
        hasMore = houseModel.hasMore;
        refreshTip = houseModel.refreshTip;
        itemArray = houseModel.items;
        self.searchId = houseModel.searchId;

        [itemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
//            FHSingleImageInfoCellModel *cellModel = [self houseItemByModel:obj];
//            cellModel.houseType = FHHouseTypeSecondHandHouse;
        FHHouseListBaseItemModel *cellModel = (FHHouseListBaseItemModel *)obj;
            if (cellModel) {
                [self.houseList addObject:cellModel];
            }
            
        }];

        if (itemArray.count > 0) {
            if (houseModel.searchId) {
                self.originSearchId = houseModel.searchId;
                self.searchId = houseModel.searchId;
            }
            
            
            self.isShowErrorPage = NO;
            
            [self addEnterCategoryLog];
            
            [self.topHeader setTitleStr:itemArray.count];
            
            [self.currentViewController setNaviBarTitle:[NSString stringWithFormat:@"为您找到%ld套二手房",itemArray.count]];
            
            [self.tableView reloadData];
            self.bottomView.hidden = NO;
            
            self.tableView.scrollEnabled = YES;
        }else
        {
            [self.topHeader setTitleStr:0];
            self.isShowErrorPage = YES;

            [self.tableView reloadData];
            self.bottomView.hidden = YES;
            self.tableView.scrollEnabled = NO;
        }
        
    }else
    {
        [self.topHeader setTitleStr:0];
        self.isShowErrorPage = YES;
        [self.tableView reloadData];
        self.bottomView.hidden = YES;
        self.tableView.scrollEnabled = NO;
    }
    
    [self addHouseSearchLog];
    
    [self.currentViewController endLoading];
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
    if (self.isShowErrorPage) {
        return 1;
    }
    return _houseList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.isShowErrorPage) {
        UITableViewCell *cellError = [tableView dequeueReusableCellWithIdentifier:kBaseErrorCellId];
        for (UIView *subView in cellError.contentView.subviews) {
            [subView removeFromSuperview];
        }
        cellError.selectionStyle = UITableViewCellSelectionStyleNone;
        FHErrorView * noDataErrorView = [[FHErrorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.6)];
//        [noDataErrorView setBackgroundColor:[UIColor redColor]];
        [cellError.contentView addSubview:noDataErrorView];
        
        __weak typeof(self) weakSelf = self;
        noDataErrorView.retryBlock = ^{
                NSMutableDictionary *categoryDict = [NSMutableDictionary new];
                [categoryDict setValue:@"old_list" forKey:@"page_type"];
                [categoryDict setValue:@"driving_find_house" forKey:@"element_from"];
                [FHUserTracker writeEvent:@"click_loadmore" params:categoryDict];
            
                NSURL *url1 = [NSURL URLWithString:@"sslocal://house_list?house_type=2"];
                [[TTRoute sharedRoute] openURLByPushViewController:url1 userInfo:nil];
        };
        
        [noDataErrorView showEmptyWithTip:@"没有找到符合要求的二手房源" errorImageName:@"group-9"
                                showRetry:YES];
        noDataErrorView.retryButton.userInteractionEnabled = YES;
        [noDataErrorView.retryButton setTitle:@"查看其它房源" forState:UIControlStateNormal];
        [noDataErrorView.retryButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(104, 30));
        }];

        return cellError;
    }
    
//    FHHouseBaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kBaseCellId];
//    if (indexPath.row < self.houseList.count) {
//        FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
//
//        [cell refreshTopMargin: 20];
//        [cell updateWithHouseCellModel:cellModel];
//        return cell;
//    }
       FHHouseListBaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kBaseCellId];
        if (indexPath.row < self.houseList.count) {
            FHHouseListBaseItemModel *cellModel = self.houseList[indexPath.row];

    //        [cell refreshTopMargin: 20];
            [cell refreshWithData:cellModel];
        }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        if (indexPath.row < self.houseList.count) {
            
            FHHouseListBaseItemModel *cellModel = self.houseList[indexPath.row];
            if (![self.houseShowCache.allKeys containsObject:cellModel.houseid] && cellModel.houseid) {
                [self addHouseShowLog:cellModel withRank:indexPath.row];
                self.houseShowCache[cellModel.houseid] = @"1";
            }
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isShowErrorPage) {
        return [UIScreen mainScreen].bounds.size.height * 0.6;
    }
    
    if (indexPath.row < self.houseList.count) {
//        FHSingleImageInfoCellModel *cellModel  = nil;
//        BOOL isLastCell = NO;
//
//        cellModel = self.houseList[indexPath.row];
//
//        isLastCell = (indexPath.row == self.houseList.count - 1);
//        CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHHouseBaseItemCell recommendReasonHeight] : 0;
//        return (isLastCell ? 125 : 105) + reasonHeight;
         return 88;
    }
    return 88;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _topHeader;
}// custom view for header. will be adjusted to default or specified header height


- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return _bottomView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 191;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row < self.houseList.count) {
            FHHouseListBaseItemModel *cellModel = self.houseList[indexPath.row];
            if (cellModel) {
                [self jump2HouseDetailPage:cellModel withRank:indexPath.row];
            }
        }
    }
}

#pragma mark house_show log
-(void)addHouseShowLog:(FHHouseListBaseItemModel *)cellModel withRank: (NSInteger) rank {
    if (!cellModel) {
        return;
    }
    
    NSString *originFrom = self.originFrom ? : @"be_null";
    
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"house_type"] = [self houseTypeString];
    tracerDict[@"card_type"] = @"left_pic";
    tracerDict[@"page_type"] = [self pageTypeString];
    tracerDict[@"element_type"] = @"be_null";
    tracerDict[@"search_id"] = self.searchId ? : @"be_null";
    tracerDict[@"group_id"] = [cellModel groupId] ? : @"be_null";
    tracerDict[@"impr_id"] = [cellModel imprId] ? : @"be_null";
    tracerDict[@"rank"] = @(rank);
    tracerDict[@"origin_from"] = originFrom;
    tracerDict[@"origin_search_id"] = self.originSearchId ? : @"be_null";
    tracerDict[@"log_pb"] = [cellModel logPb] ? : @"be_null";
    
    [FHUserTracker writeEvent:@"house_show" params:tracerDict];
}

- (NSString *)houseTypeString
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

- (NSString *)pageTypeString
{
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

#pragma mark - 详情页跳转
-(void)jump2HouseDetailPage:(FHHouseListBaseItemModel *)cellModel withRank: (NSInteger) rank  {
    NSMutableDictionary *traceParam = @{}.mutableCopy;

    traceParam[@"enter_from"] = [self pageTypeString];
    traceParam[@"element_from"] = @"be_null";
    traceParam[@"search_id"] = self.searchId;
    traceParam[@"card_type"] = @"left_pic";
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
//            if (cellModel.houseModel) {
//
//                FHNewHouseItemModel *theModel = cellModel.houseModel;
//                urlStr = [NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",theModel.houseId];
//            }
            break;
        case FHHouseTypeSecondHandHouse:
//            if (cellModel.secondModel) {
                
//                FHSearchHouseDataItemsModel *theModel = cellModel.secondModel;
                urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",cellModel.houseid];
//            }
            break;
        case FHHouseTypeRentHouse:
//            if (cellModel.rentModel) {
//
//                FHHouseRentDataItemsModel *theModel = cellModel.rentModel;
//                urlStr = [NSString stringWithFormat:@"sslocal://rent_detail?house_id=%@",theModel.id];
//            }
            break;
        case FHHouseTypeNeighborhood:
//            if (cellModel.neighborModel) {
//
//                FHHouseNeighborDataItemsModel *theModel = cellModel.neighborModel;
//                urlStr = [NSString stringWithFormat:@"sslocal://neighborhood_detail?neighborhood_id=%@",theModel.id];
//            }
            break;
        default:
            break;
    }
    
    if (urlStr.length > 0) {
        NSURL *url = [NSURL URLWithString:urlStr];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.currentViewController refreshContentOffset:scrollView.contentOffset];
}

#pragma mark - 埋点相关
-(NSMutableDictionary *)houseShowCache {
    
    if (!_houseShowCache) {
        _houseShowCache = [NSMutableDictionary dictionary];
    }
    return _houseShowCache;
}

@end
