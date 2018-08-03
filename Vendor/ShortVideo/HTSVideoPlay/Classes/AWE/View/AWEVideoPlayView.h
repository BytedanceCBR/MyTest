//
//  AWEVideoPlayView.h
//  Pods
//
//  Created by 01 on 17/5/3.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TTShortVideoModel;
@class AWEVideoPlayView;
@protocol AWEVideoPlayViewDelegate <NSObject>
@optional
- (void)playView:(AWEVideoPlayView *)view didStartPlayWithModel:(TTShortVideoModel *)model;
- (void)playView:(AWEVideoPlayView *)view didPlayNextLoopWithModel:(TTShortVideoModel *)model;
/** 返回duration后会清零 */
- (void)playView:(AWEVideoPlayView *)view didPausePlayWithModel:(TTShortVideoModel *)model duration:(NSTimeInterval)duration;
- (void)playView:(AWEVideoPlayView *)view didResumePlayWithModel:(TTShortVideoModel *)model duration:(NSTimeInterval)duration;
/** 返回duration后会清零 */
- (void)playView:(AWEVideoPlayView *)view didStopPlayWithModel:(TTShortVideoModel *)model duration:(NSTimeInterval)duration;
- (void)playView:(AWEVideoPlayView *)view didClickInputWithModel:(TTShortVideoModel *)model;
- (void)playView:(AWEVideoPlayView *)view didClickCommentWithModel:(TTShortVideoModel *)model;
- (void)playView:(AWEVideoPlayView *)view didClickLikeWithModel:(TTShortVideoModel *)model;
- (void)playView:(AWEVideoPlayView *)view didClickMoreWithModel:(TTShortVideoModel *)model;
- (void)playView:(AWEVideoPlayView *)view didDoubleTapWithModel:(TTShortVideoModel *)model;
- (void)playView:(AWEVideoPlayView *)view didUpdateFrame:(CGRect)theNewFrame;

@end


@interface AWEVideoPlayView : UIView

@property (nonatomic, strong, readonly) TTShortVideoModel *model;
@property (nonatomic, assign, readonly) BOOL isPlaying;
@property (nonatomic, copy, nullable) NSDictionary *commonTrackingParameter;
@property (nonatomic, readonly, assign) NSTimeInterval videoDuration;
@property (nonatomic, weak, nullable) id<AWEVideoPlayViewDelegate> delegate;
/// 自动改变frame以适配视频大小，默认YES
@property (nonatomic, assign) BOOL autoAdjustViewFrame;

- (void)updateWithModel:(TTShortVideoModel *)model usingFirstFrameCover:(BOOL)usingFirstFrameCover;

- (void)prepareToPlay;

- (void)play;

- (void)stop;

- (void)pause;

@end

NS_ASSUME_NONNULL_END
