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

@interface FHTopicDetailViewModel ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , weak) FHTopicDetailViewController *detailController;
@property(nonatomic , weak) TTHttpTask *httpTopHeaderTask;
@property(nonatomic , weak) TTHttpTask *httpTopListTask;
@property (nonatomic, assign)   BOOL       canScroll;
@property (nonatomic, assign)   NSInteger       loadDataSuccessCount;

@end

@implementation FHTopicDetailViewModel

-(instancetype)initWithController:(FHTopicDetailViewController *)viewController
{   self = [super init];
    if (self) {
        self.detailController = viewController;
        self.ugcCellManager = [[FHUGCCellManager alloc] init];
        self.canScroll = NO;
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
    self.loadDataSuccessCount = 0;// 网络返回计数
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
        [wSelf processLoadingState];
    }];
}

// 请求FeedList
- (void)loadFeedListData {
    if (self.httpTopListTask) {
        [self.httpTopListTask cancel];
    }
    __weak typeof(self) wSelf = self;
    self.httpTopListTask = [FHHouseUGCAPI requestTopicList:@"" completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        wSelf.loadDataSuccessCount += 1;
        [wSelf processLoadingState];
    }];
}

- (void)processLoadingState {
    if (self.loadDataSuccessCount >= 2) {
        [self.detailController endLoading];
        self.detailController.isLoadingData = NO;
        // 刷新数据
        // 。。。
    }
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSInteger row = indexPath.row;
//    if (row >= 0 && row < self.items.count) {
//        id data = self.items[row];
//        NSString *identifier = [self cellIdentifierForEntity:data];
//        if (identifier.length > 0) {
//            FHUGCBaseCell *cell = (FHUGCBaseCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
//            cell.baseViewModel = self;
//            [cell refreshWithData:data];
//            return cell;
//        }
//    }
    FHUGCBaseCell * cell = [[FHUGCBaseCell alloc] init];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
//    NSNumber *cellHeight = [NSNumber numberWithFloat:cell.frame.size.height];
//    self.cellHeightCaches[tempKey] = cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
//    NSNumber *cellHeight = self.cellHeightCaches[tempKey];
//    if (cellHeight) {
//        return [cellHeight floatValue];
//    }
//    return UITableViewAutomaticDimension;
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
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
//        [scrollView setContentOffset:CGPointZero];
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
//        self.weakScroolView.contentOffset = CGPointZero;
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
