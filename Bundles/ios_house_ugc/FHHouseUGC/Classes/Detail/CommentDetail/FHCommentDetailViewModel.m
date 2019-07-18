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

@interface FHCommentDetailViewModel ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHCommentDetailViewController *detailVC;
@property(nonatomic , weak) TTHttpTask *httpTask;
@property(nonatomic , weak) TTHttpTask *httpListTask;
@property (nonatomic, strong)   NSMutableArray       *items;
@property (nonatomic, assign)   NSInteger       offset;
@property (nonatomic, assign)   NSInteger       count;

@end

@implementation FHCommentDetailViewModel

-(instancetype)initWithController:(FHCommentDetailViewController *)viewController tableView:(UITableView *)tableView
{   self = [super init];
    if (self) {
        self.detailVC = viewController;
        self.tableView = tableView;
        self.items = [NSMutableArray new];
        self.offset = 0;
        self.count = 20;
        [self configTableView];
    }
    return self;
}

-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[FHUGCReplyCell class] forCellReuseIdentifier:NSStringFromClass([FHUGCReplyCellModel class])];
}

- (void)startLoadData {
    // 请求评论详情
    [self requestCommentDetailData];
    // 请求回复列表
    [self requestReplyListData];
}

// 请求评论详情数据
- (void)requestCommentDetailData {
    if (self.httpTask) {
        [self.httpTask cancel];
    }
    __weak typeof(self) wself = self;
//    self.httpTask = [FHHouseUGCAPI requestRentHouseSearchWithQuery:self.condition neighborhoodId:neighborhoodId houseId:houseId searchId:self.searchId offset:offset count:15 class:[FHHouseRentModel class] completion:^(FHHouseRentModel * _Nonnull model, NSError * _Nonnull error) {
//        [wself processQueryData:model error:error];
//    }];
}

// 处理网络数据返回，详情返回直接展示
- (void)processQueryData:(id<FHBaseModelProtocol>)model error:(NSError *)error {
    if (model != NULL && error == NULL) {
        
    }
}

// 请求回复列表数据，返回后直接处理回复列表是否展示和刷新就好
- (void)requestReplyListData {
    if (self.httpListTask) {
        [self.httpListTask cancel];
    }
    __weak typeof(self) wself = self;
    self.httpListTask = [FHHouseUGCAPI requestReplyListWithCommentId:self.comment_id offset:self.offset class:[FHDetailReplyCommentModel class] completion:^(id<FHBaseModelProtocol> _Nonnull model, NSError * _Nonnull error) {
        NSLog(@"%@",model);
    }];
}


#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.items.count) {
        id data = self.items[row];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
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
