//
//  FHHouseRealtorDetailViewModel.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/12.
//

#import "FHHouseRealtorDetailViewModel.h"
#import "FHHouseRealtorDetailInfoModel.h"
#import "FHHouseRealtorDetailBaseCell.h"
#import "FHMainApi.h"
#import "UIScrollView+Refresh.h"
#import "FHRefreshCustomFooter.h"
#import "FHHouseRealtorDetailInfoModel.h"
#import "FHUGCCellManager.h"
#import "FHFeedUGCCellModel.h"
#import "FHUGCBaseCell.h"
#import "TTHttpTask.h"
#import "FHEnvContext.h"
#import "FHHouseUGCAPI.h"
#import "FHFeedListModel.h"
#import "UIViewAdditions.h"
#import "FHUGCFeedDetailJumpManager.h"
#import "ToastManager.h"
#import "FHHouseBaseItemCell.h"
#import "FHHouseRealtorDetailPlaceCell.h"

@interface FHHouseRealtorDetailViewModel()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHHouseRealtorDetailController *detailController;
@property(nonatomic, strong) FHErrorView *errorView;
@property(nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic , strong) FHUGCCellManager *cellManager;
@property(nonatomic, weak)TTHttpTask *requestTask;
@property(nonatomic, strong)FHRefreshCustomFooter *refreshFooter;
@property(nonatomic, strong) FHFeedListModel *feedListModel;
@property(nonatomic, strong) FHUGCBaseCell *currentCell;
@property(nonatomic, strong) FHFeedUGCCellModel *currentCellModel;
@property(nonatomic, strong) FHUGCFeedDetailJumpManager *detailJumpManager;
@property (nonatomic, strong) NSMutableArray *showHouseCache;
@property(nonatomic,strong)NSDictionary *tracerDic;

@property (copy, nonatomic) NSString *houseType;
@property (copy, nonatomic) NSString *houseId;
@property(nonatomic, copy)NSString *categoryId;
@property(strong, strong)NSDictionary *realtorInfo ;
@end
@implementation FHHouseRealtorDetailViewModel
- (instancetype)initWithController:(FHHouseRealtorDetailController *)viewController tableView:(UITableView *)tableView realtorInfo:(NSDictionary *)realtorInfo tracerDic:(NSDictionary *)tracerDic {
    self = [super init];
    if (self) {
        //        _detailTracerDic = [NSMutableDictionary new];
        //        _items = [NSMutableArray new];
        //        _cellHeightCaches = [NSMutableDictionary new];
        //        _elementShowCaches = [NSMutableDictionary new];
        //        _elementShdowGroup = [NSMutableDictionary new];
        //        _lastPointOffset = CGPointZero;
        //        _weakedCellTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        //        _weakedVCLifeCycleCellTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        //        self.houseType = houseType;
         self.tracerDic = tracerDic;
        self.detailController = viewController;
        self.tableView = tableView;
        self.realtorInfo = realtorInfo;
        //        self.tableView.backgroundColor = [UIColor themeGray7];
        [self configTableView];
        self.detailJumpManager = [[FHUGCFeedDetailJumpManager alloc] init];
        self.detailJumpManager.refer = 1;
        [self requestData:YES first:YES];
    }
    return self;
}

