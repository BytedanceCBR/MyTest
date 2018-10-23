//
//  TTVFeedListCell.h
//  Article
//
//  Created by panxiang on 2017/3/3.
//
//

#import "TTBaseCell.h"
#import "TTVideoFeedListEnum.h"
#import "TTVTableViewItem.h"
#import "TTVFeedListItem.h"
#import "TTVFeedCellAppear.h"
#import "TTVFeedPlayMovie.h"
#import "TTVFullscreenProtocol.h"
#import "TTVAutoPlayManager.h"

extern CGFloat ttv_feedContainerWidth(CGFloat contentViewWidth);
extern CGFloat adBottomContainerViewHeight(void);
extern CGFloat ttv_bottomPaddingViewHeight(void);

@class TTVFeedListTopImageContainerView;
@interface TTVFeedListCell : TTVTableViewCell<TTVFeedPlayMovie ,TTVFeedCellAppear ,TTVFullscreenCellProtocol ,TTVAutoPlayingCell>
@property(nonatomic ,assign) BOOL  hasRead;//记录已读状态
@property (nonatomic, strong) TTVFeedListItem *item;

@property (nonatomic, strong) UIView *bottomPaddingView;
@property (nonatomic, strong) UIView *separatorLineView;

@property (nonatomic, strong) TTVFeedListTopImageContainerView *topMovieContainerView;
@property (nonatomic, strong, readonly) UIView *containerView;

@end



