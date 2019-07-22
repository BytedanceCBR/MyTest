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
#import "TTMomentDetailAction.h"
#import "TTMomentDetailStore.h"
#import "FHPostDetailHeaderCell.h"

@interface FHCommentDetailViewModel ()<UITableViewDelegate,UITableViewDataSource,TTCommentDetailCellDelegate>

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
@property (nonatomic, strong)   TTMomentDetailStore       *store;

// 详情数据
@property (nonatomic, strong)   NSMutableArray       *detailItems;
@property (nonatomic, strong)   NSMutableArray       *detailHeights;// 高度缓存
@property (nonatomic, strong)   FHPostDetailHeaderModel *detailHeaderModel;

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
        self.detailHeights = [NSMutableArray new];
        self.detailItems = [NSMutableArray new];
        self.totalComments = [NSMutableArray new];
        self.totalCommentLayouts = [NSMutableArray new];
        [self configTableView];
        [self commentCountChanged];
        [self store];
        //  add by zyk
//        self.store.enterFrom = self.enterFrom;
//        self.store.categoryID = self.categoryID;
//        self.store.logPb = self.logPb;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delCommentDetailReplySuccess:) name:kFHUGCDelCommentDetailReplyNotification object:nil];
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
    [_tableView registerClass:[FHPostDetailHeaderCell class] forCellReuseIdentifier:NSStringFromClass([FHPostDetailHeaderModel class])];
}

- (void)startLoadData {
    self.offset = 0;
    self.commentDetailModel = nil;
    [self.totalComments removeAllObjects];
    [self.totalCommentLayouts removeAllObjects];
    [self.detailItems removeAllObjects];
    [self.detailHeights removeAllObjects];
    // 请求评论详情
    [self requestCommentDetailData];
}

