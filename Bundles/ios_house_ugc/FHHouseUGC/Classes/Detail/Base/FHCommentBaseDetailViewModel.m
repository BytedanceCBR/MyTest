//
//  FHCommentDetailViewModel.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/3.
//

#import "FHCommentBaseDetailViewModel.h"
#import "FHHouseUGCAPI.h"
#import "TTHttpTask.h"
#import "FHPostDetailViewModel.h"
#import "FHVoteDetailViewModel.h"
#import "FHUGCVoteDetailCell.h"

@interface FHCommentBaseDetailViewModel ()<UITableViewDelegate,UITableViewDataSource,FHUGCBaseCellDelegate>

@property (nonatomic, strong)   NSMutableDictionary       *cellHeightCaches;

@end

@implementation FHCommentBaseDetailViewModel

+(instancetype)createDetailViewModelWithPostType:(FHUGCPostType)postType withController:(FHCommentBaseDetailViewController *)viewController tableView:(UITableView *)tableView {
    FHCommentBaseDetailViewModel *viewModel = NULL;
    switch (postType) {
        case FHUGCPostTypePost:
            // 帖子
            viewModel = [[FHPostDetailViewModel alloc] initWithController:viewController tableView:tableView postType:postType];
        case FHUGCPostTypeWenDa:
            // 暂无
            break;
        case FHUGCPostTypeVote:
            // 投票
            viewModel = [[FHVoteDetailViewModel alloc] initWithController:viewController tableView:tableView postType:postType];
            break;
    }
    return viewModel;
}

-(instancetype)initWithController:(FHCommentBaseDetailViewController *)viewController tableView:(UITableView *)tableView postType:(FHUGCPostType)postType{
    self = [super init];
    if (self) {
        _cellHeightCaches = [NSMutableDictionary new];
        _items = [NSMutableArray new];
        self.postType = postType;
        self.detailController = viewController;
        self.tableView = tableView;
        [self configTableView];
    }
    return self;
}

-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self registerCellClasses];
}

#pragma mark - 需要子类实现的方法

// 注册cell类型
- (void)registerCellClasses {
    // sub implements.........
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}
// cell class
- (Class)cellClassForEntity:(id)model {
    // sub implements.........
    // Donothing
    return [FHUGCBaseCell class];
}
// cell identifier
- (NSString *)cellIdentifierForEntity:(id)model {
    // sub implements.........
    // Donothing
    return @"";
}
// 网络数据请求
- (void)startLoadData {
    // sub implements.........
    // Donothing
}

// 刷新数据
- (void)reloadData {
    [self.tableView reloadData];
}

// 清空高度缓存
- (void)clearCacheHeight {
    [self.cellHeightCaches removeAllObjects];
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
    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.items.count) {
        id data = self.items[row];
        NSString *identifier = [self cellIdentifierForEntity:data];
        if (identifier.length > 0) {
            FHUGCBaseCell *cell = (FHUGCBaseCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            cell.delegate = self;
            cell.isFromDetail = YES;
            cell.baseViewModel = self;
            if ([data isKindOfClass:[FHFeedUGCCellModel class]]) {
                FHFeedUGCCellModel *cellModel = data;
                cellModel.tracerDic = [self.detailController.tracerDict copy];
            }
            [cell refreshWithData:data];
            return cell;
        }
    }
    return [[FHUGCBaseCell alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
    NSNumber *cellHeight = [NSNumber numberWithFloat:cell.frame.size.height];
    self.cellHeightCaches[tempKey] = cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
    NSNumber *cellHeight = self.cellHeightCaches[tempKey];
    if (cellHeight) {
        return [cellHeight floatValue];
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 投票cell FHUGCVoteDetailCell 行高
    if (self.postType == FHUGCPostTypeVote) {
        // 投票
        NSInteger row = indexPath.row;
        if (row >= 0 && row < self.items.count) {
            id data = self.items[row];
            if ([data isKindOfClass:[FHFeedUGCCellModel class]]) {
                return [FHUGCVoteDetailCell heightForData:data];
            }
        }
    }
    return UITableViewAutomaticDimension;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FHUGCBaseCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.didClickCellBlk) {
        cell.didClickCellBlk();
    }
}

@end
