//
//  FHHouseRealtorShopVM.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/17.
//

#import "FHHouseRealtorShopVM.h"
#import "TTHttpTask.h"
#import "UIViewAdditions.h"
#import "FHRefreshCustomFooter.h"
#import "FHEnvContext.h"
#import <FHHouseBase/FHSearchChannelTypes.h>
#import "FHMainApi.h"
#import "UIDevice+BTDAdditions.h"
#import "UIScrollView+Refresh.h"
#import "ToastManager.h"
#import "FHHouseBaseItemCell.h"
@interface FHHouseRealtorShopVM ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, weak)TTHttpTask *requestTask;
@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHHouseRealtorShopVC *detailController;
@property(nonatomic, strong)FHRefreshCustomFooter *refreshFooter;
@property(nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, assign) NSInteger lastOffset;
@property (nonatomic, strong) NSString *currentSearchId;
@property (nonatomic, assign) BOOL hasMore;
@end
@implementation FHHouseRealtorShopVM
- (instancetype)initWithController:(FHHouseRealtorShopVC *)viewController tableView:(UITableView *)tableView {
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
        self.detailController = viewController;
        self.tableView = tableView;
        //        self.tableView.backgroundColor = [UIColor themeGray7];
        [self configTableView];
//        [self requestData:YES first:YES];
    }
    return self;
}

- (void)configTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self registerCellClasses];
    __weak typeof(self) wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself requestData:NO first:NO];
    }];
    self.tableView.mj_footer = self.refreshFooter;
}

- (void)registerCellClasses {
        [self.tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:@"FHHomeSmallImageItemCell"];
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    if (self.requestTask) {
        [self.requestTask cancel];
        self.detailController.isLoadingData = NO;
    }
    if(self.detailController.isLoadingData){
        return;
    }
    self.detailController.isLoadingData = YES;
    
    if(isFirst){
        [self.detailController startLoading];
    }
    __weak typeof(self) wself = self;
    NSMutableDictionary *requestDictonary = [NSMutableDictionary new];
    [requestDictonary setValue:[FHEnvContext getCurrentSelectCityIdFromLocal] forKey:@"city_id"];
    NSInteger offsetValue = self.lastOffset;
    if (isFirst || isHead) {
        [requestDictonary setValue:@(0) forKey:@"offset"];
    }else
    {
        if(self.currentSearchId)
        {
            [requestDictonary setValue:self.currentSearchId forKey:@"search_id"];
        }
        [requestDictonary setValue:@(offsetValue) forKey:@"offset"];
        
    }
    [requestDictonary setValue:@(10) forKey:@"count"];
    [requestDictonary setValue:@"3021100461591229" forKey:@"realtor_id"];
    requestDictonary[CHANNEL_ID] = CHANNEL_ID_REALTOR_DETAIL_HOUSE;
    self.requestTask = nil;
    self.requestTask = [FHMainApi requestRealtorHomeRecommend:requestDictonary completion:^(FHHomeHouseModel * _Nonnull model, NSError * _Nonnull error) {
        wself.detailController.isLoadingData = NO;
        [wself.detailController endLoading];
        if (error) {
            //TODO: show handle error
            if(isFirst){
                if(error.code != -999){
                    wself.refreshFooter.hidden = YES;
                }
            }else{
                wself.refreshFooter.hidden = YES;
                [[ToastManager manager] showToast:@"网络异常"];
                [wself updateTableViewWithMoreData:YES];
            }
            [self.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
            return;
        }
        if (model.data.items.count > 0) {
            self.detailController.emptyView.hidden = YES;
            [wself updateTableViewWithMoreData:wself.tableView.hasMore];
            if (isFirst) {
                      self.dataList = [NSMutableArray arrayWithArray:model.data.items];
                      self.lastOffset = model.data.items.count;
            }else {
                [self.dataList addObjectsFromArray:model.data.items];
                self.lastOffset += model.data.items.count;
            }
            [self.tableView reloadData];
        }else {
            [self.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, view.width - 30, 28)];
    label.textColor = [UIColor themeGray1];
    label.font = [UIFont themeFontMedium:20];
    label.text = @"热卖房源(10)";
    [view addSubview:label];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 86;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //to do 房源cell
    NSString *identifier = @"FHHomeSmallImageItemCell";
    FHHouseBaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.delegate = self;
    if (indexPath.row < self.dataList.count) {
        JSONModel *model = self.dataList[indexPath.row];
        [cell refreshTopMargin:([UIDevice btd_isIPhoneXSeries]) ? 4 : 0];
        [cell updateHomeSmallImageHouseCellModel:model andType:FHHouseTypeSecondHandHouse];
        [cell hiddenCloseBtn];
    }
    [cell refreshIndexCorner:(indexPath.row == 0) withLast:(indexPath.row == (self.dataList.count - 1))];
    [cell.contentView setBackgroundColor:[UIColor themeHomeColor]];
    return cell;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        NSMutableArray *dataList = [[NSMutableArray alloc]init];
        _dataList = dataList;
    }
    return _dataList;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataList.count>indexPath.row) {
        [self jumpToDetailPage:indexPath];
    }
}
#pragma mark - 详情页跳转
-(void)jumpToDetailPage:(NSIndexPath *)indexPath {
    if (self.dataList.count > indexPath.row) {
        FHHomeHouseDataItemsModel *theModel = self.dataList[indexPath.row];
        
        NSMutableDictionary *traceParam = [NSMutableDictionary new];
//        traceParam[@"enter_from"] = [self pageTypeString];
//        traceParam[@"log_pb"] = theModel.logPb;
//        traceParam[@"origin_from"] = [self pageTypeString];
//        traceParam[@"card_type"] = @"left_pic";
//        traceParam[@"rank"] = [self getRankFromHouseId:theModel.idx indexPath:indexPath];
//        traceParam[@"origin_search_id"] = self.originSearchId ? : @"be_null";
//        traceParam[@"element_from"] = @"maintab_list";
//        traceParam[@"enter_from"] = @"maintab";
        
                
        NSMutableDictionary *dict = @{@"house_type":@(2),
                               @"tracer": traceParam
                               }.mutableCopy;
//        dict[INSTANT_DATA_KEY] = theModel;
        dict[@"biz_trace"] = theModel.bizTrace;
        NSURL *jumpUrl = nil;
            jumpUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",theModel.idx]];
        
        if (jumpUrl != nil) {
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            [[TTRoute sharedRoute] openURLByPushViewController:jumpUrl userInfo:userInfo];
        }
    }
}
@end
