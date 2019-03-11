//
//  FHMyFavoriteViewModel.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/2/15.
//

#import "FHMyFavoriteViewModel.h"
#import <TTRoute.h>
#import <TTHttpTask.h>
#import "FHMessageCell.h"
#import "FHMineAPI.h"
#import "FHUnreadMsgModel.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "FHMessageViewController.h"
#import "FHFollowModel.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHSingleImageInfoCell.h"
#import <UIScrollView+Refresh.h>
#import "ToastManager.h"
#import "FHHouseDetailAPI.h"
#import "FHPlaceHolderCell.h"
#import "FHUserTracker.h"
#import "FHRefreshCustomFooter.h"


#define kCellId @"cell_id"
#define kFHFavoriteListPlaceholderCellId @"FHFavoriteListPlaceholderCellId"

extern NSString *const kFHDetailFollowUpNotification;

@interface FHMyFavoriteViewModel()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHMyFavoriteViewController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, assign) FHHouseType type;
@property(nonatomic, assign) NSInteger offset;
@property(nonatomic, copy) NSString *searchId;
@property(nonatomic, copy) NSString *originSearchId;
@property(nonatomic, assign) NSInteger limit;
@property(nonatomic, assign) BOOL showPlaceHolder;
@property(nonatomic, assign) BOOL isFirstLoad;
@property(nonatomic, strong) NSMutableDictionary *clientShowDict;
@property(nonatomic , strong) FHRefreshCustomFooter *refreshFooter;

@end

@implementation FHMyFavoriteViewModel

-(instancetype)initWithTableView:(UITableView *)tableView controller:(FHMyFavoriteViewController *)viewController type:(FHHouseType)type
{
    self = [super init];
    if (self) {
        
        _dataList = [[NSMutableArray alloc] init];
        _removedDataList = [NSMutableArray new];
        _limit = 10;
        _type = type;
        _tableView = tableView;
        _showPlaceHolder = YES;
        _isFirstLoad = YES;
        
        [tableView registerClass:[FHSingleImageInfoCell class] forCellReuseIdentifier:kCellId];
        [tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:kFHFavoriteListPlaceholderCellId];
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        __weak typeof(self) weakSelf = self;
        
        self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
            [weakSelf requestData:NO];
        }];
        self.tableView.mj_footer = self.refreshFooter;
        
        self.viewController = viewController;
        
        [self initNotification];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cancelFocusItem:) name:kFHDetailFollowUpNotification object:nil];
}

- (void)requestData:(BOOL)isHead {
    [self.requestTask cancel];
    
    if(isHead){
        self.offset = 0;
        self.searchId = nil;
        self.originSearchId = nil;
        [self.dataList removeAllObjects];
        [self.clientShowDict removeAllObjects];
    }

    __weak typeof(self) wself = self;
    
    self.requestTask = [FHMineAPI requestFocusDetailInfoWithType:self.type offset:self.offset searchId:self.searchId limit:self.limit className:@"FHFollowModel" completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
        [wself.tableView.mj_footer endRefreshing];
        
        if (!wself) {
            return;
        }

        if (error && wself.dataList.count == 0) {
            //TODO: show handle error
            [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
            return;
        }
        
        [wself.viewController.emptyView hideEmptyView];
        
        if(model){
            [wself handleSuccess:model isHead:isHead];
        }
    }];
}

- (void)handleSuccess:(id<FHBaseModelProtocol>  _Nonnull) model isHead:(BOOL)isHead {
    FHFollowModel *followModel = (FHFollowModel *)model;
    NSArray *itemArray = [NSArray array];
    if(self.type == FHHouseTypeNeighborhood){
        FHHouseNeighborModel *houseModel = [followModel toHouseNeighborModel];
        itemArray = houseModel.data.items;
    }else if(self.type == FHHouseTypeSecondHandHouse){
        FHSearchHouseModel *houseModel = [followModel toHouseSecondHandModel];
        itemArray = houseModel.data.items;
    }else if(self.type == FHHouseTypeNewHouse){
        FHNewHouseListResponseModel *houseModel = [followModel toHouseNewModel];
        itemArray = houseModel.data.items;
    }else if(self.type == FHHouseTypeRentHouse){
        FHHouseRentModel *houseModel = [followModel toHouseRentModel];
        itemArray = houseModel.data.items;
    }
    
    [itemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHSingleImageInfoCellModel *cellModel = [self houseItemByModel:obj];
        if (cellModel) {
            cellModel.isRecommendCell = NO;
            [self.dataList addObject:cellModel];
        }
    }];
    
    self.tableView.hasMore = followModel.data.hasMore;

    
    self.viewController.hasValidateData = self.dataList.count > 0;
    self.showPlaceHolder = NO;

    [self updateTableViewWithMoreData:followModel.data.hasMore];
    
    if (!followModel.data.hasMore && self.dataList.count < self.limit) {
        self.refreshFooter.hidden = YES;
    }
    
    if(followModel.data.hasMore){
        self.offset += self.limit;
    }else{
        self.offset += followModel.data.followItems.count;
    }
    
    if(self.dataList.count > 0){
        [self.viewController.emptyView hideEmptyView];
        [self.tableView reloadData];
    }else{
        [self.viewController.emptyView showEmptyWithTip:[self emptyTitle] errorImageName:@"group-9" showRetry:NO];
    }
    
    if(self.isFirstLoad){
        self.searchId = followModel.data.searchId;
        self.originSearchId = self.searchId;
        self.isFirstLoad = NO;
        [self addEnterCategoryLog];
    }
    
    if(!isHead){
        [self trackRefresh];
    }
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableView.mj_footer.hidden = NO;
    if (hasMore == NO) {
        [self.refreshFooter setUpNoMoreDataText:@"没有更多信息了" offsetY:-3];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
}

