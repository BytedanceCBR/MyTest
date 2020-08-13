//
//  FHMyJoinViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/12.
//

#import "FHMyJoinViewModel.h"
#import "TTHttpTask.h"
#import "FHMyJoinNeighbourhoodCell.h"
#import "FHMyJoinCommnityCell.h"
#import "FHUGCConfig.h"
#import "FHMessageNotificationTipsManager.h"
#import "FHUnreadMsgModel.h"
#import "FHUserTracker.h"
#import "FHCommunityList.h"
#import "FHMyJoinAllNeighbourhoodCell.h"
#import "TTUGCDefine.h"
#import "FHEnvContext.h"

#define cellId @"cellId"
#define allCellId @"allCellId"
#define leaveOffSet 60

@interface FHMyJoinViewModel () <UICollectionViewDelegate, UICollectionViewDataSource, FHMyJoinNeighbourhoodViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, weak) FHMyJoinViewController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, assign) BOOL isShowMessage;
@property(nonatomic, assign) CGFloat messageViewHeight;
@property(nonatomic, strong) FHMyJoinAllNeighbourhoodCell *allCell;
@property(nonatomic, strong) NSMutableDictionary *clientShowDict;
@property(nonatomic, assign) NSInteger maxFollowItem;

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

        _maxFollowItem = 3;
        [_collectionView registerClass:[FHMyJoinCommnityCell class] forCellWithReuseIdentifier:cellId];
        
//        if(!self.viewController.isNewDiscovery){
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUnreadMessageChange) name:kTTMessageNotificationTipsChangeNotification object:nil];
//            
//            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onUnreadMessageClick)];
//            [self.viewController.neighbourhoodView.messageView addGestureRecognizer:singleTap];
//            
//            [self onUnreadMessageChange];
//        }
    }

    return self;
}

// 发帖成功通知
- (void)postThreadSuccess:(NSNotification *)noti {
    if (noti) {
        NSString *groupId = noti.userInfo[@"social_group_id"];
        if (groupId.length > 0) {
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf requestData];
            });
        }
    }
}

// 删帖成功通知
- (void)delPostThreadSuccess:(NSNotification *)noti {
    NSString *groupId = noti.userInfo[@"social_group_id"];
    if (groupId.length > 0) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf requestData];
        });
    }
}

- (void)requestData {
    [self.dataList removeAllObjects];
    [self.clientShowDict removeAllObjects];
    
    [self addAllItem];
    if([[FHUGCConfig sharedInstance] followList].count > _maxFollowItem){
        NSArray *followList = [[FHUGCConfig sharedInstance] followList];
        NSArray *subFollowList = [followList subarrayWithRange:NSMakeRange(0, _maxFollowItem)];
        [self.dataList addObjectsFromArray:subFollowList];
    }else{
        [self.dataList addObjectsFromArray:[[FHUGCConfig sharedInstance] followList]];
    }
    
    [self updateJoinProgressView];
    [self.collectionView reloadData];
}

- (void)addAllItem {
    FHUGCScialGroupDataModel *model = [[FHUGCScialGroupDataModel alloc] init];
    model.socialGroupId = @"-1";
    model.socialGroupName = @"全部圈子";
    model.countText = @"发现精彩社区";
    [self.dataList addObject:model];
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
    frame.size.height = self.viewController.neighbourhoodViewHeight + self.messageViewHeight;
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
    frame.size.height = self.viewController.neighbourhoodViewHeight + self.messageViewHeight;
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
    [self trackClickOptions:@"feed_message_tips_card"];
}

// 更新发帖进度视图
- (void)updateJoinProgressView {
    CGRect frame = self.viewController.neighbourhoodView.frame;
    frame.size.height = self.viewController.neighbourhoodViewHeight + self.messageViewHeight;
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

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        [self traceClientShowAtIndexPath:indexPath];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = cellId;

    FHUGCBaseCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    if (indexPath.row < self.dataList.count) {
        [cell refreshWithData:self.dataList[indexPath.row]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if(indexPath.row < self.dataList.count){
        FHUGCScialGroupDataModel *model = self.dataList[indexPath.row];
        //最后一个为全部
        if([model.socialGroupId isEqualToString:@"-1"]){
            [self trackClickOptions:@"all_community"];
            [self gotoMore:@"click"];
            return;
        }
        
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"community_id"] = model.socialGroupId;
        NSString *originFrom = self.viewController.tracerDict[@"origin_from"] ?: @"be_null";
        dict[@"tracer"] = @{
            @"origin_from":originFrom,
            @"enter_from":[self pageType],
            @"enter_type":@"click",
            @"element_from":@"top_operation_position",
            @"rank":@(indexPath.row),
            @"log_pb":model.logPb ?: @"be_null"};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        //跳转到圈子详情页
        NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_detail"];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(120, 60);
}

- (void)trackMore {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"element_type"] = @"top_operation_position";
    tracerDict[@"page_type"] = [self pageType];
    tracerDict[@"enter_from"] = @"neighborhood_tab";
    TRACK_EVENT(@"click_more", tracerDict);
}

#pragma mark - FHMyJoinNeighbourhoodViewDelegate

- (void)gotoMore:(NSString *)enterType {
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"action_type"] = @(FHCommunityListTypeFollow);
    dict[@"select_district_tab"] = @(FHUGCCommunityDistrictTabIdFollow);
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[@"enter_type"] = enterType;
    traceParam[@"origin_from"] = self.viewController.tracerDict[@"origin_from"] ?: @"be_null";
    traceParam[@"enter_from"] = [self pageType];
    traceParam[@"element_from"] = @"top_operation_position";
    dict[TRACER_KEY] = traceParam;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

#pragma mark - 埋点

- (void)trackElementShow {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"element_type"] = @"feed_message_tips_card";
    tracerDict[@"page_type"] = [self pageType];
    tracerDict[@"enter_from"] = @"neighborhood_tab";
    TRACK_EVENT(@"element_show", tracerDict);
}

- (void)trackClickOptions:(NSString *)position {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"click_position"] = position;
    tracerDict[@"page_type"] = [self pageType];
    tracerDict[@"enter_from"] = @"neighborhood_tab";
    TRACK_EVENT(@"click_options", tracerDict);
}

- (void)traceClientShowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row >= self.dataList.count) {
        return;
    }
    
    FHUGCScialGroupDataModel *cellModel = self.dataList[indexPath.row];
    
    if (!self.clientShowDict) {
        self.clientShowDict = [NSMutableDictionary new];
    }
    
    NSString *row = [NSString stringWithFormat:@"%i",indexPath.row];
    NSString *groupId = cellModel.socialGroupId;
    if(groupId){
        if (self.clientShowDict[groupId] || [groupId isEqualToString:@"-1"]) {
            return;
        }
        
        self.clientShowDict[groupId] = @(indexPath.row);
        [self trackClientShow:cellModel rank:indexPath.row];
    }
}

- (void)trackClientShow:(FHUGCScialGroupDataModel *)cellModel rank:(NSInteger)rank {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    
    tracerDict[@"element_type"] = @"top_operation_position";
    tracerDict[@"social_group_id"] = cellModel.socialGroupId;
    tracerDict[@"page_type"] = [self pageType];
    tracerDict[@"origin_from"] = self.viewController.tracerDict[@"origin_from"] ?: @"be_null";
    tracerDict[@"enter_from"] = self.viewController.tracerDict[@"enter_from"] ?: @"be_null";
    TRACK_EVENT(@"community_group_show", tracerDict);
}

- (NSString *)pageType {
    return @"my_join_feed";
}

@end
