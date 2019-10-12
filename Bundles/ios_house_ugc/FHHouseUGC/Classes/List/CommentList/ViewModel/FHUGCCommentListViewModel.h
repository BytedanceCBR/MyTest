//
//  FHUGCCommentListViewModel.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/10/11.
//

#import <Foundation/Foundation.h>
#import "FHUGCCommentListController.h"
#import <TTHttpTask.h>
#import "FHUGCCellManager.h"
#import <FHCommonUI/FHRefreshCustomFooter.h>
#import "FHUGCBaseCell.h"
#import "FHFeedUGCCellModel.h"
#import "FHFeedListModel.h"
#import "FHUGCConfig.h"
#import "FHUserTracker.h"
#import "TSVShortVideoDetailExitManager.h"
#import "HTSVideoPageParamHeader.h"
#import "AWEVideoConstants.h"
#import <TTVFeedListItem.h>
#import <TTReachability.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCCommentListViewModel : NSObject

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHUGCCommentListController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, strong) FHUGCCellManager *cellManager;
@property(nonatomic, strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic, copy) NSString *categoryId;
@property(nonatomic, strong) FHUGCBaseCell *currentCell;
@property(nonatomic, strong) FHFeedUGCCellModel *currentCellModel;
@property(nonatomic, assign) BOOL needRefreshCell;
@property(nonatomic, strong) FHFeedListModel *feedListModel;
@property(nonatomic, strong) NSMutableDictionary *clientShowDict;
@property(nonatomic, assign) BOOL isRefreshingTip;
@property(nonatomic, assign) NSInteger refer;
@property(nonatomic, assign) BOOL isShowing;
//视频相关
@property(nonatomic, strong) NSMutableArray *movieViews;
@property(nonatomic, strong) UIView *movieView;
@property(nonatomic, strong) FHFeedUGCCellModel *movieViewCellData;
@property(nonatomic, copy) NSString *socialGroupId;


- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHUGCCommentListController *)viewController;

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst;

- (void)refreshCurrentCell;

- (void)refreshCell:(FHFeedUGCCellModel *)cellModel;

- (NSInteger)getCellIndex:(FHFeedUGCCellModel *)cellModel;

// 小视频
- (UIView *)currentSelectSmallVideoView;

- (CGRect)selectedSmallVideoFrame;

- (void)viewWillAppear;

- (void)viewWillDisappear;

- (void)endDisplay;

@end

NS_ASSUME_NONNULL_END
