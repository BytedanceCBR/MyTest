//
//  FHDetailEvaluationListViewModel.h
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/16.
//

#import <Foundation/Foundation.h>
#import "FHDetailEvaluationListViewHeader.h"
#import "FHDetailEvaluationListViewController.h"

NS_ASSUME_NONNULL_BEGIN
@interface FHDetailEvaluationListViewModel : NSObject
- (instancetype)initWithController:(FHDetailEvaluationListViewController *)viewController tableView:(UITableView *)table headerView:(FHDetailEvaluationListViewHeader *)header userInfo:(NSDictionary *)userInfo;
@property(nonatomic ,strong) NSMutableDictionary *tracerDic; // 基础埋点数据
- (void)reloadData;
- (void)addGoDtailTracer;
@end

NS_ASSUME_NONNULL_END
