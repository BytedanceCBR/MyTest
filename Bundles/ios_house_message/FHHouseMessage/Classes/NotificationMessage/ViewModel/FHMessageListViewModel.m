//
// Created by zhulijun on 2019-06-17.
//

#import "FHMessageListViewModel.h"
#import "TTHttpTask.h"
#import "FHMessageListController.h"
#import "TTReachability.h"
#import "ToastManager.h"
#import "FHHouseUGCAPI.h"
#import "FHMessageNotificationManager.h"
#import "TTBaseMacro.h"
#import "FHRefreshCustomFooter.h"
#import "FHMessageNotificationTipsManager.h"
#import "FHMessageNotificationCellHelper.h"
#import "FHMessageNotificationBaseCell.h"
#import "TTUIResponderHelper.h"

@interface FHMessageListViewModel () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic, weak) FHMessageListController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) FHRefreshCustomFooter *refreshFooter; //加载更多footer
@property(nonatomic, strong) NSMutableDictionary *cellHeightCaches; //缓存的item高度

@property(nonatomic, strong) NSMutableArray<TTMessageNotificationModel *> *messageModels; //所有拉取到的message模型数组
@property(nonatomic, assign) BOOL hasMore;

@end

@implementation FHMessageListViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHMessageListController *)viewController {
    self = [super init];
    if (self) {
        self.viewController = viewController;
        self.tableView = tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [FHMessageNotificationCellHelper registerAllCellClassWithTableView:self.tableView];
        self.messageModels = [NSMutableArray array];
    }
    return self;
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableView.mj_footer.hidden = NO;
    if (!hasMore) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.tableView.mj_footer endRefreshing];
    }
}

- (void)requestData:(BOOL)loadMore {
    if (![TTReachability isNetworkConnected]) {
        [self networkError:loadMore];
        return;
    }

    if (!loadMore) {
        [[FHMessageNotificationTipsManager sharedManager] clearTipsModel];
        [[FHMessageNotificationManager sharedManager] fetchUnreadMessageWithChannel:nil];
    }

    NSNumber *cursor = loadMore ? @(self.messageModels.count) : @(0);
    WeakSelf;
    [[FHMessageNotificationManager sharedManager] fetchMessageListWithChannel:nil cursor:cursor completionBlock:^(NSError *error, TTMessageNotificationResponseModel *response) {
        StrongSelf;
        if (response && (error == nil)) {
            if (!loadMore) {
                [wself.messageModels removeAllObjects];
                if (response.msgList.count <= 0) {
                    self.tableView.hidden = YES;
                    [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeEmptyMessage];
                    return;
                }
            }
            [wself updateTableViewWithMoreData:[response.hasMore boolValue]];
            [wself.viewController.emptyView hideEmptyView];
            [wself.messageModels addObjectsFromArray:response.msgList];
            wself.tableView.hidden = NO;
            [wself.tableView reloadData];
        } else {
            [wself.tableView.mj_footer endRefreshing];
            [self networkError:loadMore];
        }
    }];
}

- (void)networkError:(BOOL)loadMore {
    if (loadMore) {
        [[ToastManager manager] showToast:@"网络不给力,请稍后重试"];
    } else {
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.messageModels.count) {
        TTMessageNotificationModel *model = self.messageModels[indexPath.row];
        //calculate height
        CGFloat cellWidth = [TTUIResponderHelper splitViewFrameForView:tableView].size.width;
        return [FHMessageNotificationCellHelper heightForData:model cellWidth:cellWidth];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messageModels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.row < self.messageModels.count) {
        TTMessageNotificationModel *model = [self.messageModels objectAtIndex:indexPath.row];
        // refresh UI
        cell = [FHMessageNotificationCellHelper dequeueTableCellForData:model tableView:tableView atIndexPath:indexPath];
        if ([cell isKindOfClass:[FHMessageNotificationBaseCell class]]) {
            [(FHMessageNotificationBaseCell *) cell refreshWithData:model];
        }
    }

    if (!cell) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"preventCrashCellIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"preventCrashCellIdentifier"];
        }
        cell.textLabel.text = @"";
    }
    return cell;
}

@end
