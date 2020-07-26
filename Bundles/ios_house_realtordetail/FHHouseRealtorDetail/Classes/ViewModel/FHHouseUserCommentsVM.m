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
@property (nonatomic, strong) NSDictionary *realtorInfo;
@property (nonatomic, strong) NSDictionary *tracerDic;
@property (nonatomic, strong) NSMutableArray *showCommentCache;
@end
@implementation FHHouseUserCommentsVM
- (instancetype)initWithController:(FHHouseUserCommentsVC *)viewController tableView:(UITableView *)tableView tracerDic:(NSDictionary *)tracerDic realtorInfo:(NSDictionary *)realtorInfo {
        self = [super init];
        if (self) {
            self.detailController = viewController;
            self.tableView = tableView;
            self.realtorInfo = realtorInfo;
            self.tracerDic = tracerDic;
            [self addEnterCategoryLog];
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
    self.tableView.mj_footer.hidden = YES;
}
- (void)registerCellClasses {
        [self.tableView registerClass:[FHHouseUserCommentsCell class] forCellReuseIdentifier:@"FHHouseUserCommentsCell"];
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    if (![TTReachability isNetworkConnected]) {
        [self onNetworError:YES showToast:YES];
        return;
    }
    
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
    [requestDictonary setValue:self.realtorInfo[@"realtor_id"]?:@"" forKey:@"realtor_id"];
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
            self.detailController.emptyView.hidden = YES;
            [wself updateTableViewWithMoreData:model.data.hasMore];
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
        [self.refreshFooter setUpNoMoreDataText:@"- 我是有底线的哟 -" offsetY:0];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
}

-(void)onNetworError:(BOOL)showEmpty showToast:(BOOL)showToast{
    if(showEmpty){
        [self.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
    if(showToast){
        [[ToastManager manager] showToast:@"网络异常"];
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
     FHHouseRealtorUserCommentItemModel *item = self.dataList[indexPath.row];

    if (item.cellHeight) {
        return item.cellHeight;
    }
        return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
        FHHouseRealtorUserCommentItemModel *item = self.dataList[indexPath.row];
        [self addCommentShow:item];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //to do 房源cell
    NSString *identifier = @"FHHouseUserCommentsCell";
    FHHouseUserCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
      FHHouseRealtorUserCommentItemModel *item = self.dataList[indexPath.row];
    [cell refreshWithData:item];
    CGFloat cellHeight = [cell cellHeight];
    item.cellHeight = cellHeight;
    return cell;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        NSMutableArray *dataList = [[NSMutableArray alloc]init];
        _dataList = dataList;
    }
    return _dataList;
}

- (void)addEnterCategoryLog {
    NSMutableDictionary *tracerDict = self.tracerDic.mutableCopy;
    [tracerDict setObject:[self categoryName] forKey:@"category_name"];
    [tracerDict setObject:@"house_app2c_v2" forKey:@"event_type"];
    [tracerDict setObject:self.realtorInfo[@"realtor_id"] forKey:@"realtor_id"];
    TRACK_EVENT(@"enter_category", tracerDict);
}

- (NSString *)categoryName {
    return @"user_comment_list";
}

- (NSMutableArray *)showCommentCache {
    if (!_showCommentCache) {
        _showCommentCache = [NSMutableArray array];
    }
    return _showCommentCache;
}

- (void)addCommentShow:(FHHouseRealtorUserCommentItemModel *)item {
    if (!item.id) {
        return;
    }
        if ([self.showCommentCache containsObject:item.id]) {
            return;
        }
        
    [self.showCommentCache addObject:item.id];
        NSMutableDictionary *tracerDic = self.tracerDic.mutableCopy;
        [tracerDic setObject:[self categoryName] forKey:@"category_name"];
        [tracerDic setObject:@"house_app2c_v2" forKey:@"event_type"];
        [tracerDic setObject:self.realtorInfo[@"realtor_id"] forKey:@"realtor_id"];
        [tracerDic setObject:item.id forKey:@"comment_id"];
        TRACK_EVENT(@"user_comment_show", tracerDic);
}

@end
