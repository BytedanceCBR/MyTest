//
//  FHChildBrowsingHistoryViewModel.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/7/13.
//

#import "FHChildBrowsingHistoryViewModel.h"
#import "FHChildBrowsingHistoryViewController.h"
#import "FHBrowsingHistoryEmptyView.h"
#import "FHHomeConfigManager.h"
#import "FHEnvContext.h"
#import <TTNetworkManager/TTHttpTask.h>
#import "FHBrowseHistoryAPI.h"
#import "FHBrowseHistoryHouseDataModel.h"
#import "FHDetailNeighborhoodModel.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import "FHSearchBaseItemModel.h"
#import "FHHouseBaseItemCell.h"
#import "FHBrowsingHistoryContentCell.h"
#import <FHCommonUI/FHRefreshCustomFooter.h>
#import "FHHouseBaseNewHouseCell.h"
#import "FHEnvContext.h"
#import <FHHouseBase/FHMainManager+Toast.h>
#import "FHUserTracker.h"
#import <FHHouseBase/FHUserTrackerDefine.h>

@interface FHChildBrowsingHistoryViewModel()<FHBrowsingHistoryEmptyViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) FHChildBrowsingHistoryViewController *viewController;
@property (nonatomic, weak) FHBrowsingHistoryEmptyView *findHouseView;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) TTHttpTask *requestTask;
@property (nonatomic, strong) NSMutableArray *historyList;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) NSMutableDictionary *tracerDictRecord;
@property (nonatomic, assign) BOOL isEnterCategory;
@property (nonatomic, strong) NSString *searchId;
@property (nonatomic, strong) NSString *originSearchId;
@property (nonatomic, assign) BOOL isFirstRequest;

@end

@implementation FHChildBrowsingHistoryViewModel

- (instancetype)initWithViewController:(FHChildBrowsingHistoryViewController *)viewController tableView:(UITableView *)tableView emptyView:(FHBrowsingHistoryEmptyView *)emptyView {
    self = [super init];
    if (self) {
        self.isFirstRequest = YES;
        self.isEnterCategory = YES;
        self.tracerDictRecord = [[NSMutableDictionary alloc] init];
        self.historyList = [[NSMutableArray alloc] init];
        self.viewController = viewController;
        self.findHouseView = emptyView;
        self.tableView = tableView;
        emptyView.delegate = self;
        tableView.delegate = self;
        tableView.dataSource = self;
        [self registerCellClasses];
        
        __weak typeof(self) wself = self;
        FHRefreshCustomFooter *footer = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
            [wself requestData:NO];
        }];
        self.tableView.mj_footer = footer;
        [footer setUpNoMoreDataText:@"没有更多信息了"];
        footer.hidden = YES;
    }
    return self;
}

- (void)registerCellClasses {
    [_tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:@"FHHouseBaseItemCellList"];
    [_tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:[FHSearchHouseItemModel cellIdentifierByHouseType:FHHouseTypeSecondHandHouse]];
    [_tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:[FHSearchHouseItemModel cellIdentifierByHouseType:FHHouseTypeRentHouse]];
    [_tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:[FHSearchHouseItemModel cellIdentifierByHouseType:FHHouseTypeNeighborhood]];
    [_tableView registerClass:[FHHouseBaseNewHouseCell class] forCellReuseIdentifier:@"FHHouseBaseNewHouseCell"];
    [_tableView registerClass:[FHBrowsingHistoryContentCell class] forCellReuseIdentifier:@"FHBrowsingHistoryContentCell"];
}

- (void)requestData:(BOOL)isHead {
    if (![FHEnvContext isNetworkConnected]) {
        [self processErrorWithIsHead:isHead];
        return;
    }
    [_requestTask cancel];
    NSInteger offset = 0;
    if (!isHead) {
        offset = _offset;
    }
    __weak typeof(self) wself = self;
    self.requestTask = [FHBrowseHistoryAPI requestBrowseHistoryWithCount:10 houseType:self.houseType offset:offset class:([FHBrowseHistoryHouseResultModel class]) completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        [wself.viewController endLoading];
        if (!error) {
            [wself processData:model];
        } else {
            [wself processErrorWithIsHead:isHead];
        }
    }];
}

