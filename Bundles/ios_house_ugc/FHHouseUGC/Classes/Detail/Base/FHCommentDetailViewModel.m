//
//  FHCommentDetailViewModel.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/3.
//

#import "FHCommentDetailViewModel.h"
#import "FHHouseUGCAPI.h"
#import "TTHttpTask.h"

@interface FHCommentDetailViewModel ()<UITableViewDelegate,UITableViewDataSource>

@end

static int fh_count = 1;

@implementation FHCommentDetailViewModel

+(instancetype)createDetailViewModelWithPostType:(FHUGCPostType)postType withController:(FHCommentDetailViewController *)viewController tableView:(UITableView *)tableView {
    FHCommentDetailViewModel *viewModel = NULL;
    switch (postType) {
        case FHUGCPostTypePost:
            viewModel = [[FHCommentDetailViewModel alloc] initWithController:viewController tableView:tableView postType:postType];
            break;
    }
    return viewModel;
}

-(instancetype)initWithController:(FHCommentDetailViewController *)viewController tableView:(UITableView *)tableView postType:(FHUGCPostType)postType{
    self = [super init];
    if (self) {
        _items = [NSMutableArray new];
        self.postType = postType;
        self.listController = viewController;
        fh_count += 2;
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

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return fh_count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.items.count) {
        id data = self.items[row];
        NSString *identifier = [self cellIdentifierForEntity:data];
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

// 返回计算后的固定高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 105;
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
