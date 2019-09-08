//
//  FHUGCVideoView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/9/6.
//

#import <UIKit/UIKit.h>
#import "TTImageView.h"
#import "FHUGCVideoItem.h"
#import "TTAlphaThemedButton.h"
#import "TTVFeedContainerBaseView.h"
#import "TTVFullscreenProtocol.h"
@class FHUGCCellPlayMovie;
@protocol TTVCellPlayMovieProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCVideoView : TTVFeedContainerBaseView<TTVFullscreenCellProtocol>

@property (nonatomic, strong) TTVFeedListItem *cellEntity;
@property (nonatomic, strong, readonly) TTImageView *logo;
@property (nonatomic, strong, readonly) SSThemedLabel *videoRightBottomLabel; //默认显示时间
@property (nonatomic, strong, readonly) TTAlphaThemedButton *playButton;
@property (nonatomic ,strong, readonly) FHUGCCellPlayMovie *playMovie;
@property (nonatomic, copy) void (^ttv_shareButtonOnMovieFinishViewDidPressBlock)();
@property (nonatomic, copy) void (^ttv_movieViewWillMoveToSuperViewBlock)(UIView * newView, BOOL animated);
@property (nonatomic, copy) void (^ttv_shareButtonOnMovieTopViewDidPressBlock)();
@property (nonatomic, copy) void (^ttv_moreButtonOnMovieTopViewDidPressBlock)();
@property (nonatomic, copy) void (^ttv_DirectShareOnMovieFinishViewDidPressBlock)(NSString *activityType);
@property (nonatomic, copy) void (^ttv_DirectShareOnMovieViewDidPressBlock)(NSString *activityType);
@property (nonatomic, copy) void (^ttv_commodityViewClosedBlock)();
@property (nonatomic, copy) void (^ttv_commodityViewShowedBlock)();
@property (nonatomic, copy) void (^ttv_playVideoBlock)();
@property (nonatomic, copy) void (^ttv_videoPlayFinishedBlock)();
@property (nonatomic, copy) void (^ttv_videoReplayActionBlock)();

+ (CGFloat)obtainHeightForFeed:(TTVFeedListItem *)cellEntity cellWidth:(CGFloat)width;
- (void)playButtonClicked;
- (void)addCommodity;

@end

NS_ASSUME_NONNULL_END


