//
//  FHUGCFullScreenVideoCell.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/8/9.
//

#import "FHUGCBaseCell.h"
#import "TTVFeedListItem.h"

NS_ASSUME_NONNULL_BEGIN

@class TTVFeedCellSelectContext;

@interface FHUGCFullScreenVideoCell : FHUGCBaseCell

@property(nonatomic ,strong) TTVFeedListItem *videoItem;

- (void)willDisplay;

- (void)endDisplay;

- (void)didSelectCell:(TTVFeedCellSelectContext *)context;

@end

NS_ASSUME_NONNULL_END