- (void)addEnterCategoryLog {
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    TRACK_EVENT(@"enter_category", tracerDict);
}

- (void)addStayCategoryLog:(NSTimeInterval)stayTime {
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    TRACK_EVENT(@"stay_tab", tracerDict);
}

- (NSDictionary *)categoryLogDict {
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    [tracerDict addEntriesFromDictionary:self.viewController.tracerDict];
    tracerDict[@"category_name"] = [self categoryName];
    tracerDict[@"search_id"] = self.searchId ? self.searchId : @"be_null";
    tracerDict[@"origin_search_id"] = self.originSearchId ? self.originSearchId : @"be_null";
    
    return tracerDict;
}

- (NSString *)categoryName {
    NSString *categoryName = @"be_null";
    switch (self.type) {
        case FHHouseTypeNewHouse:
            categoryName = @"new_follow_list";
            break;
        case FHHouseTypeRentHouse:
            categoryName = @"rent_follow_list";
            break;
        case FHHouseTypeSecondHandHouse:
            categoryName = @"old_follow_list";
            break;
        case FHHouseTypeNeighborhood:
            categoryName = @"neighborhood_follow_list";
            break;
            
        default:
            break;
    }
    return categoryName;
}

- (NSString *)houseType {
    NSString *houseType = @"be_null";
    switch (self.type) {
        case FHHouseTypeNewHouse:
            houseType = @"new";
            break;
        case FHHouseTypeRentHouse:
            houseType = @"rent";
            break;
        case FHHouseTypeSecondHandHouse:
            houseType = @"old";
            break;
        case FHHouseTypeNeighborhood:
            houseType = @"neighborhood";
            break;
            
        default:
            break;
    }
    return houseType;
}

- (NSString *)emptyTitle {
    NSString *text = @"暂未关注";
    switch (self.type) {
        case FHHouseTypeSecondHandHouse:
            text = [text stringByAppendingString:@"二手房"];
            break;
        case FHHouseTypeRentHouse:
            text = [text stringByAppendingString:@"租房"];
            break;
        case FHHouseTypeNewHouse:
            text = [text stringByAppendingString:@"新房"];
            break;
        case FHHouseTypeNeighborhood:
            text = [text stringByAppendingString:@"小区"];
            break;
            
        default:
            break;
    }
    return text;
}

- (FHSingleImageInfoCellModel *)houseItemByModel:(id)obj {
    
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
        
    }
    return cellModel;
}

- (void)cancelFocusItem:(NSNotification *)notification {
    NSInteger followStatus = [notification.userInfo[@"followStatus"] integerValue];
    if(followStatus == 0){
        // 取消收藏
        NSString *followId = notification.userInfo[@"followId"];
        NSInteger index = [self.dataList indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FHSingleImageInfoCellModel *cellModel = (FHSingleImageInfoCellModel *)obj;
            if([followId isEqualToString:[self getFollowId:cellModel]]){
                return YES;
            }
            return NO;
        }];
        //找不到index时会返回一个大数
        if(index < self.dataList.count && index >= 0){
            [self deleteFocusCell:index];
        }
    } else if (followStatus == 1) {
        // 收藏
        NSString *followId = notification.userInfo[@"followId"];
        NSInteger index = [self.removedDataList indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FHSingleImageInfoCellModel *cellModel = (FHSingleImageInfoCellModel *)obj;
            if([followId isEqualToString:[self getFollowId:cellModel]]){
                return YES;
            }
            return NO;
        }];
        //找不到index时会返回一个大数
        if(index < self.removedDataList.count && index >= 0){
            [self addFirstFocusCell:index];
        }
    }
}

