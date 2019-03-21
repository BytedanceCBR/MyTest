//
//  FHSugSubscribeListViewModel.m
//  FHHouseList
//
//  Created by 张元科 on 2019/3/19.
//

#import "FHSugSubscribeListViewModel.h"
#import "FHHouseListAPI.h"
#import "FHSugSubscribeItemCell.h"

#define kFHSugSubscribeNotificationName @"kFHSugSubscribeNotificationName"

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sugSubscribeNoti:) name:kFHSugSubscribeNotificationName object:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             NSDictionary *ui =       @{@"subscribe_state":@(NO),
                      @"subscribe_id":@"123458",
                                        };
            [[NSNotificationCenter defaultCenter] postNotificationName:kFHSugSubscribeNotificationName object:ui];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSDictionary *ui =       @{@"subscribe_state":@(NO),
                                       @"subscribe_id":@"123457",
                                       };
            [[NSNotificationCenter defaultCenter] postNotificationName:kFHSugSubscribeNotificationName object:ui];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSDictionary *ui =       @{@"subscribe_state":@(NO),
                                       @"subscribe_id":@"123456",
                                       };
            [[NSNotificationCenter defaultCenter] postNotificationName:kFHSugSubscribeNotificationName object:ui];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSDictionary *ui =       @{@"subscribe_state":@(NO),
                                       @"subscribe_id":@"123459",
                                       };
            [[NSNotificationCenter defaultCenter] postNotificationName:kFHSugSubscribeNotificationName object:ui];
        });
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            FHSugSubscribeDataDataItemsModel *model = self.subscribeItems[2];
//            NSDictionary *ui =       @{@"subscribe_state":@(YES),
//                                       @"subscribe_id":@"123458",
//                                       @"subscribe_item":model
//                                       };
//            [[NSNotificationCenter defaultCenter] postNotificationName:kFHSugSubscribeNotificationName object:ui];
//        });
    }
    return self;
}

-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;

    [_tableView registerClass:[FHSugSubscribeItemCell class] forCellReuseIdentifier:@"FHSugSubscribeItemCell"];
}

- (void)sugSubscribeNoti:(NSNotification *)noti {
    NSDictionary *userInfo = noti.object;
    if (userInfo) {
        BOOL subscribe_state = [userInfo[@"subscribe_state"] boolValue];
        if (subscribe_state) {
            // 订阅
            FHSugSubscribeDataDataItemsModel *subscribe_item = userInfo[@"subscribe_item"];
            if (subscribe_item && [subscribe_item isKindOfClass:[FHSugSubscribeDataDataItemsModel class]]) {
                [self.subscribeItems insertObject:subscribe_item atIndex:0];
            }
        } else {
            // 取消订阅
            NSString *subscribe_id = userInfo[@"subscribe_id"];
            __block NSInteger findIndex = -1;
            if (subscribe_id.length > 0) {
                [self.subscribeItems enumerateObjectsUsingBlock:^(FHSugSubscribeDataDataItemsModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.subscribeId isEqualToString:subscribe_id]) {
                        findIndex = idx;
                        *stop = YES;
                    }
                }];
                if (findIndex >= 0 && findIndex < self.subscribeItems.count) {
                    [self.subscribeItems removeObjectAtIndex:findIndex];
                }
            }
        }
        __weak typeof(self) wself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself reloadListData];
        });
    }
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
            NSString *countStr = model.data.data.total;
            if (countStr.length > 0) {
                wself.totalCount = [countStr integerValue];
            } else {
                wself.totalCount = 0;
            }
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
