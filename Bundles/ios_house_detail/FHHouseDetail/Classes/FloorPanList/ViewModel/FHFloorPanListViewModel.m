//
//  FHFloorPanListViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHFloorPanListViewModel.h"
#import "FHHouseDetailAPI.h"
#import "FHFloorPanListCell.h"
#import "FHEnvContext.h"
#import "FHHouseDetailSubPageViewController.h"
#import <FHDetailNewModel.h>

static const NSString *kDefaultTopFilterStatus = @"-1";

@interface FHFloorPanListViewModel()
@property (nonatomic , weak) UITableView *floorListTable;
@property (nonatomic , weak) FHHouseDetailSubPageViewController *floorListVC;
@property (nonatomic , strong) NSMutableArray <FHDetailNewDataFloorpanListListModel *> *allItems;
@property (nonatomic , strong) NSMutableArray <FHDetailNewDataFloorpanListListModel *> *currentItems;
@property (nonatomic , strong) NSMutableArray *topRoomCountArray;
@property (nonatomic , weak) HMSegmentedControl *segmentedControl;
@property (nonatomic, strong)   NSMutableDictionary       *elementShowCaches;
@property (nonatomic, strong)   NSString  *currentCourtId;

@end


@implementation FHFloorPanListViewModel

-(instancetype)initWithController:(FHHouseDetailSubPageViewController *)viewController tableView:(UITableView *)tableView houseType:(FHHouseType)houseType andSegementView:(UIView *)segmentView andItems:(NSMutableArray <FHDetailNewDataFloorpanListListModel *> *)allItems andCourtId:(NSString *)courtId {
    self = [super init];
    if (self) {
        _floorListTable = tableView;
        _elementShowCaches = [NSMutableDictionary new];
        _allItems = allItems;
        _floorListVC = viewController;
        _segmentedControl = segmentView;
        _currentCourtId = courtId;
        self.detailController = viewController;
        
        [self startLoadData];

    }
    return self;
}

- (void)configTableView
{
    _floorListTable.delegate = self;
    _floorListTable.dataSource = self;
    [self registerCellClasses];
}

- (NSArray *)getSegementViewTitlsArray
{
    _topRoomCountArray = [NSMutableArray new];
    for (NSInteger i = 0; i < _allItems.count; i++) {
        FHDetailNewDataFloorpanListListModel * model = _allItems[i];
        if (model.roomCount && ![_topRoomCountArray containsObject:model.roomCount]) {
            [_topRoomCountArray addObject:model.roomCount];
        }
    }
    
    NSMutableArray *titlesArray = [NSMutableArray new];
    if (_topRoomCountArray.count > 0) {
        [_topRoomCountArray sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2){
            if ([obj1 integerValue] < [obj2 integerValue]){
                return NSOrderedAscending;
            }else{
                return NSOrderedDescending;}
        }];
        [titlesArray addObject:[NSString stringWithFormat:@"全部(%d)",_allItems.count]];
        
        for (NSInteger i = 0; i < _topRoomCountArray.count; i++) {
            NSInteger total = 0;

            for (NSInteger j = 0; j < self.allItems.count ; j++) {
                if ([self.allItems[i].roomCount isKindOfClass:[NSString class]] && [_topRoomCountArray[i] isKindOfClass:[NSString class]]) {
                        if ([self.allItems[j].roomCount integerValue] == [_topRoomCountArray[i] integerValue]) {
                            total++;
                    }
                }
            }
            
            [titlesArray addObject:[NSString stringWithFormat:@"%@室(%d)",_topRoomCountArray[i],total]];
        }
    }
    return titlesArray;
}