// 请求评论详情数据
- (void)requestCommentDetailData {
    if (self.httpTask) {
        [self.httpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.httpTask = [FHHouseUGCAPI requestCommentDetailDataWithCommentId:self.comment_id class:[FHUGCSocialGroupCommentDetailModel class] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        [wself processQueryData:model error:error];
    }];
}

// 处理网络数据返回，详情返回直接展示
- (void)processQueryData:(FHUGCSocialGroupCommentDetailModel *)model error:(NSError *)error {
    if (model != NULL) {
        // 有详情数据
        self.tableView.hidden = NO;
        [self.detailVC.emptyView hideEmptyView];
        self.detailVC.hasValidateData = YES;
        // 详情data
        if (model.commentDetail) {
            NSMutableDictionary *detailDic = [NSMutableDictionary new];
            if ([model.commentDetail.comment_base isKindOfClass:[NSDictionary class]]) {
                [detailDic addEntriesFromDictionary:model.commentDetail.comment_base];
                // 添加 评论数等数据
                if ([model.commentDetail.comment_base[@"action"] isKindOfClass:[NSDictionary class]]) {
                    [detailDic addEntriesFromDictionary:model.commentDetail.comment_base[@"action"]];
                }
            }
            if (detailDic.count > 0) {
                // 构建之前的评论详情数据，后面有用到
                TTCommentDetailModel *dModel = [[TTCommentDetailModel alloc] init];
                dModel.commentID = [NSString stringWithFormat:@"%@",detailDic[@"id"]];
                dModel.content = detailDic[@"content"];
                dModel.createTime = detailDic[@"create_time"];
                dModel.userDigg = [detailDic[@"user_digg"] boolValue];
                dModel.diggCount = [detailDic[@"digg_count"] integerValue];
                dModel.commentCount = [detailDic[@"comment_count"] integerValue];
                dModel.contentRichSpanJSONString = detailDic[@"content_rich_span"];
                
                self.commentDetailModel = dModel;
            }
            self.user_digg = self.commentDetailModel.userDigg ? 1 : 0;
            self.digg_count = self.commentDetailModel.diggCount;
            [self.detailVC refreshUI];
        }
        // 圈子详情数据
        FHUGCScialGroupDataModel *socialGroupModel = model.social_group;
        if (socialGroupModel && ![socialGroupModel.hasFollow boolValue]) {
            // 未关注
            FHPostDetailHeaderModel *headerModel = [[FHPostDetailHeaderModel alloc] init];
            headerModel.socialGroupModel = socialGroupModel;
//            headerModel.tracerDict = self.detailController.tracerDict.mutableCopy;
//            self.social_group_id = socialGroupModel.socialGroupId;
            [self.detailItems addObject:headerModel];
            self.detailHeaderModel = headerModel;
            CGFloat headerHeight = [FHPostDetailHeaderCell heightForData:headerModel];
            [self.detailHeights addObject:@(headerHeight)];// 高度提前计算
//            [self.detailController headerInfoChanged];
            //
//            FHUGCDetailGrayLineModel *grayLine = [[FHUGCDetailGrayLineModel alloc] init];
//            [self.items addObject:grayLine];
//            cellModel.showCommunity = NO;
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
    [self.detailVC openWriteCommentViewWithReplyCommentModel:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 删除回复通知
/*
 [postParams setValue:commentID forKey:@"id"];
 [postParams setValue:commentReplyID forKey:@"reply_id"];
 */
- (void)delCommentDetailReplySuccess:(NSNotification *)noti {
    NSString *commentId = noti.userInfo[@"id"];
    NSString *replyId = noti.userInfo[@"reply_id"];
    // 删除指定的回复
    if (commentId.length > 0 && replyId.length > 0) {
        if ([self.commentDetailModel.commentID isEqualToString:commentId]) {
            __block NSInteger findIndex = -1;
            [self.totalComments enumerateObjectsUsingBlock:^(TTCommentDetailReplyCommentModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.commentID isEqualToString:replyId]) {
                    findIndex = idx;
                    *stop = YES;
                }
            }];
            if (findIndex >= 0 && findIndex  < self.totalComments.count && findIndex < self.totalCommentLayouts.count) {
                [self.totalComments removeObjectAtIndex:findIndex];
                [self.totalCommentLayouts removeObjectAtIndex:findIndex];
                // 删除
                self.offset -= 1;
                if (self.offset < 0) {
                    self.offset = 0;
                }
                self.comment_count -= 1;
                [self commentCountChanged];
            }
            if (self.totalComments.count == 0 && self.hasMore) {
                // 加载更多
                [self loadMore];
            } else {
                [self updateTableViewWithMoreData:self.hasMore];
            }
            [self.tableView reloadData];
        }
    }
}

// 写评论回复成功之后调用，插入第一行
- (void)insertReplyData:(TTCommentDetailReplyCommentModel *)model {
    if (model && [model isKindOfClass:[TTCommentDetailReplyCommentModel class]]) {
        // 转化
        NSArray *layout = [[TTCommentDetailCellLayout alloc] initWithCommentModel:model containViewWidth:self.detailVC.view.width];
        if (layout) {
            [self.totalComments insertObject:model  atIndex:0];
            [self.totalCommentLayouts insertObject:layout  atIndex:0];
            self.offset += 1;
            self.comment_count += 1;
            [self commentCountChanged];
            [self.tableView reloadData];
            [self updateTableViewWithMoreData:self.hasMore];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
            // 先看是否需要滚动
            NSArray *arrCells = [self.tableView visibleCells];
            if (arrCells.count > 0) {
                UITableViewCell *firstCell = [arrCells firstObject];
                NSIndexPath *ip = [self.tableView indexPathForCell:firstCell];
                NSInteger section1 = ip.section;
                NSInteger row1 = ip.row;
                UITableViewCell *lastCell = [arrCells lastObject];
                ip = [self.tableView indexPathForCell:lastCell];
                NSInteger section2 = ip.section;
                NSInteger row2 = ip.row;
                // 上面显示详情
                if (section1 == 0) {
                    // 不跳转
                } else {
                    if (row1 >= 0) {
                        __weak typeof(self) weakSelf = self;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                        });
                    }
                }
            }
        }
    }
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;// 详情 + 回复列表
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        // 头部 详情
        return self.detailItems.count;
    }
    // 回复
    return self.totalComments.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section == 0) {
        // 头部 详情
        NSInteger row = indexPath.row;
        if (row >= 0 && row < self.detailItems.count) {
            id data = self.detailItems[row];
            NSString *identifier = data ? NSStringFromClass([data class]) : @"";
            if (identifier.length > 0) {
                FHUGCBaseCell *cell = (FHUGCBaseCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
                cell.baseViewModel = self;
                [cell refreshWithData:data];
                return cell;
            }
        }
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
                tempCell.delegate = self;
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
        // 头部 详情
        NSInteger row = indexPath.row;
        if (row >= 0 && row < self.detailHeights.count) {
            id dataHeight = self.detailHeights[row];
            return [dataHeight floatValue];
        }
        return CGFLOAT_MIN;
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
    NSInteger section = indexPath.section;
    if (section == 0) {
        // 头部详情
    } else if (section == 1) {
        if (indexPath.row < self.totalComments.count) {
            id data = self.totalComments[indexPath.row];
            if (data) {
                [self.detailVC openWriteCommentViewWithReplyCommentModel:data];
            }
        }
    }
}

// TTMomentDetailStore
- (TTMomentDetailStore *)store {
    if (!_store) {
        _store = [[TTMomentDetailStore alloc] init];
    }
    return _store;
}


#pragma mark - TTCommentDetailCellDelegate

- (void)tt_commentCell:(UITableViewCell *)view avatarTappedWithCommentModel:(TTCommentDetailReplyCommentModel *)model {

}

- (void)tt_commentCell:(UITableViewCell *)view deleteCommentWithCommentModel:(TTCommentDetailReplyCommentModel *)model {
    TTMomentDetailAction *action = [TTMomentDetailAction actionWithType:TTMomentDetailActionTypeDeleteComment payload:nil];
    action.commentDetailModel = self.commentDetailModel;
    action.replyCommentModel = model;
    action.source = TTMomentDetailActionSourceTypeComment;
    action.shouldMiddlewareHandle = YES;
    // 不想修改之前的代码
    [self.store dispatch:action];
}

- (void)tt_commentCell:(UITableViewCell *)view digCommentWithCommentModel:(TTCommentDetailReplyCommentModel *)model {
    // @"rt_like" 是否需要埋点
    NSInteger action = 0;
    if (model.userDigg) {
        action = 0;
        model.diggCount -= 1;
        if (model.diggCount < 0) {
            model.diggCount = 0;
        }
        model.userDigg = NO;
    } else {
        action = 1;
        model.diggCount += 1;
        model.userDigg = YES;
    }
    // 新接口
    [FHCommonApi requestCommonDigg: model.commentID groupType:FHDetailDiggTypeREPLY action:action completion:nil];
    // 刷新UI
    if (model) {
        NSInteger index = [self.totalComments indexOfObject:model];
        if (index >= 0 && index < self.totalCommentLayouts.count) {
            id layout = [self.totalCommentLayouts objectAtIndex:index];
            TTCommentDetailCell *tempCell = (TTCommentDetailCell *)view;
            [tempCell tt_refreshConditionWithLayout:layout model:model];
        }
    }
}

- (void)tt_commentCell:(UITableViewCell *)view nameViewonClickedWithCommentModel:(TTCommentDetailReplyCommentModel *)model {

}

- (void)tt_commentCell:(UITableViewCell *)view quotedNameOnClickedWithCommentModel:(TTCommentDetailReplyCommentModel *)model {

}

@end
