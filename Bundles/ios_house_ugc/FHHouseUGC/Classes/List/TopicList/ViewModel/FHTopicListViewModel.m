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
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
        // TODO: Mock 数据 Delete
        NSString *mockJson = @"{\"status\":\"0\",\"message\":\"success\",\"data\":{\"items\":[{\"title\":\"100万上车\",\"detail\":\"994万讨论\",\"subtitle\":\"我们小区-正华花园坐落在正定县的中另加加国中加电\",\"topicID\":\"1\",\"headerImageUrl\":\"https:\/\/www.baidu.com\/img\/baidu_resultlogo@2.png\"},{\"title\":\"武汉房市\",\"detail\":\"95.5万人讨论\",\"subtitle\":\"我们小区-正华花园坐落在正定县的北\",\"topicID\":\"2\",\"headerImageUrl\":\"https:\/\/www.baidu.com\/img\/baidu_resultlogo@2.png\"},{\"title\":\"南京楼市变化\",\"detail\":\"95.5万人讨论\",\"subtitle\":\"我们小区-正华花园坐落在正定县的北邯\",\"topicID\":\"3\",\"headerImageUrl\":\"https:\/\/www.baidu.com\/img\/baidu_resultlogo@2.png\"}]}}";
        model = [[FHTopicListResponseModel alloc] initWithString:mockJson error:nil];
        error = nil;
        //---
        if (model && (error == nil)) {
            if (isRefresh) {
                [wself.dataList removeAllObjects];
                [wself.tableView finishPullDownWithSuccess:YES];
            } else {
                [wself.tableView.mj_footer endRefreshing];
            }

            FHTopicListResponseModel *responseModel = model;

            [wself.dataList addObjectsFromArray:responseModel.data.items];
            wself.tableView.hidden = NO;
            [wself.tableView reloadData];
        } else {
            if (isRefresh) {
                [wself.tableView finishPullDownWithSuccess:NO];
            } else {
                [wself.tableView.mj_footer endRefreshing];
            }
            if (isRefresh) {
                wself.tableView.hidden = YES;
                [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
            }
            [[ToastManager manager] showToast:@"网络不给力,请稍后重试"];
        }
    }];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FHTopicListResponseItemModel *item = [self.dataList objectAtIndex:indexPath.row];
    if([self.viewController.delegate respondsToSelector:@selector(didSelectedHashtag:)]) {
        [self.viewController.delegate didSelectedHashtag:item];
        [self.viewController goBack];
    } else {
        NSURL *url = [NSURL URLWithString:@"sslocal://concern"];
        [[TTRoute sharedRoute] openURLByPushViewController:url];
    }
}

#pragma mark - UITableViewDataSource

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
