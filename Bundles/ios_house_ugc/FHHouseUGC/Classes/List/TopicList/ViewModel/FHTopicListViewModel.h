//
// Created by zhulijun on 2019-06-03.
//

#import <Foundation/Foundation.h>

@class TTHttpTask;
@class FHTopicListController;


@interface FHTopicListViewModel : NSObject

- (instancetype)initWithController:(FHTopicListController *)viewController tableView:(UITableView *)tableView;

- (void)requestData:(BOOL)isLoadMore;

- (void)addEnterCategoryLog;

- (void)addStayCategoryLog:(NSTimeInterval)stayTime;

- (void)addCategoryRefreshLog: (BOOL)isLoadMore;
@end
