//
//  FHHouseRealtorDetailRgcCollectionCell.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/14.
//

#import "FHHouseRealtorDetailRgcCollectionCell.h"
#import "FHFeedUGCCellModel.h"
#import "FHUGCBaseCell.h"
#import "FHUGCCellManager.h"
#import "FHEnvContext.h"
#import "FHHouseUGCAPI.h"
#import "FHHouseRealtorDetailStatusModel.h"

#import "TTHttpTask.h"

#import "FHFeedListModel.h"
@interface FHHouseRealtorDetailRgcCollectionCell()<UITableViewDelegate,UITableViewDataSource,FHUGCBaseCellDelegate>
@property (nonatomic , strong) NSMutableArray *dataList;
@property (nonatomic , strong) UITableView *mainTab;
@property (nonatomic , strong) FHUGCCellManager *cellManager;
@property (copy, nonatomic) NSString *houseType;
@property (copy, nonatomic) NSString *houseId;
@property(nonatomic, copy)NSString *categoryId;
@property(nonatomic, strong) FHFeedListModel *feedListModel;
@end
@implementation FHHouseRealtorDetailRgcCollectionCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setupUI {
    [self.mainTab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(0);
        make.bottom.equalTo(self.contentView);
    }];
    self.cellManager = [[FHUGCCellManager alloc] init];
    [self.cellManager registerAllCell:self.mainTab];
    
}

- (UITableView *)mainTab {
    if (!_mainTab) {
        UITableView *mainTab = [[UITableView alloc]init];
        mainTab.layer.masksToBounds = YES;
        mainTab.delegate = self;
        mainTab.dataSource = self;
        //        mainTab.bounces = NO;
        //        mainTab.scrollEnabled = NO;
        mainTab.separatorStyle = UITableViewCellSeparatorStyleNone;
        mainTab.backgroundColor = [UIColor clearColor];
        mainTab.sectionFooterHeight = 0.0;
        mainTab.estimatedRowHeight = 0;
        if (@available(iOS 11.0 , *)) {
            mainTab.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            mainTab.estimatedRowHeight = 0;
            mainTab.estimatedSectionFooterHeight = 0;
            mainTab.estimatedSectionHeaderHeight = 0;
        }
        [self.contentView addSubview:mainTab];
        _mainTab = mainTab;
    }
    return _mainTab;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHHouseRealtorDetailRgcCollectionModel class]]) {
        return;
    }
    self.currentData = data;
    FHHouseRealtorDetailRgcCollectionModel *model = (FHHouseRealtorDetailRgcCollectionModel *)data;
    [self requestData:YES first:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
        self.mainTab.bounces = scrollView.contentOffset.y >0;
    
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    //    if (self.requestTask) {
    //        [self.requestTask cancel];
    //        self.listController.isLoadingData = NO;
    //    }
    //
    //    if(self.listController.isLoadingData){
    //        return;
    //    }
    NSString *refreshType = @"be_null";
    //    self.listController.isLoadingData = YES;
    
    //    if(isFirst){
    //        [self.listController startLoading];
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
    //    if (self.houseId) {
    //        [extraDic setObject:self.houseId forKey:@"house_id"];
    [extraDic setObject:@"6759777706138665224" forKey:@"house_id"];
    //    }
    //    if (self.houseType) {
    //         [extraDic setObject:self.houseType forKey:@"house_type"];
    [extraDic setObject:@"2" forKey:@"house_type"];
    //    }
    //    if (self.evaluationHeader.selectName) {
    [extraDic setObject:@"video" forKey:@"tab_name"];
    //         [extraDic setObject:self.evaluationHeader.selectName forKey:@"tab_name"];
    //    }
    TTHttpTask *task = [FHHouseUGCAPI requestFeedListWithCategory:self.categoryId behotTime:behotTime loadMore:!isHead listCount:listCount extraDic:extraDic completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        //        wself.listController.isLoadingData = NO;
        FHFeedListModel *feedListModel = (FHFeedListModel *)model;
        wself.feedListModel = feedListModel;
        //        if (!wself) {
        //            if(isFirst){
        //                [wself.listController endLoading];
        //            }
        //            return;
        //        }
        if (error) {
            //TODO: show handle error
            if(isFirst){
                //                [wself.listController endLoading];
                if(error.code != -999){
                    //                    [wself.listController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
                    //                    wself.listController.showenRetryButton = YES;
                    //                    wself.refreshFooter.hidden = YES;
                    [FHHouseRealtorDetailStatusModel sharedInstance].currentRealtorDetailStatus.isHiddenFooterRefish = YES;
                    [FHHouseRealtorDetailStatusModel sharedInstance].currentRealtorDetailStatus.hasMore = NO;
                }
            }else{
                [FHHouseRealtorDetailStatusModel sharedInstance].currentRealtorDetailStatus.isHiddenFooterRefish = YES;
                [FHHouseRealtorDetailStatusModel sharedInstance].currentRealtorDetailStatus.hasMore = NO;
                
                //                [wself.listController.emptyView showEmptyWithTip:@"网络异常，请检查网络连接" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
                //                     wself.refreshFooter.hidden = YES;
                [[ToastManager manager] showToast:@"网络异常"];
                //                [wself updateTableViewWithMoreData:YES];
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
                [self computedAltitude];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(!isHead){
                        [FHHouseRealtorDetailStatusModel sharedInstance].currentRealtorDetailStatus.hasMore  = feedListModel.hasMore;
                    }
                    //                    wself.listController.hasValidateData = wself.dataList.count > 0;
                    if(wself.dataList.count > 0){
                        //                        [wself updateTableViewWithMoreData:wself.mainTab.hasMore];
                        //                        [wself.listController.emptyView hideEmptyView];
                    }else{
                        [FHHouseRealtorDetailStatusModel sharedInstance].currentRealtorDetailStatus.isHiddenFooterRefish = YES;
                        //                        [wself.listController.emptyView showEmptyWithTip:@"暂无内容" errorImageName:kFHErrorMaskNoDataImageName showRetry:NO];
                        //                        wself.refreshFooter.hidden = YES;
                    }
                    if (self.cellRefreshComplete) {
                        self.cellRefreshComplete();
                    }
                    [wself.mainTab reloadData];
                });
            });
        }
    }];
    //    self.requestTask = task;
}



