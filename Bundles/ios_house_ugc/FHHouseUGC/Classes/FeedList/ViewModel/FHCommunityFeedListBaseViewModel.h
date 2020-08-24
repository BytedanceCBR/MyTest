//
//  FHCommunityFeedListBaseViewModel.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import <Foundation/Foundation.h>
#import "FHCommunityFeedListController.h"
#import "TTHttpTask.h"
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
#import "TTVFeedListItem.h"
#import "TTReachability.h"
#import "FHUGCFeedDetailJumpManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCommunityFeedListBaseViewModel : NSObject

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, weak) FHCommunityFeedListController *viewController;
@property(nonatomic, weak) TTHttpTask *requestTask;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, strong) FHUGCCellManager *cellManager;
@property(nonatomic, strong) FHUGCFeedDetailJumpManager *detailJumpManager;
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


- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHCommunityFeedListController *)viewController;

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst;

- (void)refreshCurrentCell;

- (void)refreshCell:(FHFeedUGCCellModel *)cellModel;

- (NSInteger)getCellIndex:(FHFeedUGCCellModel *)cellModel;

// 小视频
- (UIView *)currentSelectSmallVideoView;

- (CGRect)selectedSmallVideoFrame;

- (void)viewWillAppear;

- (void)viewWillDisappear;

- (void)recordGroupWithCellModel:(FHFeedUGCCellModel *)cellModel status:(SSImpressionStatus)status;

- (void)endDisplay;

- (void)showCustomErrorView:(FHEmptyMaskViewType)type;
// 更新发帖进度视图
- (void)updateJoinProgressView;

- (void)stopCurrentVideo;

- (void)startVideoPlay;

@end

NS_ASSUME_NONNULL_END
