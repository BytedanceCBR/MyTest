//
// Created by zhulijun on 2019-06-17.
//

#import "FHMessageListViewModel.h"
#import "TTHttpTask.h"
#import "FHMessageListController.h"
#import "TTReachability.h"
#import "ToastManager.h"
#import "FHHouseUGCAPI.h"
#import "TTMessageNotificationManager.h"
#import "TTBaseMacro.h"
#import "UIScrollView+Refresh.h"
#import "FHRefreshCustomFooter.h"
#import "FHMessageItemCell.h"
#import "TTMessageNotificationTipsManager.h"
#import "FHMessageNotificationCellHelper.h"
#import "FHMessageNotificationBaseCell.h"
#import "TTUIResponderHelper.h"

typedef NS_ENUM(NSUInteger, FHMessageNotificationCellSectionType) {
    FHMessageNotificationCellSectionTypeMessage = 0,
    FHMessageNotificationCellSectionTypeReadFooter = 1
};

@interface FHMessageListViewModel () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic, weak) FHMessageListController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) FHRefreshCustomFooter *refreshFooter; //加载更多footer
@property(nonatomic, strong) NSMutableDictionary *cellHeightCaches; //缓存的item高度

@property (nonatomic, strong) NSMutableArray<TTMessageNotificationModel *> *messageModels; //所有拉取到的message模型数组
@property (nonatomic, assign) BOOL hasMore;

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

- (void)requestData:(BOOL) loadMore {
    if (![TTReachability isNetworkConnected]) {
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        [[ToastManager manager] showToast:@"网络不给力,请稍后重试"];
        return;
    }
    NSNumber *cursor = loadMore ? @(self.messageModels.count) : @(0);

    if(!loadMore){
        [[TTMessageNotificationTipsManager sharedManager] clearTipsModel];
        [[TTMessageNotificationManager sharedManager] fetchUnreadMessageWithChannel:nil];
    }

    WeakSelf;
    [[TTMessageNotificationManager sharedManager] fetchMessageListWithChannel:nil cursor:cursor completionBlock:^(NSError *error, TTMessageNotificationResponseModel *response) {
        StrongSelf;
        if (response && (error == nil)) {
            if (!loadMore) {
                [wself.messageModels removeAllObjects];
                [wself.tableView finishPullDownWithSuccess:YES];
            } else {
                [self.tableView.mj_footer endRefreshing];
            }

            if(response.msgList.count <= 0){
                self.tableView.hidden = YES;
                [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeEmptyMessage];
                return;
            }

            [self.messageModels addObjectsFromArray:response.msgList];
            self.tableView.hidden = NO;
            [self.tableView reloadData];
        } else {
            if (!loadMore) {
                [self.tableView finishPullDownWithSuccess:NO];
            } else {
                [self.tableView.mj_footer endRefreshing];
            }
            if (!loadMore) {
                self.tableView.hidden = YES;
                [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
            }
            [[ToastManager manager] showToast:@"网络不给力,请稍后重试"];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == FHMessageNotificationCellSectionTypeMessage) {
        if (indexPath.row < self.messageModels.count) {
            TTMessageNotificationModel *model = self.messageModels[indexPath.row];
            //calculate height
            CGFloat cellWidth = [TTUIResponderHelper splitViewFrameForView:tableView].size.width;
            return [FHMessageNotificationCellHelper heightForData:model cellWidth:cellWidth];
        }
    }
//    else if (indexPath.section == FHMessageNotificationCellSectionTypeReadFooter) {
//        return [FHMessageNotificationReadFooterCell cellHeight];
//    }

    return 44;
}
//
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
//    NSNumber *cellHeight = self.cellHeightCaches[tempKey];
//    if (cellHeight) {
//        return [cellHeight floatValue];
//    }
//    return UITableViewAutomaticDimension;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messageModels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == FHMessageNotificationCellSectionTypeMessage) {
        if (indexPath.row < self.messageModels.count) {
            TTMessageNotificationModel *model = [self.messageModels objectAtIndex:indexPath.row];
            // refresh UI
            cell = [FHMessageNotificationCellHelper dequeueTableCellForData:model tableView:tableView atIndexPath:indexPath];
            if([cell isKindOfClass:[FHMessageNotificationBaseCell class]]){
                [(FHMessageNotificationBaseCell*)cell refreshWithData:model];
            }
        }
    }
//    else if (indexPath.section == FHMessageNotificationCellSectionTypeReadFooter) {
//        cell = [tableView dequeueReusableCellWithIdentifier:kTTMessageNotificationReadFooterCellIdentifier];
//        if (!cell) {
//            cell = [[TTMessageNotificationReadFooterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTTMessageNotificationReadFooterCellIdentifier];
//        }
//    }

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
