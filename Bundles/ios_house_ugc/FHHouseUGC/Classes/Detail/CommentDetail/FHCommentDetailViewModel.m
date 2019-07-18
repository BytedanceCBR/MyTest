//
//  FHCommentDetailViewModel.m
//  Pods
//
//  Created by 张元科 on 2019/7/16.
//

#import "FHCommentDetailViewModel.h"
#import "FHHouseListAPI.h"
#import "FHSugSubscribeItemCell.h"
#import "FHCommentDetailViewController.h"
#import "FHUserTracker.h"
#import "FHUGCBaseCell.h"
#import "FHUGCReplyCell.h"
#import "FHHouseUGCAPI.h"
#import "FHDetailReplyCommentModel.h"
#import "TTCommentDetailCell.h"
#import "UIView+TTFFrame.h"
#import "FHRefreshCustomFooter.h"
#import "FHDetailCommentAllFooter.h"
#import "FHUGCReplyListEmptyView.h"
#import "TTCommentDetailModel.h"

@interface FHCommentDetailViewModel ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHCommentDetailViewController *detailVC;
@property(nonatomic , weak) TTHttpTask *httpTask;
@property(nonatomic , weak) TTHttpTask *httpListTask;
@property (nonatomic, strong)   FHRefreshCustomFooter       *refreshFooter;
@property (nonatomic, assign)   NSInteger       offset;
@property (nonatomic, assign)   NSInteger       count;
@property (nonatomic, assign)   BOOL       hasMore;
@property (nonatomic, strong)   FHDetailCommentAllFooter       *commentAllFooter;
@property (nonatomic, strong)   FHUGCReplyListEmptyView       *replayListEmptyView;

// 评论回复列表数据源
@property (nonatomic, strong) NSMutableArray<TTCommentDetailReplyCommentModel *> *totalComments;//dataSource
@property (nonatomic, strong) NSMutableArray<TTCommentDetailCellLayout *>  *totalCommentLayouts;

@end

@implementation FHCommentDetailViewModel

-(instancetype)initWithController:(FHCommentDetailViewController *)viewController tableView:(UITableView *)tableView
{   self = [super init];
    if (self) {
        self.detailVC = viewController;
        self.tableView = tableView;
        self.offset = 0;
        self.count = 20;
        self.comment_count = 0;
        self.user_digg = 0;
        self.digg_count = 0;
        self.hasMore = NO;
        self.totalComments = [NSMutableArray new];
        self.totalCommentLayouts = [NSMutableArray new];
        [self configTableView];
        [self commentCountChanged];
    }
    return self;
}

-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    __weak typeof(self) wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself loadMore];
    }];
    self.tableView.mj_footer = _refreshFooter;
    [_refreshFooter setUpNoMoreDataText:@" " offsetY:-3];
    _refreshFooter.hidden = YES;
    
    [_tableView registerClass:[TTCommentDetailCell class] forCellReuseIdentifier:NSStringFromClass([TTCommentDetailReplyCommentModel class])];
}

- (void)startLoadData {
    self.offset = 0;
    self.commentDetailModel = nil;
    [self.totalComments removeAllObjects];
    [self.totalCommentLayouts removeAllObjects];
    // 请求评论详情
    [self requestCommentDetailData];
}

