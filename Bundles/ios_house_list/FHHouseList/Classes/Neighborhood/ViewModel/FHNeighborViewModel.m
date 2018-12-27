//
//  FHNeighborViewModel.m
//  FHHouseList
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHNeighborViewModel.h"
#import "FHNeighborListViewController.h"
#import "FHPlaceHolderCell.h"
#import "FHHouseListAPI.h"
#import "FHNeighborListModel.h"
#import "FHHouseBridgeManager.h"
#import "FHHouseSingleImageInfoCellBridgeDelegate.h"
#import "FHRefreshCustomFooter.h"


#define kPlaceholderCellId @"placeholder_cell_id"
#define kSingleImageCellId @"single_image_cell_id"

@interface FHNeighborViewModel ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHNeighborListViewController *listController;
@property(nonatomic , weak) TTHttpTask *httpTask;
@property(nonatomic , assign) BOOL lastHasMore;

@end

@implementation FHNeighborViewModel

-(instancetype)initWithController:(FHNeighborListViewController *)viewController tableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        _houseList = [NSMutableArray new];
        self.listController = viewController;
        self.tableView = tableView;
        self.lastHasMore = NO;
        [self configTableView];
    }
    return self;
}

-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"testcell"];
    [_tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:kPlaceholderCellId];

    id<FHHouseCellsBridge> bridge = [[FHHouseBridgeManager sharedInstance] cellsBridge];
    Class cellClass = [bridge singleImageCellClass];
    [_tableView registerClass:cellClass forCellReuseIdentifier:kSingleImageCellId];
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

- (void)processError:(FHEmptyMaskViewType)maskViewType tips:(NSString *)tips {
    // 此时需要看是否已经有有效数据，如果已经有的话只需要toast提示，不显示空页面
    if (self.houseList.count > 0) {
        self.listController.hasValidateData = YES;
        [self.listController.emptyView hideEmptyView];
        if (tips.length > 0) {
            // Toast
        }
    } else {
        self.listController.hasValidateData = NO;
        [self.listController.emptyView showEmptyWithType:maskViewType];
        if (tips.length > 0) {
            // Toast
        }
    }
    [self updateTableViewWithMoreData:self.lastHasMore];
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.listController.hasValidateData == YES) {
        return _houseList.count;
    } else {
        // PlaceholderCell Count
        return 10;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.listController.hasValidateData == YES) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSingleImageCellId];
        BOOL isLastCell = (indexPath.row == self.houseList.count - 1);
        id model = _houseList[indexPath.row];
        if([model isKindOfClass:[FHHouseRentDataItemsModel class]]){
            FHHouseRentDataItemsModel *rentModel = (FHHouseRentDataItemsModel *)model;
            [(id<FHHouseSingleImageInfoCellBridgeDelegate>)cell  updateWithRentHouseModel:rentModel isFirstCell:NO isLastCell:isLastCell];
        } else {
            SEL sel = @selector(updateWithModel:isLastCell:);
            if ([cell respondsToSelector:sel]) {
                FHSearchHouseDataItemsModel *item = _houseList[indexPath.row];
                [(id<FHHouseSingleImageInfoCellBridgeDelegate>)cell updateWithModel:item isLastCell:isLastCell];
            }
        }
        return cell;
    } else {
        // PlaceholderCell
        FHPlaceHolderCell *cell = (FHPlaceHolderCell *)[tableView dequeueReusableCellWithIdentifier:kPlaceholderCellId];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
}

#pragma mark - Request

