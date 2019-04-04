//
//  FHPriceValuationHistoryViewModel.m
//  FHHouseTrend
//
//  Created by 谢思铭 on 2019/3/22.
//

#import "FHPriceValuationHistoryViewModel.h"
#import "FHPriceValuationHistoryCell.h"
#import <TTRoute.h>
#import "FHPriceValuationEvaluateModel.h"
#import "FHPriceValuationAPI.h"
#import "FHUserTracker.h"

#define kCellId @"FHPriceValuationHistoryCell_id"

@interface FHPriceValuationHistoryViewModel()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHPriceValuationHistoryController *viewController;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, strong) FHPriceValuationHistoryModel *model;

@end

@implementation FHPriceValuationHistoryViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHPriceValuationHistoryController *)viewController {
    self = [super init];
    if (self) {
        self.tableView = tableView;
        self.viewController = viewController;
        self.dataList = [NSMutableArray array];
        [tableView registerClass:[FHPriceValuationHistoryCell class] forCellReuseIdentifier:kCellId];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView reloadData];
    }
    return self;
}

- (void)requestData:(BOOL)isFirst {
    __weak typeof(self) wself = self;
    if(isFirst){
        [self.viewController startLoading];
    }
    [FHPriceValuationAPI requestHistoryListWithCompletion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        if(isFirst){
            [self.viewController endLoading];
        }
        FHPriceValuationHistoryModel *historyModel = (FHPriceValuationHistoryModel *)model;
        
        if (!wself) {
            return;
        }
        
        if (error) {
            //TODO: show handle error
            [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
            return;
        }
        
        [wself addEnterCategoryTracer];
        [wself.viewController.emptyView hideEmptyView];
        
        if(model){
            wself.model = historyModel;
            if(historyModel.data.historyHouseList.count > 0){
                wself.viewController.hasValidateData = YES;
                [wself.dataList removeAllObjects];
                [wself.dataList addObjectsFromArray:historyModel.data.historyHouseList];
                [wself.tableView reloadData];
            }else{
                [wself.viewController.emptyView showEmptyWithTip:@"暂无估价历史" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
            }
        }
    }];
}

- (NSString *)categoryName {
    return @"value_history_list";
}

- (void)addEnterCategoryTracer {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    
    NSMutableDictionary *tracer = [NSMutableDictionary dictionary];
    tracer[@"category_name"] = [self categoryName];
    tracer[@"enter_from"] = tracerDict[@"enter_from"] ? tracerDict[@"enter_from"] : @"be_null";
    tracer[@"enter_type"] = @"click";
    tracer[@"element_from"] = @"be_null";
    tracer[@"search_id"] = @"be_null";
    tracer[@"origin_from"] = tracerDict[@"origin_from"] ? tracerDict[@"origin_from"] : @"be_null";
    tracer[@"origin_search_id"] = tracerDict[@"origin_search_id"] ? tracerDict[@"origin_search_id"] : @"be_null";
    TRACK_EVENT(@"enter_category", tracer);
}

- (FHPriceValuationEvaluateModel *)covert:(FHPriceValuationHistoryDataHistoryHouseListModel *)model {
    FHPriceValuationEvaluateModel *eModel = [[FHPriceValuationEvaluateModel alloc] init];
    FHPriceValuationEvaluateDataModel *dataModel = [[FHPriceValuationEvaluateDataModel alloc] init];

    dataModel.estimateId = model.houseInfo.houseInfoDict.estimateId;
    dataModel.estimatePrice = model.houseInfo.estimatePriceInt;
    dataModel.estimatePriceRateStr = model.houseInfo.rateStr;
    dataModel.estimatePricingPersqmStr = model.houseInfo.averagePriceStr;
    
    eModel.data = dataModel;
    return eModel;
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHPriceValuationHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(indexPath.row < self.dataList.count){
        FHPriceValuationHistoryDataHistoryHouseListModel *listModel = self.dataList[indexPath.row];
        [cell updateCell:listModel];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 141.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    tracerDict[@"enter_from"] = [self categoryName];
    
    FHPriceValuationHistoryDataHistoryHouseListModel *listModel = self.dataList[indexPath.row];
    FHPriceValuationHistoryDataHistoryHouseListHouseInfoHouseInfoDictModel *infoModel = listModel.houseInfo.houseInfoDict;
    infoModel.neighborhoodName = listModel.houseInfo.neiborhoodNameStr;
    FHPriceValuationEvaluateModel *model = [self covert:listModel];
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"model"] = model;
    dict[@"infoModel"] = infoModel;
    dict[@"tracer"] = tracerDict;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL* url = [NSURL URLWithString:@"sslocal://price_valuation_result"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}



@end
