//
// Created by zhulijun on 2019-06-03.
//

#import "FHTopicListViewModel.h"
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

@interface FHTopicListViewModel () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic, weak) FHTopicListController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) NSMutableArray *dataList;

@end

@implementation FHTopicListViewModel

- (instancetype)initWithController:(FHTopicListController *)viewController tableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.viewController = viewController;
        self.tableView = tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.dataList = [NSMutableArray array];
    }
    return self;
}

- (void)requestData:(BOOL)isRefresh {
    if (![TTReachability isNetworkConnected]) {
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        [[ToastManager manager] showToast:@"网络不给力,请稍后重试"];
        return;
    }

    WeakSelf;
    [FHHouseUGCAPI requestTopicList:@"1234" class:FHTopicListResponseModel.class completion:^(id <FHBaseModelProtocol> model, NSError *error) {
        StrongSelf;
        if (model && (error == nil)) {
            if (isRefresh) {
                [self.dataList removeAllObjects];
                [self.tableView finishPullDownWithSuccess:YES];
            } else {
                [self.tableView.mj_footer endRefreshing];
            }

            FHTopicListResponseModel *responseModel = model;
            [self.dataList addObjectsFromArray:responseModel.data.items];
            self.tableView.hidden = NO;
            [self.tableView reloadData];
        } else {
            if (isRefresh) {
                [self.tableView finishPullDownWithSuccess:NO];
            } else {
                [self.tableView.mj_footer endRefreshing];
            }
            if (isRefresh) {
                self.tableView.hidden = YES;
                [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
            }
            [[ToastManager manager] showToast:@"网络不给力,请稍后重试"];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = NSStringFromClass(FHTopicCell.class);
    FHTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        Class cellClass = NSClassFromString(cellIdentifier);
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (indexPath.row < self.dataList.count) {
        [cell refreshWithData:self.dataList[indexPath.row]];
    }

    return cell;
}

@end
