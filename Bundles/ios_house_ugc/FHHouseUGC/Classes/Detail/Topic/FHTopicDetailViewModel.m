//
//  FHTopicDetailViewModel.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/8/22.
//

#import "FHTopicDetailViewModel.h"
#import "FHHouseListAPI.h"
#import "FHUserTracker.h"
#import "FHUGCBaseCell.h"
#import "FHUGCReplyCell.h"
#import "FHHouseUGCAPI.h"
#import "FHTopicFeedListModel.h"
#import "FHUGCTopicRefreshHeader.h"
#import "FHRefreshCustomFooter.h"
#import "FHFeedUGCCellModel.h"

@interface FHTopicDetailViewModel ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , weak) FHTopicDetailViewController *detailController;
@property(nonatomic , weak) TTHttpTask *httpTopHeaderTask;
@property(nonatomic , weak) TTHttpTask *httpTopListTask;
@property (nonatomic, assign)   BOOL       canScroll;
@property (nonatomic, assign)   NSInteger       loadDataSuccessCount;
@property (nonatomic, strong)   NSMutableArray       *items;// FeedList数据，目前只有一个tab
@property (nonatomic, assign)   BOOL       hasFeedListData;// 第一次加载数据成功
@property (nonatomic, assign)   NSInteger       count;
@property (nonatomic, assign)   NSInteger       feedOffset;
@property (nonatomic, assign)   BOOL       hasMore;

@end

@implementation FHTopicDetailViewModel

-(instancetype)initWithController:(FHTopicDetailViewController *)viewController
{   self = [super init];
    if (self) {
        self.detailController = viewController;
        self.ugcCellManager = [[FHUGCCellManager alloc] init];
        self.canScroll = NO;
        self.hasFeedListData = NO;
        self.hasMore = NO;
        self.count = 20;// 每次20条
        self.feedOffset = 0;
        self.items = [[NSMutableArray alloc] init];
        self.hashTable = [NSHashTable weakObjectsHashTable];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"kFHUGCGoTop" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"kFHUGCLeaveTop" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startLoadData {
    self.loadDataSuccessCount = 0;// 网络接口返回计数
    [self loadHeaderData];
    [self loadFeedListData];
}

// 请求顶部的header
- (void)loadHeaderData {
    if (self.httpTopHeaderTask) {
        [self.httpTopHeaderTask cancel];
    }
    __weak typeof(self) wSelf = self;
    self.httpTopHeaderTask = [FHHouseUGCAPI requestTopicHeader:@"" completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        wSelf.loadDataSuccessCount += 1;
        if (error) {
            wSelf.headerModel = nil;
        } else {
            if ([model isKindOfClass:[FHTopicHeaderModel class]]) {
                wSelf.headerModel = model;
                [wSelf.detailController refreshHeaderData];
            }
        }
        [wSelf processLoadingState];
    }];
}

// 请求FeedList
- (void)loadFeedListData {
    if (self.httpTopListTask) {
        [self.httpTopListTask cancel];
    }
    self.detailController.isLoadingData = YES;
    self.feedOffset = 0;
    __weak typeof(self) wSelf = self;
    self.httpTopListTask = [FHHouseUGCAPI requestTopicList:@"" completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        wSelf.loadDataSuccessCount += 1;
        if (error) {
            if (wSelf.feedOffset == 0) {
                // 说明是第一次请求
            } else {
                // 上拉加载loadmore
            }
        } else {
            if ([model isKindOfClass:[FHTopicFeedListModel class]]) {
                wSelf.hasFeedListData = YES;
                FHTopicFeedListModel *feedList = (FHTopicFeedListModel *)model;
                if (wSelf.feedOffset == 0) {
                    // 说明是第一次请求
                    [wSelf.items removeAllObjects];
                } else {
                    // 上拉加载loadmore
                }
                // 数据转模型 添加数据
                [feedList.data enumerateObjectsUsingBlock:^(FHTopicFeedListDataModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[FHTopicFeedListDataModel class]]) {
                        FHFeedUGCCellModel *cellModel = [FHFeedUGCCellModel modelFromFeed:obj.content];
                        [wSelf.items addObject:cellModel];
                    }
                }];
        
                wSelf.hasMore = feedList.hasMore;
                wSelf.feedOffset = [feedList.offset integerValue];
            }
        }
        [wSelf processLoadingState];
    }];
}

