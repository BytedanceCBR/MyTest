//
//  FHUGCUserFollowListVM.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/10/16.
//

#import "FHUGCUserFollowListVM.h"
#import "TTHttpTask.h"
#import "FHTopicListController.h"
#import "FHTopicCell.h"
#import "TTAccountLoginPCHHeader.h"
#import "FHHouseUGCAPI.h"
#import "FHTopicListModel.h"
#import "MJRefreshConst.h"
#import "TTReachability.h"
#import "FHRefreshCustomFooter.h"
#import "ToastManager.h"
#import "UIScrollView+Refresh.h"
#import "FHUserTracker.h"
#import "FHUGCUserFollowListController.h"
#import "FHUGCUserFollowModel.h"

@interface FHUGCUserFollowListVM ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign)   NSInteger       offset;
@property (nonatomic, assign)   BOOL       hasMore;
@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic, weak) FHUGCUserFollowListController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) NSMutableArray *dataList;

@end

@implementation FHUGCUserFollowListVM

- (instancetype)initWithController:(FHUGCUserFollowListController *)viewController tableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.viewController = viewController;
        self.tableView = tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
//        [_tableView registerClass:[FHUGCSearchListCell class] forCellReuseIdentifier:@"FHUGCSearchListCell"];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.dataList = [NSMutableArray array];
    }
    return self;
}

// 请求用户列表
- (void)requestUserList {
    if (self.requestTask) {
        [self.requestTask cancel];
    }
    __weak typeof(self) weakSelf = self;
    self.requestTask = [FHHouseUGCAPI requestFollowUserListBySocialGroupId:self.socialGroupId offset:self.offset class:[FHUGCUserFollowModel class] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        if (model != NULL && error == NULL) {
            NSLog(@"%@",model);
        }
    }];
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    FHUGCSearchListCell *cell = (FHUGCSearchListCell *) [tableView dequeueReusableCellWithIdentifier:@"FHUGCSearchListCell" forIndexPath:indexPath];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//
//    NSInteger row = indexPath.row;
//    if (row >= 0 && row < self.items.count) {
//        cell.highlightedText = self.searchText;
//        FHUGCScialGroupDataModel *data = self.items[row];
//        // 埋点
//        NSMutableDictionary *tracerDic = @{}.mutableCopy;
//        tracerDic[@"card_type"] = @"left_pic";
//        tracerDic[@"page_type"] = @"community_search";
//        tracerDic[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
//        tracerDic[@"rank"] = @(row);
//        tracerDic[@"click_position"] = @"join_like";
//        tracerDic[@"log_pb"] = data.logPb ?: @"be_null";
//        cell.tracerDic = tracerDic;
//        // 刷新数据
//    }
//
//    return cell;
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.dataList.count) {
//        // 键盘是否显示
//        self.isKeybordShow = self.keyboardVisible;
//
//        FHUGCScialGroupDataModel *data = self.items[row];
//
//        // 点击埋点
//        [self addCommunityClickLog:data rank:row];
//        NSMutableDictionary *dict = @{}.mutableCopy;
//        dict[@"community_id"] = data.socialGroupId;
//        dict[@"tracer"] = @{@"enter_from":@"community_search_show",
//                            @"enter_type":@"click",
//                            @"rank":@(row),
//                            @"log_pb":data.logPb ?: @"be_null"};
//        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
//        // 跳转到圈子详情页
//        NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_detail"];
//        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}


@end