- (void)addFirstFocusCell:(NSInteger)index {
    if(index < self.removedDataList.count && index >= 0){
        id data = self.removedDataList[index];
        [self.dataList insertObject:data atIndex:0];
        [self.removedDataList removeObjectAtIndex:index];
        self.offset++;
        if(self.dataList.count > 0){
            [self.viewController.emptyView hideEmptyView];
            [self.tableView reloadData];
        }else{
            [self.viewController.emptyView showEmptyWithTip:[self emptyTitle] errorImageName:@"group-9" showRetry:NO];
        }
    }
}

- (void)deleteFocusCell:(NSInteger)index {
    if(index < self.dataList.count && index >= 0){
        id data = self.dataList[index];
        [self.removedDataList addObject:data];
        [self.dataList removeObjectAtIndex:index];
        if(self.offset > 0){
            self.offset--;
        }
        
        //删除一条后有下页有新数据，用新数据填充
        if(self.tableView.hasMore && self.dataList.count < self.limit){
            [self requestData:YES];
        }else{
            if(self.dataList.count > 0){
                [self.viewController.emptyView hideEmptyView];
                [self.tableView reloadData];
                if (self.dataList.count < self.limit) {
                    self.refreshFooter.hidden = YES;
                }
            }else{
                [self.viewController.emptyView showEmptyWithTip:[self emptyTitle] errorImageName:@"group-9" showRetry:NO];
            }
        }
    }
}

- (void)hideMjFooter
{
    if (self.dataList.count <= 9) {
        self.tableView.mj_footer.hidden = YES;
    }
}

//列表页刷新 埋点
- (void)trackRefresh {
    NSMutableDictionary *dict = [self categoryLogDict];
    dict[@"refresh_type"] = @"pre_load_more";
    dict[@"search_id"] = self.searchId;
    TRACK_EVENT(@"category_refresh", dict);
}

- (void)trackHouseShow:(FHSingleImageInfoCellModel *)cellModel rank:(NSInteger)rank {
    NSMutableDictionary *dict = [self categoryLogDict];
    dict[@"card_type"] = @"left_pic";
    dict[@"group_id"] = cellModel.houseId;
    dict[@"house_type"] = [self houseType];
    dict[@"impr_id"] = cellModel.imprId;
    dict[@"log_pb"] = cellModel.logPb;
    dict[@"page_type"] = [self categoryName];
    dict[@"rank"] = @(rank);
    TRACK_EVENT(@"house_show", dict);
}

