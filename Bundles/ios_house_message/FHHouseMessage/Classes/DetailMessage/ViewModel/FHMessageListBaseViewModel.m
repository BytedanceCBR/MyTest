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
        
        [_tableView tt_addDefaultPullUpLoadMoreWithHandler:^{
            [weakSelf requestData:NO first:NO];
        }];
        
    }
    return self;
}

-(void)requestData:(BOOL)isHead first:(BOOL)isFirst
{
//    [self trackRefresh:isHead first:isFirst];
    [self.requestTask cancel];
}

- (NSDictionary *)categoryLogDict {
    return nil;
}


@end
