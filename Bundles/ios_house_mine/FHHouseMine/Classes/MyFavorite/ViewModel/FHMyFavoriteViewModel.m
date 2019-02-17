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

#define kCellId @"cell_id"

extern NSString *const kFHDetailFollowUpNotification;

@interface FHMyFavoriteViewModel()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHMyFavoriteViewController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, assign) FHHouseType type;
@property(nonatomic, assign) NSInteger offset;
@property(nonatomic, copy) NSString *searchId;
@property(nonatomic, assign) NSInteger limit;

@end

@implementation FHMyFavoriteViewModel

-(instancetype)initWithTableView:(UITableView *)tableView controller:(FHMyFavoriteViewController *)viewController type:(FHHouseType)type
{
    self = [super init];
    if (self) {
        
        _dataList = [[NSMutableArray alloc] init];
        _limit = 10;
        _type = type;
        _tableView = tableView;
        
        [tableView registerClass:[FHSingleImageInfoCell class] forCellReuseIdentifier:kCellId];
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        __weak typeof(self) weakSelf = self;
        
        [tableView tt_addDefaultPullUpLoadMoreWithHandler:^{
            [weakSelf requestData:NO];
        }];
        
        self.viewController = viewController;
        
    }
    return self;
}

- (void)viewWillAppear {
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshData:) name:kFHDetailFollowUpNotification object:nil];
}

- (void)viewWillDisappear {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)requestData:(BOOL)isHead {
    [self.requestTask cancel];
    
    if(isHead){
        self.offset = 0;
        self.searchId = nil;
        [self.dataList removeAllObjects];
    }
    
//    [self trackRefresh];
    __weak typeof(self) wself = self;
    
    if(self.dataList.count == 0){
        [self.viewController startLoading];
    }
    
    self.requestTask = [FHMineAPI requestFocusDetailInfoWithType:self.type offset:self.offset searchId:self.searchId limit:self.limit className:@"FHFollowModel" completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        if(self.dataList.count == 0){
            [self.viewController endLoading];
        }
        
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
            [wself handleSuccess:model];
        }
    }];
}

- (void)handleSuccess:(id<FHBaseModelProtocol>  _Nonnull) model {
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
    self.searchId = followModel.data.searchId;
    self.viewController.hasValidateData = self.dataList.count > 0;
    
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

//列表页刷新 埋点
- (void)trackRefresh {
    //    NSMutableDictionary *dict = [self.viewController.tracerModel logDict];
    //    dict[@"refresh_type"] = @"default";
    //    TRACK_EVENT(@"category_refresh", dict);
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHSingleImageInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    BOOL isFirstCell = (indexPath.row == 0);
    BOOL isLastCell = (indexPath.row == self.dataList.count - 1);
    
    if (indexPath.row < self.dataList.count) {
        
        FHSingleImageInfoCellModel *cellModel = self.dataList[indexPath.row];
        [cell updateWithHouseCellModel:cellModel];
        [cell refreshTopMargin: 20];
        [cell refreshBottomMargin:isLastCell ? 20 : 0];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isLastCell = (indexPath.row == self.dataList.count - 1);
    return isLastCell ? 125 : 105;
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

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete){
//        [[ToastManager manager] showCustomLoading:@"正在取消关注"];
//        
//        if(indexPath.row < self.dataList.count){
//            
//            [self cancelHouseFollow:self.dataList[indexPath.row] completion:^(FHDetailUserFollowResponseModel * _Nullable model, NSError * _Nullable error) {
//                if(error){
//                    [self.tableView setEditing:NO animated:YES];
//                    [[ToastManager manager] showToast:@"网络异常"];
//                }else{
//                    [self.dataList removeObjectAtIndex:indexPath.row];
//                    [UIView performWithoutAnimation:^{
//                        [self.tableView reloadData];
//                    }];
//                    
//                    [[ToastManager manager] dismissCustomLoading];
//                    [[ToastManager manager] showToast:@"已取消关注"];
//                }
//            }];
//        }
//    }
//}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) wself = self;
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"取消关注" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

        [[ToastManager manager] showCustomLoading:@"正在取消关注"];
        if(indexPath.row < wself.dataList.count){
            [self cancelHouseFollow:wself.dataList[indexPath.row] completion:^(FHDetailUserFollowResponseModel * _Nullable model, NSError * _Nullable error) {
                if(error){
                    [wself.tableView setEditing:NO animated:YES];
                    [[ToastManager manager] showToast:@"网络异常"];
                }else{
                    [wself.dataList removeObjectAtIndex:indexPath.row];
                    [UIView performWithoutAnimation:^{
                        [wself.tableView reloadData];
                    }];

                    [[ToastManager manager] dismissCustomLoading];
                    [[ToastManager manager] showToast:@"已取消关注"];
                }
            }];
        }
    }];

    action.backgroundColor = [UIColor colorWithRed:236/255.0 green:77/255.0 blue:61/255.0 alpha:1];
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[action]];
    config.performsFirstActionWithFullSwipe = NO;

    return config;
}

#pragma mark - 详情页跳转
-(void)jump2HouseDetailPage:(FHSingleImageInfoCellModel *)cellModel withRank:(NSInteger)rank {
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[@"card_type"] = @"left_pic";
//    traceParam[@"enter_from"] = [self pageTypeString];
//    traceParam[@"element_from"] = [self elementTypeString];
    traceParam[@"search_id"] = self.searchId;
    traceParam[@"log_pb"] = [cellModel logPb];
//    traceParam[@"origin_from"] = self.originFrom;
//    traceParam[@"origin_search_id"] = self.originSearchId;
    traceParam[@"rank"] = @(rank);
    NSDictionary *dict = @{
                           @"house_type":@(self.type),
                           @"tracer": traceParam
                           };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSString *urlStr;
    
//    id<FHHouseEnvContextBridge> contextBridge = [[FHHouseBridgeManager sharedInstance]envContextBridge];
//    [contextBridge setTraceValue:self.originFrom forKey:@"origin_from"];
//    [contextBridge setTraceValue:self.originSearchId forKey:@"origin_search_id"];
    
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
    
    [FHHouseDetailAPI requestCancelFollow:followId houseType:self.type actionType:self.type completion:completion];
}

@end
