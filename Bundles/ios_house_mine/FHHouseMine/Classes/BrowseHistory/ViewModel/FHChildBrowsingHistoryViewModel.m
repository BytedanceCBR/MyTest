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

@interface FHChildBrowsingHistoryViewModel()<FHBrowsingHistoryEmptyViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) FHChildBrowsingHistoryViewController *viewController;
@property (nonatomic, weak) FHBrowsingHistoryEmptyView *emptyView;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) TTHttpTask *requestTask;
@property (nonatomic, strong) NSMutableArray *historyList;
@property (nonatomic, assign) NSInteger offset;

@end

@implementation FHChildBrowsingHistoryViewModel

- (instancetype)initWithViewController:(FHChildBrowsingHistoryViewController *)viewController tableView:(UITableView *)tableView emptyView:(FHBrowsingHistoryEmptyView *)emptyView {
    self = [super init];
    if (self) {
        self.historyList = [[NSMutableArray alloc] init];
        self.viewController = viewController;
        self.emptyView = emptyView;
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
    [_requestTask cancel];
    NSInteger offset = 0;
    if (!isHead) {
        offset = _historyList.count;
    }
    __weak typeof(self) wself = self;
    self.requestTask = [FHBrowseHistoryAPI requestBrowseHistoryWithCount:20 houseType:self.houseType offset:offset class:([FHBrowseHistoryHouseResultModel class]) completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        if (!error) {
            [wself processData:model];
        }
    }];
}

- (void)processData:(id)model {
    if (model) {
        NSMutableArray *items = @[].mutableCopy;
        FHBrowseHistoryHouseDataModel *historyModel = ((FHBrowseHistoryHouseResultModel *)model).data;
        self.offset = historyModel.offset;
        if (historyModel.historyItems.count > 0) {
            [items addObjectsFromArray:historyModel.historyItems];
        }
        [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                id item = [self historyItemModelByDict:obj];
                [self.historyList addObject:item];
            }
        }];
        self.emptyView.hidden = YES;
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
            [cell refreshWithData:data];
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 开始拖拽滑动时，收起键盘
    self.viewController.fatherVC.collectionView.scrollEnabled = NO;
}

#pragma mark - FHBrowsingHistoryEmptyViewDelegate
- (void)clickFindHouse:(FHHouseType)houseType {
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

-(void)showHouseDetail:(id)cellModel atIndex:(NSInteger *)index {
    NSString *logPb = @"";
    NSMutableDictionary *tracerParam = [NSMutableDictionary dictionary];
    NSString *urlStr = nil;
    tracerParam[@"card_type"] = @"left_pic";
    if ([cellModel isKindOfClass:[FHSearchHouseItemModel class]]) {
        
    }
    
}

- (void)popToMainPage {
    [self.viewController.navigationController popToRootViewControllerAnimated:YES];
    if (![[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance isCurrentTabFirst]) {
        [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance jumpToTabbarFirst];
    }
}

@end