- (void)requestHouseInSameNeighborhoodSearch:(NSString *)neighborhoodId houseId:(NSString *)houseId offset:(NSInteger)offset
{
    if (self.httpTask) {
        [self.httpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.httpTask = [FHHouseListAPI requestHouseInSameNeighborhoodQuery:self.condition neighborhoodId:neighborhoodId houseId:houseId searchId:self.searchId offset:offset count:15 class:[FHSameNeighborhoodHouseResponse class] completion:^(FHSameNeighborhoodHouseResponse * _Nonnull model, NSError * _Nonnull error) {
        if (model != NULL && error == NULL) {
            if (model.data.items.count > 0) {
                wself.listController.hasValidateData = YES;
                [wself.listController.emptyView hideEmptyView];
                [wself.houseList addObjectsFromArray:model.data.items];
                [wself.tableView reloadData];
                [wself updateTableViewWithMoreData:model.data.hasMore];
                wself.searchId = model.data.searchId;
            } else {
                [wself processError:FHEmptyMaskViewTypeNoDataForCondition tips:NULL];
            }
        } else {
            [wself processError:FHEmptyMaskViewTypeNetWorkError tips:@"网络异常"];
        }
    }];
}

- (void)requestRentInSameNeighborhoodSearch:(NSString *)neighborhoodId houseId:(NSString *)houseId offset:(NSInteger)offset {
    if (self.httpTask) {
        [self.httpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.httpTask = [FHHouseListAPI requestRentInSameNeighborhoodQuery:self.condition neighborhoodId:neighborhoodId houseId:houseId searchId:self.searchId offset:offset count:15 class:[FHHouseRentModel class] completion:^(FHHouseRentModel * _Nonnull model, NSError * _Nonnull error) {
        if (model != NULL && error == NULL) {
            if (model.data.items.count > 0) {
                wself.listController.hasValidateData = YES;
                [wself.listController.emptyView hideEmptyView];
                [wself.houseList addObjectsFromArray:model.data.items];
                [wself.tableView reloadData];
                [wself updateTableViewWithMoreData:model.data.hasMore];
                wself.searchId = model.data.searchId;
            } else {
                [wself processError:FHEmptyMaskViewTypeNoDataForCondition tips:NULL];
            }
        } else {
            [wself processError:FHEmptyMaskViewTypeNetWorkError tips:@"网络异常"];
        }
    }];
}

- (void)requestRelatedHouseSearch:(NSString *)neighborhoodId houseId:(NSString *)houseId offset:(NSInteger)offset {
    if (self.httpTask) {
        [self.httpTask cancel];
    }
    __weak typeof(self) wself = self;
    // condition添加请求参数到url后面
    self.httpTask = [FHHouseListAPI requestRelatedHouseSearchWithQuery:self.condition houseId:houseId offset:offset count:15 class:[FHRelatedHouseResponse class] completion:^(FHRelatedHouseResponse * _Nonnull model, NSError * _Nonnull error) {
        if (model != NULL && error == NULL) {
            if (model.data.items.count > 0) {
                wself.listController.hasValidateData = YES;
                [wself.listController.emptyView hideEmptyView];
                [wself.houseList addObjectsFromArray:model.data.items];
                [wself.tableView reloadData];
                [wself updateTableViewWithMoreData:model.data.hasMore];
                wself.searchId = model.data.searchId;
            } else {
                [wself processError:FHEmptyMaskViewTypeNoDataForCondition tips:NULL];
            }
        } else {
            [wself processError:FHEmptyMaskViewTypeNetWorkError tips:@"网络异常"];
        }
    }];
}

- (void)requestRentRelatedHouseSearch:(NSString *)neighborhoodId houseId:(NSString *)houseId offset:(NSInteger)offset {
    if (self.httpTask) {
        [self.httpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.httpTask = [FHHouseListAPI requestRentHouseSearchWithQuery:self.condition neighborhoodId:neighborhoodId houseId:houseId searchId:self.searchId offset:offset count:15 class:[FHHouseRentModel class] completion:^(FHHouseRentModel * _Nonnull model, NSError * _Nonnull error) {
        if (model != NULL && error == NULL) {
            if (model.data.items.count > 0) {
                wself.listController.hasValidateData = YES;
                [wself.listController.emptyView hideEmptyView];
                [wself.houseList addObjectsFromArray:model.data.items];
                [wself.tableView reloadData];
                [wself updateTableViewWithMoreData:model.data.hasMore];
                wself.searchId = model.data.searchId;
            } else {
                [wself processError:FHEmptyMaskViewTypeNoDataForCondition tips:NULL];
            }
        } else {
            [wself processError:FHEmptyMaskViewTypeNetWorkError tips:@"网络异常"];
        }
    }];
}

@end