- (void)trackDeleteFollow:(FHSingleImageInfoCellModel *)cellModel {
    NSMutableDictionary *dict = [self categoryLogDict];
    dict[@"group_id"] = cellModel.houseId;
    dict[@"log_pb"] = cellModel.logPb;
    dict[@"page_type"] = [self categoryName];
    TRACK_EVENT(@"delete_follow", dict);
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.showPlaceHolder) {
        return 10;
    }
    return [_dataList count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!self.showPlaceHolder && indexPath.row < self.dataList.count){
        FHSingleImageInfoCellModel *cellModel = self.dataList[indexPath.row];
        
        if (!_clientShowDict) {
            _clientShowDict = [NSMutableDictionary new];
        }
        
        NSString *row = [NSString stringWithFormat:@"%i",indexPath.row];
        NSString *followId = [self getFollowId:cellModel];
        if(followId){
            if (_clientShowDict[followId]) {
                return;
            }
    
            _clientShowDict[followId] = @(indexPath.row);
            [self trackHouseShow:cellModel rank:indexPath.row];
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.showPlaceHolder){
        FHPlaceHolderCell *cell = [tableView dequeueReusableCellWithIdentifier:kFHFavoriteListPlaceholderCellId];
        return cell;
    }else{
        FHSingleImageInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
        BOOL isFirstCell = (indexPath.row == 0);
        BOOL isLastCell = (indexPath.row == self.dataList.count - 1);
        
        if (indexPath.row < self.dataList.count) {
            FHSingleImageInfoCellModel *cellModel = self.dataList[indexPath.row];
            CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHSingleImageInfoCell recommendReasonHeight] : 0;
            [cell updateWithHouseCellModel:cellModel];
            [cell refreshTopMargin: 20];
            [cell refreshBottomMargin:(isLastCell ? 20 : 0)+reasonHeight];
        }
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.showPlaceHolder) {
        return 105;
    }else{
        BOOL isLastCell = (indexPath.row == self.dataList.count - 1);
        FHSingleImageInfoCellModel *cellModel = self.dataList[indexPath.row];
            CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHSingleImageInfoCell recommendReasonHeight] : 0;
        return (isLastCell ? 125 : 105)+reasonHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row < self.dataList.count) {
        FHSingleImageInfoCellModel *cellModel = self.dataList[indexPath.row];
        if (cellModel) {
            [self jump2HouseDetailPage:cellModel withRank:indexPath.row];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"取消关注";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) wself = self;
    if (editingStyle == UITableViewCellEditingStyleDelete){
        FHSingleImageInfoCellModel *cellModel = wself.dataList[indexPath.row];
        [wself trackDeleteFollow:cellModel];
        [[ToastManager manager] showCustomLoading:@"正在取消关注"];
        if(indexPath.row < wself.dataList.count){
            [self cancelHouseFollow:cellModel completion:^(FHDetailUserFollowResponseModel * _Nullable model, NSError * _Nullable error) {
                if(error){
                    [wself.tableView setEditing:NO animated:YES];
                    [[ToastManager manager] showToast:@"网络异常"];
                }else{
                    [wself deleteFocusCell:indexPath.row];
                    [[ToastManager manager] dismissCustomLoading];
                    [[ToastManager manager] showToast:@"取消关注"];
                }
            }];
        }
    }
    
    [self performSelector:@selector(hideMjFooter) withObject:nil afterDelay:0.1];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) wself = self;
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"取消关注" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        FHSingleImageInfoCellModel *cellModel = wself.dataList[indexPath.row];
        [wself trackDeleteFollow:cellModel];
        [[ToastManager manager] showCustomLoading:@"正在取消关注"];
        if(indexPath.row < wself.dataList.count){
            [self cancelHouseFollow:cellModel completion:^(FHDetailUserFollowResponseModel * _Nullable model, NSError * _Nullable error) {
                if(error){
                    [wself.tableView setEditing:NO animated:YES];
                    [[ToastManager manager] showToast:@"网络异常"];
                }else{
                    [wself deleteFocusCell:indexPath.row];
                    [[ToastManager manager] dismissCustomLoading];
                    [[ToastManager manager] showToast:@"取消关注"];
                }
            }];
        }
    }];

    action.backgroundColor = [UIColor themeRed1];
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[action]];
    config.performsFirstActionWithFullSwipe = NO;

    
    return config;
}

#pragma mark - 详情页跳转
-(void)jump2HouseDetailPage:(FHSingleImageInfoCellModel *)cellModel withRank:(NSInteger)rank {
    
    NSMutableDictionary *traceParam = [self categoryLogDict];
    traceParam[@"card_type"] = @"left_pic";
    traceParam[@"enter_from"] = [self categoryName];
    traceParam[@"log_pb"] = [cellModel logPb];
    traceParam[@"rank"] = @(rank);
    NSDictionary *dict = @{
                           @"house_type":@(self.type),
                           @"tracer": traceParam
                           };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSString *urlStr;
    
    switch (self.type) {
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

- (void)cancelHouseFollow:(FHSingleImageInfoCellModel *)cellModel completion:(void(^)(FHDetailUserFollowResponseModel * _Nullable model , NSError * _Nullable error))completion {
    NSString *followId = [self getFollowId:cellModel];
    [FHHouseDetailAPI requestCancelFollow:followId houseType:self.type actionType:self.type completion:completion];
}

- (NSString *)getFollowId:(FHSingleImageInfoCellModel *)cellModel {
    NSString *followId = @"";
    switch (self.type) {
        case FHHouseTypeNewHouse:
            if (cellModel.houseModel) {
                FHNewHouseItemModel *theModel = cellModel.houseModel;
                followId = theModel.houseId;
            }
            break;
        case FHHouseTypeSecondHandHouse:
            if (cellModel.secondModel) {
                FHSearchHouseDataItemsModel *theModel = cellModel.secondModel;
                followId = theModel.hid;
            }
            break;
        case FHHouseTypeRentHouse:
            if (cellModel.rentModel) {
                FHHouseRentDataItemsModel *theModel = cellModel.rentModel;
                followId = theModel.id;
            }
            break;
        case FHHouseTypeNeighborhood:
            if (cellModel.neighborModel) {
                FHHouseNeighborDataItemsModel *theModel = cellModel.neighborModel;
                followId = theModel.id;
            }
            break;
        default:
            break;
    }
    
    return followId;
}

-(NSString *)pageTypeString {
    switch (self.type) {
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

@end