- (NSArray *)convertModel:(NSArray *)feedList{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    CGFloat contentHeight = 60;
    for (FHFeedListDataModel *itemModel in feedList) {
        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:itemModel.content];
        cellModel.isInRealtorEvaluationList = YES;
        cellModel.categoryId = self.categoryId;
        cellModel.tableView = self.mainTab;
        //        cellModel.enterFrom = [self.listController categoryName];
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
    NSMutableArray *statusArr =  [FHHouseRealtorDetailStatusModel sharedInstance].statusArray.mutableCopy;
    FHHouseRealtorDetailStatus *status = statusArr[self.selfIndex];
    status.cellHeight = contentHeight;
    return resultArray;
}

- (void)computedAltitude {
    NSMutableArray *resultArray = self.dataList;
    CGFloat contentHeight = 60;
    for (FHFeedUGCCellModel *cellModel in resultArray) {
        switch (cellModel.cellType) {
            case FHUGCFeedListCellTypeUGC:
                contentHeight = cellModel.contentHeight  + (cellModel.imageList.count == 0?0:75 + 30) + 40 +contentHeight + 40;
                break;
            case FHUGCFeedListCellTypeUGCSmallVideo:
                contentHeight = cellModel.contentHeight  +150 + 10 + 40 +contentHeight + 90;
                break;
            default:
                break;
        }
    }
    NSMutableArray *statusArr =  [FHHouseRealtorDetailStatusModel sharedInstance].statusArray.mutableCopy;
    FHHouseRealtorDetailStatus *status = statusArr[self.selfIndex];
    status.cellHeight = contentHeight;
    NSMutableArray *heightArr = [[NSMutableArray alloc]init];
    for (FHHouseRealtorDetailStatus *status in statusArr) {
        [heightArr addObject:@(status.cellHeight)];
    }
    CGFloat maxValue = [[heightArr valueForKeyPath:@"@max.floatValue"] floatValue];
    //    if (contentHeight >maxValue ) {
    //
    //    }
    //    if (maxValue > [UIScreen mainScreen].bounds.size.height) {
    //
    //    }
    for (FHHouseRealtorDetailStatus *status in statusArr) {
        if (status.cellHeight < [UIScreen mainScreen].bounds.size.height) {
            if (maxValue >  [UIScreen mainScreen].bounds.size.height) {
                status.cellHeight = [UIScreen mainScreen].bounds.size.height;
            }else {
                status.cellHeight = maxValue;
            }
        }
    }
    
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        NSString *cellIdentifier = NSStringFromClass([self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil]);
        FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            Class cellClass = NSClassFromString(cellIdentifier);
            cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        if(indexPath.row < self.dataList.count){
            [cell refreshWithData:cellModel];
        }
        return cell;
    }
    return [[FHUGCBaseCell alloc] init];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        Class cellClass = [self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil];
        if([cellClass isSubclassOfClass:[FHUGCBaseCell class]]) {
            return [cellClass heightForData:cellModel];
        }
    }
    return 100;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        NSMutableArray *dataList = [[NSMutableArray alloc]init];
        _dataList = dataList;
    }
    return _dataList;
}
@end
@implementation FHHouseRealtorDetailRgcCollectionModel
@end
