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

@interface FHCommentDetailViewModel ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHCommentDetailViewController *detailVC;
@property(nonatomic , weak) TTHttpTask *httpTask;
@property(nonatomic , weak) TTHttpTask *httpListTask;
@property (nonatomic, strong)   id       detailData;// 详情数据
@property (nonatomic, assign)   NSInteger       offset;
@property (nonatomic, assign)   NSInteger       count;

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
        self.totalComments = [NSMutableArray new];
        self.totalCommentLayouts = [NSMutableArray new];
        [self configTableView];
    }
    return self;
}

-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[TTCommentDetailCell class] forCellReuseIdentifier:NSStringFromClass([TTCommentDetailReplyCommentModel class])];
}

- (void)startLoadData {
    self.offset = 0;
    self.detailData = nil;
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
    self.httpTask = [FHHouseUGCAPI requestCommentDetailDataWithCommentId:self.comment_id class:[FHDetailReplyCommentModel class] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        [wself processQueryData:model error:error];
    }];
}

// 处理网络数据返回，详情返回直接展示
- (void)processQueryData:(id<FHBaseModelProtocol>)model error:(NSError *)error {
    if (model != NULL) {
        // 有详情数据
        self.tableView.hidden = NO;
        [self.detailVC.emptyView hideEmptyView];
        self.detailVC.hasValidateData = YES;
        // 详情data
        self.detailData = model;
        // 请求回复列表
        [self requestReplyListData];
    } else {
        self.detailVC.hasValidateData = NO;
        self.tableView.hidden = YES;
        [self.detailVC.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
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
    } else {
        // hasmore = no
    }
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
    return CGFLOAT_MIN;
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
