//
//  FHMyJoinViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/12.
//

#import "FHMyJoinViewModel.h"
#import <TTHttpTask.h>
#import "FHMyJoinNeighbourhoodCell.h"
#import "FHUGCConfig.h"
#import "FHMessageNotificationTipsManager.h"
#import "FHUnreadMsgModel.h"
#import "FHUserTracker.h"
#import "FHCommunityList.h"

#define cellId @"cellId"
#define neighbourhoodViewHeight 194

@interface FHMyJoinViewModel () <UICollectionViewDelegate, UICollectionViewDataSource, FHMyJoinNeighbourhoodViewDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, weak) FHMyJoinViewController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, assign) BOOL isShowMessage;
@property(nonatomic, assign) CGFloat messageViewHeight;

@end

@implementation FHMyJoinViewModel

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView controller:(FHMyJoinViewController *)viewController {
    self = [super init];
    if (self) {
        _dataList = [[NSMutableArray alloc] init];
        _viewController = viewController;
        _collectionView = collectionView;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _messageViewHeight = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUnreadMessageChange) name:kTTMessageNotificationTipsChangeNotification object:nil];

        [_collectionView registerClass:[FHMyJoinNeighbourhoodCell class] forCellWithReuseIdentifier:cellId];
        __weak typeof(self) weakSelf = self;
        self.viewController.neighbourhoodView.progressView.refreshViewBlk = ^{
            [weakSelf updateJoinProgressView];
        };

        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onUnreadMessageClick)];
        [self.viewController.neighbourhoodView.messageView addGestureRecognizer:singleTap];
        
        [self onUnreadMessageChange];
    }

    return self;
}

- (void)requestData {
    [self.dataList removeAllObjects];
    [self.dataList addObjectsFromArray:[[FHUGCConfig sharedInstance] followList]];

    [self updateJoinProgressView];
    [self.collectionView reloadData];
}

- (void)onUnreadMessageChange {
    FHUnreadMsgDataUnreadModel *model = [FHMessageNotificationTipsManager sharedManager].tipsModel;
    if (model && [model.unread integerValue] > 0) {
        [self showMessageView];
    }else{
        [self hideMessageView];
    }
}

- (void)showMessageView {
    FHUnreadMsgDataUnreadModel *model = [FHMessageNotificationTipsManager sharedManager].tipsModel;
    if (isEmptyString(model.openUrl) || isEmptyString(model.lastUserAvatar) || [model.unread intValue] <= 0) {
        return;
    }
    self.messageViewHeight = 58;
    self.isShowMessage = YES;
    self.viewController.neighbourhoodView.messageView.hidden = NO;

    CGRect frame = self.viewController.neighbourhoodView.frame;
    frame.size.height = neighbourhoodViewHeight + self.messageViewHeight + self.viewController.neighbourhoodView.progressView.viewHeight;
    self.viewController.neighbourhoodView.frame = frame;

    self.viewController.feedListVC.tableHeaderView = self.viewController.neighbourhoodView;
    [self.viewController.neighbourhoodView.messageView refreshWithUrl:model.lastUserAvatar messageCount:[model.unread intValue]];
    [self trackElementShow];
}

- (void)hideMessageView {
    self.isShowMessage = NO;
    self.viewController.neighbourhoodView.messageView.hidden = YES;
    self.messageViewHeight = 0;

    CGRect frame = self.viewController.neighbourhoodView.frame;
    frame.size.height = neighbourhoodViewHeight + self.messageViewHeight + self.viewController.neighbourhoodView.progressView.viewHeight;
    self.viewController.neighbourhoodView.frame = frame;

    self.viewController.feedListVC.tableHeaderView = self.viewController.neighbourhoodView;
}

- (void)onUnreadMessageClick {
    FHUnreadMsgDataUnreadModel *model = [FHMessageNotificationTipsManager sharedManager].tipsModel;
    NSURL *openURL = [NSURL URLWithString:[model.openUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
        NSMutableDictionary *tracerDictForUgc = [NSMutableDictionary dictionary];
        tracerDictForUgc[@"enter_from"] = @"neighborhood_tab";
        tracerDictForUgc[@"enter_type"] = @"click";
        tracerDictForUgc[@"element_from"] = @"feed_message_tips_card";
        TTRouteUserInfo *ugcUserInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer":tracerDictForUgc}];
        [[TTRoute sharedRoute] openURLByPushViewController:openURL userInfo:ugcUserInfo];
    }
    [self trackClickOptions];
}

// 更新发帖进度视图
- (void)updateJoinProgressView {
    CGRect frame = self.viewController.neighbourhoodView.frame;
    frame.size.height = neighbourhoodViewHeight + self.messageViewHeight + self.viewController.neighbourhoodView.progressView.viewHeight;
    self.viewController.neighbourhoodView.frame = frame;

    self.viewController.feedListVC.tableHeaderView = self.viewController.neighbourhoodView;
}

#pragma mark - collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHMyJoinNeighbourhoodCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    if (indexPath.row < self.dataList.count) {
        [cell refreshWithData:self.dataList[indexPath.row]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    FHUGCScialGroupDataModel *model = self.dataList[indexPath.row];
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"community_id"] = model.socialGroupId;
    dict[@"tracer"] = @{@"enter_from":@"my_joined_neighborhood",
                        @"enter_type":@"click",
                        @"rank":@(indexPath.row),
                        @"log_pb":model.logPb ?: @"be_null"};
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    //跳转到圈子详情页
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_detail"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

//埋点
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
//    if ([self.houseShowCache valueForKey:tempKey]) {
//        return;
//    }
//    [self.houseShowCache setValue:@(YES) forKey:tempKey];
//    // 添加埋点
//    if (self.displayCellBlk) {
//        self.displayCellBlk(indexPath.row);
//    }
}

- (void)trackMore {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"element_type"] = @"my_joined_neighborhood";
    tracerDict[@"page_type"] = @"my_join_list";
    tracerDict[@"enter_from"] = @"neighborhood_tab";
    TRACK_EVENT(@"click_more", tracerDict);
}

#pragma mark - FHMyJoinNeighbourhoodViewDelegate

- (void)gotoMore {
    [self trackMore];
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"action_type"] = @(FHCommunityListTypeFollow);
    dict[@"select_district_tab"] = @(FHUGCCommunityDistrictTabIdFollow);
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[@"enter_type"] = @"click";
    traceParam[@"enter_from"] = @"my_join_list";
    traceParam[@"element_from"] = @"my_joined_neighborhood";
    dict[TRACER_KEY] = traceParam;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

#pragma mark - 埋点

- (void)trackElementShow {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"element_type"] = @"feed_message_tips_card";
    tracerDict[@"page_type"] = @"my_join_list";
    tracerDict[@"enter_from"] = @"neighborhood_tab";
    TRACK_EVENT(@"element_show", tracerDict);
}

- (void)trackClickOptions {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"click_position"] = @"feed_message_tips_card";
    tracerDict[@"page_type"] = @"my_join_list";
    tracerDict[@"enter_from"] = @"neighborhood_tab";
    TRACK_EVENT(@"click_options", tracerDict);
}


@end
