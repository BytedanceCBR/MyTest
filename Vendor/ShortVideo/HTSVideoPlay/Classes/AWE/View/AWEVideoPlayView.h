//
//  AWEVideoPlayView.h
//  Pods
//
//  Created by 01 on 17/5/3.
//
//

#import <UIKit/UIKit.h>
#import "ExploreMovieMiniSliderView.h"
#import "FHFeedUGCCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@class TTShortVideoModel;
@class AWEVideoPlayView;
@protocol AWEVideoPlayViewDelegate <NSObject>
@optional
- (void)playView:(AWEVideoPlayView *)view didStartPlayWithModel:(FHFeedUGCCellModel *)model;
- (void)playView:(AWEVideoPlayView *)view didPlayNextLoopWithModel:(FHFeedUGCCellModel *)model;
/** 返回duration后会清零 */
- (void)playView:(AWEVideoPlayView *)view didPausePlayWithModel:(FHFeedUGCCellModel *)model duration:(NSTimeInterval)duration;
- (void)playView:(AWEVideoPlayView *)view didResumePlayWithModel:(FHFeedUGCCellModel *)model duration:(NSTimeInterval)duration;
/** 返回duration后会清零 */
- (void)playView:(AWEVideoPlayView *)view didStopPlayWithModel:(FHFeedUGCCellModel *)model duration:(NSTimeInterval)duration;
- (void)playView:(AWEVideoPlayView *)view didClickInputWithModel:(FHFeedUGCCellModel *)model;
- (void)playView:(AWEVideoPlayView *)view didClickCommentWithModel:(FHFeedUGCCellModel *)model;
- (void)playView:(AWEVideoPlayView *)view didClickLikeWithModel:(FHFeedUGCCellModel *)model;
- (void)playView:(AWEVideoPlayView *)view didClickMoreWithModel:(FHFeedUGCCellModel *)model;
- (void)playView:(AWEVideoPlayView *)view didDoubleTapWithModel:(FHFeedUGCCellModel *)model;
- (void)playView:(AWEVideoPlayView *)view didUpdateFrame:(CGRect)theNewFrame;

@end


@interface AWEVideoPlayView : UIView

@property (nonatomic, strong, readonly) FHFeedUGCCellModel *model;
@property (nonatomic, assign, readonly) BOOL isPlaying;
@property (nonatomic, copy, nullable) NSDictionary *commonTrackingParameter;
@property (nonatomic, readonly, assign) NSTimeInterval videoDuration;
@property (nonatomic, weak, nullable) id<AWEVideoPlayViewDelegate> delegate;
@property(nonatomic, strong)ExploreMovieMiniSliderView * miniSlider;
/// 自动改变frame以适配视频大小，默认YES
@property (nonatomic, assign) BOOL autoAdjustViewFrame;

- (void)updateWithModel:(FHFeedUGCCellModel *)model usingFirstFrameCover:(BOOL)usingFirstFrameCover;

- (void)prepareToPlay;

- (void)play;

- (void)stop;

- (void)pause;

- (void)pauseOrPlayVideo;

@end

NS_ASSUME_NONNULL_END
