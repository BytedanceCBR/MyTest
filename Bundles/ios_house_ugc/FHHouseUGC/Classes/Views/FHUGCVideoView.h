//
//  FHUGCVideoView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/9/6.
//

#import <UIKit/UIKit.h>
#import "TTImageView.h"
#import "TTVFeedListItem.h"
#import "TTAlphaThemedButton.h"
#import "TTVFeedContainerBaseView.h"
#import "TTVFullscreenProtocol.h"
#import "TTVPlayerControllerState.h"

@class TTVCellPlayMovie;
@protocol TTVCellPlayMovieProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCVideoView : TTVFeedContainerBaseView<TTVFullscreenCellProtocol>

@property (nonatomic, strong) TTVFeedListItem *cellEntity;
@property (nonatomic, strong, readonly) TTImageView *logo;
@property (nonatomic, strong, readonly) SSThemedLabel *videoRightBottomLabel; //默认显示时间
@property (nonatomic, strong, readonly) TTAlphaThemedButton *playButton;
@property (nonatomic ,strong, readonly) TTVCellPlayMovie *playMovie;
@property (nonatomic, copy) void (^ttv_shareButtonOnMovieFinishViewDidPressBlock)(void);
@property (nonatomic, copy) void (^ttv_movieViewWillMoveToSuperViewBlock)(UIView * newView, BOOL animated);
@property (nonatomic, copy) void (^ttv_shareButtonOnMovieTopViewDidPressBlock)(void);
@property (nonatomic, copy) void (^ttv_moreButtonOnMovieTopViewDidPressBlock)(void);
@property (nonatomic, copy) void (^ttv_DirectShareOnMovieFinishViewDidPressBlock)(NSString *activityType);
@property (nonatomic, copy) void (^ttv_DirectShareOnMovieViewDidPressBlock)(NSString *activityType);
@property (nonatomic, copy) void (^ttv_commodityViewClosedBlock)(void);
@property (nonatomic, copy) void (^ttv_commodityViewShowedBlock)(void);
@property (nonatomic, copy) void (^ttv_playVideoBlock)(void);
@property (nonatomic, copy ,nullable) void (^ttv_videoPlayFinishedBlock)(void);
@property (nonatomic, copy) void (^ttv_videoReplayActionBlock)(void);
@property (nonatomic, copy ,nullable) void (^ttv_playButtonClickedBlock)(void);
@property (nonatomic, copy) void (^ttv_playerPlaybackStateBlock)(TTVVideoPlaybackState state);
@property (nonatomic, copy) void (^ttv_playerCurrentPlayBackTimeChangeBlock)(NSTimeInterval currentPlayBackTime,NSTimeInterval duration);

+ (CGFloat)obtainHeightForFeed:(TTVFeedListItem *)cellEntity cellWidth:(CGFloat)width;
- (void)playButtonClicked;
- (void)playVideo;
- (void)addCommodity;
- (void)setMuted:(BOOL)muted;

@end

NS_ASSUME_NONNULL_END