- (CGFloat)getVisibleHeight:(NSInteger)maxCount {
    CGFloat height = 0;
    if(self.dataList.count <= maxCount){
        for (FHFeedUGCCellModel *cellModel in self.dataList) {
            Class cellClass = [self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil];
            if([cellClass isSubclassOfClass:[FHUGCBaseCell class]]) {
                height += [cellClass heightForData:cellModel];
            }
        }
    }
    return height;
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    if (self.requestTask) {
        [self.requestTask cancel];
        self.detailController.isLoadingData = NO;
    }
    //
    if(self.detailController.isLoadingData){
        return;
    }
    NSString *refreshType = @"be_null";
    //    self.detailController.isLoadingData = YES;
    
    //    if(isFirst){
    //        [self.detailController startLoading];
    //    }
    __weak typeof(self) wself = self;
    NSInteger listCount = self.dataList.count;
    if(isFirst){
        listCount = 0;
    }
    double behotTime = 0;
    if(!isHead && listCount > 0){
        FHFeedUGCCellModel *cellModel = [self.dataList lastObject];
        behotTime = [cellModel.behotTime doubleValue];
    }
    if(isHead && listCount > 0){
        FHFeedUGCCellModel *cellModel = [self.dataList firstObject];
        behotTime = [cellModel.behotTime doubleValue];
    }
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    NSString *fCityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
    if(fCityId){
        [extraDic setObject:fCityId forKey:@"f_city_id"];
    }
    if (self.realtorInfo[@"tab_name"]) {
        [extraDic setObject:self.realtorInfo[@"tab_name"] forKey:@"tab_name"];
    }
    if (self.realtorInfo[@"realtor_id"]) {
        [extraDic setObject:self.realtorInfo[@"realtor_id"] forKey:@"realtor_id"];
    }
    self.categoryId = @"f_realtor_profile";
    TTHttpTask *task = [FHHouseUGCAPI requestFeedListWithCategory:self.categoryId behotTime:behotTime loadMore:!isHead listCount:listCount extraDic:extraDic completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        wself.detailController.isLoadingData = NO;
        FHFeedListModel *feedListModel = (FHFeedListModel *)model;
        wself.feedListModel = feedListModel;
        if (!wself) {
            if(isFirst){
                [wself.detailController endLoading];
            }
            return;
        }
        if (error) {
            //TODO: show handle error
            [self reloadTableViewData];
            if(isFirst){
                [wself.detailController endLoading];
                if(error.code != -999){
                    wself.refreshFooter.hidden = YES;
                }
            }else{
                wself.refreshFooter.hidden = YES;
                [[ToastManager manager] showToast:@"网络异常"];
                [wself updateTableViewWithMoreData:YES];
            }
            return;
        }
        if(model){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSArray *resultArr = [self convertModel:feedListModel.data];
                if(isHead && feedListModel.hasMore){
                    [wself.dataList removeAllObjects];
                }
                if(isHead){
                    [wself.dataList removeAllObjects];
                    [wself.dataList addObjectsFromArray:resultArr];
                }else{
                    [wself.dataList addObjectsFromArray:resultArr];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(isHead){
                        wself.tableView.hasMore = YES;
                    }else {
                        wself.tableView.hasMore = feedListModel.hasMore;
                    }
                    wself.detailController.hasValidateData = wself.dataList.count > 0;
                    if(wself.dataList.count > 0){
                        [wself updateTableViewWithMoreData:wself.tableView.hasMore];
                        [wself.detailController.emptyView hideEmptyView];
                    }
                    [self reloadTableViewData];
                });
            });
        }
    }];
    //    self.requestTask = task;
}
- (NSArray *)convertModel:(NSArray *)feedList{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (FHFeedListDataModel *itemModel in feedList) {
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:itemModel.content];
        cellModel.isHiddenConnectBtn = YES;
        cellModel.isInRealtorEvaluationList = YES;
        cellModel.categoryId = self.categoryId;
        cellModel.tableView = self.tableView;
        cellModel.enterFrom = [self.detailController categoryName];
        cellModel.isShowLineView = NO;
        switch (cellModel.cellType) {
            case FHUGCFeedListCellTypeUGC:
                cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCBrokerImage;
                break;
            case FHUGCFeedListCellTypeUGCSmallVideo:
                cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCBrokerVideo;
                break;
            default:
                break;
        }
        //        cellModel.tracerDic = self.tracerDic;
        if (cellModel) {
            [resultArray addObject:cellModel];
        }
    }
    return resultArray;
}

- (void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self registerCellClasses];
    [self.tableView registerClass:[FHHouseRealtorDetailPlaceCell class] forCellReuseIdentifier:@"FHHouseRealtorDetailPlaceCell"];
    __weak typeof(self) wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself requestData:NO first:NO];
    }];
    self.tableView.mj_footer = self.refreshFooter;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableView.mj_footer.hidden = NO;
    if (hasMore) {
        [self.tableView.mj_footer endRefreshing];
    }else {
        [self.refreshFooter setUpNoMoreDataText:@"- 我是有底线的哟 -" offsetY:-3];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
}

