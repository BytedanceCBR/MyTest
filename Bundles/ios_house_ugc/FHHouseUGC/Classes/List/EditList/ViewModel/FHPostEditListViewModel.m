//
// FHPostEditListViewModel.m
//

#import "FHPostEditListViewModel.h"
#import "FHPostEditListController.h"
#import "TTHttpTask.h"
#import "FHHouseUGCAPI.h"
#import "MJRefreshConst.h"
#import "TTReachability.h"
#import "FHRefreshCustomFooter.h"
#import "ToastManager.h"
#import "UIScrollView+Refresh.h"
#import "FHUserTracker.h"
#import "FHUGCUserFollowModel.h"
#import "FHPostEditListModel.h"
#import "FHFeedContentModel.h"
#import "FHMainApi.h"
#import "FHBaseModelProtocol.h"
#import "FHPostDetailCell.h"

@interface FHPostEditListViewModel () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign)   NSInteger       offset;
@property (nonatomic, assign)   BOOL       hasMore;
@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic, weak) FHPostEditListController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) NSMutableArray *dataList;

@end

@implementation FHPostEditListViewModel

- (instancetype)initWithController:(FHPostEditListController *)viewController tableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.viewController = viewController;
        self.tableView = tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerClass:[FHPostDetailCell class] forCellReuseIdentifier:NSStringFromClass([FHPostDetailCell class])];
        self.offset = 0;
        self.hasMore = NO;
        self.dataList = [NSMutableArray array];
    }
    return self;
}

- (void)startLoadData {
    self.offset = 0;
    [self.dataList removeAllObjects];
    [self requestData:self.offset];
}

- (void)loadMore {
    self.offset = self.dataList.count;
    [self requestData:self.offset];
}

- (void)requestData:(NSInteger)offset {
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络不给力,请稍后重试"];
        self.viewController.isLoadingData = NO;
        [self.viewController endLoading];
        return;
    }
    self.viewController.isLoadingData = YES;
    if (self.requestTask) {
        [self.requestTask cancel];
    }
    if (self.offset == 0) {
        [self.viewController startLoading];
    }
    __weak typeof(self) weakSelf = self;
    self.requestTask = [FHHouseUGCAPI requestPostHistoryByGroupId:[NSString stringWithFormat:@"%ld",self.tid] offset:self.offset class:[FHUGCPostHistoryModel class] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        [weakSelf.viewController endLoading];
        weakSelf.viewController.isLoadingData = NO;
        if (model != NULL && error == NULL) {
            [weakSelf processDataWith:(FHUGCPostHistoryModel *)model];
        } else {
            [weakSelf processDataWith:nil];
        }
    }];
}

- (void)processDataWith:(FHUGCPostHistoryModel *)model {
    if (model && [model isKindOfClass:[FHUGCPostHistoryModel class]]) {
        // 有数据
        self.hasMore = model.hasMore;
        if (model.data.count > 0) {
            [model.data enumerateObjectsUsingBlock:^(FHUGCPostHistoryDataModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *dataStr = obj.content;
                NSError *jsonParseError;
                NSData *jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
                if (jsonData) {
                    Class cls = [FHFeedUGCContentModel class];
                    FHFeedUGCContentModel * model = (id<FHBaseModelProtocol>)[FHMainApi generateModel:jsonData class:[FHFeedUGCContentModel class] error:&jsonParseError];
                    if (model && !jsonParseError) {
                        // 网络请求返回
                        model.isFromDetail = YES;
                        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeedUGCContent:model];
                        cellModel.isFromDetail = YES;
                        cellModel.feedVC = nil;
                        cellModel.isStick = NO;
                        cellModel.stickStyle = FHFeedContentStickStyleUnknown;
                        cellModel.contentDecoration = nil;
                        cellModel.community = nil;
                        cellModel.tracerDic = [self.viewController.tracerDict copy];
                        [self.dataList addObject:cellModel];
                    }
                }
            }];
        }
    }
    // 后处理
    if (self.dataList.count > 0) {
        self.viewController.hasValidateData = YES;
        [self.viewController.emptyView hideEmptyView];
        self.tableView.hasMore = self.hasMore;
        [self updateTableViewWithMoreData:self.hasMore];
        [self.tableView reloadData];
    } else {
        self.viewController.hasValidateData = NO;
        // 显示空的关注页面-数据走丢了
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
    }
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableView.mj_footer.hidden = NO;
    if (hasMore == NO) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHPostDetailCell *cell = (FHPostDetailCell *) [tableView dequeueReusableCellWithIdentifier:@"FHPostDetailCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSInteger row = indexPath.row;
    if (row < self.dataList.count) {
        FHFeedUGCCellModel *data = self.dataList[row];
        [cell refreshWithData:data];
    }
    return cell;
}


@end
