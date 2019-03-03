//
//  FHMessageListBaseViewModel.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/1.
//

#import <Foundation/Foundation.h>
#import <TTHttpTask.h>
#import "FHMessageListViewController.h"
#import "FHRefreshCustomFooter.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMessageListBaseViewModel : NSObject

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHMessageListViewController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong ,nullable) NSString *maxCursor;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic , strong) FHRefreshCustomFooter *refreshFooter;

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHMessageListViewController *)viewController;

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst;

- (void)updateTableViewWithMoreData:(BOOL)hasMore;

- (NSDictionary *)categoryLogDict;

@end

NS_ASSUME_NONNULL_END