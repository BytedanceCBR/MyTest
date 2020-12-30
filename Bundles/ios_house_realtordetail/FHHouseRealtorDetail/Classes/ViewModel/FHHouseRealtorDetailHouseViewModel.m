//
//  FHHouseRealtorDetailHouseViewModel.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/16.
//

#import "FHHouseRealtorDetailHouseViewModel.h"
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
#import "FHHouseRealtorDetailPlaceCell.h"
#import "FHRealtorSecondCell.h"
#import "FHPlaceHolderCell.h"

@interface FHHouseRealtorDetailHouseViewModel ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, weak)TTHttpTask *requestTask;
@property(nonatomic,strong)NSDictionary *tracerDic;
@property(nonatomic, strong)FHRefreshCustomFooter *refreshFooter;
@property (nonatomic, strong) NSMutableArray *showHouseCache;
@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHHouseRealtorDetailHouseVC *detailController;
@property(nonatomic, strong) FHErrorView *errorView;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic , assign) BOOL showPlaceHolder;
@property (nonatomic, assign) NSInteger lastOffset;
@property (nonatomic, strong) NSString *currentSearchId;
@property (nonatomic, assign) BOOL hasMore;
@property(strong, strong)NSDictionary *realtorInfo ;
@end
@implementation FHHouseRealtorDetailHouseViewModel
- (instancetype)initWithController:(FHHouseRealtorDetailHouseVC *)viewController tableView:(UITableView *)tableView realtorInfo:(NSDictionary *)realtorInfo tracerDic:(NSDictionary *)tracerDic {
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
        self.showPlaceHolder = YES;
        self.tableView = tableView;
        self.realtorInfo = realtorInfo;
        //        self.tableView.backgroundColor = [UIColor themeGray7];
        [self configTableView];

    }
    return self;
}

- (void)configTableView {
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self registerCellClasses];
    __weak typeof(self) wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself requestData:NO first:NO];
    }];
    self.tableView.mj_footer = self.refreshFooter;
    self.tableView.mj_footer.hidden = YES;
}

- (void)registerCellClasses {
    [self.tableView registerClass:[FHHouseRealtorDetailPlaceCell class] forCellReuseIdentifier:@"FHHouseRealtorDetailPlaceCell"];
    [self.tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:@"FHHomeSmallImageItemCell"];
    [self.tableView registerClass:[FHRealtorSecondCell class] forCellReuseIdentifier:NSStringFromClass([FHRealtorSecondCell class])];
    [self.tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:@"FHPlaceHolderCell"];
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    if (self.requestTask) {
        [self.requestTask cancel];
        self.detailController.isLoadingData = NO;
    }
    
    if (![TTReachability isNetworkConnected]) {
        [self showErrorViewNoNetWork];
        self.showPlaceHolder = NO;
        [self.tableView reloadData];
        self.tableView.scrollEnabled = YES;
        return;
    }

    if(self.detailController.isLoadingData){
        return;
    }
    self.detailController.isLoadingData = YES;
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
    [requestDictonary setValue:self.realtorInfo[@"realtor_id"] forKey:@"realtor_id"];
    requestDictonary[CHANNEL_ID] = CHANNEL_ID_REALTOR_DETAIL_HOUSE;
    self.requestTask = nil;
    self.requestTask = [FHMainApi requestRealtorHomeRecommend:requestDictonary completion:^(FHHomeHouseModel * _Nonnull model, NSError * _Nonnull error) {
        wself.detailController.isLoadingData = NO;
        if (error) {
            //TODO: show handle error
            if(isFirst){
                if(error.code != -999){
                     [wself updateTableViewWithMoreData:YES];
                }
            }else{
                [[ToastManager manager] showToast:@"网络异常"];
                [wself updateTableViewWithMoreData:YES];
            }
            self.showPlaceHolder = NO;
            [self reloadTableViewData];
            return;
        }
        if (model.data.items.count > 0) {
            [wself updateTableViewWithMoreData:model.data.hasMore];
            if (isFirst) {
                      self.dataList = [NSMutableArray arrayWithArray:model.data.items];
                      self.lastOffset = model.data.items.count;
            }else {
                [self.dataList addObjectsFromArray:model.data.items];
                self.lastOffset += model.data.items.count;
            }
        }
        self.showPlaceHolder = NO;
        [self reloadTableViewData];
    }];
}

- (void)showErrorViewNoNetWork {
    [self.errorView showEmptyWithTip:@"网络异常" errorImageName:kFHErrorMaskNoNetWorkImageName showRetry:YES];
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.detailController.errorViewHeight)];
      tableFooterView.backgroundColor = [UIColor clearColor];
    [tableFooterView addSubview:self.errorView];
    self.tableView.tableFooterView = tableFooterView;
    self.refreshFooter.hidden = YES;
    [self.tableView reloadData];
}

