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
#import "FHMessageNotificationCellHelper.h"
#import "FHMessageNotificationBaseCell.h"
#import "TTUIResponderHelper.h"
#import "FHMessageNotificationTipsManager.h"
#import "TTStringHelper.h"
#import "FHUserTracker.h"
#import "FHMessageNotificationCellHelper.h"
#import "UIScrollView+Refresh.h"

@interface FHMessageListViewModel () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic, weak) FHMessageListController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) FHRefreshCustomFooter *refreshFooter; //加载更多footer
@property(nonatomic, strong) NSNumber *maxCursor;
@property(nonatomic, strong) NSMutableDictionary *messageShowRecords;

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
        self.messageShowRecords = [NSMutableDictionary dictionary];
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

- (void)requestData:(BOOL)loadMore isFirst:(BOOL)isFirst {
    if (![TTReachability isNetworkConnected]) {
        [self networkError:loadMore];
        return;
    }

    if (!loadMore) {
        [self.viewController startLoading];
        self.maxCursor = nil;
    }

    WeakSelf;
    [[FHMessageNotificationManager sharedManager] fetchMessageListWithChannel:nil cursor:self.maxCursor completionBlock:^(NSError *error, TTMessageNotificationResponseModel *response) {
        StrongSelf;
        [wself.viewController endLoading];
        if (response && (error == nil)) {
            if (!loadMore) {
                [[FHMessageNotificationTipsManager sharedManager] clearTipsModel];
                [wself.messageModels removeAllObjects];
                if (response.msgList.count <= 0) {
                    wself.tableView.hidden = YES;
                    if (isFirst) {
                        [wself addEnterCategoryLog:YES];
                    }
                    [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeEmptyMessage];
                    return;
                }
            }
            wself.maxCursor = response.minCursor;
            wself.tableView.hasMore = [response.hasMore boolValue];
            [wself updateTableViewWithMoreData:wself.tableView.hasMore];
            [wself.viewController.emptyView hideEmptyView];
            if(response.msgList){
                for(TTMessageNotificationModel* itemModel in response.msgList){
                    CGFloat cellWidth = [TTUIResponderHelper splitViewFrameForView:wself.tableView].size.width;
                    [FHMessageNotificationCellHelper heightForData:itemModel cellWidth:cellWidth];
                }
                [wself.messageModels addObjectsFromArray:response.msgList];
            }
            wself.tableView.hidden = NO;
            [wself.tableView reloadData];
            if (isFirst) {
                [wself addEnterCategoryLog:NO];
            }
        } else {
            [wself.tableView.mj_footer endRefreshing];
            [self networkError:loadMore];
        }
    }];
}

- (void)networkError:(BOOL)loadMore {
    if (loadMore) {
        [[ToastManager manager] showToast:@"网络不给力,请稍后重试"];
        [self updateTableViewWithMoreData:self.tableView.hasMore];
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
        model.index = @(indexPath.row);
        // refresh UI
        cell = [FHMessageNotificationCellHelper dequeueTableCellForData:model tableView:tableView atIndexPath:indexPath];
        if ([cell isKindOfClass:[FHMessageNotificationBaseCell class]]) {
            [(FHMessageNotificationBaseCell *) cell refreshWithData:model];
        }
    }

    if (!cell) {
        cell = [UITableViewCell new];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TTMessageNotificationModel *model = self.messageModels[indexPath.row];
    [self addFeedMessageClickLog:model rank:indexPath.row];
    NSString *bodyUrl = model.content.bodyUrl;
    if (!isEmptyString(bodyUrl)) {
        TTRouteUserInfo *userInfo = nil;
        NSMutableDictionary *dict = @{}.mutableCopy;
        if([bodyUrl containsString:@"comment_detail"]){
            //dict[@"hidePost"] = @(1);
        }
        
        NSMutableDictionary *traceParam = @{}.mutableCopy;
        traceParam[@"origin_from"] = @"message";
        traceParam[@"enter_from"] = @"feed_message_list";
        traceParam[@"enter_type"] = @"feed_message_card";
        traceParam[@"rank"] = @(indexPath.row);
        traceParam[@"log_pb"] = model.logPb;
        dict[TRACER_KEY] = traceParam;
        
        dict[@"begin_show_comment"] = @"1";
        userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        
        NSURL *openURL = [NSURL URLWithString:[bodyUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
            [[TTRoute sharedRoute] openURLByPushViewController:openURL userInfo:userInfo];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.messageModels.count) {
        TTMessageNotificationModel *model = self.messageModels[indexPath.row];
        if (model && !self.messageShowRecords[model.ID]) {
            self.messageShowRecords[model.ID] = @(YES);
            [self addFeedMessageShowLog:model rank:indexPath.row];
        }
    }
}

- (NSString *)categoryName {
    return @"feed_message_list";
}

- (NSString *)pageType {
    return @"feed_message_list";
}

- (void)addEnterCategoryLog:(BOOL)blank {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"category_name"] = [self categoryName];
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"enter_type"] = self.tracerDict[@"enter_type"] ?: @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    params[@"show_type"] = blank ? @"message_blank" : @"message_full";
    [FHUserTracker writeEvent:@"enter_category" params:params];
}

- (void)addStayCategoryLog:(NSTimeInterval)stayTime {
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"category_name"] = [self categoryName];
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"enter_type"] = self.tracerDict[@"enter_type"] ?: @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    params[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHUserTracker writeEvent:@"stay_category" params:params];
}

- (void)addFeedMessageShowLog:(TTMessageNotificationModel*)model rank:(NSInteger)rank {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"page_type"] = [self pageType];
    params[@"card_type"] = !isEmptyString(model.content.refThumbUrl) ? @"right_pic" : @"no_pic";
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"origin_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    params[@"rank"] = @(rank);
    params[@"log_pb"] = model.logPb ?: @"be_null";
    [FHUserTracker writeEvent:@"feed_message_show" params:params];
}

- (void)addFeedMessageClickLog:(TTMessageNotificationModel*)model rank:(NSInteger)rank {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"page_type"] = [self pageType];
    params[@"card_type"] = !isEmptyString(model.content.refThumbUrl) ? @"right_pic" : @"no_pic";
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"origin_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    params[@"rank"] = @(rank);
    params[@"click_position"] = @"feed_message";
    params[@"log_pb"] = model.logPb ?: @"be_null";
    [FHUserTracker writeEvent:@"click_feed_message" params:params];
}

@end
