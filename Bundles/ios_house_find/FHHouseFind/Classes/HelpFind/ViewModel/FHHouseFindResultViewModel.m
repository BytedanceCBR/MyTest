//
//  FHHouseFindResultViewModel.m
//  FHHouseFind
//
//  Created by 张静 on 2019/3/25.
//

#import "FHHouseFindResultViewModel.h"
#import <FHHouseType.h>
#import <FHHouseBaseItemCell.h>
#import <FHErrorView.h>
#import <FHSingleImageInfoCellModel.h>
#import <FHUserTracker.h>
#import <FHHouseBridgeManager.h>
#import <TTRoute.h>
#import <FHHouseListAPI.h>
#import <TTHttpTask.h>
#import "FHHouseFindResultViewController.h"
#import "FHHouseFindResultTopHeader.h"
#import "FHHouseFindResultViewController.h"

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
@property (nonatomic , strong) FHHouseFindRecommendDataModel *recommendModel;
@property(nonatomic , assign) BOOL isShowErrorPage;
@property (nonatomic, strong) FHHouseFindResultViewController *currentViewController;
@end

@implementation FHHouseFindResultViewModel

- (instancetype)initWithTableView:(UITableView *)tableView viewController:(FHHouseFindResultViewController *)viewController routeParam:(TTRouteParamObj *)paramObj
{

    self = [super init];
    if (self) {
        
        self.houseList = [NSMutableArray array];
        self.tableView = tableView;
        
        _topHeader = [[FHHouseFindResultTopHeader alloc] initWithFrame:CGRectZero];
        [_topHeader setBackgroundColor:[UIColor whiteColor]];
        
        self.isShowErrorPage = YES;
        
        _currentViewController = viewController;
        
        NSString *houseTypeStr = paramObj.allParams[@"house_type"];
        self.houseType = FHHouseTypeSecondHandHouse;
        //
        //        self.houseSearchDic = paramObj.userInfo.allInfo[@"houseSearch"];
        //        NSDictionary *tracerDict = paramObj.allParams[@"tracer"];
        //        if (tracerDict) {
        //            self.tracerModel = [FHTracerModel makerTracerModelWithDic:tracerDict];
        //            self.originFrom = self.tracerModel.originFrom;
        //        }
        
        NSDictionary *recommendHouseParam = paramObj.allParams[@"recommend_house"];
        
        if (recommendHouseParam && [recommendHouseParam isKindOfClass:[NSDictionary class]]) {
            _recommendModel = [[FHHouseFindRecommendDataModel alloc] initWithDictionary:recommendHouseParam error:nil];
        }
        
        [_topHeader refreshUI:_recommendModel];
        
        NSString *queryString = [self getNoneFilterQueryWithParams:paramObj.queryParams];
        NSLog(@"query str:%@",queryString);
        
        [self requestErshouHouseListData:YES query:@"xxx" offset:50 searchId:_searchId];

        [self configTableView];
        
        
    }
    return self;
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
    [paramsRequest setValue:@(2) forKey:@"house_type"];
    
    __weak typeof(self) wself = self;
    TTHttpTask *task = [FHHouseListAPI searchErshouHouseList:query params:paramsRequest offset:offset searchId:searchId sugParam:nil class:[FHSearchHouseModel class] completion:^(FHSearchHouseModel *  _Nullable model, NSError * _Nullable error) {
    
            if (!wself) {
                return ;
            }
            [wself processData:model error:error];
    
        }];
    
    self.requestTask = task;
}

-(void)processData:(id<FHBaseModelProtocol>)model error: (NSError *)error {
    if (model) {
        
        NSMutableArray *itemArray = [NSMutableArray new];
        BOOL hasMore = NO;
        NSString *refreshTip;
        
        FHSearchHouseDataModel *houseModel = ((FHSearchHouseModel *)model).data;
        hasMore = houseModel.hasMore;
        refreshTip = houseModel.refreshTip;
        itemArray = houseModel.items;
        self.searchId = houseModel.searchId;
        
        [itemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            FHSingleImageInfoCellModel *cellModel = [self houseItemByModel:obj];
            cellModel.houseType = FHHouseTypeSecondHandHouse;
            
            if (cellModel) {
                [self.houseList addObject:cellModel];
            }
            
        }];
        NSLog(@"count = %d",_houseList.count);
        
        [self.tableView reloadData];
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

        FHErrorView * noDataErrorView = [[FHErrorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.6)];
//        [noDataErrorView setBackgroundColor:[UIColor redColor]];
        [cellError.contentView addSubview:noDataErrorView];

        noDataErrorView.retryBlock = ^{

        };
        [noDataErrorView showEmptyWithTip:@"没有找到符合要求的二手房源" errorImageName:@"group-9"
                                showRetry:YES];
        [noDataErrorView.retryButton setTitle:@"查看其他房源" forState:UIControlStateNormal];
        [noDataErrorView.retryButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(104, 30));
        }];
//
        [self.currentViewController hideBottomView];

//        [noDataErrorView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.left.right.equalTo(cellError.contentView);
//            make.height.mas_equalTo([UIScreen mainScreen].bounds.size.height * 0.6);
//        }];
//
        return cellError;
    }
    
    FHHouseBaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kBaseCellId];
    if (indexPath.row < self.houseList.count) {
        FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];

        [cell refreshTopMargin: 20];
        [cell updateWithHouseCellModel:cellModel];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        if (indexPath.row < self.houseList.count) {
            
//            FHSingleImageInfoCellModel *cellModel = self.houseList[indexPath.row];
//            if (![self.houseShowCache.allKeys containsObject:cellModel]) {
//
//                [self addHouseShowLog:cellModel withRank:indexPath.row];
//                self.houseShowCache[cellModel.houseModel.groupId] = @"1";
//            }
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isShowErrorPage) {
        return [UIScreen mainScreen].bounds.size.width * 0.6;
    }
    
    if (indexPath.row < self.houseList.count) {
        FHSingleImageInfoCellModel *cellModel  = nil;
        BOOL isLastCell = NO;
        
        
        cellModel = self.houseList[indexPath.row];
        
        isLastCell = (indexPath.row == self.houseList.count - 1);
        
        return (isLastCell ? 125 : 105);
    }
    return 105;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _topHeader;
}// custom view for header. will be adjusted to default or specified header height

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 191;
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
    }
}

#pragma mark house_show log
-(void)addHouseShowLog:(FHSingleImageInfoCellModel *)cellModel withRank: (NSInteger) rank {
    if (!cellModel) {
        return;
    }
    
    NSString *originFrom = self.originFrom ? : @"be_null";
    
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"house_type"] = @"be_null";
    tracerDict[@"card_type"] = @"left_pic";
    tracerDict[@"page_type"] = @"be_null";
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

#pragma mark - 详情页跳转
-(void)jump2HouseDetailPage:(FHSingleImageInfoCellModel *)cellModel withRank: (NSInteger) rank  {
    NSMutableDictionary *traceParam = @{}.mutableCopy;

    traceParam[@"enter_from"] = [self pageTypeString];
    traceParam[@"element_from"] = @"be_null";
    traceParam[@"search_id"] = self.searchId;
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

#pragma mark - 埋点相关
-(NSMutableDictionary *)houseShowCache {
    
    if (!_houseShowCache) {
        _houseShowCache = [NSMutableDictionary dictionary];
    }
    return _houseShowCache;
}

@end
