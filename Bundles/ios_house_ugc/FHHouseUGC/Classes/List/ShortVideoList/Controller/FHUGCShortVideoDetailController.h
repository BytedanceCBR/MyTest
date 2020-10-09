//
//  FHUGCShortVideoDetailController.h
//  FHHouseUGC
//
//  Created by liuyu on 2020/9/18.
//

#import "FHBaseViewController.h"
#import "SSThemed.h"
#import "FHFeedUGCCellModel.h"
@class TTShortVideoModel;
@class AWEVideoDetailViewController;
NS_ASSUME_NONNULL_BEGIN

@interface FHUGCShortVideoDetailController : FHBaseViewController


@property (nonatomic, strong, readonly) UITableView *tableView;

@property (nonatomic, strong, readonly) SSThemedView *commentView;

@property (nonatomic, strong, readonly) FHFeedUGCCellModel *model;
@end

NS_ASSUME_NONNULL_END
