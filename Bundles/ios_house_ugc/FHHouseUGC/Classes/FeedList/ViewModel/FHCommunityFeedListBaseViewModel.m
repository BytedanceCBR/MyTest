//
//  FHCommunityFeedListBaseViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHCommunityFeedListBaseViewModel.h"

@implementation FHCommunityFeedListBaseViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHCommunityFeedListController *)viewController {
    self = [super init];
    if (self) {
        
        self.tableView = tableView;
        self.viewController = viewController;
        
        self.cellManager = [[FHUGCCellManager alloc] init];
        [self.cellManager registerAllCell:tableView];
        
        _cellHeightCaches = [NSMutableDictionary dictionary];
//        __weak typeof(self) weakSelf = self;
        
//        self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
//            [weakSelf requestData:NO first:NO];
//        }];
//        self.refreshFooter.hidden = YES;
//        self.tableView.mj_footer = self.refreshFooter;
        
    }
    return self;
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    [self.requestTask cancel];
}

@end