// 请求评论详情数据
- (void)requestCommentDetailData {
    if (self.httpTask) {
        [self.httpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.httpTask = [FHHouseUGCAPI requestCommentDetailDataWithCommentId:self.comment_id class:[FHUGCCommentDetailModel class] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        [wself processQueryData:model error:error];
    }];
}

// 处理网络数据返回，详情返回直接展示
- (void)processQueryData:(FHUGCCommentDetailModel *)model error:(NSError *)error {
    if (model != NULL) {
        // 有详情数据
        self.tableView.hidden = NO;
        [self.detailVC.emptyView hideEmptyView];
        self.detailVC.hasValidateData = YES;
        // 详情data
        if (model.data && [model.data isKindOfClass:[NSDictionary class]]) {
            TTCommentDetailModel *dModel = [[TTCommentDetailModel alloc] initWithDictionary:model.data error:nil];
            self.commentDetailModel = dModel;
        }
        // 请求回复列表
        [self requestReplyListData];
    } else {
        self.detailVC.hasValidateData = NO;
        self.tableView.hidden = YES;
        [self.detailVC.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
    }
}

- (void)loadMore {
    if (self.hasMore) {
        [self requestReplyListData];
    }
}

// 请求回复列表数据，返回后直接处理回复列表是否展示和刷新就好
- (void)requestReplyListData {
    if (self.httpListTask) {
        [self.httpListTask cancel];
    }
    __weak typeof(self) wself = self;
    self.httpListTask = [FHHouseUGCAPI requestReplyListWithCommentId:self.comment_id offset:self.offset class:[FHDetailReplyCommentModel class] completion:^(id<FHBaseModelProtocol> _Nonnull model, NSError * _Nonnull error) {
        [wself processReplyListData:model error:error];
    }];
}

- (void)processReplyListData:(FHDetailReplyCommentModel *)model error:(NSError *)error {
    if (model) {
        if (model.data.allCommentModels.count > 0) {
            // 转化
            NSArray *layouts = [TTCommentDetailCellLayout arrayOfLayoutsFromModels:model.data.allCommentModels containViewWidth:self.detailVC.view.width];
            if (layouts.count > 0) {
                // 布局
                [self.totalComments addObjectsFromArray:model.data.allCommentModels];
                [self.totalCommentLayouts addObjectsFromArray:layouts];
            }
            [self.tableView reloadData];
        }
        self.hasMore = model.data.hasMore;
        self.offset = [model.data.offset integerValue];
        self.comment_count = [model.data.totalCount integerValue];
        [self commentCountChanged];
    } else {
        // hasmore = no
        self.hasMore = NO;
    }
    [self updateTableViewWithMoreData:self.hasMore];
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableView.mj_footer.hidden = NO;
    if (hasMore == NO) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
    // 没有评论
    if (self.totalComments.count == 0) {
        self.tableView.mj_footer.hidden = YES;
        // 显示 暂无评论，点击抢沙发
        self.tableView.tableFooterView = self.replayListEmptyView;
    } else {
        self.tableView.mj_footer.hidden = NO;
        self.tableView.tableFooterView = nil;
    }
}

- (void)commentCountChanged {
    if (self.commentAllFooter == nil) {
        self.commentAllFooter = [[FHDetailCommentAllFooter alloc] initWithFrame:CGRectMake(0, 0, self.detailVC.view.width, 52)];
        UIView *bottomSepView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, self.detailVC.view.width - 40, 0.5)];
        bottomSepView.backgroundColor = [UIColor themeGray6];
        [self.commentAllFooter addSubview:bottomSepView];
    }
    // 全部评论
    NSString *commentStr = @"全部评论";
    if (self.comment_count > 0) {
        commentStr = [NSString stringWithFormat:@"全部评论(%ld)",self.comment_count];
    } else {
        commentStr = [NSString stringWithFormat:@"全部评论(0)"];
    }
    self.commentAllFooter.allCommentLabel.text = commentStr;
}

- (FHUGCReplyListEmptyView *)replayListEmptyView {
    if (_replayListEmptyView == nil) {
        _replayListEmptyView = [[FHUGCReplyListEmptyView alloc] initWithFrame:CGRectMake(0, 0, self.detailVC.view.width, 100)];
        _replayListEmptyView.descLabel.text = @"暂无评论，点击抢沙发";
        [_replayListEmptyView addTarget:self action:@selector(commentFirst) forControlEvents:UIControlEventTouchUpInside];
    }
    return _replayListEmptyView;
}

// 抢沙发点击
- (void)commentFirst {
    
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;// 详情 + 回复列表
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        // 头部详情
        return 1;
    }
    // 回复
    return self.totalComments.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section == 0) {
        // 头部详情
        return [[FHUGCBaseCell alloc] init];
    }
    // reply list
    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.totalComments.count && row < self.totalCommentLayouts.count) {
        id data = self.totalComments[row];
        id layout = self.totalCommentLayouts[row];
        NSString *identifier = data ? NSStringFromClass([data class]) : @"";
        if (identifier.length > 0) {
            UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            if ([cell isKindOfClass:[TTCommentDetailCell class]]) {
                TTCommentDetailCell *tempCell = cell;
                [tempCell tt_refreshConditionWithLayout:layout model:data];
            }
            return cell;
        }
    }
    return [[FHUGCBaseCell alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section == 0) {
        // 头部详情
        return 200;
    }
    if (indexPath.row < self.totalCommentLayouts.count) {
        return self.totalCommentLayouts[indexPath.row].cellHeight;
    }
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        // 头部详情
        return CGFLOAT_MIN;
    }
    if (section == 1) {
        return 52;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        // 头部详情
        return nil;
    }
    if (section == 1) {
        return self.commentAllFooter;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