- (void)registerCellClasses {
    self.cellManager = [[FHUGCCellManager alloc] init];
    [self.cellManager registerAllCell:self.tableView];
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        NSMutableArray *dataList = [[NSMutableArray alloc]init];
        _dataList = dataList;
    }
    return _dataList;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count>0?self.dataList.count+1:self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
         NSString *identifier = @"FHHouseRealtorDetailPlaceCell";
         FHHouseBaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        [cell.contentView setBackgroundColor:[UIColor colorWithHexStr:@"#f8f8f8"]];
         return cell;
    }else {
        if(indexPath.row < self.dataList.count + 1){
            FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row -1];
            NSString *cellIdentifier = NSStringFromClass([self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil]);
            FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                Class cellClass = NSClassFromString(cellIdentifier);
                cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.delegate = self;
            if(indexPath.row < self.dataList.count +1){
                [cell refreshWithData:cellModel];
            }
            return cell;
        }
    }

    return [[FHUGCBaseCell alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count + 1){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row -1];
        [self trackFeedClientShow:cellModel withExtraDic:self.tracerDic];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 15;
    }
    
    if(indexPath.row < self.dataList.count + 1){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row -1];
        Class cellClass = [self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil];
        if([cellClass isSubclassOfClass:[FHUGCBaseCell class]]) {
            return [cellClass heightForData:cellModel];
        }
    }
    return 100;
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 10;
//}

- (void)reloadTableViewData {
    if(self.dataList.count > 0){
        [self updateTableViewWithMoreData:self.tableView.hasMore];
        self.tableView.backgroundColor = [UIColor themeGray7];
        
        CGFloat height = [self getVisibleHeight:5];
        if(height < self.detailController.errorViewHeight && height > 0 && self.detailController.errorViewHeight > 0){
            [self.tableView reloadData];
            CGFloat refreshFooterBottomHeight = self.tableView.mj_footer.height;
            if ([TTDeviceHelper isIPhoneXSeries]) {
                refreshFooterBottomHeight += 34;
            }
            //设置footer来占位
            UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, [UIScreen mainScreen].bounds.size.width, self.detailController.errorViewHeight - height - refreshFooterBottomHeight)];
            tableFooterView.backgroundColor = [UIColor clearColor];
            self.tableView.tableFooterView = tableFooterView;
            //            //修改footer的位置回到cell下方，不修改会在tableFooterView的下方
            //            self.tableView.mj_footer.mj_y -= tableFooterView.height;
            //            self.tableView.mj_footer.hidden = NO;
        }else{
            self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,0.001)];
            [self.tableView reloadData];
        }
    }else{
        [self.errorView showEmptyWithTip:@"暂无内容" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
        UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.detailController.errorViewHeight)];
        tableFooterView.backgroundColor = [UIColor whiteColor];
        [tableFooterView addSubview:self.errorView];
        self.tableView.tableFooterView = tableFooterView;
        self.refreshFooter.hidden = YES;
        self.tableView.backgroundColor = [UIColor whiteColor];
        [self.tableView reloadData];
    }
}
- (FHErrorView *)errorView {
    if(!_errorView){
        _errorView = [[FHErrorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 500)];
    }
    return _errorView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return;
    }
    FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row - 1];
    self.currentCellModel = cellModel;
    self.currentCell = [tableView cellForRowAtIndexPath:indexPath];
    self.detailJumpManager.currentCell = self.currentCell;
    [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
}

- (void)commentClicked:(FHFeedUGCCellModel *)cellModel cell:(nonnull FHUGCBaseCell *)cell {
    //    [self trackClickComment:cellModel];
    self.currentCellModel = cellModel;
    self.currentCell = cell;
    self.detailJumpManager.currentCell = self.currentCell;
    [self.detailJumpManager jumpToDetail:cellModel showComment:YES enterType:@"feed_comment"];
}

//- (void)clickRealtorIm:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell {
//    NSInteger index = [self.dataList indexOfObject:cellModel];
//    NSMutableDictionary *imExtra = @{}.mutableCopy;
//    imExtra[@"realtor_position"] = @"realtor_evaluate";
//    imExtra[@"from_gid"] = cellModel.groupId;
//    [self.realtorPhoneCallModel imchatActionWithPhone:cellModel.realtor realtorRank:[NSString stringWithFormat:@"%ld",(long)index] extraDic:imExtra];
//}