- (void)processErrorWithIsHead:(BOOL)isHead {
    if (isHead) {
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    } else {
        [[FHMainManager sharedInstance] showToast:@"网络异常" duration:1];
        [self.tableView.mj_footer endRefreshing];
    }
}

- (void)processData:(id)model {
    if (model) {
        [self.viewController.emptyView hideEmptyView];
        NSMutableArray *items = @[].mutableCopy;
        FHBrowseHistoryHouseDataModel *historyModel = ((FHBrowseHistoryHouseResultModel *)model).data;
        self.offset = historyModel.offset;
        if (historyModel.searchId.length > 0) {
            self.searchId = historyModel.searchId;
        }
        if (_isFirstRequest && self.searchId.length > 0) {
            self.isFirstRequest = NO;
            self.originSearchId = self.searchId;
        }
        if (self.isEnterCategory) {
            [self addEnterLog];
            self.isEnterCategory = NO;
        }
        if (historyModel.historyItems.count > 0) {
            [items addObjectsFromArray:historyModel.historyItems];
        }
        [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                id item = [self historyItemModelByDict:obj];
                [self.historyList addObject:item];
            }
        }];
        if (_historyList.count > 0) {
            self.findHouseView.hidden = YES;
            self.tableView.hidden = NO;
            [self.tableView reloadData];
            if (self.historyList.count > 10) {
                self.tableView.mj_footer.hidden = NO;
            } else {
                self.tableView.mj_footer.hidden = YES;
            }
            if (!historyModel.hasMore) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [self.tableView.mj_footer endRefreshing];
            }
        } else {
            self.findHouseView.hidden = NO;
            self.tableView.hidden = YES;
            [self.viewController.emptyView setHidden:YES];
        }
    }
}

