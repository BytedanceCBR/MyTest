//
//  FHSugSubscribeListViewModel.m
//  FHHouseList
//
//  Created by 张元科 on 2019/3/19.
//

#import "FHSugSubscribeListViewModel.h"
#import "FHHouseListAPI.h"
#import "FHSugSubscribeItemCell.h"

@interface FHSugSubscribeListViewModel ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHSugSubscribeListViewController *listController;
@property(nonatomic , weak) TTHttpTask *httpTask;
@property (nonatomic, strong , nullable) NSMutableArray<FHSugSubscribeDataDataItemsModel> *subscribeItems;
@property (nonatomic, assign)   NSInteger       totalCount; // 订阅搜索总个数

@end

@implementation FHSugSubscribeListViewModel

-(instancetype)initWithController:(FHSugSubscribeListViewController *)viewController tableView:(UITableView *)tableView
{   self = [super init];
    if (self) {
        self.subscribeItems = [NSMutableArray new];
        self.listController = viewController;
        self.tableView = tableView;
        [self configTableView];
    }
    return self;
}

-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;

    [_tableView registerClass:[FHSugSubscribeItemCell class] forCellReuseIdentifier:@"FHSugSubscribeItemCell"];
}

- (void)reloadListData {
    if (self.subscribeItems.count > 0) {
        self.tableView.hidden = NO;
        [self.listController.emptyView hideEmptyView];
        self.listController.hasValidateData = YES;
        [self.tableView reloadData];
    } else {
        // 显示空页面
        self.tableView.hidden = YES;
        self.listController.hasValidateData = NO;
        [self.listController.emptyView showEmptyWithTip:@"尚未订阅任何搜索" errorImageName:kFHErrorMaskNoListDataImageName showRetry:NO];
    }
}

- (void)requestSugSubscribe:(NSInteger)cityId houseType:(NSInteger)houseType {
    
    if (self.httpTask) {
        [self.httpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.httpTask = [FHHouseListAPI requestSugSubscribe:cityId houseType:houseType subscribe_type:3 subscribe_count:50 class:[FHSugSubscribeModel class] completion:^(FHSugSubscribeModel *  _Nonnull model, NSError * _Nonnull error) {
        // if (model != NULL && error == NULL) add by zyk 后面要改w回来，现在为了测试
        [wself.subscribeItems removeAllObjects];
        if (model != NULL) {
            // 构建数据源
            if (model.data.data.items.count > 0) {
                [wself.subscribeItems addObjectsFromArray:model.data.data.items];
            }
        } else {
            wself.listController.hasValidateData = NO;
        }
        // 刷新
        [wself reloadListData];
    }];
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.subscribeItems.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= 0 && indexPath.row < self.subscribeItems.count) {
        
        FHSugSubscribeDataDataItemsModel *model = self.subscribeItems[indexPath.row];
        FHSugSubscribeItemCell *cell = (FHSugSubscribeItemCell *)[tableView dequeueReusableCellWithIdentifier:@"FHSugSubscribeItemCell"];
        if (cell) {
            cell.titleLabel.text = model.title;
            cell.sugLabel.text = model.text;
            cell.isValid = model.status;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

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
