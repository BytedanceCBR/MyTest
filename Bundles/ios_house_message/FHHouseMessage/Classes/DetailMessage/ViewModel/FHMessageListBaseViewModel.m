//
//  FHMessageListBaseViewModel.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/1.
//

#import "FHMessageListBaseViewModel.h"
#import "FHMessageAPI.h"
#import <UIScrollView+Refresh.h>
#import "FHUserTracker.h"

@interface FHMessageListBaseViewModel()

@end

@implementation FHMessageListBaseViewModel

-(instancetype)initWithTableView:(UITableView *)tableView controller:(FHMessageListViewController *)viewController
{
    self = [super init];
    if (self) {
        
        self.tableView = tableView;
        self.viewController = viewController;
        
        __weak typeof(self) weakSelf = self;
        
        self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
            [weakSelf requestData:NO first:NO];
        }];
        self.refreshFooter.hidden = YES;
        self.tableView.mj_footer = self.refreshFooter;
        
    }
    return self;
}

-(void)requestData:(BOOL)isHead first:(BOOL)isFirst
{
    [self.requestTask cancel];
}

- (NSDictionary *)categoryLogDict {
    return nil;
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableView.mj_footer.hidden = NO;
    if (hasMore == NO) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
}


@end
