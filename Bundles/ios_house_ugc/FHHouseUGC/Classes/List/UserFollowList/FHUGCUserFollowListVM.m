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
#import "FHUGCUserFollowTC.h"
#import "FHRefreshCustomFooter.h"
#import "TTReachability.h"

@interface FHUGCUserFollowListVM ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign)   NSInteger       offset;
@property (nonatomic, assign)   BOOL       hasMore;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) FHUGCUserFollowListController *viewController;
@property (nonatomic, weak) TTHttpTask *requestTask;
@property (nonatomic, strong) NSMutableArray *followList;// 用户列表
@property (nonatomic, strong)   NSMutableArray       *adminList;// 管理员
@property (nonatomic, strong)   NSMutableArray       *mergedArray;
@property (nonatomic, strong)   FHRefreshCustomFooter       *refreshFooter;
@property (nonatomic, assign)   NSInteger       adminCount;
@property (nonatomic, assign)   NSInteger       followCount;

@end

@implementation FHUGCUserFollowListVM

- (instancetype)initWithController:(FHUGCUserFollowListController *)viewController tableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.viewController = viewController;
        self.tableView = tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [_tableView registerClass:[FHUGCUserFollowTC class] forCellReuseIdentifier:@"FHUGCUserFollowTC_List"];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.followList = [NSMutableArray array];
        self.adminList = [NSMutableArray array];
        self.mergedArray = [NSMutableArray array];
        self.adminCount = 0;
        self.followCount = 0;
        
        __weak typeof(self) weakSelf = self;
        
        self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
            if (![TTReachability isNetworkConnected]) {
                [[ToastManager manager] showToast:@"网络异常"];
                [weakSelf updateTableViewWithMoreData:weakSelf.tableView.hasMore];
            } else {
                [weakSelf requestUserList];
            }
        }];
        [self.refreshFooter setUpNoMoreDataText:@"没有更多成员了"];
        self.tableView.mj_footer = self.refreshFooter;
        self.tableView.mj_footer.hidden = YES;
    }
    return self;
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableView.mj_footer.hidden = NO;
    if (hasMore == NO) {
        [self.refreshFooter setUpNoMoreDataText:@"没有更多成员了"];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
}

// 请求用户列表
- (void)requestUserList {
    if (self.requestTask) {
        [self.requestTask cancel];
    }
    if (self.offset == 0) {
        [self.viewController startLoading];
    }
    __weak typeof(self) weakSelf = self;
    self.requestTask = [FHHouseUGCAPI requestFollowUserListBySocialGroupId:self.socialGroupId offset:self.offset class:[FHUGCUserFollowModel class] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        [weakSelf.viewController endLoading];
        if (model != NULL && error == NULL) {
            [weakSelf processDataWith:(FHUGCUserFollowModel *)model];
        } else {
            [weakSelf processDataWith:nil];
        }
    }];
}

- (void)processDataWith:(FHUGCUserFollowModel *)model {
    if (model && [model isKindOfClass:[FHUGCUserFollowModel class]] && model.data) {
        if (model.data.adminList.count > 0 && self.offset == 0) {
            [self.adminList addObjectsFromArray:model.data.adminList];
        }
        if (model.data.followList.count > 0) {
            [self.followList addObjectsFromArray:model.data.followList];
        }
        self.hasMore = model.data.hasMore;
        if (self.offset == 0) {
            self.adminCount = model.data.adminCount;
            self.followCount = model.data.followCount;
        }
        self.offset = model.data.offset;
    }
    // 后处理
    if (self.adminList.count > 0 || self.followList.count > 0) {
        [self.mergedArray removeAllObjects];
        if (self.adminList.count > 0) {
            [self.mergedArray addObject:self.adminList];
        }
        if (self.followList.count > 0) {
            [self.mergedArray addObject:self.followList];
        }
        self.viewController.hasValidateData = YES;
        self.viewController.ttNeedHideBottomLine = YES;
        [self.viewController.emptyView hideEmptyView];
        self.tableView.hasMore = self.hasMore;
        [self updateTableViewWithMoreData:self.hasMore];
        [self.tableView reloadData];
    } else {
        self.viewController.hasValidateData = NO;
        self.viewController.ttNeedHideBottomLine = NO;
        // 显示空的关注页面-数据走丢了
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
    }
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.mergedArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < self.mergedArray.count) {
        NSArray *arr = self.mergedArray[section];
        return arr.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHUGCUserFollowTC *cell = (FHUGCUserFollowTC *) [tableView dequeueReusableCellWithIdentifier:@"FHUGCUserFollowTC_List" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    if (section < self.mergedArray.count) {
        NSArray *data = self.mergedArray[section];
        if (row < data.count) {
            FHUGCUserFollowDataFollowListModel *itemData = (FHUGCUserFollowDataFollowListModel *)data[row];
            [cell refreshWithData:itemData];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 33;
    }
    return 37;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    FHUGCUserFollowSectionHeader *v = [[FHUGCUserFollowSectionHeader alloc] init];
    v.backgroundColor = [UIColor whiteColor];
    if (section < self.mergedArray.count) {
        NSArray *data = self.mergedArray[section];
        if (self.mergedArray.count == 2) {
            if (section == 0) {
                v.sectionLabel.text = [NSString stringWithFormat:@"管理员（%ld人）",self.adminCount];
            }
            if (section == 1) {
                v.sectionLabel.text = [NSString stringWithFormat:@"圈子成员（%ld人）",self.followCount];
            }
        } else if (self.mergedArray.count == 1) {
            // 只有一个section
            if (self.adminList.count > 0) {
                v.sectionLabel.text = [NSString stringWithFormat:@"管理员（%ld人）",self.adminCount];
            }
            if (self.followList.count > 0) {
                v.sectionLabel.text = [NSString stringWithFormat:@"圈子成员（%ld人）",self.followCount];
            }
        }
    }
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    if (section < self.mergedArray.count) {
        NSArray *dataArr = self.mergedArray[section];
        if (row < dataArr.count) {
            FHUGCUserFollowDataFollowListModel *data = dataArr[row];
            if (data.schema.length > 0) {
                // 点击埋点
                [self.viewController.view endEditing:YES];
                // 跳转到个人主页
                NSURL *openUrl = [NSURL URLWithString:data.schema];
                [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
            }
        }
    }
}


@end