//- (void)clickRealtorPhone:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell {
//     NSMutableDictionary *extraDict = self.tracerDic.mutableCopy;
//    extraDict[@"realtor_id"] = cellModel.realtor.realtorId;
//    extraDict[@"realtor_rank"] = @"be_null";
//    extraDict[@"realtor_logpb"] = cellModel.realtor.realtorLogpb;
//    extraDict[@"realtor_position"] = @"realtor_evaluate";
//    extraDict[@"from_gid"] = cellModel.groupId;
//    NSDictionary *associateInfoDict = cellModel.realtor.associateInfo.phoneInfo;
//    extraDict[kFHAssociateInfo] = associateInfoDict;
//    FHAssociatePhoneModel *associatePhone = [[FHAssociatePhoneModel alloc]init];
//    associatePhone.reportParams = extraDict;
//    associatePhone.associateInfo = associateInfoDict;
//    associatePhone.realtorId = cellModel.realtor.realtorId;
//    associatePhone.searchId = self.tracerDic[@"log_pb"][@"search_id"];
//    associatePhone.imprId = self.tracerDic[@"log_pb"][@"impr_id"];
//    associatePhone.houseType =self.houseType.integerValue;
//    associatePhone.houseId = self.houseId;
//    associatePhone.showLoading = NO;
//    [self.realtorPhoneCallModel phoneChatActionWithAssociateModel:associatePhone];
//}

- (void)goToCommunityDetail:(FHFeedUGCCellModel *)cellModel {
    [self.detailJumpManager goToCommunityDetail:cellModel];
}

- (void)lookAllLinkClicked:(FHFeedUGCCellModel *)cellModel cell:(nonnull FHUGCBaseCell *)cell {
    self.currentCellModel = cellModel;
    self.currentCell = cell;
    self.detailJumpManager.currentCell = self.currentCell;
    [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
}

//- (void)clickRealtorHeader:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell {
//    if ([self.houseType integerValue] == FHHouseTypeSecondHandHouse) {
//            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//         dict[@"element_from"] = @"old_detail_related";
//         dict[@"enter_from"] = @"realtor_evaluate_list";
//        [self.realtorPhoneCallModel jump2RealtorDetailWithPhone:cellModel.realtor isPreLoad:NO extra:dict];
//    }
//}
- (void)trackFeedClientShow:(FHFeedUGCCellModel *)itemData withExtraDic:(NSDictionary *)extraDic{
    if (!itemData.groupId) {
        return;
    }
    if ([self.showHouseCache containsObject:itemData.groupId]) {
        return;
    }
    [self.showHouseCache addObject:itemData.groupId];
      NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"origin_from"] = [extraDic.allKeys containsObject:@"origin_from"]?extraDic[@"origin_from"]:@"be_null";
        dict[@"enter_from"] =  [extraDic.allKeys containsObject:@"enter_from"]?extraDic[@"enter_from"]:@"be_null";
        dict[@"page_type"] = [extraDic.allKeys containsObject:@"page_type"]?extraDic[@"page_type"]:@"be_null";
        dict[@"event_type"] = [self eventType];
    //    dict[@"group_id"] = itemData.groupId?:@"be_null";
        dict[@"group_id"] = [extraDic.allKeys containsObject:@"group_id"]?extraDic[@"group_id"]:@"be_null";
        dict[@"group_source"] = itemData.logPb[@"group_source"]?:@"be_null";
        dict[@"realtor_id"] = itemData.realtor.realtorId?:@"be_null";
        dict[@"realtor_id"] = itemData.realtor.realtorId?:@"be_null";
        dict[@"element_type"] = @"realtor_evaluate";
        dict[@"rank"] = [extraDic.allKeys containsObject:@"rank"]?extraDic[@"rank"]:@"be_null";
        dict[@"from_gid"] = [extraDic.allKeys containsObject:@"from_gid"]?extraDic[@"from_gid"]:@"be_null";
        dict[@"log_pb"] =  [extraDic.allKeys containsObject:@"log_pb"]?extraDic[@"log_pb"]:@"be_null";
        TRACK_EVENT(@"feed_client_show", dict);
}

- (NSString*)eventType {
    return @"house_app2c_v2";
}

- (NSMutableArray *)showHouseCache {
    if (!_showHouseCache) {
        _showHouseCache = [NSMutableArray array];
    }
    return _showHouseCache;
}
@end
