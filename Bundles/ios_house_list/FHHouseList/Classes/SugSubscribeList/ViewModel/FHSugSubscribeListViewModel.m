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
#import "NSArray+BTDAdditions.h"

#define kFHSugSubscribeNotificationName @"kFHSugSubscribeNotificationName"
static NSString* const kFHSuggestionSubscribeNotificationKey = @"kFHSuggestionSubscribeNotificationKey";

@interface FHSugSubscribeListViewModel ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHSugSubscribeListViewController *listController;
@property(nonatomic , weak) TTHttpTask *httpTask;
@property (nonatomic, strong , nullable) NSMutableArray<FHSugSubscribeDataDataItemsModel> *subscribeItems;
@property (nonatomic, assign)   NSInteger       totalCount; // 订阅搜索总个数
@property (nonatomic, strong)   NSMutableDictionary *tracerCacheDic;// 埋点
@property (nonatomic, strong) TTHttpTask *requestTask;

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
    // "subscribe_list_type": 2(搜索页) / 3(独立展示页) 请求总数50
    self.httpTask = [FHHouseListAPI requestSugSubscribe:cityId houseType:houseType subscribe_type:3 subscribe_count:50 class:[FHSugSubscribeModel class] completion:(FHMainApiCompletion)^(FHSugSubscribeModel *  _Nonnull model, NSError * _Nonnull error) {
        if (error.code == NSURLErrorCancelled) {
            // 是否canceled请求
            return;
        }
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
            [cell updateConstraintsIfNeeded];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    FHSugSubscribeDataDataItemsModel *model = [self.subscribeItems btd_objectAtIndex:indexPath.row];
    if (!model) {
        return;
    }
    
    NSString *subscribeID = model.subscribeId;
    NSString *text = model.text;
    __weak typeof(self) weakSelf = self;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [weakSelf determineToDeleteSubscriptionWithsubscribeID:subscribeID text:text];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

///iOS11以上系统使用方法修改删除按钮样式
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHSugSubscribeDataDataItemsModel *model = [self.subscribeItems btd_objectAtIndex:indexPath.row];
    NSString *subscribeID = model.subscribeId;
    NSString *subscribeText = model.text;
    __weak typeof(self) weakSelf = self;
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [weakSelf determineToDeleteSubscriptionWithsubscribeID:subscribeID text:subscribeText];
    }];

    action.backgroundColor = [UIColor themeOrange1];
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[action]];
    config.performsFirstActionWithFullSwipe = NO;

    return config;
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
        if ([item isKindOfClass:[FHSugSubscribeDataDataItemsModel class]]) {
            NSString *subscribe_id = item.subscribeId;
            if (subscribe_id.length > 0) {
                if (self.tracerCacheDic[subscribe_id]) {
                    return;
                }
                self.tracerCacheDic[subscribe_id] = @"1";
                NSMutableDictionary *tracerDic = @{@"subscribe_id":subscribe_id}.mutableCopy;
                tracerDic[@"title"] = item.title.length > 0 ? item.title : @"be_null";
                tracerDic[@"text"] = item.text.length > 0 ? item.text : @"be_null";
                tracerDic[@"word_type"] = [self wordType];
                tracerDic[@"page_type"] = [self pageType];
                tracerDic[@"rank"] = @(index);
                tracerDic[@"origin_from"] = self.listController.tracerDict[@"origin_from"] ? self.listController.tracerDict[@"origin_from"] : @"be_null";
                [FHUserTracker writeEvent:@"subscribe_card_show" params:tracerDic];
            }
        }
    }
}

- (void)addItemClickTracer:(FHSugSubscribeDataDataItemsModel* )item index:(NSInteger)index {
    if ([item isKindOfClass:[FHSugSubscribeDataDataItemsModel class]]) {
        NSString *subscribe_id = item.subscribeId;
        if (subscribe_id.length > 0) {
            NSMutableDictionary *tracerDic = @{@"subscribe_id":subscribe_id}.mutableCopy;
            tracerDic[@"title"] = item.title.length > 0 ? item.title : @"be_null";
            tracerDic[@"text"] = item.text.length > 0 ? item.text : @"be_null";
            tracerDic[@"word_type"] = [self wordType];
            tracerDic[@"page_type"] = [self pageType];
            tracerDic[@"rank"] = @(index);
            tracerDic[@"origin_from"] = self.listController.tracerDict[@"origin_from"] ? self.listController.tracerDict[@"origin_from"] : @"be_null";
            [FHUserTracker writeEvent:@"subscribe_card_click" params:tracerDic];
        }
    }
}

- (void)determineToDeleteSubscriptionWithsubscribeID:(NSString *)subscribeID text:(NSString *)text {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认取消订阅？" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"我再想想" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf requestDeleteSubScribe:subscribeID andText:text];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    [self.listController presentViewController:alertController animated:YES completion:nil];
}

- (void)requestDeleteSubScribe:(NSString *)subscribeId andText:(NSString *)text {
    if (!subscribeId || !text) {
        return;
    }
    
    [self.requestTask cancel];
    TTHttpTask *task = [FHHouseListAPI requestDeleteSugSubscribe:subscribeId class:nil completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        if (!error) {
            NSMutableDictionary *dict = [NSMutableDictionary new];
            if (text.length > 0) {
                [dict setValue:text forKey:@"text"];
            }
            [dict setValue:@"0" forKey:@"status"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFHSuggestionSubscribeNotificationKey object:nil userInfo:dict];
            
            NSMutableDictionary *uiDict = [NSMutableDictionary new];
            [uiDict setValue:@(NO) forKey:@"subscribe_state"];
            [uiDict setValue:subscribeId forKey:@"subscribe_id"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHSugSubscribeNotificationName" object:uiDict];
        }
    }];
    
    self.requestTask = task;
}

@end