// 刷新数据和状态
- (void)processLoadingState {
    if (self.loadDataSuccessCount >= 2) {
        [self.detailController endLoading];
        self.detailController.isLoadingData = NO;
        // 刷新数据
        if (self.headerModel && self.hasFeedListData && self.items.count > 0) {
            // 数据ok
            [self.detailController hiddenEmptyView];
            [self.detailController refreshHeaderData];
            [self.currentTableView reloadData];
            // hasMore
            FHRefreshCustomFooter *refreshFooter = (FHRefreshCustomFooter *)self.currentTableView.mj_footer;
            self.currentTableView.mj_footer.hidden = NO;
            if (self.hasMore == NO) {
                [refreshFooter setUpNoMoreDataText:@"没有更多信息了"];
                [refreshFooter endRefreshingWithNoMoreData];
            }else {
                [refreshFooter endRefreshing];
            }
        } else {
            [self.detailController showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        }
    }
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < self.items.count){
        FHFeedUGCCellModel *cellModel = self.items[indexPath.row];
        NSString *cellIdentifier = NSStringFromClass([self.ugcCellManager cellClassFromCellViewType:cellModel.cellSubType data:nil]);
        FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            Class cellClass = NSClassFromString(cellIdentifier);
            cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.delegate = self;
//        cellModel.tracerDic = [self trackDict:cellModel rank:indexPath.row];
        
        if(indexPath.row < self.items.count){
            [cell refreshWithData:cellModel];
        }
        return cell;
    }
    return [[FHUGCBaseCell alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
//    NSNumber *cellHeight = [NSNumber numberWithFloat:cell.frame.size.height];
//    self.cellHeightCaches[tempKey] = cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.items.count){
        FHFeedUGCCellModel *cellModel = self.items[indexPath.row];
        Class cellClass = [self.ugcCellManager cellClassFromCellViewType:cellModel.cellSubType data:nil];
        if([cellClass isSubclassOfClass:[FHUGCBaseCell class]]) {
            return [cellClass heightForData:cellModel];
        }
    }
    return 100;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    FHUGCBaseCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    if (cell.didClickCellBlk) {
//        cell.didClickCellBlk();
//    }
}
#pragma mark - UIScrollViewDelegate
//
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.canScroll) {
        [[self.hashTable allObjects] enumerateObjectsUsingBlock:^(UIScrollView*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setContentOffset:CGPointZero];
        }];
    }
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY<=0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHUGCLeaveTop" object:nil userInfo:@{@"canScroll":@"1"}];
    }
}

-(void)acceptMsg:(NSNotification *)notification{
    NSString *notificationName = notification.name;
    if ([notificationName isEqualToString:@"kFHUGCGoTop"]) {
        NSDictionary *userInfo = notification.userInfo;
        NSString *canScroll = userInfo[@"canScroll"];
        if ([canScroll isEqualToString:@"1"]) {
            self.canScroll = YES;
        }
    }else if([notificationName isEqualToString:@"kFHUGCLeaveTop"]){
        [[self.hashTable allObjects] enumerateObjectsUsingBlock:^(UIScrollView*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setContentOffset:CGPointZero];
        }];
        self.canScroll = NO;
    }
}

- (UITableView *)currentTableView {
    UITableView *ret = nil;
    NSInteger index = self.currentSelectIndex;
    NSArray *arr = [self.hashTable allObjects];
    if (index >= 0 && index < arr.count) {
        return arr[index];
    }
    return ret;
}

@end
