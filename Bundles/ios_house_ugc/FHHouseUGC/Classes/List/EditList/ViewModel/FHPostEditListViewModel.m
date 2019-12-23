//
// FHPostEditListViewModel.m
//

#import "FHPostEditListViewModel.h"
#import "FHPostEditListController.h"
#import "TTHttpTask.h"
#import "FHHouseUGCAPI.h"
#import "MJRefreshConst.h"
#import "TTReachability.h"
#import "FHRefreshCustomFooter.h"
#import "ToastManager.h"
#import "UIScrollView+Refresh.h"
#import "FHUserTracker.h"

@interface FHPostEditListViewModel () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign)   NSInteger       offset;
@property (nonatomic, assign)   BOOL       hasMore;
@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic, weak) FHPostEditListController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) NSMutableArray *dataList;

@end

@implementation FHPostEditListViewModel

- (instancetype)initWithController:(FHPostEditListController *)viewController tableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.viewController = viewController;
        self.tableView = tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.offset = 0;
        self.hasMore = NO;
        self.dataList = [NSMutableArray array];
    }
    return self;
}

- (void)startLoadData {
    
}

- (void)loadMore {
    
}

- (void)requestData:(BOOL)isRefresh {
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络不给力,请稍后重试"];
        return;
    }

   
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableView.mj_footer.hidden = NO;
    if (hasMore == NO) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row < 0 || indexPath.row >= self.dataList.count) {
        return;
    }

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {



    return nil;
}


@end
