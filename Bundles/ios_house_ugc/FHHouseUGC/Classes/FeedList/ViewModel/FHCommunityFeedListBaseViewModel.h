//
//  FHCommunityFeedListBaseViewModel.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import <Foundation/Foundation.h>
#import "FHCommunityFeedListController.h"
#import <TTHttpTask.h>
#import "FHUGCCellManager.h"
#import <FHCommonUI/FHRefreshCustomFooter.h>
#import "FHUGCBaseCell.h"
#import "FHFeedUGCCellModel.h"
#import "FHFeedListModel.h"
#import "FHUGCConfig.h"
#import "FHUserTracker.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCommunityFeedListBaseViewModel : NSObject

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHCommunityFeedListController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, strong) FHUGCCellManager *cellManager;
@property(nonatomic, strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic, strong) NSMutableDictionary *cellHeightCaches;
@property(nonatomic, copy) NSString *categoryId;
@property(nonatomic, strong) FHUGCBaseCell *currentCell;
@property(nonatomic, strong) FHFeedUGCCellModel *currentCellModel;
@property(nonatomic, assign) BOOL needRefreshCell;
@property(nonatomic, strong) FHFeedListModel *feedListModel;
@property(nonatomic, strong) NSMutableDictionary *clientShowDict;
@property(nonatomic, assign) BOOL isRefreshingTip;


- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHCommunityFeedListController *)viewController;

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst;

- (void)refreshCurrentCell;

- (void)viewWillAppear;

@end

NS_ASSUME_NONNULL_END
