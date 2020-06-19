//
//  FHDetailEvaluationListViewModel.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/16.
//

#import "FHDetailEvaluationListViewModel.h"
#import "TTHttpTask.h"
#import "FHHouseUGCAPI.h"
#import "FHHouseDeatilRGCImageCell.h"
#import "FHUGCCellManager.h"
#import "FHEnvContext.h"
#import "FHHouseUGCAPI.h"
#import "UIScrollView+Refresh.h"
#import "TTHttpTask.h"
#import "FHRefreshCustomFooter.h"
#import "ToastManager.h"

#import "FHFeedListModel.h"
#import "FHRealtorEvaluatingTracerHelper.h"
#import "FHUGCFeedDetailJumpManager.h"
#import "FHRealtorEvaluatingPhoneCallModel.h"
#import "FHUserTracker.h"
#import "TTStringHelper.h"
@interface FHDetailEvaluationListViewModel()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, weak)FHDetailEvaluationListViewController *listController;
@property (weak, nonatomic)FHDetailEvaluationListViewHeader *evaluationHeader;
@property (nonatomic , strong) FHUGCCellManager *cellManager;
@property(nonatomic, weak)TTHttpTask *requestTask;
@property(nonatomic, copy)NSString *categoryId;
@property(nonatomic, strong)FHRefreshCustomFooter *refreshFooter;
@property (nonatomic, strong)NSMutableArray *dataList;
@property(nonatomic, strong) FHFeedListModel *feedListModel;
@property (nonatomic, strong)NSMutableDictionary *elementShowCaches;
@property (nonatomic, strong)FHRealtorEvaluatingTracerHelper *tracerHelper;
@property(nonatomic, strong) FHUGCBaseCell *currentCell;
@property(nonatomic, strong) FHFeedUGCCellModel *currentCellModel;
@property(nonatomic, strong) FHUGCFeedDetailJumpManager *detailJumpManager;
@property(nonatomic, strong) FHRealtorEvaluatingPhoneCallModel *realtorPhoneCallModel;
@property (copy, nonatomic) NSString *houseType;
@property (copy, nonatomic) NSString *houseId;


@end
@implementation FHDetailEvaluationListViewModel
- (instancetype)initWithController:(FHDetailEvaluationListViewController *)viewController tableView:(UITableView *)table headerView:(FHDetailEvaluationListViewHeader *)header userInfo:(NSDictionary *)userInfo {
    self = [super init];
    if (self) {
        self.listController = viewController;
        self.tableView = table;
        self.evaluationHeader = header;
        self.dataList = [[NSMutableArray alloc] init];
        self.houseId = userInfo[@"house_id"];
        self.houseType = userInfo[@"house_type"];
        self.categoryId = userInfo[@"category_name"];
        self.elementShowCaches = [NSMutableDictionary new];
        self.tracerHelper = [[FHRealtorEvaluatingTracerHelper alloc]init];
        self.listController.emptyView.backgroundColor = [UIColor colorWithHexStr:@"#f8f8f8"];
        self.detailJumpManager = [[FHUGCFeedDetailJumpManager alloc] init];
        self.detailJumpManager.refer = 1;
        [self configTableView];
        self.realtorPhoneCallModel = [[FHRealtorEvaluatingPhoneCallModel alloc]initWithHouseType:self.houseType.integerValue houseId:self.houseId];
        self.realtorPhoneCallModel.belongsVC = self.listController;
    }
    return self;
}

- (void)configTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.cellManager = [[FHUGCCellManager alloc] init];
    [self.cellManager registerAllCell:_tableView];
    __weak typeof(self) wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself requestData:NO first:NO];
    }];
    self.evaluationHeader.headerItemSelectAction = ^(void) {
        [wself.listController.emptyView hideEmptyView];
        [wself.dataList removeAllObjects];
        self.refreshFooter.hidden = YES;
        [wself.tableView reloadData];
        wself.listController.hasValidateData = NO;
         [wself requestData:YES first:YES];
    };
    self.tableView.mj_footer = self.refreshFooter;
    self.refreshFooter.hidden = YES;
     [wself requestData:YES first:YES];
}

- (void)setTracerDic:(NSMutableDictionary *)tracerDic {
    _tracerDic = tracerDic;
    self.realtorPhoneCallModel.tracerDict = self.tracerDic;
    self.tracerHelper.tracerModel = [FHTracerModel makerTracerModelWithDic:tracerDic];
}

