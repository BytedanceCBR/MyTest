//
//  FHHouseUserCommentsVM.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/17.
//

#import "FHHouseUserCommentsVM.h"
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
#import "FHHouseUserCommentsCell.h"
@interface FHHouseUserCommentsVM()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, weak)TTHttpTask *requestTask;
@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHHouseUserCommentsVC *detailController;
@property(nonatomic, strong)FHRefreshCustomFooter *refreshFooter;
@property(nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, assign) NSInteger lastOffset;
@property (nonatomic, strong) NSString *currentSearchId;
@end
@implementation FHHouseUserCommentsVM
- (instancetype)initWithController:(FHHouseUserCommentsVC *)viewController tableView:(UITableView *)tableView {
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
            [self requestData:YES first:YES];
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
        [self.tableView registerClass:[FHHouseUserCommentsCell class] forCellReuseIdentifier:@"FHHouseUserCommentsCell"];
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
    self.requestTask = [FHMainApi requestRealtorUserCommon:requestDictonary completion:^(FHHouseRealtorUserCommentDataModel * _Nonnull model, NSError * _Nonnull error) {
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
        if (model.data.commentInfo.count > 0) {
            [wself updateTableViewWithMoreData:wself.tableView.hasMore];
                [self.dataList addObjectsFromArray:model.data.commentInfo];
                self.lastOffset = model.data.offset;
            [self.tableView reloadData];
        }else {
            
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //to do 房源cell
    NSString *identifier = @"FHHouseUserCommentsCell";
    FHHouseUserCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell refreshWithData:self.dataList[indexPath.row]];
    return cell;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        NSMutableArray *dataList = [[NSMutableArray alloc]init];
        _dataList = dataList;
    }
    return _dataList;
}

@end