- (id)historyItemModelByDict:(NSDictionary *)itemDict {
    NSInteger cardType = -1;
    cardType = [itemDict tt_integerValueForKey:@"card_type"];
    if (cardType == 0 || cardType == -1) {
        cardType = [itemDict tt_integerValueForKey:@"house_type"];
    }
    id itemModel = nil;
    NSError *jerror = nil;
    switch (cardType) {
        case FHSearchCardTypeNewHouse:
            itemModel = [[FHSearchHouseItemModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeSecondHouse:
            itemModel = [[FHSearchHouseItemModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeRentHouse:
            itemModel = [[FHSearchHouseItemModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeNeighborhood:
            itemModel = [[FHSearchHouseItemModel alloc]initWithDictionary:itemDict error:&jerror];
            break;
        case FHSearchCardTypeBrowseHistoryTip:
            itemModel = [[FHBrowseHistoryContentModel alloc] initWithDictionary:itemDict error:&jerror];
            break;
        default:
            break;
    }
    if (jerror) {
        NSLog(@"error");
    }
    return itemModel;
}

- (Class)cellClassForEntity:(id)model {
    if ([model isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *houseModel = (FHSearchHouseItemModel *)model;
        if (houseModel.houseType.integerValue == FHHouseTypeNewHouse) {
            return [FHHouseBaseNewHouseCell class];
        }
        return [FHHouseBaseItemCell class];
    } else if ([model isKindOfClass:[FHBrowseHistoryContentModel class]]) {
        return [FHBrowsingHistoryContentCell class];
    }
    return [FHListBaseCell class];
}

- (NSString *)cellIdentifierForEntity:(id)model {
    if ([model isKindOfClass:[FHBrowseHistoryContentModel class]]) {
        return @"FHBrowsingHistoryContentCell";
    } else if ([model isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *houseModel = (FHSearchHouseItemModel *)model;
        if (houseModel.houseType.integerValue == FHHouseTypeNewHouse) {
            return @"FHHouseBaseNewHouseCell";
        }
        return [FHSearchHouseItemModel cellIdentifierByHouseType:houseModel.houseType.integerValue];
    }
    return @"";
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _historyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row >= 0 && row < _historyList.count) {
        BOOL isLastCell = NO;
        BOOL isFirstCell = NO;
        id data = _historyList[row];
        NSString *identifier = [self cellIdentifierForEntity:data];
        if (identifier.length > 0) {
             FHListBaseCell *cell = (FHListBaseCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            FHSearchHouseItemModel *houseModel = nil;
            if ([data isKindOfClass:[FHSearchHouseItemModel class]]) {
                houseModel = (FHSearchHouseItemModel *)data;
            }
            if ([cell isKindOfClass:[FHHouseBaseNewHouseCell class]]) {
                FHHouseBaseNewHouseCell *theCell = (FHHouseBaseNewHouseCell *)cell;
                [theCell updateHouseListNewHouseCellModel:data];
                if (houseModel.houseStatus.integerValue != 0) {
                   [theCell updateHouseStatus];
                }
            }
            [cell refreshWithData:data];
            if ([cell isKindOfClass:[FHHouseBaseItemCell class]]) {
                FHHouseBaseItemCell *theCell = (FHHouseBaseItemCell *)cell;
               if (houseModel.houseStatus.integerValue != 0) {
                   [theCell updateHouseStatus];
                }
            }
            
            return cell;
        }
    }
    return [[UITableViewCell alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    if (row >= 0 && row < _historyList.count) {
        BOOL isFirstCell = NO;
        BOOL isLastCell = NO;
        id data = _historyList[row];
        if (indexPath.row == self.historyList.count - 1) {
            isLastCell = YES;
        }
        if (indexPath.row == 0) {
            isFirstCell = YES;
        }
        id cellClass = [self cellClassForEntity:data];
        if ([data isKindOfClass:[FHBrowseHistoryContentModel class]]) {
            return 40;
        } else if ([data isKindOfClass:[FHSearchHouseItemModel class]]) {
            FHSearchHouseItemModel *item = (FHSearchHouseItemModel *)data;
            item.isLastCell = isLastCell;
            if ((item.houseType.integerValue == FHHouseTypeRentHouse || item.houseType.integerValue == FHHouseTypeNeighborhood) && isFirstCell) {
                item.topMargin = 10;
            }else {
                item.topMargin = 0;
            }
            data = item;
        }
        if ([[cellClass class]respondsToSelector:@selector(heightForData:)]) {
            return [[cellClass class] heightForData:data];
        }
    }
    return 88;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row >= 0 && row < _historyList.count) {
        id cellModel = _historyList[row];
        if ([cellModel isKindOfClass:[FHSearchHouseItemModel class]]) {
            [self showHouseDetail:cellModel atIndex:row];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row >= 0 && row < _historyList.count) {
        id cellModel = _historyList[row];
        if ([cellModel isKindOfClass:[FHSearchHouseItemModel class]]) {
            [self addHouseShowLog:cellModel withRank:row];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 开始滑动时, 禁止collectionView滑动
    self.viewController.fatherVC.collectionView.scrollEnabled = NO;
}

#pragma mark - FHBrowsingHistoryEmptyViewDelegate

- (void)clickFindHouse:(FHHouseType)houseType {
    [self addClickOptionLog];
    NSArray *houseTypeList = [[FHEnvContext sharedInstance] getConfigFromCache].houseTypeList;
    NSNumber *houseTypeNum = [NSNumber numberWithInteger:houseType];
    if (![houseTypeList containsObject:houseTypeNum]) {
        [self popToMainPage];
        return;
    }
    
    NSMutableDictionary *dictTrace = [NSMutableDictionary new];
    [dictTrace setValue:@"maintab" forKey:@"enter_from"];
    [dictTrace setValue:@"maintab_icon" forKey:@"element_from"];
    [dictTrace setValue:@"click" forKey:@"enter_type"];
    [dictTrace setValue:@"be_null" forKey:@"origin_from"];
    NSDictionary *userInfoDict = @{@"tracer":dictTrace};
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
    NSString *urlStr = @"";
    switch (houseType) {
        case FHHouseTypeSecondHandHouse:
            urlStr = @"sslocal://second_house_main";
            break;
        case FHHouseTypeRentHouse:
            urlStr = @"sslocal://rent_main";
            break;
        case FHHouseTypeNewHouse:
            urlStr = @"sslocal://house_list?house_type=1";
            break;
        case FHHouseTypeNeighborhood:
            urlStr = @"sslocal://main?select_tab=tab_stream";
            break;
        default:
            urlStr = @"sslocal://main?select_tab=tab_stream";
            break;
    }
    NSURL *url = [NSURL URLWithString:urlStr];
    if (![urlStr isEqualToString:@"sslocal://main?select_tab=tab_stream"]) {
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    } else {
        [[TTRoute sharedRoute] openURLByViewController:url userInfo:userInfo];
    }
}

- (void)popToMainPage {
    [self.viewController.navigationController popToRootViewControllerAnimated:YES];
    if (![[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance isCurrentTabFirst]) {
        [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance jumpToTabbarFirst];
    }
}

-(void)showHouseDetail:(id)cellModel atIndex:(NSInteger)index {
    if ([cellModel isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)cellModel;
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSString *urlStr = nil;
        params[@"card_type"] = @"left_pic";
        params[UT_ENTER_FROM] = [self getPageType:self.houseType];
        params[UT_RANK] = @(index);
        switch (self.houseType) {
            case FHHouseTypeRentHouse:
                urlStr = [NSString stringWithFormat:@"fschema://rent_detail?house_id=%@",  model.id];
                break;
            case FHHouseTypeSecondHandHouse:
                urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@", model.id];
                break;;
            case FHHouseTypeNewHouse:
                urlStr = [NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@", model.id];
                break;
            case FHHouseTypeNeighborhood:
                urlStr = [NSString stringWithFormat:@"sslocal://neighborhood_detail?neighborhood_id=%@", model.id];
                break;
            default:
                break;
        }
        if (urlStr) {
            NSURL *url = [NSURL URLWithString:urlStr];
            NSMutableDictionary *dict = [NSMutableDictionary new];
            dict[@"tracer"] = params;
            dict[@"house_type"] = @(self.houseType);
            TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            [[TTRoute sharedRoute] openURLByViewController:url userInfo: userInfo];
        }
    }
}

#pragma mark - 埋点

- (void)addEnterLog {
    NSMutableDictionary *params = @{}.mutableCopy;
    [params addEntriesFromDictionary:self.viewController.tracerDict];
    params[UT_CATEGORY_NAME] = [self getPageType:self.houseType];
    params[UT_ORIGIN_SEARCH_ID] = self.originSearchId ? : @"be_null";
    params[UT_SEARCH_ID] = self.searchId ? : @"be_null";
    TRACK_EVENT(@"enter_category", params);
}

- (void)addClickOptionLog {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[UT_ORIGIN_FROM] = self.searchId ? : @"be_null";
    params[UT_PAGE_TYPE] = [self getPageType:self.houseType];
    params[UT_CLICK_POSITION] = @"去挑好房";
    TRACK_EVENT(@"click_options", params);
}

-(void)addHouseShowLog:(FHSearchBaseItemModel *)cellModel withRank: (NSInteger)rank {
    NSString *recordKey = [NSString stringWithFormat:@"%ld",rank];
    if (self.tracerDictRecord[recordKey]) {
        return;
    }
    if ([cellModel isKindOfClass:[FHSearchHouseItemModel class]]) {
        NSMutableDictionary *params = @{}.mutableCopy;
        [params addEntriesFromDictionary:self.viewController.tracerDict];
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)cellModel;
        self.tracerDictRecord[recordKey] = @(YES);
        
        
        params[UT_PAGE_TYPE] = [self getPageType:self.houseType];
        params[UT_ORIGIN_SEARCH_ID] = self.originSearchId ? : @"be_null";
        params[UT_SEARCH_ID] = self.searchId ? : @"be_null";
        params[@"impr_id"] = model.imprId;
        params[UT_RANK] = @(rank);
        params[UT_HOUSE_TYPE] = [self getHouseType:self.houseType];
        params[@"log_pb"] = model.logPb;
        TRACK_EVENT(@"house_show", params);
    }
}

- (NSString *)getPageType:(FHHouseType)houseType {
    switch (houseType) {
        case FHHouseTypeNewHouse:
            return @"history_new_list";
        case FHHouseTypeSecondHandHouse:
            return @"history_old_list";
        case FHHouseTypeRentHouse:
            return @"history_rent_list";
        case FHHouseTypeNeighborhood:
            return @"history_neighborhood_list";
        default:
            return @"";
    }
}

- (NSString *)getHouseType:(FHHouseType)houseType {
    switch (houseType) {
        case FHHouseTypeNewHouse:
            return @"new";
        case FHHouseTypeSecondHandHouse:
            return @"old";
        case FHHouseTypeRentHouse:
            return @"rent";
        case FHHouseTypeNeighborhood:
            return @"neighborhood";
        default:
            return @"";
    }
}

@end
