//
//  FHUGCFullScreenVideoCell.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/8/9.
//

#import "FHUGCBaseCell.h"
#import "TTVFeedListItem.h"
#import "FHUGCVideoView.h"

NS_ASSUME_NONNULL_BEGIN

@class TTVFeedCellSelectContext;

@interface FHUGCFullScreenVideoCell : FHUGCBaseCell

@property(nonatomic ,strong) TTVFeedListItem *videoItem;
@property(nonatomic ,strong) FHUGCVideoView *videoView;
@property(nonatomic ,strong) UIButton *muteBtn;

- (void)willDisplay;

- (void)endDisplay;

- (void)didSelectCell:(TTVFeedCellSelectContext *)context;

- (void)play;

- (BOOL)cell_isPlaying;

- (void)showMutedBtn;

@end

NS_ASSUME_NONNULL_END