- (void)reloadData {
    self.listController.hasValidateData = NO;
    [self requestData:YES first:YES];
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    if(self.listController.isLoadingData){
        return;
    }
    
    NSString *refreshType = @"be_null";
//    if(isHead){
//        if(self.listController.isRefreshTypeClicked){
//            refreshType = @"click";
//            self.listController.isRefreshTypeClicked = NO;
//        }else{
//            refreshType = @"push";
//        }
//    }else{
//        refreshType = @"pre_load_more";
//    }
//    [self trackCategoryRefresh:refreshType];
    
    self.listController.isLoadingData = YES;
    

    if(isFirst){
        [self.listController startLoading];
//        self.retryCount = 0;
    }
    
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
    if (self.houseId) {
        [extraDic setObject:self.houseId forKey:@"house_id"];
    }
    if (self.houseType) {
         [extraDic setObject:self.houseType forKey:@"house_type"];
    }
    if (self.evaluationHeader.selectName) {
         [extraDic setObject:self.evaluationHeader.selectName forKey:@"tab_name"];
    }
    self.requestTask = [FHHouseUGCAPI requestFeedListWithCategory:self.categoryId behotTime:behotTime loadMore:!isHead listCount:listCount extraDic:extraDic completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        wself.listController.isLoadingData = NO;
        FHFeedListModel *feedListModel = (FHFeedListModel *)model;
        wself.feedListModel = feedListModel;
        if (!wself) {
            if(isFirst){
                [wself.listController endLoading];
            }
            return;
        }
        if (error) {
            //TODO: show handle error
            if(isFirst){
                [wself.listController endLoading];
                if(error.code != -999){
                    [wself.listController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
                    wself.listController.showenRetryButton = YES;
                    wself.refreshFooter.hidden = YES;
                }
            }else{
                [wself.listController.emptyView showEmptyWithTip:@"网络异常，请检查网络连接" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
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
//                    [wself.dataList insertObjects:result atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, result.count)]];
                }else{
                    [wself.dataList addObjectsFromArray:resultArr];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(isHead){
                        wself.tableView.hasMore = YES;
                    }else{
                        wself.tableView.hasMore = feedListModel.hasMore;
                    }
                    wself.listController.hasValidateData = wself.dataList.count > 0;
                    if(wself.dataList.count > 0){
                        [wself updateTableViewWithMoreData:wself.tableView.hasMore];
                        [wself.listController.emptyView hideEmptyView];
                    }else{
                        [wself.listController.emptyView showEmptyWithTip:@"暂无内容" errorImageName:kFHErrorMaskNoDataImageName showRetry:NO];
                        wself.refreshFooter.hidden = YES;
                    }
                    [wself.tableView reloadData];
//                    NSString *refreshTip = feedListModel.tips.displayInfo;
//                    if (isHead && wself.dataList.count > 0 && ![refreshTip isEqualToString:@""] && wself.viewController.tableViewNeedPullDown && !wself.isRefreshingTip){
//                        wself.isRefreshingTip = YES;
//                        [wself.viewController showNotify:refreshTip completion:^{
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                wself.isRefreshingTip = NO;
//                            });
//                        }];
//                        [wself.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
//                    }
                });
            });
        }
    }];
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
self.tableView.mj_footer.hidden = NO;
if (hasMore) {
    [self.tableView.mj_footer endRefreshing];
}else {
    [self.refreshFooter setUpNoMoreDataText:@"我是有底线的" offsetY:-3];
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
}
}

- (NSArray *)convertModel:(NSArray *)feedList{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (FHFeedListDataModel *itemModel in feedList) {
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:itemModel.content];
        cellModel.isInRealtorEvaluationList = YES;
        cellModel.categoryId = self.categoryId;
        cellModel.tableView = self.tableView;
        cellModel.enterFrom = [self.listController categoryName];
        switch (cellModel.cellType) {
            case FHUGCFeedListCellTypeUGC:
                cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCBrokerImage;
//                contentHeight = model.contentHeight  +75 + 20 + 50 +contentHeight + 30;
                break;
            case FHUGCFeedListCellTypeUGCSmallVideo:
                cellModel.cellSubType = FHUGCFeedListCellSubTypeUGCBrokerVideo;
//                contentHeight = model.contentHeight  +150 + 20 + 50 +contentHeight + 45;
                break;
            default:
                break;
        }
        [resultArray addObject:cellModel];
    }
    return resultArray;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        NSString *cellIdentifier = NSStringFromClass([self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil]);
        FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            Class cellClass = NSClassFromString(cellIdentifier);
            cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if(indexPath.row < self.dataList.count){
            [cell refreshWithData:cellModel];
        }
        cell.delegate = self;
        return cell;
    }
    return [[FHUGCBaseCell alloc] init];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
        if (!self.elementShowCaches[tempKey]) {
            self.elementShowCaches[tempKey] = @(YES);
            FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
            NSDictionary  *extraDic = self.tracerDic.mutableCopy;
            [extraDic setValue:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:@"rank"];
            [extraDic setValue:cellModel.logPb forKey:@"log_pb"];
            [self.tracerHelper trackFeedClientShow:self.dataList[indexPath.row] withExtraDic:extraDic];
        }
    }
}


