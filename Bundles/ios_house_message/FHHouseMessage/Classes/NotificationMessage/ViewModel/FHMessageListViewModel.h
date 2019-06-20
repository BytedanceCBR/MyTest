//
// Created by zhulijun on 2019-06-17.
//

#import <Foundation/Foundation.h>

@class TTHttpTask;
@class FHMessageListController;
@class FHRefreshCustomFooter;


@interface FHMessageListViewModel : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHMessageListController *)viewController;

- (void)requestData:(BOOL)isLoadMore;

@end