//
//  FHSugSubscribeListViewModel.m
//  FHHouseList
//
//  Created by 张元科 on 2019/3/19.
//

#import "FHSugSubscribeListViewModel.h"
#import "FHHouseListAPI.h"
#import "FHSugSubscribeItemCell.h"
#import "FHSugSubscribeListViewController.h"
#import "FHUserTracker.h"

#define kFHSugSubscribeNotificationName @"kFHSugSubscribeNotificationName"

@interface FHSugSubscribeListViewModel ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHSugSubscribeListViewController *listController;
@property(nonatomic , weak) TTHttpTask *httpTask;
@property (nonatomic, strong , nullable) NSMutableArray<FHSugSubscribeDataDataItemsModel> *subscribeItems;
@property (nonatomic, assign)   NSInteger       totalCount; // 订阅搜索总个数
@property (nonatomic, strong)   NSMutableDictionary *tracerCacheDic;// 埋点

@end

@implementation FHSugSubscribeListViewModel

-(instancetype)initWithController:(FHSugSubscribeListViewController *)viewController tableView:(UITableView *)tableView
{   self = [super init];
    if (self) {
        self.subscribeItems = [NSMutableArray new];
        self.listController = viewController;
        self.tableView = tableView;
        self.tracerCacheDic = [NSMutableDictionary new];
        [self configTableView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sugSubscribeNoti:) name:kFHSugSubscribeNotificationName object:nil];
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
        [wself.subscribeItems removeAllObjects];
        if (model != NULL && error == NULL) {
            // 构建数据源
            NSString *countStr = model.data.total;
            if (countStr.length > 0) {
                wself.totalCount = [countStr integerValue];
            } else {
                wself.totalCount = 0;
            }
            if (model.data.items.count > 0) {
                [wself.subscribeItems addObjectsFromArray:model.data.items];
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
    if (indexPath.row >= 0 && indexPath.row < self.subscribeItems.count) {
        FHSugSubscribeDataDataItemsModel *model = self.subscribeItems[indexPath.row];
        [self addItemShowTracer:model index:indexPath.row];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    // 由 FHSugSubscribeListViewController 转 FHSuggestionListViewModel 转 FHSuggestionListViewController 进行页面跳转和页面移除等操作
    if (indexPath.row >= 0 && indexPath.row < self.subscribeItems.count) {
        FHSugSubscribeDataDataItemsModel *model = self.subscribeItems[indexPath.row];
        [self.listController cellSubscribeItemClick:model];
        [self addItemClickTracer:model index:indexPath.row];
    }
}

// 埋点添加
- (NSString *)wordType {
    NSString *word_type = @"be_null";
    switch (self.houseType) {
        case FHHouseTypeSecondHandHouse:
            word_type = @"old";
            break;
        case FHHouseTypeNewHouse:
            word_type = @"new";
            break;
        case FHHouseTypeRentHouse:
            word_type = @"rent";
            break;
        case FHHouseTypeNeighborhood:
            word_type = @"neighborhood";
            break;
        default:
            break;
    }
    return word_type;
}

- (NSString *)pageType {
    NSString *page_type = @"be_null";
    switch (self.houseType) {
        case FHHouseTypeSecondHandHouse:
            page_type = @"old_subscribe_list";
            break;
        case FHHouseTypeNewHouse:
            page_type = @"new_subscribe_list";
            break;
        case FHHouseTypeRentHouse:
            page_type = @"rent_subscribe_list";
            break;
        case FHHouseTypeNeighborhood:
            page_type = @"neighborhood_subscribe_list";
            break;
        default:
            break;
    }
    return page_type;
}

- (void)addItemShowTracer:(FHSugSubscribeDataDataItemsModel* )item index:(NSInteger)index {
    if (item) {
        NSString *subscribe_id = item.subscribeId;
        if (subscribe_id.length > 0) {
            if (self.tracerCacheDic[subscribe_id]) {
                return;
            }
            self.tracerCacheDic[subscribe_id] = @"1";
            NSMutableDictionary *tracerDic = @{@"subscribe_id":subscribe_id}.mutableCopy;
            tracerDic[@"word"] = item.text.length > 0 ? item.text : @"be_null";
            tracerDic[@"word_type"] = [self wordType];
            tracerDic[@"page_type"] = [self pageType];
            tracerDic[@"rank"] = @(index);
            [FHUserTracker writeEvent:@"subscribe_card_show" params:tracerDic];
        }
    }
}

- (void)addItemClickTracer:(FHSugSubscribeDataDataItemsModel* )item index:(NSInteger)index {
    if (item) {
        NSString *subscribe_id = item.subscribeId;
        if (subscribe_id.length > 0) {
            NSMutableDictionary *tracerDic = @{@"subscribe_id":subscribe_id}.mutableCopy;
            tracerDic[@"word"] = item.text.length > 0 ? item.text : @"be_null";
            tracerDic[@"word_type"] = [self wordType];
            tracerDic[@"page_type"] = [self pageType];
            tracerDic[@"rank"] = @(index);
            [FHUserTracker writeEvent:@"subscribe_card_click" params:tracerDic];
        }
    }
}

@end