#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001f)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        CGFloat contentHeight = 0;
        Class cellClass = [self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil];
        if([cellClass isSubclassOfClass:[FHUGCBaseCell class]]) {
            //图片高+user高 +bottomview 高度
            switch (cellModel.cellType) {
                case FHUGCFeedListCellTypeUGC:
                    contentHeight = cellModel.contentHeight  +75 + 30 + 50 + 75;
                    break;
                case FHUGCFeedListCellTypeUGCSmallVideo:
                    contentHeight = cellModel.contentHeight  +150 + 30 + 50 + 130;
                    break;
                default:
                    break;
            }
            return contentHeight;
        }
    }
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
    BOOL canOpenURL = NO;
    if (!canOpenURL && !isEmptyString(cellModel.openUrl)) {
        NSURL *url = [TTStringHelper URLWithURLString:cellModel.openUrl];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            canOpenURL = YES;
            [[UIApplication sharedApplication] openURL:url];
        }
        else if([[TTRoute sharedRoute] canOpenURL:url]){
            canOpenURL = YES;
            //优先跳转openurl
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
        }
    }else{
        NSURL *openUrl = [NSURL URLWithString:cellModel.detailScheme];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
    }
}

- (void)commentClicked:(FHFeedUGCCellModel *)cellModel cell:(nonnull FHUGCBaseCell *)cell {
    [self trackClickComment:cellModel];
    self.currentCellModel = cellModel;
    self.currentCell = cell;
    self.detailJumpManager.currentCell = self.currentCell;
    [self.detailJumpManager jumpToDetail:cellModel showComment:YES enterType:@"feed_comment"];
}

- (void)clickRealtorIm:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell {
    NSInteger index = [self.dataList indexOfObject:cellModel];
    NSMutableDictionary *imExtra = @{}.mutableCopy;
    imExtra[@"realtor_position"] = @"detail_related";
    [self.realtorPhoneCallModel imchatActionWithPhone:cellModel.realtor realtorRank:[NSString stringWithFormat:@"%ld",(long)index] extraDic:imExtra];
}

- (void)clickRealtorPhone:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell {
    NSMutableDictionary *extraDict = @{}.mutableCopy;
    extraDict[@"realtor_id"] = cellModel.realtor.realtorId;
    extraDict[@"realtor_rank"] = @"be_null";
    extraDict[@"realtor_logpb"] = cellModel.realtor.realtorLogpb;
    NSDictionary *associateInfoDict = cellModel.realtor.associateInfo.phoneInfo;
    extraDict[kFHAssociateInfo] = associateInfoDict;
    FHAssociatePhoneModel *associatePhone = [[FHAssociatePhoneModel alloc]init];
    associatePhone.reportParams = extraDict;
    associatePhone.associateInfo = associateInfoDict;
    associatePhone.realtorId = cellModel.realtor.realtorId;
    associatePhone.searchId = self.tracerDic[@"log_pb"][@"search_id"];
    associatePhone.imprId = self.tracerDic[@"log_pb"][@"impr_id"];
    associatePhone.houseType =self.houseType.integerValue;
    associatePhone.houseId = self.houseId;
    associatePhone.showLoading = NO;
    [self.realtorPhoneCallModel phoneChatActionWithAssociateModel:associatePhone];
}

- (void)lookAllLinkClicked:(FHFeedUGCCellModel *)cellModel cell:(nonnull FHUGCBaseCell *)cell {
    self.currentCellModel = cellModel;
    self.currentCell = cell;
    self.detailJumpManager.currentCell = self.currentCell;
    [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
}

- (void)clickRealtorHeader:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
     dict[@"element_from"] = @"old_detail_related";
     dict[@"enter_from"] = @"realtor_evaluate_list";
    [self.realtorPhoneCallModel jump2RealtorDetailWithPhone:cellModel.realtor isPreLoad:NO extra:dict];
}


- (void)trackClickComment:(FHFeedUGCCellModel *)cellModel {
    NSMutableDictionary *dict = [cellModel.tracerDic mutableCopy];
    dict[@"click_position"] = @"feed_comment";
    TRACK_EVENT(@"click_comment", dict);
}
@end