- (void)refreshCurrentShowList
{
    _currentItems = [self getSelectFilterDataList];
    if (_currentItems.count == 0) {
        [[ToastManager manager] showToast:@"暂无相关房型~"];
    }
    [_floorListTable reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    if ([_floorListTable numberOfSections] && [_floorListTable numberOfRowsInSection:0]) {
        [_floorListTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    _floorListTable.contentInset = UIEdgeInsetsMake(20,0,0,0);
    _floorListTable.contentOffset = CGPointMake(0, -20);
    
}

- (NSArray<FHDetailNewDataFloorpanListListModel *> *)getSelectFilterDataList
{
    NSString *roomCuntKey = kDefaultTopFilterStatus;
    if ( _segmentedControl.selectedSegmentIndex != 0 && _topRoomCountArray.count > _segmentedControl.selectedSegmentIndex - 1) {
        roomCuntKey = _topRoomCountArray[_segmentedControl.selectedSegmentIndex - 1];
    }
    
    NSMutableArray *currentItemsArray = [NSMutableArray new];
    for(FHDetailNewDataFloorpanListListModel *model in _allItems)
    {
        if([roomCuntKey isEqualToString:kDefaultTopFilterStatus]) {
            [currentItemsArray addObject:model];
        }
        else if ([model.roomCount isEqualToString:roomCuntKey]) {
                [currentItemsArray addObject:model];
        }
    }
    return currentItemsArray;
}

// 注册cell类型
- (void)registerCellClasses {
    [self.floorListTable registerClass:[FHFloorPanListCell class] forCellReuseIdentifier:NSStringFromClass([FHFloorPanListCell class])];
}
// cell class
- (Class)cellClassForEntity:(id)model {
    if ([model isKindOfClass:[FHDetailNewDataFloorpanListListModel class]]) {
        return [FHFloorPanListCell class];
    }
    return [FHDetailBaseCell class];
}
// cell identifier
- (NSString *)cellIdentifierForEntity:(id)model {
    Class cls = [self cellClassForEntity:model];
    return NSStringFromClass(cls);
}

- (void)startLoadData
{
    if (![TTReachability isNetworkConnected]) {
        [self.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkNotRefresh];
        return;
    }
    
    if (_currentCourtId) {
        [self.detailController startLoading];
        __weak typeof(self) wSelf = self;
        [FHHouseDetailAPI requestFloorPanListSearch:_currentCourtId completion:^(FHDetailFloorPanListResponseModel * _Nullable model, NSError * _Nullable error) {
            if(model.data && !error)
            {
                self.floorListTable.hidden = NO;
                self.segmentedControl.hidden = NO;
                
                [wSelf.detailController.emptyView hideEmptyView];
                wSelf.detailController.hasValidateData = YES;
                [wSelf processDetailData:model];
            }else
            {
                wSelf.detailController.hasValidateData = NO;
                [wSelf.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
            }
        }];
    }
}

- (void)processDetailData:(FHDetailFloorPanListResponseModel *)model {
    self.allItems = model.data.list;
    self.currentItems = model.data.list;

    if (_allItems.count > 0) {
        _segmentedControl.sectionTitles = [self getSegementViewTitlsArray];
    }
    [self configTableView];
    
    WeakSelf;
    _segmentedControl.indexChangeBlock = ^(NSInteger index) {
        StrongSelf;
        [self refreshCurrentShowList];
    };
    
    [self refreshCurrentShowList];
}

#pragma UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _currentItems.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHFloorPanListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHFloorPanListCell class])];
    BOOL isFirst = (indexPath.row == 0);
    BOOL isLast = (indexPath.row == _currentItems.count - 1);
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass([FHFloorPanListCell class])];
    }
    if ([cell isKindOfClass:[FHFloorPanListCell class]] && _currentItems.count > indexPath.row) {
        if (indexPath.row == 0) {
            ((FHDetailNewDataFloorpanListListModel *)self.currentItems[indexPath.row]).index = indexPath.row;
        }
        [cell refreshWithData:_currentItems[indexPath.row]];
        [cell refreshWithData:isFirst andLast:isLast];
        cell.baseViewModel = self;
    }
    cell.backgroundColor = [UIColor themeGray7];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_currentItems.count > indexPath.row) {
        FHDetailNewDataFloorpanListListModel *model = (FHDetailNewDataFloorpanListListModel *)_currentItems[indexPath.row];
        if ([model isKindOfClass:[FHDetailNewDataFloorpanListListModel class]]) {
            
            NSMutableDictionary *subPageParams = [_floorListVC subPageParams];
            subPageParams[@"contact_phone"] = nil;
            NSDictionary *tracer = subPageParams[@"tracer"];
            NSMutableDictionary *traceParam = [NSMutableDictionary new];
            if (tracer) {
                [traceParam addEntriesFromDictionary:tracer];
            }
            traceParam[@"enter_from"] = @"house_model_list";
//            traceParam[@"log_pb"] = self.baseViewModel.listLogPB;
//            traceParam[@"origin_from"] = self.baseViewModel.detailTracerDic[@"origin_from"];
            traceParam[@"card_type"] = @"left_pic";
            traceParam[@"rank"] = @(indexPath.row);
//            traceParam[@"origin_search_id"] = self.baseViewModel.detailTracerDic[@"origin_search_id"];
            traceParam[@"element_from"] = @"be_null";
            traceParam[@"log_pb"] = model.logPb;
            NSDictionary *dict = @{@"house_type":@(1),
                                   @"tracer": traceParam
                                   };

            NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithDictionary:nil];
            [infoDict setValue:model.id forKey:@"floor_plan_id"];
            [infoDict addEntriesFromDictionary:subPageParams];
            infoDict[@"house_type"] = @(1);
            infoDict[@"tracer"] = traceParam;
            TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];

            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://floor_plan_detail"] userInfo:info];
        } 
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
    // 添加element_show埋点
    if (!self.elementShowCaches[tempKey]) {
        self.elementShowCaches[tempKey] = @(YES);
        
        NSMutableDictionary *subPageParams = [_floorListVC subPageParams];
        NSDictionary *tracer = subPageParams[@"tracer"];
        NSMutableDictionary *traceParam = [NSMutableDictionary new];
        if ([tracer isKindOfClass:[NSDictionary class]]) {
            [traceParam addEntriesFromDictionary:tracer];
        }
        traceParam[@"card_type"] = @"left_pic";
        traceParam[@"rank"] = @(indexPath.row);
        traceParam[@"element_type"] = @"house_model";
        traceParam[@"page_type"] = @"house_model_list";
        [traceParam removeObjectForKey:@"enter_from"];
        [traceParam removeObjectForKey:@"element_from"];
        [traceParam addEntriesFromDictionary:tracer[@"log_pb"]];
        if (_currentItems.count > indexPath.row) {
            FHDetailNewDataFloorpanListListModel *itemModel = (FHDetailNewDataFloorpanListListModel *)_currentItems[indexPath.row];
            
            if (itemModel.logPb) {
                [traceParam setValue:itemModel.logPb forKey:@"log_pb"];
            }
            
            if (itemModel.searchId) {
                [traceParam setValue:itemModel.searchId forKey:@"search_id"];
            }
            
            if (itemModel.groupId) {
                [traceParam setValue:itemModel.groupId forKey:@"group_id"];
            }else
            {
                [traceParam setValue:itemModel.id forKey:@"group_id"];
            }
            
            if (itemModel.imprId) {
                [traceParam setValue:itemModel.imprId forKey:@"impr_id"];
            }
        }
        
        [FHEnvContext recordEvent:traceParam andEventKey:@"house_show"];
    }
}

@end