- (CGFloat)getVisibleHeight:(NSInteger)maxCount {
    CGFloat height = 0;
    if(self.dataList.count <= maxCount){
        height = 86 *maxCount;
    }
    return height;
}


- (void)reloadTableViewData {
    self.tableView.scrollEnabled = YES;
    if(self.dataList.count > 0){
//        [self updateTableViewWithMoreData:self.tableView.hasMore];
        self.tableView.backgroundColor = [UIColor themeGray7];
        
        CGFloat height = [self getVisibleHeight:10];
        if(height < self.detailController.errorViewHeight && height > 0 && self.detailController.errorViewHeight > 0){
            [self.tableView reloadData];
            CGFloat refreshFooterBottomHeight = self.tableView.mj_footer.height;
            if ([UIDevice btd_isIPhoneXSeries]) {
                refreshFooterBottomHeight += 34;
            }
            //设置footer来占位
            UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.detailController.errorViewHeight - height - refreshFooterBottomHeight)];
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
          tableFooterView.backgroundColor = [UIColor clearColor];
        [tableFooterView addSubview:self.errorView];
        self.tableView.tableFooterView = tableFooterView;
        self.refreshFooter.hidden = YES;
        [self.tableView reloadData];
    }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.showPlaceHolder) {
        return 10;
    }
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.showPlaceHolder) {
        return 88;
    }else {
        return 86;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.showPlaceHolder) {
        NSString *identifier = @"FHPlaceHolderCell";
        FHPlaceHolderCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        [cell.contentView setBackgroundColor:[UIColor colorWithHexStr:@"#f8f8f8"]];
        return cell;
    }
        if ([FHEnvContext isDisplayNewCardType]) {
            NSString *identifier = NSStringFromClass([FHRealtorSecondCell class]);
            FHHouseBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (indexPath.row < self.dataList.count) {
                JSONModel *model = self.dataList[indexPath.row];
                [cell refreshWithData:model];
                [cell refreshIndexCorner:(indexPath.row == 0) andLast:(indexPath.row == self.dataList.count)];
            }
            return cell;
        }
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
        [cell refreshIndexCorner:(indexPath.row == 0) withLast:(indexPath.row == (self.dataList.count))];
        [cell.contentView setBackgroundColor:[UIColor colorWithHexStr:@"#f8f8f8"]];
        return cell;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        NSMutableArray *dataList = [[NSMutableArray alloc]init];
        _dataList = dataList;
    }
    return _dataList;
}

- (FHErrorView *)errorView {
    if(!_errorView){
        __weak typeof(self)ws = self;
        _errorView = [[FHErrorView alloc] initWithFrame:CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width, 500)];
        _errorView.backgroundColor = [UIColor colorWithHexStr:@"f8f8f8"];
        _errorView.retryBlock = ^{
            [ws requestData:YES first:YES];
        };
    }
    return _errorView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *index = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    [self jumpToDetailPage:index];
}
#pragma mark - 详情页跳转
-(void)jumpToDetailPage:(NSIndexPath *)indexPath {
    if (self.dataList.count > indexPath.row) {
        FHHomeHouseDataItemsModel *theModel = self.dataList[indexPath.row];
        
        NSMutableDictionary *traceParam = [NSMutableDictionary new];
        [traceParam addEntriesFromDictionary:self.tracerDic];
        [traceParam setObject:traceParam[@"page_type"] forKey:@"enter_from"];
        NSMutableDictionary *dict = @{@"house_type":@(2),
                               @"tracer": traceParam
                               }.mutableCopy;
//        dict[INSTANT_DATA_KEY] = theModel;
        dict[@"biz_trace"] = theModel.bizTrace;
        NSURL *jumpUrl = nil;
        jumpUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@&realtor_id=%@",theModel.idx,self.realtorInfo[@"realtor_id"]?:@""]];
        
        if (jumpUrl != nil) {
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            [[TTRoute sharedRoute] openURLByPushViewController:jumpUrl userInfo:userInfo];
        }
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[FHHouseBaseItemCell class]]) {
        FHHomeHouseDataItemsModel *model = self.dataList[indexPath.row -1];
        [self addHouseShow:model ];
    }
}

- (NSMutableArray *)showHouseCache {
    if (!_showHouseCache) {
        _showHouseCache = [NSMutableArray array];
    }
    return _showHouseCache;
}

- (void)addHouseShow:(FHHomeHouseDataItemsModel *)model {
    if (!model.id) {
        return;
    }
    if ([self.showHouseCache containsObject:model.id]) {
        return;
    }
    [self.showHouseCache addObject:model.id];
    NSMutableDictionary *tracerDic = self.tracerDic.mutableCopy;
    tracerDic[@"house_type"] = @"old";
    tracerDic[@"log_pb"] = model.logPb?:@"be_null";
    tracerDic[@"group_id"] = model.id;
    TRACK_EVENT(@"house_show", tracerDic);
}
@end
